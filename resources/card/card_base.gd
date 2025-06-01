## 记录卡牌数据
class_name CardBase
extends Resource

@export var base_cost: int = 0
@export var upgrade_cost: int = 1
enum card_base_type{
	skill,
	item,
	ability,
	active,
	counter
}
@export var card_type: card_base_type
@export var card_name: String = "名字名字"
var backup_name: String = "备注名" ## 在图书馆，玩家可以自定义卡牌昵称
@export var card_face: Texture2D = preload("res://icon.svg") ## 在编辑器里设置
@export var effect_description: String = ""
@export var upgrade_effect_description: String = ""
enum rarity{
	normal,
	uncommon,
	rare
}
@export var card_rarity: rarity

#@export var effects: Array[EffectBase]  ## 存储多个效果，在编辑器里设置
#@export var context: Array[Dictionary] ## 多个效果的上下文，在编辑器里设置
#
#func play(context: Dictionary) -> void:
	#for effect in effects:
		#effect.context = context  # 注入上下文
		#effect.apply()
#
#func _init() -> void:
	#pass
