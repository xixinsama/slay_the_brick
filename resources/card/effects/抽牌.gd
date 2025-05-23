## 从一个牌堆抽牌到手牌
## 示例：
## context: {target: "抽牌堆", nums: 3}
extends EffectBase
class_name GetCards

func apply() -> void:
	var target: String = context.get("target")
	var nums: int = context.get("nums")
	match target:
		"抽牌堆":
			pass
		"弃牌堆":
			pass
		"消耗牌堆":
			pass
		var outer_var:
			print("GetCards目标错误：", outer_var)
