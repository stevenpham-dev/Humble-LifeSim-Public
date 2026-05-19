extends Control

signal school_action_completed

@onready var description_label: Label = $Content/Layout/DescriptionLabel
@onready var summary_text: Label = $Content/Layout/StudySummaryPanel/StudySummaryMargin/StudySummaryColumn/StudySummaryText
@onready var study_column: VBoxContainer = $Content/Layout/StudyPanel/StudyMargin/StudyColumn
@onready var study_button: Button = $Content/Layout/StudyPanel/StudyMargin/StudyColumn/StudyButtonsRow/StudyButton
@onready var read_book_button: Button = $Content/Layout/StudyPanel/StudyMargin/StudyColumn/StudyButtonsRow/ReadBookButton
@onready var exam_button: Button = $Content/Layout/StudyPanel/StudyMargin/StudyColumn/StudyButtonsRow/OpenBookcaseButton
@onready var notes_column: VBoxContainer = $Content/Layout/NotesPanel/NotesMargin/NotesColumn
@onready var notes_text: Label = $Content/Layout/NotesPanel/NotesMargin/NotesColumn/NotesText

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _selected_track: String = "Sales Certificate"
var _track_buttons: Dictionary = {}
var _books_count_label: Label = null
var _exam_questions: Array[Dictionary] = []
var _exam_index: int = 0
var _exam_correct: int = 0
var _exam_active: bool = false
var _question_label: Label = null
var _answer_buttons: Array[Button] = []
var _exam_result_label: Label = null
var _last_hud_message: String = ""

const PASSING_SCORE := 2
const SCHOOL_ACTION_MINUTES := 180
const LEARN_ENERGY_COST := 15
const LEARN_STRESS_GAIN := 10
const BOOK_ENERGY_COST := 12
const BOOK_STRESS_GAIN := 8
const TRACK_ORDER := [
	"Sales Certificate",
	"Teaching Credential",
	"Programming Certificate",
	"Nursing License",
	"Engineering Degree",
	"Advanced Degree",
	"Medical Degree"
]

