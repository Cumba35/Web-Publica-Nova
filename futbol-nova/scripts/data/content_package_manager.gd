extends Node
class_name NovaContentPackageManager

signal package_progress(package_id: String, downloaded_bytes: int, total_bytes: int)
signal package_installed(package_id: String, installed_path: String)
signal package_failed(package_id: String, reason: String)
signal queue_changed(pending_count: int, paused: bool)

const DOWNLOAD_ROOT := "user://futbol_nova/downloads"
const CONTENT_ROOT := "user://futbol_nova/packages"
const INSTALLED_INDEX := "user://futbol_nova/installed_packages.json"
const HTTP_TIMEOUT := 90.0
const MAX_UNPACKED_PACKAGE_BYTES := 536870912

var _http: HTTPRequest
var _queue: Array[Dictionary] = []
var _active_package: Dictionary = {}
var _active_temp_path := ""
var _queue_paused := false
var _retry_package: Dictionary = {}

func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = HTTP_TIMEOUT
	_http.max_redirects = 0 # No seguir redirecciones fuera del repositorio autorizado de NOVA.
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	set_process(true)
	_ensure_storage()

func enqueue_package(package: Dictionary) -> bool:
	var validation := _validate_package(package)
	if not bool(validation.get("ok", false)):
		package_failed.emit(str(package.get("package_id", "")), str(validation.get("error", "Paquete inválido")))
		return false
	var package_id := str(package.package_id)
	if _is_installed(package_id, str(package.get("version", ""))):
		return true
	for queued in _queue:
		if str(queued.get("package_id", "")) == package_id:
			return true
	if str(_active_package.get("package_id", "")) == package_id:
		return true
	_queue.append(package.duplicate(true))
	queue_changed.emit(_queue.size(), _queue_paused)
	_start_next()
	return true

func enqueue_packages(packages: Array) -> Dictionary:
	var accepted := 0
	var rejected: Array[String] = []
	for item in packages:
		if item is Dictionary and enqueue_package(item):
			accepted += 1
		else:
			rejected.append(str(item.get("package_id", "unknown")) if item is Dictionary else "invalid")
	return {"accepted": accepted, "rejected": rejected}

func pause_queue() -> void:
	_queue_paused = true
	queue_changed.emit(_queue.size(), _queue_paused)

func resume_queue() -> void:
	_queue_paused = false
	queue_changed.emit(_queue.size(), _queue_paused)
	_start_next()

func cancel_active_download() -> void:
	if _active_package.is_empty():
		return
	var package_id := str(_active_package.get("package_id", ""))
	_http.cancel_request()
	if FileAccess.file_exists(_active_temp_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_active_temp_path))
	_active_package.clear()
	_active_temp_path = ""
	package_failed.emit(package_id, "Descarga cancelada por el usuario")
	_start_next()

func retry_last_failed() -> bool:
	if _retry_package.is_empty():
		return false
	var package := _retry_package.duplicate(true)
	_retry_package.clear()
	return enqueue_package(package)

