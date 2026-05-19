extends Control

const SETTINGS_SCENE_PATH := "res://scenes/SettingsMenu.tscn"
const SAVE_SLOTS_SCENE_PATH := "res://scenes/SaveSlotsMenu.tscn"
const GAME_ROOT_SCENE_PATH := "res://scenes/GameRoot.tscn"
const ACHIEVEMENTS_PANEL_PATH := "res://scenes/AchievementsPanel.tscn"

@onready var background: TextureRect = $Background
@onready var title_wrap: Control = $Center/Layout/TitleWrap

@onready var new_game_button: Button = $Center/Layout/NewGameButton
@onready var continue_button: Button = $Center/Layout/ContinueButton
@onready var saved_games_button: Button = $Center/Layout/SavedGamesButton
@onready var settings_button: Button = $Center/Layout/SettingsButton
@onready var achievements_button: Button = $Center/Layout/AchievementsButton

var project_info_button: Button = null
var quit_game_button: Button = null
var project_info_overlay: Control = null

@onready var buttons := [
	$Center/Layout/NewGameButton,
	$Center/Layout/ContinueButton,
	$Center/Layout/SavedGamesButton,
	$Center/Layout/SettingsButton,
	$Center/Layout/AchievementsButton
]

var achievements_panel: Control = null

var backgrounds := [
	"res://assets/images/GameMenu_camaro_1.png",
	"res://assets/images/GameMenu_camaro_2.png",
	"res://assets/images/GameMenu_mustang_1.png",
	"res://assets/images/GameMenu_mustang_2.png"
]

