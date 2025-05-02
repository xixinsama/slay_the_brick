@tool
extends Node
class_name CS2P ##获取CollisionShape的形状并对其进行采样，得到一个多边形

@export var collision: CollisionShape2D
@export var polygon: Polygon2D
@export_range(3, 20, 1, "or_greater") var esp: int = 8 ##采样数量
@export var enable: bool = true
var polygon_points: PackedVector2Array

func _ready() -> void:
	re_shape()

func re_shape() -> void:
	if collision:
		# 采样
		if collision.shape is CircleShape2D:
			#print("圆形")
			var r: float =  collision.shape.get("radius")
			for i in range(esp):
				polygon_points.append(Vector2(r*cos(2*PI*i/esp), r*sin(2*PI*i/esp)))
			
	if polygon:
		polygon.polygon = polygon_points
