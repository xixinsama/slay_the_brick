extends Node2D

#@onready var game_viewport_container: SubViewportContainer = $GameViewportContainer
#@onready var game_viewport: SubViewport = $GameViewportContainer/GameViewport
@onready var 手牌区: Hand = $UI/手牌区
@onready var 牌效果信息: Label = $UI/leftPanel/MarginContainer/VBoxContainer/牌效果信息
@onready var 卡牌展示界面: CardDisplayUI = $卡牌展示界面


func _ready() -> void:
	var card = Card.new()
	card.reset_tween.connect(手牌区._update_cards)
	卡牌展示界面.init_display(card_data_all(), "图书馆")


func _on_生成卡牌_pressed() -> void:
	手牌区.draw()


func _on_清除卡牌_pressed() -> void:
	手牌区.discard()
	牌效果信息.text = str(GameManage.get_message_all())

#

## 对应序号转化卡牌
func drew_card_data(ckey: String) -> CardBase:
	#var ckey: String = str(index) + " " # 不知道如何去掉该空格
	var card_info: Dictionary = ImportCard.infosDic.get(ckey)
	var card_base: CardBase = CardBase.new()
	card_base.card_name = card_info.get("card_name")
	card_base.base_cost = card_info.get("base_cost")
	card_base.upgrade_cost = card_info.get("upgrade_cost")
	match card_info.get("type"):
		"道具":
			card_base.card_type = card_base.card_base_type.item
		"技能":
			card_base.card_type = card_base.card_base_type.skill
		"主动":
			card_base.card_type = card_base.card_base_type.active
		"能量":
			card_base.card_type = card_base.card_base_type.ability
		"反制":
			card_base.card_type = card_base.card_base_type.counter
	card_base.effect_description = card_info.get("base_description")
	card_base.upgrade_effect_description = card_info.get("upgrade_description")
	match card_info.get("rarity"):
		"普通":
			card_base.card_rarity = card_base.rarity.normal
		"罕见":
			card_base.card_rarity = card_base.rarity.uncommon
		"稀有":
			card_base.card_rarity = card_base.rarity.rare
	return card_base.duplicate()

## 批量转化卡牌信息
func card_data_all() -> Array[CardBase]:
	var card_list: Array[CardBase]
	for ckey in ImportCard.infosDic.keys():
		card_list.append(drew_card_data(ckey))
	return card_list
