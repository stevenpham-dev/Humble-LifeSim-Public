
extends Control

signal close_requested

@onready var close_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleRow/CloseButton
@onready var filter_option_button: OptionButton = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ToolbarPanel/ToolbarMargin/ToolbarRow/FilterOptionButton
@onready var progress_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ToolbarPanel/ToolbarMargin/ToolbarRow/ProgressLabel
@onready var achievement_list: VBoxContainer = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ContentPanel/ContentMargin/AchievementScroll/AchievementList
@onready var footer_hint_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/FooterHintLabel

var _font: Font = preload("res://assets/fonts/fonts.ttf")

func _ready() -> void:
	close_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("close_requested")
	)

	filter_option_button.item_selected.connect(func(_index: int) -> void:
		AudioManager.play_ui_click()
		refresh()
	)

	refresh()


func refresh() -> void:
	var achievements := _get_achievements()
	var unlocked_count := 0
	for achievement in achievements:
		if bool(achievement.get("unlocked", false)):
			unlocked_count += 1

	progress_label.text = "Unlocked: %d / %d" % [unlocked_count, achievements.size()]
	footer_hint_label.text = "Achievements summarize your progress across work, school, health, travel, minigames, casino, and reincarnation milestones."

	for child in achievement_list.get_children():
		child.queue_free()

	var selected_filter := filter_option_button.selected
	for achievement in achievements:
		var unlocked := bool(achievement.get("unlocked", false))
		if selected_filter == 1 and not unlocked:
			continue
		if selected_filter == 2 and unlocked:
			continue
		achievement_list.add_child(_make_achievement_card(achievement))


