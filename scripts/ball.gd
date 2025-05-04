extends RigidBody2D
class_name PinballBall

## 初始速度（像素/秒）
@export var initial_speed: float = 700
## 最大允许速度（防止速度无限增加）
@export var max_speed: float = 999
## 碰撞伤害
@export var damage: int = 1
## 是否启用速度维持（防止物理衰减）
@export var maintain_speed: bool = true
## 是否启用方向过滤（防止纯垂直/水平方向）
@export var enable_direction_filter: bool = true

@onready var label: Label = $Label

# 碰撞信号（用于触发特效/音效）
signal collided(normal: Vector2)

func _ready():
	setup_physics_material()
	generate_initial_velocity()
	add_to_group("紫色小球")

## 设置小球的物理材质
func setup_physics_material():
	var mat = PhysicsMaterial.new()
	mat.bounce = 1.0
	mat.rough = 0.0
	physics_material_override = mat

var current_vel: Vector2 ## 记录当前速度
## 设置小球的初始速度
func generate_initial_velocity():
	var valid_direction = false
	var attempt_count = 0
	
	# 使用循环保证生成有效方向
	while not valid_direction and attempt_count < 100:
		var base_angle = randf_range(-PI/4, PI/4)  # -45度 ~ +45度
		if randi() % 2 == 0:
			base_angle += PI  # 添加180度偏移
		
		var direction = Vector2.from_angle(base_angle)
		
		# 方向过滤检查
		if enable_direction_filter:
			if abs(direction.x) > 0.2 and abs(direction.y) > 0.2:
				valid_direction = true
		else:
			# 添加一个随机扰动
			direction += Vector2(randi_range(-5, 5), randi_range(-5, 5))
			valid_direction = true
		
		if valid_direction:
			apply_central_impulse(direction * initial_speed)
		
		attempt_count += 1
	
	# 如果无法生成有效方向则强制设置
	if not valid_direction:
		apply_central_impulse(Vector2(0.707, 0.707) * initial_speed)
	
	await get_tree().create_timer(0.1).timeout
	current_vel = linear_velocity

func _physics_process(_delta: float) -> void:
	show_message()

## 内部函数，处理反弹效果
func _integrate_forces(state: PhysicsDirectBodyState2D):
	# 处理所有碰撞事件
	_process_collisions(state)

func _process_collisions(state: PhysicsDirectBodyState2D):
	# 遍历所有碰撞接触点
	for i in state.get_contact_count():
		var collision_normal = state.get_contact_local_normal(i)
		var collider = state.get_contact_collider_object(i)
		
		var new_vel = current_vel.bounce(collision_normal)
		#print(current_vel, collision_normal, new_vel)
		state.linear_velocity = new_vel
		# 更新速度
		current_vel = new_vel
		# 触发碰撞信号
		emit_signal("collided", collision_normal)
		
		# 处理砖块伤害
		if collider and collider.has_method("take_hit"):
			collider.take_hit(damage)

func show_message() -> void:
	label.text = str(linear_velocity)

## 重置小球
func reset_ball(pos: Vector2):
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	global_position = pos
	generate_initial_velocity()
