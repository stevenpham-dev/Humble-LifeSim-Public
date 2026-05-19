extends Control

signal back_pressed
signal open_phone_requested(job_id: String)

const MAIN_GAME_SCENE_PATH := "res://scenes/GameRoot.tscn"

@onready var category_option: OptionButton = $Content/Layout/FilterPanel/FilterMargin/FilterRow/CategoryOptionButton
@onready var refresh_button: Button = $Content/Layout/FilterPanel/FilterMargin/FilterRow/RefreshButton
@onready var job_list: VBoxContainer = $Content/Layout/JobListPanel/JobListMargin/JobScroll/JobList
@onready var description_label: Label = $Content/Layout/DescriptionLabel
@onready var back_button: Button = $Content/Layout/TopBar/TopBarMargin/TopBarRow/BackButton

var _font: Font = preload("res://assets/fonts/fonts.ttf")

func _ready() -> void:
	category_option.clear()
	category_option.add_item("All", 0)
	category_option.add_item("Physical", 1)
	category_option.add_item("Social", 2)
	category_option.add_item("Technical", 3)
	category_option.select(0)

	back_button.pressed.connect(_on_back_pressed)

	if refresh_button != null:
		refresh_button.text = "Back"
		refresh_button.pressed.connect(_on_back_pressed)

	category_option.item_selected.connect(func(_i: int) -> void:
		AudioManager.play_ui_click()
		_refresh_job_list()
	)

	_refresh_job_list()


func _on_back_pressed() -> void:
	AudioManager.play_ui_click()
	emit_signal("back_pressed")


func _refresh_job_list() -> void:
	for child in job_list.get_children():
		child.queue_free()

	var selected_category: int = category_option.get_selected_id()
	var current_job: String = GameState.get_primary_job_id()

	for job_id in GameState.get_job_order():
		if not _job_matches_filter(job_id, selected_category):
			continue

		job_list.add_child(_build_job_card(str(job_id), current_job))


func _job_matches_filter(job_id: String, filter_id: int) -> bool:
	if filter_id == 0:
		return true

	var category: String = GameState.get_job_category(job_id)

	if filter_id == 1:
		return category == "physical"
	elif filter_id == 2:
		return category == "social"
	elif filter_id == 3:
		return category == "technical"

	return true


func _build_job_card(job_id: String, current_job: String) -> Control:
	var definition: Dictionary = GameState.get_job_definition(job_id)

	var unlocked: bool = GameState.jobs.has(job_id)
	var is_current: bool = job_id == current_job
	var tier: int = GameState.get_job_tier(job_id) if unlocked else 1

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(job_id, is_current))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	margin.add_child(col)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	col.add_child(title_row)

	var name_label := Label.new()
	name_label.text = "%s %d" % [str(definition.get("name", "Job")), tier]
	name_label.add_theme_font_override("font", _font)
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(1, 0.97, 0.78, 1))
	title_row.add_child(name_label)

	var status_label := Label.new()
	status_label.add_theme_font_override("font", _font)
	status_label.add_theme_font_size_override("font_size", 16)

	if is_current:
		status_label.text = "Current Job"
		status_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.65, 1))
	elif unlocked:
		status_label.text = "Unlocked"
		status_label.add_theme_color_override("font_color", Color(0.70, 0.95, 1.0, 1))
	elif GameState.has_applied_to_job_today(job_id):
		status_label.text = "Applied Today"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.45, 1))
	else:
		status_label.text = "Open"
		status_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.90))

	title_row.add_child(status_label)

	var details := Label.new()
	details.text = _build_job_details_text(job_id, tier, unlocked)
	details.add_theme_font_override("font", _font)
	details.add_theme_font_size_override("font_size", 17)
	details.add_theme_color_override("font_color", Color(0.96, 0.96, 1, 1))
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(details)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 10)
	col.add_child(button_row)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(190, 42)
	btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 17)

	if is_current:
		btn.text = "Current Job"
		btn.disabled = true

	elif unlocked:
		btn.text = "Switch Job"
		btn.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			var result: Dictionary = GameState.switch_to_job(job_id)
			if bool(result.get("success", false)):
				description_label.text = "Switched to %s." % GameState.get_job_display_name(job_id)
			else:
				description_label.text = str(result.get("reason", "Could not switch jobs."))
			_refresh_job_list()
		)

	else:
		if GameState.has_applied_to_job_today(job_id):
			btn.text = "Daily Limit Reached"
			btn.disabled = true
		else:
			btn.text = "Apply"
			btn.pressed.connect(func() -> void:
				AudioManager.play_ui_click()
				var result: Dictionary = GameState.apply_to_job(job_id)

				if bool(result.get("accepted", false)):
					description_label.text = "Accepted! Current job: %s" % GameState.get_primary_job_name()
				else:
					description_label.text = str(result.get("reason", "Rejected."))

				_refresh_job_list()
			)

	button_row.add_child(btn)

	var contact_button := Button.new()
	contact_button.custom_minimum_size = Vector2(210, 42)
	contact_button.add_theme_font_override("font", _font)
	contact_button.add_theme_font_size_override("font_size", 17)

	var contact_known: bool = GameState.has_job_employer_contact(job_id)
	var contact_check: Dictionary = GameState.can_contact_job_employer(job_id)
	var can_request_contact: bool = bool(contact_check.get("success", false))

	if is_current:
		contact_button.text = "Contact Boss"
	elif contact_known:
		contact_button.text = "Contact Employer"
	elif can_request_contact:
		contact_button.text = "Add Employer Contact"
	else:
		contact_button.text = "Need 75% Stats"
		contact_button.disabled = true

	contact_button.pressed.connect(func() -> void:
		AudioManager.play_phone()

		if is_current or GameState.has_job_employer_contact(job_id):
			var contact_result: Dictionary = GameState.discover_job_employer_contact(job_id, true)
			description_label.text = "Opening Phone: %s." % str(contact_result.get("contact_name", "Employer"))
			emit_signal("open_phone_requested", job_id)
			return

		var unlock_contact_result: Dictionary = GameState.request_job_employer_contact(job_id)
		description_label.text = str(unlock_contact_result.get("message", unlock_contact_result.get("reason", "Contact unavailable.")))

		if bool(unlock_contact_result.get("success", false)):
			emit_signal("open_phone_requested", job_id)
			return

		_refresh_job_list()
	)
	button_row.add_child(contact_button)

	if not unlocked and GameState.has_applied_to_job_today(job_id):
		var daily_label := Label.new()
		daily_label.text = "Try Again Tomorrow!"
		daily_label.add_theme_font_override("font", _font)
		daily_label.add_theme_font_size_override("font_size", 15)
		daily_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.55, 1))
		col.add_child(daily_label)

	return panel


