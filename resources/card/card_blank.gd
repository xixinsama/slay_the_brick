## 卡牌基类脚本
## 内置多种效果，请谨慎修改
class_name Card
extends Control

const HINT = preload("res://scenes/hint.tscn")
#const CARD_BLANK = preload("res://scenes/card_blank.tscn")

@onready var shadow: ColorRect = $shadow
@onready var frame: TextureRect = $Frame
@onready var energy: Label = $MarginContainer/VBoxContainer/HBoxContainer/Energy
@onready var card_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var card_face: TextureRect = $MarginContainer/VBoxContainer/CardFace
@onready var card_type: Label = $MarginContainer/VBoxContainer/HBoxContainer/CardType
@onready var effect: RichTextLabel = $Button/Effect
@onready var shake_component: ShakeComponent = $ShakeComponent

signal Hand2Readqueue
signal Readqueue2Hand

const SIZE: Vector2 = Vector2(135, 216) ## 由hand脚本使用
var card_data: CardBase: set = _set_card_data ## 赋值时会自动重新更新卡牌
var is_upgrade: bool = false:
	set(value):
		init_card()
var whichDeckMouseIn: Node
var original_position: Vector2
var original_parent: Node
var is_draggable: bool = true  # 是否允许拖拽
var drag_offset: Vector2  # 拖拽偏移量
var is_shadow: bool = false # 阴影可见

##  拖拽动画相关
var velocity: Vector2 = Vector2.ZERO
var damping: float = 0.35
var stiffness: int = 500
enum cardState{following, dragging}
#var preview: Card

@export var cardCurrentState = cardState.following
@export var follow_target_position: Vector2 = -Vector2.ONE ## 跟随坐标

# 动画相关变量
var hover_tween: Tween
var unhover_tween: Tween
const HOVER_SCALE := Vector2(1.5, 1.5)
const HOVER_COLOR := Color(1.1, 1.1, 1.1)
const ANIM_DURATION := 0.1
var ROTATE: float = 0
var tween_times: int = 0
signal reset_tween ## 重置补间动画，修复中断错误

func _process(delta: float) -> void:
	#print(cardCurrentState)
	# 阴影移动
	#print(is_shadow)
	if scale == Vector2.ONE:
		is_shadow = false
		shadow.global_position = global_position
	else: 
		is_shadow = true
	# 阴影偏移
	if is_shadow:
		var shadow_offset: Vector2 = (get_global_mouse_position() - global_position - SIZE / 2 * HOVER_SCALE) * 0.4
		shadow_offset = shadow_offset.clamp(-Card.SIZE/2, Card.SIZE/2)
		shadow.global_position = global_position - shadow_offset
		
	match cardCurrentState:
		cardState.dragging:
			var mouse_position = get_global_mouse_position()
			var target_position = mouse_position - drag_offset
			#if is_draggable:
			global_position = target_position
			whichDeckMouseIn = null  # 先重置
			# 获取所有可放置区域（确保它们都在同一坐标系下）
			var drop_zones = get_tree().get_nodes_in_group("card_dropzone")
			for zone in drop_zones:
				# 正确获取全局边界矩形
				var zone_rect: Rect2 = zone.get_global_rect()
				if zone.visible && zone_rect.has_point(mouse_position):
					whichDeckMouseIn = zone
					#print(whichDeckMouseIn)
					break  # 找到第一个符合条件的区域即可
		cardState.following:
			if follow_target_position != -Vector2.ONE:
				var displacement = follow_target_position - global_position
				# 添加距离阈值防止震荡
				if displacement.length() < 2.0:
					global_position = follow_target_position
					return
				
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta
	

func _set_card_data(new_data: CardBase) -> void:
	card_data = new_data
	init_card() 
 
## 初始化卡牌，需要先给card_data赋值
func init_card() -> bool:
	if card_data:
		card_name.text = card_data.card_name
		match card_data.card_type:
			card_data.card_base_type.skill:
				card_type.text = "技能"
			card_data.card_base_type.item:
				card_type.text = "道具"
			card_data.card_base_type.ability:
				card_type.text = "能力"
			card_data.card_base_type.active:
				card_type.text = "主动"
			card_data.card_base_type.counter:
				card_type.text = "反制"
		card_face.texture = card_data.card_face
		# 升级描述
		if not is_upgrade:
			energy.text = str(card_data.base_cost)
			effect.text = card_data.effect_description
		else:
			energy.text = str(card_data.upgrade_cost)
			effect.text = card_data.upgrade_effect_description
		return true
	else:
		## 从卡牌池里提取出来时
		## 重置属性
		## 正常开启拖拽和帧处理
		visible = true
		is_draggable = true
		card_name.text = "noname"
		set_process(true)
		return false

