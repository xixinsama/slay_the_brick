## 对一个group的小球使用加法增加伤害
## 示例：
## context: {target: "red", damage: 5}
extends EffectBase
class_name BallDamageAdd

func apply() -> void:
	var target: String = context.get("target")
	var damage: int = context.get("damage")
	match target:
		"red":
			GameManage.redball_damage += damage
		"yellow":
			GameManage.yellowball_damage += damage
		"blue":
			GameManage.blueball_damage += damage
		"purple":
			GameManage.purpleball_damage += damage
		var outer_var:
			print("BallDamageAdd目标错误：", outer_var)
