extends Node

const HOME_SCENE_PATH := "res://scenes/HomeScene.tscn"
const MAIN_MENU_PATH := "res://scenes/MainMenu.tscn"

const MAP_SCENE_PATH := "res://scenes/MapScene.tscn"
const CAR_SHOP_SCENE_PATH := "res://scenes/CarShopScene.tscn"
const BURGER_MINIGAME_SCENE_PATH := "res://scenes/BurgerMinigameScene.tscn"
const GYM_SCENE_PATH := "res://scenes/GymScene.tscn"
const OFFICE_SCENE_PATH := "res://scenes/OfficeScene.tscn"
const CLINIC_SCENE_PATH := "res://scenes/ClinicScene.tscn"
const CASINO_SCENE_PATH := "res://scenes/CasinoScene.tscn"
const PHONE_SCENE_PATH := "res://scenes/PhoneScene.tscn"

const LOGS_PANEL_PATH := "res://scenes/LogsPanel.tscn"
const NOTIFICATION_TOAST_PATH := "res://scenes/NotificationToast.tscn"
const WORK_RESULTS_PANEL_PATH := "res://scenes/WorkResultsPanel.tscn"
const JOB_PROMOTION_PANEL_PATH := "res://scenes/JobPromotionPanel.tscn"
const TRAVEL_CONFIRM_PANEL_PATH := "res://scenes/TravelConfirmPanel.tscn"
const JOB_BOARD_SCENE_PATH := "res://scenes/JobBoardScene.tscn"
const INVENTORY_PANEL_PATH := "res://scenes/InventoryPanel.tscn"
const TUTORIAL_PANEL_PATH := "res://scenes/TutorialPanel.tscn"
const REINCARNATION_PANEL_PATH := "res://scenes/ReincarnationPanel.tscn"
const HEALTH_WARNING_PANEL_PATH := "res://scenes/HealthWarningPanel.tscn"

const UI_FONT_PATH := "res://assets/fonts/fonts.ttf"

@onready var root_background: ColorRect = $RootBackground
@onready var location_container: Node = $LocationContainer
@onready var hud = $UILayer/HUD
@onready var stats_panel = $UILayer/StatsPanel
@onready var ui_layer: CanvasLayer = $UILayer
@onready var autosave_timer: Timer = $AutosaveTimer

var current_location_node: Node = null

var logs_panel: Control = null
var notification_toast: Control = null
var work_results_panel: Control = null
var job_promotion_panel: Control = null
var travel_confirm_panel: Control = null
var inventory_panel: Control = null
var tutorial_panel: Control = null
var reincarnation_panel: Control = null
var health_warning_panel: Control = null

var pending_travel_callback: Callable = Callable()
var location_before_map: String = "home"
var location_before_phone: String = "home"

func _ready() -> void:
	if SettingsData != null:
		SettingsData.load_settings()
		if SettingsData.has_signal("settings_changed") and not SettingsData.settings_changed.is_connected(_on_settings_changed):
			SettingsData.settings_changed.connect(_on_settings_changed)

	_connect_hud()
	_setup_runtime_panels()
	_load_starting_state()
	_load_current_location_scene()
	_refresh_ui()
	_refresh_logs_panel()

	autosave_timer.timeout.connect(_on_autosave_timer_timeout)
	autosave_timer.start()

	call_deferred("_maybe_show_start_tutorial")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if _critical_modal_is_open():
			_bring_critical_panels_to_front()
			return

		if event.keycode == KEY_L:
			_toggle_logs_panel()

		if event.keycode == KEY_I:
			_toggle_inventory_panel()

func _on_inventory_pressed() -> void:
	_toggle_inventory_panel()


func _toggle_inventory_panel() -> void:
	if inventory_panel == null:
		return

	if inventory_panel.visible:
		inventory_panel.visible = false
	else:
		_open_inventory_panel()


func _open_inventory_panel() -> void:
	if inventory_panel == null:
		return

	if inventory_panel.has_method("open_inventory"):
		inventory_panel.open_inventory()
	else:
		if inventory_panel.has_method("refresh"):
			inventory_panel.refresh()
		inventory_panel.visible = true
	_bring_ui_panel_to_front(inventory_panel)

	_set_message("Viewing inventory.")
	
func _connect_hud() -> void:
	if hud == null:
		return

	_connect_hud_signal("home_pressed", "_on_home_pressed")
	_connect_hud_signal("map_pressed", "_on_map_pressed")
	_connect_hud_signal("jobs_pressed", "_on_jobs_pressed")
	_connect_hud_signal("hints_pressed", "_on_hints_pressed")
	_connect_hud_signal("inventory_pressed", "_on_inventory_pressed")
	_connect_hud_signal("stats_pressed", "_on_stats_pressed")
	_connect_hud_signal("logs_pressed", "_on_logs_pressed")
	_connect_hud_signal("save_pressed", "_on_save_pressed")
	_connect_hud_signal("menu_pressed", "_on_menu_pressed")
	_connect_hud_signal("goal_skip_pressed", "_on_goal_skip_pressed")

	# Backward compatibility if an older HUD scene/script is accidentally loaded.
	_connect_hud_signal("work_pressed", "_on_work_pressed")
	_connect_hud_signal("gym_pressed", "_on_gym_pressed")


func _connect_hud_signal(signal_name: String, method_name: String) -> void:
	if hud == null or not hud.has_signal(signal_name):
		return

	var callback := Callable(self, method_name)
	if not hud.is_connected(signal_name, callback):
		hud.connect(signal_name, callback)

func _on_logs_pressed() -> void:
	_open_logs_panel()
	
func _setup_runtime_panels() -> void:
	logs_panel = _instance_ui_scene(LOGS_PANEL_PATH, "LogsPanelRuntime")
	notification_toast = _instance_ui_scene(NOTIFICATION_TOAST_PATH, "NotificationToastRuntime")
	work_results_panel = _instance_ui_scene(WORK_RESULTS_PANEL_PATH, "WorkResultsPanelRuntime")
	job_promotion_panel = _instance_ui_scene(JOB_PROMOTION_PANEL_PATH, "JobPromotionPanelRuntime")
	travel_confirm_panel = _instance_ui_scene(TRAVEL_CONFIRM_PANEL_PATH, "TravelConfirmPanelRuntime")
	inventory_panel = _instance_ui_scene(INVENTORY_PANEL_PATH, "InventoryPanelRuntime")
	tutorial_panel = _instance_ui_scene(TUTORIAL_PANEL_PATH, "TutorialPanelRuntime")
	reincarnation_panel = _instance_ui_scene(REINCARNATION_PANEL_PATH, "ReincarnationPanelRuntime")
	health_warning_panel = _instance_ui_scene(HEALTH_WARNING_PANEL_PATH, "HealthWarningPanelRuntime")

	_wire_logs_panel()
	_wire_notification_toast()
	_wire_work_results_panel()
	_wire_job_promotion_panel()
	_wire_travel_confirm_panel()
	_wire_inventory_panel()
	_wire_tutorial_panel()
	_wire_reincarnation_panel()
	_wire_health_warning_panel()
	_wire_stats_panel()
	_apply_visual_settings()



