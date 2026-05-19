extends Control

signal bank_action_completed
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var wallet_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/WalletLabel
@onready var bank_balance_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/BankBalanceLabel
@onready var net_worth_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/NetWorthLabel
@onready var interest_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryGrid/InterestLabel
@onready var amount_line_edit: LineEdit = $Content/Layout/ActionsPanel/ActionsMargin/ActionsColumn/AmountRow/AmountLineEdit
@onready var deposit_button: Button = $Content/Layout/ActionsPanel/ActionsMargin/ActionsColumn/ButtonGrid/DepositButton
@onready var withdraw_button: Button = $Content/Layout/ActionsPanel/ActionsMargin/ActionsColumn/ButtonGrid/WithdrawButton
@onready var deposit_all_button: Button = $Content/Layout/ActionsPanel/ActionsMargin/ActionsColumn/ButtonGrid/DepositAllButton
@onready var withdraw_all_button: Button = $Content/Layout/ActionsPanel/ActionsMargin/ActionsColumn/ButtonGrid/WithdrawAllButton
@onready var message_label: Label = $Content/Layout/MessageLabel
@onready var history_list: VBoxContainer = $Content/Layout/HistoryPanel/HistoryMargin/HistoryScroll/HistoryList

var _font: Font = preload("res://assets/fonts/fonts.ttf")

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	deposit_button.pressed.connect(func() -> void:
		AudioManager.play_bank()
		_handle_result(GameState.deposit_to_bank(_parse_amount()))
	)

	withdraw_button.pressed.connect(func() -> void:
		AudioManager.play_bank()
		_handle_result(GameState.withdraw_from_bank(_parse_amount()))
	)

	deposit_all_button.pressed.connect(func() -> void:
		AudioManager.play_bank()
		_handle_result(GameState.deposit_all_to_bank())
	)

	withdraw_all_button.pressed.connect(func() -> void:
		AudioManager.play_bank()
		_handle_result(GameState.withdraw_all_from_bank())
	)

	amount_line_edit.text_submitted.connect(func(_text: String) -> void:
		AudioManager.play_bank()
		_handle_result(GameState.deposit_to_bank(_parse_amount()))
	)

	message_label.text = "Deposit money to savings, withdraw it later, and earn small daily interest when you sleep."
	_refresh()


func _parse_amount() -> int:
	var cleaned := amount_line_edit.text.strip_edges()
	cleaned = cleaned.replace("$", "")
	cleaned = cleaned.replace(",", "")

	if cleaned == "" or not cleaned.is_valid_int():
		return 0

	return maxi(0, int(cleaned))


func _handle_result(result: Dictionary) -> void:
	message_label.text = str(result.get("message", ""))

	if bool(result.get("success", false)):
		amount_line_edit.text = ""
		emit_signal("bank_action_completed")

	_refresh()


func _refresh() -> void:
	wallet_label.text = "Wallet: $%d" % GameState.money
	bank_balance_label.text = "Bank Balance: $%d" % GameState.get_bank_balance()
	net_worth_label.text = "Net Worth: $%d" % GameState.get_net_worth()
	interest_label.text = "Daily Interest: %s | Next Sleep: +$%d" % [
		GameState.get_bank_daily_interest_percent_text(),
		GameState.get_bank_interest_preview()
	]

	deposit_button.disabled = GameState.money <= 0
	deposit_all_button.disabled = GameState.money <= 0
	withdraw_button.disabled = GameState.get_bank_balance() <= 0
	withdraw_all_button.disabled = GameState.get_bank_balance() <= 0

	_refresh_history()


func _refresh_history() -> void:
	for child in history_list.get_children():
		child.queue_free()

	var transactions: Array = GameState.get_bank_transactions()
	if transactions.is_empty():
		history_list.add_child(_make_history_label("No bank transactions yet."))
		return

	for i in range(transactions.size() - 1, -1, -1):
		var entry: Dictionary = transactions[i]
		var line := "Day %d %s - %s | Wallet $%d | Bank $%d" % [
			int(entry.get("day", 1)),
			str(entry.get("time_text", "00:00")),
			str(entry.get("text", "Transaction")),
			int(entry.get("wallet", GameState.money)),
			int(entry.get("bank_balance", GameState.get_bank_balance()))
		]
		history_list.add_child(_make_history_label(line))


func _make_history_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.94, 0.95, 1.0, 1))
	return label
