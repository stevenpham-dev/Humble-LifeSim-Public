extends Control

const GAME_ROOT_PATH := "res://scenes/GameRoot.tscn"
const MAIN_MENU_PATH := "res://scenes/MainMenu.tscn"

@onready var title_label: Label = $Center/Panel/Layout/Title
@onready var layout: VBoxContainer = $Center/Panel/Layout
@onready var slots_wrap: VBoxContainer = $Center/Panel/Layout/SlotsWrap
@onready var back_button: Button = $Center/Panel/Layout/BottomButtons/BackButton

var player_name_line_edit: LineEdit = null
var player_name_hint_label: Label = null
var message_label: Label = null
var slots_scroll: ScrollContainer = null

var delete_confirm_overlay: Control = null
var delete_confirm_label: Label = null
var delete_confirm_button: Button = null
var delete_cancel_button: Button = null
var _pending_delete_slot_id: int = -1

var rename_overlay: Control = null
var rename_title_label: Label = null
var rename_line_edit: LineEdit = null
var rename_confirm_button: Button = null
var rename_cancel_button: Button = null
var _pending_rename_slot_id: int = -1

var _font: Font = preload("res://assets/fonts/fonts.ttf")

func _ready() -> void:
	SaveManager.compact_save_slots()
	_prepare_scrollable_slots_area()
	_ensure_player_name_row()
	_ensure_message_label()
	_ensure_rename_dialog()
	_ensure_delete_confirm_dialog()
	_wire_buttons()
	_apply_mode_title()
	_rebuild_slots()


func _prepare_scrollable_slots_area() -> void:
	if slots_wrap == null:
		return

	if slots_wrap.get_parent() is ScrollContainer:
		slots_scroll = slots_wrap.get_parent() as ScrollContainer
		return

	var old_parent := slots_wrap.get_parent()
	if old_parent == null:
		return

	var old_index := slots_wrap.get_index()
	old_parent.remove_child(slots_wrap)

	slots_scroll = ScrollContainer.new()
	slots_scroll.name = "SlotsScroll"
	slots_scroll.custom_minimum_size = Vector2(0, 315)
	slots_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slots_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	old_parent.add_child(slots_scroll)
	old_parent.move_child(slots_scroll, old_index)

	slots_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots_wrap.add_theme_constant_override("separation", 12)
	slots_scroll.add_child(slots_wrap)


func _ensure_player_name_row() -> void:
	if player_name_line_edit != null:
		return

	var existing := layout.get_node_or_null("PlayerNamePanel")
	if existing != null:
		return

	var panel := PanelContainer.new()
	panel.name = "PlayerNamePanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_name_panel_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)

	var label := Label.new()
	label.text = "New Character Name"
	label.custom_minimum_size = Vector2(190, 0)
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 1))
	row.add_child(label)

	player_name_line_edit = LineEdit.new()
	player_name_line_edit.name = "PlayerNameLineEdit"
	player_name_line_edit.text = "Bobby"
	player_name_line_edit.placeholder_text = "Bobby"
	player_name_line_edit.clear_button_enabled = true
	player_name_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_name_line_edit.add_theme_font_override("font", _font)
	player_name_line_edit.add_theme_font_size_override("font_size", 18)
	player_name_line_edit.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	player_name_line_edit.add_theme_stylebox_override("normal", _make_name_input_style())
	row.add_child(player_name_line_edit)

	player_name_hint_label = Label.new()
	player_name_hint_label.text = "Used only when pressing New on an empty slot. Rename has its own popup and does not start the game."
	player_name_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_name_hint_label.add_theme_font_override("font", _font)
	player_name_hint_label.add_theme_font_size_override("font_size", 15)
	player_name_hint_label.add_theme_color_override("font_color", Color(0.82, 0.88, 1.0, 1))
	column.add_child(player_name_hint_label)

	layout.add_child(panel)
	layout.move_child(panel, 1)


func _ensure_message_label() -> void:
	if message_label != null:
		return

	var existing := layout.get_node_or_null("SaveMessageLabel")
	if existing is Label:
		message_label = existing as Label
		return

	message_label = Label.new()
	message_label.name = "SaveMessageLabel"
	message_label.text = ""
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_override("font", _font)
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", Color(0.72, 1.0, 0.78, 1))

	layout.add_child(message_label)
	layout.move_child(message_label, 2)


