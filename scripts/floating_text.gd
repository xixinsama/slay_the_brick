extends Node2D

@onready var label: Label = $Label

var position_tween: Tween
var scale_tween: Tween

func display_damage_text(damage_amount: float, flag: int = 0)-> void:
	if position_tween != null and position_tween.is_running():
		position_tween.kill()
	if scale_tween != null and scale_tween.is_running():
		scale_tween.kill()
	
	label.text = str(int(damage_amount))
	if flag == 0:
		pass
	elif flag == 1:
		label.theme.set_color("flat_theme", "theme", Color.CORNFLOWER_BLUE)
	position_tween = create_tween()
	scale_tween = create_tween()
	position_tween.tween_property(self, "global_position", global_position + Vector2.UP * 16, 0.3)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	position_tween.tween_property(self, "global_position", global_position + Vector2.UP * 48, 0.3)
	scale_tween.tween_property(self,"scale", Vector2.ZERO, 0.4)
	position_tween.tween_callback(queue_free)
