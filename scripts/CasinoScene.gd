extends Control

signal casino_action_completed(result: Dictionary)
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var wallet_label: Label = $Content/Layout/TopRow/WalletLabel
@onready var summary_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/SummaryLabel
@onready var blackjack_tab_button: Button = $Content/Layout/GameTabRow/BlackjackTabButton
@onready var slots_tab_button: Button = $Content/Layout/GameTabRow/SlotsTabButton
@onready var blackjack_panel: PanelContainer = $Content/Layout/BlackjackPanel
@onready var slots_panel: PanelContainer = $Content/Layout/SlotsPanel
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel

@onready var blackjack_bet_slider: HSlider = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/BetPanel/BetMargin/BetColumn/BetRow/BetSlider
@onready var blackjack_bet_line_edit: LineEdit = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/BetPanel/BetMargin/BetColumn/BetRow/BetLineEdit
@onready var blackjack_max_button: Button = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/BetPanel/BetMargin/BetColumn/BetRow/MaxBetButton
@onready var deal_button: Button = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/BetPanel/BetMargin/BetColumn/BetRow/DealButton
@onready var dealer_value_label: Label = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/DealerPanel/DealerMargin/DealerColumn/DealerValueLabel
@onready var dealer_cards_row: HBoxContainer = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/DealerPanel/DealerMargin/DealerColumn/DealerCardsRow
@onready var player_value_label: Label = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/PlayerPanel/PlayerMargin/PlayerColumn/PlayerValueLabel
@onready var player_cards_row: HBoxContainer = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/PlayerPanel/PlayerMargin/PlayerColumn/PlayerCardsRow
@onready var hit_button: Button = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/ActionRow/HitButton
@onready var stand_button: Button = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/ActionRow/StandButton
@onready var new_round_button: Button = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/ActionRow/NewRoundButton
@onready var blackjack_result_label: Label = $Content/Layout/BlackjackPanel/BlackjackMargin/BlackjackColumn/BlackjackResultLabel

@onready var slots_bet_slider: HSlider = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/BetPanel/BetMargin/BetColumn/BetRow/BetSlider
@onready var slots_bet_line_edit: LineEdit = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/BetPanel/BetMargin/BetColumn/BetRow/BetLineEdit
@onready var slots_max_button: Button = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/BetPanel/BetMargin/BetColumn/BetRow/MaxBetButton
@onready var spin_button: Button = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/BetPanel/BetMargin/BetColumn/BetRow/SpinButton
@onready var reel1_label: Label = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/ReelPanel/ReelMargin/ReelRow/Reel1Label
@onready var reel2_label: Label = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/ReelPanel/ReelMargin/ReelRow/Reel2Label
@onready var reel3_label: Label = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/ReelPanel/ReelMargin/ReelRow/Reel3Label
@onready var slots_result_label: Label = $Content/Layout/SlotsPanel/SlotsMargin/SlotsColumn/SlotsResultLabel

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _syncing_bet_ui: bool = false
var _deck: Array[Dictionary] = []
var _player_hand: Array[Dictionary] = []
var _dealer_hand: Array[Dictionary] = []
var _dealer_hidden: bool = true
var _round_active: bool = false
var _round_busy: bool = false
var _slots_busy: bool = false
var _blackjack_bet: int = 0

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		if not can_leave_location():
			message_label.text = get_leave_block_message()
			return
		emit_signal("back_pressed")
	)

	blackjack_tab_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_show_blackjack()
	)

	slots_tab_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_show_slots()
	)

	blackjack_bet_slider.value_changed.connect(func(value: float) -> void:
		if _syncing_bet_ui:
			return
		_syncing_bet_ui = true
		blackjack_bet_line_edit.text = str(int(value))
		_syncing_bet_ui = false
	)

	blackjack_bet_line_edit.text_changed.connect(func(text_value: String) -> void:
		if _syncing_bet_ui:
			return
		_sync_bet_line_to_slider(blackjack_bet_line_edit, blackjack_bet_slider, text_value)
	)

	slots_bet_slider.value_changed.connect(func(value: float) -> void:
		if _syncing_bet_ui:
			return
		_syncing_bet_ui = true
		slots_bet_line_edit.text = str(int(value))
		_syncing_bet_ui = false
	)

	slots_bet_line_edit.text_changed.connect(func(text_value: String) -> void:
		if _syncing_bet_ui:
			return
		_sync_bet_line_to_slider(slots_bet_line_edit, slots_bet_slider, text_value)
	)

	blackjack_max_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_set_bet_amount(blackjack_bet_line_edit, blackjack_bet_slider, GameState.money)
	)

	slots_max_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_set_bet_amount(slots_bet_line_edit, slots_bet_slider, GameState.money)
	)

	deal_button.pressed.connect(func() -> void:
		_on_deal_pressed()
	)

	hit_button.pressed.connect(func() -> void:
		_on_hit_pressed()
	)

	stand_button.pressed.connect(func() -> void:
		_on_stand_pressed()
	)

	new_round_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_reset_blackjack_table()
	)

	spin_button.pressed.connect(func() -> void:
		_on_spin_pressed()
	)

	_show_blackjack()
	_reset_blackjack_table()
	refresh()