func _ensure_rename_dialog() -> void:
	if rename_overlay != null:
		return

	rename_overlay = Control.new()
	rename_overlay.name = "RenameSaveOverlay"
	rename_overlay.visible = false
	rename_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	rename_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rename_overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.56)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	rename_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	rename_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 250)
	panel.add_theme_stylebox_override("panel", _make_dialog_panel_style())
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	rename_title_label = Label.new()
	rename_title_label.text = "Rename Save"
	rename_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rename_title_label.add_theme_font_override("font", _font)
	rename_title_label.add_theme_font_size_override("font_size", 26)
	rename_title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 1))
	column.add_child(rename_title_label)

	var info_label := Label.new()
	info_label.text = "This only changes the save label. It will not load, overwrite, or reset the save."
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_override("font", _font)
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.add_theme_color_override("font_color", Color(0.90, 0.94, 1.0, 1))
	column.add_child(info_label)

	rename_line_edit = LineEdit.new()
	rename_line_edit.placeholder_text = "Save name..."
	rename_line_edit.clear_button_enabled = true
	rename_line_edit.add_theme_font_override("font", _font)
	rename_line_edit.add_theme_font_size_override("font_size", 18)
	rename_line_edit.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	rename_line_edit.add_theme_stylebox_override("normal", _make_name_input_style())
	column.add_child(rename_line_edit)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	column.add_child(button_row)

	rename_cancel_button = _make_action_button("Cancel")
	rename_cancel_button.custom_minimum_size = Vector2(150, 44)
	rename_cancel_button.pressed.connect(_cancel_rename)
	button_row.add_child(rename_cancel_button)

	rename_confirm_button = _make_action_button("Save Name")
	rename_confirm_button.custom_minimum_size = Vector2(170, 44)
	rename_confirm_button.pressed.connect(_confirm_rename)
	button_row.add_child(rename_confirm_button)

	rename_line_edit.text_submitted.connect(func(_text: String) -> void:
		_confirm_rename()
	)


func _ensure_delete_confirm_dialog() -> void:
	if delete_confirm_overlay != null:
		return

	delete_confirm_overlay = Control.new()
	delete_confirm_overlay.name = "DeleteConfirmOverlay"
	delete_confirm_overlay.visible = false
	delete_confirm_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	delete_confirm_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(delete_confirm_overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	delete_confirm_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	delete_confirm_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 250)
	panel.add_theme_stylebox_override("panel", _make_dialog_panel_style())
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	var title := Label.new()
	title.text = "Delete Save?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.72, 0.72, 1))
	column.add_child(title)

	delete_confirm_label = Label.new()
	delete_confirm_label.text = "Are you sure you want to delete this save forever?"
	delete_confirm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	delete_confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	delete_confirm_label.add_theme_font_override("font", _font)
	delete_confirm_label.add_theme_font_size_override("font_size", 18)
	delete_confirm_label.add_theme_color_override("font_color", Color(0.95, 0.96, 1.0, 1))
	column.add_child(delete_confirm_label)

	var warning := Label.new()
	warning.text = "This cannot be undone."
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_font_override("font", _font)
	warning.add_theme_font_size_override("font_size", 16)
	warning.add_theme_color_override("font_color", Color(1.0, 0.84, 0.60, 1))
	column.add_child(warning)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	column.add_child(button_row)

	delete_cancel_button = _make_action_button("Cancel")
	delete_cancel_button.custom_minimum_size = Vector2(150, 44)
	delete_cancel_button.pressed.connect(_cancel_delete)
	button_row.add_child(delete_cancel_button)

	delete_confirm_button = _make_action_button("Delete Forever", true)
	delete_confirm_button.custom_minimum_size = Vector2(210, 44)
	delete_confirm_button.pressed.connect(_confirm_delete)
	button_row.add_child(delete_confirm_button)


func _wire_buttons() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		SceneTransition.change_scene(MAIN_MENU_PATH)
	)


func _apply_mode_title() -> void:
	match SaveManager.slot_menu_mode:
		"new":
			title_label.text = "NEW GAME"
			_set_message("Choose an empty slot, name your character, then press New. Existing saves can be renamed, duplicated, loaded, or deleted.")
		"manage":
			title_label.text = "SAVE SLOTS"
			_set_message("Load a save, rename a save label, duplicate a save, or delete one. Saves are kept at the top with no gaps.")
		_:
			title_label.text = "SAVE SLOTS"
			_set_message("Manage your save files.")


func _set_message(text_value: String) -> void:
	if message_label != null:
		message_label.text = text_value


func _get_entered_player_name() -> String:
	if player_name_line_edit == null:
		return "Bobby"
	var cleaned := player_name_line_edit.text.strip_edges()
	if cleaned == "" or cleaned == "Player":
		return "Bobby"
	return cleaned


