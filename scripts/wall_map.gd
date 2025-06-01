@tool
extends StaticBody2D
class_name WallMap ## 记录地图模式

@onready var p_2cp: P2CP = $P2CP
@export var maps: Array[PolyResource] ## 存储所有的地图数据

func _ready() -> void:
	var map_poly: Array[PackedVector2Array]
	#map_poly.append(maps[0].self_polygon)
	#map_poly.append(maps[5].self_polygon)
	map_poly.append(maps[0].self_polygon)
	p_2cp.map = map_poly
	p_2cp.setup_map()