func can_leave_location() -> bool:
	return not _round_active and not _round_busy and not _slots_busy


func get_leave_block_message() -> String:
	if _round_busy:
		return "Casino: wait for the current card animation to finish."
	if _round_active:
		return "Casino: finish the current blackjack hand before traveling."
	if _slots_busy:
		return "Casino: wait for the slot spin to finish."
	return "Casino: finish the current action before traveling."


func _exit_tree() -> void:
	_round_active = false
	_round_busy = false
	_slots_busy = false

func refresh() -> void:
	wallet_label.text = "Wallet: $%d" % GameState.money
	var casino_data: Dictionary = GameState.get_casino_data()
	summary_label.text = "Net: %+d | Blackjack: %dW/%dL/%dP | Slots wins: %d/%d" % [
		int(casino_data.get("casino_net", 0)),
		int(casino_data.get("blackjack_wins", 0)),
		int(casino_data.get("blackjack_losses", 0)),
		int(casino_data.get("blackjack_pushes", 0)),
		int(casino_data.get("slots_wins", 0)),
		int(casino_data.get("slots_spins", 0))
	]
	_update_bet_sliders()
	if not _round_active and not _round_busy:
		_set_blackjack_buttons(false)
		deal_button.disabled = GameState.money <= 0

	if not _slots_busy:
		spin_button.disabled = GameState.money <= 0

func _show_blackjack() -> void:
	blackjack_panel.visible = true
	slots_panel.visible = false
	message_label.text = "Blackjack: use the slider or type a cash bet, then deal."

func _show_slots() -> void:
	blackjack_panel.visible = false
	slots_panel.visible = true
	message_label.text = "Slots: choose a bet from $0 to your full wallet, then spin."

func _update_bet_sliders() -> void:
	_syncing_bet_ui = true
	blackjack_bet_slider.min_value = 0
	blackjack_bet_slider.max_value = GameState.money
	blackjack_bet_slider.step = 1
	blackjack_bet_slider.value = clampi(_parse_bet(blackjack_bet_line_edit), 0, GameState.money)
	blackjack_bet_line_edit.text = str(int(blackjack_bet_slider.value))

	slots_bet_slider.min_value = 0
	slots_bet_slider.max_value = GameState.money
	slots_bet_slider.step = 1
	slots_bet_slider.value = clampi(_parse_bet(slots_bet_line_edit), 0, GameState.money)
	slots_bet_line_edit.text = str(int(slots_bet_slider.value))
	_syncing_bet_ui = false

func _sync_bet_line_to_slider(_line_edit: LineEdit, slider: HSlider, text_value: String) -> void:
	var value := _parse_bet_text(text_value)
	value = clampi(value, 0, GameState.money)
	_syncing_bet_ui = true
	slider.value = value
	_syncing_bet_ui = false

func _set_bet_amount(line_edit: LineEdit, slider: HSlider, amount: int) -> void:
	var value := clampi(amount, 0, GameState.money)
	_syncing_bet_ui = true
	slider.value = value
	line_edit.text = str(value)
	_syncing_bet_ui = false

func _parse_bet(line_edit: LineEdit) -> int:
	return _parse_bet_text(line_edit.text)

func _parse_bet_text(text_value: String) -> int:
	var cleaned := text_value.strip_edges().replace("$", "").replace(",", "")
	if cleaned == "" or not cleaned.is_valid_int():
		return 0
	return maxi(0, int(cleaned))

func _on_deal_pressed() -> void:
	if _round_active or _round_busy:
		return

	var bet := _parse_bet(blackjack_bet_line_edit)
	var pay_check: Dictionary = GameState.can_place_casino_bet(bet)
	if not bool(pay_check.get("success", false)):
		AudioManager.play_ui_click()
		blackjack_result_label.text = str(pay_check.get("message", "Invalid bet."))
		message_label.text = blackjack_result_label.text
		return

	_blackjack_bet = bet
	_start_blackjack_deal()

