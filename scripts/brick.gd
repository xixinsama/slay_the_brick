extends RigidBody2D

@export var max_health: int = 999
@export var hits_required: int = 99
@export var shape: PackedVector2Array = PackedVector2Array()

const FLOATING_TEXT = preload("res://scenes/floating_text.tscn")

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var p_2cp: P2CP = $P2CP
@onready var label: Label = $Label


func _ready():
	update_display()
	if shape.size() >= 3:
		polygon_2d.polygon = shape
		p_2cp.re_shape()

## 出伤函数
## 0表示球，1表示鼠标
func take_hit(hurt: int = 1, flag: int = 0, node: Node =  null):
	var actual_damage: int
	if hurt >= hits_required: 
		actual_damage = hits_required
	else: 
		actual_damage = hurt
	hits_required -= actual_damage
	# 添加飘字
	var ft := FLOATING_TEXT.instantiate()
	add_child(ft)
	ft.global_position = global_position + Vector2.UP * 30 + Vector2(randi_range(-30, 30), 0)
	ft.display_damage_text(actual_damage, flag)
	if hits_required <= 0:
		queue_free()
		#get_tree().call_group("game", "brick_destroyed")
	# 计算分数，并登记
	if flag == 0: ## 球出伤
		GameManage.gold_points += GameManage.ball2points * actual_damage
		GameManage.value_logs.append({
			"name": self.name,
			"time": Time.get_ticks_msec(),
			"points": GameManage.ball2points * actual_damage,
			"from": node.name
			})
	elif flag == 1:  ## 鼠标出伤
		GameManage.gold_points += GameManage.mouse2points * actual_damage
		GameManage.value_logs.append({
			"name": self.name,
			"time": Time.get_ticks_msec(),
			"points": GameManage.mouse2points * actual_damage,
			"from": "mouse"
			})
	update_display()
	
func update_display():
	label.text = str(hits_required)
	polygon_2d.modulate = Color(0.8 - float(hits_required)/ 99, 0.5, 1 - float(hits_required)/ 99)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		#print("砖块收到点击事件！位置：", event.position)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if GameManage.can_mouse:
				take_hit(GameManage.mouse_click, 1)
				viewport.set_input_as_handled() ## 禁止输入向下传播，防止重叠的部分被同样触发
