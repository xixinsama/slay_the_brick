## 卡牌展示界面
## 从开始界面的卡牌图书馆
## 打牌阶段的抽牌堆，弃牌堆，消耗牌堆，消失牌堆可进入
## 不可见
extends CanvasLayer
class_name CardDisplayUI

signal opened
signal closed

# 节点路径
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TitleLabel
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var sort_option_button: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SortOptionButton
@onready var card_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/CardContainer

# 配置参数
@export var columns: int = 8 : set = set_columns
@export var horizontal_spacing: int = 180
@export var vertical_spacing: int = 240

var current_cards: Array[CardBase] = []
var card_instances: Array[Card] = []
var target_positions: Array[Vector2] = []

enum mode {SHOW, SELECT}
var current_mode: mode = mode.SHOW

func _ready() -> void:
	# 连接信号
	close_button.pressed.connect(_on_close_button_pressed)
	sort_option_button.item_selected.connect(_on_sort_option_selected)
	#visibility_changed.connect(_on_visibility_changed)
	opened.connect(_open_card_show)
	# 配置容器
	card_container.add_theme_constant_override("h_separation", horizontal_spacing)
	card_container.add_theme_constant_override("v_separation", vertical_spacing)
	set_columns(columns)

# 初始化显示
func init_display(cards: Array[CardBase], title: String) -> void:
	current_cards = cards.duplicate()
	title_label.text = title
	_clear_cards()
	_generate_cards()
	_apply_sort(0)
	#_play_enter_animation()

# 生成卡牌实例
func _generate_cards() -> void:
	for card_data in current_cards:
		var card: Card = GameManage.get_card_instance()
		card_instances.append(card)
		card_container.add_child(card)
		card.card_data = card_data
		card.is_draggable = false
		card.init_card()
		card.follow_which = Card.follow_type.LIBRARY
	# 初始位置
	for i in card_instances.size():
		target_positions.append(card_instances[i].position)

# 清空卡牌
func _clear_cards() -> void:
	for card in card_instances:
		GameManage.recycle_card(card)
	card_instances.clear()
	target_positions.clear()

#=== 排序系统 ===#
func _apply_sort(sort_id: int) -> void:
	match sort_id:
		0: _sort_by_energy()
		1: _sort_by_name()
		2: _sort_by_type()
		3: _sort_by_rare()

	_update_card_order()
	_arrange_with_animation()

func _sort_by_energy() -> void:
	current_cards.sort_custom(func(a, b): return a.base_cost < b.base_cost)

func _sort_by_name() -> void:
	current_cards.sort_custom(func(a, b): return a.card_name.naturalnocasecmp_to(b.card_name) < 0)

func _sort_by_type() -> void:
	current_cards.sort_custom(func(a, b): return a.card_type < b.card_type)

func _sort_by_rare() -> void:
	current_cards.sort_custom(func(a, b): return a.card_rarity < b.card_rarity)

# 更新实例顺序
func _update_card_order() -> void:
	card_instances.sort_custom(func(a, b): 
		return current_cards.find(a.card_data) < current_cards.find(b.card_data)
	)

#=== 布局系统 ===#
func set_columns(value: int) -> void:
	columns = clamp(value, 1, 10)
	if card_container:
		card_container.columns = columns
		_arrange_with_animation()

func _calculate_layout() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var row := 0
	var col := 0
	
	for card in card_instances:
		var pos_x = col * (card.size.x + horizontal_spacing)
		var pos_y = row * (card.size.y + vertical_spacing)
		positions.append(Vector2(pos_x, pos_y))
		
		col += 1
		if col >= columns:
			col = 0
			row += 1
	
	return positions

#=== 动画系统 ===#
#func _play_enter_animation() -> void:
	#var tween = create_tween().set_parallel(true)
	#for i in card_instances.size():
		#var card := card_instances[i]
		#card.modulate = Color.TRANSPARENT
		#card.position += Vector2(0, 50)
		#
		#tween.tween_property(card, "position", target_positions[i], 0.4)\
			#.set_delay(i * 0.02)\
			#.set_ease(Tween.EASE_OUT)
		#tween.tween_property(card, "modulate", Color.WHITE, 0.3)\
			#.set_delay(i * 0.02)

func _arrange_with_animation() -> void:
	if card_instances.is_empty():
		return
	target_positions = _calculate_layout()
	var tween: Tween = create_tween().set_parallel(true)
	for i in card_instances.size():
		var card = card_instances[i]
		var target_pos = target_positions[i]
		# 添加位置有效性检查
		if target_pos != card.position:
			tween.tween_property(card, "position", target_pos, 0.3)\
				.set_ease(Tween.EASE_IN_OUT)\
				.set_trans(Tween.TRANS_CUBIC)
		
	#await tween.finished
	#for card in card_instances:
		#card.follow_target_position = card.global_position

#=== 信号处理 ===#
func _on_sort_option_selected(index: int) -> void:
	_apply_sort(index)

func _on_close_button_pressed() -> void:
	var exit_tween = create_tween()
	exit_tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.4).set_ease(Tween.EASE_IN)
	exit_tween.finished.connect(_final_close)

#=== 开关信号 ===#
func _open_card_show() -> void:
	var open_tween = create_tween()
	open_tween.tween_property(self, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT)

func _final_close() -> void:
	_clear_cards()
	visible = false

func _on_visibility_changed() -> void:
	if visible == false: closed.emit()
	else: opened.emit()
