extends Node

const SAVE_DIR := "user://saves/"
const SLOT_COUNT := 3
const SAVE_VERSION := 1
var active_slot := 1

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))

func slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

func has_save(slot: int) -> bool:
	return slot >= 1 and slot <= SLOT_COUNT and FileAccess.file_exists(slot_path(slot))

func save_game(slot: int, data: Dictionary) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	var payload := data.duplicate(true)
	payload["save_version"] = SAVE_VERSION
	payload["saved_at"] = Time.get_datetime_string_from_system(true)
	var temp_path := slot_path(slot) + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível criar o salvamento temporário.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()
	var verify := FileAccess.open(temp_path, FileAccess.READ)
	if verify == null:
		return false
	var parsed := JSON.new()
	var parse_result := parsed.parse(verify.get_as_text())
	verify.close()
	if parse_result != OK or not (parsed.data is Dictionary):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
		push_error("O salvamento temporário não passou na validação JSON.")
		return false
	var target := slot_path(slot)
	var backup := target + ".bak"
	if FileAccess.file_exists(target):
		if FileAccess.file_exists(backup):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(backup))
		var backup_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(target), ProjectSettings.globalize_path(backup))
		if backup_error != OK:
			push_error("Falha ao preservar o salvamento anterior.")
			return false
	var replace_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(target))
	if replace_error != OK:
		if FileAccess.file_exists(backup):
			DirAccess.rename_absolute(ProjectSettings.globalize_path(backup), ProjectSettings.globalize_path(target))
		push_error("Falha ao concluir o salvamento.")
		return false
	return true

func load_game(slot: int) -> Dictionary:
	if slot < 1 or slot > SLOT_COUNT:
		return {}
	var result := _read_save(slot_path(slot))
	if not result.is_empty():
		return result
	var backup := _read_save(slot_path(slot) + ".bak")
	if not backup.is_empty():
		push_warning("Salvamento principal inválido; cópia de segurança recuperada.")
	return backup

func _read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	file.close()
	if error != OK or not (parser.data is Dictionary):
		return {}
	var data: Dictionary = parser.data
	if int(data.get("save_version", -1)) != SAVE_VERSION:
		return {}
	return data
