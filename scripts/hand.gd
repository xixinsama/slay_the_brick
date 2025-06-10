class_name Hand ## 手牌区
extends ColorRect

var card_instances: Array[Card] = []   # 当前显示的卡牌实例

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees: float = 10
@export var x_sep: int = 20
@export var y_min: int = 20
@export var y_max: int = -20

## 更新卡牌位置
func _update_cards() -> void:
	var cards: int = card_instances.size()
	var all_cards_size := Card.SIZE.x * cards + x_sep * (cards - 1)
	var final_x_sep = x_sep
	var cards_pos: Array[Vector2] = []
	
	if all_cards_size > size.x:
		final_x_sep = (size.x - Card.SIZE.x * cards) / (cards - 1)
		all_cards_size = size.x

	var offset := (size.x - all_cards_size) / 2
	
	# 获得位置和旋转
	for i in cards:
		var y_multiplier := hand_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)
		
		if cards == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
		
		var final_x: float = offset + Card.SIZE.x * i + final_x_sep * i
		var final_y: float = y_min + y_max * y_multiplier
		
		# 赋值
		card_instances[i].follow_target_position = Vector2(final_x, final_y) + position
		card_instances[i].rotation_degrees = max_rotation_degrees * rot_multiplier
		card_instances[i].z_index = 6 + i
		card_instances[i].follow_which = Card.follow_type.HAND

## 添加一张牌
func add_card(new_card: Card):
	self.add_child(new_card)
	card_instances.append(new_card)
	_update_cards()

## 通过卡牌信息添加一张牌
func add_card_by_base(new_base: CardBase):
	var card: Card = GameManage.get_card_instance()
	if card:
		self.add_child(card)
		card.card_data = new_base
		card_instances.append(card)
		# 摆放
		_update_cards()
	else: print("添加卡牌失败")

## 删除一张牌
func delete_card(old_card: Card):
	var index: int = card_instances.find(old_card)
	card_instances.pop_at(index)
	self.remove_child(old_card)
	_update_cards()

## 删除卡
func discard() -> void:
	var card: Card = card_instances.pop_back()
	GameManage.recycle_card(card)
	_update_cards()

## 生成卡
var card_range: Array = [1, 2, 3, 4, 5, 7, 8, 12] ## 测试已完成的牌

func draw() -> void:
	var card: Card = GameManage.get_card_instance()
	if card:
		self.add_child(card)
		# 随机找一个数据赋值
		#card.card_data = ImportCard.all_cardbase[randi_range(0, ImportCard.all_cardbase.size()-1)]
		card.card_data = ImportCard.all_cardbase[card_range[randi_range(0, card_range.size()-1)] - 1]
		card_instances.append(card)
		
		# 摆放
		_update_cards()
	else: print("未获得卡牌")
