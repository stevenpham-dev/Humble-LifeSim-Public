
extends Control

signal home_pressed
signal map_pressed
signal jobs_pressed
signal hints_pressed
signal inventory_pressed
signal stats_pressed
signal logs_pressed
signal save_pressed
signal menu_pressed
signal goal_skip_pressed

@onready var day_label: Label = $TopBar/TopBarMargin/TopBarRow/DayLabel
@onready var time_label: Label = $TopBar/TopBarMargin/TopBarRow/TimeLabel
@onready var money_label: Label = $TopBar/TopBarMargin/TopBarRow/MoneyLabel
@onready var energy_label: Label = $TopBar/TopBarMargin/TopBarRow/EnergyLabel
@onready var hunger_label: Label = $TopBar/TopBarMargin/TopBarRow/HungerLabel
@onready var happiness_label: Label = $TopBar/TopBarMargin/TopBarRow/HappinessLabel
@onready var health_label: Label = $TopBar/TopBarMargin/TopBarRow/HealthLabel

@onready var home_button: Button = $BottomBar/BottomBarMargin/ActionsRow/HomeButton
@onready var map_button: Button = $BottomBar/BottomBarMargin/ActionsRow/WorkButton
@onready var jobs_button: Button = $BottomBar/BottomBarMargin/ActionsRow/JobsButton
@onready var hints_button: Button = $BottomBar/BottomBarMargin/ActionsRow/GymButton
@onready var inventory_button: Button = $BottomBar/BottomBarMargin/ActionsRow/InventoryButton
@onready var stats_button: Button = $BottomBar/BottomBarMargin/ActionsRow/StatsButton
@onready var logs_button: Button = $BottomBar/BottomBarMargin/ActionsRow/LogsButton
@onready var save_button: Button = $BottomBar/BottomBarMargin/ActionsRow/SaveButton
@onready var menu_button: Button = $BottomBar/BottomBarMargin/ActionsRow/MenuButton

@onready var message_panel: PanelContainer = $TopBar/TopBarMargin/TopBarRow/MessagePanel
@onready var message_label: Label = $TopBar/TopBarMargin/TopBarRow/MessagePanel/MessageMargin/MessageLabel

var goal_panel: PanelContainer = null
var goal_label: Label = null
var goal_skip_button: Button = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$TopBar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$BottomBar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$TopBar/TopBarMargin/TopBarRow/MessagePanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$TopBar/TopBarMargin/TopBarRow/MessagePanel/MessageMargin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_goal_panel()

	_make_non_button_children_ignore_mouse(self)
	for button in [
		home_button,
		map_button,
		jobs_button,
		hints_button,
		inventory_button,
		stats_button,
		logs_button,
		save_button,
		menu_button,
		goal_skip_button
	]:
		if button == null:
			continue
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
	home_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("home_pressed")
	)

	map_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("map_pressed")
	)

	jobs_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("jobs_pressed")
	)

	hints_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("hints_pressed")
	)

	inventory_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("inventory_pressed")
	)

	stats_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("stats_pressed")
	)

	logs_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("logs_pressed")
	)

	save_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("save_pressed")
	)

	menu_button.pressed.connect(func():
		AudioManager.play_ui_click()
		emit_signal("menu_pressed")
	)

	refresh()



func _setup_goal_panel() -> void:
	var top_row := get_node_or_null("TopBar/TopBarMargin/TopBarRow") as HBoxContainer
	if top_row == null or goal_panel != null:
		return

	goal_panel = PanelContainer.new()
	goal_panel.name = "GoalPanel"
	goal_panel.custom_minimum_size = Vector2(320, 46)
	goal_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal_panel.visible = false
	goal_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.24, 0.42, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 0.95, 0.55, 0.22)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	goal_panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.name = "GoalMargin"
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	goal_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.name = "GoalRow"
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	goal_label = Label.new()
	goal_label.name = "GoalLabel"
	goal_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal_label.text = "Goal: Start your life."
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	goal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_label.add_theme_font_override("font", load("res://assets/fonts/fonts.ttf"))
	goal_label.add_theme_font_size_override("font_size", 14)
	goal_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78, 1))
	row.add_child(goal_label)

	goal_skip_button = Button.new()
	goal_skip_button.name = "GoalSkipButton"
	goal_skip_button.custom_minimum_size = Vector2(70, 34)
	goal_skip_button.text = "Skip"
	goal_skip_button.add_theme_font_override("font", load("res://assets/fonts/fonts.ttf"))
	goal_skip_button.add_theme_font_size_override("font_size", 13)
	goal_skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	goal_skip_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	goal_skip_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("goal_skip_pressed")
	)
	row.add_child(goal_skip_button)

	top_row.add_child(goal_panel)

func set_goal_text(text: String, enabled: bool) -> void:
	if goal_panel == null or goal_label == null:
		return

	goal_panel.visible = enabled
	if message_panel != null:
		message_panel.custom_minimum_size = Vector2(260, 46) if enabled else Vector2(280, 46)
		message_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if not enabled:
		return

	var clean_text := text.strip_edges()
	if clean_text == "":
		clean_text = "Goal: Keep building your life."
	goal_label.text = clean_text

	if clean_text.length() <= 70:
		goal_label.add_theme_font_size_override("font_size", 14)
	else:
		goal_label.add_theme_font_size_override("font_size", 12)

func refresh() -> void:
	var data := GameState.get_top_bar_strings()
	day_label.text = data.day
	time_label.text = data.time
	money_label.text = data.money
	energy_label.text = data.energy
	hunger_label.text = data.hunger
	happiness_label.text = data.happiness
	health_label.text = data.health


func set_message(text: String) -> void:
	var clean_text := text.strip_edges()
	var max_chars := 76
	if clean_text.length() > max_chars:
		clean_text = clean_text.substr(0, max_chars - 3) + "..."
	message_label.text = clean_text

	if clean_text.length() <= 48:
		message_label.add_theme_font_size_override("font_size", 16)
	elif clean_text.length() <= 64:
		message_label.add_theme_font_size_override("font_size", 14)
	else:
		message_label.add_theme_font_size_override("font_size", 13)

func _make_non_button_children_ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control and not child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_non_button_children_ignore_mouse(child)
