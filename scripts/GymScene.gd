extends Control

signal gym_workout_pressed
signal gym_trainer_pressed
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var energy_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/EnergyLabel
@onready var food_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/FoodLabel
@onready var fitness_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/FitnessLabel
@onready var strength_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/StrengthLabel
@onready var endurance_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/EnduranceLabel
@onready var confidence_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/ConfidenceLabel
@onready var workout_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/WorkoutButton
@onready var trainer_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/TrainerButton
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	workout_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("gym_workout_pressed")
	)

	trainer_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("gym_trainer_pressed")
	)

	refresh()


func refresh() -> void:
	energy_label.text = "Energy: %d" % GameState.energy
	food_label.text = "Food: %d" % GameState.hunger
	fitness_label.text = "Fitness: %d" % GameState.fitness
	strength_label.text = "Strength: %d" % GameState.strength
	endurance_label.text = "Endurance: %d" % GameState.endurance
	confidence_label.text = "Confidence: %d" % GameState.confidence
	var need_energy := 18
	var can_workout := GameState.can_perform_action(need_energy)
	workout_button.disabled = not can_workout
	workout_button.text = "Workout" if can_workout else "Need Energy"

	var trainer_energy: int = GameState.GYM_TRAINER_ENERGY_COST
	var can_trainer_energy := GameState.can_perform_action(trainer_energy)
	var can_afford_trainer := GameState.money >= GameState.GYM_TRAINER_COST
	trainer_button.disabled = not (can_trainer_energy and can_afford_trainer)
	if can_trainer_energy and can_afford_trainer:
		trainer_button.text = "Workout with Trainer ($%d)" % GameState.GYM_TRAINER_COST
	elif not can_afford_trainer:
		trainer_button.text = "Need $%d for Trainer" % GameState.GYM_TRAINER_COST
	else:
		trainer_button.text = "Trainer Needs Energy"

	var normal_text := "Workout: %d min, Energy -%d, improves FIT/STR/END/CONF." % [GameState.GYM_WORKOUT_MINUTES, need_energy]
	var trainer_text := "Trainer: $%d, %d min, Energy -%d, gives +2 FIT/STR/END, +1 CONF/CHA, Happiness +8." % [GameState.GYM_TRAINER_COST, GameState.GYM_TRAINER_MINUTES, trainer_energy]
	if can_workout or (can_trainer_energy and can_afford_trainer):
		message_label.text = "%s\n%s" % [normal_text, trainer_text]
	elif not can_workout:
		message_label.text = "Not enough Energy to workout. You need at least %d Energy. Sleep or drink an Energy Drink first.\n%s" % [need_energy, trainer_text]
