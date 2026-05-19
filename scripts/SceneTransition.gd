extends CanvasLayer

var _fade_rect: ColorRect
var _is_transitioning := false

func _ready() -> void:
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchor_left = 0
	_fade_rect.anchor_top = 0
	_fade_rect.anchor_right = 1
	_fade_rect.anchor_bottom = 1
	_fade_rect.offset_left = 0
	_fade_rect.offset_top = 0
	_fade_rect.offset_right = 0
	_fade_rect.offset_bottom = 0

	# IMPORTANT: don't block clicks
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(_fade_rect)

func change_scene(path: String, fade_out_time := 0.18, fade_in_time := 0.18) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	var t := create_tween()
	t.tween_property(_fade_rect, "color:a", 1.0, fade_out_time)
	t.tween_callback(Callable(get_tree(), "change_scene_to_file").bind(path))
	t.tween_property(_fade_rect, "color:a", 0.0, fade_in_time)
	t.finished.connect(func(): _is_transitioning = false)
	
