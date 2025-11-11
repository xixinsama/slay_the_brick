extends Node2D
## 战斗场景主脚本
## 负责生成小球，砖块，以及管理回合时间
class_name MainWorld

@onready var wall: WallMap = $Wall
@onready var bricks: Node2D = $Bricks
@onready var balls: Node2D = $Balls
@onready var spawn_here: Marker2D = $Spawn_here
@onready var line_2d: ClockLine = $Spawn_here/Line2D
@onready var color_rect: ColorRect = $ColorRect
@onready var round_countdown: Timer = $round_countdown
@onready var label: Label = $Label

var scene: PackedScene
const BALL = preload("uid://4bi461trk0xs")
const BRICK = preload("uid://l28w4r2njqbr")

var all_balls: Array[PinBall] = []
var num2balls: Array[int] = []

signal ball_phase_end

## 测试用
func _ready() -> void:
	set_process(false)
	round_countdown.timeout.connect(_phase_end)

func _process(_delta: float) -> void:
	label.text = "倒计时："+str(round_countdown.time_left)

func begin_play_ball() -> void:
	num2balls = GameManage.ball_nums.duplicate()
	num_sqawn_ball()
	round_countdown.wait_time = GameManage.level_time_now
	round_countdown.start()
	color_rect.hide()
	set_process(true)

## 实例化子场景
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
	var ball = spawn(spawn_here.global_position, balls, flag)
	balls.append(ball)

## 将球对应为数字
func balls2num() -> void:
	pass
## 按数字序列生成小球
func num_sqawn_ball() -> void:
	for i in num2balls:
		spawn_ball(i)

## 清空小球
func clear_balls() -> void:
	var Balls = balls.get_children()
	for b in Balls:
		b.queue_free()
	balls.clear()
	num2balls.clear()
## 清空砖块
func clear_bricks() -> void:
	var Bricks = bricks.get_children()
	for b in Bricks:
		b.queue_free()
## 清空所有，每回合都清空
func clear_all() -> void:
	clear_balls()
	clear_bricks()

func _phase_end() -> void:
	print("打砖块阶段结束")
	set_process(false)
	ball_phase_end.emit()
	clear_all()
	
func export_brick_mode_data() -> void:
	for brick in bricks.get_children():
		pass