func _on_mouse_entered() -> void:
	# 取消之前的动画
	if hover_tween:
		hover_tween.kill()
	ROTATE = rotation_degrees
	#pos_now = global_position
	tween_times += 1
	if tween_times == 50:
		reset_tween.emit()
		tween_times = 0
	# 创建新的悬停动画
	hover_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "scale", HOVER_SCALE, ANIM_DURATION)
	hover_tween.parallel().tween_property(self, "rotation_degrees", 0, ANIM_DURATION)
	hover_tween.parallel().tween_property(self, "modulate", HOVER_COLOR, ANIM_DURATION)
	# 提升层级避免被遮挡
	z_index == 99
	# 影子偏移
	#is_shadow = true

func _on_mouse_exited() -> void:
	# 取消之前的动画
	if unhover_tween:
		unhover_tween.kill()
	# 创建新的恢复动画
	unhover_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	unhover_tween.tween_property(self, "scale", Vector2.ONE, ANIM_DURATION)
	unhover_tween.parallel().tween_property(self, "rotation_degrees", ROTATE, ANIM_DURATION)
	if modulate.a != 0.5:
		unhover_tween.parallel().tween_property(self, "modulate", Color.WHITE, ANIM_DURATION)
	# 恢复层级
	z_index = 5 # 
	# 影子归位
	#if cardCurrentState == cardState.following:
		#is_shadow = false
		#shadow.global_position = global_position

func _on_button_button_down() -> void:
	if is_draggable:
		# 保存原始状态
		original_position = global_position
		original_parent = get_parent()
		## 生成预览复制
		#preview = CARD_BLANK.instantiate()
		#original_parent.add_child(preview)
		#preview.card_data = card_data
		#preview.init_card()
		#preview.global_position = original_position
		#preview.modulate.a = 0.5
		##disconnect_all_signals_in_scene(preview)
		##preview.set_process(false)
		#preview.clear_hint()
		# 拖拽 
		cardCurrentState = cardState.dragging
		drag_offset = get_global_mouse_position() - global_position
		# 创建连线
		await get_tree().process_frame
		var current_connector = ArrowConnector.new()
		current_connector.target_node = self
		current_connector.start_offset = Vector2(SIZE.x / 2, SIZE.y / 2)
		current_connector.end_offset = Vector2(SIZE.x / 2, SIZE.y)
		#preview.add_child(current_connector)
	else:
		shake_component.tween_shake()

func _on_button_button_up() -> void:
	var now_pos: Vector2 = global_position ## 为了解决位置瞬移的特殊bug
	if whichDeckMouseIn != null:
		if original_parent == whichDeckMouseIn:
			#print("放回")
			if original_parent.name == "准备队列":
				#print("调换位置")
				original_parent.change_cards_pos(self, get_global_mouse_position())
			else: original_parent._update_cards()
		else:
			if whichDeckMouseIn is ReadyQueue:
				if whichDeckMouseIn.card_instances.size() < whichDeckMouseIn.fields:
					original_parent.delete_card(self)
					whichDeckMouseIn.add_card(self)
					Hand2Readqueue.emit()
				else:
					print("准备队列栏位已满")
			elif whichDeckMouseIn is Hand:
				original_parent.delete_card(self)
				whichDeckMouseIn.add_card(self)
				Readqueue2Hand.emit()
			else: pass
			global_position = now_pos
	cardCurrentState = cardState.following
	#if preview: preview.queue_free()
	clear_hint()


func _on_effect_meta_hover_started(meta: Variant) -> void:
	# 生成提示
	if get_node_or_null(str(meta)) == null and cardCurrentState == cardState.following:
		var hint: Hint = HINT.instantiate()
		add_child(hint)
		hint.init_hint(str(meta))
		# 生成箭头
		var current_connector = ArrowConnector.new()
		current_connector.target_node = self
		current_connector.start_offset = Vector2(121.5, 0)
		current_connector.end_offset = get_global_mouse_position() - global_position
		hint.add_child(current_connector)
	else:
		print("hint已存在：" + str(meta))

func _on_effect_meta_hover_ended(meta: Variant) -> void:
	if get_node_or_null(str(meta)) != null and cardCurrentState == cardState.following:
		get_node(str(meta)).queue_free()

## 清除所有的提示
func clear_hint() -> void:
	for child in get_children():
		if child is Hint:
			child.queue_free()