func _rebuild_slots() -> void:
	for child in slots_wrap.get_children():
		slots_wrap.remove_child(child)
		child.queue_free()

	var summaries := SaveManager.get_all_slot_summaries()
	var can_duplicate := SaveManager.has_empty_slot()
	for summary in summaries:
		var slot_id := int(summary.get("slot_id", 0))
		slots_wrap.add_child(_make_slot_card(slot_id, summary, can_duplicate))


func _make_slot_card(slot_id: int, summary: Dictionary, can_duplicate: bool) -> PanelContainer:
	var exists := bool(summary.get("exists", false))

	var panel := PanelContainer.new()
	panel.name = "Slot%dPanel" % slot_id
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_slot_panel_style(exists))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)

	var name_label := Label.new()
	name_label.text = "Slot %d - %s" % [slot_id, str(summary.get("display_name", "Slot %d" % slot_id))]
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_override("font", _font)
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1) if exists else Color(0.80, 0.84, 0.92, 1))
	info.add_child(name_label)

	var meta_label := Label.new()
	meta_label.text = str(summary.get("meta_text", "Empty"))
	meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	meta_label.add_theme_font_override("font", _font)
	meta_label.add_theme_font_size_override("font_size", 15)
	meta_label.add_theme_color_override("font_color", Color(0.82, 0.88, 1.0, 1) if exists else Color(0.70, 0.74, 0.82, 1))
	info.add_child(meta_label)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	row.add_child(buttons)

	var load_button := _make_action_button("Load")
	load_button.disabled = not exists
	load_button.pressed.connect(_on_load_pressed.bind(slot_id))
	buttons.add_child(load_button)

	if exists:
		var rename_button := _make_action_button("Rename")
		rename_button.custom_minimum_size = Vector2(110, 42)
		rename_button.pressed.connect(_on_rename_pressed.bind(slot_id, str(summary.get("display_name", "Slot %d" % slot_id))))
		buttons.add_child(rename_button)
	else:
		var new_button := _make_action_button("New")
		new_button.pressed.connect(_on_new_pressed.bind(slot_id))
		buttons.add_child(new_button)

	var duplicate_button := _make_action_button("Duplicate")
	duplicate_button.custom_minimum_size = Vector2(118, 42)
	duplicate_button.disabled = not exists or not can_duplicate
	duplicate_button.pressed.connect(_on_duplicate_pressed.bind(slot_id))
	buttons.add_child(duplicate_button)

	var delete_button := _make_action_button("Delete", true)
	delete_button.disabled = not exists
	delete_button.pressed.connect(_on_delete_pressed.bind(slot_id))
	buttons.add_child(delete_button)

	return panel


func _make_action_button(text_value: String, is_delete: bool = false) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(92, 42)
	button.focus_mode = Control.FOCUS_NONE
	button.text = text_value
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_stylebox_override("normal", _make_delete_button_style(false) if is_delete else _make_button_style(false))
	button.add_theme_stylebox_override("hover", _make_delete_button_style(true) if is_delete else _make_button_style(true))
	button.add_theme_stylebox_override("pressed", _make_pressed_button_style())
	button.add_theme_stylebox_override("disabled", _make_disabled_button_style())
	return button


func _on_load_pressed(slot_id: int) -> void:
	AudioManager.play_ui_click()

	if not SaveManager.save_exists(slot_id):
		_rebuild_slots()
		_set_message("That slot is empty.")
		return

	SaveManager.set_pending_load_slot(slot_id)
	SceneTransition.change_scene(GAME_ROOT_PATH)


func _on_new_pressed(slot_id: int) -> void:
	AudioManager.play_ui_click()

	if SaveManager.save_exists(slot_id):
		_set_message("That slot already has a save. Use Rename, Duplicate, Delete, or Load.")
		_rebuild_slots()
		return

	var player_name := _get_entered_player_name()
	var result := SaveManager.create_new_save(slot_id, player_name, player_name)
	if not bool(result.get("success", false)):
		push_error("Failed to create new save in slot %d: %s" % [slot_id, str(result.get("error", "Unknown error"))])
		_set_message(str(result.get("error", "Failed to create save.")))
		return

	GameState.load_from_dictionary(result.get("data", {}))
	SaveManager.set_pending_load_slot(slot_id)
	SceneTransition.change_scene(GAME_ROOT_PATH)


