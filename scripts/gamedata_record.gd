## 全局变量，记录游戏主场景的各种数值信息、
## 针对于打牌阶段的效果施加到打砖块阶段
extends Node

var gold_points: int = 0 ## 游戏点数
var lucky: float = 100.0 ## 幸运值
var energy: int = 6 ## 能量
var cardplay_num: int = 12 ## 出牌次数

## 鼠标类
var can_mouse: bool = true ## 能否鼠标点方块
var mouse_click: int = 10 ## 鼠标点方块的伤害
var mouse2points: float = 1.0 ## 鼠标点方块的积分转换效率

## 球类
var ball2points: float = 1.0 ## 球撞方块的积分转换效率
## 红球
var redball_damage: int = 1
var redball_speed: float = 10
var redball_radius: float = 10
## 黄球
var yellowball_damage: int = 1
var yellowball_speed: float = 10
var yellowball_radius: float = 10
## 蓝球
var blueball_damage: int = 1
var blueball_speed: float = 10
var blueball_radius: float = 10
## 紫球
var purpleball_damage: int = 1
var purpleball_speed: float = 10
var purpleball_radius: float = 10
