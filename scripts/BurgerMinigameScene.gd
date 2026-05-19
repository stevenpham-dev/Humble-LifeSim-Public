extends Control

signal burger_minigame_action_completed(result: Dictionary)
signal burger_minigame_no_more_pressed

const IMAGE_BASE := "res://assets/images/burger_minigame/"
const SUCCESS_IMAGE := IMAGE_BASE + "burger_success_check.png"
const WRONG_IMAGE := IMAGE_BASE + "burger_wrong_x.png"

const INGREDIENTS := [
	{"id": "bottom_bun", "name": "Bottom Bun", "image": IMAGE_BASE + "bottom_bun.png"},
	{"id": "meat_patty", "name": "Meat Patty", "image": IMAGE_BASE + "meat_patty.png"},
	{"id": "cheese", "name": "Cheese", "image": IMAGE_BASE + "cheese.png"},
	{"id": "ketchup", "name": "Ketchup", "image": IMAGE_BASE + "ketchup.png"},
	{"id": "mustard", "name": "Mustard", "image": IMAGE_BASE + "mustard.png"},
	{"id": "onion", "name": "Onion", "image": IMAGE_BASE + "onion.png"},
	{"id": "pickles", "name": "Pickles", "image": IMAGE_BASE + "pickles.png"},
	{"id": "top_bun", "name": "Top Bun", "image": IMAGE_BASE + "top_bun.png"}
]

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var wallet_label: Label = $Content/Layout/TopRow/WalletLabel
@onready var order_label: Label = $Content/Layout/HeaderPanel/HeaderMargin/HeaderColumn/OrderLabel
@onready var streak_label: Label = $Content/Layout/HeaderPanel/HeaderMargin/HeaderColumn/StreakLabel
@onready var progress_label: Label = $Content/Layout/HeaderPanel/HeaderMargin/HeaderColumn/ProgressLabel
@onready var order_list: VBoxContainer = $Content/Layout/GamePanel/GameMargin/MainRow/OrderPanel/OrderMargin/OrderList
@onready var card_grid: GridContainer = $Content/Layout/GamePanel/GameMargin/MainRow/CardPanel/CardMargin/CardGrid
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel
@onready var result_overlay: Control = $ResultOverlay
@onready var result_panel: PanelContainer = $ResultOverlay/CenterContainer/ResultPanel
@onready var result_icon: TextureRect = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ResultIcon
@onready var result_title: Label = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ResultTitle
@onready var result_details: Label = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ResultDetails
@onready var play_again_button: Button = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ButtonRow/PlayAgainButton
@onready var no_more_button: Button = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ButtonRow/NoMoreButton

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _next_index: int = 0
var _round_over: bool = false

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("burger_minigame_no_more_pressed")
	)

	play_again_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_start_round()
	)

	no_more_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("burger_minigame_no_more_pressed")
	)

	_start_round()


func _start_round() -> void:
	_next_index = 0
	_round_over = false
	result_overlay.visible = false
	wallet_label.text = "Wallet: $%d" % GameState.money
	streak_label.text = "Current streak: %d | Best: %d" % [GameState.get_burger_streak(), GameState.get_best_burger_streak()]
	order_label.text = "Order: " + " -> ".join(_get_order_names())

	if GameState.has_method("can_play_burger_minigame"):
		var play_check: Dictionary = GameState.can_play_burger_minigame()
		if not bool(play_check.get("success", false)):
			_round_over = true
			message_label.text = str(play_check.get("message", "You cannot work Burger Town right now."))
			_update_progress_label()
			_rebuild_order_list()
			for child in card_grid.get_children():
				child.queue_free()
			return

	message_label.text = "Click the ingredient cards in the correct order. Wrong click ends the round."
	_update_progress_label()
	_rebuild_order_list()
	_rebuild_cards()


func _get_order_names() -> Array[String]:
	var names: Array[String] = []
	for ingredient in INGREDIENTS:
		var data: Dictionary = ingredient
		names.append(str(data.get("name", "Ingredient")))
	return names


func _rebuild_order_list() -> void:
	for child in order_list.get_children():
		child.queue_free()

	for i in range(INGREDIENTS.size()):
		var data: Dictionary = INGREDIENTS[i]
		var label := Label.new()
		label.text = "%d. %s" % [i + 1, str(data.get("name", "Ingredient"))]
		label.add_theme_font_override("font", _font)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1))
		order_list.add_child(label)