func _build_job_details_text(job_id: String, tier: int, unlocked: bool) -> String:
	var definition: Dictionary = GameState.get_job_definition(job_id)
	var next_exp: int = GameState.get_job_exp_required_for_next_tier(job_id, tier)
	var pay: int = GameState.get_job_pay(job_id, tier)
	var credential: String = str(definition.get("required_credential", ""))
	var required_stats: Dictionary = definition.get("required_stats", {})

	var lines: Array[String] = []
	lines.append("Pay: $%d per shift" % pay)
	lines.append("Next Promotion: %d EXP" % next_exp)
	lines.append("Employer: %s" % GameState.get_job_networking_summary(job_id))
	lines.append("Contact Access: %d%% / 75%% required" % GameState.get_job_required_stat_completion_percent(job_id))

	if credential == "":
		lines.append("Credential: None")
	else:
		var owned_text := "Owned" if GameState.has_credential(credential) else "Missing - earn at School"
		lines.append("Credential: %s (%s)" % [credential, owned_text])

	if required_stats.is_empty():
		lines.append("Requirements: None")
	else:
		var parts: Array[String] = []
		for stat_name in required_stats.keys():
			var needed: int = int(required_stats[stat_name])
			var current_value: int = int(GameState.get(stat_name))
			parts.append("%s %d/%d" % [String(stat_name).capitalize(), current_value, needed])
		lines.append("Requirements: %s" % ", ".join(parts))

	if unlocked:
		lines.append("Current EXP: %d / %d" % [GameState.get_job_exp(job_id), next_exp])
	else:
		var check: Dictionary = GameState.can_unlock_job(job_id)
		if bool(check.get("success", false)):
			lines.append("Application Chance: %d%%" % GameState.get_job_application_chance(job_id))
		else:
			lines.append("Missing: %s" % str(check.get("reason", "Requirements not met.")))
			lines.append("Tip: Use School for credentials and Stats for progress.")

	return "\n".join(lines)


func _estimate_application_chance(job_id: String) -> int:
	return GameState.get_job_application_chance(job_id)


func _make_card_style(job_id: String, is_current: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	match GameState.get_job_category(job_id):
		"physical":
			style.bg_color = Color(0.24, 0.46, 0.76, 0.96)
			style.border_color = Color(0.72, 0.90, 1.0, 0.48)
		"social":
			style.bg_color = Color(0.70, 0.36, 0.66, 0.96)
			style.border_color = Color(1.0, 0.78, 0.96, 0.48)
		"technical":
			style.bg_color = Color(0.32, 0.62, 0.48, 0.96)
			style.border_color = Color(0.76, 1.0, 0.82, 0.48)
		_:
			style.bg_color = Color(0.24, 0.36, 0.52, 0.96)
			style.border_color = Color(1, 1, 1, 0.20)

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	if is_current:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = Color(1.0, 0.92, 0.42, 0.90)

	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16

	return style
