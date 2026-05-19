extends Control

signal inventory_action_completed

@onready var close_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleRow/CloseButton

@onready var category_option: OptionButton = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ToolbarPanel/ToolbarMargin/ToolbarRow/CategoryOptionButton
@onready var search_line_edit: LineEdit = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ToolbarPanel/ToolbarMargin/ToolbarRow/SearchLineEdit
@onready var sort_option: OptionButton = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ToolbarPanel/ToolbarMargin/ToolbarRow/SortOptionButton
@onready var item_count_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ToolbarPanel/ToolbarMargin/ToolbarRow/ItemCountLabel

@onready var item_grid: GridContainer = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/GridPanel/GridMargin/ItemScroll/ItemGrid

@onready var detail_title_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailTitleLabel
@onready var detail_image: TextureRect = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailScroll/DetailScrollColumn/DetailImagePanel/DetailImageMargin/DetailImage
@onready var detail_category_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailScroll/DetailScrollColumn/DetailCategoryLabel
@onready var detail_quantity_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailScroll/DetailScrollColumn/DetailQuantityLabel
@onready var detail_description_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailScroll/DetailScrollColumn/DetailDescriptionLabel
@onready var detail_effects_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailScroll/DetailScrollColumn/DetailEffectsLabel
@onready var detail_scroll: ScrollContainer = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/DetailScroll
@onready var use_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/ActionRows/UseRow/UseButton
@onready var eat_five_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/ActionRows/UseRow/EatUntilFullButton
@onready var secondary_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/ActionRows/DropRow/SecondaryButton
@onready var drop_five_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/ActionRows/DropRow/DropFiveButton
@onready var drop_all_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyRow/DetailPanel/DetailMargin/DetailColumn/ActionRows/DropRow/DropAllButton

@onready var footer_hint_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/FooterPanel/FooterMargin/FooterHintLabel

const GRID_COLUMNS := 4
const MIN_VISIBLE_SLOTS := 12

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _active_category: String = "all"
var _search_text: String = ""
var _sort_mode: String = "name"
var _selected_item_id: String = ""

