extends Control

signal reincarnation_cancelled
signal reincarnation_completed(result: Dictionary)

const TOMB_IMAGE := "res://assets/images/reincarnation/tombstone.png"
const HEAVEN_IMAGE := "res://assets/images/reincarnation/heaven_light.png"

@onready var close_button: Button = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleRow/CloseButton
@onready var tombstone_texture: TextureRect = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/HeroPanel/HeroMargin/HeroRow/TombstoneTexture
@onready var life_summary_label: Label = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/HeroPanel/HeroMargin/HeroRow/SummaryColumn/LifeSummaryLabel
@onready var formula_label: Label = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/HeroPanel/HeroMargin/HeroRow/SummaryColumn/FormulaLabel
@onready var mode_option: OptionButton = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/ModePanel/ModeMargin/ModeColumn/ModeRow/ModeOptionButton
@onready var name_line_edit: LineEdit = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/NamePanel/NameMargin/NameColumn/NameRow/NameLineEdit
@onready var keep_same_check: CheckButton = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/NamePanel/NameMargin/NameColumn/NameRow/KeepSameCheck
@onready var preview_label: Label = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/PreviewPanel/PreviewMargin/PreviewColumn/PreviewLabel
@onready var allocation_panel: PanelContainer = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/AllocationPanel
@onready var allocation_list: VBoxContainer = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/AllocationPanel/AllocationMargin/AllocationColumn/AllocationList
@onready var allocation_status_label: Label = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/MainScroll/ContentColumn/AllocationPanel/AllocationMargin/AllocationColumn/AllocationStatusLabel
@onready var reincarnate_button: Button = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/ReincarnateButton
@onready var cancel_button: Button = $DimBackground/CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/CancelButton
@onready var transition_overlay: Control = $TransitionOverlay
@onready var heaven_texture: TextureRect = $TransitionOverlay/CenterContainer/TransitionPanel/TransitionMargin/TransitionColumn/HeavenTexture
@onready var transition_label: Label = $TransitionOverlay/CenterContainer/TransitionPanel/TransitionMargin/TransitionColumn/TransitionLabel
@onready var result_overlay: Control = $ResultOverlay
@onready var result_title: Label = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ResultTitle
@onready var result_details: Label = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/ResultDetails
@onready var begin_button: Button = $ResultOverlay/CenterContainer/ResultPanel/ResultMargin/ResultColumn/BeginButton

var _font: Font = preload("res://assets/fonts/fonts.ttf")
var _summary: Dictionary = {}
var _allocation_spinboxes: Dictionary = {}
var _syncing_allocation: bool = false
var _death_mode: bool = false

func _ready() -> void:
	visible = false
	transition_overlay.visible = false
	result_overlay.visible = false

	close_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		if _death_mode:
			return
		emit_signal("reincarnation_cancelled")
	)

	cancel_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		if _death_mode:
			return
		emit_signal("reincarnation_cancelled")
	)

	begin_button.pressed.connect(func() -> void:
		AudioManager.play_ui_click()
		_death_mode = false
		visible = false
	)

	reincarnate_button.pressed.connect(func() -> void:
		_start_reincarnation()
	)

	mode_option.item_selected.connect(func(_index: int) -> void:
		AudioManager.play_ui_click()
		_refresh_preview()
	)

	keep_same_check.toggled.connect(func(pressed: bool) -> void:
		AudioManager.play_ui_click()
		name_line_edit.editable = not pressed
		if pressed:
			name_line_edit.text = str(_summary.get("player_name", "Bobby"))
	)

	_load_optional_textures()


func open_panel(force_reincarnation: bool = false) -> void:
	_death_mode = force_reincarnation
	_summary = GameState.get_reincarnation_summary()
	visible = true
	transition_overlay.visible = false
	result_overlay.visible = false
	keep_same_check.button_pressed = true
	name_line_edit.text = str(_summary.get("player_name", "Bobby"))
	name_line_edit.editable = false
	mode_option.select(0)
	close_button.visible = not _death_mode
	cancel_button.visible = not _death_mode
	close_button.disabled = _death_mode
	cancel_button.disabled = _death_mode
	_rebuild_allocation_controls()
	_refresh_preview()


func _load_optional_textures() -> void:
	if ResourceLoader.exists(TOMB_IMAGE):
		var tomb := load(TOMB_IMAGE)
		if tomb is Texture2D:
			tombstone_texture.texture = tomb
	if ResourceLoader.exists(HEAVEN_IMAGE):
		var heaven := load(HEAVEN_IMAGE)
		if heaven is Texture2D:
			heaven_texture.texture = heaven


func _refresh_preview() -> void:
	var player_name := str(_summary.get("player_name", "Bobby"))
	life_summary_label.text = "Here lies %s\nDays lived: %d\nNet worth: $%d\nTotal skill points: %d\nPast lives: %d" % [
		player_name,
		int(_summary.get("days_lived", 0)),
		int(_summary.get("net_worth", 0)),
		int(_summary.get("total_skill_points", 0)),
		int(_summary.get("past_lives_count", 0))
	]

	formula_label.text = "Balanced keeps %.2f%% of every skill.\nCustom allocation uses %.2f%% of total old skill points with %.2f%% max into one stat.\nWealth starts helping above $10,000 and is divided by days lived." % [
		float(_summary.get("balanced_rate", 0.05)) * 100.0,
		float(_summary.get("allocation_rate", 0.0)) * 100.0,
		float(_summary.get("single_stat_cap_rate", 0.0)) * 100.0
	]

	var custom := _is_custom_mode()
	allocation_panel.visible = custom
	if custom:
		_refresh_allocation_status()
		preview_label.text = _build_custom_preview_text()
	else:
		preview_label.text = _build_balanced_preview_text()


