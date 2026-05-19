extends Node

signal settings_changed
signal dim_mode_changed(enabled: bool)

const SAVE_PATH := "user://settings.cfg"
const SECTION := "settings"

# Defaults
const DEFAULT_MASTER_VOLUME := 1.0
const DEFAULT_FULLSCREEN := false
const DEFAULT_RESOLUTION := Vector2i(1280, 720)
const DEFAULT_MUSIC_ENABLED := true
const DEFAULT_SFX_ENABLED := true
const DEFAULT_SHOW_POPUP_NOTIFICATIONS := true
const DEFAULT_DIM_MODE_ENABLED := false
const DEFAULT_SHOW_TUTORIAL_ON_NEW_GAME := true
const DEFAULT_GOALS_MILESTONES_ENABLED := true
const DEFAULT_CONFIRMATION_PANELS_ENABLED := true
const DEFAULT_CONFIRMATION_PANEL_OPTIONS := {
	"travel": true,
	"burger_minigame_result": true,
	"save_delete": true
}

# Audio
var master_volume: float = DEFAULT_MASTER_VOLUME
var music_enabled: bool = DEFAULT_MUSIC_ENABLED
var sfx_enabled: bool = DEFAULT_SFX_ENABLED

# Video
var fullscreen: bool = DEFAULT_FULLSCREEN
var resolution: Vector2i = DEFAULT_RESOLUTION

# UI
var show_popup_notifications: bool = DEFAULT_SHOW_POPUP_NOTIFICATIONS
var dim_mode_enabled: bool = DEFAULT_DIM_MODE_ENABLED
var show_tutorial_on_new_game: bool = DEFAULT_SHOW_TUTORIAL_ON_NEW_GAME
var goals_milestones_enabled: bool = DEFAULT_GOALS_MILESTONES_ENABLED
var confirmation_panels_enabled: bool = DEFAULT_CONFIRMATION_PANELS_ENABLED
var confirmation_panel_options: Dictionary = DEFAULT_CONFIRMATION_PANEL_OPTIONS.duplicate(true)

func set_defaults() -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	music_enabled = DEFAULT_MUSIC_ENABLED
	sfx_enabled = DEFAULT_SFX_ENABLED
	fullscreen = DEFAULT_FULLSCREEN
	resolution = DEFAULT_RESOLUTION
	show_popup_notifications = DEFAULT_SHOW_POPUP_NOTIFICATIONS
	dim_mode_enabled = DEFAULT_DIM_MODE_ENABLED
	show_tutorial_on_new_game = DEFAULT_SHOW_TUTORIAL_ON_NEW_GAME
	goals_milestones_enabled = DEFAULT_GOALS_MILESTONES_ENABLED
	confirmation_panels_enabled = DEFAULT_CONFIRMATION_PANELS_ENABLED
	confirmation_panel_options = DEFAULT_CONFIRMATION_PANEL_OPTIONS.duplicate(true)


func get_confirmation_panel_definitions() -> Array[Dictionary]:
	return [
		{
			"id": "travel",
			"name": "Travel Confirmations",
			"description": "Show the destination, travel time, and travel cost before moving."
		},
		{
			"id": "burger_minigame_result",
			"name": "Burger Town Result Panel",
			"description": "Show the Play Again / No More result panel after each burger round."
		},
		{
			"id": "save_delete",
			"name": "Delete Save Confirmation",
			"description": "Ask before permanently deleting a save slot."
		}
	]


func is_confirmation_enabled(panel_id: String) -> bool:
	if not confirmation_panels_enabled:
		return false
	return get_confirmation_panel_option_stored(panel_id)


func get_confirmation_panel_option_stored(panel_id: String) -> bool:
	_ensure_confirmation_panel_option(panel_id)
	return bool(confirmation_panel_options.get(panel_id, true))


func set_confirmation_panel_option(panel_id: String, enabled: bool) -> void:
	_ensure_confirmation_panel_option(panel_id)
	confirmation_panel_options[panel_id] = enabled


func _ensure_confirmation_panel_option(panel_id: String) -> void:
	if panel_id == "":
		return
	if not confirmation_panel_options.has(panel_id):
		confirmation_panel_options[panel_id] = bool(DEFAULT_CONFIRMATION_PANEL_OPTIONS.get(panel_id, true))