const EXTRA_ITEM_DEFINITIONS := {
	"starter_car": {
		"name": "Starter Car",
		"category": "vehicle",
		"image": "res://assets/images/cars/starter_car.png",
		"description": "Your first basic car. Reliable enough to travel around town.",
		"use_text": "Equip"
	},
	"used_sedan": {
		"name": "Used Sedan",
		"category": "vehicle",
		"image": "res://assets/images/cars/used_sedan.png",
		"description": "Affordable daily driver. A practical upgrade from the starter car.",
		"use_text": "Equip"
	},
	"compact_car": {
		"name": "Compact Car",
		"category": "vehicle",
		"image": "res://assets/images/cars/compact_car.png",
		"description": "Small, efficient, and easy to maintain.",
		"use_text": "Equip"
	},
	"camaro": {
		"name": "Camaro",
		"category": "vehicle",
		"image": "res://assets/images/cars/camaro.png",
		"description": "A stylish Camaro for players who saved up.",
		"use_text": "Equip"
	},
	"mustang": {
		"name": "Mustang Shelby",
		"category": "vehicle",
		"image": "res://assets/images/cars/mustang.png",
		"description": "A high-end dream car and a major status upgrade.",
		"use_text": "Equip"
	},
	"sports_coupe": {
		"name": "Sports Coupe",
		"category": "vehicle",
		"image": "res://assets/images/cars/sports_coupe.png",
		"description": "Fast, flashy, and expensive to own.",
		"use_text": "Equip"
	},
	"family_suv": {
		"name": "Family SUV",
		"category": "vehicle",
		"image": "res://assets/images/cars/family_suv.png",
		"description": "Comfortable vehicle with plenty of space.",
		"use_text": "Equip"
	},
	"electric_car": {
		"name": "Electric Car",
		"category": "vehicle",
		"image": "res://assets/images/cars/electric_car.png",
		"description": "Modern electric vehicle for a late-game lifestyle upgrade.",
		"use_text": "Equip"
	},
	"car_keys": {
		"name": "Car Keys",
		"category": "special",
		"image": "res://assets/images/items/car_keys.png",
		"description": "A special key item connected to travel and vehicles.",
		"use_text": "View"
	},
	"house_key": {
		"name": "House Key",
		"category": "special",
		"image": "res://assets/images/items/house_key.png",
		"description": "A basic life item connected to housing.",
		"use_text": "View"
	},
	"student_id": {
		"name": "Student ID",
		"category": "special",
		"image": "res://assets/images/items/student_id.png",
		"description": "A school-related item for education progression.",
		"use_text": "View"
	},
	"debit_card": {
		"name": "Debit Card",
		"category": "special",
		"image": "res://assets/images/items/debit_card.png",
		"description": "A banking item for future money-management systems.",
		"use_text": "View"
	},
	"job_badge": {
		"name": "Job Badge",
		"category": "special",
		"image": "res://assets/images/items/job_badge.png",
		"description": "A workplace item that represents career progress.",
		"use_text": "View"
	},
	"diploma": {
		"name": "Diploma",
		"category": "special",
		"image": "res://assets/images/items/diploma.png",
		"description": "A generic diploma-style item. Specific degrees earned at School use this image.",
		"use_text": "View",
		"permanent": true
	},
	"certificate_scroll": {
		"name": "Certificate",
		"category": "special",
		"image": "res://assets/images/items/certificate_scroll.png",
		"description": "A generic certificate-style item. Specific credentials earned at School use this image.",
		"use_text": "View",
		"permanent": true
	},
	"sales_certificate": {
		"name": "Sales Certificate",
		"category": "credential",
		"image": "res://assets/images/items/certificate_scroll.png",
		"description": "Earned at School. Required for Sales jobs.",
		"use_text": "View",
		"permanent": true
	},
	"teaching_credential": {
		"name": "Teaching Credential",
		"category": "credential",
		"image": "res://assets/images/items/certificate_scroll.png",
		"description": "Earned at School. Required for Teacher jobs.",
		"use_text": "View",
		"permanent": true
	},
	"programming_certificate": {
		"name": "Programming Certificate",
		"category": "credential",
		"image": "res://assets/images/items/certificate_scroll.png",
		"description": "Earned at School. Required for Programmer jobs.",
		"use_text": "View",
		"permanent": true
	},
	"nursing_license": {
		"name": "Nursing License",
		"category": "credential",
		"image": "res://assets/images/items/certificate_scroll.png",
		"description": "Earned at School. Required for Nurse jobs.",
		"use_text": "View",
		"permanent": true
	},
	"engineering_degree": {
		"name": "Engineering Degree",
		"category": "credential",
		"image": "res://assets/images/items/diploma.png",
		"description": "Earned at School. Required for Engineer jobs.",
		"use_text": "View",
		"permanent": true
	},
	"medical_degree": {
		"name": "Medical Degree",
		"category": "credential",
		"image": "res://assets/images/items/diploma.png",
		"description": "Earned at School. Required for Doctor jobs.",
		"use_text": "View",
		"permanent": true
	},
	"advanced_degree": {
		"name": "Advanced Degree",
		"category": "credential",
		"image": "res://assets/images/items/diploma.png",
		"description": "Earned at School. Required for Professor jobs.",
		"use_text": "View",
		"permanent": true
	}
}


func _ready() -> void:
	_setup_dropdowns()

	close_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		visible = false
	)

	category_option.item_selected.connect(func(_index: int) -> void:
		AudioManager.play_ui_click()
		_active_category = _get_category_from_selected_id(category_option.get_selected_id())
		refresh()
	)

	sort_option.item_selected.connect(func(_index: int) -> void:
		AudioManager.play_ui_click()
		_sort_mode = _get_sort_mode_from_selected_id(sort_option.get_selected_id())
		refresh()
	)

	search_line_edit.text_changed.connect(func(new_text: String) -> void:
		_search_text = new_text.strip_edges().to_lower()
		refresh()
	)

	use_button.pressed.connect(_on_use_pressed)
	eat_five_button.pressed.connect(_on_eat_five_pressed)
	secondary_button.pressed.connect(_on_secondary_pressed)
	_setup_extra_drop_buttons()

	refresh()


func _setup_extra_drop_buttons() -> void:
	# Drop buttons are now part of InventoryPanel.tscn. Keeping them in their
	# own row prevents long item descriptions plus five action buttons from
	# stretching or squishing the inventory window.
	if drop_five_button != null and not drop_five_button.pressed.is_connected(Callable(self, "_on_drop_five_pressed")):
		drop_five_button.pressed.connect(_on_drop_five_pressed)
	if drop_all_button != null and not drop_all_button.pressed.is_connected(Callable(self, "_on_drop_all_pressed")):
		drop_all_button.pressed.connect(_on_drop_all_pressed)


