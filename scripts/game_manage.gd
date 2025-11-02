## 管理和存储游戏信息
## 针对所有阶段
extends Node

var gold_points: int = 0 ## 游戏点数
var lucky: float = 100.0 ## 幸运值
var energy: int = 12 ## 能量上限
var queue_field: int = 13 ## 准备队列栏位
var cardplay_num: int = 12 ## 出牌次数
var card_excute_logs: Array = [] ## 卡牌被执行情况信息
var card_play_logs: Array = [] ## 卡牌效果执行情况信息
var value_logs: Array = [] ## 弹球阶段的日志，只保留一回合

## 关卡类
#class leveltime
var level_now: int = 0
var level_time: Array[float] = [200, 20, 30, 25, 25, 35, 30, 30, 40] ## 每关基础时间
var layer_now: int = 0 ## 第几层
var level_time_now: float ## 实际关卡时间

## 鼠标类
var can_mouse: bool = true ## 能否鼠标点方块
var mouse_click: int = 1 ## 鼠标点方块的伤害
var mouse2points: float = 1.0 ## 鼠标点方块的积分转换效率

## 球类
var ball_nums: Array[int] = [] ## 各个球数量信息。[1,3,2,4,1]分别代表 红 蓝 黄 紫 红 球各一个
var ball2points: float = 1.0 ## 球撞方块的积分转换效率
## 红球
var redball_damage: int = 1
var redball_speed: float = 20
var redball_radius: float = 5
## 黄球
var yellowball_damage: int = 1
var yellowball_speed: float = 1000
var yellowball_radius: float = 100
## 蓝球
var blueball_damage: int = 4
var blueball_speed: float = 100
var blueball_radius: float = 15
## 紫球
var purpleball_damage: int = 8
var purpleball_speed: float = 200
var purpleball_radius: float = 25
##_____________________________________________________________________________

## 卡牌池
## 统统使用该对象池里的实例
const card_prefab = preload("res://scenes/card_blank.tscn")
var card_pool: Array[Card] = []
func get_card_instance() -> Card:
	if card_pool.is_empty():
		return card_prefab.instantiate()
	else:
		return card_pool.pop_back()
func recycle_card(card: Card):
	card.get_parent().remove_child(card) ## 将自己从父节点上取下来
	card.hide()
	card.set("card_data", null) ## 这里已经初始化了
	card_pool.append(card)

##_____________________________________________________________________________

## 路径
const rq: String = "/root/main/UI/card_play/准备队列"   ## 准备队列
const hd: String = "/root/main/UI/card_play/手牌区"    ## 手牌区
const dr: String = "/root/main/UI/card_play/抽牌堆"    ## 抽牌堆
const dc: String = "/root/main/UI/card_play/弃牌堆"    ## 弃牌堆
const ep: String = "/root/main/UI/card_play/消耗牌堆"   ## 消耗牌堆
const vn: String = "/root/main/UI/card_play/消失牌堆"   ## 消失牌堆

## 获取分组下的所有小球
func get_balls_in_group(name: String) -> Array:
	return get_tree().get_nodes_in_group(name)

## 从卡牌实体获得卡牌信息
func entity2massage(card_instances: Array[Card]) -> Array[CardBase]:
	var cb: Array[CardBase] = []
	for i in card_instances:
		cb.append(i.card_data)
	return cb

## 获取牌堆
## 0: 准备队列
## 1: 手牌区
func get_cards_stack(index: int = 0) -> Array:
	match index:
		0:
			var node: ReadyQueue = get_node(rq)
			return node.card_instances.duplicate()
		1:
			var node: Hand = get_node(hd)
			return node.card_instances.duplicate()
		_:
			print("GameManage：不在牌堆索引中")
			return []

## 初始化回合信息
var _origin_card_sequence: Array[Card] = [] ## 原始牌序
var _execute_card_sequence: Array[Card] = [] ## 执行牌序
var energy_now: int
var is_next_passed: bool = false
var next_excute_times: int = 1 ## 下张牌执行效果次数
func init_round() -> void:
	energy_now = energy


## 以字典形式返回所有的信息
func get_message_all() -> Dictionary:
	var messages: Dictionary = {
		"points": gold_points,
		"lucky": lucky,
		"energy": energy_now,
		"cardplay_num": cardplay_num,
		"mouse_click": mouse_click,
		"mouse2points": mouse2points,
		"ball2points": ball2points,
		"speed": [redball_speed, yellowball_speed, blueball_speed, purpleball_speed],
		"damage": [redball_damage, yellowball_damage, blueball_damage, purpleball_damage],
		"radius": [redball_radius, yellowball_radius, blueball_radius, purpleball_radius],
	}
	return messages


## 解析器（内部调用）
## 将原始牌序转换为执行牌序
func _card_parser() -> void:
	pass

## 传输卡牌数据进入其他牌堆
## 默认依照类型
## 指定flag来代替
## 1：准；2：手；3：弃；4：消耗；5：抽；6：消失
func goto_stack(cb: CardBase, flag: int = 0) -> void:
	if flag == 0:
		match cb.card_type:
			0:
				var node: CardStack = get_node(dc)
				node.add_card_by_base(cb)
			1:
				var node: CardStack = get_node(vn)
				node.current_cards.append(cb)
			2:
				var node: CardStack = get_node(ep)
				node.current_cards.append(cb)
			3:
				var node: CardStack = get_node(vn)
				node.current_cards.append(cb)
			4:
				var node: CardStack = get_node(vn)
				node.current_cards.append(cb)
	else:
		match flag:
			1:
				pass
			2:
				pass
			3:
				pass
			4:
				pass
			5:
				pass
			6:
				pass
			_:
				print("非法的flag.")
				return