func _rebuild_cards() -> void:
	for child in card_grid.get_children():
		child.queue_free()

	var shuffled: Array = INGREDIENTS.duplicate(true)
	shuffled.shuffle()

	for ingredient in shuffled:
		var data: Dictionary = ingredient
		card_grid.add_child(_build_ingredient_card(data))


func _build_ingredient_card(data: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 176)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.add_theme_stylebox_override("normal", _make_card_style(false))
	button.add_theme_stylebox_override("hover", _make_card_style(true))
	button.add_theme_stylebox_override("pressed", _make_card_pressed_style())

	var image := TextureRect.new()
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.offset_left = 10
	image.offset_top = 12
	image.offset_right = -10
	image.offset_bottom = -44
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = _load_texture(str(data.get("image", "")))
	button.add_child(image)

	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name_label.offset_left = 8
	name_label.offset_top = -42
	name_label.offset_right = -8
	name_label.offset_bottom = -8
	name_label.text = str(data.get("name", "Ingredient"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_override("font", _font)
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color(1, 0.96, 0.82, 1))
	button.add_child(name_label)

	var number_label := Label.new()
	number_label.name = "OrderNumberLabel"
	number_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	number_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	number_label.offset_left = -58
	number_label.offset_top = 8
	number_label.offset_right = -10
	number_label.offset_bottom = 58
	number_label.text = ""
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number_label.add_theme_font_override("font", _font)
	number_label.add_theme_font_size_override("font_size", 36)
	number_label.add_theme_color_override("font_color", Color(0.98, 0.08, 0.08, 1))
	button.add_child(number_label)

	button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_on_card_pressed(button, data)
	)

	return button


func _on_card_pressed(button: Button, data: Dictionary) -> void:
	if _round_over:
		return

	var expected: Dictionary = INGREDIENTS[_next_index]
	var clicked_id: String = str(data.get("id", ""))
	var expected_id: String = str(expected.get("id", ""))

	if clicked_id != expected_id:
		AudioManager.play_burger_wrong()
		_show_result(false)
		return

	var number_label := button.get_node_or_null("OrderNumberLabel")
	if number_label is Label:
		number_label.text = str(_next_index + 1)

	AudioManager.play_burger_correct()
	button.disabled = true
	_next_index += 1
	_update_progress_label()

	if _next_index >= INGREDIENTS.size():
		_show_result(true)
	else:
		var next_data: Dictionary = INGREDIENTS[_next_index]
		message_label.text = "Good! Next: %s" % str(next_data.get("name", "Ingredient"))


func _update_progress_label() -> void:
	progress_label.text = "Progress: %d / %d" % [_next_index, INGREDIENTS.size()]


func _show_result(success: bool) -> void:
	_round_over = true
	var result: Dictionary = GameState.complete_burger_minigame(success)
	wallet_label.text = "Wallet: $%d" % GameState.money
	streak_label.text = "Current streak: %d | Best: %d" % [GameState.get_burger_streak(), GameState.get_best_burger_streak()]

	if success:
		AudioManager.play_burger_success()
		result_title.text = "Well done!"
		result_details.text = str(result.get("stat_effects", "Burger completed."))
		result_icon.texture = _load_texture(SUCCESS_IMAGE)
		message_label.text = "Burger completed successfully."
	else:
		result_title.text = "Wrong Order!"
		result_details.text = str(result.get("stat_effects", "Try again."))
		result_icon.texture = _load_texture(WRONG_IMAGE)
		message_label.text = "Wrong order. Try again when ready."

	if _should_show_result_panel():
		result_overlay.visible = true
		emit_signal("burger_minigame_action_completed", result)
	else:
		result_overlay.visible = false
		emit_signal("burger_minigame_action_completed", result)
		call_deferred("_auto_start_next_round")


func _should_show_result_panel() -> bool:
	if SettingsData != null and SettingsData.has_method("is_confirmation_enabled"):
		return SettingsData.is_confirmation_enabled("burger_minigame_result")
	return true


func _auto_start_next_round() -> void:
	if not is_inside_tree():
		return
	_start_round()


func _load_texture(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		var texture := load(path)
		if texture is Texture2D:
			return texture
	return null


func _make_card_style(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.34, 0.50, 0.72, 0.98) if hover else Color(0.24, 0.39, 0.61, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.92, 0.62, 0.35)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style


func _make_card_pressed_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.28, 0.48, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.82, 0.36, 0.55)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style
