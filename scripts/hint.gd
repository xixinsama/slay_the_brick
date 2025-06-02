extends Control
class_name Hint ## 卡牌描述悬停时会出现的提示

@onready var color_rect: ColorRect = $ColorRect
@onready var effect_describe: RichTextLabel = $Effect

const xh: String = "消耗：被消耗的牌在本层内永久存在于消耗牌堆，不会放回牌库，下一层回归"
const gy: String = "固有：每回合都会优先抽到，且不占用抽牌数"
const kzxcs: String = "可执行次数x：可在单回合内执行效果x次，第x+1次消耗。如果第第x+1次被执行，但没执行其效果，则会如一般牌的情况一样，放入弃牌堆，不被消耗"
const qr: String = "嵌入：该牌在任何牌堆（一般是准备队列）里的位置永远不变，不受任何影响"
const bl: String = "保留：本回合结束时，该牌不进入弃牌堆，获得一次短暂的固有，下回合会再次抽到"
const bktz: String = "不可拖拽：该牌在任何牌堆里永远不可进入其他牌堆"
const xw: String = "虚无：本回合内，如果该牌没有被打出，则进入消耗牌堆。如果该回合是本层最后一个回合，意味着进入下一层会洗牌，此时该条件影响不大"
const qzzx: String = "强制执行：不消耗出牌次数，无视准备队列执行顺序，且最优先执行，进入执行判定。本意是为了一些反制牌在回合开始时，迅速通过一个执行的动画来表现效果：直接插入准备队列，然后系统自动点击出牌"
const thzx: String = "替换执行：将被替换的目标放入准备队列中，开始执行"
const fzzx: String = "复制执行：将被复制牌放在该牌之后，依次执行"
const fzxgzx: String = "复制效果执行：将被复制的效果加入该牌的效果之中，再执行"

func init_hint(describe: String) -> void:
	if get(describe) != null:
		effect_describe.text = get(describe)
	await get_tree().process_frame
	color_rect.size = effect_describe.get_rect().size
	#print(effect_describe.get_rect().size, color_rect.size)
