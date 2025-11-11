extends Node2D

@onready var ball: PinBall = $balls/ball
@onready var ball_2: PinBall = $balls/ball2

func _ready() -> void:
	ball.start(ball.position, 25)
	ball_2.start(ball_2.position, 100)
	Engine.time_scale = 5.0
