extends Node2D
class_name ArrowConnector

# 配置参数
@export var target_node: CanvasItem : set = set_target_node
@export var curve_color := Color("#4a90e2")
@export var line_width := 2.0
@export var arrow_size := 12.0
@export var curve_height := 80.0
@export var start_offset: Vector2 = Vector2.ZERO
@export var end_offset: Vector2 = Vector2.ZERO

# 私有变量
var _current_target: CanvasItem = null

func set_target_node(value: CanvasItem) -> void:
	if _current_target != null:
		_disconnect_target_signals()
	
	_current_target = value
	target_node = value
	
	if _current_target != null:
		_connect_target_signals()
	
	queue_redraw()

func _ready():
	z_index = 100
	set_process(true)

func _process(_delta):
	queue_redraw()

func _draw():
	if not _should_draw():
		return
	
	var start = _get_origin_position() + start_offset
	var end = _get_target_position() + end_offset
	var points = _calculate_bezier_curve(start, end)
	
	draw_polyline(points, curve_color, line_width, true)
	_draw_arrow(points)

func _should_draw() -> bool:
	return is_instance_valid(_current_target) && _current_target.is_inside_tree()

func _get_origin_position() -> Vector2:
	return global_position

func _get_target_position() -> Vector2:
	if _current_target is Control:
		return (_current_target as Control).get_global_rect().get_center()
	elif _current_target is Node2D:
		return _current_target.global_position
	return Vector2.ZERO

func _calculate_bezier_curve(start: Vector2, end: Vector2) -> PackedVector2Array:
	var control_point = (start + end) / 2 + (end - start).rotated(PI/2).normalized() * curve_height
	var points = PackedVector2Array()
	
	for t in 20:
		var ratio = t / 20.0
		var point = start.bezier_interpolate(
			control_point,
			control_point,
			end,
			ratio
		)
		points.append(to_local(point))
	
	return points

func _draw_arrow(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	
	var tip = points[-1]
	var direction = (tip - points[-2]).normalized()
	var base = tip - direction * arrow_size
	
	var left = base + direction.rotated(PI/2) * arrow_size/2
	var right = base + direction.rotated(-PI/2) * arrow_size/2
	
	draw_colored_polygon(PackedVector2Array([left, tip, right]), curve_color)

func _connect_target_signals():
	if _current_target.has_signal("tree_exiting"):
		_current_target.connect("tree_exiting", _on_target_exiting)
	
	if _current_target is Control:
		(_current_target as Control).connect("resized", _on_target_moved)
	elif _current_target is Node2D:
		_current_target.connect("transform_changed", _on_target_moved)

func _disconnect_target_signals():
	if _current_target.has_signal("tree_exiting"):
		_current_target.disconnect("tree_exiting", _on_target_exiting)
	
	if _current_target is Control && (_current_target as Control).is_connected("resized", _on_target_moved):
		(_current_target as Control).disconnect("resized", _on_target_moved)
	elif _current_target is Node2D && _current_target.is_connected("transform_changed", _on_target_moved):
		_current_target.disconnect("transform_changed", _on_target_moved)

func _on_target_exiting():
	set_target_node(null)

func _on_target_moved():
	queue_redraw()