const TRACKS := {
	"Teaching Credential": {
		"short_name": "Teaching",
		"item_id": "teaching_credential",
		"item_image": "res://assets/images/items/certificate_scroll.png",
		"required_progress": 45,
		"required_stats": {"education": 80, "intelligence": 70, "charisma": 50, "discipline": 40},
		"recommended_books": ["teaching_credential_book"],
		"description": "Prepare for teaching jobs through communication, patience, and lesson planning.",
		"facts": [
			{
				"id": "teaching_communication",
				"fact": "Teaching requires clear communication, patience, and organized lesson planning.",
				"education": 1,
				"intelligence": 1,
				"discipline": 1,
				"question": "What skill is most important for teaching?",
				"answers": ["Clear communication", "Random guessing", "Ignoring students", "Skipping lessons"],
				"correct": 0
			},
			{
				"id": "teaching_lesson_plan",
				"fact": "A lesson plan helps a teacher organize goals, activities, and student learning.",
				"education": 1,
				"intelligence": 1,
				"charisma": 1,
				"question": "What does a lesson plan help organize?",
				"answers": ["Car repairs", "Learning goals and activities", "Bank deposits", "Gym workouts"],
				"correct": 1
			},
			{
				"id": "teaching_patience",
				"fact": "Patience helps teachers explain difficult ideas without overwhelming students.",
				"education": 1,
				"discipline": 1,
				"charisma": 1,
				"question": "Why is patience useful for teachers?",
				"answers": ["It replaces preparation", "It helps explain difficult ideas", "It removes the need to study", "It increases pay instantly"],
				"correct": 1
			}
		]
	},
	"Sales Certificate": {
		"short_name": "Sales",
		"item_id": "sales_certificate",
		"item_image": "res://assets/images/items/certificate_scroll.png",
		"required_progress": 20,
		"required_stats": {"charisma": 12, "confidence": 6},
		"recommended_books": ["sales_book"],
		"description": "Prepare for sales jobs through customer conversation, product knowledge, and confidence.",
		"facts": [
			{"id": "sales_listening", "fact": "Good sales starts with listening to the customer before recommending a product.", "charisma": 1, "confidence": 1, "question": "What should a good salesperson do first?", "answers": ["Listen to the customer", "Ignore the customer", "Guess randomly", "Leave work"], "correct": 0},
			{"id": "sales_pitch", "fact": "A clear product pitch explains the benefit, not just the price.", "charisma": 1, "discipline": 1, "question": "What should a clear product pitch explain?", "answers": ["The benefit", "Only the weather", "Nothing useful", "The bank balance"], "correct": 0},
			{"id": "sales_followup", "fact": "Following up politely can build trust and improve future opportunities.", "charisma": 1, "confidence": 1, "question": "Why does following up help in sales?", "answers": ["It builds trust", "It removes all work", "It lowers confidence", "It replaces products"], "correct": 0}
		]
	},
	"Programming Certificate": {
		"short_name": "Programming",
		"item_id": "programming_certificate",
		"item_image": "res://assets/images/items/certificate_scroll.png",
		"required_progress": 60,
		"required_stats": {"education": 100, "intelligence": 140, "discipline": 80, "confidence": 40},
		"recommended_books": ["programming_book"],
		"description": "Prepare for programming jobs through logic, variables, conditions, and debugging.",
		"facts": [
			{
				"id": "programming_logic",
				"fact": "Programming depends on logic and step-by-step problem solving.",
				"education": 1,
				"intelligence": 2,
				"discipline": 1,
				"question": "Programming mainly depends on what?",
				"answers": ["Luck", "Logic and problem solving", "Eating food", "Car upgrades"],
				"correct": 1
			},
			{
				"id": "programming_variables",
				"fact": "Variables store values that a program can read, change, and reuse.",
				"education": 1,
				"intelligence": 2,
				"question": "What do variables do in programming?",
				"answers": ["Store values", "Drive cars", "Pay bills", "Lower education"],
				"correct": 0
			},
			{
				"id": "programming_debugging",
				"fact": "Debugging means finding and fixing errors in code.",
				"education": 1,
				"intelligence": 2,
				"discipline": 1,
				"question": "What does debugging mean?",
				"answers": ["Deleting all code", "Finding and fixing code errors", "Buying a textbook", "Skipping tests"],
				"correct": 1
			}
		]
	},
	"Nursing License": {
		"short_name": "Nursing",
		"item_id": "nursing_license",
		"item_image": "res://assets/images/items/certificate_scroll.png",
		"required_progress": 75,
		"required_stats": {"education": 120, "intelligence": 110, "endurance": 100, "discipline": 80},
		"recommended_books": ["nursing_textbook"],
		"description": "Prepare for nursing through patient care, anatomy basics, and endurance.",
		"facts": [
			{
				"id": "nursing_vitals",
				"fact": "Nurses often monitor vital signs like temperature, pulse, and blood pressure.",
				"education": 2,
				"intelligence": 1,
				"endurance": 1,
				"question": "Which vital signs might a nurse monitor?",
				"answers": ["Weather and traffic", "Temperature and blood pressure", "Car mileage", "Bank interest"],
				"correct": 1
			},
			{
				"id": "nursing_patient_care",
				"fact": "Patient care requires communication, accuracy, and attention to small changes.",
				"education": 1,
				"intelligence": 1,
				"charisma": 1,
				"question": "Patient care requires communication and what else?",
				"answers": ["Accuracy", "Ignoring details", "Random choices", "No teamwork"],
				"correct": 0
			},
			{
				"id": "nursing_endurance",
				"fact": "Nursing can require strong endurance because shifts can be long and active.",
				"education": 1,
				"endurance": 2,
				"question": "Why is endurance useful for nursing?",
				"answers": ["Shifts can be long and active", "It replaces medical knowledge", "It removes stress forever", "It buys groceries"],
				"correct": 0
			}
		]
	},
	"Engineering Degree": {
		"short_name": "Engineering",
		"item_id": "engineering_degree",
		"item_image": "res://assets/images/items/diploma.png",
		"required_progress": 95,
		"required_stats": {"education": 180, "intelligence": 220, "discipline": 140, "confidence": 80},
		"recommended_books": ["engineering_textbook"],
		"description": "Prepare for engineering through design, testing, safety, and systems thinking.",
		"facts": [
			{
				"id": "engineering_testing",
				"fact": "Engineering uses testing to improve systems and reduce failure.",
				"education": 2,
				"intelligence": 2,
				"discipline": 1,
				"question": "Why do engineers test systems?",
				"answers": ["To reduce failure", "To avoid learning", "To spend money only", "To remove all rules"],
				"correct": 0
			},
			{
				"id": "engineering_safety",
				"fact": "Safety matters in engineering because designs can affect real people and structures.",
				"education": 2,
				"intelligence": 1,
				"discipline": 1,
				"question": "Why is safety important in engineering?",
				"answers": ["Designs can affect real people", "It makes code shorter", "It avoids all testing", "It replaces math"],
				"correct": 0
			},
			{
				"id": "engineering_iteration",
				"fact": "Iteration means improving a design through repeated testing and changes.",
				"education": 1,
				"intelligence": 2,
				"question": "What does iteration mean?",
				"answers": ["Improving through repeated changes", "Doing nothing", "Deleting the project", "Taking one random guess"],
				"correct": 0
			}
		]
	},
	"Medical Degree": {
		"short_name": "Medical",
		"item_id": "medical_degree",
		"item_image": "res://assets/images/items/diploma.png",
		"required_progress": 150,
		"required_stats": {"education": 450, "intelligence": 500, "endurance": 300, "discipline": 350},
		"recommended_books": ["medical_textbook"],
		"description": "Prepare for doctor careers through anatomy, diagnosis, and careful decisions.",
		"facts": [
			{
				"id": "medical_anatomy",
				"fact": "Medical careers require anatomy knowledge to understand body systems.",
				"education": 2,
				"intelligence": 2,
				"question": "Why is anatomy important in medical careers?",
				"answers": ["It explains body systems", "It replaces patient care", "It removes exams", "It increases car speed"],
				"correct": 0
			},
			{
				"id": "medical_diagnosis",
				"fact": "Diagnosis means identifying a likely health problem from evidence and symptoms.",
				"education": 2,
				"intelligence": 2,
				"discipline": 1,
				"question": "What does diagnosis mean?",
				"answers": ["Identifying a health problem", "Ignoring symptoms", "Buying food", "Skipping evidence"],
				"correct": 0
			},
			{
				"id": "medical_careful_decisions",
				"fact": "Doctors need careful decision-making because mistakes can seriously affect patients.",
				"education": 2,
				"intelligence": 2,
				"discipline": 1,
				"question": "Why do doctors need careful decision-making?",
				"answers": ["Mistakes can affect patients", "It makes work shorter", "It avoids learning", "It replaces communication"],
				"correct": 0
			}
		]
	},
	"Advanced Degree": {
		"short_name": "Advanced",
		"item_id": "advanced_degree",
		"item_image": "res://assets/images/items/diploma.png",
		"required_progress": 120,
		"required_stats": {"education": 280, "intelligence": 320, "charisma": 160, "discipline": 220},
		"recommended_books": ["advanced_academic_textbook"],
		"description": "Prepare for professor-level jobs through research, communication, and advanced study.",
		"facts": [
			{
				"id": "advanced_research",
				"fact": "Research means asking focused questions, gathering evidence, and explaining results.",
				"education": 2,
				"intelligence": 2,
				"discipline": 1,
				"question": "What does research involve?",
				"answers": ["Evidence and explanation", "Only guessing", "Skipping sources", "Avoiding questions"],
				"correct": 0
			},
			{
				"id": "advanced_professor",
				"fact": "Professors usually need advanced education, research ability, and strong communication.",
				"education": 2,
				"intelligence": 1,
				"charisma": 1,
				"question": "What do professors usually need besides education?",
				"answers": ["Research and communication", "Only money", "No reading", "No patience"],
				"correct": 0
			},
			{
				"id": "advanced_sources",
				"fact": "Strong academic work uses reliable sources and explains why evidence matters.",
				"education": 2,
				"intelligence": 2,
				"question": "What does strong academic work use?",
				"answers": ["Reliable sources", "Only opinions", "No evidence", "Random answers"],
				"correct": 0
			}
		]
	}
}