func _on_drop_five_pressed() -> void:
	_drop_selected_amount(5)


func _on_drop_all_pressed() -> void:
	_drop_selected_amount(-1)

func _setup_dropdowns() -> void:
	category_option.clear()
	category_option.add_item("All Items", 0)
	category_option.add_item("Food", 1)
	category_option.add_item("Books", 2)
	category_option.add_item("Vehicles", 3)
	category_option.add_item("Special", 4)
	category_option.add_item("Credentials", 5)
	category_option.select(0)

	sort_option.clear()
	sort_option.add_item("Sort: Name", 0)
	sort_option.add_item("Sort: Quantity", 1)
	sort_option.add_item("Sort: Category", 2)
	sort_option.select(0)


func refresh() -> void:
	for child in item_grid.get_children():
		child.queue_free()

	var entries: Array[Dictionary] = _get_filtered_inventory_entries()
	_sort_entries(entries)

	if _selected_item_id != "" and not _entries_contain_item(entries, _selected_item_id):
		_selected_item_id = ""

	if _selected_item_id == "" and not entries.is_empty():
		_selected_item_id = str(entries[0].get("id", ""))

	var slot_count: int = _get_visible_slot_count(entries.size())
	item_count_label.text = "Items: %d | Slots: %d" % [entries.size(), slot_count]

	for i in range(slot_count):
		if i < entries.size():
			item_grid.add_child(_build_item_slot(entries[i]))
		else:
			item_grid.add_child(_build_empty_slot())

	_refresh_detail_panel()


func open_inventory() -> void:
	refresh()
	visible = true


func close_inventory() -> void:
	visible = false


func _get_visible_slot_count(item_count: int) -> int:
	var rows_needed: int = ceili(float(item_count) / float(GRID_COLUMNS))
	var slots_needed: int = rows_needed * GRID_COLUMNS
	return max(MIN_VISIBLE_SLOTS, slots_needed)


func _get_category_from_selected_id(id: int) -> String:
	match id:
		1:
			return "food"
		2:
			return "book"
		3:
			return "vehicle"
		4:
			return "special"
		5:
			return "credential"
		_:
			return "all"


func _get_sort_mode_from_selected_id(id: int) -> String:
	match id:
		1:
			return "quantity"
		2:
			return "category"
		_:
			return "name"


func _get_filtered_inventory_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for item in GameState.inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var item_id: String = str(item.get("id", ""))
		var quantity: int = int(item.get("quantity", 0))

		if item_id == "" or quantity <= 0:
			continue

		var definition: Dictionary = _get_item_definition(item_id)
		var category: String = str(definition.get("category", "special"))

		if _active_category != "all" and category != _active_category:
			continue

		if _search_text != "":
			var item_name: String = str(definition.get("name", item_id)).to_lower()
			var item_description: String = str(definition.get("description", "")).to_lower()

			if not item_name.contains(_search_text) and not item_description.contains(_search_text) and not item_id.to_lower().contains(_search_text):
				continue

		result.append({
			"id": item_id,
			"quantity": quantity
		})

	return result


func _sort_entries(entries: Array[Dictionary]) -> void:
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_id: String = str(a.get("id", ""))
		var b_id: String = str(b.get("id", ""))
		var a_def: Dictionary = _get_item_definition(a_id)
		var b_def: Dictionary = _get_item_definition(b_id)

		if _sort_mode == "quantity":
			var a_quantity: int = int(a.get("quantity", 0))
			var b_quantity: int = int(b.get("quantity", 0))
			if a_quantity == b_quantity:
				return str(a_def.get("name", a_id)).to_lower() < str(b_def.get("name", b_id)).to_lower()
			return a_quantity > b_quantity

		if _sort_mode == "category":
			var a_category: String = str(a_def.get("category", "special"))
			var b_category: String = str(b_def.get("category", "special"))
			if a_category == b_category:
				return str(a_def.get("name", a_id)).to_lower() < str(b_def.get("name", b_id)).to_lower()
			return a_category < b_category

		return str(a_def.get("name", a_id)).to_lower() < str(b_def.get("name", b_id)).to_lower()
	)


func _entries_contain_item(entries: Array[Dictionary], item_id: String) -> bool:
	for entry in entries:
		if str(entry.get("id", "")) == item_id:
			return true
	return false


