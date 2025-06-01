extends Resource
class_name PolyResource
## 不要随意更改已有变量，会破坏已经保存的资源
## 可添加变量，但要同步更新导出器


enum type_of_res {PINBALL, BRICK, MAP}
@export var self_type: type_of_res
@export var name: String
@export var self_polygon: PackedVector2Array
#@export var useable: bool