func _wire_stats_panel() -> void:
	if stats_panel == null:
		return
	if stats_panel.has_signal("reincarnation_requested") and not stats_panel.is_connected("reincarnation_requested", Callable(self, "_open_reincarnation_panel")):
		stats_panel.connect("reincarnation_requested", Callable(self, "_open_reincarnation_panel"))


func _wire_reincarnation_panel() -> void:
	if reincarnation_panel == null:
		return
	if reincarnation_panel.has_signal("reincarnation_cancelled"):
		reincarnation_panel.connect("reincarnation_cancelled", Callable(self, "_on_reincarnation_cancelled"))
	if reincarnation_panel.has_signal("reincarnation_completed"):
		reincarnation_panel.connect("reincarnation_completed", Callable(self, "_on_reincarnation_completed"))



func _wire_health_warning_panel() -> void:
	if health_warning_panel == null:
		return
	if health_warning_panel.has_signal("warning_closed"):
		health_warning_panel.connect("warning_closed", Callable(self, "_on_health_warning_closed"))


func _on_health_warning_closed() -> void:
	if health_warning_panel != null:
		health_warning_panel.visible = false
	_refresh_ui()
	_set_message("Low health warning closed. Visit the Clinic soon.")


func _open_health_warning_panel(alert: Dictionary) -> void:
	if health_warning_panel == null:
		_set_message(str(alert.get("hud_message", "Critical Health.")))
		return

	if health_warning_panel.has_method("open_warning"):
		health_warning_panel.call("open_warning", alert)
	else:
		health_warning_panel.visible = true

	_bring_ui_panel_to_front(health_warning_panel)
	call_deferred("_bring_health_warning_to_front")


func _open_reincarnation_panel() -> void:
	if reincarnation_panel == null:
		_set_message("Reincarnation panel is not available.")
		return
	if stats_panel.visible and stats_panel.has_method("close_panel"):
		stats_panel.close_panel()
	if reincarnation_panel.has_method("open_panel"):
		reincarnation_panel.open_panel()
	else:
		reincarnation_panel.visible = true
	_bring_ui_panel_to_front(reincarnation_panel)
	call_deferred("_bring_reincarnation_to_front")
	_set_message("Review your legacy before reincarnating.")


func _on_reincarnation_cancelled() -> void:
	if reincarnation_panel != null:
		reincarnation_panel.visible = false
	_set_message("Reincarnation cancelled.")


func _on_reincarnation_completed(result: Dictionary = {}) -> void:
	_go_direct_to_location("home", str(result.get("welcome", "Welcome back.")))
	_refresh_ui()
	_refresh_logs_panel()
	var save_result := SaveManager.save_current_game()
	if not bool(save_result.get("success", false)):
		_show_toast("Save Failed", "Reincarnation worked, but autosave failed.", "!")
	else:
		_show_toast("Reincarnated", str(result.get("toast_message", "A new life begins.")), "☁")

func _wire_tutorial_panel() -> void:
	if tutorial_panel == null:
		return

	if tutorial_panel.has_signal("tutorial_closed"):
		tutorial_panel.connect("tutorial_closed", Callable(self, "_on_tutorial_closed"))


func _maybe_show_start_tutorial() -> void:
	if tutorial_panel == null:
		return

	if SettingsData != null and not SettingsData.show_tutorial_on_new_game:
		return

	if bool(GameState.flags.get("tutorial_completed", false)):
		return

	# Avoid interrupting older saves. New saves start on Day 1 at Home.
	if GameState.day > 1:
		return

	if GameState.current_location != "home":
		return

	_open_tutorial_panel()


func _open_tutorial_panel() -> void:
	if tutorial_panel == null:
		return

	if tutorial_panel.has_method("open_tutorial"):
		tutorial_panel.open_tutorial()
	else:
		tutorial_panel.visible = true

	_set_message("Tutorial opened. Learn the core life-sim loop.")


func _on_tutorial_closed(completed: bool = true) -> void:
	if completed:
		GameState.flags["tutorial_completed"] = true
		if GameState.slot_id > 0:
			SaveManager.save_current_game()

	_refresh_ui()
	_set_message("Tutorial complete. Explore Home, Map, Store, School, Jobs, and Inventory.")

func _wire_inventory_panel() -> void:
	if inventory_panel == null:
		return

	var close_button := inventory_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleRow/CloseButton")

	if close_button is Button:
		close_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			inventory_panel.visible = false
		)

	if inventory_panel.has_signal("inventory_action_completed"):
		inventory_panel.connect("inventory_action_completed", Callable(self, "_on_inventory_action_completed"))

func _instance_ui_scene(scene_path: String, new_name: String) -> Control:
	var packed := load(scene_path)
	if packed == null or not (packed is PackedScene):
		return null

	var node := (packed as PackedScene).instantiate()
	if node == null or not (node is Control):
		return null

	node.name = new_name
	node.visible = false
	ui_layer.add_child(node)
	return node as Control



func _bring_ui_panel_to_front(panel: Control) -> void:
	if panel == null or panel.get_parent() == null:
		return
	panel.get_parent().move_child(panel, panel.get_parent().get_child_count() - 1)


func _bring_health_warning_to_front() -> void:
	if health_warning_panel != null and health_warning_panel.visible:
		_bring_ui_panel_to_front(health_warning_panel)


func _bring_reincarnation_to_front() -> void:
	if reincarnation_panel != null and reincarnation_panel.visible:
		_bring_ui_panel_to_front(reincarnation_panel)


func _bring_critical_panels_to_front() -> void:
	_bring_health_warning_to_front()
	_bring_reincarnation_to_front()


