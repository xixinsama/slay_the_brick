@tool
extends Node
class_name P2CP ## 将多边形赋予碰撞箱

@export var polygon: Polygon2D
@export var collision: CollisionPolygon2D
@export var enable: bool = true: ## 编辑器里查看
	set(value):
		re_shape()
@export var map: Array[PackedVector2Array]

func re_shape() -> void:
	if polygon and collision:
		collision.polygon = polygon.polygon

## 设置地图
func setup_map() -> void:
	if polygon:
		for i in range(map.size()):
			# 添加碰撞
			if i == 0:
				collision.polygon = map[i]
				polygon.polygon = map[i]
			else:
				var new_poly := Polygon2D.new()
				get_parent().add_child(new_poly)
				new_poly.polygon = map[i]
				var new_colli := CollisionPolygon2D.new()
				get_parent().add_child(new_colli)
				new_colli.polygon = map[i]
