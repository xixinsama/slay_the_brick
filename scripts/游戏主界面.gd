extends Node2D

## 主世界
@onready var world: MainWorld = $world
## UI
@onready var 手牌区: Hand = %手牌区
@onready var 准备队列: ReadyQueue = %准备队列
@onready var card_play: Control = $UI/card_play
@onready var 牌效果信息: Label = $UI/leftPanel/MarginContainer/VBoxContainer/牌效果信息
@onready var select_panel: Panel = $UI/SelectPanel

## 图书馆
@onready var 卡牌展示界面: CardDisplayUI = $卡牌展示界面

enum game_state {
	card_play,
	ball_play
}

signal card_phase_end

func _ready() -> void:
	卡牌展示界面.init_display(ImportCard.all_cardbase, "图书馆")
	GameManage.init_round()
	#Card.Hand2Readqueue.connect(func(s):)

func _process(delta: float) -> void:
	牌效果信息.text = str(GameManage.get_message_all())

func _on_生成卡牌_pressed() -> void:
	手牌区.draw()

func _on_清除卡牌_pressed() -> void:
	手牌区.discard()

func _on_执行卡牌_pressed() -> void:
	GameManage.apply_card_effect()

func _on_结束打牌_pressed() -> void:
	card_phase_end.emit()
	card_play.hide()
	GameManage.level_time_now = GameManage.level_time[GameManage.level_now]
	world.begin_play_ball()

## 测试用，重启整个游戏
func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()