func _ready() -> void:
	study_button.text = "Learn"
	read_book_button.text = "Read Book"
	exam_button.text = "Take Exam"

	study_button.pressed.connect(_on_learn_pressed)
	read_book_button.pressed.connect(_on_read_book_pressed)
	exam_button.pressed.connect(_on_take_exam_pressed)

	_setup_track_selector()
	_setup_exam_area()
	_refresh_all()


func _get_track_order() -> Array[String]:
	var result: Array[String] = []
	for track_name in TRACK_ORDER:
		if TRACKS.has(track_name):
			result.append(str(track_name))
	for track_name in TRACKS.keys():
		var text_name := str(track_name)
		if not result.has(text_name):
			result.append(text_name)
	return result


func _setup_track_selector() -> void:
	var label := Label.new()
	label.text = "Choose Credential Track"
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.78, 1))
	study_column.add_child(label)
	study_column.move_child(label, 1)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	study_column.add_child(row)
	study_column.move_child(row, 2)

	for track_name in _get_track_order():
		var captured_track: String = str(track_name)
		var data: Dictionary = TRACKS[captured_track]
		var button := Button.new()
		button.custom_minimum_size = Vector2(135, 38)
		button.text = str(data.get("short_name", captured_track))
		button.add_theme_font_override("font", _font)
		button.add_theme_font_size_override("font_size", 14)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			_selected_track = captured_track
			_exam_active = false
			_refresh_all()
		)
		row.add_child(button)
		_track_buttons[captured_track] = button

	_books_count_label = Label.new()
	_books_count_label.text = "Books: 0"
	_books_count_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_books_count_label.add_theme_font_override("font", _font)
	_books_count_label.add_theme_font_size_override("font_size", 17)
	_books_count_label.add_theme_color_override("font_color", Color(1, 0.95, 0.60, 1))
	study_column.add_child(_books_count_label)
	study_column.move_child(_books_count_label, 3)


func _setup_exam_area() -> void:
	_question_label = Label.new()
	_question_label.text = "Choose a credential track, learn facts, then take an exam."
	_question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question_label.add_theme_font_override("font", _font)
	_question_label.add_theme_font_size_override("font_size", 18)
	_question_label.add_theme_color_override("font_color", Color(1, 0.95, 0.78, 1))
	notes_column.add_child(_question_label)

	for i in range(4):
		var answer_button := Button.new()
		answer_button.custom_minimum_size = Vector2(0, 38)
		answer_button.add_theme_font_override("font", _font)
		answer_button.add_theme_font_size_override("font_size", 15)
		answer_button.disabled = true
		answer_button.visible = false
		var answer_index := i
		answer_button.pressed.connect(func() -> void:
			_on_answer_selected(answer_index)
		)
		notes_column.add_child(answer_button)
		_answer_buttons.append(answer_button)

	_exam_result_label = Label.new()
	_exam_result_label.text = ""
	_exam_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_exam_result_label.add_theme_font_override("font", _font)
	_exam_result_label.add_theme_font_size_override("font_size", 17)
	_exam_result_label.add_theme_color_override("font_color", Color(0.78, 1.0, 0.82, 1))
	notes_column.add_child(_exam_result_label)


func _refresh_all() -> void:
	_refresh_track_buttons()
	_refresh_book_count_label()
	_refresh_summary()
	_refresh_notes()
	_refresh_exam_controls()


func _refresh_track_buttons() -> void:
	for track_name in _track_buttons.keys():
		var button: Button = _track_buttons[track_name]
		var owned: bool = GameState.has_credential(track_name)
		var selected: bool = track_name == _selected_track

		if owned:
			button.text = "OK %s" % str(TRACKS[track_name].get("short_name", track_name))
		else:
			button.text = str(TRACKS[track_name].get("short_name", track_name))

		if selected:
			button.add_theme_color_override("font_color", Color(1, 0.95, 0.55, 1))
		else:
			button.add_theme_color_override("font_color", Color(1, 1, 1, 1))



func _refresh_book_count_label() -> void:
	if _books_count_label == null:
		return

	var useful_book_count := _get_owned_useful_book_count(_selected_track)
	var recommended_text := _build_recommended_book_text(_selected_track)
	_books_count_label.text = "Books: %d useful for %s | %s" % [useful_book_count, _selected_track, recommended_text]