func _build_item_slot(entry: Dictionary) -> Control:
	var item_id: String = str(entry.get("id", ""))
	var quantity: int = int(entry.get("quantity", 0))
	var definition: Dictionary = _get_item_definition(item_id)
	var category: String = str(definition.get("category", "special"))
	var is_selected: bool = item_id == _selected_item_id

	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 148)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.text = ""
	button.add_theme_stylebox_override("normal", _make_slot_style(category, is_selected))
	button.add_theme_stylebox_override("hover", _make_slot_hover_style(category))
	button.add_theme_stylebox_override("pressed", _make_slot_pressed_style())

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.offset_left = 10
	margin.offset_top = 10
	margin.offset_right = -10
	margin.offset_bottom = -10
	button.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(0, 72)
	icon.texture = _load_item_texture(definition)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(icon)

	var title_label := Label.new()
	title_label.text = str(definition.get("name", item_id))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_override("font", _font)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	column.add_child(title_label)

	var quantity_label := Label.new()
	quantity_label.text = "x%d" % quantity
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quantity_label.add_theme_font_override("font", _font)
	quantity_label.add_theme_font_size_override("font_size", 16)
	quantity_label.add_theme_color_override("font_color", Color(1, 0.96, 0.70, 1))
	column.add_child(quantity_label)

	_make_children_ignore_mouse(button)

	button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_selected_item_id = item_id
		refresh()
	)

	return button


func _build_empty_slot() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 148)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_empty_slot_style())

	var label := Label.new()
	label.text = "Empty"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	panel.add_child(label)

	return panel


func _refresh_detail_panel() -> void:
	if detail_scroll != null:
		detail_scroll.scroll_vertical = 0
	if _selected_item_id == "":
		detail_title_label.text = "No Item Selected"
		detail_image.texture = null
		detail_category_label.text = "Category: -"
		detail_quantity_label.text = "Owned: 0"
		detail_description_label.text = "Select an item to view details."
		detail_effects_label.text = ""
		use_button.text = "Use"
		use_button.disabled = true
		eat_five_button.text = "Eat Until Full"
		eat_five_button.visible = false
		eat_five_button.disabled = true
		secondary_button.text = "Drop 1"
		secondary_button.disabled = true
		if drop_five_button != null:
			drop_five_button.visible = false
			drop_five_button.disabled = true
		if drop_all_button != null:
			drop_all_button.visible = false
			drop_all_button.disabled = true
		footer_hint_label.text = "Your inventory starts with 12 visible slots and expands by rows as you collect more items."
		return

	var quantity: int = GameState.get_inventory_quantity(_selected_item_id)
	var definition: Dictionary = _get_item_definition(_selected_item_id)
	var category: String = str(definition.get("category", "special"))

	detail_title_label.text = str(definition.get("name", _selected_item_id))
	detail_image.texture = _load_item_texture(definition)
	detail_category_label.text = "Category: %s" % _get_display_category(category)
	detail_quantity_label.text = "Owned: %d" % quantity
	var is_equipped_vehicle := category == "vehicle" and _selected_item_id == str(GameState.current_car_id)
	var description_text := str(definition.get("description", "No description available."))
	if is_equipped_vehicle:
		description_text += "\n\nStatus: Equipped. This vehicle is currently active for travel."
	detail_description_label.text = description_text
	detail_effects_label.text = _build_effect_text(_selected_item_id, definition)

	use_button.text = "Equipped" if is_equipped_vehicle else str(definition.get("use_text", _get_default_use_text(category)))
	var retired_book := category == "book" and bool(definition.get("retired", false))
	use_button.disabled = retired_book or is_equipped_vehicle or not _can_use_item(category)
	use_button.add_theme_stylebox_override("disabled", _make_disabled_action_style())
	eat_five_button.visible = category == "food"
	eat_five_button.text = str(definition.get("booster_until_full_text", "Eat Until Full"))
	eat_five_button.disabled = category != "food" or quantity <= 0
	eat_five_button.add_theme_stylebox_override("disabled", _make_disabled_action_style())

	secondary_button.text = "Drop 1"
	var is_permanent := false
	if GameState.has_method("is_permanent_inventory_item"):
		is_permanent = bool(GameState.is_permanent_inventory_item(_selected_item_id))
	else:
		is_permanent = _selected_item_id in ["certificate_scroll", "diploma"]

	var drop_disabled := quantity <= 0 or _selected_item_id == str(GameState.current_car_id) or is_permanent
	secondary_button.disabled = drop_disabled
	if drop_five_button != null:
		drop_five_button.visible = true
		drop_five_button.disabled = drop_disabled or quantity < 2
	if drop_all_button != null:
		drop_all_button.visible = true
		drop_all_button.disabled = drop_disabled

	if _selected_item_id == str(GameState.current_car_id):
		footer_hint_label.text = "This vehicle is currently equipped."
	elif category == "credential":
		footer_hint_label.text = "Credentials are permanent achievements earned at School and used for job applications."
	else:
		footer_hint_label.text = "Food can be eaten manually or automatically during sleep. Books are consumed at School for stronger credential progress. Vehicles can be equipped."


