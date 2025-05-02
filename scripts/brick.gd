extends RigidBody2D

@export var hits_required := 99
@export var shape: PackedVector2Array = PackedVector2Array()

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var p_2cp: P2CP = $P2CP
@onready var label: Label = $Label


func _ready():
	update_display()
	if shape.size() >= 3:
		polygon_2d.polygon = shape
		p_2cp.re_shape()

func take_hit(hurt: int = 1):
	hits_required -= hurt
	if hits_required <= 0:
		queue_free()
		get_tree().call_group("game", "brick_destroyed")
	update_display()

func update_display():
	label.text = str(hits_required)
	modulate = Color(1, 1 - float(hits_required)/3, 1 - float(hits_required)/3)
