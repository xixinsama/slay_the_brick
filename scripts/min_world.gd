extends Node2D
## 预览的小世界
## 可以看到砖块的数量和总生命
class_name MinWorld

## 导入砖块模式资源数据
@export var brick_mode: BrickMode
const BRICK_SCENE = preload("uid://l28w4r2njqbr")

## 计算砖块的数量和总生命
func get_brick_count() -> int:
	if brick_mode == null or brick_mode.mode_info.is_empty():
		return 0
	return brick_mode.mode_info.size()

func get_total_hp() -> int:
	if brick_mode == null or brick_mode.mode_info.is_empty():
		return 0
	var total := 0
	for info in brick_mode.mode_info:
		total += info.brick_hp
	return total

## 实例化所有砖块
func clear_bricks() -> void:
	for c in get_children():
		if c is PolygonBrick:
			c.queue_free()

func spawn_all_bricks() -> void:
	clear_bricks()
	if brick_mode == null:
		return
	for info in brick_mode.mode_info:
		var brick := BRICK_SCENE.instantiate()
		add_child(brick)
		brick.position = info.brick_position
		brick.hits_required = info.brick_hp
		brick.flag = info.flag