func _build_effect_text(item_id: String, definition: Dictionary) -> String:
	var category: String = str(definition.get("category", "special"))

	if category == "food":
		var parts: Array[String] = [
			"Food +%d" % int(definition.get("hunger_value", 0)),
			"Health %+d" % int(definition.get("health_effect", 0))
		]
		var extra_text := ""
		if GameState.has_method("get_food_item_extra_effect_text"):
			extra_text = GameState.get_food_item_extra_effect_text(item_id)
		if extra_text.strip_edges() != "":
			parts.append(extra_text)
		return "Effect: " + " | ".join(parts)

	if category == "book":
		if item_id == "study_guide" or bool(definition.get("retired", false)):
			return "Effect: Retired book | No school or credential effect"

		var effect_text := ""
		if GameState.has_method("get_book_study_effect_text"):
			effect_text = GameState.get_book_study_effect_text(item_id)
		else:
			var effects: Dictionary = _get_book_stat_effects(item_id)
			var parts: Array[String] = ["+3 Progress"]
			for stat_name in effects.keys():
				var amount: int = int(effects[stat_name])
				parts.append("%s %+d" % [String(stat_name).capitalize(), amount])
			parts.append("3 hours")
			effect_text = " | ".join(parts)
		return "Effect: Study at School | %s" % effect_text

	if category == "vehicle":
		if GameState.has_method("get_car_shop_listing"):
			var listing: Dictionary = GameState.get_car_shop_listing(item_id)
			if not listing.is_empty():
				var effect_text := "Effect: Travel %d min | Cost $%d | Style +%d | Comfort +%d" % [
					int(listing.get("travel_minutes", 25)),
					int(listing.get("travel_cost", 0)),
					int(listing.get("style_bonus", 0)),
					int(listing.get("comfort_bonus", 0))
				]
				if item_id == str(GameState.current_car_id):
					return "%s | Equipped" % effect_text
				return effect_text
		if item_id == str(GameState.current_car_id):
			return "Effect: Currently equipped vehicle."
		return "Effect: Equip this vehicle to change travel time, travel cost, and vehicle bonuses."

	if category == "credential":
		return "Effect: Permanent credential for job applications. Cannot be dropped."

	return "Effect: Special collectible or milestone item."


func _on_use_pressed() -> void:
	if _selected_item_id == "":
		return

	AudioManager.play_ui_click()

	var result: Dictionary = {}

	var definition: Dictionary = _get_item_definition(_selected_item_id)
	var category: String = str(definition.get("category", "special"))
	var item_name: String = str(definition.get("name", _selected_item_id))

	if category == "vehicle" and _selected_item_id == str(GameState.current_car_id):
		footer_hint_label.text = "%s is already equipped." % item_name
		refresh()
		return

	if category == "book":
		if _selected_item_id == "study_guide" or bool(definition.get("retired", false)):
			footer_hint_label.text = "%s is retired and no longer gives credential progress." % item_name
			return

		result = {
			"success": true,
			"action": "go_to_school",
			"item_id": _selected_item_id,
			"message": "Study %s at School. Choose a track and press Read Book to consume it." % item_name,
			"hud_message": "Study at School: %s" % item_name
		}
		footer_hint_label.text = str(result.get("message", "Go to School."))
		emit_signal("inventory_action_completed", result)
		return

	if GameState.has_method("use_inventory_item"):
		result = GameState.use_inventory_item(_selected_item_id)
	else:
		result = _fallback_use_item(_selected_item_id)

	if bool(result.get("success", false)):
		if category == "food":
			AudioManager.play_eat_food()
		elif category == "vehicle":
			AudioManager.play_equip_car()

	footer_hint_label.text = str(result.get("message", "Used item."))
	emit_signal("inventory_action_completed", result)
	refresh()