func _refresh_summary() -> void:
	var owned_credentials: Array[String] = []
	for credential_name in _get_track_order():
		if GameState.has_credential(credential_name):
			owned_credentials.append(credential_name)

	var credential_text := "None"
	if not owned_credentials.is_empty():
		credential_text = ", ".join(owned_credentials)

	var useful_book_count := _get_owned_useful_book_count(_selected_track)
	summary_text.text = "Education: %d | Intelligence: %d | Endurance: %d | Food: %d | Books: %d\nSelected: %s | Credentials: %s" % [
		GameState.education,
		GameState.intelligence,
		GameState.endurance,
		GameState.hunger,
		useful_book_count,
		_selected_track,
		credential_text
	]

func _refresh_notes() -> void:
	var data: Dictionary = TRACKS.get(_selected_track, {})
	var progress: int = GameState.get_school_progress(_selected_track)
	var required_progress: int = int(data.get("required_progress", 1))
	var requirement_text: String = _build_requirement_text(_selected_track)
	var book_text: String = _build_recommended_book_text(_selected_track)
	var useful_book_count := _get_owned_useful_book_count(_selected_track)
	var learned_count: int = GameState.get_school_learned_fact_count(_selected_track)
	var status := "Not earned"

	if GameState.has_credential(_selected_track):
		status = "Earned"
	elif _meets_exam_requirements(_selected_track):
		status = "Ready for exam"
	else:
		status = "Keep learning"

	var hidden_hint := ""
	var overflow_progress := _get_track_overprogress(_selected_track)
	if overflow_progress > 0:
		if bool(GameState.flags.get("achievement_learn_too_much", false)):
			hidden_hint = "\nHidden Study: +%d extra progress is stored. Press Take Exam to convert it into a book-like bonus and cap progress back to %d/%d." % [overflow_progress, required_progress, required_progress]
		else:
			hidden_hint = "\nSomething feels overprepared..."

	notes_text.text = "%s\n\nStatus: %s\nProgress: %d / %d\nBooks Owned: %d\nFacts Learned: %d / 3\nRequirements: %s\nRecommended Book: %s%s" % [
		str(data.get("description", "Choose a credential track.")),
		status,
		progress,
		required_progress,
		useful_book_count,
		learned_count,
		requirement_text,
		book_text,
		hidden_hint
	]

	var costs: Dictionary = _get_school_action_costs(_selected_track, false)
	var book_costs: Dictionary = _get_school_action_costs(_selected_track, true)
	var learn_energy := int(costs.get("energy", LEARN_ENERGY_COST))
	var read_energy := int(book_costs.get("energy", BOOK_ENERGY_COST))
	study_button.text = "Learn" if GameState.can_perform_action(learn_energy) else "Learn (Need Energy)"
	read_book_button.text = "Read Book" if GameState.can_perform_action(read_energy) else "Read Book (Need Energy)"
	description_label.text = "School actions take 3 hours. Tracks follow the career path: Sales -> Teaching -> Programming -> Nursing -> Engineering -> Advanced -> Medical. Learn is free; Read Book uses the matching profession book. Current Learn Cost: Energy -%d | Stress +%d." % [learn_energy, int(costs.get("stress", LEARN_STRESS_GAIN))]


func _refresh_exam_controls() -> void:
	if not _exam_active:
		if _question_label != null:
			_question_label.text = "Exam Area: Learn facts first, then press Take Exam for %s." % _selected_track
		for button in _answer_buttons:
			button.visible = false
		if _exam_result_label != null:
			_exam_result_label.text = "Pass score: %d / 3 correct." % PASSING_SCORE
		return

	if _exam_index >= _exam_questions.size():
		return

	var question: Dictionary = _exam_questions[_exam_index]
	_question_label.text = "Question %d of %d: %s" % [
		_exam_index + 1,
		_exam_questions.size(),
		str(question.get("question", ""))
	]

	var answers: Array = question.get("answers", [])
	var letters := ["A", "B", "C", "D"]
	for i in range(_answer_buttons.size()):
		var button: Button = _answer_buttons[i]
		if i < answers.size():
			button.visible = true
			button.disabled = false
			button.text = "%s. %s" % [letters[i], str(answers[i])]
		else:
			button.visible = false
			button.disabled = true

	_exam_result_label.text = "Correct so far: %d" % _exam_correct



func _get_track_preparedness_percent(track_name: String) -> int:
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_stats: Dictionary = data.get("required_stats", {})
	var total_needed := 0
	var total_current_capped := 0

	for stat_name in required_stats.keys():
		var needed := int(required_stats[stat_name])
		var current_value := int(GameState.get(str(stat_name)))
		total_needed += needed
		total_current_capped += mini(current_value, needed)

	if total_needed <= 0:
		return 100
	return clampi(int(floor((float(total_current_capped) / float(total_needed)) * 100.0)), 0, 100)


func _get_school_action_costs(track_name: String, using_book: bool) -> Dictionary:
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_progress := int(data.get("required_progress", 45))
	var preparedness := _get_track_preparedness_percent(track_name)
	var difficulty_stress := clampi(int(floor(float(required_progress) / 25.0)), 1, 7)
	var difficulty_energy := clampi(int(floor(float(required_progress) / 35.0)), 1, 5)
	var unprepared_stress := 0
	var unprepared_energy := 0

	# Advanced tracks punish blind spamming more than early tracks.
	if preparedness < 25:
		unprepared_stress = clampi(int(floor(float(required_progress) / 45.0)), 0, 5)
		unprepared_energy = clampi(int(floor(float(required_progress) / 75.0)), 0, 3)
	elif preparedness < 50:
		unprepared_stress = clampi(int(floor(float(required_progress) / 60.0)), 0, 3)
		unprepared_energy = clampi(int(floor(float(required_progress) / 100.0)), 0, 2)
	elif preparedness < 75:
		unprepared_stress = 1

	var base_energy := BOOK_ENERGY_COST if using_book else LEARN_ENERGY_COST
	var base_stress := BOOK_STRESS_GAIN if using_book else LEARN_STRESS_GAIN
	return {
		"energy": base_energy + difficulty_energy + unprepared_energy,
		"stress": base_stress + difficulty_stress + unprepared_stress,
		"preparedness": preparedness
	}


