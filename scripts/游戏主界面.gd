extends Node2D

#@onready var game_viewport_container: SubViewportContainer = $GameViewportContainer
#@onready var game_viewport: SubViewport = $GameViewportContainer/GameViewport
@onready var 手牌区: Hand = $UI/手牌区

func _ready() -> void:
	var card = Card.new()
	card.reset_tween.connect(手牌区._update_cards)

func _on_生成卡牌_pressed() -> void:
	手牌区.draw()


func _on_清除卡牌_pressed() -> void:
	手牌区.discard()
