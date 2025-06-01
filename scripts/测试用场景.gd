extends Node2D

@onready var ball: PinBall = $balls/ball
@onready var ball_2: PinBall = $balls/ball2

func _ready() -> void:
	ball.initialize(1)
	ball_2.initialize(2)
	Engine.time_scale = 2.0
