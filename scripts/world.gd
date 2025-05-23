extends Node2D

## 挂载节点的节点
@onready var bricks_here: Node2D = $bricks
@onready var balls_here: Node2D = $balls
@onready var spawn_here: Marker2D = $spawn_here

var scene: PackedScene
const BALL = preload("res://scenes/ball.tscn")
const BRICK = preload("res://scenes/brick.tscn")

var balls: Array[PinBall] = []
var num2balls: Array[int] = []

## 测试用
func _ready() -> void:
	num2balls =  Array(range(4), TYPE_INT, "", null) 
	num_sqawn_ball()

func spawn(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene, flag: int = 0) -> Node:
	assert(scene is PackedScene, "Error: The scene export was never set on this spawner component.")
	var instance = scene.instantiate()
	parent.add_child(instance)
	instance.global_position = global_spawn_position
	# 将参数传递给子弹的脚本
	if instance.has_method("initialize"):
		instance.initialize(flag)
	return instance

## 生成位置固定，整数0123对应红黄蓝紫球等
func spawn_ball(flag: int = 0) -> void:
	scene = BALL
	var ball = spawn(spawn_here.position, balls_here, flag)
	balls.append(ball)

## 将球对应为数字
func balls2num() -> void:
	pass
## 按数字序列生成小球
func num_sqawn_ball() -> void:
	for i in num2balls:
		spawn_ball(i)


## 按模式生成砖(未完成)
func spawn_brick(mod: int = 0) -> void:
	scene = BRICK
	pass

## 清空小球
func clear_balls() -> void:
	var Balls = balls_here.get_children()
	for b in Balls:
		b.queue_free()
	balls.clear()
## 清空砖块
func clear_bricks() -> void:
	var Bricks = bricks_here.get_children()
	for b in Bricks:
		b.queue_free()
## 清空所有，每回合都清空
func clear_all() -> void:
	clear_balls()
	clear_bricks()
