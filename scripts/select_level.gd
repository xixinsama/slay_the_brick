extends Node2D
## 选择关卡界面

@onready var min_world: MinWorld = $MarginContainer/HBoxContainer/SubViewportContainer/SubViewport/MinWorld
@onready var min_world_2: MinWorld = $MarginContainer/HBoxContainer/SubViewportContainer2/SubViewport/MinWorld2
@onready var min_world_3: MinWorld = $MarginContainer/HBoxContainer/SubViewportContainer3/SubViewport/MinWorld3
@onready var left_select: Button = $LeftSelect
@onready var mid_select: Button = $MidSelect
@onready var right_select: Button = $RightSelect
@onready var shop_enter: Button = $ShopEnter
@onready var 反制牌堆: ReadyQueue = %反制牌堆

func _ready() -> void:
	# 连接信号
	left_select.pressed.connect(_on_select_button_pressed.bind(0))
	mid_select.pressed.connect(_on_select_button_pressed.bind(1))
	right_select.pressed.connect(_on_select_button_pressed.bind(2))
	shop_enter.toggled.connect(_on_shop_enter_toggled)
	
	random_map()

## 给世界随机赋予地图，并生成
## 第一步：获取游戏种子，生成随机数
## 第二步：将随机数映射到地图和砖块资源
## 同步随机数到全局，给下一个场景使用
## 第三步：生成砖块
## 第四步：砖块权重，提升血量
func random_map() -> void:
	min_world.brick_mode = preload("uid://bn6choigoallm")
	min_world_2.brick_mode = preload("uid://7bpvu506w477")
	min_world_3.brick_mode = preload("uid://0nnshtto6n3h")
	min_world.spawn_all_bricks()
	min_world_2.spawn_all_bricks()
	min_world_3.spawn_all_bricks()

## 显示关卡信息到按钮
func show_button_text() -> void:
	pass

## 切换到战斗场景
func _on_select_button_pressed(button: int) -> void:
	print(button)

func _on_shop_enter_toggled(toggled_on: bool) -> void:
	print(toggled_on)
