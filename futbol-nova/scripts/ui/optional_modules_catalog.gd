extends CanvasLayer
class_name NovaOptionalModulesCatalog

signal catalog_closed

const CATALOG_PATH := "res://data/optional_modules_catalog.json"
const DOWNLOAD_ICON := "⬇"

var _root_panel: PanelContainer
var _list: VBoxContainer
var _status: Label
var _modules: Array = []

func _ready() -> void:
	_build_ui()
	_load_catalog()
	if not ContentPackages.package_installed.is_connected(_on_package_installed):
		ContentPackages.package_installed.connect(_on_package_installed)
	if not ContentPackages.package_failed.is_connected(_on_package_failed):
		ContentPackages.package_failed.connect(_on_package_failed)
	if not ContentPackages.package_progress.is_connected(_on_package_progress):
		ContentPackages.package_progress.connect(_on_package_progress)

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.045, 0.92)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	_root_panel = PanelContainer.new()
	_root_panel.anchor_left = 0.06
	_root_panel.anchor_top = 0.06
	_root_panel.anchor_right = 0.94
	_root_panel.anchor_bottom = 0.94
	add_child(_root_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	_root_panel.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	title.text = "FÚTBOL NOVA · AGREGADOS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "Cerrar"
	close_button.pressed.connect(_close)
	header.add_child(close_button)
	var description := Label.new()
	description.text = "Instala solo las funciones adicionales que quieras. El juego base sigue funcionando sin estos módulos."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	_status = Label.new()
	_status.text = "Los agregados se verifican antes de activarse."
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status)

func _load_catalog() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		_status.text = "No se encontró el catálogo de agregados."
		return
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		_status.text = "No se pudo abrir el catálogo de agregados."
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary) or not (parsed.get("modules", []) is Array):
		_status.text = "El catálogo de agregados no es válido."
		return
	_modules = parsed.get("modules", [])
	_refresh_rows()

func _refresh_rows() -> void:
	for child in _list.get_children():
		child.queue_free()
	var installed := ContentPackages.get_installed_packages()
	for item in _modules:
		if not (item is Dictionary):
			continue
		var module: Dictionary = item
		var package: Dictionary = module.get("package", {})
		var package_id := str(module.get("package_id", package.get("package_id", "")))
		var is_installed := not package_id.is_empty() and installed.has(package_id)
		var row := PanelContainer.new()
		_list.add_child(row)
		var content := VBoxContainer.new()
		row.add_child(content)
		var heading := HBoxContainer.new()
		content.add_child(heading)
		var name := Label.new()
		name.text = DOWNLOAD_ICON + "  " + str(module.get("name", "Módulo"))
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name.add_theme_font_size_override("font_size", 17)
		heading.add_child(name)
		var state := Label.new()
		state.text = "Instalado" if is_installed else _state_label(module, package)
		heading.add_child(state)
		var details := Label.new()
		details.text = str(module.get("role", module.get("description", "")))
		var dependencies: Array = module.get("dependencies", package.get("dependencies", []))
		if not dependencies.is_empty():
			details.text += "\nRequiere también: " + ", ".join(PackedStringArray(dependencies))
		details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(details)
		var action := Button.new()
		action.size_flags_horizontal = Control.SIZE_SHRINK_END
		if is_installed:
			action.text = "Desinstalar"
			action.pressed.connect(_uninstall.bind(package_id))
			content.add_child(action)
		elif bool(package.get("downloadable", false)) and str(package.get("content_status", "")) == "published":
			action.text = DOWNLOAD_ICON + " Descargar"
			action.pressed.connect(_download.bind(module))
			content.add_child(action)
		else:
			action.text = "En preparación"
			action.disabled = true
			content.add_child(action)

func _state_label(module: Dictionary, package: Dictionary) -> String:
	var status := str(package.get("content_status", module.get("status", "planned")))
	match status:
		"published":
			return "Disponible"
		"testing":
			return "En pruebas"
		"in_development":
			return "En desarrollo"
		_:
			return "En preparación"

