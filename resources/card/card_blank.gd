## 卡牌基类脚本
## 内置多种效果，请谨慎修改
class_name Card
extends Control

@onready var energy: Label = $MarginContainer/VBoxContainer/HBoxContainer/Energy
@onready var card_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var card_face: TextureRect = $MarginContainer/VBoxContainer/CardFace
@onready var rarity: Label = $MarginContainer/VBoxContainer/HBoxContainer/Rarity
@onready var effect: RichTextLabel = $MarginContainer/VBoxContainer/Effect
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

##  拖拽动画相关
var velocity: Vector2 = Vector2.ZERO
var damping: float = 0.35
var stiffness: int = 500
enum cardState{following, dragging}
var preview: Control

@export var cardCurrentState = cardState.following
@export var follow_target_position: Vector2 = -Vector2.ONE ## 跟随坐标

# 动画相关变量
var hover_tween: Tween
var unhover_tween: Tween
const HOVER_SCALE := Vector2(1.05, 1.05)
const HOVER_COLOR := Color(1.1, 1.1, 1.1)
const ANIM_DURATION := 0.1
var ROTATE: float = 0
var tween_times: int = 0
signal reset_tween ## 重置补间动画，修复中断错误

func _process(delta: float) -> void:
	#print(global_position)
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
			#else:
				#shake_component.tween_shake()
				#_on_button_button_up()
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
		match card_data.card_rarity:
			card_data.rarity.normal:
				rarity.text = "normal"
			card_data.rarity.uncommon:
				rarity.text = "uncommon"
			card_data.rarity.rare:
				rarity.text = "rare"
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
	z_index += 1

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
	z_index -= 1

var current_connector: ArrowConnector = null
func _on_button_button_down() -> void:
	if is_draggable:
		# 保存原始状态
		original_position = global_position
		original_parent = get_parent()
		# 生成预览复制
		preview = self.duplicate()
		original_parent.add_child(preview)
		preview.global_position = original_position
		preview.modulate.a = 0.5
		preview.set_process(false)
		# 拖拽 
		cardCurrentState = cardState.dragging
		drag_offset = get_global_mouse_position() - global_position
		# 创建连线
		await get_tree().process_frame
		var current_connector = ArrowConnector.new()
		current_connector.target_node = self
		current_connector.start_offset = Vector2(SIZE.x / 2, 0)
		current_connector.end_offset = Vector2(SIZE.x / 2, SIZE.y)
		preview.add_child(current_connector)
	else:
		shake_component.tween_shake()

func _on_button_button_up() -> void:
	var now_pos: Vector2 = global_position ## 为了解决位置瞬移的特殊bug
	if whichDeckMouseIn != null:
		#print("可放置")
		#print("前主人：", original_parent)
		#print("现主人：", whichDeckMouseIn)
		if original_parent == whichDeckMouseIn:
			#print("放回")
			if original_parent.name == "准备队列":
				#print("调换位置")
				original_parent.change_cards_pos(self, get_global_mouse_position())
			else: original_parent._update_cards()
		else:
			if original_parent is ReadyQueue: Hand2Readqueue.emit()
			elif original_parent is Hand: Readqueue2Hand.emit()
			else: pass
			original_parent.delete_card(self)
			whichDeckMouseIn.add_card(self)
			self.global_position = now_pos
	
	cardCurrentState = cardState.following
	#if current_connector:
		#current_connector.queue_free()
		#current_connector = null
	if preview: preview.queue_free()
