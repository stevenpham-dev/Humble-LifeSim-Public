extends Node

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 16
const SAVE_VERSION := 2

var slot_menu_mode: String = "manage"
var pending_load_slot_id: int = -1

func _ready() -> void:
	_ensure_save_directory()


func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func set_slot_menu_mode(mode: String) -> void:
	slot_menu_mode = mode


func set_pending_load_slot(slot_id: int) -> void:
	pending_load_slot_id = slot_id


func clear_pending_load_slot() -> void:
	pending_load_slot_id = -1


func get_slot_path(slot_id: int) -> String:
	return "%sslot_%d.json" % [SAVE_DIR, slot_id]


func is_valid_slot(slot_id: int) -> bool:
	return slot_id >= 1 and slot_id <= MAX_SLOTS


func save_exists(slot_id: int) -> bool:
	if not is_valid_slot(slot_id):
		return false
	return FileAccess.file_exists(get_slot_path(slot_id))


func delete_save(slot_id: int) -> bool:
	if not is_valid_slot(slot_id):
		push_warning("delete_save: invalid slot_id %d" % slot_id)
		return false

	var path := get_slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return false

	var result := DirAccess.remove_absolute(path)
	if result != OK:
		push_error("Failed to delete save in slot %d. Error code: %d" % [slot_id, result])
		return false

	return true


func create_new_save(slot_id: int, save_name: String = "", player_name: String = "Bobby") -> Dictionary:
	if not is_valid_slot(slot_id):
		return {
			"success": false,
			"error": "Invalid slot id."
		}

	var cleaned_player_name := player_name.strip_edges()
	if cleaned_player_name == "" or cleaned_player_name == "Player":
		cleaned_player_name = "Bobby"

	var final_save_name := save_name.strip_edges()
	if final_save_name == "":
		final_save_name = "Slot %d" % slot_id

	var data := GameState.create_new_game_data(slot_id, final_save_name, cleaned_player_name)
	var save_result := write_save(slot_id, data)

	if not bool(save_result.get("success", false)):
		return save_result

	return {
		"success": true,
		"data": data
	}


func write_save(slot_id: int, data: Dictionary, update_last_played: bool = true) -> Dictionary:
	if not is_valid_slot(slot_id):
		return {
			"success": false,
			"error": "Invalid slot id."
		}

	_ensure_save_directory()

	var migrated_data := _migrate_if_needed(data.duplicate(true))
	migrated_data["version"] = SAVE_VERSION

	if not migrated_data.has("meta"):
		migrated_data["meta"] = {}

	var meta: Dictionary = migrated_data["meta"]
	meta["slot_id"] = slot_id
	if update_last_played or not meta.has("last_played_unix"):
		meta["last_played_unix"] = Time.get_unix_time_from_system()
	migrated_data["meta"] = meta

	var path := get_slot_path(slot_id)
	var file := FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		return {
			"success": false,
			"error": "Could not open save file for writing."
		}

	var json_text := JSON.stringify(migrated_data, "\t")
	file.store_string(json_text)
	file.close()

	return {
		"success": true,
		"path": path
	}


func load_save(slot_id: int) -> Dictionary:
	if not is_valid_slot(slot_id):
		return {
			"success": false,
			"error": "Invalid slot id."
		}

	var path := get_slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return {
			"success": false,
			"error": "Save file does not exist."
		}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"success": false,
			"error": "Could not open save file for reading."
		}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		return {
			"success": false,
			"error": "Save file JSON parse failed."
		}

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return {
			"success": false,
			"error": "Save file format is invalid."
		}

	var migrated_data := _migrate_if_needed(data)

	return {
		"success": true,
		"data": migrated_data
	}


func load_into_game_state(slot_id: int) -> Dictionary:
	var result := load_save(slot_id)
	if not bool(result.get("success", false)):
		return result

	var data: Dictionary = result.get("data", {})
	GameState.load_from_dictionary(data)

	return {
		"success": true,
		"data": data
	}


func save_current_game() -> Dictionary:
	if GameState.slot_id <= 0:
		return {
			"success": false,
			"error": "No active slot loaded in GameState."
		}

	var data := GameState.to_dictionary()
	return write_save(GameState.slot_id, data)


