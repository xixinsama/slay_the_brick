## 对一个group的小球使用加法增加伤害
extends EffectBase

func apply() -> void:
	var target = context.get("target")
	var damage: int = context.get("damage")
	target.take_damage(damage)
