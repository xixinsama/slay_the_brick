extends Button
## 抽牌堆会在游戏一开始被赋予一组卡牌
## 点击牌堆会展示牌堆——》卡牌展示界面
## 牌堆之间传递卡牌数据
## 不同传递之间有不同的信号
## 以触发各种动画及效果
class_name CardStack ## 所有牌堆共用脚本

## 牌堆类型枚举
## 抽牌堆，弃牌堆，消耗牌堆，消失牌堆
enum PileType {DRAW, DISCARD, EXPEND, VANISH}
@export var pile_type: PileType = PileType.DRAW
@export var test_mode: bool = false: set = set_test_mode

signal DRAW2HAND(nums: int) ## 抽牌堆到手牌区，卡牌数量 

# 卡牌数据管理
var current_cards: Array[CardBase] = []  # 原始卡牌数据
var working_list: Array[CardBase] = []   # 操作副本

# 界面引用
@export var card_display_ui: CanvasLayer # 卡牌展示界面

# 初始化配置
func _ready() -> void:
	# 消失牌堆默认隐藏
	if pile_type == PileType.VANISH:
		visible = test_mode
	# 连接按钮信号
	pressed.connect(_on_pile_clicked)
	
	# 初始化工作列表
	working_list = current_cards.duplicate()

# 测试模式设置
func set_test_mode(value: bool) -> void:
	test_mode = value
	if pile_type == PileType.VANISH:
		visible = value

#=== 核心功能方法 ===#
# 添加卡牌到底部
func add_cards(cards: Array[CardBase]) -> void:
	working_list.append_array(cards)
	_update_entity_count()

# 从指定位置移除卡牌
func remove_card(index: int) -> CardBase:
	if index < 0 or index >= working_list.size():
		return null
	var card = working_list.pop_at(index)
	_update_entity_count()
	return card

# 传递整个牌堆数据
func transfer_all(target_pile: Node) -> void:
	target_pile.add_cards(working_list)
	working_list.clear()
	_update_entity_count()

# 洗牌算法
func shuffle() -> void:
	working_list.shuffle()
	# 洗牌动画示例
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation", randf_range(-0.05, 0.05), 0.2)
	tween.chain().tween_property(self, "rotation", 0.0, 0.2)

# 弹出顶部卡牌
func pop_top() -> CardBase:
	return remove_card(0)

# 在指定位置插入卡牌
func insert_card(index: int, card: CardBase) -> void:
	working_list.insert(clamp(index, 0, working_list.size()), card)
	_update_entity_count()

#=== 界面交互 ===#
func _on_pile_clicked() -> void:
	match pile_type:
		PileType.DRAW:
			card_display_ui.init_display(current_cards, "抽牌堆")
		PileType.DISCARD:
			card_display_ui.init_display(current_cards, "弃牌堆")
		PileType.EXPEND:
			card_display_ui.init_display(current_cards, "消耗牌堆")
		PileType.VANISH:
			card_display_ui.init_display(current_cards, "消失牌堆")
	card_display_ui.visible = true

# 更新实体数量显示
func _update_entity_count() -> void:
	text = str(working_list.size())
	# 更新牌堆外观
	if pile_type == PileType.DRAW:
		modulate = Color(0.8, 1.0, 0.8)
	elif pile_type == PileType.DISCARD:
		modulate = Color(1.0, 0.8, 0.8)


##=== 调试功能 ===#
## 编辑器模式下绘制调试图形
#func _draw() -> void:
	#if Engine.is_editor_hint():
		#var color: Color
		#match pile_type:
			#PileType.DRAW: color = Color.GREEN
			#PileType.DISCARD: color = Color.RED
			#PileType.EXPEND: color = Color.ORANGE
			#PileType.VANISH: color = Color.PURPLE
		#
		#draw_rect(Rect2(Vector2.ZERO, size), color, false, 2.0)
		#draw_string(
			#get_theme_default_font(),
			#Vector2(10, 20),
			#"Pile: %s" % PileType.keys()[pile_type],
			#HORIZONTAL_ALIGNMENT_LEFT,
			#-1,
			#16
		#)
