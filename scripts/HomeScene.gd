extends Control

signal sleep_selected
signal workout_selected
signal work_selected
signal study_selected
signal phone_selected
signal car_selected

@onready var description_label: Label = $Content/Layout/HeaderPanel/HeaderMargin/HeaderColumn/DescriptionLabel

@onready var sleep_button: Button = $Content/Layout/ActionGrid/SleepButton
@onready var workout_button: Button = $Content/Layout/ActionGrid/WorkoutButton
@onready var study_button: Button = $Content/Layout/ActionGrid/StudyButton
@onready var phone_button: Button = $Content/Layout/ActionGrid/PhoneButton
@onready var car_button: Button = $Content/Layout/ActionGrid/CarButton
@onready var work_at_job_button: Button = $Content/Layout/ActionGrid/WorkAtJobButton

func _ready() -> void:
	_prepare_card_button(sleep_button)
	_prepare_card_button(workout_button)
	_prepare_card_button(study_button)
	_prepare_card_button(phone_button)
	_prepare_card_button(car_button)
	_prepare_card_button(work_at_job_button)

	sleep_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("sleep_selected")
	)

	workout_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("workout_selected")
	)

	study_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("study_selected")
	)

	phone_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("phone_selected")
	)

	car_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("car_selected")
	)

	work_at_job_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("work_selected")
	)

	sleep_button.mouse_entered.connect(func() -> void:
		description_label.text = "Sleep to restore energy, move to the next day, and reset your daily application limits."
	)

	workout_button.mouse_entered.connect(func() -> void:
		description_label.text = "Workout to improve endurance, fitness, and your long-term physical growth."
	)

	study_button.mouse_entered.connect(func() -> void:
		description_label.text = "Go to school to learn facts, read books, take exams, and earn job credentials."
	)

	phone_button.mouse_entered.connect(func() -> void:
		description_label.text = "Use your phone to build employer relationships, ask for advice, and improve job opportunities."
	)

	car_button.mouse_entered.connect(func() -> void:
		description_label.text = "Use your car to open travel options and move between important locations."
	)

	work_at_job_button.mouse_entered.connect(func() -> void:
		description_label.text = "Work your current job from home to earn money, gain EXP, and build discipline."
	)

	var reset_description := func() -> void:
		description_label.text = "Your home is where you recover, improve yourself, and decide how to spend the day."

	sleep_button.mouse_exited.connect(reset_description)
	workout_button.mouse_exited.connect(reset_description)
	study_button.mouse_exited.connect(reset_description)
	phone_button.mouse_exited.connect(reset_description)
	car_button.mouse_exited.connect(reset_description)
	work_at_job_button.mouse_exited.connect(reset_description)

func _prepare_card_button(button: Button) -> void:
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_make_children_ignore_mouse(button)


func _make_children_ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_children_ignore_mouse(child)
