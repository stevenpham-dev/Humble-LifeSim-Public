
extends Panel

signal reincarnation_requested

const FONT_PATH := "res://assets/fonts/fonts.ttf"

var show_core: bool = true
var show_life: bool = true
var show_general: bool = true

@onready var title_label: Label = $Margin/Layout/Title
@onready var core_button: Button = $Margin/Layout/FilterRow/CoreButton
@onready var life_button: Button = $Margin/Layout/FilterRow/LifeButton
@onready var general_button: Button = $Margin/Layout/FilterRow/GeneralButton
@onready var stats_grid: GridContainer = $Margin/Layout/Scroll/StatsGrid
@onready var close_button: Button = $Margin/Layout/BottomRow/CloseButton

var filter_style_on: StyleBox
var filter_style_off: StyleBox
var stat_font: FontFile
var reincarnate_button: Button = null

func _ready() -> void:
	_ensure_reincarnate_button()
	filter_style_on = core_button.get_theme_stylebox("normal")
	var off_box := StyleBoxFlat.new()
	off_box.bg_color = Color(0.22, 0.32, 0.46, 0.95)
	off_box.border_color = Color(1, 1, 1, 0.16)
	off_box.border_width_left = 1
	off_box.border_width_top = 1
	off_box.border_width_right = 1
	off_box.border_width_bottom = 1
	off_box.corner_radius_top_left = 10
	off_box.corner_radius_top_right = 10
	off_box.corner_radius_bottom_left = 10
	off_box.corner_radius_bottom_right = 10
	off_box.content_margin_left = 16
	off_box.content_margin_top = 8
	off_box.content_margin_right = 16
	off_box.content_margin_bottom = 8
	filter_style_off = off_box
	stat_font = load(FONT_PATH)
	core_button.text = "Core"
	life_button.text = "Life"
	general_button.text = "Skills"
	core_button.pressed.connect(_on_core_pressed)
	life_button.pressed.connect(_on_life_pressed)
	general_button.pressed.connect(_on_general_pressed)
	close_button.pressed.connect(_on_close_pressed)
	_update_filter_button_styles()
	refresh()

func open_panel() -> void:
	refresh()
	visible = true

func close_panel() -> void:
	visible = false

func toggle_panel() -> void:
	if visible:
		close_panel()
	else:
		open_panel()

func refresh() -> void:
	title_label.text = "PLAYER STATS"
	_rebuild_stats_grid()
	_update_filter_button_styles()

func _on_core_pressed() -> void:
	AudioManager.play_ui_click()
	show_core = not show_core
	refresh()

func _on_life_pressed() -> void:
	AudioManager.play_ui_click()
	show_life = not show_life
	refresh()

func _on_general_pressed() -> void:
	AudioManager.play_ui_click()
	show_general = not show_general
	refresh()

func _on_close_pressed() -> void:
	AudioManager.play_ui_click()
	close_panel()

func _update_filter_button_styles() -> void:
	core_button.add_theme_stylebox_override("normal", filter_style_on if show_core else filter_style_off)
	life_button.add_theme_stylebox_override("normal", filter_style_on if show_life else filter_style_off)
	general_button.add_theme_stylebox_override("normal", filter_style_on if show_general else filter_style_off)

func _rebuild_stats_grid() -> void:
	for child in stats_grid.get_children():
		child.queue_free()

	var stats: Array[String] = []
	if show_core:
		stats.append_array(_get_core_stats())
	if show_life:
		stats.append_array(_get_life_stats())
	if show_general:
		stats.append_array(_get_skill_stats())

	if stats.is_empty():
		stats.append("No categories selected.")

	for stat_text in stats:
		var label := Label.new()
		label.text = stat_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(240, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		if stat_font != null:
			label.add_theme_font_override("font", stat_font)

		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

		if stat_text.begins_with("--"):
			label.add_theme_font_size_override("font_size", 19)
			label.add_theme_color_override("font_color", Color(1, 0.95, 0.78, 1))

		if stat_text.begins_with("Credentials") or stat_text.begins_with("School Progress") or stat_text.begins_with("Jobs"):
			label.add_theme_font_size_override("font_size", 16)

		if stat_text == "No categories selected.":
			label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))

		stats_grid.add_child(label)

func _get_core_stats() -> Array[String]:
	return [
		"-- Core --",
		"Name: %s" % GameState.get_player_name(),
		"Day: %d" % GameState.day,
		"Time: %s (%s)" % [GameState.get_time_text_12h(), GameState.time_of_day.capitalize()],
		"Wallet: $%d" % GameState.money,
		"Bank: $%d" % GameState.get_bank_balance(),
		"Net Worth: $%d" % GameState.get_net_worth(),
		"Energy: %d / %d" % [GameState.energy, GameState.get_max_energy()],
		"Food: %d / %d" % [GameState.hunger, GameState.get_max_fullness()],
		"Health: %d / %d" % [GameState.health, GameState.get_max_health()],
		"Meter Scaling: %s" % GameState.get_meter_scaling_summary(),
		"Daily Aging Loss: Health -%d/day" % GameState.get_daily_aging_health_loss_for_day(),
		"Happiness: %d" % GameState.happiness,
		"Stress: %d" % GameState.stress
	]


