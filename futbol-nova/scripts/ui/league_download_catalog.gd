extends CanvasLayer
class_name NovaLeagueDownloadCatalog

const LEAGUE_MANIFEST := "res://data/league_content_manifest.json"
const REGION_MANIFEST := "res://data/league_regions.json"
const NATIONAL_MANIFEST := "res://data/national_teams_manifest.json"
const ASSOCIATION_DIRECTORY := "res://data/national_association_directory.json"
const MEMBERSHIP_SEED := "res://data/imports/additional_league_club_membership_2026_27.json"
var _manager: Node
var _region_filter: OptionButton
var _confederation_filter: OptionButton
var _items: ItemList
var _status: Label
var _national_status: Label
var _league_records: Array[Dictionary] = []
var _regions: Array[Dictionary] = []
var _national_data: Dictionary = {}
var _national_packages: Array[Dictionary] = []
var _club_counts_by_country: Dictionary = {}
var _association_count := 0
var _confirm_uninstall: ConfirmationDialog
var _pending_uninstall_ids: Array[String] = []

func _ready() -> void:
	_manager = get_node("/root/ContentPackages")
	_manager.package_progress.connect(_on_progress)
	_manager.package_installed.connect(_on_installed)
	_manager.package_failed.connect(_on_failed)
	_build_ui()
	_load_catalog()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.05, 0.94)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 610)
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	title.text = "FÚTBOL NOVA  ·  CONTENIDO DESCARGABLE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	header.add_child(title)
	var close := Button.new()
	close.text = "Cerrar"
	close.pressed.connect(queue_free)
	header.add_child(close)
	var intro := Label.new()
	intro.text = "Recomendación: descarga las 10 ligas siguientes por ranking (puestos 11–20) y todas las selecciones nacionales publicadas. Es opcional: el juego base no queda bloqueado."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(intro)
	_region_filter = OptionButton.new()
	_region_filter.add_item("Todas las regiones", 0)
	_region_filter.add_item("Europa", 1)
	_region_filter.add_item("Sudamérica", 2)
	_region_filter.add_item("Norteamérica, Centroamérica y Caribe", 3)
	_region_filter.add_item("África", 4)
	_region_filter.add_item("Asia", 5)
	_region_filter.add_item("Oceanía", 6)
	_region_filter.item_selected.connect(_on_region_selected)
	column.add_child(_region_filter)
	_confederation_filter = OptionButton.new()
	_confederation_filter.add_item("Todas las confederaciones")
	for code in ["AFC", "CAF", "CONCACAF", "CONMEBOL", "OFC", "UEFA"]:
		_confederation_filter.add_item(code)
	_confederation_filter.item_selected.connect(_on_confederation_selected)
	column.add_child(_confederation_filter)
	_items = ItemList.new()
	_items.select_mode = ItemList.SELECT_MULTI
	_items.custom_minimum_size = Vector2(0, 330)
	_items.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_items)
	_national_status = Label.new()
	_national_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_national_status)
	var actions := GridContainer.new()
	actions.columns = 2
	column.add_child(actions)
	var selected_button := Button.new()
	selected_button.text = "Descargar selección"
	selected_button.pressed.connect(_download_selected)
	actions.add_child(selected_button)
	var recommended_button := Button.new()
	recommended_button.text = "Descargar 10 ligas recomendadas"
	recommended_button.pressed.connect(_download_ten_recommended)
	actions.add_child(recommended_button)
	var all_button := Button.new()
	all_button.text = "Descargar todas las disponibles"
	all_button.pressed.connect(_download_all_available)
	actions.add_child(all_button)
	var pause_button := Button.new()
	pause_button.text = "Pausar cola"
	pause_button.pressed.connect(_manager.pause_queue)
	actions.add_child(pause_button)
	var resume_button := Button.new()
	resume_button.text = "Reanudar"
	resume_button.pressed.connect(_manager.resume_queue)
	actions.add_child(resume_button)
	var national_button := Button.new()
	national_button.text = "Descargar todas las selecciones disponibles"
	national_button.pressed.connect(_download_all_national_teams)
	actions.add_child(national_button)
	var retry_button := Button.new()
	retry_button.text = "Reintentar último error"
	retry_button.pressed.connect(_retry_last_failed)
	actions.add_child(retry_button)
	var uninstall_button := Button.new()
	uninstall_button.text = "Desinstalar selección"
	uninstall_button.pressed.connect(_request_uninstall_selected)
	actions.add_child(uninstall_button)
	var cancel_button := Button.new()
	cancel_button.text = "Cancelar descarga"
	cancel_button.pressed.connect(_manager.cancel_active_download)
	actions.add_child(cancel_button)
	_confirm_uninstall = ConfirmationDialog.new()
	_confirm_uninstall.title = "Desinstalar contenido"
	_confirm_uninstall.dialog_text = "Se eliminarán solo los archivos del paquete. Las partidas guardadas no se borrarán."
	_confirm_uninstall.confirmed.connect(_confirm_uninstall_selected)
	add_child(_confirm_uninstall)
	_status = Label.new()
	_status.text = "Preparando catálogo..."
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status)