func _start_blackjack_deal() -> void:
	_round_busy = true
	_round_active = false
	_dealer_hidden = true
	_set_blackjack_buttons(false)
	deal_button.disabled = true
	new_round_button.disabled = true
	blackjack_result_label.text = "Dealing cards face down..."
	message_label.text = "Dealing blackjack hand..."
	_build_deck()
	_player_hand.clear()
	_dealer_hand.clear()
	_player_hand.append(_draw_card())
	_dealer_hand.append(_draw_card())
	_player_hand.append(_draw_card())
	_dealer_hand.append(_draw_card())
	AudioManager.play_card_deal()
	_render_blackjack_hands(true)
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	AudioManager.play_card_flip()
	_round_busy = false
	_round_active = true
	_render_blackjack_hands(false)
	blackjack_result_label.text = "Hit or Stand. Dealer has one hidden card."
	message_label.text = "Blackjack hand active."
	_set_blackjack_buttons(true)

	if _is_blackjack(_player_hand) or _is_blackjack(_dealer_hand):
		await get_tree().create_timer(0.8).timeout
		if not is_inside_tree():
			return
		_finish_blackjack_after_natural()

func _on_hit_pressed() -> void:
	if not _round_active or _round_busy:
		return

	_round_busy = true
	_set_blackjack_buttons(false)
	var new_card := _draw_card()
	_player_hand.append(new_card)
	AudioManager.play_card_deal()
	_render_blackjack_hands(false, true)
	await get_tree().create_timer(0.55).timeout
	if not is_inside_tree():
		return
	AudioManager.play_card_flip()
	_round_busy = false
	_render_blackjack_hands(false)

	if _hand_value(_player_hand) > 21:
		_settle_blackjack("lose")
	else:
		_set_blackjack_buttons(true)
		blackjack_result_label.text = "Hit or Stand."

func _on_stand_pressed() -> void:
	if not _round_active or _round_busy:
		return

	_round_busy = true
	_set_blackjack_buttons(false)
	_dealer_hidden = false
	AudioManager.play_card_flip()
	_render_blackjack_hands(false)
	blackjack_result_label.text = "Dealer reveals and plays..."
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return

	while _hand_value(_dealer_hand) < 17:
		_dealer_hand.append(_draw_card())
		AudioManager.play_card_deal()
		_render_blackjack_hands(false, false, true)
		await get_tree().create_timer(0.55).timeout
		if not is_inside_tree():
			return
		AudioManager.play_card_flip()
		_render_blackjack_hands(false)
		await get_tree().create_timer(0.4).timeout
		if not is_inside_tree():
			return

	_round_busy = false
	var player_value := _hand_value(_player_hand)
	var dealer_value := _hand_value(_dealer_hand)
	if dealer_value > 21:
		_settle_blackjack("win")
	elif player_value > dealer_value:
		_settle_blackjack("win")
	elif player_value == dealer_value:
		_settle_blackjack("push")
	else:
		_settle_blackjack("lose")

func _finish_blackjack_after_natural() -> void:
	_dealer_hidden = false
	_render_blackjack_hands(false)
	var player_blackjack := _is_blackjack(_player_hand)
	var dealer_blackjack := _is_blackjack(_dealer_hand)
	if player_blackjack and dealer_blackjack:
		_settle_blackjack("push")
	elif player_blackjack:
		_settle_blackjack("blackjack")
	else:
		_settle_blackjack("lose")

func _settle_blackjack(outcome: String) -> void:
	_round_active = false
	_round_busy = false
	_dealer_hidden = false
	_set_blackjack_buttons(false)
	new_round_button.disabled = false
	_render_blackjack_hands(false)
	var result: Dictionary = GameState.resolve_blackjack_round(outcome, _blackjack_bet, _hand_value(_player_hand), _hand_value(_dealer_hand))
	if int(result.get("money_delta", 0)) >= 0:
		AudioManager.play_casino_win()
	else:
		AudioManager.play_casino_lose()
	blackjack_result_label.text = str(result.get("message", "Blackjack complete."))
	message_label.text = blackjack_result_label.text
	refresh()
	deal_button.disabled = true
	new_round_button.disabled = false
	emit_signal("casino_action_completed", result)

func _reset_blackjack_table() -> void:
	_round_active = false
	_round_busy = false
	_dealer_hidden = true
	_blackjack_bet = 0
	_player_hand.clear()
	_dealer_hand.clear()
	_clear_cards(player_cards_row)
	_clear_cards(dealer_cards_row)
	player_value_label.text = "Value: 0"
	dealer_value_label.text = "Value: ?"
	blackjack_result_label.text = "Place a bet and deal to begin."
	_set_blackjack_buttons(false)
	deal_button.disabled = false
	new_round_button.disabled = true
	refresh()

