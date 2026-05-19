
extends Control

@onready var background: TextureRect = $Background
@onready var dim_overlay: ColorRect = $Dim
@onready var panel: Control = $Center/Panel

@onready var slider: HSlider = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/VolumeRow/VolumeSlider

@onready var fullscreen_toggle: CheckButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/FullscreenRow/FullscreenToggle
@onready var music_toggle: CheckButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/MusicRow/MusicToggle
@onready var sfx_toggle: CheckButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/SfxRow/SfxToggle
@onready var popup_toggle: CheckButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/PopupRow/PopupToggle
@onready var tutorial_toggle: CheckButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/TutorialRow/TutorialToggle
@onready var dim_mode_toggle: CheckButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/DimModeRow/DimModeToggle
var goals_toggle: CheckButton = null

@onready var resolution_option: OptionButton = $Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent/ResolutionRow/ResolutionOption

@onready var defaults_button: Button = $Center/Panel/Layout/ButtonsRow/DefaultsButton
@onready var back_button: Button = $Center/Panel/Layout/ButtonsRow/BackButton

var backgrounds := [
	"res://assets/images/GameMenu_camaro_1.png",
	"res://assets/images/GameMenu_camaro_2.png",
	"res://assets/images/GameMenu_mustang_1.png",
	"res://assets/images/GameMenu_mustang_2.png"
]

var _resolutions := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

func _ready() -> void:
	SettingsData.load_settings()
	_apply_random_background()

	_setup_resolution_dropdown()
	_setup_goals_toggle()
	_sync_ui_from_settings()
	_select_resolution(SettingsData.resolution)

	slider.value_changed.connect(_on_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	popup_toggle.toggled.connect(_on_popup_toggled)
	tutorial_toggle.toggled.connect(_on_tutorial_toggled)
	dim_mode_toggle.toggled.connect(_on_dim_mode_toggled)
	if goals_toggle != null:
		goals_toggle.toggled.connect(_on_goals_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)

	defaults_button.pressed.connect(_on_defaults_pressed)
	back_button.pressed.connect(_go_back)

	_animate_in()


func _setup_goals_toggle() -> void:
	var scroll_content := get_node_or_null("Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent")
	if scroll_content == null:
		return

	var existing := scroll_content.get_node_or_null("GoalsRow")
	if existing != null:
		goals_toggle = existing.get_node_or_null("GoalsToggle") as CheckButton
		return

	var row := HBoxContainer.new()
	row.name = "GoalsRow"
	row.add_theme_constant_override("separation", 12)

	var label := Label.new()
	label.name = "GoalsLabel"
	label.text = "Goals / Milestones"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_override("font", load("res://assets/fonts/fonts.ttf"))
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	row.add_child(label)

	goals_toggle = CheckButton.new()
	goals_toggle.name = "GoalsToggle"
	goals_toggle.text = ""
	row.add_child(goals_toggle)

	var dim_row := scroll_content.get_node_or_null("DimModeRow")
	if dim_row != null:
		scroll_content.add_child(row)
		scroll_content.move_child(row, dim_row.get_index())
	else:
		scroll_content.add_child(row)

func _sync_ui_from_settings() -> void:
	slider.value = SettingsData.master_volume
	fullscreen_toggle.button_pressed = SettingsData.fullscreen
	music_toggle.button_pressed = SettingsData.music_enabled
	sfx_toggle.button_pressed = SettingsData.sfx_enabled
	popup_toggle.button_pressed = SettingsData.show_popup_notifications
	tutorial_toggle.button_pressed = SettingsData.show_tutorial_on_new_game
	dim_mode_toggle.button_pressed = SettingsData.dim_mode_enabled
	if goals_toggle != null:
		goals_toggle.button_pressed = SettingsData.goals_milestones_enabled
	_apply_visual_settings_to_menu()

func _apply_random_background() -> void:
	if backgrounds.is_empty():
		return
	randomize()
	var i := randi() % backgrounds.size()
	var tex := load(backgrounds[i])
	if tex != null:
		background.texture = tex

func _setup_resolution_dropdown() -> void:
	resolution_option.clear()
	for r in _resolutions:
		resolution_option.add_item(str(r.x) + " x " + str(r.y))

func _select_resolution(r: Vector2i) -> void:
	var idx := 0
	for i in range(_resolutions.size()):
		if _resolutions[i] == r:
			idx = i
			break
	resolution_option.select(idx)

func _on_volume_changed(v: float) -> void:
	SettingsData.master_volume = v
	SettingsData.apply_settings()
	SettingsData.save_settings()

func _on_fullscreen_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.fullscreen = on
	SettingsData.apply_settings()
	SettingsData.save_settings()

func _on_music_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.music_enabled = on
	SettingsData.apply_settings()
	SettingsData.save_settings()

func _on_sfx_toggled(on: bool) -> void:
	SettingsData.sfx_enabled = on
	SettingsData.apply_settings()
	SettingsData.save_settings()
	AudioManager.play_ui_click()

func _on_popup_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.show_popup_notifications = on
	SettingsData.save_settings()


func _on_tutorial_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.show_tutorial_on_new_game = on
	SettingsData.save_settings()

func _on_goals_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.goals_milestones_enabled = on
	SettingsData.save_settings()
	SettingsData.apply_settings()

func _on_dim_mode_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.dim_mode_enabled = on
	SettingsData.apply_settings()
	SettingsData.save_settings()
	_apply_visual_settings_to_menu()
func _apply_visual_settings_to_menu() -> void:
	var dim_enabled := false
	if SettingsData != null:
		dim_enabled = SettingsData.dim_mode_enabled

	if dim_overlay != null:
		dim_overlay.color = Color(0, 0, 0, 0.52) if dim_enabled else Color(0.20, 0.55, 0.80, 0.12)

	if panel != null:
		panel.modulate = Color(0.78, 0.82, 0.90, 1.0) if dim_enabled else Color(1, 1, 1, 1)


func _on_resolution_selected(index: int) -> void:
	AudioManager.play_ui_click()
	if index < 0 or index >= _resolutions.size():
		return
	SettingsData.resolution = _resolutions[index]
	SettingsData.apply_settings()
	SettingsData.save_settings()

func _on_defaults_pressed() -> void:
	AudioManager.play_ui_click()
	SettingsData.reset_to_defaults()
	_sync_ui_from_settings()
	_select_resolution(SettingsData.resolution)
	_apply_visual_settings_to_menu()

func _go_back() -> void:
	AudioManager.play_ui_click()
	SceneTransition.change_scene("res://scenes/MainMenu.tscn")

func _animate_in() -> void:
	panel.scale = Vector2(0.96, 0.96)
	panel.modulate = Color(1, 1, 1, 0)

	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate:a", 1.0, 0.18)
	t.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.18)