func _load_catalog() -> void:
	var league_manifest := _read_json(LEAGUE_MANIFEST)
	var region_manifest := _read_json(REGION_MANIFEST)
	_national_data = _read_json(NATIONAL_MANIFEST)
	_national_packages.clear()
	for package in _national_data.get("packages", []):
		if package is Dictionary:
			_national_packages.append(package.duplicate(true))
	_regions = region_manifest.get("regions", [])
	_league_records.clear()
	var source_records: Array = []
	source_records.append_array(league_manifest.get("base_leagues", []))
	source_records.append_array(league_manifest.get("downloadable_leagues", []))
	for league in ContinentalLeagues.get_all_leagues():
		if not league is Dictionary:
			continue
		var record: Dictionary = league.duplicate(true)
		var package_id := str(record.get("package_id", ""))
		if not package_id.is_empty():
			for source in source_records:
				if source is Dictionary and str(source.get("package_id", "")) == package_id:
					var confederation_code := str(record.get("confederation_code", ""))
					var region_id := str(record.get("region_id", ""))
					record.merge(source, true)
					record["confederation_code"] = confederation_code
					record["region_id"] = region_id
					break
		_league_records.append(record)
	_load_membership_summary()
	_refresh_list()
	var national_module: Dictionary = _national_data.get("module", {})
	var national_availability: Dictionary = _national_data.get("availability", {})
	var association_directory: Dictionary = _read_json("res://data/national_association_directory.json")
	_national_status.text = "SELECCIONES NACIONALES: %s · %d asociaciones FIFA catalogadas · %d paquetes publicados. Recomendación: descargar todas las selecciones disponibles." % [str(national_module.get("name", "Módulo mundial")), _association_count, int(national_availability.get("published_packages", 0))]
	if int(national_availability.get("published_packages", 0)) == 0:
		_national_status.text += " Actualmente el catálogo está en preparación; no hay paquetes que descargar."

func _refresh_list() -> void:
	_items.clear()
	var selected_region := _selected_region_id()
	var selected_confederation := _selected_confederation_code()
	var available_count := 0
	for league in _league_records:
		if not selected_region.is_empty() and str(league.get("region_id", "")) != selected_region:
			continue
		if not selected_confederation.is_empty() and str(league.get("confederation_code", "")) != selected_confederation:
			continue
		var is_ready := bool(league.get("downloadable", false)) and str(league.get("content_status", "")) == "published"
		var package_id := str(league.get("package_id", ""))
		var installed: bool = not package_id.is_empty() and _manager.is_package_installed(package_id)
		var rank := int(league.get("rank", league.get("source_rank", 0)))
		var country_code := str(league.get("country_code", ""))
		var club_count := int(_club_counts_by_country.get(country_code, int(league.get("club_count", 0))))
		var label := (("#%02d  " % rank) if rank > 0 else "") + "%s — %s" % [str(league.get("country", "")), str(league.get("league_name", ""))]
		if club_count > 0:
			label += " · %d clubes" % club_count
		var state_label := "Instalada" if installed else ("Disponible" if is_ready else ("Incluida en el juego base · validación pendiente" if bool(league.get("counts_as_existing_base", false)) else "En preparación"))
		label += " · " + state_label
		var index := _items.add_item(label)
		_items.set_item_metadata(index, league)
		_items.set_item_disabled(index, not is_ready and not installed)
		if is_ready and not installed:
			available_count += 1
	_status.text = "%d ligas catalogadas en los seis módulos continentales · %d publicadas y verificadas. Solo se pueden descargar paquetes publicados." % [_items.item_count, available_count]

func _load_membership_summary() -> void:
	_club_counts_by_country.clear()
	var membership := _read_json(MEMBERSHIP_SEED)
	for league in membership.get("leagues", []):
		if league is Dictionary:
			_club_counts_by_country[str(league.get("country_code", ""))] = int(league.get("club_count", 0))
	var directory := _read_json(ASSOCIATION_DIRECTORY)
	_association_count = int(directory.get("association_count", 0))

func _selected_region_id() -> String:
	match _region_filter.selected:
		1: return "europe"
		2: return "south_america"
		3: return "north_central_america_caribbean"
		4: return "africa"
		5: return "asia"
		6: return "oceania"
	return ""

func _selected_confederation_code() -> String:
	match _confederation_filter.selected:
		1: return "AFC"
		2: return "CAF"
		3: return "CONCACAF"
		4: return "CONMEBOL"
		5: return "OFC"
		6: return "UEFA"
	return ""

func _on_region_selected(_index: int) -> void:
	_refresh_list()

func _on_confederation_selected(_index: int) -> void:
	_refresh_list()