func _critical_modal_is_open() -> bool:
	if reincarnation_panel != null and reincarnation_panel.visible:
		return true
	if health_warning_panel != null and health_warning_panel.visible:
		return true
	return false


func _health_warning_blocks_action() -> bool:
	if health_warning_panel != null and health_warning_panel.visible:
		_bring_health_warning_to_front()
		_set_message("Close the low-health warning before continuing.")
		return true
	return false


func _wire_logs_panel() -> void:
	if logs_panel == null:
		return

	var close_button := logs_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/TitleRow/CloseButton")
	var week_button := logs_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ControlsPanel/ControlsMargin/ControlsRow/WeekOptionButton")

	if close_button is Button:
		close_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			logs_panel.visible = false
		)

	if week_button is OptionButton:
		week_button.item_selected.connect(func(_index: int) -> void:
			AudioManager.play_ui_click()
			_refresh_logs_panel()
		)


func _wire_notification_toast() -> void:
	if notification_toast == null:
		return

	var timer := notification_toast.get_node_or_null("LifetimeTimer")
	if timer is Timer:
		timer.timeout.connect(func() -> void:
			notification_toast.visible = false
		)


func _wire_work_results_panel() -> void:
	if work_results_panel == null:
		return

	var work_again_button := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/BottomRow/WorkAgainButton")
	var close_button := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/BottomRow/CloseButton")
	var open_logs_button := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/BottomRow/OpenLogsButton")

	if work_again_button is Button:
		work_again_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			work_results_panel.visible = false
			_on_work_pressed()
		)

	if close_button is Button:
		close_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			work_results_panel.visible = false
		)

	if open_logs_button is Button:
		open_logs_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			work_results_panel.visible = false
			_open_logs_panel()
		)


func _wire_job_promotion_panel() -> void:
	if job_promotion_panel == null:
		return

	var continue_button := job_promotion_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ContinueButton")
	if continue_button is Button:
		continue_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			job_promotion_panel.visible = false
		)


func _wire_travel_confirm_panel() -> void:
	if travel_confirm_panel == null:
		return

	var cancel_button := travel_confirm_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/CancelButton")
	var travel_button := travel_confirm_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ButtonRow/TravelButton")

	if cancel_button is Button:
		cancel_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			travel_confirm_panel.visible = false
			pending_travel_callback = Callable()
		)

	if travel_button is Button:
		travel_button.pressed.connect(func() -> void:
			AudioManager.play_ui_click()
			travel_confirm_panel.visible = false

			if pending_travel_callback.is_valid():
				var callback := pending_travel_callback
				pending_travel_callback = Callable()
				callback.call()
		)


func _clear_travel_request() -> void:
	pending_travel_callback = Callable()

	if travel_confirm_panel != null:
		travel_confirm_panel.visible = false


func _current_location_blocks_travel(_destination_name: String) -> bool:
	if current_location_node == null:
		return false

	if not current_location_node.has_method("can_leave_location"):
		return false

	var can_leave: bool = bool(current_location_node.call("can_leave_location"))
	if can_leave:
		return false

	var message_text := "Finish the current action before traveling."
	if current_location_node.has_method("get_leave_block_message"):
		message_text = str(current_location_node.call("get_leave_block_message"))

	_set_message(message_text)
	_show_toast("Travel Blocked", message_text, "!")
	return true


func _go_direct_to_location(location_id: String, message_text: String = "") -> void:
	_clear_travel_request()

	# Opening the map is navigation, not travel. Remember where the player came from
	# so choosing that same location on the map does not charge time or money.
	if location_id == "map" and GameState.current_location != "map":
		location_before_map = GameState.current_location

	GameState.go_to_location(location_id)
	_load_current_location_scene()
	_refresh_ui()
	_refresh_logs_panel()

	if message_text != "":
		_set_message(message_text)


func _load_starting_state() -> void:
	if SaveManager.pending_load_slot_id > 0:
		var slot_id := SaveManager.pending_load_slot_id
		SaveManager.clear_pending_load_slot()

		var result := SaveManager.load_into_game_state(slot_id)
		if not result.success:
			GameState.create_new_game(1)
			_set_message("Failed to load save. Started fallback game.")
			_show_toast("Load Failed", "Started fallback game.", "!")
			return

		_set_message("Loaded %s." % GameState.save_name)
		_show_toast("Loaded", GameState.save_name, "✓")
		return

	if GameState.slot_id <= 0:
		GameState.create_new_game(1)
		_set_message("Started fallback game.")
		_show_toast("New Game", "Started fallback game.", "+")


func _on_settings_changed() -> void:
	_apply_visual_settings()


func _load_current_location_scene() -> void:
	_clear_travel_request()

	if current_location_node != null:
		current_location_node.queue_free()
		current_location_node = null

	var scene_path := _get_scene_path_for_location(GameState.current_location)
	var packed: PackedScene = load(scene_path)

	if packed == null:
		push_error("Could not load location scene: %s" % scene_path)
		return

	current_location_node = packed.instantiate()
	location_container.add_child(current_location_node)
	_fit_location_scene_to_container()
	_wire_current_location_scene()
	_apply_visual_settings()

func _fit_location_scene_to_container() -> void:
	if current_location_node == null:
		return

	if current_location_node is Control:
		var control := current_location_node as Control
		control.set_anchors_preset(Control.PRESET_FULL_RECT)
		control.offset_left = 0
		control.offset_top = 0
		control.offset_right = 0
		control.offset_bottom = 0
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _apply_visual_settings() -> void:
	var dim_enabled := false
	if SettingsData != null:
		dim_enabled = SettingsData.dim_mode_enabled

	if root_background != null:
		# Fills the HUD-safe bands above/below the location scene.
		# Bright mode = cyan/daytime. Dim mode = dark blue/night.
		root_background.color = Color(0.04, 0.08, 0.14, 1.0) if dim_enabled else Color(0.45, 0.68, 0.90, 1.0)

	if current_location_node is CanvasItem:
		var location_item := current_location_node as CanvasItem
		location_item.modulate = Color(0.72, 0.78, 0.88, 1.0) if dim_enabled else Color(1, 1, 1, 1)

	_apply_dim_backgrounds(ui_layer, dim_enabled)
	_apply_dim_backgrounds(location_container, dim_enabled)


