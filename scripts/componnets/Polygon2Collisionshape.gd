@tool
extends Node
class_name P2CP ## 将多边形赋予碰撞箱

@export var polygon: Polygon2D
@export var collosion: CollisionPolygon2D
@export var enable: bool = true: ## 编辑器里查看
	set(value):
		re_shape()

@export var map: Array[PackedVector2Array]
func _ready() -> void:
	re_shape()

#func _process(delta: float) -> void:
	#if Engine.is_editor_hint() and enable:
		#re_shape()

func re_shape() -> void:
	if polygon and collosion:
		collosion.polygon = polygon.polygon

## 设置地图
func setup_map(map_index: int) -> void:
	if map[map_index].size() != 0:
		if polygon:
			polygon.polygon = map[map_index]
			re_shape()
