extends CharacterBody2D
## 2D弹球
class_name PinBall

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var cs_2p: CS2P = $CS2P
@onready var label: Label = $Label
@onready var line_2d: Line2D = $Line2D

## 初始速度（像素/秒）
@export var initial_speed: float = 50
## 最大允许速度（防止速度无限增加）
@export var max_speed: float = 999
## 最小速度（保证手感，不至于停滞）
@export var min_speed: float = 20
## 碰撞伤害
@export var damage: int = 1
## 是否启用速度维持（防止物理衰减）
@export var maintain_speed: bool = true
## 是否启用方向过滤（防止纯垂直/水平方向）
@export var enable_direction_filter: bool = true
## 方向过滤阈值（越大越避免接近水平/垂直）
@export_range(0.0, 0.7, 0.01) var direction_axis_threshold: float = 0.2
## 碰撞后保持速度模长（避免因数值误差变慢）
@export var preserve_speed_on_bounce: bool = true
## 物理弹跳模拟
@export var physics_bounce_simulation: bool = false
## 重力加速度（仅在物理弹跳模式下生效）
@export var gravity: float = 980.0
## 弹性系数：0-1（仅在物理弹跳模式下生效）
@export_range(0.0, 1.0, 0.01) var bounce_coefficient: float = 0.9
## 最大下落速度（仅在物理弹跳模式下生效）
@export var max_fall_speed: float = 2000.0
## 休眠速度阈值（接地且近似静止时进入休眠以省性能）
@export var sleep_speed_threshold: float = 15.0
## 静止持续时间（秒）超过该值将休眠
@export var sleep_after_seconds: float = 1.0
# 小球半径（用于小球-小球穿透校正）；若碰撞形状半径不同请同步配置
var ball_radius: float = 18.0
## 穿透余量修正（越大越强制分离，避免黏连）
@export var penetration_slop: float = 5
## 最小冲击速度阈值：低于此值不施加冲量，仅做分离，防抖
@export var min_impact_speed: float = 8
## 黏住检测：速度与实际位移差异的倍率阈值
@export var sticky_discrepancy_ratio: float = 2.5
## 黏住检测：实际速度阈值（实际速度过低时才认为可能黏住）
@export var sticky_actual_speed_threshold: float = 20.0
## 黏住检测：连续帧数阈值
@export var sticky_confirm_frames: int = 2
## 黏住修正：额外分离距离
@export var sticky_separation_extra: float = 4.0


# 碰撞信号（用于触发特效/音效）
signal collided(normal: Vector2)

func start(start_position: Vector2, direction: float = 0.0):
	position = start_position
	velocity = Vector2(initial_speed, 0).rotated(direction)
	# 方向安全微扰
	_nudge_axis_locked_direction()
	_wake_up()

func _ready():
	_prev_pos = global_position

## 设置小球的初始速度（供外部调用时也可用）
func generate_initial_velocity():
	var valid_direction := false
	var attempt_count := 0
	while not valid_direction and attempt_count < 100:
		var base_angle := randf_range(-PI/4, PI/4)
		if randi() % 2 == 0:
			base_angle += PI
		var direction := Vector2.from_angle(base_angle)
		if enable_direction_filter:
			if abs(direction.x) > direction_axis_threshold and abs(direction.y) > direction_axis_threshold:
				valid_direction = true
		else:
			# 轻微随机扰动
			direction += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
			valid_direction = true
		if valid_direction:
			velocity = direction.normalized() * max(initial_speed, min_speed)
		attempt_count += 1
	if not valid_direction:
		velocity = Vector2(0.707, 0.707) * max(initial_speed, min_speed)
	_nudge_axis_locked_direction()
	_wake_up()