func _get_achievements() -> Array[Dictionary]:
	var casino_data: Dictionary = {}
	if GameState.has_method("get_casino_data"):
		casino_data = GameState.get_casino_data()

	var owned_vehicle_count := 0
	if GameState.has_method("get_owned_vehicle_count"):
		owned_vehicle_count = GameState.get_owned_vehicle_count()

	var burger_best := 0
	if GameState.has_method("get_best_burger_streak"):
		burger_best = GameState.get_best_burger_streak()

	var credential_count := _get_credential_count()
	var total_money_seen := GameState.money
	if GameState.has_method("get_bank_balance"):
		total_money_seen += GameState.get_bank_balance()

	var past_lives := _get_past_lives()
	var past_lives_count := past_lives.size()
	var best_past_net_worth := _get_best_past_life_net_worth(past_lives)
	var best_reincarnation_rate := _get_best_reincarnation_rate(past_lives)
	var last_inherited_total := _get_last_inherited_total(past_lives)
	var used_custom_reincarnation := _used_reincarnation_mode(past_lives, "custom")
	var used_balanced_reincarnation := _used_reincarnation_mode(past_lives, "balanced")
	var latest_reincarnation_name := _get_latest_reincarnation_name(past_lives)
	var latest_name_suffix := ""
	if latest_reincarnation_name != "":
		latest_name_suffix = " | Current name: %s" % latest_reincarnation_name

	var learn_too_much_unlocked := bool(GameState.flags.get("achievement_learn_too_much", false))
	var learn_too_much_uses := int(GameState.flags.get("learn_too_much_total_uses", 0))
	var learn_too_much_track := str(GameState.flags.get("last_learn_too_much_track", ""))
	var learn_too_much_overflow := int(GameState.flags.get("last_learn_too_much_overflow", 0))
	var learn_too_much_detail := "???"
	if learn_too_much_unlocked:
		learn_too_much_detail = "Converted +%d extra progress on %s. Total uses: %d" % [learn_too_much_overflow, learn_too_much_track, learn_too_much_uses]

	return [
		{
			"title": "First Paycheck",
			"description": "Earn or save your first dollars.",
			"unlocked": total_money_seen > 0,
			"detail": "Current wallet/bank total: $%d" % total_money_seen
		},
		{
			"title": "Another Day",
			"description": "Reach Day 2 or later.",
			"unlocked": GameState.day >= 2,
			"detail": "Current day: %d" % GameState.day
		},
		{
			"title": "Student Progress",
			"description": "Build education through school actions.",
			"unlocked": GameState.education >= 10,
			"detail": "Education: %d" % GameState.education
		},
		{
			"title": "Learn Too Much!",
			"description": "Turn extra school progress into a hidden book-like bonus before an exam." if learn_too_much_unlocked else "???",
			"unlocked": learn_too_much_unlocked,
			"detail": learn_too_much_detail
		},
		{
			"title": "Certified",
			"description": "Earn at least one school credential.",
			"unlocked": credential_count > 0,
			"detail": "Credentials owned: %d" % credential_count
		},
		{
			"title": "Gym Routine",
			"description": "Improve fitness through workouts.",
			"unlocked": GameState.fitness >= 10 or GameState.strength >= 10 or GameState.endurance >= 10,
			"detail": "FIT %d | STR %d | END %d" % [GameState.fitness, GameState.strength, GameState.endurance]
		},
		{
			"title": "Car Owner",
			"description": "Own at least two vehicles.",
			"unlocked": owned_vehicle_count >= 2,
			"detail": "Owned vehicles: %d" % owned_vehicle_count
		},
		{
			"title": "Burger Builder",
			"description": "Complete at least one Burger Town order.",
			"unlocked": burger_best >= 1,
			"detail": "Best burger streak: %d" % burger_best
		},
		{
			"title": "Health Conscious",
			"description": "Keep Health high while managing food and stress.",
			"unlocked": GameState.health >= 90 and GameState.hunger >= 50,
			"detail": "Health %d | Food %d | Stress %d" % [GameState.health, GameState.hunger, GameState.stress]
		},
		{
			"title": "Casino Visitor",
			"description": "Play Blackjack or Slots at least once.",
			"unlocked": int(casino_data.get("blackjack_wins", 0)) + int(casino_data.get("blackjack_losses", 0)) + int(casino_data.get("blackjack_pushes", 0)) + int(casino_data.get("slots_spins", 0)) > 0,
			"detail": "Blackjack %dW/%dL/%dP | Slots %d" % [
				int(casino_data.get("blackjack_wins", 0)),
				int(casino_data.get("blackjack_losses", 0)),
				int(casino_data.get("blackjack_pushes", 0)),
				int(casino_data.get("slots_spins", 0))
			]
		},
		{
			"title": "Savings Account",
			"description": "Deposit money into the bank.",
			"unlocked": GameState.has_method("get_bank_balance") and GameState.get_bank_balance() > 0,
			"detail": "Bank balance: $%d" % (GameState.get_bank_balance() if GameState.has_method("get_bank_balance") else 0)
		},
		{
			"title": "Second Life",
			"description": "Reincarnate and begin a new life.",
			"unlocked": past_lives_count >= 1,
			"detail": "Past lives: %d%s" % [past_lives_count, latest_name_suffix]
		},
		{
			"title": "Inherited Spark",
			"description": "Carry at least one skill point into a new life.",
			"unlocked": last_inherited_total > 0,
			"detail": "Last inherited skill points: %d" % last_inherited_total
		},
		{
			"title": "Balanced Soul",
			"description": "Use balanced inheritance at least once.",
			"unlocked": used_balanced_reincarnation,
			"detail": "Balanced mode keeps every skill by the earned inheritance rate."
		},
		{
			"title": "Strategic Rebirth",
			"description": "Use custom allocation at least once.",
			"unlocked": used_custom_reincarnation,
			"detail": "Custom mode trades total inheritance for control over specific stats."
		},
		{
			"title": "Legacy Builder",
			"description": "End a life with at least $10,000 net worth.",
			"unlocked": best_past_net_worth >= 10000,
			"detail": "Best past-life net worth: $%d" % best_past_net_worth
		},
		{
			"title": "Powerful Legacy",
			"description": "Reach at least a 10% reincarnation inheritance rate.",
			"unlocked": best_reincarnation_rate >= 0.10,
			"detail": "Best past-life inheritance rate: %.2f%%" % (best_reincarnation_rate * 100.0)
		}
	]


