extends Node

const SFX_BASE := "res://assets/audio/sfx/"

@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var ui_click: AudioStreamPlayer = $UIClick
@onready var action_sfx: AudioStreamPlayer = get_node_or_null("ActionSFX") as AudioStreamPlayer

func _ready() -> void:
	if action_sfx == null:
		action_sfx = AudioStreamPlayer.new()
		action_sfx.name = "ActionSFX"
		action_sfx.bus = &"SFX"
		add_child(action_sfx)

	if menu_music != null and not menu_music.finished.is_connected(_on_menu_music_finished):
		menu_music.finished.connect(_on_menu_music_finished)

	if menu_music != null and menu_music.stream != null and not menu_music.playing:
		menu_music.play()


func play_ui_click() -> void:
	if ui_click == null:
		return
	ui_click.stop()
	ui_click.play()


func play_menu_music() -> void:
	if menu_music == null or menu_music.stream == null:
		return

	if not menu_music.playing:
		menu_music.play()


func stop_menu_music() -> void:
	if menu_music == null:
		return

	menu_music.stop()


func play_sfx_file(file_name: String, fallback_to_click: bool = true) -> void:
	var path := SFX_BASE + file_name
	if ResourceLoader.exists(path):
		var stream := load(path)
		if stream is AudioStream:
			_play_action_stream(stream as AudioStream)
			return

	if fallback_to_click:
		play_ui_click()


func play_eat_food() -> void:
	play_sfx_file("eat_food.wav")


func play_sleep() -> void:
	play_sfx_file("sleep.wav")


func play_work() -> void:
	play_sfx_file("work_shift.wav")


func play_gym() -> void:
	play_sfx_file("gym_workout.wav")


func play_study() -> void:
	play_sfx_file("study.wav")


func play_buy_item() -> void:
	play_sfx_file("buy_item.wav")


func play_bank() -> void:
	play_sfx_file("bank_action.wav")


func play_travel(is_electric: bool = false) -> void:
	if is_electric:
		play_sfx_file("travel_electric.wav")
	else:
		play_sfx_file("travel_gas.wav")


func play_burger_correct() -> void:
	play_sfx_file("burger_correct.wav")


func play_burger_wrong() -> void:
	play_sfx_file("burger_wrong.wav")


func play_burger_success() -> void:
	play_sfx_file("burger_success.wav")


func play_equip_car() -> void:
	play_sfx_file("equip_car.wav")


func play_clinic() -> void:
	play_sfx_file("clinic_action.wav")


func play_phone() -> void:
	play_sfx_file("phone_action.wav")


func play_reincarnation() -> void:
	play_sfx_file("reincarnation.wav")


func play_card_deal() -> void:
	play_sfx_file("card_deal.wav")


func play_card_flip() -> void:
	play_sfx_file("card_flip.wav")


func play_slots_spin() -> void:
	play_sfx_file("slots_spin.wav")


func play_casino_win() -> void:
	play_sfx_file("casino_win.wav")


func play_casino_lose() -> void:
	play_sfx_file("casino_lose.wav")


func _play_action_stream(stream: AudioStream) -> void:
	if action_sfx == null:
		return
	action_sfx.stop()
	action_sfx.stream = stream
	action_sfx.play()


func _on_menu_music_finished() -> void:
	if menu_music == null or menu_music.stream == null:
		return

	menu_music.play()