func _apply_stat_change_dictionary(changes: Dictionary) -> void:
	for stat_name in changes.keys():
		var key := str(stat_name)
		if key == "progress" or key == "school_progress" or key == "energy" or key == "food" or key == "stress":
			continue
		var amount := int(changes.get(key, 0))
		if amount == 0:
			continue
		var current_value := int(GameState.get(key))
		GameState.set(key, clampi(current_value + amount, 0, 999))


func _on_learn_pressed() -> void:
	if _exam_active:
		_show("Finish the exam first.")
		return
	if GameState.has_credential(_selected_track):
		_show("You already earned %s." % _selected_track)
		return
	var costs: Dictionary = _get_school_action_costs(_selected_track, false)
	var energy_cost := int(costs.get("energy", LEARN_ENERGY_COST))
	var stress_gain := int(costs.get("stress", LEARN_STRESS_GAIN))
	var preparedness := int(costs.get("preparedness", 100))
	if not GameState.can_perform_action(energy_cost):
		_show("You are too tired to learn. Need at least %d Energy." % energy_cost)
		return
	AudioManager.play_study()
	var fact_data: Dictionary = _choose_unlearned_fact(_selected_track)
	var progress_maxed := _is_track_progress_maxed(_selected_track)
	var stat_changes: Dictionary = _get_learn_stat_changes(_selected_track)
	var progress_text := ""
	if progress_maxed:
		progress_text = "Progress is already maxed, so Learn trained the normal track stats without extra progress."
	else:
		stat_changes["progress"] = 1
		GameState.add_school_progress(_selected_track, 1)
		progress_text = "Progress +1 | track stats trained"
	GameState.mark_school_fact_learned(_selected_track, str(fact_data.get("id", "")))
	var food_loss: int = GameState.get_food_loss_for_minutes(SCHOOL_ACTION_MINUTES)
	stat_changes["energy"] = -energy_cost
	stat_changes["food"] = -food_loss
	stat_changes["stress"] = stress_gain
	_apply_stat_change_dictionary(stat_changes)
	GameState.energy = clampi(GameState.energy - energy_cost, 0, GameState.get_max_energy())
	GameState.stress = clampi(GameState.stress + stress_gain, 0, 100)
	GameState.advance_time(SCHOOL_ACTION_MINUTES)
	var short_text := GameState.format_stat_changes_short(stat_changes, true, 5)
	var full_text := GameState.format_stat_changes_full(stat_changes)
	_last_hud_message = "Learn: %s" % short_text
	GameState.add_log("Learn (%s): %s. %s. Took 3 hours. Preparedness %d%%. Fact: %s" % [_selected_track, full_text, progress_text, preparedness, str(fact_data.get("fact", ""))], "school")
	_show("Learned: %s\n%s\n%s\nTook 3 hours. Preparedness: %d%%." % [str(fact_data.get("fact", "")), full_text, progress_text, preparedness])
	_emit_completed()
	_refresh_all()


func _on_read_book_pressed() -> void:
	if _exam_active:
		_show("Finish the exam first.")
		return
	var already_earned := GameState.has_credential(_selected_track)
	var costs: Dictionary = _get_school_action_costs(_selected_track, true)
	var energy_cost := int(costs.get("energy", BOOK_ENERGY_COST))
	var stress_gain := int(costs.get("stress", BOOK_STRESS_GAIN))
	var preparedness := int(costs.get("preparedness", 100))
	if not GameState.can_perform_action(energy_cost):
		_show("You are too tired to read. Need at least %d Energy." % energy_cost)
		return
	AudioManager.play_study()
	var book_id: String = _choose_best_book_for_track(_selected_track)
	if book_id == "":
		_show("You do not own a profession-specific book for this track. Buy the matching book from the Super Market first.")
		return
	var book_name: String = str(GameState.get_inventory_item_definition(book_id).get("name", book_id))
	if not GameState.remove_inventory_item(book_id, 1):
		_show("You do not own %s anymore." % book_name)
		return
	var fact_data: Dictionary = _choose_unlearned_fact(_selected_track)
	var progress_maxed := _is_track_progress_maxed(_selected_track)
	var stat_changes: Dictionary = {}
	if GameState.has_method("get_book_study_stat_effects"):
		stat_changes = GameState.get_book_study_stat_effects(book_id)
	if stat_changes.is_empty():
		stat_changes = _get_learn_stat_changes(_selected_track)
	var progress_text := ""
	if already_earned:
		stat_changes = _add_bonus_to_each_school_stat(stat_changes, 1)
		progress_text = "Credential already earned, so Read Book trained the book stats without adding progress."
	elif progress_maxed:
		stat_changes = _add_bonus_to_each_school_stat(stat_changes, 1)
		progress_text = "Progress is already maxed, so Read Book added +1 extra to each book stat."
	else:
		stat_changes["progress"] = 3
		GameState.add_school_progress(_selected_track, 3)
		progress_text = "Progress +3 | book stats trained"
	GameState.mark_school_fact_learned(_selected_track, str(fact_data.get("id", "")))
	var food_loss: int = GameState.get_food_loss_for_minutes(SCHOOL_ACTION_MINUTES)
	stat_changes["energy"] = -energy_cost
	stat_changes["food"] = -food_loss
	stat_changes["stress"] = stress_gain
	_apply_stat_change_dictionary(stat_changes)
	GameState.energy = clampi(GameState.energy - energy_cost, 0, GameState.get_max_energy())
	GameState.stress = clampi(GameState.stress + stress_gain, 0, 100)
	GameState.advance_time(SCHOOL_ACTION_MINUTES)
	var short_text := GameState.format_stat_changes_short(stat_changes, true, 6)
	var full_text := GameState.format_stat_changes_full(stat_changes)
	_last_hud_message = "Book: %s" % short_text
	GameState.add_log("Read %s (%s): %s. %s. Consumed 1 book. Took 3 hours. Preparedness %d%%." % [book_name, _selected_track, full_text, progress_text, preparedness], "school")
	_show("Read %s. Learned: %s\n%s\n%s\nConsumed 1 book and took 3 hours. Preparedness: %d%%." % [book_name, str(fact_data.get("fact", "")), full_text, progress_text, preparedness])
	_emit_completed()
	_refresh_all()


