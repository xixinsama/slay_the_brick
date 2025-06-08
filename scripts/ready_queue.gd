class_name ReadyQueue ## 准备队列
extends ColorRect

var card_instances: Array[Card] = []   # 当前显示的卡牌实例
var fields: int = 13 # 栏位数量
var card_pos: Array[Vector2] = []

var gap: float = 140.0
var panel_range: Rect2 = get_rect()

func _ready() -> void:
	pass

## 管理卡牌位置
func _update_cards() -> void:
	# 清空旧坐标
	card_pos.clear()
	# 生成坐标
	var card_weight := card_instances.size() * gap
	if card_weight > panel_range.size.x:
		gap = panel_range.size.x / card_instances.size()
	for i in range(card_instances.size()):
		card_pos.append(Vector2(gap * i, 0))
	var n: int = 0
	for cards in card_instances:
		cards.follow_target_position = card_pos[n] + global_position
		n += 1

## 通过拖拽获得卡牌
func add_card(new_card: Card):
	new_card.rotation = 0
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

## 删除卡牌
func delete_card(old_card: Card):
	var index: int = card_instances.find(old_card)
	card_instances.pop_at(index)
	self.remove_child(old_card)

## 智能调换卡牌位置
func change_cards_pos(dragged_card: Card, drop_pos: Vector2) -> void:
	# 获取当前拖拽卡牌的索引
	var dragged_index := card_instances.find(dragged_card)
	#print(dragged_index)
	if dragged_index == -1:
		return

	# 转换坐标到本地坐标系
	var local_pos: Vector2 = drop_pos - global_position
	#print(local_pos)
	# 计算最近的位置索引
	var closest_index := 0
	var min_distance := INF
	for i in card_pos.size():
		var distance: float = abs(card_pos[i].x - local_pos.x)
		if distance < min_distance:
			min_distance = distance
			closest_index = i

	# 添加交换阈值（半个卡牌间距）
	if min_distance < gap * 0.6 and closest_index != dragged_index:
		# 交换卡牌位置
		swap(card_instances, dragged_index, closest_index)
		_update_cards()
		
		# 触发动画效果
		var temp_pos = card_pos[dragged_index]
		card_pos[dragged_index] = card_pos[closest_index]
		card_pos[closest_index] = temp_pos
		
		# 更新所有卡牌目标位置
		for i in card_instances.size():
			card_instances[i].follow_target_position = card_pos[i] + global_position

## 交换数组元素位置
## 仅供 change_cards_pos 调用
static func swap(arr: Array, i: int, j: int) -> void:
	var temp = arr[i]
	arr[i] = arr[j]
	arr[j] = temp
