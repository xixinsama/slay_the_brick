class_name Card
extends Control

@onready var energy: Label = $MarginContainer/VBoxContainer/HBoxContainer/Energy
@onready var card_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var card_face: TextureRect = $MarginContainer/VBoxContainer/CardFace
@onready var effect: Label = $MarginContainer/VBoxContainer/Effect

const SIZE: Vector2 = Vector2(135, 216)
@export var card_data: CardBase
var original_position: Vector2

func init_card() -> bool:
	if card_data:
		energy.text = str(card_data.energy)
		card_name.text = card_data.card_name
		card_face.texture = card_data.card_face
		effect.text = card_data.effect_description
		return true
	else: return false

func _get_drag_data(_pos):
	set_drag_preview(_create_preview())
	return self

func _create_preview():
	var preview = TextureRect.new()
	preview.texture = card_face.texture
	preview.size = size
	return preview
