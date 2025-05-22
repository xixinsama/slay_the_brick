## 使一个Node2D节点晃动的组件
class_name ShakeComponent
extends Node

# 你应该摇动精灵而不是根节点，否则你会得到意想不到的行为
# 因为我们正在操纵节点的位置并将其移动到 0,0 
# 就是相对位置和绝对位置，我们只希望调整其相对位置
# 如果有坐标问题就先找这里，如振荡
@export var node: Node ## 摇晃目标
@export var shake_amount: float = 2.0 ## 震动幅度
@export var shake_duration: float = 0.4 ## 震动持续时间

# 存储当前震动幅度，将随时间减小
var shake = 0
var node_position_now: Vector2 #记录当前位置

func _ready() -> void:
	set_physics_process(false)

func tween_shake():
	shake = shake_amount
	node_position_now = node.global_position
	set_physics_process(true)
	# 创造一个缓动效果，并最终降到0
	var tween := create_tween().tween_property(self, "shake", 0.0, shake_duration).from_current()
	await tween.finished
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	node.global_position = node_position_now + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	
