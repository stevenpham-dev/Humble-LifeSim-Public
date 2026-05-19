
extends Control

signal phone_action_completed(result: Dictionary)
signal back_pressed

@onready var back_button: Button = $Content/Layout/TopRow/BackButton
@onready var current_job_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/CurrentJobLabel
@onready var boss_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/BossLabel
@onready var bonus_label: Label = $Content/Layout/SummaryPanel/SummaryMargin/SummaryColumn/BonusLabel
@onready var contact_option_button: OptionButton = $Content/Layout/ContactPanel/ContactMargin/ContactColumn/ContactRow/ContactOptionButton
@onready var contact_info_label: Label = $Content/Layout/ContactPanel/ContactMargin/ContactColumn/ContactInfoLabel
@onready var converse_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/ActionGrid/ConverseButton
@onready var praise_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/ActionGrid/PraiseButton
@onready var advice_button: Button = $Content/Layout/ActionPanel/ActionMargin/ActionColumn/ActionGrid/AdviceButton
@onready var message_label: Label = $Content/Layout/MessagePanel/MessageLabel
@onready var contact_list: VBoxContainer = $Content/Layout/ListPanel/ListMargin/ContactScroll/ContactList

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _contacts: Array[Dictionary] = []
var _selected_contact_id: String = ""

func _ready() -> void:
	back_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		emit_signal("back_pressed")
	)

	contact_option_button.item_selected.connect(func(_index: int) -> void:
		AudioManager.play_ui_click()
		var contact := _get_selected_contact()
		if not contact.is_empty():
			_selected_contact_id = str(contact.get("contact_id", ""))
		_refresh_selected_contact()
	)

	converse_button.pressed.connect(func() -> void:
		_run_phone_action("converse")
	)

	praise_button.pressed.connect(func() -> void:
		_run_phone_action("praise")
	)

	advice_button.pressed.connect(func() -> void:
		_run_phone_action("advice")
	)

	message_label.text = "Build relationships with known bosses and employers. JobBoard contacts appear here after you meet enough requirements."
	refresh()


func refresh() -> void:
	var previous_selected_id := _selected_contact_id
	if GameState.has_method("get_preferred_phone_contact_id"):
		var preferred_id := GameState.get_preferred_phone_contact_id()
		if preferred_id != "":
			previous_selected_id = preferred_id
			if GameState.has_method("clear_preferred_phone_contact_id"):
				GameState.clear_preferred_phone_contact_id()

	if previous_selected_id == "":
		var old_contact := _get_selected_contact()
		if not old_contact.is_empty():
			previous_selected_id = str(old_contact.get("contact_id", ""))

	_contacts = GameState.get_phone_contacts()
	current_job_label.text = "Current Job: %s" % GameState.get_primary_job_name()
	boss_label.text = "Boss: %s" % GameState.get_current_boss_relationship_summary()
	bonus_label.text = "Phone actions take time, use Energy, drain Food, and can randomly improve social or insight stats."

	contact_option_button.clear()
	var select_index := -1
	for i in range(_contacts.size()):
		var contact: Dictionary = _contacts[i]
		var label := "%s — %s" % [str(contact.get("name", "Contact")), str(contact.get("role", "Role"))]
		if bool(contact.get("is_current_boss", false)):
			label += " (Current Boss)"
		contact_option_button.add_item(label, i)
		if str(contact.get("contact_id", "")) == previous_selected_id:
			select_index = i

	if _contacts.size() > 0:
		if select_index < 0:
			select_index = 0
		contact_option_button.select(select_index)
		_selected_contact_id = str(_contacts[select_index].get("contact_id", ""))

	_refresh_selected_contact()
	_rebuild_contact_list()


func _get_selected_contact() -> Dictionary:
	if _contacts.is_empty():
		return {}
	var index := clampi(contact_option_button.selected, 0, _contacts.size() - 1)
	return _contacts[index]


func _refresh_selected_contact() -> void:
	var contact := _get_selected_contact()
	if contact.is_empty():
		contact_info_label.text = "No contacts available."
		return

	var job_id := str(contact.get("job_id", ""))
	var contact_id := str(contact.get("contact_id", ""))
	var relationship := GameState.get_relationship(contact_id)
	var rank := GameState.get_relationship_rank_text(relationship)
	var apply_bonus := GameState.get_job_application_relationship_bonus(job_id)
	var exp_bonus := GameState.get_job_work_exp_bonus_percent(job_id)
	var advice_stats: Array = contact.get("advice_stats", [])
	var advice_text := ", ".join(_capitalize_array(advice_stats))

	contact_info_label.text = "%s\nRole: %s\nRelationship: %d/100 (%s)\nApplication Bonus: +%d%%\nWork EXP Bonus: +%d%%\nAdvice can improve: %s
Energy Cost: Converse 6 | Praise 5 | Advice 8" % [
		str(contact.get("name", "Contact")),
		str(contact.get("role", "Role")),
		relationship,
		rank,
		apply_bonus,
		exp_bonus,
		advice_text
	]


func _capitalize_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value).capitalize())
	return result


func _run_phone_action(action: String) -> void:
	var contact := _get_selected_contact()
	if contact.is_empty():
		return

	_selected_contact_id = str(contact.get("contact_id", ""))
	AudioManager.play_phone()
	var result: Dictionary = GameState.do_phone_action(_selected_contact_id, action)
	message_label.text = str(result.get("message", "Phone updated."))
	refresh()
	emit_signal("phone_action_completed", result)


func _rebuild_contact_list() -> void:
	for child in contact_list.get_children():
		child.queue_free()

	for contact in _contacts:
		contact_list.add_child(_make_contact_label(contact))


func _make_contact_label(contact: Dictionary) -> Label:
	var job_id := str(contact.get("job_id", ""))
	var relationship := GameState.get_job_employer_relationship(job_id)
	var label := Label.new()
	label.text = "%s — %s | %d/100 | Apply +%d%% | Work EXP +%d%%" % [
		str(contact.get("name", "Contact")),
		str(contact.get("role", "Role")),
		relationship,
		GameState.get_job_application_relationship_bonus(job_id),
		GameState.get_job_work_exp_bonus_percent(job_id)
	]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1))
	return label