## 消耗能量
## 疑似bug
func cost_test(cost: int) -> bool:
	if cost <= energy_now:
		energy_now -= cost
		return true
	else: return false

## 执行器
func apply_card_effect():
	_origin_card_sequence = get_cards_stack(0)
	if _origin_card_sequence == []:
		print("准备队列为空，不消耗出牌次数")
	else:
		cardplay_num -= 1
	# 依次执行
	# 当前卡牌是否被跳过
	# 能量
	for running_card in _origin_card_sequence:
		if is_next_passed:
			print(running_card.card_data.card_name, "被跳过")
			card_excute_logs.append({
				"card": running_card.card_data.card_name,
				"execute": false,
				"why": "passed"
			})
			is_next_passed = false
			break
		else:
			# 获取实际能量消耗
			var actual_cost: int = running_card.card_data.upgrade_cost \
				if running_card.is_upgrade \
				else running_card.card_data.upgrade_cost
			## 消耗能量，并执行
			if cost_test(actual_cost):
				var effect_method = "_handle_%s" % running_card.card_data.card_name.to_lower().replace(" ", "_")
				if self.has_method(effect_method):
					# 效果执行次数
					for i in range(next_excute_times):
						call(effect_method, running_card)
						card_excute_logs.append({
							"card": running_card.card_data.card_name,
							"execute": true,
							"why": next_excute_times
						})
					
					next_excute_times = 1
				else:
					card_excute_logs.append({
						"card": running_card.card_data.card_name,
						"execute": false,
						"why": "No_this_method"
					})
			else:
				print(running_card.card_data.card_name, "能量不足不予执行")
				card_excute_logs.append({
				"card": running_card.card_data.card_name,
				"execute": false,
				"why": "unexecute_by_cost"
				})
				break
	# 卡牌离开准备队列


# 具体效果实现 --------------------------------------------
func _handle_模板(card: Card) -> void:
	## 效果
	## 日志记录
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "效果",
		"execute": true
	})

func _handle_红球(card: Card) -> void:
	ball_nums.append(1)
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "生成红球",
		"execute": true
	})

func _handle_黄球(card: Card) -> void:
	ball_nums.append(2)
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "生成黄球",
		"execute": true
	})

func _handle_变快(card: Card) -> void:
	var s_value: float = 1.1 if card.is_upgrade else 1.05
	redball_speed *= s_value
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "redball_speed*"+str(s_value),
		"execute": true
	})

func _handle_变大(card: Card) -> void:
	var r_value: float = 1.1 if card.is_upgrade else 1.05
	var s_value: float = 0.95 if card.is_upgrade else 0.97
	redball_radius *= r_value
	redball_speed *= s_value
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "redball_radius*"+str(r_value)+"redball_speed*"+str(s_value),
		"execute": true
	})

func _handle_变强(card: Card) -> void:
	var d_value: int = 2 if card.is_upgrade else 1
	redball_damage += d_value
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "redball_damage+"+str(d_value),
		"execute": true
	})

func _handle_对撞实验(card: Card) -> void: ##bug
	## 效果
	var rq: ReadyQueue = get_node(rq)
	var index: int = rq.card_instances.find(card) ##bug
	if index <= 1: 
		card_play_logs.append({
			"card": card.card_data.card_name,
			"effect": "不符合判定条件： 前无两张牌",
			"execute": false
		})
		return
	else:
		var temp_card1: Card = rq.card_instances[index-1]
		var temp_card2: Card = rq.card_instances[index-2]
		if temp_card1.card_name == temp_card2.card_name:
			var e_value: int = 5 if card.is_upgrade else 4
			energy_now += e_value
			## 日志记录
			card_play_logs.append({
				"card": card.card_data.card_name,
				"effect": "energy_now+"+str(e_value),
				"execute": true
			})
		else:
			card_play_logs.append({
				"card": card.card_data.card_name,
				"effect": "不符合判定条件： 前两张牌不同",
				"execute": false
			})
			return

func _handle_升级(card: Card) -> void:
	## 效果
	# 获得目标等级球的索引
	var indices := []
	for i in range(ball_nums.size()):
		if card.is_upgrade:
			if ball_nums[i] <= 2:
				indices.append(i)
		else:
			if ball_nums[i] <= 1:
				indices.append(i)
	# 随机升级目标球
	if not indices.is_empty():
		var index: int = indices[randi_range(0, indices.size()-1)]
		ball_nums[index] += 1
		card_play_logs.append({
			"card": card.card_data.card_name,
			"effect": "upgrade"+str(index),
			"execute": true
		})
	else:
		card_play_logs.append({
			"card": card.card_data.card_name,
			"effect": "球不存在",
			"execute": true
		})
		return

func _handle_你给路打哟(card: Card):
	var last_two := card_excute_logs.slice(-2, -1)
	print(last_two)
	
func _handle_变高(card: Card) -> void:
	## 效果
	var value: float = 1.6 if card.is_upgrade else 1.5
	ball2points *= value
	## 日志记录
	card_play_logs.append({
		"card": card.card_data.card_name,
		"effect": "ball2points*" + str(value),
		"execute": true
	})
