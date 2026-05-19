extends Control

signal start_burger_shift
signal quick_work_pressed
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var wallet_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/WalletLabel
@onready var job_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/JobLabel
@onready var streak_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/StreakLabel
@onready var start_burger_button: Button = $Content/Layout/ActionGrid/StartBurgerCard/StartBurgerMargin/StartBurgerColumn/StartBurgerButton
@onready var quick_work_button: Button = $Content/Layout/ActionGrid/QuickWorkCard/QuickWorkMargin/QuickWorkColumn/QuickWorkButton

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	start_burger_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("start_burger_shift")
	)

	quick_work_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("quick_work_pressed")
	)

	refresh()


func refresh() -> void:
	wallet_label.text = "Wallet: $%d" % GameState.money
	job_label.text = "Current Job: %s" % GameState.get_primary_job_name()
	streak_label.text = "Burger Streak: %d | Best: %d" % [GameState.get_burger_streak(), GameState.get_best_burger_streak()]
