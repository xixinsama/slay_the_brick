extends Control
class_name Hint ## 卡牌描述悬停时会出现的提示

@onready var color_rect: ColorRect = $ColorRect
@onready var effect_describe: RichTextLabel = $Effect

const xh: String = "消耗：被消耗的牌在本层内永久存在于消耗牌堆，不会放回牌库，下一层回归"
const gy: String = "固有：每回合开始会优先抽到，且不占用抽牌数"
const kzxcs: String = "可执行次数x：可在单回合内执行效果x次，第x+1次消耗。如果第x+1次被执行，但没执行其效果，则会放入弃牌堆，不消耗"
const qr: String = "嵌入：该牌在任何牌堆里的位置永远不变，不受任何影响"
const bl: String = "保留：本回合结束时，该牌不进入弃牌堆，获得一次短暂的固有，下回合会再次抽到"
const bktz: String = "不可拖拽：该牌在任何牌堆里永远不可进入其他牌堆"
const xw: String = "虚无：本回合内，如果该牌没有被打出，则进入消耗牌堆"
const qzzx: String = "强制执行：不消耗出牌次数，无视准备队列执行顺序，且最优先执行，进入执行判定"
const thzx: String = "替换执行：将被替换的目标放入准备队列的相应位置上，开始执行"
const fzzx: String = "复制执行：将被复制牌放在该牌之后，依次执行"
const fzxgzx: String = "复制效果执行：将被复制的效果加入该牌的效果之中，再执行"

const effect_size: Vector2 = Vector2(135, 48)
var left_offset: Vector2 = Vector2(225, 100)
var right_offset: Vector2 = Vector2(-225, 100)
var parent_pos: Vector2 = Vector2.ZERO
var follow_pos: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var damping: float = 0.35
var stiffness: int = 400

## 初始化
func init_hint(describe: String) -> void:
	set_process(false)
	parent_pos = get_parent().global_position + Card.SIZE * 0.9
	global_position = parent_pos
	name = describe
	if get(describe) != null:
		effect_describe.text = get(describe)
	await effect_describe.resized
	color_rect.size = effect_describe.get_rect().size
	set_process(true)

## 弹簧跟随父节点
func _process(delta: float) -> void:
	parent_pos = get_parent().global_position
	if parent_pos.x < get_viewport_rect().size.x / 2:
		follow_pos = parent_pos + left_offset
	else:
		follow_pos = parent_pos + right_offset
	var displacement = follow_pos - global_position
	# 添加距离阈值防止震荡
	if displacement.length() < 2.0:
		global_position = follow_pos
		return

	var force = displacement * stiffness
	velocity += force * delta
	velocity *= (1.0 - damping)
	global_position += velocity * delta