func _on_take_exam_pressed() -> void:
	if _exam_active:
		_show("Exam already in progress. Answer the question below.")
		return

	AudioManager.play_study()

	if GameState.has_credential(_selected_track):
		_show("You already earned %s." % _selected_track)
		return

	var overlearn_result := _apply_learn_too_much_if_needed(_selected_track)
	var overlearn_message := str(overlearn_result.get("message", ""))

	if not _meets_exam_requirements(_selected_track):
		var missing_text := _build_missing_requirements_text(_selected_track)
		if overlearn_message != "":
			_show("%s\n\n%s" % [overlearn_message, missing_text])
		else:
			_show(missing_text)
		_refresh_all()
		return

	_start_exam(_selected_track, overlearn_message)


func _start_exam(track_name: String, opening_message: String = "") -> void:
	var data: Dictionary = TRACKS.get(track_name, {})
	var facts: Array = data.get("facts", [])
	_exam_questions.clear()

	for fact in facts:
		if typeof(fact) == TYPE_DICTIONARY:
			_exam_questions.append((fact as Dictionary).duplicate(true))

	_exam_questions.shuffle()
	while _exam_questions.size() > 3:
		_exam_questions.pop_back()

	_exam_index = 0
	_exam_correct = 0
	_exam_active = true
	var start_message := "Exam started for %s. Pass with %d / 3 correct." % [track_name, PASSING_SCORE]
	if opening_message != "":
		start_message = "%s\n\n%s" % [opening_message, start_message]
	_show(start_message)
	_refresh_exam_controls()


func _on_answer_selected(answer_index: int) -> void:
	if not _exam_active or _exam_index >= _exam_questions.size():
		return

	AudioManager.play_ui_click()

	var question: Dictionary = _exam_questions[_exam_index]
	var correct_index: int = int(question.get("correct", -1))

	if answer_index == correct_index:
		_exam_correct += 1
		_exam_result_label.text = "Correct."
	else:
		var answers: Array = question.get("answers", [])
		var correct_text := "Unknown"
		if correct_index >= 0 and correct_index < answers.size():
			correct_text = str(answers[correct_index])
		_exam_result_label.text = "Incorrect. Correct answer: %s" % correct_text

	_exam_index += 1

	if _exam_index >= _exam_questions.size():
		_finish_exam()
	else:
		_refresh_exam_controls()


func _finish_exam() -> void:
	_exam_active = false
	for button in _answer_buttons:
		button.visible = false
		button.disabled = true
	var food_loss: int = GameState.get_food_loss_for_minutes(120)
	GameState.energy = clampi(GameState.energy - 15, 0, 100)
	GameState.stress = clampi(GameState.stress + 8, 0, 100)
	GameState.advance_time(120)
	var exam_changes := {"energy": -15, "food": -food_loss, "stress": 8}
	if _exam_correct >= PASSING_SCORE:
		GameState.add_credential(_selected_track)
		GameState.add_log("Passed %s exam: score %d / 3. Credential earned." % [_selected_track, _exam_correct], "school")
		_last_hud_message = "Exam: %s earned" % _selected_track
		_show("Passed! Score: %d / 3. Earned %s." % [_exam_correct, _selected_track])
		_exam_result_label.text = "Passed! The credential was added to your inventory."
	else:
		GameState.add_log("Failed %s exam: score %d / 3." % [_selected_track, _exam_correct], "school")
		_last_hud_message = "Exam: failed %d/3" % _exam_correct
		_show("Failed. Score: %d / 3. Learn more facts and try again.\n%s" % [_exam_correct, GameState.format_stat_changes_full(exam_changes)])
		_exam_result_label.text = "Failed. You can study more and retake the exam."
	_emit_completed()
	_refresh_all()

func _choose_unlearned_fact(track_name: String) -> Dictionary:
	var data: Dictionary = TRACKS.get(track_name, {})
	var facts: Array = data.get("facts", [])
	var unlearned: Array[Dictionary] = []

	for fact in facts:
		if typeof(fact) != TYPE_DICTIONARY:
			continue

		var fact_id: String = str((fact as Dictionary).get("id", ""))
		if not GameState.has_learned_school_fact(track_name, fact_id):
			unlearned.append((fact as Dictionary).duplicate(true))

	if not unlearned.is_empty():
		return unlearned.pick_random()

	if not facts.is_empty() and typeof(facts[0]) == TYPE_DICTIONARY:
		return (facts.pick_random() as Dictionary).duplicate(true)

	return {}