func _apply_dim_backgrounds(root: Node, dim_enabled: bool) -> void:
	if root == null:
		return

	for child in root.get_children():
		if child is ColorRect:
			var rect := child as ColorRect
			match rect.name:
				"DimBackground":
					rect.color = Color(0.01, 0.03, 0.07, 0.62) if dim_enabled else Color(0.12, 0.46, 0.70, 0.18)
				"Dim":
					rect.color = Color(0.01, 0.03, 0.07, 0.46) if dim_enabled else Color(0.55, 0.85, 1.00, 0.08)
				"GradientGlow", "SkyGlow", "GoldGlow":
					if dim_enabled:
						rect.color = Color(0.02, 0.05, 0.10, 0.18)
		_apply_dim_backgrounds(child, dim_enabled)


func _wire_current_location_scene() -> void:
	if current_location_node == null:
		return

	if current_location_node.has_signal("sleep_selected"):
		current_location_node.connect("sleep_selected", Callable(self, "_on_sleep_pressed"))

	if current_location_node.has_signal("workout_selected"):
		current_location_node.connect("workout_selected", Callable(self, "_on_gym_pressed"))

	if current_location_node.has_signal("work_selected"):
		current_location_node.connect("work_selected", Callable(self, "_on_work_pressed"))

	if current_location_node.has_signal("study_selected"):
		current_location_node.connect("study_selected", Callable(self, "_on_study_pressed"))

	if current_location_node.has_signal("phone_selected"):
		current_location_node.connect("phone_selected", Callable(self, "_on_home_phone_selected"))

	if current_location_node.has_signal("car_selected"):
		current_location_node.connect("car_selected", Callable(self, "_on_home_car_selected"))

	if current_location_node.has_signal("go_home"):
		current_location_node.connect("go_home", Callable(self, "_map_go_home"))

	if current_location_node.has_signal("go_office"):
		current_location_node.connect("go_office", Callable(self, "_map_go_office"))

	if current_location_node.has_signal("go_gym"):
		current_location_node.connect("go_gym", Callable(self, "_map_go_gym"))

	if current_location_node.has_signal("go_fast_food"):
		current_location_node.connect("go_fast_food", Callable(self, "_map_go_fast_food"))

	if current_location_node.has_signal("go_store"):
		current_location_node.connect("go_store", Callable(self, "_map_go_store"))

	if current_location_node.has_signal("go_bank"):
		current_location_node.connect("go_bank", Callable(self, "_map_go_bank"))

	if current_location_node.has_signal("go_school"):
		current_location_node.connect("go_school", Callable(self, "_map_go_school"))

	if current_location_node.has_signal("go_car_shop"):
		current_location_node.connect("go_car_shop", Callable(self, "_map_go_car_shop"))

	if current_location_node.has_signal("go_clinic"):
		current_location_node.connect("go_clinic", Callable(self, "_map_go_clinic"))

	if current_location_node.has_signal("go_casino"):
		current_location_node.connect("go_casino", Callable(self, "_map_go_casino"))

	if current_location_node.has_signal("school_action_completed"):
		current_location_node.connect("school_action_completed", Callable(self, "_on_school_action_completed"))

	if current_location_node.has_signal("store_action_completed"):
		current_location_node.connect("store_action_completed", Callable(self, "_on_store_action_completed"))

	if current_location_node.has_signal("bank_action_completed"):
		current_location_node.connect("bank_action_completed", Callable(self, "_on_bank_action_completed"))

	if current_location_node.has_signal("car_shop_action_completed"):
		current_location_node.connect("car_shop_action_completed", Callable(self, "_on_car_shop_action_completed"))

	if current_location_node.has_signal("clinic_action_completed"):
		current_location_node.connect("clinic_action_completed", Callable(self, "_on_clinic_action_completed"))

	if current_location_node.has_signal("casino_action_completed"):
		current_location_node.connect("casino_action_completed", Callable(self, "_on_casino_action_completed"))

	if current_location_node.has_signal("phone_action_completed"):
		current_location_node.connect("phone_action_completed", Callable(self, "_on_phone_action_completed"))

	if current_location_node.has_signal("open_phone_requested"):
		current_location_node.connect("open_phone_requested", Callable(self, "_on_open_phone_requested"))

	if current_location_node.has_signal("start_burger_shift"):
		current_location_node.connect("start_burger_shift", Callable(self, "_on_fast_food_start_burger_shift"))

	if current_location_node.has_signal("quick_work_pressed"):
		current_location_node.connect("quick_work_pressed", Callable(self, "_perform_work_shift"))

	if current_location_node.has_signal("work_shift_pressed"):
		current_location_node.connect("work_shift_pressed", Callable(self, "_perform_work_shift"))

	if current_location_node.has_signal("gym_workout_pressed"):
		current_location_node.connect("gym_workout_pressed", Callable(self, "_perform_gym_workout"))

	if current_location_node.has_signal("gym_trainer_pressed"):
		current_location_node.connect("gym_trainer_pressed", Callable(self, "_perform_gym_trainer_workout"))

	if current_location_node.has_signal("burger_minigame_action_completed"):
		current_location_node.connect("burger_minigame_action_completed", Callable(self, "_on_burger_minigame_action_completed"))

	if current_location_node.has_signal("burger_minigame_no_more_pressed"):
		current_location_node.connect("burger_minigame_no_more_pressed", Callable(self, "_on_burger_minigame_no_more_pressed"))

	if current_location_node.has_signal("back_pressed"):
		current_location_node.connect("back_pressed", Callable(self, "_on_location_back_pressed"))

func _on_school_action_completed() -> void:
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("get_last_hud_message"):
		var message_text: String = str(current_location_node.get_last_hud_message())
		if message_text != "":
			_set_message(message_text)


func _on_store_action_completed(result: Dictionary = {}) -> void:
	_refresh_ui()
	_refresh_logs_panel()
	var message_text: String = str(result.get("hud_message", result.get("message", "Store updated.")))
	if message_text != "":
		_set_message(message_text)


func _on_inventory_action_completed(result: Dictionary = {}) -> void:
	if str(result.get("action", "")) == "go_to_school":
		if inventory_panel != null:
			inventory_panel.visible = false
		_refresh_ui()
		_refresh_logs_panel()
		var school_message_text: String = str(result.get("hud_message", result.get("message", "Study at School.")))
		if school_message_text != "":
			_set_message(school_message_text)
		_on_study_pressed()
		return

	_refresh_ui()
	_refresh_logs_panel()
	if inventory_panel != null and inventory_panel.has_method("refresh"):
		inventory_panel.refresh()
	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()
	var message_text: String = str(result.get("hud_message", result.get("message", "Inventory updated.")))
	if message_text != "":
		_set_message(message_text)