func get_installed_packages() -> Dictionary:
	if not FileAccess.file_exists(INSTALLED_INDEX):
		return {}
	var file := FileAccess.open(INSTALLED_INDEX, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func is_package_installed(package_id: String) -> bool:
	return get_installed_packages().has(package_id)

func uninstall_package(package_id: String) -> Dictionary:
	var installed := get_installed_packages()
	if not installed.has(package_id):
		return {"ok": false, "error": "El paquete no está instalado"}
	for installed_id in installed:
		if str(installed_id) == package_id:
			continue
		var installed_record: Dictionary = installed[installed_id]
		var required_dependencies: Array = installed_record.get("dependencies", [])
		if required_dependencies.has(package_id):
			return {"ok": false, "error": "No se puede desinstalar %s: el módulo instalado %s depende de él." % [package_id, str(installed_id)]}
	var record: Dictionary = installed[package_id]
	var path := str(record.get("installed_path", ""))
	if path.is_empty() or not path.begins_with(CONTENT_ROOT + "/") or path.contains(".."):
		return {"ok": false, "error": "Ruta de instalación no válida"}
	_remove_tree(path)
	installed.erase(package_id)
	var save_error := _write_json(INSTALLED_INDEX, installed)
	return {"ok": save_error == OK, "error": "No se pudo actualizar el índice" if save_error != OK else ""}

func _process(_delta: float) -> void:
	if not _active_package.is_empty() and _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		var total := _http.get_body_size()
		package_progress.emit(str(_active_package.package_id), _http.get_downloaded_bytes(), total)

func _start_next() -> void:
	if _queue_paused or not _active_package.is_empty() or _queue.is_empty():
		return
	_active_package = _queue.pop_front()
	var package_id := str(_active_package.get("package_id", ""))
	var installed_dependencies := get_installed_packages()
	for dependency_id in _active_package.get("dependencies", []):
		var dependency_key := str(dependency_id)
		if not installed_dependencies.has(dependency_key):
			_fail_active("Falta la dependencia obligatoria %s; se cancela la instalación de %s." % [dependency_key, package_id])
			return
		var required_versions: Dictionary = _active_package.get("dependency_versions", {})
		var required_version := str(required_versions.get(dependency_key, ""))
		var installed_version := str(installed_dependencies[dependency_key].get("version", ""))
		if not required_version.is_empty() and installed_version != required_version:
			_fail_active("La dependencia %s necesita la versión %s; se cancela la instalación de %s." % [dependency_key, required_version, package_id])
			return
	_active_temp_path = DOWNLOAD_ROOT + "/" + package_id + ".part"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DOWNLOAD_ROOT))
	if FileAccess.file_exists(_active_temp_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_active_temp_path))
	_http.body_size_limit = mini(int(_active_package.get("download_size_bytes", 0)) + 1024, 2147483647)
	_http.download_file = _active_temp_path
	var error := _http.request(str(_active_package.get("download_url", "")))
	if error != OK:
		_fail_active("No se pudo iniciar la descarga (código %d)" % error)
	queue_changed.emit(_queue.size(), _queue_paused)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if _active_package.is_empty():
		return
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_fail_active("Error HTTP: resultado %d, código %d" % [result, response_code])
		return
	var expected := str(_active_package.get("checksum_sha256", "")).to_lower()
	var downloaded_file := FileAccess.open(_active_temp_path, FileAccess.READ)
	if downloaded_file == null:
		_fail_active("No se pudo abrir el archivo descargado")
		return
	var actual_size := downloaded_file.get_length()
	downloaded_file.close()
	if actual_size != int(_active_package.get("download_size_bytes", -1)):
		_fail_active("El tamaño descargado no coincide con el manifiesto")
		return
	var actual := FileAccess.get_sha256(_active_temp_path).to_lower()
	if actual.is_empty() or actual != expected:
		_fail_active("La verificación SHA-256 no coincide")
		return
	var package_id := str(_active_package.package_id)
	var version := str(_active_package.get("version", "1.0.0"))
	var final_path := CONTENT_ROOT + "/" + package_id + "/" + version
	var staging_path := final_path + ".staging"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(staging_path))
	var format := str(_active_package.get("content_format", "zip")).to_lower()
	var install_error := OK
	if format == "zip":
		install_error = _extract_zip_safely(_active_temp_path, staging_path)
	elif format == "json":
		var filename := str(_active_package.get("content_filename", "content.json"))
		if filename.contains("/") or filename.contains("..") or filename.contains(":"):
			install_error = ERR_INVALID_DATA
		else:
			var target := staging_path + "/" + filename
			var source := FileAccess.open(_active_temp_path, FileAccess.READ)
			if source == null:
				install_error = ERR_CANT_OPEN
			else:
				install_error = _write_bytes(target, source.get_buffer(source.get_length()))
	else:
		install_error = ERR_INVALID_DATA
	if install_error != OK:
		_remove_tree(staging_path)
		_fail_active("No se pudo instalar el contenido (código %d)" % install_error)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(final_path.get_base_dir()))
	var final_absolute := ProjectSettings.globalize_path(final_path)
	if DirAccess.dir_exists_absolute(final_absolute):
		_remove_tree(staging_path)
		_fail_active("Ya existe una instalación con esa versión; se conserva el contenido anterior")
		return
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(staging_path), final_absolute)
	if rename_error != OK:
		_remove_tree(staging_path)
		_fail_active("No se pudo completar la instalación atómica")
		return
	var installed := get_installed_packages()
	installed[package_id] = {
		"version": version,
		"installed_path": final_path,
		"installed_at_unix": int(Time.get_unix_time_from_system()),
		"checksum_sha256": expected,
		"region_id": str(_active_package.get("region_id", "")),
		"competition_id": str(_active_package.get("competition_id", "")),
		"content_type": str(_active_package.get("content_type", "league")), 
		"country_code": str(_active_package.get("country_code", "")),
		"confederation": str(_active_package.get("confederation", "")),
		"dependencies": _active_package.get("dependencies", []).duplicate(true)
	}
	var save_error := _write_json(INSTALLED_INDEX, installed)
	if save_error != OK:
		_remove_tree(final_path)
		_fail_active("No se pudo registrar la instalación")
		return
	if FileAccess.file_exists(_active_temp_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_active_temp_path))
	package_installed.emit(package_id, final_path)
	_active_package.clear()
	_active_temp_path = ""
	_start_next()

