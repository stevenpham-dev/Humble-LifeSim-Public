
extends Control

@warning_ignore("unused_signal")
signal go_home
@warning_ignore("unused_signal")
signal go_office
@warning_ignore("unused_signal")
signal go_gym
@warning_ignore("unused_signal")
signal go_fast_food
@warning_ignore("unused_signal")
signal go_store
@warning_ignore("unused_signal")
signal go_bank
@warning_ignore("unused_signal")
signal go_school
@warning_ignore("unused_signal")
signal go_car_shop
@warning_ignore("unused_signal")
signal go_clinic
@warning_ignore("unused_signal")
signal go_casino

@onready var description_label: Label = $Content/Layout/HeaderPanel/HeaderMargin/HeaderColumn/DescriptionLabel

@onready var home_button: Button = $Content/Layout/ActionGrid/HomeButton
@onready var office_button: Button = $Content/Layout/ActionGrid/WorkButton
@onready var gym_button: Button = $Content/Layout/ActionGrid/GymButton
@onready var fastfood_button: Button = $Content/Layout/ActionGrid/FastFoodButton
@onready var store_button: Button = $Content/Layout/ActionGrid/StoreButton
@onready var bank_button: Button = $Content/Layout/ActionGrid/BankButton
@onready var school_button: Button = $Content/Layout/ActionGrid/SchoolButton
@onready var carshop_button: Button = $Content/Layout/ActionGrid/CarShopButton
@onready var clinic_button: Button = $Content/Layout/ActionGrid/ClinicButton
@onready var casino_button: Button = $Content/Layout/ActionGrid/CasinoButton

var _travel_click_locked: bool = false

func _ready() -> void:
	_prepare_card_button(home_button)
	_prepare_card_button(office_button)
	_prepare_card_button(gym_button)
	_prepare_card_button(fastfood_button)
	_prepare_card_button(store_button)
	_prepare_card_button(bank_button)
	_prepare_card_button(school_button)
	_prepare_card_button(carshop_button)
	_prepare_card_button(clinic_button)
	_prepare_card_button(casino_button)
	_connect(home_button, "go_home")
	_connect(office_button, "go_office")
	_connect(gym_button, "go_gym")
	_connect(fastfood_button, "go_fast_food")
	_connect(store_button, "go_store")
	_connect(bank_button, "go_bank")
	_connect(school_button, "go_school")
	_connect(carshop_button, "go_car_shop")
	_connect(clinic_button, "go_clinic")
	_connect(casino_button, "go_casino")

func _connect(button: Button, signal_name: String) -> void:
	button.pressed.connect(func():
		if _travel_click_locked:
			return
		_travel_click_locked = true
		AudioManager.play_ui_click()
		emit_signal(signal_name)
		await get_tree().create_timer(0.15).timeout
		if is_inside_tree():
			_travel_click_locked = false
	)

	button.mouse_entered.connect(func():
		description_label.text = _get_destination_description(signal_name)
	)

	button.mouse_exited.connect(func():
		description_label.text = "Choose a destination."
	)

func _prepare_card_button(button: Button) -> void:
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_make_children_ignore_mouse(button)


func _make_children_ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_children_ignore_mouse(child)

func _get_destination_description(signal_name: String) -> String:
	match signal_name:
		"go_home":
			return "Return home to rest, study, and manage your day."
		"go_office":
			return "Travel to the Office for your normal job shift and promotion EXP."
		"go_gym":
			return "Travel to the Gym for workouts that improve fitness, strength, endurance, and confidence."
		"go_fast_food":
			return "Go to Burger Town for the burger minigame and entry-level work."
		"go_store":
			return "Visit the Super Market for food, books, and supplies."
		"go_bank":
			return "Go to the bank to manage savings and daily interest."
		"go_school":
			return "Visit school to build education and earn credentials."
		"go_car_shop":
			return "Browse cars, buy vehicles, and equip your current ride."
		"go_clinic":
			return "Visit the clinic to recover Health and manage wellness."
		"go_casino":
			return "Visit the casino to play blackjack or slots with cash bets."
		_:
			return "Choose a destination."