func _on_bank_action_completed() -> void:
	_refresh_ui()
	_refresh_logs_panel()


func _on_car_shop_action_completed(result: Dictionary = {}) -> void:
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	var message_text: String = str(result.get("hud_message", result.get("message", "Car shop updated.")))
	if message_text != "":
		_set_message(message_text)


func _on_clinic_action_completed(result: Dictionary = {}) -> void:
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	var message_text: String = str(result.get("hud_message", result.get("message", "Clinic updated.")))
	if message_text != "":
		_set_message(message_text)

	_show_toast("Clinic", str(result.get("toast_message", result.get("message", "Clinic action complete."))), "❤️")



func _on_casino_action_completed(result: Dictionary = {}) -> void:
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	var message_text: String = str(result.get("hud_message", result.get("message", "Casino updated.")))
	if message_text != "":
		_set_message(message_text)

	_show_toast("Casino", str(result.get("toast_message", result.get("message", "Casino action complete."))), "♠")


func _on_phone_action_completed(result: Dictionary = {}) -> void:
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	var message_text: String = str(result.get("hud_message", result.get("message", "Phone updated.")))
	if message_text != "":
		_set_message(message_text)

	_show_toast("Phone", str(result.get("toast_message", result.get("message", "Phone action complete."))), "☎")

func _on_fast_food_start_burger_shift() -> void:
	_go_direct_to_location("burger_minigame", "Burger shift started.")
	_show_toast("Burger Town", "Build the burger in order.", "🍔")


func _on_burger_minigame_action_completed(result: Dictionary = {}) -> void:
	_refresh_ui()
	_refresh_logs_panel()

	var message_text: String = str(result.get("hud_message", result.get("message", "Burger shift updated.")))
	if message_text != "":
		_set_message(message_text)

	_show_toast("Burger Town", str(result.get("toast_message", result.get("message", "Burger shift complete."))), "🍔")

	var promotion: Dictionary = result.get("promotion", {})
	if bool(promotion.get("success", false)):
		_show_job_promotion(promotion)


func _on_burger_minigame_no_more_pressed() -> void:
	_go_direct_to_location("fast_food", "Returned to Burger Town.")


func _on_location_back_pressed() -> void:
	if GameState.current_location == "phone":
		var return_location := location_before_phone
		if return_location == "" or return_location == "phone":
			return_location = "home"
		_go_direct_to_location(return_location, "Returned from Phone.")
		return

	_go_direct_to_location("map", "Returned to the map.")


func _on_open_phone_requested(job_id: String = "") -> void:
	if _life_state_blocks_action():
		return

	location_before_phone = GameState.current_location

	var contact_name := "Employer"
	if job_id != "" and GameState.has_method("get_job_employer_contact"):
		var contact: Dictionary = GameState.get_job_employer_contact(job_id)
		contact_name = str(contact.get("name", "Employer"))
		if GameState.has_method("discover_job_employer_contact"):
			GameState.discover_job_employer_contact(job_id, true)

	_go_direct_to_location("phone", "Opened Phone contacts for %s." % contact_name)
	_show_toast("Phone", "Use Converse, Praise, or Ask Advice to build the relationship.", "☎")


func _on_home_phone_selected() -> void:
	if _life_state_blocks_action():
		return

	location_before_phone = GameState.current_location
	_go_direct_to_location("phone", "Opened Phone contacts.")
	_show_toast("Phone", "Build employer relationships and networking bonuses.", "☎")


func _on_home_car_selected() -> void:
	if _life_state_blocks_action():
		return

	# Opening the map is navigation, not travel. Destination buttons on the map still use car time/cost.
	_go_direct_to_location("map", "Opened the map. Choose a destination to travel.")
	_show_toast("Map", "Map opened. Travel only happens after choosing a destination.", "🗺")


func _request_travel_to(destination_id: String, destination_name: String, travel_effect_text: String = "") -> void:
	if _life_state_blocks_action():
		return

	if destination_id == GameState.current_location:
		_clear_travel_request()
		_set_message("You are already at %s." % destination_name)
		return

	if GameState.current_location == "map" and destination_id == location_before_map:
		_clear_travel_request()
		_go_direct_to_location(destination_id, "Returned to %s. No travel time needed." % destination_name)
		return

	_clear_travel_request()

	if _current_location_blocks_travel(destination_name):
		return

	var travel_minutes: int = GameState.get_current_car_travel_minutes()
	var travel_cost: int = GameState.get_current_car_travel_cost()
	var car_name: String = GameState.get_current_car_name()
	var effect_text := travel_effect_text

	if effect_text.strip_edges() != "":
		effect_text += "\n"

	effect_text += "Vehicle: %s | %s" % [car_name, GameState.get_current_car_bonus_text()]

	_show_travel_confirm(
		"Travel to %s?" % destination_name,
		"Travel Time: %d minutes" % travel_minutes,
		"Travel Cost: $%d" % travel_cost,
		effect_text,
		func() -> void:
			AudioManager.play_travel(str(GameState.current_car_id) == "electric_car")
			var result: Dictionary = GameState.perform_travel(destination_id, destination_name)
			if not bool(result.get("success", false)):
				_refresh_ui()
				_set_message(str(result.get("hud_message", "Travel failed.")))
				_show_toast("Travel Failed", str(result.get("message", "Could not travel.")), "!")
				return

			location_before_map = destination_id
			_load_current_location_scene()
			_refresh_ui()
			_refresh_logs_panel()
			_set_message(str(result.get("hud_message", "Traveled.")))
			_show_toast("Travel", str(result.get("toast_message", destination_name)), "→")
	)


func _map_go_home():
	_request_travel_to("home", "Home", "Return home to rest, sleep, and plan your next action.")

func _map_go_office():
	_request_travel_to("office", "Office", "Go to work, complete a shift, earn money, and gain job EXP.")

func _map_go_gym():
	_request_travel_to("gym", "Gym", "Go to the gym, then choose a workout once you arrive.")

func _map_go_fast_food():
	_request_travel_to("fast_food", "Burger Town", "Go to Burger Town for work and food-related systems.")

func _map_go_store():
	_request_travel_to("store", "Super Market", "Visit the store to buy food, books, and useful items.")

