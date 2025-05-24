## 管理和存储游戏信息
## 针对所有阶段
extends Node

var gold_points: int = 0 ## 游戏点数
var lucky: float = 100.0 ## 幸运值
var energy: int = 6 ## 能量
var cardplay_num: int = 12 ## 出牌次数
var value_logs: Dictionary = {}

## 关卡类
var level_now: int = 0
var level_time: Array[float] = [20, 20, 30, 25, 25, 35, 30, 30, 40] ## 每关基础时间
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
var yellowball_damage: int = 2
var yellowball_speed: float = 50
var yellowball_radius: float = 8
## 蓝球
var blueball_damage: int = 4
var blueball_speed: float = 100
var blueball_radius: float = 15
## 紫球
var purpleball_damage: int = 8
var purpleball_speed: float = 200
var purpleball_radius: float = 25

## 卡牌池
## 统统使用该对象池里的实例
const card_prefab = preload("res://scenes/card_blank.tscn")
var card_pool: Array[Card] = []
func get_card_instance() -> Card:
	if card_pool.is_empty():
		return card_prefab.instantiate()
	else:
		#var card_in_pool: Card = card_pool.pop_back()
		#card_in_pool.init_card()
		return card_pool.pop_back()
func recycle_card(card: Card):
	card.get_parent().remove_child(card) ## 将自己从父节点上取下来
	card.hide()
	card.set("card_data", null) ## 这里已经初始化了
	card_pool.append(card)


## 获取分组下的所有小球
func get_balls_in_group(name: String) -> Array:
	return get_tree().get_nodes_in_group(name)

## 获取牌堆
func get_cards_stack(name: String) -> Array[CardBase]:
	var stack := get_node_or_null("UI/"+name)
	if stack is Hand or stack is ReadyQueue or stack is CardStack:
		return stack.get("card_entities")
	else: return []

## 以字典形式返回所有的信息
func get_message_all() -> Dictionary:
	var messages: Dictionary = {
		"points": gold_points,
		"lucky": lucky,
		"energy": energy,
		"cardplay_num": cardplay_num,
		"mouse_click": mouse_click,
		"mouse2points": mouse2points,
		"ball2points": ball2points,
		"speed": [redball_speed, yellowball_speed, blueball_speed, purpleball_speed],
		"damage": [redball_damage, yellowball_damage, blueball_damage, purpleball_damage],
		"radius": [redball_radius, yellowball_radius, blueball_radius, purpleball_radius],
	}
	return messages
	