func _get_life_stats() -> Array[String]:
	return [
		"-- Life --",
		"Location: %s" % GameState.current_location.capitalize(),
		"House: %s" % GameState.current_house_id,
		"Car: %s" % _get_current_car_text(),
		"Owned Vehicles: %d" % GameState.get_owned_vehicle_count(),
		"Car Bonus: %s" % GameState.get_current_car_bonus_text(),
		_build_current_job_text(),
		_build_current_boss_text(),
		_build_networking_text(),
		_build_jobs_text(),
		_build_credentials_text(),
		_build_school_progress_text(),
		"Inventory Item Types: %d" % GameState.inventory.size(),
		"Relationships: %d" % GameState.relationships.size(),
		"Activity Logs: %d" % GameState.activity_logs.size(),
		"Reincarnation: %s" % GameState.get_reincarnation_status_text()
	]

func _get_skill_stats() -> Array[String]:
	return [
		"-- Skills --",
		"Fitness: %d" % GameState.fitness,
		"Strength: %d" % GameState.strength,
		"Endurance: %d" % GameState.endurance,
		"Education: %d" % GameState.education,
		"Intelligence: %d" % GameState.intelligence,
		"Discipline: %d" % GameState.discipline,
		"Confidence: %d" % GameState.confidence,
		"Charisma: %d" % GameState.charisma,
		"Total Skill Points: %d" % _get_total_skill_points()
	]

func _get_current_car_text() -> String:
	if GameState.current_car_id == "none":
		return "None"

	var definition: Dictionary = GameState.get_inventory_item_definition(GameState.current_car_id)
	return str(definition.get("name", GameState.current_car_id))

func _build_current_job_text() -> String:
	var job_id: String = GameState.get_primary_job_id()
	var job_name: String = GameState.get_primary_job_name()
	var tier: int = GameState.get_job_tier(job_id)
	var exp_value: int = GameState.get_job_exp(job_id)
	var next_exp: int = GameState.get_job_exp_required_for_next_tier(job_id)
	var pay: int = GameState.get_current_work_pay()

	return "Current Job: %s %d | $%d/shift | EXP %d/%d" % [job_name, tier, pay, exp_value, next_exp]


func _build_current_boss_text() -> String:
	if GameState.has_method("get_current_boss_relationship_summary"):
		return "Boss Relationship: %s" % GameState.get_current_boss_relationship_summary()
	return "Boss Relationship: None"


func _build_networking_text() -> String:
	if not GameState.has_method("get_phone_contacts"):
		return "Networking Contacts: 0"
	var contacts: Array = GameState.get_phone_contacts()
	var best_name := "None"
	var best_value := 0
	for contact in contacts:
		var contact_id := str(contact.get("contact_id", ""))
		var value := GameState.get_relationship(contact_id) if GameState.has_method("get_relationship") else 0
		if value > best_value:
			best_value = value
			best_name = str(contact.get("name", "Contact"))
	return "Networking Contacts: %d | Best: %s %d/100" % [contacts.size(), best_name, best_value]

func _build_jobs_text() -> String:
	var count := GameState.jobs.size()

	if count <= 0:
		return "Jobs (0): None"

	var names: Array[String] = []
	for job_id in GameState.jobs:
		names.append(GameState.get_job_display_name(str(job_id)))

	return "Jobs (%d): %s" % [count, ", ".join(names)]

func _build_credentials_text() -> String:
	var credentials: Array = GameState.flags.get("credentials", [])
	if credentials.is_empty():
		return "Credentials: None"

	var values: Array[String] = []
	for credential in credentials:
		values.append(str(credential))

	return "Credentials (%d): %s" % [values.size(), ", ".join(values)]

func _build_school_progress_text() -> String:
	var progress_data: Dictionary = GameState.flags.get("school_progress", {})
	if progress_data.is_empty():
		return "School Progress: None"

	var parts: Array[String] = []
	for track in progress_data.keys():
		var entry: Dictionary = progress_data.get(track, {})
		parts.append("%s %d" % [str(track), int(entry.get("progress", 0))])

	return "School Progress: %s" % "; ".join(parts)

func _get_total_skill_points() -> int:
	return GameState.fitness + GameState.strength + GameState.endurance + GameState.education + GameState.intelligence + GameState.discipline + GameState.confidence + GameState.charisma


func _ensure_reincarnate_button() -> void:
	if reincarnate_button != null:
		return

	var bottom_row := close_button.get_parent()
	if bottom_row == null:
		return

	reincarnate_button = Button.new()
	reincarnate_button.name = "ReincarnateButton"
	reincarnate_button.text = "Reincarnate"
	reincarnate_button.custom_minimum_size = Vector2(180, 46)
	reincarnate_button.add_theme_font_override("font", load(FONT_PATH))
	reincarnate_button.add_theme_font_size_override("font_size", 18)
	reincarnate_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	reincarnate_button.add_theme_stylebox_override("normal", _make_reincarnate_button_style(false))
	reincarnate_button.add_theme_stylebox_override("hover", _make_reincarnate_button_style(true))
	reincarnate_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("reincarnation_requested")
	)

	bottom_row.add_child(reincarnate_button)
	bottom_row.move_child(reincarnate_button, 0)


func _make_reincarnate_button_style(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.42, 0.34, 0.78, 0.98) if hover else Color(0.30, 0.26, 0.62, 0.96)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 18
	style.content_margin_top = 10
	style.content_margin_right = 18
	style.content_margin_bottom = 10
	return style