func _map_go_bank():
	_request_travel_to("bank", "Bank", "Go to the bank to manage savings and daily interest.")

func _map_go_school():
	_request_travel_to("school", "School", "Go to school to learn, read books, and earn credentials.")

func _map_go_car_shop():
	_request_travel_to("car_shop", "Car Shop", "Browse cars, buy vehicles, and equip your current car.")

func _map_go_clinic():
	_request_travel_to("clinic", "Clinic", "Recover health, get a checkup, or receive treatment.")

func _map_go_casino():
	_request_travel_to("casino", "Casino", "Play blackjack or slots. Gambling is optional and risky.")

func _get_scene_path_for_location(location_id: String) -> String:
	match location_id:
		"home":
			return HOME_SCENE_PATH
		"map":
			return MAP_SCENE_PATH
		"car_shop":
			return CAR_SHOP_SCENE_PATH
		"fast_food":
			return "res://scenes/FastFoodScene.tscn"
		"burger_minigame":
			return BURGER_MINIGAME_SCENE_PATH
		"gym":
			return GYM_SCENE_PATH
		"office":
			return OFFICE_SCENE_PATH
		"clinic":
			return CLINIC_SCENE_PATH
		"casino":
			return CASINO_SCENE_PATH
		"phone":
			return PHONE_SCENE_PATH
		"job_board":
			return JOB_BOARD_SCENE_PATH
		"store":
			return "res://scenes/StoreScene.tscn"
		"bank":
			return "res://scenes/BankPanel.tscn"
		"school":
			return "res://scenes/SchoolScene.tscn"
		_:
			return HOME_SCENE_PATH


func _refresh_ui() -> void:
	_apply_visual_settings()
	if hud != null:
		hud.refresh()
		if hud.has_method("set_goal_text") and GameState.has_method("get_current_goal_text"):
			var goals_enabled := true
			if SettingsData != null:
				goals_enabled = SettingsData.goals_milestones_enabled
			hud.call("set_goal_text", GameState.get_current_goal_text(), goals_enabled)

	if stats_panel.has_method("refresh"):
		stats_panel.refresh()

	_evaluate_health_state()


func _evaluate_health_state() -> void:
	if not GameState.has_method("consume_health_alert"):
		return

	var alert: Dictionary = GameState.consume_health_alert()
	if alert.is_empty():
		_bring_critical_panels_to_front()
		return

	if bool(alert.get("death", false)):
		_set_message(str(alert.get("hud_message", "Health 0: Reincarnation required.")))
		_show_toast("Life Ended", str(alert.get("toast_message", "Reincarnate to begin again.")), "☁")
		_open_death_reincarnation_panel()
		return

	if bool(alert.get("low_health", false)):
		_set_message(str(alert.get("hud_message", "Critical Health.")))
		_open_health_warning_panel(alert)


func _life_state_blocks_action() -> bool:
	if GameState.has_method("is_dead") and bool(GameState.is_dead()):
		_evaluate_health_state()
		_set_message("Health is 0. Reincarnate to continue.")
		return true

	if _health_warning_blocks_action():
		return true

	return false


func _open_death_reincarnation_panel() -> void:
	if reincarnation_panel == null:
		return

	if stats_panel.visible and stats_panel.has_method("close_panel"):
		stats_panel.close_panel()

	if inventory_panel != null:
		inventory_panel.visible = false
	if logs_panel != null:
		logs_panel.visible = false
	if work_results_panel != null:
		work_results_panel.visible = false
	if job_promotion_panel != null:
		job_promotion_panel.visible = false
	if travel_confirm_panel != null:
		travel_confirm_panel.visible = false
	if health_warning_panel != null:
		health_warning_panel.visible = false

	if reincarnation_panel.has_method("open_panel"):
		reincarnation_panel.open_panel(true)
	else:
		reincarnation_panel.visible = true
	_bring_ui_panel_to_front(reincarnation_panel)
	call_deferred("_bring_reincarnation_to_front")


func _set_message(text: String) -> void:
	hud.set_message(text)


func _on_goal_skip_pressed() -> void:
	if GameState.has_method("skip_current_goal"):
		var next_goal: Dictionary = GameState.skip_current_goal()
		if hud != null and hud.has_method("set_goal_text"):
			var goals_enabled := true
			if SettingsData != null:
				goals_enabled = SettingsData.goals_milestones_enabled
			hud.call("set_goal_text", str(next_goal.get("text", "Goal skipped.")), goals_enabled)
	_set_message("Skipped milestone. Showing the next goal.")


func _on_home_pressed() -> void:
	if _life_state_blocks_action():
		return

	if GameState.current_location == "home":
		_go_direct_to_location("home", "You are at home.")
		return

	_request_travel_to("home", "Home", "Returning home will move you back to your home scene.")
	

func _on_map_pressed() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	_go_direct_to_location("map", "Opened the map. Choose a destination to travel.")
	_show_toast("Map", "Map opened. Travel only happens after choosing a destination.", "🗺")


func _on_hints_pressed() -> void:
	if _critical_modal_is_open():
		_bring_critical_panels_to_front()
		return

	_open_tutorial_panel()
	if tutorial_panel != null:
		_bring_ui_panel_to_front(tutorial_panel)
	_show_toast("Hints", "Tutorial opened. Review the core systems anytime.", "?")


func _on_work_pressed() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	if GameState.current_location == "office":
		_perform_work_shift()
		return

	_request_travel_to("office", "Office", "Go to work, complete a shift, earn money, and gain job EXP.")


func _perform_work_shift() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	if not GameState.can_perform_action(20):
		_set_message("You are too tired to work.")
		_show_toast("Too Tired", "You are too tired to work.", "!")
		return

	AudioManager.play_work()
	var result: Dictionary = GameState.do_work()
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	var money_earned := int(result.get("money_earned", 0))
	_set_message(str(result.get("hud_message", "Work: +$%d" % money_earned)))
	_show_toast("Work Complete", str(result.get("toast_message", "+$%d earned" % money_earned)), "$")

	_show_work_results(result)

	var promotion: Dictionary = result.get("promotion", {})
	if bool(promotion.get("success", false)):
		_show_job_promotion(promotion)

func _on_jobs_pressed() -> void:
	if _life_state_blocks_action():
		return

	_go_direct_to_location("job_board", "Opened Job Board.")

