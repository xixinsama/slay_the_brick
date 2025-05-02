@tool
extends Node
class_name P2CP ## 将多边形赋予碰撞箱

@export var polygon: Polygon2D
@export var collosion: CollisionPolygon2D
@export var enable: bool = true

func _ready() -> void:
	re_shape()

#func _process(delta: float) -> void:
	#if Engine.is_editor_hint() and enable:
		#re_shape()

func re_shape() -> void:
	if polygon and collosion:
		collosion.polygon = polygon.polygon
