@tool
extends StaticBody2D
class_name WallMap ## 记录地图模式

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var p_2cp: P2CP = $P2CP

@export var maps: Array[PolyResource] ## 存储所有的地图数据
@export var used_map: int = 0:
	set(value):
		if value in range(maps.size()):
			used_map = value
			set_map([used_map])
@export var export_map: bool = true:
	set(value):
		print("导入多边形地图")
		export_map_2_data()

func _ready() -> void:
	set_map([used_map])

func set_map(index: Array[int]) -> void:
	var map_poly: Array[PackedVector2Array]
	for i in index:
		map_poly.append(maps[i].self_polygon)
	if p_2cp:
		p_2cp.map = map_poly
		p_2cp.setup_map()

func export_map_2_data() -> void:
	var map: PolyResource = PolyResource.new()
	if not polygon_2d:
		polygon_2d = get_node_or_null("Polygon2D")
	map.self_polygon = polygon_2d.polygon
	map.name = "map_" + str(maps.size())
	map.self_type = PolyResource.type_of_res.MAP
	maps.append(map.duplicate())
