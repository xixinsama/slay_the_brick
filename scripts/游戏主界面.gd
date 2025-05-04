extends Node2D

@onready var game_viewport_container: SubViewportContainer = $GameViewportContainer
@onready var game_viewport: SubViewport = $GameViewportContainer/GameViewport
@onready var 手牌区: Hand = $UI/手牌区

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		# 获取鼠标在 SubViewportContainer 中的坐标
		var local_pos = game_viewport_container.get_local_mouse_position()
		
		# 转换到 SubViewport 的坐标系
		var viewport_transform = game_viewport.get_final_transform().affine_inverse()
		var viewport_pos = viewport_transform * local_pos
		print("鼠标左键", local_pos, viewport_pos)
		# 复制并转发事件到子视口
		var new_event = event.duplicate()
		new_event.position = viewport_pos
		game_viewport.push_input(new_event)


func _on_生成卡牌_pressed() -> void:
	手牌区.draw()


func _on_清除卡牌_pressed() -> void:
	手牌区.discard()
