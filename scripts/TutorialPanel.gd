

extends Control

signal tutorial_closed(completed: bool)

@onready var close_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleRow/CloseButton
@onready var step_count_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/StepCountLabel
@onready var step_title_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ContentPanel/ContentMargin/StepColumn/StepTitleLabel
@onready var step_body_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ContentPanel/ContentMargin/StepColumn/StepBodyLabel
@onready var hint_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/HintLabel
@onready var dont_show_toggle: CheckButton = $CenterContainer/WindowPanel/WindowMargin/MainColumn/OptionRow/DontShowToggle
@onready var back_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/BackButton
@onready var next_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/NextButton
@onready var skip_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/SkipButton

const STEPS := [
	{
		"title": "Welcome to Humble LifeSim",
		"body": "Your goal is to manage a daily life loop: earn money, protect your Energy, Food, Happiness, and Health, improve stats, and unlock better jobs over time.",
		"hint": "Start at Home. The HUD at the top shows the most important numbers."
	},
	{
		"title": "HUD and daily meters",
		"body": "Day, time, cash, Energy, Food, Happiness, and Health are always visible. Time passing drains Food. If Food stays at 0, Health slowly drops over time.",
		"hint": "Food is your fullness meter. Keep it above 0 when possible."
	},
	{
		"title": "Max meters and aging",
		"body": "Your maximum Health, Energy, and Food can rise above 100. For every 10 points in your lowest skill, all three max meters increase by 1. Every 100 days also adds another 1 Health lost at the start of each new day.",
		"hint": "Balanced growth matters. If one skill stays low, your max meters barely grow."
	},
	{
		"title": "Home actions",
		"body": "Home is your main hub. Sleep restores Energy and starts the next day. Work and Gym travel to their display scenes first. Study sends you to School for credentials.",
		"hint": "The Home cards and HUD buttons share the same core systems."
	},
	{
		"title": "Map and vehicles",
		"body": "Use the Car or Map to choose a destination. Opening the Map itself is free. Your equipped vehicle controls travel time and travel cost only when you choose a destination.",
		"hint": "Going back to the location you just came from does not waste travel time."
	},
	{
		"title": "Store and Inventory",
		"body": "Buy food and books at the Store. Inventory stores food, books, vehicles, and credentials. Eating from Inventory takes time, restores Food, and may affect Health.",
		"hint": "Healthy foods improve Health. Unhealthy foods fill you but can lower Health."
	},
	{
		"title": "School and Jobs",
		"body": "School lets you choose credential tracks, learn facts, read books, and pass exams. Learn is free but slower. Books cost money but give stronger progress.",
		"hint": "Better jobs usually require both stats and credentials."
	},
	{
		"title": "Money systems",
		"body": "Work at the Office for normal job pay and EXP, use Burger Town for the burger minigame, deposit savings at the Bank, and visit the Casino for optional risk/reward gameplay.",
		"hint": "The Bank earns small daily interest when you sleep."
	},
	{
		"title": "Tracking progress",
		"body": "Use Stats to review your build, Logs to see what happened, Achievements to track milestones, and Save to preserve progress.",
		"hint": "You can turn new-game tutorials on or off in Settings, and reopen Hints from the HUD anytime."
	},
	{
		"title": "Death is not the End!",
		"body": "If Health reaches 0, your life ends and Reincarnation begins. A new life starts from Day 0, but strong past lives can pass on partial skill inheritance based on net worth, days lived, and your chosen inheritance mode.",
		"hint": "Reincarnation turns late-game progress into a replay loop instead of a hard game over."
	}
]

var _step_index: int = 0

func _ready() -> void:
	close_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_finish_tutorial()
	)

	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_step_index = maxi(0, _step_index - 1)
		_refresh_step()
	)

	next_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		if _step_index >= STEPS.size() - 1:
			_finish_tutorial()
		else:
			_step_index += 1
			_refresh_step()
	)

	skip_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_finish_tutorial()
	)

	dont_show_toggle.toggled.connect(func(pressed: bool) -> void:
		_sync_tutorial_setting_from_toggle(pressed)
	)

	visible = false
	_refresh_step()


func open_tutorial() -> void:
	_step_index = 0
	_sync_toggle_from_saved_setting()
	visible = true
	_refresh_step()


func _refresh_step() -> void:
	var step: Dictionary = STEPS[_step_index]
	step_count_label.text = "Step %d / %d" % [_step_index + 1, STEPS.size()]
	step_title_label.text = str(step.get("title", "Tutorial"))
	step_body_label.text = str(step.get("body", ""))
	hint_label.text = str(step.get("hint", ""))
	back_button.disabled = _step_index <= 0
	next_button.text = "Finish" if _step_index >= STEPS.size() - 1 else "Next"


func _finish_tutorial() -> void:
	GameState.flags["tutorial_completed"] = true
	_sync_tutorial_setting_from_toggle(dont_show_toggle.button_pressed)

	visible = false
	emit_signal("tutorial_closed", true)


func _sync_toggle_from_saved_setting() -> void:
	if SettingsData == null or dont_show_toggle == null:
		return
	dont_show_toggle.set_pressed_no_signal(not SettingsData.show_tutorial_on_new_game)


func _sync_tutorial_setting_from_toggle(pressed: bool) -> void:
	if SettingsData == null:
		return
	SettingsData.show_tutorial_on_new_game = not pressed
	SettingsData.save_settings()
