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
var confirmation_master_toggle: CheckButton = null
var confirmation_options_container: VBoxContainer = null
var confirmation_option_toggles: Dictionary = {}
var _font: Font = preload("res://assets/fonts/fonts.ttf")

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
	_setup_confirmation_panel_settings()
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
	if confirmation_master_toggle != null:
		confirmation_master_toggle.toggled.connect(_on_confirmation_master_toggled)
	for panel_id in confirmation_option_toggles.keys():
		var option_toggle := confirmation_option_toggles[panel_id] as CheckButton
		if option_toggle != null:
			option_toggle.toggled.connect(_on_confirmation_option_toggled.bind(str(panel_id)))
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


func _setup_confirmation_panel_settings() -> void:
	var scroll_content := get_node_or_null("Center/Panel/Layout/ScrollContainer/ScrollContentMargin/ScrollContent")
	if scroll_content == null:
		return

	var existing := scroll_content.get_node_or_null("ConfirmationPanelSettings")
	if existing != null:
		confirmation_master_toggle = existing.get_node_or_null("Content/HeaderRow/ConfirmationMasterToggle") as CheckButton
		confirmation_options_container = existing.get_node_or_null("Content/OptionsList") as VBoxContainer
		_reconnect_existing_confirmation_options()
		return

	var panel := PanelContainer.new()
	panel.name = "ConfirmationPanelSettings"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_confirmation_panel_style())

	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var header_row := HBoxContainer.new()
	header_row.name = "HeaderRow"
	header_row.add_theme_constant_override("separation", 12)
	content.add_child(header_row)

	var title_label := _make_settings_label("Enable Confirmation Panels", 22, Color(1.0, 0.95, 0.78, 1.0))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title_label)

	confirmation_master_toggle = CheckButton.new()
	confirmation_master_toggle.name = "ConfirmationMasterToggle"
	confirmation_master_toggle.text = ""
	header_row.add_child(confirmation_master_toggle)

	var helper_label := _make_settings_label("Turn this off to skip all optional confirmation/result panels. Your custom list choices are remembered and come back when this is turned on again.", 15, Color(0.82, 0.88, 1.0, 1.0))
	helper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(helper_label)

	var list_label := _make_settings_label("List", 18, Color(1.0, 1.0, 1.0, 1.0))
	content.add_child(list_label)

	confirmation_options_container = VBoxContainer.new()
	confirmation_options_container.name = "OptionsList"
	confirmation_options_container.add_theme_constant_override("separation", 6)
	content.add_child(confirmation_options_container)

	_build_confirmation_option_rows()

	var dim_row := scroll_content.get_node_or_null("DimModeRow")
	if dim_row != null:
		scroll_content.add_child(panel)
		scroll_content.move_child(panel, dim_row.get_index())
	else:
		scroll_content.add_child(panel)


func _reconnect_existing_confirmation_options() -> void:
	confirmation_option_toggles.clear()
	if confirmation_options_container == null:
		return
	for row in confirmation_options_container.get_children():
		if not (row is HBoxContainer):
			continue
		var panel_id := str(row.get_meta("panel_id", ""))
		var option_toggle := row.get_node_or_null("OptionToggle") as CheckButton
		if panel_id != "" and option_toggle != null:
			confirmation_option_toggles[panel_id] = option_toggle


func _build_confirmation_option_rows() -> void:
	if confirmation_options_container == null:
		return

	for child in confirmation_options_container.get_children():
		child.queue_free()
	confirmation_option_toggles.clear()

	for definition in SettingsData.get_confirmation_panel_definitions():
		var panel_id := str(definition.get("id", ""))
		if panel_id == "":
			continue

		var row := HBoxContainer.new()
		row.name = "ConfirmationOption_%s" % panel_id
		row.set_meta("panel_id", panel_id)
		row.add_theme_constant_override("separation", 10)
		confirmation_options_container.add_child(row)

		var text_column := VBoxContainer.new()
		text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_column.add_theme_constant_override("separation", 2)
		row.add_child(text_column)

		var name_label := _make_settings_label(str(definition.get("name", panel_id)), 17, Color(1.0, 1.0, 1.0, 1.0))
		text_column.add_child(name_label)

		var description_label := _make_settings_label(str(definition.get("description", "")), 13, Color(0.76, 0.82, 0.92, 1.0))
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_column.add_child(description_label)

		var option_toggle := CheckButton.new()
		option_toggle.name = "OptionToggle"
		option_toggle.text = ""
		row.add_child(option_toggle)
		confirmation_option_toggles[panel_id] = option_toggle


func _sync_confirmation_ui_from_settings() -> void:
	var master_on := true
	if SettingsData != null:
		master_on = SettingsData.confirmation_panels_enabled

	if confirmation_master_toggle != null:
		confirmation_master_toggle.button_pressed = master_on

	for panel_id in confirmation_option_toggles.keys():
		var option_toggle := confirmation_option_toggles[panel_id] as CheckButton
		if option_toggle == null:
			continue
		option_toggle.disabled = not master_on
		if master_on:
			option_toggle.button_pressed = SettingsData.get_confirmation_panel_option_stored(str(panel_id))
		else:
			option_toggle.button_pressed = false


func _on_confirmation_master_toggled(on: bool) -> void:
	AudioManager.play_ui_click()
	SettingsData.confirmation_panels_enabled = on
	SettingsData.save_settings()
	_sync_confirmation_ui_from_settings()


func _on_confirmation_option_toggled(on: bool, panel_id: String) -> void:
	if not SettingsData.confirmation_panels_enabled:
		_sync_confirmation_ui_from_settings()
		return
	AudioManager.play_ui_click()
	SettingsData.set_confirmation_panel_option(panel_id, on)
	SettingsData.save_settings()


func _make_settings_label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_confirmation_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.19, 0.31, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.95, 0.82, 0.40, 0.22)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	return style

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
	_sync_confirmation_ui_from_settings()
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			_toggle_fullscreen_shortcut()
			get_viewport().set_input_as_handled()


func _toggle_fullscreen_shortcut() -> void:
	AudioManager.play_ui_click()
	SettingsData.toggle_fullscreen(true)
	if fullscreen_toggle != null:
		fullscreen_toggle.set_pressed_no_signal(SettingsData.fullscreen)


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