func _on_study_pressed() -> void:
	if stats_panel.visible:
		return

	if GameState.current_location == "school":
		_set_message("You are already at school.")
		return

	_request_travel_to("school", "School", "Open the school scene to learn facts, read books, and earn credentials.")


func _on_gym_pressed() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	if GameState.current_location == "gym":
		_perform_gym_workout()
		return

	_request_travel_to("gym", "Gym", "Go to the gym, then choose a workout once you arrive.")


func _perform_gym_workout() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	if not GameState.can_perform_action(18):
		_set_message("You are too tired to work out.")
		_show_toast("Too Tired", "You are too tired to work out.", "!")
		return

	AudioManager.play_gym()
	var result: Dictionary = GameState.do_gym()
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	_set_message(str(result.get("hud_message", "Gym complete.")))
	_show_toast("Fitness Improved", str(result.get("toast_message", "Training complete.")), "+")
	_show_simple_result_toast(str(result.get("stat_effects", result.get("headline", "You trained."))))


func _perform_gym_trainer_workout() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	if not GameState.can_perform_action(GameState.GYM_TRAINER_ENERGY_COST):
		_set_message("You are too tired for a trainer session.")
		_show_toast("Too Tired", "You need at least %d Energy for a trainer session." % GameState.GYM_TRAINER_ENERGY_COST, "!")
		return

	if GameState.money < GameState.GYM_TRAINER_COST:
		_set_message("You need $%d for a trainer session." % GameState.GYM_TRAINER_COST)
		_show_toast("Need Money", "Trainer costs $%d." % GameState.GYM_TRAINER_COST, "$")
		return

	AudioManager.play_gym()
	var result: Dictionary = GameState.do_gym_trainer()
	_refresh_ui()
	_refresh_logs_panel()

	if current_location_node != null and current_location_node.has_method("refresh"):
		current_location_node.refresh()

	if not bool(result.get("success", false)):
		var failed_message := str(result.get("message", result.get("hud_message", "Trainer unavailable.")))
		_set_message(failed_message)
		_show_toast("Trainer", failed_message, "!")
		return

	_set_message(str(result.get("hud_message", "Trainer session complete.")))
	_show_toast("Trainer Workout", str(result.get("toast_message", "Training complete.")), "+")
	_show_simple_result_toast(str(result.get("stat_effects", result.get("headline", "You trained with a trainer."))))

func _on_sleep_pressed() -> void:
	if _life_state_blocks_action():
		return

	if stats_panel.visible:
		return

	AudioManager.play_sleep()
	var result: Dictionary = GameState.sleep_to_next_day()
	_go_direct_to_location("home")

	_set_message(str(result.get("hud_message", "Sleep: Energy 100")))
	_show_toast("New Day", str(result.get("toast_message", "Recovered.")), "☾")
	_show_simple_result_toast(str(result.get("stat_effects", result.get("headline", "You slept."))))


func _on_stats_pressed() -> void:
	if _critical_modal_is_open():
		_bring_critical_panels_to_front()
		_set_message("Close the warning panel before opening stats.")
		return

	if stats_panel.has_method("toggle_panel"):
		stats_panel.toggle_panel()

	if stats_panel.visible:
		_set_message("Viewing player stats.")
	else:
		_set_message("Closed stats.")


func _on_save_pressed() -> void:
	var result := SaveManager.save_current_game()
	if result.success:
		_refresh_ui()
		_set_message("Game saved.")
		_show_toast("Saved", "Game saved successfully.", "✓")
	else:
		_set_message("Save failed: %s" % result.error)
		_show_toast("Save Failed", str(result.error), "!")


func _on_menu_pressed() -> void:
	if stats_panel.visible and stats_panel.has_method("close_panel"):
		stats_panel.close_panel()

	var result := SaveManager.save_current_game()
	if result.success:
		SceneTransition.change_scene(MAIN_MENU_PATH)
	else:
		_set_message("Could not return to menu because saving failed.")
		_show_toast("Save Failed", "Could not return to menu.", "!")


func _on_autosave_timer_timeout() -> void:
	if GameState.slot_id <= 0:
		return

	var result := SaveManager.save_current_game()
	if result.success:
		_show_toast("Autosave", "Progress saved.", "✓")


func _show_toast(title: String, message: String, icon_text: String = "") -> void:
	if not SettingsData.show_popup_notifications:
		return

	if notification_toast == null:
		return

	var title_label := notification_toast.get_node_or_null("ToastPanel/ToastMargin/ToastRow/TextColumn/TitleLabel")
	var message_label := notification_toast.get_node_or_null("ToastPanel/ToastMargin/ToastRow/TextColumn/MessageLabel")
	var icon_label := notification_toast.get_node_or_null("ToastPanel/ToastMargin/ToastRow/IconBox/IconLabel")
	var timer := notification_toast.get_node_or_null("LifetimeTimer")

	if title_label is Label:
		title_label.text = title
	if message_label is Label:
		message_label.text = message
	if icon_label is Label:
		icon_label.text = icon_text

	notification_toast.visible = true
	_bring_ui_panel_to_front(notification_toast)

	if timer is Timer:
		timer.stop()
		timer.start()


func _show_work_results(result: Dictionary) -> void:
	if work_results_panel == null:
		return

	var headline_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/HeadlinePanel/HeadlineMargin/HeadlineText")
	var money_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ResultPanel/ResultMargin/ResultColumn/MoneyEarnedLabel")
	var exp_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ResultPanel/ResultMargin/ResultColumn/ExpEarnedLabel")
	var promotion_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ResultPanel/ResultMargin/ResultColumn/PromotionLabel")
	var next_promotion_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ResultPanel/ResultMargin/ResultColumn/NextPromotionLabel")
	var bonus_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ResultPanel/ResultMargin/ResultColumn/BonusLabel")
	var stat_effect_label := work_results_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ResultPanel/ResultMargin/ResultColumn/StatEffectLabel")

	if headline_label is Label:
		headline_label.text = str(result.get("headline", "You completed your shift."))

	if money_label is Label:
		money_label.text = "Money Earned: $%d" % int(result.get("money_earned", 0))

	if exp_label is Label:
		exp_label.text = "EXP Earned: +%d" % int(result.get("exp_earned", 0))

	var promotion: Dictionary = result.get("promotion", {})
	if promotion_label is Label:
		if bool(promotion.get("success", false)):
			promotion_label.text = "Promotion: %s" % str(promotion.get("new_rank", "Promoted"))
		else:
			promotion_label.text = "Promotion: Not promoted"

	if next_promotion_label is Label:
		var current_exp: int = int(result.get("job_exp", 0))
		var next_requirement: int = int(result.get("next_promotion_requirement", 0))

		if next_requirement > 0:
			var remaining: int = max(0, next_requirement - current_exp)

			next_promotion_label.text = "Next Promotion: %d EXP remaining" % remaining

			# OPTIONAL (but highly recommended)
			if exp_label is Label:
				exp_label.text = "EXP: %d / %d (+%d)" % [
					current_exp,
					next_requirement,
					int(result.get("exp_earned", 0))
				]
		else:
			next_promotion_label.text = "Next Promotion: Max rank reached"

	if bonus_label is Label:
		bonus_label.text = "Bonus: Base shift completion"

	if stat_effect_label is Label:
		stat_effect_label.text = str(result.get("stat_effects", ""))


	work_results_panel.visible = true
	_bring_ui_panel_to_front(work_results_panel)
	call_deferred("_bring_critical_panels_to_front")