func _set_blackjack_buttons(enabled: bool) -> void:
	hit_button.disabled = not enabled
	stand_button.disabled = not enabled

func _build_deck() -> void:
	_deck.clear()
	var suits := ["♠", "♥", "♦", "♣"]
	var ranks := ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	for suit in suits:
		for rank in ranks:
			_deck.append({"rank": rank, "suit": suit})
	_deck.shuffle()

func _draw_card() -> Dictionary:
	if _deck.is_empty():
		_build_deck()
	return _deck.pop_back()

func _render_blackjack_hands(face_down_all: bool = false, hide_new_player_card: bool = false, hide_new_dealer_card: bool = false) -> void:
	_clear_cards(player_cards_row)
	_clear_cards(dealer_cards_row)
	for i in range(_player_hand.size()):
		var card_hidden := face_down_all or (hide_new_player_card and i == _player_hand.size() - 1)
		player_cards_row.add_child(_make_card_label(_player_hand[i], card_hidden))
	for i in range(_dealer_hand.size()):
		var card_hidden := face_down_all or (_dealer_hidden and i == 1) or (hide_new_dealer_card and i == _dealer_hand.size() - 1)
		dealer_cards_row.add_child(_make_card_label(_dealer_hand[i], card_hidden))
	player_value_label.text = "Value: %d" % _hand_value(_player_hand)
	dealer_value_label.text = "Value: ?" if _dealer_hidden or face_down_all else "Value: %d" % _hand_value(_dealer_hand)

func _clear_cards(row: HBoxContainer) -> void:
	for child in row.get_children():
		child.queue_free()

func _make_card_label(card: Dictionary, is_hidden: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(84, 112)
	panel.add_theme_stylebox_override("panel", _make_card_style(is_hidden))
	var label := Label.new()
	label.text = "🂠" if is_hidden else _card_text(card)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1) if is_hidden else _card_color(card))
	panel.add_child(label)
	return panel

func _make_card_style(is_hidden: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.22, 0.42, 1.0) if is_hidden else Color(0.96, 0.96, 0.92, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.92, 0.62, 0.45)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

func _card_text(card: Dictionary) -> String:
	return "%s%s" % [str(card.get("rank", "?")), str(card.get("suit", "?"))]

func _card_color(card: Dictionary) -> Color:
	var suit := str(card.get("suit", ""))
	if suit == "♥" or suit == "♦":
		return Color(0.82, 0.06, 0.08, 1)
	return Color(0.05, 0.07, 0.10, 1)

func _hand_value(hand: Array[Dictionary]) -> int:
	var total := 0
	var aces := 0
	for card in hand:
		var rank := str(card.get("rank", ""))
		match rank:
			"A":
				total += 11
				aces += 1
			"K", "Q", "J":
				total += 10
			_:
				total += int(rank)
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total

func _is_blackjack(hand: Array[Dictionary]) -> bool:
	return hand.size() == 2 and _hand_value(hand) == 21

func _on_spin_pressed() -> void:
	if spin_button.disabled or _slots_busy:
		return
	var bet := _parse_bet(slots_bet_line_edit)
	var pay_check: Dictionary = GameState.can_place_casino_bet(bet)
	if not bool(pay_check.get("success", false)):
		AudioManager.play_ui_click()
		slots_result_label.text = str(pay_check.get("message", "Invalid bet."))
		message_label.text = slots_result_label.text
		return
	_slots_busy = true
	spin_button.disabled = true
	slots_result_label.text = "Spinning..."
	message_label.text = "Slots spinning..."
	reel1_label.text = "🎰"
	reel2_label.text = "🎰"
	reel3_label.text = "🎰"
	AudioManager.play_slots_spin()
	await get_tree().create_timer(0.9).timeout
	if not is_inside_tree():
		return
	var result: Dictionary = GameState.play_slots_round(bet)
	var symbols: Array = result.get("symbols", [])
	if symbols.size() >= 3:
		reel1_label.text = str(symbols[0])
		reel2_label.text = str(symbols[1])
		reel3_label.text = str(symbols[2])
	if int(result.get("money_delta", 0)) > 0:
		AudioManager.play_casino_win()
	else:
		AudioManager.play_casino_lose()
	slots_result_label.text = str(result.get("message", "Slots complete."))
	message_label.text = slots_result_label.text
	_slots_busy = false
	spin_button.disabled = false
	refresh()
	emit_signal("casino_action_completed", result)