func get_slot_summary(slot_id: int) -> Dictionary:
	if not is_valid_slot(slot_id):
		return {
			"slot_id": slot_id,
			"exists": false,
			"display_name": "Invalid Slot",
			"meta_text": ""
		}

	if not save_exists(slot_id):
		return {
			"slot_id": slot_id,
			"exists": false,
			"display_name": "Slot %d" % slot_id,
			"meta_text": "Empty"
		}

	var result := load_save(slot_id)
	if not bool(result.get("success", false)):
		return {
			"slot_id": slot_id,
			"exists": true,
			"display_name": "Slot %d" % slot_id,
			"meta_text": "Corrupted or unreadable"
		}

	var data: Dictionary = result.get("data", {})
	var meta: Dictionary = data.get("meta", {})
	var player: Dictionary = data.get("player", {})
	var progress: Dictionary = data.get("progress", {})

	var display_name := str(meta.get("save_name", "Slot %d" % slot_id))
	if display_name.strip_edges() == "":
		display_name = "Slot %d" % slot_id

	var player_name := str(player.get("name", "Bobby"))
	var day := int(progress.get("day", 1))
	var money := int(progress.get("money", 0))
	var location := str(progress.get("current_location", "home")).capitalize()

	return {
		"slot_id": slot_id,
		"exists": true,
		"display_name": display_name,
		"meta_text": "%s | Day %d | $%d | %s" % [player_name, day, money, location]
	}


func get_all_slot_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for slot_id in range(1, MAX_SLOTS + 1):
		summaries.append(get_slot_summary(slot_id))
	return summaries


func get_latest_save_slot() -> int:
	var latest_slot := -1
	var latest_time := -1

	for slot_id in range(1, MAX_SLOTS + 1):
		if not save_exists(slot_id):
			continue

		var result := load_save(slot_id)
		if not bool(result.get("success", false)):
			continue

		var data: Dictionary = result.get("data", {})
		var meta: Dictionary = data.get("meta", {})
		var last_played := int(meta.get("last_played_unix", 0))

		if last_played > latest_time:
			latest_time = last_played
			latest_slot = slot_id

	return latest_slot


func has_any_saves() -> bool:
	for slot_id in range(1, MAX_SLOTS + 1):
		if save_exists(slot_id):
			return true
	return false


func get_first_empty_slot() -> int:
	for slot_id in range(1, MAX_SLOTS + 1):
		if not save_exists(slot_id):
			return slot_id
	return -1


func has_empty_slot() -> bool:
	return get_first_empty_slot() > 0


func rename_save(slot_id: int, new_save_name: String) -> Dictionary:
	if not is_valid_slot(slot_id):
		return {
			"success": false,
			"error": "Invalid slot id."
		}

	if not save_exists(slot_id):
		return {
			"success": false,
			"error": "That slot is empty."
		}

	var cleaned_name := new_save_name.strip_edges()
	if cleaned_name == "":
		return {
			"success": false,
			"error": "Enter a save name first."
		}

	if cleaned_name.length() > 40:
		cleaned_name = cleaned_name.substr(0, 40)

	var result := load_save(slot_id)
	if not bool(result.get("success", false)):
		return result

	var data: Dictionary = result.get("data", {}).duplicate(true)
	var meta: Dictionary = data.get("meta", {})
	meta["save_name"] = cleaned_name
	meta["slot_id"] = slot_id
	data["meta"] = meta

	var write_result := write_save(slot_id, data, false)
	if not bool(write_result.get("success", false)):
		return write_result

	return {
		"success": true,
		"slot_id": slot_id,
		"save_name": cleaned_name,
		"message": "Renamed slot %d to %s." % [slot_id, cleaned_name]
	}


func duplicate_save(source_slot_id: int) -> Dictionary:
	if not is_valid_slot(source_slot_id):
		return {
			"success": false,
			"error": "Invalid source slot."
		}

	if not save_exists(source_slot_id):
		return {
			"success": false,
			"error": "Source save does not exist."
		}

	var target_slot_id := get_first_empty_slot()
	if target_slot_id <= 0:
		return {
			"success": false,
			"error": "No empty save slots available."
		}

	var result := load_save(source_slot_id)
	if not bool(result.get("success", false)):
		return result

	var data: Dictionary = result.get("data", {}).duplicate(true)
	var meta: Dictionary = data.get("meta", {})
	var base_name := str(meta.get("save_name", "Slot %d" % source_slot_id)).strip_edges()
	if base_name == "":
		base_name = "Slot %d" % source_slot_id

	meta["save_name"] = _make_copy_save_name(base_name)
	meta["slot_id"] = target_slot_id
	meta["created_unix"] = Time.get_unix_time_from_system()
	meta["last_played_unix"] = Time.get_unix_time_from_system()
	data["meta"] = meta

	var write_result := write_save(target_slot_id, data)
	if not bool(write_result.get("success", false)):
		return write_result

	return {
		"success": true,
		"source_slot_id": source_slot_id,
		"target_slot_id": target_slot_id,
		"data": data,
		"message": "Duplicated slot %d into slot %d." % [source_slot_id, target_slot_id]
	}


