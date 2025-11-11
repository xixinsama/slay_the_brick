extends Node2D

@onready var pool: WallMap = $Pool
@onready var balls: Node2D = $Balls
@onready var marker_2d: Marker2D = $Marker2D

const BALL = preload("uid://4bi461trk0xs")

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_spawn_ball)

func _spawn_ball() -> void:
	var ball: PinBall = BALL.instantiate()
	balls.add_child(ball)
	ball.global_position = marker_2d.global_position
	ball.physics_bounce_simulation = true
	ball.collision_mask = 7 ## 相互碰撞
	ball.velocity += Vector2(randi_range(-20, 20), 0)
