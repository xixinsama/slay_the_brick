## 记录卡牌数据
class_name CardBase
extends Resource

@export var energy: int = 1
@export var card_name: String = "名字名字"
@export var card_face: Texture2D = preload("res://icon.svg")
@export var effect_description: String = ""
@export var effect_script: Script

func apply_effect(game_manager: Node) -> void:
	var effect = effect_script.new()
	effect.execute(game_manager)

var card_list: Dictionary = {
	"id": 0001,
	CardBase: "res://resources/card/card_message/0001.tres"
	
}