func compact_save_slots() -> Dictionary:
	_ensure_save_directory()

	var saved_data: Array[Dictionary] = []
	for slot_id in range(1, MAX_SLOTS + 1):
		if not save_exists(slot_id):
			continue

		var result := load_save(slot_id)
		if not bool(result.get("success", false)):
			return {
				"success": false,
				"error": "Slot %d could not be read, so saves were not rearranged." % slot_id
			}

		var data: Dictionary = result.get("data", {}).duplicate(true)
		saved_data.append(data)

	for slot_id in range(1, MAX_SLOTS + 1):
		var path := get_slot_path(slot_id)
		if FileAccess.file_exists(path):
			var remove_result := DirAccess.remove_absolute(path)
			if remove_result != OK:
				return {
					"success": false,
					"error": "Failed to clear old slot %d during rearrange." % slot_id
				}

	for i in range(saved_data.size()):
		var new_slot_id := i + 1
		var data_to_write: Dictionary = saved_data[i]
		var write_result := write_save(new_slot_id, data_to_write, false)
		if not bool(write_result.get("success", false)):
			return write_result

	return {
		"success": true,
		"count": saved_data.size()
	}


func overwrite_or_create_from_game_state(slot_id: int, save_name: String = "") -> Dictionary:
	if not is_valid_slot(slot_id):
		return {
			"success": false,
			"error": "Invalid slot id."
		}

	GameState.slot_id = slot_id

	if save_name.strip_edges() != "":
		GameState.save_name = save_name

	return save_current_game()


func _make_copy_save_name(base_name: String) -> String:
	var copy_name := "%s Copy" % base_name
	if copy_name.length() > 40:
		copy_name = copy_name.substr(0, 40)
	return copy_name


func _migrate_if_needed(data: Dictionary) -> Dictionary:
	var version := int(data.get("version", 0))
	if version <= 0:
		data["version"] = SAVE_VERSION

	if not data.has("meta"):
		data["meta"] = {}
	if not data.has("player"):
		data["player"] = {}
	if not data.has("progress"):
		data["progress"] = {}
	if not data.has("systems"):
		data["systems"] = {}

	var meta: Dictionary = data["meta"]
	var player: Dictionary = data["player"]
	var progress: Dictionary = data["progress"]
	var systems: Dictionary = data["systems"]

	if not meta.has("slot_id"):
		meta["slot_id"] = 0
	if not meta.has("save_name"):
		meta["save_name"] = "Unnamed Save"
	if not meta.has("created_unix"):
		meta["created_unix"] = Time.get_unix_time_from_system()
	if not meta.has("last_played_unix"):
		meta["last_played_unix"] = Time.get_unix_time_from_system()

	if not player.has("name"):
		player["name"] = "Bobby"
	if str(player.get("name", "")).strip_edges() == "" or str(player.get("name", "")) == "Player":
		player["name"] = "Bobby"
	if not player.has("energy"):
		player["energy"] = 100
	if not player.has("hunger"):
		player["hunger"] = 0
	if not player.has("happiness"):
		player["happiness"] = 50
	if not player.has("stress"):
		player["stress"] = 0
	if not player.has("fitness"):
		player["fitness"] = 0
	if not player.has("education"):
		player["education"] = 0

	if not player.has("strength"):
		player["strength"] = 0
	if not player.has("intelligence"):
		player["intelligence"] = 0
	if not player.has("discipline"):
		player["discipline"] = 0
	if not player.has("confidence"):
		player["confidence"] = 0
	if not player.has("charisma"):
		player["charisma"] = 0
	if not player.has("endurance"):
		player["endurance"] = 0

	if not progress.has("day"):
		progress["day"] = 1
	if not progress.has("time_of_day"):
		progress["time_of_day"] = "morning"
	if not progress.has("money"):
		progress["money"] = 0
	if not progress.has("current_location"):
		progress["current_location"] = "home"
	if not progress.has("current_house_id"):
		progress["current_house_id"] = "starter_house"
	if not progress.has("current_car_id"):
		progress["current_car_id"] = "none"
	if not progress.has("job_id"):
		progress["job_id"] = "none"
	if not progress.has("school_level"):
		progress["school_level"] = 0

	if not progress.has("jobs"):
		progress["jobs"] = []

	if typeof(progress["jobs"]) != TYPE_ARRAY:
		progress["jobs"] = []

	var jobs_array = progress["jobs"]
	if jobs_array.is_empty():
		var old_job_id := str(progress.get("job_id", "none"))
		if old_job_id != "" and old_job_id != "none":
			jobs_array.append(old_job_id)
			progress["jobs"] = jobs_array

	if not systems.has("inventory"):
		systems["inventory"] = []
	if not systems.has("flags"):
		systems["flags"] = {}
	if not systems.has("relationships"):
		systems["relationships"] = {}
	if not systems.has("activity_logs"):
		systems["activity_logs"] = []

	if typeof(systems["activity_logs"]) != TYPE_ARRAY:
		systems["activity_logs"] = []

	data["version"] = SAVE_VERSION
	return data
