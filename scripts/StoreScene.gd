extends Control

signal store_action_completed

@onready var description_label: Label = $Content/Layout/DescriptionLabel
@onready var summary_text: Label = $Content/Layout/StoreSummaryPanel/StoreSummaryMargin/StoreSummaryColumn/StoreSummaryText
@onready var item_list: VBoxContainer = $Content/Layout/ItemListPanel/ItemListMargin/ItemScroll/ItemList

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _active_category: String = "all"
var _bulk_mode: String = ""
var _custom_bulk_amount: int = 1
var _custom_bulk_line_edit: LineEdit = null

func _ready() -> void:
	_refresh_store()


func _refresh_store() -> void:
	for child in item_list.get_children():
		child.queue_free()

	description_label.text = "Welcome to the Super Market. Buy food, books, and useful items for your daily life."
	summary_text.text = "Money: $%d | Category: %s | Bulk: %s | Books are consumed at School." % [
		GameState.money,
		_active_category.capitalize(),
		_get_bulk_display_text()
	]

	item_list.add_child(_build_category_and_bulk_row())

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	item_list.add_child(grid)

	for item_id in GameState.STORE_ITEMS.keys():
		var id_text := str(item_id)
		if id_text == "study_guide":
			continue

		var definition: Dictionary = GameState.get_store_item_definition(id_text)
		if bool(definition.get("retired", false)):
			continue

		var category: String = str(definition.get("category", ""))

		if _active_category != "all" and category != _active_category:
			continue

		grid.add_child(_build_item_card(id_text))


func _build_category_and_bulk_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	for category in ["all", "food", "book"]:
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 42)
		button.text = category.capitalize()
		button.add_theme_font_override("font", _font)
		button.add_theme_font_size_override("font_size", 16)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_stylebox_override("normal", _make_button_style(category == _active_category))
		button.add_theme_stylebox_override("hover", _make_button_hover_style())
		button.add_theme_stylebox_override("pressed", _make_button_pressed_style())

		button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			_active_category = category
			_refresh_store()
		)

		row.add_child(button)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var bulk_label := Label.new()
	bulk_label.text = "Bulk:"
	bulk_label.add_theme_font_override("font", _font)
	bulk_label.add_theme_font_size_override("font_size", 18)
	bulk_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 1))
	bulk_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(bulk_label)

	row.add_child(_make_bulk_button("x5", "x5"))
	row.add_child(_make_bulk_button("x100", "x100"))
	row.add_child(_build_custom_bulk_control())

	return row


func _make_bulk_button(text_value: String, mode_value: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(80, 42)
	button.text = text_value
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 15)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _make_button_style(_bulk_mode == mode_value))
	button.add_theme_stylebox_override("hover", _make_button_hover_style())
	button.add_theme_stylebox_override("pressed", _make_button_pressed_style())
	button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_toggle_bulk_mode(mode_value)
	)
	return button


func _build_custom_bulk_control() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var custom_button := _make_bulk_button("Custom", "custom")
	custom_button.custom_minimum_size = Vector2(104, 42)
	row.add_child(custom_button)

	_custom_bulk_line_edit = LineEdit.new()
	_custom_bulk_line_edit.custom_minimum_size = Vector2(76, 42)
	_custom_bulk_line_edit.text = str(_custom_bulk_amount)
	_custom_bulk_line_edit.placeholder_text = "1"
	_custom_bulk_line_edit.clear_button_enabled = true
	_custom_bulk_line_edit.add_theme_font_override("font", _font)
	_custom_bulk_line_edit.add_theme_font_size_override("font_size", 15)
	_custom_bulk_line_edit.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_custom_bulk_line_edit.add_theme_stylebox_override("normal", _make_input_style(_bulk_mode == "custom"))
	_custom_bulk_line_edit.text_submitted.connect(func(_text: String) -> void:
		AudioManager.play_ui_click()
		_update_custom_bulk_amount_from_text()
		_bulk_mode = "custom"
		_refresh_store()
	)
	_custom_bulk_line_edit.focus_exited.connect(func() -> void:
		_update_custom_bulk_amount_from_text()
	)
	row.add_child(_custom_bulk_line_edit)

	return row


func _toggle_bulk_mode(mode_value: String) -> void:
	if _bulk_mode == mode_value:
		_bulk_mode = ""
	else:
		if mode_value == "custom":
			_update_custom_bulk_amount_from_text()
		_bulk_mode = mode_value
	_refresh_store()


func _update_custom_bulk_amount_from_text() -> void:
	if _custom_bulk_line_edit == null:
		return
	var cleaned := _custom_bulk_line_edit.text.strip_edges()
	cleaned = cleaned.replace(",", "")
	if cleaned == "" or not cleaned.is_valid_int():
		_custom_bulk_amount = 1
		return
	_custom_bulk_amount = clampi(int(cleaned), 1, 9999)


func _get_selected_buy_amount() -> int:
	match _bulk_mode:
		"x5":
			return 5
		"x100":
			return 100
		"custom":
			return maxi(1, _custom_bulk_amount)
		_:
			return 1


func _get_bulk_display_text() -> String:
	var amount := _get_selected_buy_amount()
	if amount <= 1:
		return "Buy 1"
	return "Buy %d" % amount


