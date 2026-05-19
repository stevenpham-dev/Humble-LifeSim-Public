extends Control

signal warning_closed

@onready var close_button: Button = $CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/CloseButton
@onready var title_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleLabel
@onready var body_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/BodyLabel
@onready var detail_label: Label = $CenterContainer/WindowPanel/WindowMargin/MainColumn/DetailPanel/DetailMargin/DetailLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	close_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		visible = false
		emit_signal("warning_closed")
	)


func open_warning(alert: Dictionary = {}) -> void:
	var message := str(alert.get("message", "Critical Health."))
	var low_mood_minutes := 0
	if GameState.has_method("get_pending_zero_happiness_minutes"):
		low_mood_minutes = GameState.get_pending_zero_happiness_minutes()

	title_label.text = "CRITICAL HEALTH WARNING"
	body_label.text = "%s\n\nYour Health is very low. Visit the Clinic, eat healthier food, raise Happiness, sleep, or recover before continuing too aggressively." % message
	detail_label.text = "Current Health: %d / %d\nFood: %d / %d\nHappiness: %d / 100\nStarving Timer: %d / 60 min\nLow Mood Timer: %d / 60 min\nDaily Aging Loss: -%d Health per new day\n%s" % [
		GameState.health,
		GameState.get_max_health(),
		GameState.hunger,
		GameState.get_max_fullness(),
		GameState.happiness,
		GameState.get_pending_starvation_minutes(),
		low_mood_minutes,
		GameState.get_daily_aging_health_loss_for_day(),
		GameState.get_meter_scaling_summary()
	]
	visible = true
	if get_parent() != null:
		get_parent().move_child(self, get_parent().get_child_count() - 1)