func _ready() -> void:
	SettingsData.load_settings()

	randomize()

	if not backgrounds.is_empty():
		var random_index := randi() % backgrounds.size()
		var tex := load(backgrounds[random_index])
		if tex != null:
			background.texture = tex

	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	saved_games_button.pressed.connect(_on_saved_games_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	achievements_button.pressed.connect(_on_achievements_pressed)
	_ensure_project_info_button()
	_ensure_quit_game_button()

	continue_button.disabled = not SaveManager.has_any_saves()

	_setup_button_anims()
	_start_title_sway()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			_toggle_fullscreen_shortcut()
			get_viewport().set_input_as_handled()


func _toggle_fullscreen_shortcut() -> void:
	_play_ui_click()
	if SettingsData != null and SettingsData.has_method("toggle_fullscreen"):
		SettingsData.toggle_fullscreen(true)


func _play_ui_click() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("play_ui_click"):
		audio_manager.play_ui_click()


func _on_new_game_pressed() -> void:
	_play_ui_click()
	SaveManager.set_slot_menu_mode("new")
	SceneTransition.change_scene(SAVE_SLOTS_SCENE_PATH)


func _on_continue_pressed() -> void:
	_play_ui_click()

	var latest_slot := SaveManager.get_latest_save_slot()
	if latest_slot <= 0:
		continue_button.disabled = true
		return

	SaveManager.set_pending_load_slot(latest_slot)
	SceneTransition.change_scene(GAME_ROOT_SCENE_PATH)


func _on_saved_games_pressed() -> void:
	_play_ui_click()
	SaveManager.set_slot_menu_mode("manage")
	SceneTransition.change_scene(SAVE_SLOTS_SCENE_PATH)


func _on_settings_pressed() -> void:
	_play_ui_click()
	SceneTransition.change_scene(SETTINGS_SCENE_PATH)

func _on_achievements_pressed() -> void:
	_play_ui_click()
	_open_achievements_panel()


func _open_achievements_panel() -> void:
	if achievements_panel == null:
		var packed := load(ACHIEVEMENTS_PANEL_PATH)
		if packed == null or not (packed is PackedScene):
			return

		achievements_panel = (packed as PackedScene).instantiate() as Control
		if achievements_panel == null:
			return

		achievements_panel.visible = false
		add_child(achievements_panel)

		if achievements_panel.has_signal("close_requested"):
			achievements_panel.connect("close_requested", Callable(self, "_on_achievements_close_requested"))

	if achievements_panel.has_method("refresh"):
		achievements_panel.refresh()

	achievements_panel.visible = true
	achievements_panel.move_to_front()


func _on_achievements_close_requested() -> void:
	if achievements_panel != null:
		achievements_panel.visible = false



func _ensure_project_info_button() -> void:
	if project_info_button != null:
		return

	var layout_node := $Center/Layout
	project_info_button = Button.new()
	project_info_button.name = "ProjectInfoButton"
	project_info_button.text = "Project Info"
	project_info_button.focus_mode = Control.FOCUS_NONE
	project_info_button.add_theme_font_size_override("font_size", 32)
	project_info_button.pressed.connect(_on_project_info_pressed)
	layout_node.add_child(project_info_button)
	buttons.append(project_info_button)



func _ensure_quit_game_button() -> void:
	if quit_game_button != null:
		return

	var layout_node := $Center/Layout
	quit_game_button = Button.new()
	quit_game_button.name = "QuitGameButton"
	quit_game_button.text = "Quit Game"
	quit_game_button.focus_mode = Control.FOCUS_NONE
	quit_game_button.add_theme_font_size_override("font_size", 32)
	quit_game_button.pressed.connect(_on_quit_game_pressed)
	layout_node.add_child(quit_game_button)
	buttons.append(quit_game_button)


func _on_quit_game_pressed() -> void:
	_play_ui_click()
	get_tree().quit()

func _on_project_info_pressed() -> void:
	_play_ui_click()
	_open_project_info_overlay()


func _open_project_info_overlay() -> void:
	if project_info_overlay == null:
		_build_project_info_overlay()

	project_info_overlay.visible = true
	project_info_overlay.move_to_front()


func _build_project_info_overlay() -> void:
	project_info_overlay = Control.new()
	project_info_overlay.name = "ProjectInfoOverlay"
	project_info_overlay.visible = false
	project_info_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	project_info_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(project_info_overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	project_info_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	project_info_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820, 500)
	panel.add_theme_stylebox_override("panel", _make_project_info_panel_style())
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	var title := Label.new()
	title.text = "Humble LifeSim Portfolio Prototype"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 1.0))
	column.add_child(title)

	var body := Label.new()
	body.text = "This is a playable portfolio prototype built in Godot and GDScript. The goal of this demo is not perfect balance yet. The goal is to show a stable life-sim loop with connected systems.\n\nCurrent systems include save/load, inventory, store purchases, school progress, credentials, jobs, banking, travel, logs, achievements, settings, audio, and the Burger Town minigame.\n\nThis build can run as a local Godot project or as an AWS-hosted browser demo using Godot Web export, Amazon S3, and CloudFront. A later cloud upgrade may add serverless save/load with API Gateway, Lambda, DynamoDB, and optional login."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0, 1.0))
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)

	var note := Label.new()
	note.text = "Prototype note: balance areas like economy, happiness, stress, and progression may still change as the project keeps improving."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 17)
	note.add_theme_color_override("font_color", Color(0.72, 1.0, 0.78, 1.0))
	column.add_child(note)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(button_row)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(180, 46)
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(_close_project_info_overlay)
	button_row.add_child(close_button)


func _close_project_info_overlay() -> void:
	_play_ui_click()
	if project_info_overlay != null:
		project_info_overlay.visible = false


func _make_project_info_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.20, 0.34, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.95, 0.82, 0.40, 0.35)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	return style


func _start_title_sway() -> void:
	await get_tree().process_frame
	title_wrap.pivot_offset = title_wrap.size * 0.5
	title_wrap.rotation_degrees = -10.0
	_title_sway_to(10.0)


func _title_sway_to(target_degrees: float) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title_wrap, "rotation_degrees", target_degrees, 5.0)
	t.finished.connect(func():
		_title_sway_to(-target_degrees)
	)


func _setup_button_anims() -> void:
	await get_tree().process_frame
	for b in buttons:
		b.pivot_offset = b.size * 0.5
		b.mouse_entered.connect(func(): _button_hover_in(b))
		b.mouse_exited.connect(func(): _button_hover_out(b))
		b.pressed.connect(func(): _button_click_pop(b))


func _button_hover_in(b: Control) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2(1.06, 1.06), 0.12)
	t.parallel().tween_property(b, "modulate", Color(1.15, 1.15, 1.15, 1.0), 0.12)


func _button_hover_out(b: Control) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2(1.0, 1.0), 0.12)
	t.parallel().tween_property(b, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)


func _button_click_pop(b: Control) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2(0.98, 0.98), 0.05)
	t.tween_property(b, "scale", Vector2(1.06, 1.06), 0.08)