func _physics_process(delta: float) -> void:
	show_message()
	# 根据模式应用不同的运动学
	if physics_bounce_simulation:
		# 应用重力（限制最大落速）
		var vy: float = velocity.y + gravity * delta
		velocity.y = min(vy, max_fall_speed)
	else:
		# 保持速度与方向健康
		if maintain_speed:
			_maintain_velocity_magnitude()
			_nudge_axis_locked_direction()
	# 运动与碰撞
	var collision := move_and_collide(velocity * delta)
	if collision:
		var normal: Vector2 = collision.get_normal()
		if physics_bounce_simulation:
			# 物理模式：区分与 PinBall 碰撞与其他碰撞
			var other := collision.get_collider()
			if other is PinBall:
				# 仅由 instance_id 较小者处理一次，避免双重计算
				if get_instance_id() < other.get_instance_id():
					_handle_ball_ball_impulse(other as PinBall, normal)
				_last_ball_collided = other as PinBall
				_recent_ball_collision_time = 0.25
			else:
				velocity = velocity.bounce(normal) * bounce_coefficient
				_clamp_max_speed()
		else:
			# 街机模式：保持碰撞前速度模长
			var speed_before: float = velocity.length()
			velocity = velocity.bounce(normal)
			if preserve_speed_on_bounce and speed_before > 0.0:
				velocity = velocity.normalized() * speed_before
			# 维持速度上/下限
			_maintain_velocity_magnitude()
		# 触发伤害
		var collider := collision.get_collider()
		if collider and collider.has_method("take_hit"):
			collider.take_hit(damage, 0, self)
		# 发射碰撞信号
		collided.emit(normal)
		# 接地检测（用于休眠）
		if physics_bounce_simulation and normal.y > 0.7 and not (collision.get_collider() is PinBall):
			_last_on_floor = true
	else:
		_last_on_floor = false

	# 休眠判定（仅在物理模式）
	if physics_bounce_simulation:
		if _eligible_for_sleep():
			_still_time += delta
			if _still_time >= sleep_after_seconds:
				_sleep()
		else:
			_still_time = 0.0
		# 黏住检测与修正
		_sticky_check_and_fix(delta)
		_recent_ball_collision_time = max(_recent_ball_collision_time - delta, 0.0)

	# 更新上一帧位置
	_prev_pos = global_position

### 内部函数，处理反弹效果
#func _integrate_forces(state: PhysicsDirectBodyState2D):
	## 处理所有碰撞事件
	#_process_collisions(state)
#
#func _process_collisions(state: PhysicsDirectBodyState2D):
	## 遍历所有碰撞接触点
	#for i in state.get_contact_count():
		#var collision_normal = state.get_contact_local_normal(i)
		#var collider = state.get_contact_collider_object(i)
		#
		#var new_vel = current_vel.bounce(collision_normal)
		##print(current_vel, collision_normal, new_vel)
		#state.linear_velocity = new_vel
		## 更新速度
		#current_vel = new_vel
		## 触发碰撞信号
		#emit_signal("collided", collision_normal)
		#
		## 处理砖块伤害
		#if collider and collider.has_method("take_hit"):
			#collider.take_hit(damage, 0, self)

## 显示信息
func show_message() -> void:
	if label:
		label.text = "vel=" + str(velocity) + " speed=" + str(int(velocity.length()))
	if line_2d:
		if line_2d.points.size() < 2:
			line_2d.points = PackedVector2Array([Vector2.ZERO, velocity])
		else:
			# 安全更新第二个点
			line_2d.set_point_position(1, velocity)
		line_2d.queue_redraw()

## 重置小球
func reset_ball(pos: Vector2):
	velocity = Vector2.ZERO
	global_position = pos
	rotation = 0
	if enable_direction_filter:
		# 延迟一帧再启动可避免穿透
		await get_tree().process_frame
		generate_initial_velocity()
	_wake_up()

## 维持速度模长上下限
func _maintain_velocity_magnitude():
	var speed: float = velocity.length()
	if speed == 0:
		return
	var clamped: float = clamp(speed, min_speed, max_speed)
	if abs(clamped - speed) > 0.001:
		velocity = velocity.normalized() * clamped

## 仅限制最大速度（物理弹跳模式）
func _clamp_max_speed():
	var speed: float = velocity.length()
	if speed > max_speed and speed > 0.0:
		velocity = velocity.normalized() * max_speed

## 避免接近纯水平/垂直的方向（微扰）
func _nudge_axis_locked_direction():
	if not enable_direction_filter:
		return
	var v: Vector2 = velocity
	if v.length() == 0:
		return
	var n: Vector2 = v.normalized()
	var need_nudge: bool = abs(n.x) <= direction_axis_threshold or abs(n.y) <= direction_axis_threshold
	if need_nudge:
		var angle: float = n.angle() + randf_range(-0.12, 0.12)
		var speed: float = max(v.length(), min_speed)
		velocity = Vector2.from_angle(angle).normalized() * speed

