extends Control

signal clinic_action_completed(result: Dictionary)
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var health_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/HealthLabel
@onready var food_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/FoodLabel
@onready var stress_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/StressLabel
@onready var wallet_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/WalletLabel
@onready var status_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/StatusLabel
@onready var starvation_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/StarvationLabel
@onready var checkup_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/ButtonRow/CheckupButton
@onready var treatment_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/ButtonRow/TreatmentButton
@onready var advice_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/ButtonRow/AdviceButton
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	checkup_button.pressed.connect(func() -> void:
		_handle_result(GameState.do_clinic_checkup())
	)

	treatment_button.pressed.connect(func() -> void:
		_handle_result(GameState.do_clinic_treatment())
	)

	advice_button.pressed.connect(func() -> void:
		_handle_result(GameState.do_clinic_rest_advice())
	)

	message_label.text = "Clinic actions can restore Health or reduce Stress. If Food or Happiness stay at 0, Health drops over time during actions."
	refresh()


func refresh() -> void:
	health_label.text = "Health: %d / %d" % [GameState.health, GameState.get_max_health()]
	food_label.text = "Food: %d / %d" % [GameState.hunger, GameState.get_max_fullness()]
	stress_label.text = "Stress: %d / 100" % GameState.stress
	wallet_label.text = "Wallet: $%d" % GameState.money
	status_label.text = "Status: %s | %s" % [GameState.get_health_status_text(), GameState.get_meter_scaling_summary()]
	var low_mood_minutes := 0
	if GameState.has_method("get_pending_zero_happiness_minutes"):
		low_mood_minutes = GameState.get_pending_zero_happiness_minutes()
	starvation_label.text = "Starving Timer: %d / 60 min | Low Mood Timer: %d / 60 min" % [GameState.get_pending_starvation_minutes(), low_mood_minutes]

	checkup_button.text = "Checkup ($%d)" % GameState.CLINIC_CHECKUP_COST
	treatment_button.text = "Treatment ($%d)" % GameState.CLINIC_TREATMENT_COST
	advice_button.text = "Rest Advice (Free)"

	treatment_button.disabled = GameState.money < GameState.CLINIC_TREATMENT_COST
	checkup_button.disabled = GameState.money < GameState.CLINIC_CHECKUP_COST


func _handle_result(result: Dictionary) -> void:
	if bool(result.get("success", false)):
		AudioManager.play_clinic()
	else:
		AudioManager.play_ui_click()

	message_label.text = str(result.get("message", "Clinic updated."))
	refresh()
	emit_signal("clinic_action_completed", result)