func _get_learn_stat_changes(track_name: String) -> Dictionary:
	match track_name:
		"Sales Certificate":
			return {"charisma": 1, "confidence": 1}
		"Teaching Credential":
			return {"education": 1, "intelligence": 1, "charisma": 1, "discipline": 1}
		"Programming Certificate":
			return {"education": 1, "intelligence": 1, "discipline": 1, "confidence": 1}
		"Nursing License":
			return {"education": 1, "intelligence": 1, "endurance": 1, "discipline": 1}
		"Engineering Degree":
			return {"education": 1, "intelligence": 1, "discipline": 1, "confidence": 1}
		"Advanced Degree":
			return {"education": 2, "intelligence": 2, "charisma": 1, "discipline": 1}
		"Medical Degree":
			return {"education": 2, "intelligence": 2, "endurance": 2, "discipline": 2}
		_:
			return _get_required_stat_changes(track_name, 1)


func _add_bonus_to_each_school_stat(source: Dictionary, bonus: int) -> Dictionary:
	var result: Dictionary = {}
	for stat_name in source.keys():
		var key := str(stat_name)
		if key == "" or key == "progress" or key == "school_progress" or key == "energy" or key == "food" or key == "stress":
			continue
		var amount := int(source.get(key, 0))
		if amount <= 0:
			continue
		result[key] = amount + bonus
	return result


func _get_required_progress(track_name: String) -> int:
	var data: Dictionary = TRACKS.get(track_name, {})
	return maxi(1, int(data.get("required_progress", 1)))


func _get_track_overprogress(track_name: String) -> int:
	var current_progress := GameState.get_school_progress(track_name)
	var required_progress := _get_required_progress(track_name)
	return maxi(0, current_progress - required_progress)


func _get_first_recommended_book(track_name: String) -> String:
	var data: Dictionary = TRACKS.get(track_name, {})
	var books: Array = data.get("recommended_books", [])
	for book_id in books:
		var id_text := str(book_id)
		if id_text == "" or id_text == "study_guide":
			continue
		var definition: Dictionary = GameState.get_inventory_item_definition(id_text)
		if bool(definition.get("retired", false)):
			continue
		return id_text
	return ""


func _get_overprogress_bonus_stat_changes(track_name: String) -> Dictionary:
	var book_id := _get_first_recommended_book(track_name)
	var stat_changes: Dictionary = {}
	if book_id != "" and GameState.has_method("get_book_study_stat_effects"):
		stat_changes = GameState.get_book_study_stat_effects(book_id)
	if stat_changes.is_empty():
		stat_changes = _get_learn_stat_changes(track_name)
	return _add_bonus_to_each_school_stat(stat_changes, 1)


func _apply_learn_too_much_if_needed(track_name: String) -> Dictionary:
	var overflow_progress := _get_track_overprogress(track_name)
	if overflow_progress <= 0:
		return {"applied": false, "message": ""}

	var required_progress := _get_required_progress(track_name)
	var stat_changes := _get_overprogress_bonus_stat_changes(track_name)
	if stat_changes.is_empty():
		stat_changes = _get_required_stat_changes(track_name, 1)

	_apply_stat_change_dictionary(stat_changes)
	if GameState.has_method("set_school_progress"):
		GameState.set_school_progress(track_name, required_progress)
	else:
		# Fallback for safety if an older GameState is accidentally loaded.
		var progress_data: Dictionary = GameState.flags.get("school_progress", {})
		var entry: Dictionary = progress_data.get(track_name, {"progress": 0, "learned_facts": []})
		entry["progress"] = required_progress
		progress_data[track_name] = entry
		GameState.flags["school_progress"] = progress_data

	var unlocked_now := not bool(GameState.flags.get("achievement_learn_too_much", false))
	GameState.flags["achievement_learn_too_much"] = true
	GameState.flags["learn_too_much_total_uses"] = int(GameState.flags.get("learn_too_much_total_uses", 0)) + 1
	GameState.flags["last_learn_too_much_track"] = track_name
	GameState.flags["last_learn_too_much_overflow"] = overflow_progress

	var short_text := GameState.format_stat_changes_short(stat_changes, true, 6)
	var full_text := GameState.format_stat_changes_full(stat_changes)
	_last_hud_message = "Learn Too Much: %s" % short_text
	GameState.add_log("Learn Too Much! %s had +%d extra progress. Converted overflow into %s, then capped progress at %d/%d." % [track_name, overflow_progress, full_text, required_progress, required_progress], "school")

	var unlock_text := "Achievement unlocked: Learn Too Much!" if unlocked_now else "Learn Too Much activated again."
	return {
		"applied": true,
		"unlocked_now": unlocked_now,
		"message": "%s\nYour extra Progress +%d became a hidden book-like study bonus: %s. Progress is now capped at %d/%d." % [unlock_text, overflow_progress, full_text, required_progress, required_progress]
	}


func _get_required_stat_changes(track_name: String, amount_per_stat: int) -> Dictionary:
	var changes: Dictionary = {}
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_stats: Dictionary = data.get("required_stats", {})

	for stat_name in required_stats.keys():
		var key := str(stat_name)
		if key == "" or amount_per_stat <= 0:
			continue
		changes[key] = amount_per_stat

	return changes


func _merge_stat_changes_max(target: Dictionary, source: Dictionary) -> void:
	for stat_name in source.keys():
		var key := str(stat_name)
		if key == "" or key == "progress" or key == "school_progress" or key == "energy" or key == "food" or key == "stress":
			continue
		var amount := int(source.get(key, 0))
		if amount <= 0:
			continue
		target[key] = maxi(int(target.get(key, 0)), amount)


