extends Node2D
class_name ArrowConnector

# 配置参数
@export var target_node: CanvasItem : set = set_target_node
@export var curve_color := Color("#4a90e2")
@export var line_width := 2.0
@export var arrow_size := 12.0
@export var max_curve_height := 100.0  # 最大曲线高度
@export var min_curve_height := 30.0   # 最小曲线高度
@export var start_offset: Vector2 = Vector2.ZERO
@export var end_offset: Vector2 = Vector2.ZERO
@export var curve_smoothness := 0.5  # 曲线平滑度 (0.0-1.0)
@export var arrow_head_ratio := 0.7  # 箭头头部比例 (0.5-1.0)

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
	
	# 绘制曲线
	draw_polyline(points, curve_color, line_width, true)
	
	# 绘制箭头
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
	var direction = (end - start).normalized()
	var distance = start.distance_to(end)
	
	# 自适应曲线高度 - 基于距离
	var height_factor = clamp(distance / 300.0, 0.1, 1.0)
	var curve_height = lerp(min_curve_height, max_curve_height, height_factor)
	
	# 修正：双控制点创建真正的S形曲线
	# 第一个控制点在垂直方向上方，第二个在下方
	var perpendicular = direction.rotated(PI/2)
	var control_point1 = start + direction * (distance * 0.3 * curve_smoothness) + perpendicular * curve_height
	var control_point2 = end - direction * (distance * 0.3 * curve_smoothness) - perpendicular * curve_height
	
	var points = PackedVector2Array()
	
	# 动态采样点数量 - 基于距离
	var steps = max(10, int(distance / 10))
	
	for i in steps + 1:
		var t = i / float(steps)
		var point = _cubic_bezier(start, control_point1, control_point2, end, t)
		points.append(to_local(point))
	
	return points

# 三次贝塞尔曲线计算
func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	
	var p = uuu * p0 # (1-t)^3 * P0
	p += 3 * uu * t * p1 # 3*(1-t)^2*t * P1
	p += 3 * u * tt * p2 # 3*(1-t)*t^2 * P2
	p += ttt * p3 # t^3 * P3
	
	return p

func _draw_arrow(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	
	var tip = points[-1]
	var base_index = max(0, points.size() - 2)
	var direction = (tip - points[base_index]).normalized()
	
	# 箭头大小
	var base = tip - direction * arrow_size
	
	# 箭头形状参数化
	var wing_length = arrow_size * arrow_head_ratio
	var wing_width = arrow_size * 0.4
	
	var left_wing = base + direction.rotated(PI/2) * wing_width
	var right_wing = base + direction.rotated(-PI/2) * wing_width
	var left_tip = tip + direction.rotated(PI/2) * wing_width - direction * wing_length
	var right_tip = tip + direction.rotated(-PI/2) * wing_width - direction * wing_length
	
	# 绘制箭头主体
	draw_colored_polygon(PackedVector2Array([base, left_wing, left_tip, tip, right_tip, right_wing]), curve_color)
	
	# 添加箭头中线
	draw_line(base, tip, curve_color.darkened(0.1), line_width * 0.7)

func _connect_target_signals():
	if _current_target.has_signal("tree_exiting"):
		_current_target.connect("tree_exiting", _on_target_exiting)
	
	if _current_target is Control:
		(_current_target as Control).connect("resized", _on_target_moved)
	elif _current_target is Node2D:
		_current_target.connect("transform_changed", _on_target_moved)

func _disconnect_target_signals():
	if not is_instance_valid(_current_target):
		return
	
	if _current_target.has_signal("tree_exiting") and _current_target.is_connected("tree_exiting", _on_target_exiting):
		_current_target.disconnect("tree_exiting", _on_target_exiting)
	
	if _current_target is Control && (_current_target as Control).is_connected("resized", _on_target_moved):
		(_current_target as Control).disconnect("resized", _on_target_moved)
	elif _current_target is Node2D && _current_target.is_connected("transform_changed", _on_target_moved):
		_current_target.disconnect("transform_changed", _on_target_moved)

func _on_target_exiting():
	set_target_node(null)

func _on_target_moved():
	queue_redraw()