func _show_job_promotion(promotion: Dictionary) -> void:
	if job_promotion_panel == null:
		return

	var headline_text := job_promotion_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/HeadlinePanel/HeadlineMargin/HeadlineText")
	var old_rank_label := job_promotion_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/OldRankLabel")
	var new_rank_label := job_promotion_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/NewRankLabel")
	var pay_increase_label := job_promotion_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/PayIncreaseLabel")
	var requirement_note_label := job_promotion_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/RequirementNoteLabel")

	var old_rank := str(promotion.get("old_rank", "Unknown"))
	var new_rank := str(promotion.get("new_rank", "Unknown"))
	var old_pay := int(promotion.get("old_pay", 0))
	var new_pay := int(promotion.get("new_pay", 0))

	if headline_text is Label:
		headline_text.text = "You have been promoted from %s to %s!" % [old_rank, new_rank]
	if old_rank_label is Label:
		old_rank_label.text = "Old Rank: %s" % old_rank
	if new_rank_label is Label:
		new_rank_label.text = "New Rank: %s" % new_rank
	if pay_increase_label is Label:
		pay_increase_label.text = "Pay Increase: $%d → $%d" % [old_pay, new_pay]
	if requirement_note_label is Label:
		requirement_note_label.text = "You met the needed performance and stat requirements."

	job_promotion_panel.visible = true
	_bring_ui_panel_to_front(job_promotion_panel)
	call_deferred("_bring_critical_panels_to_front")


func _show_travel_confirm(destination_title: String, travel_time_text: String, travel_cost_text: String, travel_effect_text: String, callback: Callable) -> void:
	if travel_confirm_panel == null:
		if callback.is_valid():
			callback.call()
		return

	var headline_text := travel_confirm_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/HeadlinePanel/HeadlineMargin/HeadlineText")
	var travel_time_label := travel_confirm_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/TravelTimeLabel")
	var travel_cost_label := travel_confirm_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/TravelCostLabel")
	var travel_effect_label := travel_confirm_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/InfoPanel/InfoMargin/InfoColumn/TravelEffectLabel")

	if headline_text is Label:
		headline_text.text = destination_title
	if travel_time_label is Label:
		travel_time_label.text = travel_time_text
	if travel_cost_label is Label:
		travel_cost_label.text = travel_cost_text
	if travel_effect_label is Label:
		travel_effect_label.text = travel_effect_text

	pending_travel_callback = callback
	travel_confirm_panel.visible = true


func _toggle_logs_panel() -> void:
	if logs_panel == null:
		return

	if logs_panel.visible:
		logs_panel.visible = false
	else:
		_open_logs_panel()


func _open_logs_panel() -> void:
	if logs_panel == null:
		return

	_refresh_logs_panel()
	logs_panel.visible = true
	_bring_ui_panel_to_front(logs_panel)
	_set_message("Viewing logs.")


func _refresh_logs_panel() -> void:
	if logs_panel == null:
		return

	var week_button := logs_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ControlsPanel/ControlsMargin/ControlsRow/WeekOptionButton")
	var summary_label := logs_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/ControlsPanel/ControlsMargin/ControlsRow/SummaryLabel")
	var log_content := logs_panel.get_node_or_null("CenterContainer/WindowPanel/WindowMargin/MainColumn/LogPanel/LogMargin/LogScroll/LogContent")

	if not (week_button is OptionButton):
		return
	if not (log_content is VBoxContainer):
		return

	var previously_selected_week: int = week_button.get_selected_id()
	if previously_selected_week <= 0:
		previously_selected_week = GameState.get_max_logged_week()
		if previously_selected_week <= 0:
			previously_selected_week = 1

	var max_week := GameState.get_max_logged_week()

	week_button.clear()
	for week in range(1, max_week + 1):
		week_button.add_item("Week %d" % week, week)

	if week_button.item_count <= 0:
		week_button.add_item("Week 1", 1)

	var selected_index: int = 0
	for i in range(week_button.item_count):
		if week_button.get_item_id(i) == previously_selected_week:
			selected_index = i
			break

	week_button.select(selected_index)

	var selected_week: int = week_button.get_selected_id()
	if selected_week <= 0:
		selected_week = 1

	for child in log_content.get_children():
		child.queue_free()

	var entries := GameState.get_logs_for_week(selected_week)

	var week_label := Label.new()
	week_label.text = "Week: %d" % selected_week
	week_label.add_theme_font_size_override("font_size", 26)
	log_content.add_child(week_label)

	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No logs for this week yet."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		log_content.add_child(empty_label)

		if summary_label is Label:
			summary_label.text = "Entries: 0"
		return

	var current_day: int = -1

	for entry in entries:
		var day_value: int = int(entry.get("day", 1))
		var time_label: String = str(entry.get("time_text", entry.get("time", "Unknown")))
		var message: String = str(entry.get("text", entry.get("message", "")))

		if day_value != current_day:
			current_day = day_value

			var day_header := Label.new()
			day_header.text = "Day %d" % current_day
			day_header.add_theme_font_size_override("font_size", 22)
			log_content.add_child(day_header)

		var entry_label := Label.new()
		entry_label.text = "• [%s] %s" % [time_label, message]
		entry_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		log_content.add_child(entry_label)

	if summary_label is Label:
		summary_label.text = "Entries: %d" % entries.size()


func _show_simple_result_toast(headline: String) -> void:
	_show_toast("Update", headline, "•")
