extends ColorRect

var card_eneity: Array[Card]
var card_list: Array[CardBase]


func _can_drop_data(_pos, data):
	return data is Dictionary && data["card"] is Card

func _drop_data(pos, data):
	var card: Card = data["card"]
	var offset = data["offset"]

	card.original_parent.remove_child(card)
	add_child(card)
	card_eneity.append(card)
	card_list.append(card.card_data)
	# 重置卡牌状态
	card.modulate.a = 1.0
	card.rotation = 0
	card.z_index = 0
	# 放置卡牌
	_place_card()

func _place_card():
	for i in card_eneity.size():
		card_eneity[i].global_position = position + Vector2(Card.SIZE.x * i, 0)
		print(card_eneity[i].global_position)