func _load_confirmation_panel_options(cfg: ConfigFile) -> void:
	confirmation_panel_options = DEFAULT_CONFIRMATION_PANEL_OPTIONS.duplicate(true)
	for definition in get_confirmation_panel_definitions():
		var panel_id := str(definition.get("id", ""))
		if panel_id == "":
			continue
		var key := "confirmation_panel_%s" % panel_id
		confirmation_panel_options[panel_id] = bool(cfg.get_value(SECTION, key, DEFAULT_CONFIRMATION_PANEL_OPTIONS.get(panel_id, true)))


func _save_confirmation_panel_options(cfg: ConfigFile) -> void:
	for definition in get_confirmation_panel_definitions():
		var panel_id := str(definition.get("id", ""))
		if panel_id == "":
			continue
		_ensure_confirmation_panel_option(panel_id)
		var key := "confirmation_panel_%s" % panel_id
		cfg.set_value(SECTION, key, bool(confirmation_panel_options.get(panel_id, true)))


func toggle_fullscreen(save_after: bool = true) -> bool:
	fullscreen = not fullscreen
	apply_settings()
	if save_after:
		save_settings()
	return fullscreen

func reset_to_defaults() -> void:
	set_defaults()
	apply_settings()
	save_settings()

func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)

	set_defaults()

	if err == OK:
		master_volume = float(cfg.get_value(SECTION, "master_volume", DEFAULT_MASTER_VOLUME))
		music_enabled = bool(cfg.get_value(SECTION, "music_enabled", DEFAULT_MUSIC_ENABLED))
		sfx_enabled = bool(cfg.get_value(SECTION, "sfx_enabled", DEFAULT_SFX_ENABLED))
		fullscreen = bool(cfg.get_value(SECTION, "fullscreen", DEFAULT_FULLSCREEN))
		show_popup_notifications = bool(cfg.get_value(SECTION, "show_popup_notifications", DEFAULT_SHOW_POPUP_NOTIFICATIONS))
		dim_mode_enabled = bool(cfg.get_value(SECTION, "dim_mode_enabled", DEFAULT_DIM_MODE_ENABLED))
		show_tutorial_on_new_game = bool(cfg.get_value(SECTION, "show_tutorial_on_new_game", DEFAULT_SHOW_TUTORIAL_ON_NEW_GAME))
		goals_milestones_enabled = bool(cfg.get_value(SECTION, "goals_milestones_enabled", DEFAULT_GOALS_MILESTONES_ENABLED))
		confirmation_panels_enabled = bool(cfg.get_value(SECTION, "confirmation_panels_enabled", DEFAULT_CONFIRMATION_PANELS_ENABLED))
		_load_confirmation_panel_options(cfg)

		var w := int(cfg.get_value(SECTION, "res_w", DEFAULT_RESOLUTION.x))
		var h := int(cfg.get_value(SECTION, "res_h", DEFAULT_RESOLUTION.y))
		resolution = Vector2i(w, h)

	apply_settings()

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "master_volume", master_volume)
	cfg.set_value(SECTION, "music_enabled", music_enabled)
	cfg.set_value(SECTION, "sfx_enabled", sfx_enabled)
	cfg.set_value(SECTION, "fullscreen", fullscreen)
	cfg.set_value(SECTION, "show_popup_notifications", show_popup_notifications)
	cfg.set_value(SECTION, "dim_mode_enabled", dim_mode_enabled)
	cfg.set_value(SECTION, "show_tutorial_on_new_game", show_tutorial_on_new_game)
	cfg.set_value(SECTION, "goals_milestones_enabled", goals_milestones_enabled)
	cfg.set_value(SECTION, "confirmation_panels_enabled", confirmation_panels_enabled)
	_save_confirmation_panel_options(cfg)
	cfg.set_value(SECTION, "res_w", resolution.x)
	cfg.set_value(SECTION, "res_h", resolution.y)
	cfg.save(SAVE_PATH)

func apply_settings() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(max(master_volume, 0.0001)))

	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_mute(music_bus, not music_enabled)

	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_mute(sfx_bus, not sfx_enabled)

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)

		var screen_size := DisplayServer.screen_get_size()
		var centered_position := Vector2i(
			int((screen_size.x - resolution.x) / 2.0),
			int((screen_size.y - resolution.y) / 2.0)
		)
		DisplayServer.window_set_position(centered_position)

	emit_signal("settings_changed")
	emit_signal("dim_mode_changed", dim_mode_enabled)
