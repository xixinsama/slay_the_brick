class_name Card
extends Control

@onready var energy: Label = $MarginContainer/VBoxContainer/HBoxContainer/Energy
@onready var card_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var card_face: TextureRect = $MarginContainer/VBoxContainer/CardFace
@onready var effect: Label = $MarginContainer/VBoxContainer/Effect

const SIZE: Vector2 = Vector2(135, 216) ## 由hand脚本使用
var card_data: CardBase

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

func init_card() -> bool:
	if card_data:
		energy.text = str(card_data.energy)
		card_name.text = card_data.card_name
		card_face.texture = card_data.card_face
		effect.text = card_data.effect_description
		return true
	else: return false

func _get_drag_data(pos):
	if not is_draggable:
		return null
	# 计算鼠标在卡牌内的相对偏移（基于卡牌坐标系）
	drag_offset = pos
	# 保存原始状态
	original_position = global_position
	original_parent = get_parent()
	# 创建预览
	var preview = _create_preview()
	set_drag_preview(preview[0])
	# 半透明效果
	modulate.a = 0.5
	z_index = 1
	# 返回包含卡牌和偏移量的字典
	return {
		"card": self,
		"offset": drag_offset
	}

func _create_preview():
	var preview = self.duplicate()
	# 创建偏移控制容器
	var offset_container = Control.new()
	offset_container.add_child(preview)
	preview.position = -drag_offset  # 偏移预览位置
	return [offset_container, preview.card_data]

func _on_mouse_entered() -> void:
	# 取消之前的动画
	if hover_tween:
		hover_tween.kill()
	ROTATE = rotation_degrees
#	pos_now = global_position
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
