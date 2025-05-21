class_name Card
extends Control

@onready var energy: Label = $MarginContainer/VBoxContainer/HBoxContainer/Energy
@onready var card_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var card_face: TextureRect = $MarginContainer/VBoxContainer/CardFace
@onready var effect: RichTextLabel = $MarginContainer/VBoxContainer/Effect
@onready var shake_component: ShakeComponent = $ShakeComponent

const SIZE: Vector2 = Vector2(135, 216) ## 由hand脚本使用
var card_data: CardBase

var velocity: Vector2 = Vector2.ZERO
var damping: float = 0.35
var stiffness: int = 500
enum cardState{following, dragging}
var preview: Control

@export var cardCurrentState = cardState.following
@export var follow_target: Control

# 拖拽控制变量
var original_position: Vector2
var original_parent: Node
var is_draggable: bool = true  # 是否允许拖拽
var drag_offset: Vector2  # 拖拽偏移量

# 动画相关变量
var hover_tween: Tween
var unhover_tween: Tween
const HOVER_SCALE := Vector2(1.05, 1.05)
const HOVER_COLOR := Color(1.1, 1.1, 1.1)
const ANIM_DURATION := 0.1
var ROTATE: float = 0
#const golbal_pos: Vector2 = Vector2(0, -30)
#var pos_now: Vector2 = Vector2.ZERO
var tween_times: int = 0
signal reset_tween ## 重置补间动画，修复中断错误

func _process(delta: float) -> void:
	match cardCurrentState:
		cardState.dragging:
			var target_position = get_global_mouse_position() - drag_offset
			if is_draggable:
				global_position = global_position.lerp(target_position, 0.4)
			else:
				shake_component.tween_shake()
				_on_button_button_up()
		cardState.following:
			if follow_target != null:
				var target_position := Vector2.ZERO
				if follow_target == Hand:
					pass
				else:
					target_position = follow_target.global_position
				var displacement = target_position - global_position
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta


func init_card() -> bool:
	if card_data:
		energy.text = str(card_data.energy)
		card_name.text = card_data.card_name
		card_face.texture = card_data.card_face
		effect.text = card_data.effect_description
		return true
	else: return false

#func _get_drag_data(pos):
	#if not is_draggable:
		#return null
	#print("dragging")
	## 计算鼠标在卡牌内的相对偏移（基于卡牌坐标系）
	#drag_offset = pos
	## 保存原始状态
	#original_position = global_position
	#original_parent = get_parent()
	## 创建预览
	#var preview = self.duplicate()
	#preview.position = original_position
	#set_drag_preview(preview)
	## 半透明效果
	#modulate.a = 0.5
	#z_index = 5
	## 返回包含卡牌和偏移量的字典
	#return {
		#"card": self,
		#"info": card_data
	#}

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
	#hover_tween.parallel().tween_property(self, "global_position", pos_now+golbal_pos, ANIM_DURATION)
	hover_tween.parallel().tween_property(self, "modulate", HOVER_COLOR, ANIM_DURATION)
	
	# 提升层级避免被遮挡
	z_index = 1
func _on_mouse_exited() -> void:
	# 取消之前的动画
	if unhover_tween:
		unhover_tween.kill()
	
		
	# 创建新的恢复动画
	unhover_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	unhover_tween.tween_property(self, "scale", Vector2.ONE, ANIM_DURATION)
	unhover_tween.parallel().tween_property(self, "rotation_degrees", ROTATE, ANIM_DURATION)
	#unhover_tween.parallel().tween_property(self, "global_position", pos_now, ANIM_DURATION)
	if modulate.a != 0.5:
		unhover_tween.parallel().tween_property(self, "modulate", Color.WHITE, ANIM_DURATION)
	# 恢复层级
	z_index = 0

var current_connector: ArrowConnector = null
func _on_button_button_down() -> void:
	# 保存原始状态
	original_position = position
	original_parent = get_parent()
	# 生成预览复制
	preview = self.duplicate()
	preview.global_position = original_position
	preview.modulate.a = 0.5
	original_parent.add_child(preview)
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
func _on_button_button_up() -> void:
	cardCurrentState = cardState.following
	#if current_connector:
		#current_connector.queue_free()
		#current_connector = null
	if preview: preview.queue_free()