## 处理 PinBall 与 PinBall 之间的弹性冲量
func _handle_ball_ball_impulse(other: PinBall, normal: Vector2):
	# 1) 位置分离：根据两球中心与半径校正，避免持续重叠造成“黏住”
	var delta: Vector2 = global_position - other.global_position
	var distance: float = max(delta.length(), 0.0001)
	var required: float = (ball_radius + other.ball_radius) - distance + penetration_slop
	if required > 0.0:
		var corr_dir: Vector2 = delta / distance
		# 平分位移，双方各退一半
		var correction: Vector2 = corr_dir * (required * 0.5)
		global_position += correction
		other.global_position -= correction
		# 位置修正后更新法线用于冲量（与分离方向一致）
		normal = corr_dir
	# 2) 冲量：仅在接近或正在接近（rel_n_speed<0）且超过最小冲击速度时施加
	var rel_v: Vector2 = velocity - other.velocity
	var rel_n_speed: float = rel_v.dot(normal)
	if rel_n_speed < -min_impact_speed:
		var e: float = clamp(bounce_coefficient, 0.0, 1.0)
		# 质量相同：J = -0.5*(1+e)*(v_rel·n)
		var J: float = -0.5 * (1.0 + e) * rel_n_speed
		var impulse: Vector2 = J * normal
		velocity += impulse
		other.apply_external_impulse(-impulse)
		# 限速
		_clamp_max_speed()
		other._clamp_max_speed()
	# 3) 唤醒
	_wake_up()
	other._wake_up()

## 黏住检测：当理论速度远大于根据位置变化推算的实际速度，且最近发生过小球-小球碰撞，则认定可能黏住
func _sticky_check_and_fix(delta: float):
	if _recent_ball_collision_time <= 0.0:
		_suspect_sticky_frames = 0
		return
	var frame_disp: Vector2 = global_position - _prev_pos
	var actual_speed: float = frame_disp.length() / max(delta, 0.0001)
	var reported_speed: float = velocity.length()
	var discrepant: bool = reported_speed > sticky_discrepancy_ratio * max(actual_speed, 0.0001)
	var actual_low: bool = actual_speed <= sticky_actual_speed_threshold
	if discrepant and actual_low:
		_suspect_sticky_frames += 1
	else:
		_suspect_sticky_frames = 0
	if _suspect_sticky_frames >= sticky_confirm_frames:
		# 调整速度为实际速度方向与大小
		if frame_disp.length() > 0.0001:
			velocity = frame_disp / max(delta, 0.0001)
		# 若有最近的另一小球，则强制分离一定距离
		if _last_ball_collided and is_instance_valid(_last_ball_collided):
			var other: PinBall = _last_ball_collided
			var delta_pos: Vector2 = global_position - other.global_position
			var dist: float = max(delta_pos.length(), 0.0001)
			var desired: float = (ball_radius + other.ball_radius + sticky_separation_extra)
			var need: float = desired - dist
			if need > 0.0:
				var dir: Vector2 = delta_pos / dist
				var half_push: Vector2 = dir * (need * 0.5)
				global_position += half_push
				other.global_position -= half_push
		# 修复后重置计数，避免重复修正
		_suspect_sticky_frames = 0

## 外部施加冲量（用于被动受力/唤醒）
func apply_external_impulse(impulse: Vector2):
	velocity += impulse
	_wake_up()

## 判断是否满足休眠条件
func _eligible_for_sleep() -> bool:
	# 接地、速度很低、几乎不动
	if not _last_on_floor:
		return false
	var speed: float = velocity.length()
	return speed <= sleep_speed_threshold and abs(velocity.y) <= sleep_speed_threshold

var _still_time: float = 0.0
var _is_sleeping: bool = false
var _last_on_floor: bool = false
var _prev_pos: Vector2
var _recent_ball_collision_time: float = 0.0
var _last_ball_collided: PinBall
var _suspect_sticky_frames: int = 0

func _sleep():
	_is_sleeping = true
	set_physics_process(false)

func _wake_up():
	if _is_sleeping:
		_is_sleeping = false
		_still_time = 0.0
		set_physics_process(true)