func validate_package(package: Dictionary) -> Dictionary:
	return _validate_package(package)

func _validate_package(package: Dictionary) -> Dictionary:
	var package_id := str(package.get("package_id", ""))
	var url := str(package.get("download_url", ""))
	var download_size := int(package.get("download_size_bytes", 0))
	var checksum := str(package.get("checksum_sha256", ""))
	if package_id.is_empty() or package_id.contains("/") or package_id.contains(".."):
		return {"ok": false, "error": "Identificador de paquete no válido"}
	if str(package.get("content_status", "")) != "published" or not bool(package.get("downloadable", false)):
		return {"ok": false, "error": "El paquete todavía no está publicado y validado"}
	var content_type := str(package.get("content_type", "league"))
	if not ["league", "national_teams", "input_extension", "graphics_module", "realism_module", "continental_competition_module"].has(content_type):
		return {"ok": false, "error": "Tipo de paquete no compatible"}
	if not _is_nova_github_url(url):
		return {"ok": false, "error": "Solo se permiten paquetes alojados en el repositorio GitHub autorizado de NOVA"}
	if download_size <= 0 or download_size > 2147483647:
		return {"ok": false, "error": "Tamaño de descarga ausente o fuera de límites"}
	if checksum.length() != 64 or not checksum.is_valid_hex_number(false):
		return {"ok": false, "error": "Falta un checksum SHA-256 válido"}
	var version := str(package.get("version", ""))
	if version.is_empty() or version.contains("/") or version.contains(".."):
		return {"ok": false, "error": "Versión de paquete no válida"}
	return {"ok": true}


func _is_nova_github_url(url: String) -> bool:
	# Descargas de contenido: solo archivos del repositorio canónico de Workspace.
	# Se rechazan dominios parecidos, proveedores externos y URLs de otros repos.
	return url.begins_with("https://raw.githubusercontent.com/Cumba35/Nova-Workspace/") or url.begins_with("https://github.com/Cumba35/Nova-Workspace/releases/download/")

func _is_installed(package_id: String, version: String) -> bool:
	var installed := get_installed_packages()
	return installed.has(package_id) and str(installed[package_id].get("version", "")) == version

func _extract_zip_safely(zip_path: String, destination: String) -> int:
	var reader := ZIPReader.new()
	var open_error := reader.open(zip_path)
	if open_error != OK:
		return open_error
	var total_unpacked := 0
	for entry in reader.get_files():
		var name := str(entry).replace("\\", "/")
		var path_parts := name.split("/")
		var unsafe_path := name.begins_with("/") or name.contains(":")
		for part in path_parts:
			if part == ".." or part == ".":
				unsafe_path = true
		if unsafe_path:
			reader.close()
			return ERR_INVALID_DATA
		var target := destination.path_join(name)
		if name.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
			continue
		var file_bytes := reader.read_file(entry)
		total_unpacked += file_bytes.size()
		if total_unpacked > MAX_UNPACKED_PACKAGE_BYTES:
			reader.close()
			return ERR_INVALID_DATA
		var write_error := _write_bytes(target, file_bytes)
		if write_error != OK:
			reader.close()
			return write_error
	reader.close()
	return OK

func _write_bytes(path: String, bytes: PackedByteArray) -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(bytes)
	return file.get_error()

func _write_json(path: String, value: Dictionary) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value, "\t"))
	return file.get_error()

func _ensure_storage() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DOWNLOAD_ROOT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CONTENT_ROOT))

func _remove_tree(path: String) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	if not DirAccess.dir_exists_absolute(absolute):
		return
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child := path.path_join(entry)
			if directory.current_is_dir():
				_remove_tree(child)
			else:
				DirAccess.remove_absolute(ProjectSettings.globalize_path(child))
		entry = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(absolute)

func _fail_active(reason: String) -> void:
	var failed := _active_package.duplicate(true)
	var package_id := str(failed.get("package_id", ""))
	if FileAccess.file_exists(_active_temp_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_active_temp_path))
	_active_package.clear()
	_active_temp_path = ""
	_retry_package = failed
	package_failed.emit(package_id, reason)
	_start_next()