func _on_eat_five_pressed() -> void:
	if _selected_item_id == "":
		return

	AudioManager.play_ui_click()

	var definition: Dictionary = _get_item_definition(_selected_item_id)
	var category: String = str(definition.get("category", "special"))
	if category != "food":
		footer_hint_label.text = "Only food can use Eat Until Full."
		return

	var result: Dictionary = {}
	if str(definition.get("booster_stat", "")) != "" and GameState.has_method("use_inventory_item_until_boost_full"):
		result = GameState.use_inventory_item_until_boost_full(_selected_item_id)
	elif GameState.has_method("use_inventory_item_until_full"):
		result = GameState.use_inventory_item_until_full(_selected_item_id)
	elif GameState.has_method("use_inventory_item_amount"):
		result = GameState.use_inventory_item_amount(_selected_item_id, 5)
	else:
		result = _fallback_use_item(_selected_item_id)

	if bool(result.get("success", false)):
		AudioManager.play_eat_food()

	footer_hint_label.text = str(result.get("message", "Used item."))
	emit_signal("inventory_action_completed", result)
	refresh()


func _on_secondary_pressed() -> void:
	_drop_selected_amount(1)


func _drop_selected_amount(amount: int) -> void:
	if _selected_item_id == "":
		return

	AudioManager.play_ui_click()

	if _selected_item_id == str(GameState.current_car_id):
		footer_hint_label.text = "You cannot drop your currently equipped vehicle."
		return

	var definition: Dictionary = _get_item_definition(_selected_item_id)
	var item_name := str(definition.get("name", _selected_item_id))
	var quantity := GameState.get_inventory_quantity(_selected_item_id)
	var drop_amount := quantity if amount <= 0 else mini(amount, quantity)
	if drop_amount <= 0:
		footer_hint_label.text = "Nothing to drop."
		return

	var is_permanent := false
	if GameState.has_method("is_permanent_inventory_item"):
		is_permanent = bool(GameState.is_permanent_inventory_item(_selected_item_id))
	if is_permanent:
		footer_hint_label.text = "Permanent items and credentials cannot be dropped."
		return

	var removed := false
	if GameState.has_method("remove_inventory_item"):
		removed = bool(GameState.remove_inventory_item(_selected_item_id, drop_amount))

	if removed:
		GameState.add_log("Dropped %dx %s." % [drop_amount, item_name], "inventory")
		var result := {
			"success": true,
			"message": "Dropped %dx %s." % [drop_amount, item_name],
			"hud_message": "Dropped: %dx %s" % [drop_amount, item_name]
		}
		if GameState.get_inventory_quantity(_selected_item_id) <= 0:
			_selected_item_id = ""
		footer_hint_label.text = str(result.get("message", "Dropped item."))
		emit_signal("inventory_action_completed", result)
	else:
		footer_hint_label.text = "Could not drop item."

	refresh()



func _fallback_use_item(item_id: String) -> Dictionary:
	var definition: Dictionary = _get_item_definition(item_id)
	var category: String = str(definition.get("category", "special"))
	var item_name: String = str(definition.get("name", item_id))

	if category == "vehicle":
		GameState.current_car_id = item_id
		GameState.add_log("Equipped %s." % item_name, "inventory")

		return {
			"success": true,
			"message": "Equipped %s." % item_name
		}

	if category == "food":
		if not GameState.remove_inventory_item(item_id, 1):
			return {
				"success": false,
				"message": "You do not have this food item."
			}

		var hunger_value: int = int(definition.get("hunger_value", 0))
		var health_effect: int = int(definition.get("health_effect", 0))

		GameState.hunger = clampi(GameState.hunger + hunger_value, 0, GameState.get_max_fullness() if GameState.has_method("get_max_fullness") else 100)

		GameState.health = clampi(GameState.health + health_effect, 0, GameState.get_max_health() if GameState.has_method("get_max_health") else 100)

		GameState.add_log("Ate %s." % item_name, "inventory")

		return {
			"success": true,
			"message": "Ate %s. Hunger +%d." % [item_name, hunger_value]
		}

	if category == "book":
		return {
			"success": true,
			"message": "%s is consumed at School when you press Read Book for credential progress." % item_name
		}

	if category == "credential":
		return {
			"success": true,
			"message": "%s is permanent and cannot be dropped." % item_name
		}

	return {
		"success": false,
		"message": "This item cannot be used yet."
	}


