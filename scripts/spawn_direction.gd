@tool
extends Line2D
class_name ClockLine

## 箭头长度
const length: int = 36

## 角度制的左右方向箭头
@export var left_direction: float = 90.0 : set = set_left_direction
@export var right_direction: float = 0.0 : set = set_right_direction

func set_left_direction(value: float) -> void:
	left_direction = value
	var point_zero: Vector2 = Vector2(length, 0).rotated(deg_to_rad(left_direction))
	var self_points: PackedVector2Array = points.duplicate()
	self_points.set(0, point_zero)
	points = self_points

func set_right_direction(value: float) -> void:
	right_direction = value
	var point_two: Vector2 = Vector2(length, 0).rotated(deg_to_rad(right_direction))
	var self_points: PackedVector2Array = points.duplicate()
	self_points.set(2, point_two)
	points = self_points
