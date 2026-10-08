@icon("res://Assets/Icons/cursor_icon.png")
class_name BaseCursor
extends Sprite2D

# -------------------------------------------------------------------------------------------------
var _brush_size: int
var _pressure := 1.0
var _last_viewport_position := Vector2.ZERO
var _has_viewport_position := false
static var _diagnostic_motion_count := 0

@onready var _camera: Camera2D = get_viewport().get_node("Camera2D")

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_visible_in_tree():
		_set_position_from_viewport_event(event.position)
		_log_motion_bounded()

# -------------------------------------------------------------------------------------------------
func update_position() -> void:
	_last_viewport_position = get_viewport().get_mouse_position()
	_has_viewport_position = true
	_set_position_from_viewport_event(_last_viewport_position)

func _set_position_from_viewport_event(viewport_position: Vector2) -> void:
	_last_viewport_position = viewport_position
	_has_viewport_position = true
	global_position = _camera.get_canvas_transform().affine_inverse() * viewport_position

func _log_motion_bounded() -> void:
	if _diagnostic_motion_count >= 5:
		return
	_diagnostic_motion_count += 1
	var event_number := _diagnostic_motion_count
	var cursor_path := str(get_path())
	var cursor_visible := is_visible_in_tree()
	var immediate_position := global_position
	print("[CURSOR MOTION %d] path=%s visible=%s immediate=%s" % [
		event_number, cursor_path, str(cursor_visible), str(immediate_position)
	])
	RenderingServer.frame_post_draw.connect(
		_log_deferred_position.bind(event_number, cursor_path, cursor_visible, immediate_position),
		CONNECT_ONE_SHOT
	)

func _log_deferred_position(event_number: int, cursor_path: String, cursor_visible: bool, immediate_position: Vector2) -> void:
	print("[CURSOR MOTION %d DEFERRED] path=%s visible=%s immediate=%s end_of_frame=%s" % [
		event_number, cursor_path, str(cursor_visible), str(immediate_position), str(global_position)
	])

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	_pressure = pressure

# -------------------------------------------------------------------------------------------------
func change_size(value: int) -> void:
	_brush_size = value

# -------------------------------------------------------------------------------------------------
func _on_canvas_position_changed(pos: Vector2) -> void:
	if _has_viewport_position:
		_set_position_from_viewport_event(_last_viewport_position)

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(value: float) -> void:
	pass