func _get_past_lives() -> Array:
	if GameState.has_method("get_past_lives"):
		return GameState.get_past_lives()

	var lives = GameState.flags.get("past_lives", [])
	if typeof(lives) == TYPE_ARRAY:
		return lives
	return []


func _get_best_past_life_net_worth(past_lives: Array) -> int:
	var best := 0
	for life in past_lives:
		if life is Dictionary:
			var life_data: Dictionary = life
			best = maxi(best, int(life_data.get("net_worth", 0)))
	return best


func _get_best_reincarnation_rate(past_lives: Array) -> float:
	var best := 0.0
	for life in past_lives:
		if life is Dictionary:
			var life_data: Dictionary = life
			var mode := str(life_data.get("mode", "balanced"))
			var rate := float(life_data.get("balanced_rate", 0.05))
			if mode == "custom":
				rate = float(life_data.get("allocation_rate", 0.0))
			best = maxf(best, rate)
	return best


func _get_last_inherited_total(past_lives: Array) -> int:
	if past_lives.is_empty():
		return 0

	var last_life = past_lives[past_lives.size() - 1]
	if not (last_life is Dictionary):
		return 0

	var life_data: Dictionary = last_life
	var inherited = life_data.get("inherited_stats", {})
	if not (inherited is Dictionary):
		return 0

	var inherited_stats: Dictionary = inherited
	var total := 0
	for value in inherited_stats.values():
		total += int(value)
	return total


func _used_reincarnation_mode(past_lives: Array, target_mode: String) -> bool:
	for life in past_lives:
		if life is Dictionary:
			var life_data: Dictionary = life
			if str(life_data.get("mode", "balanced")) == target_mode:
				return true
	return false


func _get_latest_reincarnation_name(past_lives: Array) -> String:
	if past_lives.is_empty():
		return ""

	var last_life = past_lives[past_lives.size() - 1]
	if not (last_life is Dictionary):
		return ""

	var life_data: Dictionary = last_life
	return str(life_data.get("new_name", ""))

func _get_credential_count() -> int:
	var count := 0
	for item in GameState.inventory:
		var item_id := ""
		if item is Dictionary:
			item_id = str(item.get("id", item.get("item_id", "")))
		else:
			item_id = str(item)

		if item_id == "":
			continue

		var definition: Dictionary = {}
		if GameState.has_method("get_inventory_item_definition"):
			definition = GameState.get_inventory_item_definition(item_id)

		if str(definition.get("category", "")) == "credential":
			count += 1

	return count


func _make_achievement_card(achievement: Dictionary) -> PanelContainer:
	var unlocked := bool(achievement.get("unlocked", false))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(unlocked))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var title := Label.new()
	title.text = "%s %s" % ["✓" if unlocked else "○", str(achievement.get("title", "Achievement"))]
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.74, 1.0, 0.78, 1) if unlocked else Color(1.0, 0.95, 0.78, 1))
	column.add_child(title)

	var description := Label.new()
	description.text = str(achievement.get("description", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_override("font", _font)
	description.add_theme_font_size_override("font_size", 17)
	description.add_theme_color_override("font_color", Color(0.95, 0.96, 1.0, 1))
	column.add_child(description)

	var detail := Label.new()
	detail.text = str(achievement.get("detail", ""))
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_override("font", _font)
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Color(0.72, 1.0, 0.78, 1) if unlocked else Color(0.78, 0.82, 0.90, 1))
	column.add_child(detail)

	return panel


func _make_card_style(unlocked: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.36, 0.32, 0.95) if unlocked else Color(0.14, 0.18, 0.28, 0.94)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.74, 1.0, 0.78, 0.35) if unlocked else Color(1.0, 1.0, 1.0, 0.08)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style
