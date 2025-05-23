extends Node
class_name cardInfos ## 卡牌信息导入器，存储，转化，提取
var file_path = "res://resources/card/csv2card/cardInfos.csv"
var infosDic: Dictionary ## 所有卡牌原始数据
var all_cardbase: Array[CardBase] ## 所有卡牌基础数据

func _init()-> void:
	infosDic = read_csv_as_nested_dict(file_path)
	all_cardbase = card_data_all()

## 从磁盘中读取卡牌信息
func read_csv_as_nested_dict(path: String) -> Dictionary:
	var data = {}
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	
	while not file.eof_reached():
		var raw_line = file.get_csv_line()
		# 去除每行的首尾空白字符
		var values = Array(raw_line).map(func(x): return x.strip_edges())
		
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 1:  # 修改判断条件为至少有一个元素
			var key = values[0].strip_edges()  # 关键修复：去除键的首尾空格
			if key.is_empty():
				continue
			
			var row_dict = {}
			for i in range(headers.size()):
				# 处理可能存在的列数不匹配情况
				var value = values[i] if i < values.size() else ""
				row_dict[headers[i].strip_edges()] = value.strip_edges()
			
			data[key] = row_dict
	
	file.close()
	return data


## 对应序号转化卡牌
func drew_card_data(ckey: String) -> CardBase:
	var card_info: Dictionary = infosDic.get(ckey)
	var card_base: CardBase = CardBase.new()
	card_base.card_name = card_info.get("card_name")
	card_base.base_cost = card_info.get("base_cost")
	card_base.upgrade_cost = card_info.get("upgrade_cost")
	match card_info.get("type"):
		"道具":
			card_base.card_type = card_base.card_base_type.item
		"技能":
			card_base.card_type = card_base.card_base_type.skill
		"主动":
			card_base.card_type = card_base.card_base_type.active
		"能量":
			card_base.card_type = card_base.card_base_type.ability
		"反制":
			card_base.card_type = card_base.card_base_type.counter
	card_base.effect_description = card_info.get("base_description")
	card_base.upgrade_effect_description = card_info.get("upgrade_description")
	match card_info.get("rarity"):
		"普通":
			card_base.card_rarity = card_base.rarity.normal
		"罕见":
			card_base.card_rarity = card_base.rarity.uncommon
		"稀有":
			card_base.card_rarity = card_base.rarity.rare
	return card_base.duplicate()

## 批量转化卡牌信息
func card_data_all() -> Array[CardBase]:
	var card_list: Array[CardBase]
	for ckey in infosDic.keys():
		card_list.append(drew_card_data(ckey))
	return card_list