func _on_rename_pressed(slot_id: int, current_name: String) -> void:
	AudioManager.play_ui_click()

	if not SaveManager.save_exists(slot_id):
		_set_message("That slot is empty.")
		_rebuild_slots()
		return

	_pending_rename_slot_id = slot_id
	if rename_title_label != null:
		rename_title_label.text = "Rename Slot %d" % slot_id
	if rename_line_edit != null:
		rename_line_edit.text = current_name
		rename_line_edit.caret_column = current_name.length()
	if rename_overlay != null:
		rename_overlay.visible = true
		rename_overlay.move_to_front()
	if rename_line_edit != null:
		rename_line_edit.grab_focus()


func _confirm_rename() -> void:
	AudioManager.play_ui_click()

	if _pending_rename_slot_id <= 0:
		_cancel_rename()
		return

	var new_name := ""
	if rename_line_edit != null:
		new_name = rename_line_edit.text

	var result := SaveManager.rename_save(_pending_rename_slot_id, new_name)
	if not bool(result.get("success", false)):
		var error_text := str(result.get("error", "Could not rename save."))
		if rename_title_label != null:
			rename_title_label.text = error_text
		_set_message(error_text)
		return

	var renamed_slot := _pending_rename_slot_id
	_pending_rename_slot_id = -1
	if rename_overlay != null:
		rename_overlay.visible = false

	_rebuild_slots()
	_set_message(str(result.get("message", "Renamed slot %d." % renamed_slot)))


func _cancel_rename() -> void:
	AudioManager.play_ui_click()
	_pending_rename_slot_id = -1
	if rename_overlay != null:
		rename_overlay.visible = false


func _on_duplicate_pressed(slot_id: int) -> void:
	AudioManager.play_ui_click()

	var result := SaveManager.duplicate_save(slot_id)
	if not bool(result.get("success", false)):
		_set_message(str(result.get("error", "Could not duplicate save.")))
		_rebuild_slots()
		return

	_rebuild_slots()
	_set_message(str(result.get("message", "Save duplicated.")))


func _on_delete_pressed(slot_id: int) -> void:
	AudioManager.play_ui_click()

	if not SaveManager.save_exists(slot_id):
		_set_message("That slot is already empty.")
		_rebuild_slots()
		return

	_pending_delete_slot_id = slot_id

	if not _should_show_delete_confirmation():
		_delete_slot_now(slot_id)
		return

	if delete_confirm_label != null:
		delete_confirm_label.text = "Are you sure you want to delete Slot %d forever?" % slot_id
	if delete_confirm_overlay != null:
		delete_confirm_overlay.visible = true
		delete_confirm_overlay.move_to_front()


func _confirm_delete() -> void:
	AudioManager.play_ui_click()

	if _pending_delete_slot_id <= 0:
		_cancel_delete()
		return

	_delete_slot_now(_pending_delete_slot_id)


func _delete_slot_now(slot_id: int) -> void:
	var deleted_slot := slot_id
	_pending_delete_slot_id = -1
	if delete_confirm_overlay != null:
		delete_confirm_overlay.visible = false

	if SaveManager.delete_save(deleted_slot):
		var compact_result := SaveManager.compact_save_slots()
		if not bool(compact_result.get("success", false)):
			_set_message(str(compact_result.get("error", "Save deleted, but rearrange failed.")))
		else:
			_set_message("Deleted slot %d. Remaining saves moved up." % deleted_slot)
	else:
		_set_message("That slot was already empty.")

	_rebuild_slots()


func _should_show_delete_confirmation() -> bool:
	if SettingsData != null and SettingsData.has_method("is_confirmation_enabled"):
		return SettingsData.is_confirmation_enabled("save_delete")
	return true


func _cancel_delete() -> void:
	AudioManager.play_ui_click()
	_pending_delete_slot_id = -1
	if delete_confirm_overlay != null:
		delete_confirm_overlay.visible = false
	_set_message("Delete cancelled.")


func _make_name_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.18, 0.28, 0.88)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 1.0, 1.0, 0.10)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style


func _make_name_input_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.22, 0.32, 0.48, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 1.0, 1.0, 0.12)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	return style


func _make_slot_panel_style(exists: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.34, 0.56, 0.94) if exists else Color(0.12, 0.16, 0.26, 0.90)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.95, 0.82, 0.40, 0.30) if exists else Color(1.0, 1.0, 1.0, 0.08)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style


func _make_button_style(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.34, 0.54, 0.86, 0.98) if hover else Color(0.22, 0.38, 0.66, 0.96)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style


func _make_delete_button_style(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.72, 0.20, 0.20, 0.98) if hover else Color(0.50, 0.14, 0.16, 0.96)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style


func _make_pressed_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.22, 0.42, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style


func _make_disabled_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.24, 0.82)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 1.0, 1.0, 0.05)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style


func _make_dialog_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.18, 0.30, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.95, 0.82, 0.40, 0.35)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	return style