func _get_fact_stat_changes(fact_data: Dictionary, multiplier: int) -> Dictionary:
	var changes: Dictionary = {}
	for stat_name in ["education", "intelligence", "discipline", "endurance", "charisma", "fitness", "confidence", "strength"]:
		var amount: int = int(fact_data.get(stat_name, 0)) * multiplier
		if amount > 0:
			changes[stat_name] = amount
	return changes

func _is_track_progress_maxed(track_name: String) -> bool:
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_progress := int(data.get("required_progress", 1))
	return GameState.get_school_progress(track_name) >= required_progress


func _get_track_stat_pool(track_name: String) -> Array[String]:
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_stats: Dictionary = data.get("required_stats", {})
	var pool: Array[String] = []
	for stat_name in required_stats.keys():
		pool.append(str(stat_name))
	if pool.is_empty():
		pool = ["education", "intelligence", "discipline"]
	return pool


func _get_random_track_stat_changes(track_name: String, amount: int) -> Dictionary:
	var changes: Dictionary = {}
	var pool := _get_track_stat_pool(track_name)
	for i in range(maxi(1, amount)):
		var stat_name := str(pool[randi_range(0, pool.size() - 1)])
		changes[stat_name] = int(changes.get(stat_name, 0)) + 1
	return changes


func get_last_hud_message() -> String:
	return _last_hud_message


func _apply_fact_stats(fact_data: Dictionary, multiplier: int) -> void:
	for stat_name in ["education", "intelligence", "discipline", "endurance", "charisma", "fitness", "confidence", "strength"]:
		var amount: int = int(fact_data.get(stat_name, 0)) * multiplier
		if amount <= 0:
			continue

		var current_value: int = int(GameState.get(stat_name))
		GameState.set(stat_name, clampi(current_value + amount, 0, 999))


func _get_owned_useful_book_count(track_name: String) -> int:
	var data: Dictionary = TRACKS.get(track_name, {})
	var books: Array = data.get("recommended_books", [])
	var seen: Dictionary = {}
	var count := 0

	for book_id in books:
		var id_text := str(book_id)
		var definition: Dictionary = GameState.get_inventory_item_definition(id_text)
		if id_text == "" or id_text == "study_guide" or bool(definition.get("retired", false)) or seen.has(id_text):
			continue
		seen[id_text] = true
		count += GameState.get_inventory_quantity(id_text)

	return count

func _choose_best_book_for_track(track_name: String) -> String:
	var data: Dictionary = TRACKS.get(track_name, {})
	var books: Array = data.get("recommended_books", [])

	for book_id in books:
		var id_text := str(book_id)
		var definition: Dictionary = GameState.get_inventory_item_definition(id_text)
		if id_text == "study_guide" or bool(definition.get("retired", false)):
			continue
		if GameState.get_inventory_quantity(id_text) > 0:
			return id_text

	return ""


func _build_recommended_book_text(track_name: String) -> String:
	var data: Dictionary = TRACKS.get(track_name, {})
	var books: Array = data.get("recommended_books", [])
	var parts: Array[String] = []

	for book_id in books:
		var id_text := str(book_id)
		var definition: Dictionary = GameState.get_inventory_item_definition(id_text)
		if id_text == "study_guide" or bool(definition.get("retired", false)):
			continue
		var owned: int = GameState.get_inventory_quantity(id_text)
		parts.append("%s x%d" % [str(definition.get("name", id_text)), owned])

	if parts.is_empty():
		return "Profession-specific books only"

	return ", ".join(parts)


func _build_requirement_text(track_name: String) -> String:
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_stats: Dictionary = data.get("required_stats", {})
	var parts: Array[String] = []

	for stat_name in required_stats.keys():
		var needed: int = int(required_stats[stat_name])
		var current_value: int = int(GameState.get(str(stat_name)))
		parts.append("%s %d/%d" % [String(stat_name).capitalize(), current_value, needed])

	var progress: int = GameState.get_school_progress(track_name)
	var needed_progress: int = int(data.get("required_progress", 1))
	parts.append("Progress %d/%d" % [progress, needed_progress])

	return ", ".join(parts)


func _build_missing_requirements_text(track_name: String) -> String:
	var data: Dictionary = TRACKS.get(track_name, {})
	var missing: Array[String] = []
	var required_stats: Dictionary = data.get("required_stats", {})

	for stat_name in required_stats.keys():
		var needed: int = int(required_stats[stat_name])
		var current_value: int = int(GameState.get(str(stat_name)))
		if current_value < needed:
			missing.append("%s %d/%d" % [String(stat_name).capitalize(), current_value, needed])

	var progress: int = GameState.get_school_progress(track_name)
	var needed_progress: int = int(data.get("required_progress", 1))
	if progress < needed_progress:
		missing.append("Progress %d/%d" % [progress, needed_progress])

	if missing.is_empty():
		return "You are ready for the exam."

	return "Not ready for %s exam yet. Missing: %s" % [track_name, ", ".join(missing)]


func _meets_exam_requirements(track_name: String) -> bool:
	var data: Dictionary = TRACKS.get(track_name, {})
	var required_stats: Dictionary = data.get("required_stats", {})

	for stat_name in required_stats.keys():
		var needed: int = int(required_stats[stat_name])
		var current_value: int = int(GameState.get(str(stat_name)))
		if current_value < needed:
			return false

	var progress: int = GameState.get_school_progress(track_name)
	var needed_progress: int = int(data.get("required_progress", 1))
	return progress >= needed_progress


func _show(text: String) -> void:
	description_label.text = text


func _emit_completed() -> void:
	emit_signal("school_action_completed")

