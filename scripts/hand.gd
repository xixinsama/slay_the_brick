class_name Hand
extends ColorRect

const CARD = preload("res://scenes/card_blank.tscn")

var card_list: Array[CardBase] = []  # 原始卡牌数据
var card_entities: Array[Control] = []   # 当前显示的卡牌实例

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees: float = 10
@export var x_sep: int = 20
@export var y_min: int = 20
@export var y_max: int = -20

## 生成卡
func draw() -> void:
	var new_card = CARD.instantiate()
	#new_card.card_data = card_data
	
	add_child(new_card)
	new_card.init_card()
	_update_cards()

## 删除卡
func discard() -> void:
	if get_child_count() < 1:
		return
		
	var child := get_child(-1)
	child.reparent(get_tree().root)
	child.queue_free()
	_update_cards()

## 更新卡牌位置
func _update_cards() -> void:
	var cards: int = get_child_count()
	var all_cards_size := Card.SIZE.x * cards + x_sep * (cards - 1)
	var final_x_sep = x_sep
	
	if all_cards_size > size.x:
		final_x_sep = (size.x - Card.SIZE.x * cards) / (cards - 1)
		all_cards_size = size.x

	var offset := (size.x - all_cards_size) / 2
	
	for i in cards:
		var card := get_child(i)
		var y_multiplier := hand_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)
		
		if cards == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
		
		var final_x: float = offset + Card.SIZE.x * i + final_x_sep * i
		var final_y: float = y_min + y_max * y_multiplier
		
		card.position = Vector2(final_x, final_y)
		card.rotation_degrees = max_rotation_degrees * rot_multiplier
