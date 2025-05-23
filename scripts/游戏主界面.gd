extends Node2D

#@onready var game_viewport_container: SubViewportContainer = $GameViewportContainer
#@onready var game_viewport: SubViewport = $GameViewportContainer/GameViewport
@onready var 手牌区: Hand = $UI/手牌区
@onready var 牌效果信息: Label = $UI/leftPanel/MarginContainer/VBoxContainer/牌效果信息
@onready var 卡牌展示界面: CardDisplayUI = $卡牌展示界面


func _ready() -> void:
	卡牌展示界面.init_display(ImportCard.all_cardbase, "图书馆")
	#Card.Hand2Readqueue.connect(func(s):)

func _process(delta: float) -> void:
	牌效果信息.text = str(GameManage.get_message_all())

func _on_生成卡牌_pressed() -> void:
	手牌区.draw()

func _on_清除卡牌_pressed() -> void:
	手牌区.discard()
	
