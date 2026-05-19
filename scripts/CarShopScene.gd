extends Control

signal car_shop_action_completed(result: Dictionary)
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var wallet_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/WalletLabel
@onready var current_car_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/CurrentCarLabel
@onready var owned_cars_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/OwnedCarsLabel
@onready var bonus_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/BonusLabel
@onready var car_grid: GridContainer = $Content/Layout/CarGridPanel/CarGridMargin/CarGrid
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _last_message: String = "Pick a vehicle to buy or equip. Vehicles are also visible in Inventory."

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	refresh()


func refresh() -> void:
	_refresh_summary()
	_rebuild_car_grid()
	message_label.text = _last_message


func _refresh_summary() -> void:
	wallet_label.text = "Wallet: $%d" % GameState.money
	current_car_label.text = "Current Car: %s" % GameState.get_current_car_name()
	owned_cars_label.text = "Owned Vehicles: %d / %d" % [
		GameState.get_owned_vehicle_count(),
		GameState.get_car_shop_order().size()
	]
	bonus_label.text = "Current Bonus: %s" % GameState.get_current_car_bonus_text()


func _rebuild_car_grid() -> void:
	for child in car_grid.get_children():
		child.queue_free()

	var car_ids: Array[String] = GameState.get_car_shop_order()
	for car_id in car_ids:
		car_grid.add_child(_build_car_card(car_id))


func _build_car_card(car_id: String) -> Control:
	var definition: Dictionary = GameState.get_inventory_item_definition(car_id)
	var listing: Dictionary = GameState.get_car_shop_listing(car_id)

	var car_name: String = str(definition.get("name", car_id.replace("_", " ").capitalize()))
	var price: int = int(listing.get("price", 0))
	var owned: bool = GameState.owns_vehicle(car_id)
	var equipped: bool = str(GameState.current_car_id) == car_id

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 330)
	panel.add_theme_stylebox_override("panel", _make_car_card_style(equipped, owned))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	column.add_child(top_row)

	var title_label := Label.new()
	title_label.text = car_name
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_override("font", _font)
	title_label.add_theme_font_size_override("font_size", 23)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 1))
	top_row.add_child(title_label)

	var status_label := Label.new()
	status_label.text = _get_status_text(owned, equipped)
	status_label.add_theme_font_override("font", _font)
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", _get_status_color(owned, equipped))
	top_row.add_child(status_label)

	var image := TextureRect.new()
	image.custom_minimum_size = Vector2(0, 130)
	image.texture = _load_car_texture(definition)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(image)

	var price_label := Label.new()
	price_label.text = "Price: Free Starter" if price <= 0 else "Price: $%d" % price
	price_label.add_theme_font_override("font", _font)
	price_label.add_theme_font_size_override("font_size", 17)
	price_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1))
	column.add_child(price_label)

	var stats_label := Label.new()
	stats_label.text = "Travel: %d min | Cost $%d | Style +%d | Comfort +%d" % [
		int(listing.get("travel_minutes", 25)),
		int(listing.get("travel_cost", 0)),
		int(listing.get("style_bonus", 0)),
		int(listing.get("comfort_bonus", 0))
	]
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_label.add_theme_font_override("font", _font)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0, 1))
	column.add_child(stats_label)

	var note_label := Label.new()
	note_label.text = str(listing.get("note", definition.get("description", "")))
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	note_label.add_theme_font_override("font", _font)
	note_label.add_theme_font_size_override("font_size", 15)
	note_label.add_theme_color_override("font_color", Color(0.93, 0.94, 0.98, 1))
	column.add_child(note_label)

	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 42)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_stylebox_override("normal", _make_button_style(false))
	button.add_theme_stylebox_override("hover", _make_button_style(true))
	button.add_theme_stylebox_override("pressed", _make_pressed_button_style())
	button.text = _get_button_text(owned, equipped, price)

	if equipped:
		button.disabled = true
	elif not owned and GameState.money < price:
		button.disabled = true

	button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_on_vehicle_button_pressed(car_id)
	)

	column.add_child(button)

	return panel


func _on_vehicle_button_pressed(car_id: String) -> void:
	var result: Dictionary = {}
	var was_owned: bool = GameState.owns_vehicle(car_id)

	if was_owned:
		result = GameState.equip_vehicle(car_id)
	else:
		result = GameState.buy_vehicle(car_id)

	_last_message = str(result.get("message", "Car shop updated."))

	if bool(result.get("success", false)):
		if was_owned:
			AudioManager.play_equip_car()
		else:
			AudioManager.play_buy_item()
		refresh()

	emit_signal("car_shop_action_completed", result)


func _get_status_text(owned: bool, equipped: bool) -> String:
	if equipped:
		return "Equipped"
	if owned:
		return "Owned"
	return "For Sale"


func _get_status_color(owned: bool, equipped: bool) -> Color:
	if equipped:
		return Color(0.72, 1.0, 0.74, 1)
	if owned:
		return Color(0.86, 0.95, 1.0, 1)
	return Color(1.0, 0.92, 0.62, 1)


func _get_button_text(owned: bool, equipped: bool, price: int) -> String:
	if equipped:
		return "Equipped"
	if owned:
		return "Equip"
	if price <= 0:
		return "Claim"
	if GameState.money < price:
		return "Need $%d" % price
	return "Buy"


func _load_car_texture(definition: Dictionary) -> Texture2D:
	var path: String = str(definition.get("image", ""))

	if path != "" and ResourceLoader.exists(path):
		var tex := load(path)
		if tex is Texture2D:
			return tex

	return null


func _make_car_card_style(equipped: bool, owned: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	if equipped:
		style.bg_color = Color(0.18, 0.45, 0.42, 0.95)
		style.border_color = Color(0.78, 1.0, 0.82, 0.72)
	elif owned:
		style.bg_color = Color(0.22, 0.38, 0.60, 0.94)
		style.border_color = Color(0.80, 0.92, 1.0, 0.45)
	else:
		style.bg_color = Color(0.21, 0.31, 0.48, 0.94)
		style.border_color = Color(1.0, 0.92, 0.62, 0.28)

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16

	return style


func _make_button_style(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.33, 0.54, 0.86, 0.98) if hover else Color(0.22, 0.38, 0.66, 0.96)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 18
	style.content_margin_top = 10
	style.content_margin_right = 18
	style.content_margin_bottom = 10
	return style


func _make_pressed_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.22, 0.42, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 18
	style.content_margin_top = 10
	style.content_margin_right = 18
	style.content_margin_bottom = 10
	return style
