extends Control

signal work_shift_pressed
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var wallet_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/WalletLabel
@onready var job_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/JobLabel
@onready var pay_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/PayLabel
@onready var exp_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/ExpLabel
@onready var energy_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/EnergyLabel
@onready var time_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/TimeLabel
@onready var work_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/WorkShiftButton
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	work_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("work_shift_pressed")
	)

	refresh()


func refresh() -> void:
	var current_job := GameState.get_primary_job_id()
	var current_exp := GameState.get_job_exp(current_job)
	var next_exp := GameState.get_job_exp_required_for_next_tier(current_job)
	wallet_label.text = "Wallet: $%d" % GameState.money
	job_label.text = "Current Job: %s" % GameState.get_primary_job_name()
	pay_label.text = "Pay: $%d / shift" % GameState.get_current_work_pay()
	exp_label.text = "EXP: %d / %d (+%d)" % [current_exp, next_exp, GameState.WORK_EXP_PER_SHIFT]
	energy_label.text = "Energy: %d" % GameState.energy
	time_label.text = "Shift Time: %d minutes" % GameState.WORK_SHIFT_MINUTES
	var need_energy := 20
	var can_work := GameState.can_perform_action(need_energy)
	work_button.disabled = not can_work
	work_button.text = "Work Shift" if can_work else "Need Energy"
	if can_work:
		message_label.text = "Normal work uses the Office display for all jobs. It gives money, job EXP, and exactly +1 random stat related to your current job."
	else:
		message_label.text = "Not enough Energy to work. You need at least %d Energy. Sleep or drink an Energy Drink first." % need_energy
