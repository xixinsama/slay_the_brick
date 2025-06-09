class_name ReadyQueue ## 准备队列
extends ColorRect

var card_instances: Array[Card] = [] # 当前显示的卡牌实例
var fields: int = 13 # 栏位数量
var card_pos: Array[Vector2] = [] # 卡片跟随的位置信息

var gap: float = 140.0 # 初始间隔距离
var act_gap: float = 0 # 实际间隔距离
var panel_range: Rect2 = get_rect()

func _ready() -> void:
	pass

## 管理卡牌位置
## 严格按照 card_instances 排列
## 赋予卡牌确定的跟随位置信息
func _update_cards() -> void:
	# 清空旧坐标
	card_pos.clear()
	# 生成坐标
	if card_instances.size() * gap > panel_range.size.x:
		act_gap = panel_range.size.x / card_instances.size()
	else: act_gap = gap
	for i in range(card_instances.size()):
		card_pos.append(Vector2(act_gap * i, 0))
	var n: int = 0
	# 跟随确定
	for cards in card_instances:
		cards.z_index = 6 + n
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

## 拖拽调换卡牌位置
## 只进行俩俩交换
## 规则，n<m,m到n的位置
## m<n，且n<=S，在卡牌内，则m到n的位置
## m<n，且n>S，移动到最后
func change_cards_pos(dragged_card: Card, drop_pos: Vector2) -> void:
	# 获取当前拖拽卡牌的索引
	var dragged_index := card_instances.find(dragged_card)
	print(dragged_index)
	if dragged_index == -1:
		return

	# 转换坐标到本地坐标系
	var local_pos: Vector2 = drop_pos - global_position
	var new_index: int = floorf(local_pos.x / act_gap)
	
	# 移动
	if new_index < dragged_index:
		swap(card_instances, new_index, dragged_index)
	elif new_index == dragged_index: return
	elif new_index > dragged_index and new_index <= card_instances.size():
		swap(card_instances, new_index, dragged_index)
	elif new_index > dragged_index and new_index > card_instances.size():
		card_instances.push_back(card_instances.pop_at(dragged_index))
	
	_update_cards()

## 交换数组元素位置
## 仅供 change_cards_pos 调用
static func swap(arr: Array, i: int, j: int) -> void:
	var temp = arr[i]
	arr[i] = arr[j]
	arr[j] = temp