func _download_selected() -> void:
	var packages: Array = []
	for index in _items.get_selected_items():
		var item = _items.get_item_metadata(index)
		if item is Dictionary and not _manager.is_package_installed(str(item.get("package_id", ""))):
			packages.append(item)
	var result: Dictionary = _manager.enqueue_packages(packages)
	_status.text = "Añadidos a la cola: %d · rechazados: %d" % [int(result.accepted), result.rejected.size()]
	if packages.is_empty():
		_status.text = "No hay paquetes nuevos seleccionados. Los instalados ya están disponibles; los demás siguen en preparación."


func _download_ten_recommended() -> void:
	var recommended: Array = []
	var preparing := 0
	for league in _league_records:
		var rank := int(league.get("rank", 0))
		if rank < 11 or rank > 20:
			continue
		if bool(league.get("downloadable", false)) and str(league.get("content_status", "")) == "published" and not _manager.is_package_installed(str(league.get("package_id", ""))):
			recommended.append(league)
		elif not (bool(league.get("downloadable", false)) and str(league.get("content_status", "")) == "published"):
			preparing += 1
	var result: Dictionary = _manager.enqueue_packages(recommended)
	_status.text = "Ligas recomendadas añadidas: %d · aún en preparación: %d." % [int(result.get("accepted", 0)), preparing]
	if recommended.is_empty():
		_status.text = "Las diez ligas recomendadas (puestos 11–20) todavía no tienen paquetes completos publicados. No se ha iniciado ninguna descarga."

func _download_all_available() -> void:
	var packages: Array = []
	for league in _league_records:
		if bool(league.get("downloadable", false)) and str(league.get("content_status", "")) == "published" and not _manager.is_package_installed(str(league.get("package_id", ""))):
			packages.append(league)
	var result: Dictionary = _manager.enqueue_packages(packages)
	_status.text = "Todas las ligas disponibles añadidas: %d · rechazadas: %d" % [int(result.accepted), result.rejected.size()]
	if packages.is_empty():
		_status.text = "Todavía no hay ligas adicionales publicadas. No se ha iniciado ninguna descarga."

func _on_progress(package_id: String, downloaded: int, total: int) -> void:
	var progress_text := "%s · %s" % [package_id, _format_bytes(downloaded)]
	if total > 0:
		progress_text += " / " + _format_bytes(total)
	_status.text = "Descargando: " + progress_text

func _on_installed(package_id: String, _path: String) -> void:
	_status.text = "Paquete instalado y verificado: " + package_id + ". Reinicia Fútbol Nova para cargar sus clubes, jugadores y competiciones."

func _on_failed(package_id: String, reason: String) -> void:
	_status.text = "Error en %s: %s" % [package_id, reason]

func _format_bytes(value: int) -> String:
	if value < 1024:
		return "%d B" % value
	if value < 1048576:
		return "%.1f KB" % (float(value) / 1024.0)
	return "%.1f MB" % (float(value) / 1048576.0)

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _download_all_national_teams() -> void:
	var available: Array = []
	for package in _national_packages:
		if bool(package.get("downloadable", false)) and str(package.get("content_status", "")) == "published" and not _manager.is_package_installed(str(package.get("package_id", ""))):
			available.append(package)
	var result: Dictionary = _manager.enqueue_packages(available)
	_status.text = "Selecciones nacionales añadidas: %d" % int(result.accepted)
	if available.is_empty():
		_status.text = "Todavía no hay selecciones nacionales publicadas y verificadas."

func _request_uninstall_selected() -> void:
	_pending_uninstall_ids.clear()
	for index in _items.get_selected_items():
		var item = _items.get_item_metadata(index)
		if item is Dictionary:
			var package_id := str(item.get("package_id", ""))
			if _manager.is_package_installed(package_id):
				_pending_uninstall_ids.append(package_id)
	if _pending_uninstall_ids.is_empty():
		_status.text = "Selecciona al menos un paquete instalado para desinstalar."
		return
	_confirm_uninstall.dialog_text = "Se eliminarán %d paquetes descargados. Las partidas guardadas se conservarán. Si una carrera depende de este contenido, no podrás cargarla hasta reinstalarlo." % _pending_uninstall_ids.size()
	_confirm_uninstall.popup_centered()

func _confirm_uninstall_selected() -> void:
	var removed := 0
	for package_id in _pending_uninstall_ids:
		var result: Dictionary = _manager.uninstall_package(package_id)
		if bool(result.get("ok", false)):
			removed += 1
	_pending_uninstall_ids.clear()
	_refresh_list()
	_status.text = "Paquetes desinstalados: %d. Las partidas guardadas se conservaron." % removed

func _retry_last_failed() -> void:
	if _manager.retry_last_failed():
		_status.text = "Se reintentará la última descarga fallida."
	else:
		_status.text = "No hay una descarga fallida pendiente de reintento."