func _build_item_card(item_id: String) -> Control:
	var definition: Dictionary = GameState.get_store_item_definition(item_id)
	var category: String = str(definition.get("category", "item"))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 230)
	panel.add_theme_stylebox_override("panel", _make_card_style(category))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var icon_box := PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(128, 128)
	icon_box.add_theme_stylebox_override("panel", _make_icon_box_style(category))
	row.add_child(icon_box)

	var icon_margin := MarginContainer.new()
	icon_margin.add_theme_constant_override("margin_left", 10)
	icon_margin.add_theme_constant_override("margin_top", 10)
	icon_margin.add_theme_constant_override("margin_right", 10)
	icon_margin.add_theme_constant_override("margin_bottom", 10)
	icon_box.add_child(icon_margin)

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _load_item_texture(definition)
	icon_margin.add_child(icon)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 6)
	row.add_child(text_col)

	var title := Label.new()
	title.text = str(definition.get("name", item_id))
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.98, 0.78, 1))
	text_col.add_child(title)

	var info := Label.new()
	info.text = _get_item_info_text(item_id)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_override("font", _font)
	info.add_theme_font_size_override("font_size", 15)
	info.add_theme_color_override("font_color", Color(0.97, 0.98, 1, 1))
	text_col.add_child(info)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	text_col.add_child(button_row)

	var buy_amount := _get_selected_buy_amount()
	var buy_button := _make_buy_button("Buy %d" % buy_amount)
	buy_button.pressed.connect(func() -> void:
		_buy_item(item_id, _get_selected_buy_amount())
	)
	button_row.add_child(buy_button)

	return panel


func _buy_item(item_id: String, amount: int) -> void:
	var result: Dictionary = GameState.buy_store_item(item_id, amount)
	if bool(result.get("success", false)):
		AudioManager.play_buy_item()
	else:
		AudioManager.play_ui_click()
	description_label.text = str(result.get("message", ""))
	_refresh_store()
	emit_signal("store_action_completed", result)


func _make_buy_button(text_value: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(124, 38)
	button.text = text_value
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 15)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _make_button_style(false))
	button.add_theme_stylebox_override("hover", _make_button_hover_style())
	button.add_theme_stylebox_override("pressed", _make_button_pressed_style())
	return button


func _load_item_texture(definition: Dictionary) -> Texture2D:
	var path: String = str(definition.get("image", ""))

	if path != "" and ResourceLoader.exists(path):
		var tex := load(path)
		if tex is Texture2D:
			return tex

	return null


func _get_item_info_text(item_id: String) -> String:
	var definition: Dictionary = GameState.get_store_item_definition(item_id)
	var category: String = str(definition.get("category", "item"))
	var owned: int = GameState.get_inventory_quantity(item_id)

	var lines: Array[String] = []
	lines.append("Price: $%d | Owned: %d" % [int(definition.get("price", 0)), owned])

	if category == "food":
		var food_line := "Food: +%d | %s | Health %+d" % [
			int(definition.get("hunger_value", 0)),
			str(definition.get("food_type", "unknown")).capitalize(),
			int(definition.get("health_effect", 0))
		]
		var extra_text := ""
		if GameState.has_method("get_food_item_extra_effect_text"):
			extra_text = GameState.get_food_item_extra_effect_text(item_id)
		if extra_text.strip_edges() != "":
			food_line += " | " + extra_text
		lines.append(food_line)
	elif category == "book":
		if bool(definition.get("retired", false)):
			lines.append("Retired book | No longer sold or used for credential progress")
		elif GameState.has_method("get_book_study_effect_text"):
			lines.append("Book item | Study at School | %s" % GameState.get_book_study_effect_text(item_id))
		else:
			lines.append("Book item | Study at School | +3 Progress | 3 hours")

	lines.append(str(definition.get("description", "")))

	return "\n".join(lines)


func _make_card_style(category: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	match category:
		"food":
			style.bg_color = Color(0.13, 0.58, 0.34, 0.96)
			style.border_color = Color(0.75, 1.0, 0.70, 0.45)
		"book":
			style.bg_color = Color(0.50, 0.34, 0.82, 0.96)
			style.border_color = Color(0.92, 0.82, 1.0, 0.45)
		_:
			style.bg_color = Color(0.24, 0.36, 0.52, 0.96)
			style.border_color = Color(1, 1, 1, 0.20)

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16

	return style


func _make_icon_box_style(category: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	match category:
		"food":
			style.bg_color = Color(0.80, 1.0, 0.72, 0.28)
		"book":
			style.bg_color = Color(0.90, 0.78, 1.0, 0.28)
		_:
			style.bg_color = Color(1, 1, 1, 0.12)

	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14

	return style


func _make_button_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.26, 0.48, 0.82, 0.96) if active else Color(0.22, 0.32, 0.56, 0.96)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _make_button_hover_style() -> StyleBoxFlat:
	var style := _make_button_style(false)
	style.bg_color = Color(0.38, 0.58, 0.92, 0.98)
	return style


func _make_button_pressed_style() -> StyleBoxFlat:
	var style := _make_button_style(false)
	style.bg_color = Color(0.12, 0.22, 0.42, 1.0)
	return style


func _make_input_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.24, 0.34, 0.56, 0.98) if active else Color(0.18, 0.25, 0.42, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.18) if active else Color(1, 1, 1, 0.08)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