func _is_custom_mode() -> bool:
	return mode_option.selected == 1


func _build_balanced_preview_text() -> String:
	var old_stats: Dictionary = _summary.get("old_stats", {})
	var preview: Dictionary = _summary.get("balanced_preview", {})
	var lines: Array[String] = ["Balanced Inheritance Preview"]
	for key in GameState.get_skill_stat_keys():
		lines.append("%s: %d -> %d" % [GameState.get_stat_display_name(key), int(old_stats.get(key, 0)), int(preview.get(key, 0))])
	return "\n".join(lines)


func _build_custom_preview_text() -> String:
	var old_stats: Dictionary = _summary.get("old_stats", {})
	var allocation := _get_custom_allocation()
	var lines: Array[String] = ["Custom Allocation Preview"]
	for key in GameState.get_skill_stat_keys():
		lines.append("%s: %d -> %d" % [GameState.get_stat_display_name(key), int(old_stats.get(key, 0)), int(allocation.get(key, 0))])
	return "\n".join(lines)


func _rebuild_allocation_controls() -> void:
	_allocation_spinboxes.clear()
	for child in allocation_list.get_children():
		child.queue_free()

	var cap := int(_summary.get("single_stat_cap", 0))
	for key in GameState.get_skill_stat_keys():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		allocation_list.add_child(row)

		var label := Label.new()
		label.text = GameState.get_stat_display_name(key)
		label.custom_minimum_size = Vector2(150, 0)
		label.add_theme_font_override("font", _font)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 1))
		row.add_child(label)

		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = cap
		spin.step = 1
		spin.value = 0
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spin.add_theme_font_override("font", _font)
		spin.add_theme_font_size_override("font_size", 16)
		row.add_child(spin)
		_allocation_spinboxes[key] = spin

		spin.value_changed.connect(func(_value: float) -> void:
			_on_allocation_changed(key)
		)

	_refresh_allocation_status()


func _on_allocation_changed(changed_key: String) -> void:
	if _syncing_allocation:
		return

	var pool := int(_summary.get("allocation_pool", 0))
	var total := _get_allocated_total()
	if total > pool:
		var spin: SpinBox = _allocation_spinboxes.get(changed_key, null)
		if spin != null:
			_syncing_allocation = true
			spin.value = maxi(0, int(spin.value) - (total - pool))
			_syncing_allocation = false

	_refresh_preview()


func _get_allocated_total() -> int:
	var total := 0
	for key in _allocation_spinboxes.keys():
		var spin: SpinBox = _allocation_spinboxes[key]
		total += int(spin.value)
	return total


func _get_custom_allocation() -> Dictionary:
	var result := {}
	for key in GameState.get_skill_stat_keys():
		var spin: SpinBox = _allocation_spinboxes.get(key, null)
		result[key] = int(spin.value) if spin != null else 0
	return result


func _refresh_allocation_status() -> void:
	var pool := int(_summary.get("allocation_pool", 0))
	var cap := int(_summary.get("single_stat_cap", 0))
	var used := _get_allocated_total()
	allocation_status_label.text = "Pool: %d / %d used | Per-stat cap: %d" % [used, pool, cap]


func _start_reincarnation() -> void:
	reincarnate_button.disabled = true
	cancel_button.disabled = true
	close_button.disabled = true
	transition_label.text = "Your old life fades away..."
	transition_overlay.visible = true
	if AudioManager.has_method("play_reincarnation"):
		AudioManager.play_reincarnation()
	else:
		AudioManager.play_ui_click()

	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree():
		return

	var final_name := name_line_edit.text.strip_edges()
	if keep_same_check.button_pressed:
		final_name = str(_summary.get("player_name", "Bobby"))

	var mode := "custom" if _is_custom_mode() else "balanced"
	var allocation := _get_custom_allocation() if mode == "custom" else {}
	var result := GameState.perform_reincarnation(mode, final_name, allocation)

	transition_overlay.visible = false
	result_overlay.visible = true
	result_title.text = str(result.get("welcome", "Welcome back."))	
	result_details.text = _build_result_details(result)

	reincarnate_button.disabled = false
	cancel_button.disabled = _death_mode
	close_button.disabled = _death_mode
	emit_signal("reincarnation_completed", result)


func _build_result_details(result: Dictionary) -> String:
	var inherited: Dictionary = result.get("inherited_stats", {})
	var lines: Array[String] = ["Inherited stats from the previous life:"]
	for key in GameState.get_skill_stat_keys():
		var value := int(inherited.get(key, 0))
		if value > 0:
			lines.append("%s +%d" % [GameState.get_stat_display_name(key), value])
	if lines.size() == 1:
		lines.append("No skill points were inherited yet. Build more wealth faster next life.")
	return "\n".join(lines)