func _get_book_stat_effects(item_id: String) -> Dictionary:
	if GameState.has_method("get_book_study_stat_effects"):
		return GameState.get_book_study_stat_effects(item_id)
	match item_id:
		"study_guide":
			return {}
		"programming_book":
			return {"intelligence": 3, "education": 1, "discipline": 1}
		"fitness_book":
			return {"fitness": 2, "endurance": 2, "discipline": 1}
		"finance_book":
			return {"discipline": 2, "confidence": 1, "charisma": 1}
		"nursing_textbook":
			return {"education": 2, "endurance": 2, "intelligence": 1}
		"engineering_textbook":
			return {"intelligence": 3, "education": 2, "discipline": 1}
		"advanced_academic_textbook":
			return {"education": 3, "intelligence": 3, "discipline": 1}
		"medical_textbook":
			return {"education": 3, "intelligence": 3, "endurance": 2, "discipline": 1}
		_:
			return {"education": 1, "intelligence": 1}


func _get_item_definition(item_id: String) -> Dictionary:
	if GameState.has_method("get_inventory_item_definition"):
		var full_definition: Dictionary = GameState.get_inventory_item_definition(item_id)
		if not full_definition.is_empty():
			return full_definition

	var store_definition: Dictionary = GameState.get_store_item_definition(item_id)

	if not store_definition.is_empty():
		return store_definition

	if EXTRA_ITEM_DEFINITIONS.has(item_id):
		return EXTRA_ITEM_DEFINITIONS[item_id]

	return {
		"name": item_id.replace("_", " ").capitalize(),
		"category": "special",
		"image": "",
		"description": "A special item reserved for future systems.",
		"use_text": "View"
	}


func _load_item_texture(definition: Dictionary) -> Texture2D:
	var path: String = str(definition.get("image", ""))

	if path != "" and ResourceLoader.exists(path):
		var tex := load(path)
		if tex is Texture2D:
			return tex

	return null


func _get_display_category(category: String) -> String:
	match category:
		"food":
			return "Food"
		"book":
			return "Book"
		"vehicle":
			return "Vehicle"
		"special":
			return "Special"
		"credential":
			return "Credential"
		_:
			return category.capitalize()


func _get_default_use_text(category: String) -> String:
	match category:
		"food":
			return "Eat"
		"book":
			return "Study at School"
		"credential":
			return "View"
		"vehicle":
			return "Equip"
		_:
			return "Use"


func _can_use_item(category: String) -> bool:
	return category == "food" or category == "book" or category == "vehicle" or category == "credential"


func _make_slot_style(category: String, selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	match category:
		"food":
			style.bg_color = Color(0.22, 0.66, 0.38, 0.96)
			style.border_color = Color(0.85, 1.0, 0.70, 0.45)
		"book":
			style.bg_color = Color(0.56, 0.38, 0.86, 0.96)
			style.border_color = Color(0.95, 0.82, 1.0, 0.45)
		"vehicle":
			style.bg_color = Color(0.22, 0.50, 0.82, 0.96)
			style.border_color = Color(0.72, 0.92, 1.0, 0.50)
		"credential":
			style.bg_color = Color(0.78, 0.58, 0.18, 0.96)
			style.border_color = Color(1.0, 0.95, 0.55, 0.60)
		_:
			style.bg_color = Color(0.80, 0.56, 0.22, 0.96)
			style.border_color = Color(1.0, 0.92, 0.62, 0.48)

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	if selected:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = Color(1.0, 0.96, 0.46, 0.95)

	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14

	return style


func _make_slot_hover_style(category: String) -> StyleBoxFlat:
	var style := _make_slot_style(category, false)
	style.bg_color = style.bg_color.lightened(0.10)
	style.border_color = Color(1, 1, 1, 0.70)
	return style


func _make_slot_pressed_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.22, 0.42, 1.0)
	style.border_color = Color(1, 1, 1, 0.45)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style


func _make_empty_slot_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.16)
	style.border_color = Color(1, 1, 1, 0.16)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style


func _make_disabled_action_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.22, 0.30, 0.82)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.08)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _make_children_ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_children_ignore_mouse(child)