func _download(module: Dictionary) -> void:
	var packages: Array[Dictionary] = []
	var visiting: Array[String] = []
	var collected_ids: Array[String] = []
	var errors := PackedStringArray()
	var module_id := str(module.get("id", ""))
	if not _collect_module_downloads(module_id, visiting, collected_ids, packages, errors):
		_status.text = "No se inició ninguna descarga: " + "; ".join(errors)
		_refresh_rows()
		return
	for package in packages:
		var validation: Dictionary = ContentPackages.validate_package(package)
		if not bool(validation.get("ok", false)):
			_status.text = "No se inició ninguna descarga: " + str(validation.get("error", "Paquete dependiente inválido"))
			_refresh_rows()
			return
	var result: Dictionary = ContentPackages.enqueue_packages(packages)
	if result.get("rejected", []).is_empty():
		_status.text = "Se añadieron %d paquetes a la misma cola de instalación. Primero se descargarán las ligas regionales y después el TAS. Cada archivo se verificará antes de instalarse." % int(result.get("accepted", 0))
	else:
		_status.text = "La cola rechazó algunos paquetes: " + ", ".join(PackedStringArray(result.get("rejected", [])))
	_refresh_rows()

func _collect_module_downloads(module_id: String, visiting: Array[String], collected_ids: Array[String], packages: Array[Dictionary], errors: PackedStringArray) -> bool:
	if visiting.has(module_id):
		errors.append("Se detectó una dependencia circular: " + module_id)
		return false
	if collected_ids.has(module_id):
		return true
	var module: Dictionary = {}
	for item in _modules:
		if item is Dictionary and str(item.get("id", "")) == module_id:
			module = item
			break
	if module.is_empty():
		errors.append("No se encontró el módulo requerido: " + module_id)
		return false
	var package: Dictionary = module.get("package", {})
	if package.is_empty():
		errors.append("El módulo no tiene ficha de paquete: " + module_id)
		return false
	var package_id := str(package.get("package_id", module.get("package_id", module_id)))
	var installed_record: Dictionary = ContentPackages.get_installed_packages().get(package_id, {})
	if not installed_record.is_empty() and str(installed_record.get("version", "")) == str(package.get("version", "")):
		collected_ids.append(module_id)
		return true
	if str(package.get("content_status", "")) != "published" or not bool(package.get("downloadable", false)):
		errors.append("La dependencia todavía no está publicada y validada: " + str(module.get("name", module_id)))
		return false
	visiting.append(module_id)
	var dependencies: Array = module.get("dependencies", package.get("dependencies", []))
	for dependency in dependencies:
		if not _collect_module_downloads(str(dependency), visiting, collected_ids, packages, errors):
			visiting.pop_back()
			return false
	visiting.pop_back()
	collected_ids.append(module_id)
	packages.append(package.duplicate(true))
	return true

func _uninstall(package_id: String) -> void:
	var installed := ContentPackages.get_installed_packages()
	for module in _modules:
		if not (module is Dictionary):
			continue
		var dependencies: Array = module.get("dependencies", module.get("package", {}).get("dependencies", []))
		var dependent_package_id := str(module.get("package_id", module.get("package", {}).get("package_id", "")))
		if dependencies.has(package_id) and installed.has(dependent_package_id):
			_status.text = "No se puede desinstalar esta liga mientras esté instalado el módulo dependiente " + str(module.get("name", dependent_package_id)) + ". Desinstala primero el módulo dependiente."
			_refresh_rows()
			return
	var result: Dictionary = ContentPackages.uninstall_package(package_id)
	_status.text = "Módulo desinstalado." if bool(result.get("ok", false)) else str(result.get("error", "No se pudo desinstalar."))
	_refresh_rows()

func _on_package_installed(package_id: String, _path: String) -> void:
	_status.text = "Módulo instalado y verificado: " + package_id
	_refresh_rows()

func _on_package_failed(package_id: String, reason: String) -> void:
	_status.text = "No se pudo instalar " + package_id + ": " + reason
	_refresh_rows()

func _on_package_progress(package_id: String, downloaded: int, total: int) -> void:
	if total > 0:
		_status.text = "Descargando %s: %d%%" % [package_id, int(100.0 * float(downloaded) / float(total))]
	else:
		_status.text = "Descargando " + package_id + "…"

func _close() -> void:
	catalog_closed.emit()
	queue_free()
