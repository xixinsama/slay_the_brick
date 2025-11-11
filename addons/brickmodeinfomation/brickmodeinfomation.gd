@tool
extends EditorPlugin
## 负责保存砖块模式数据
class_name BrickInfoSaverPlugin

var _pending_root: Node
var _file_dialog: EditorFileDialog

func _enter_tree() -> void:
	add_tool_menu_item("导出选中节点为砖块模式", _export_selected_as_brick_mode)
	# 创建保存对话框（只创建一次）
	var ui_root := EditorInterface.get_base_control()
	_file_dialog = EditorFileDialog.new()
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_file_dialog.add_filter("*.tres;TRES Resource")
	_file_dialog.title = "保存砖块模式资源"
	ui_root.add_child(_file_dialog)
	_file_dialog.file_selected.connect(_on_save_path_chosen)

func _exit_tree() -> void:
	remove_tool_menu_item("导出选中节点为砖块模式")
	if is_instance_valid(_file_dialog):
		_file_dialog.queue_free()
		_file_dialog = null

func save_brick_info(root: Node, save_path: String, mode_name: String) -> bool:
	if root == null:
		push_error("未选择根节点，无法导出砖块模式")
		return false
	var infos: Array[BrickInfo] = []
	_gather_brick_infos(root, infos)
	if infos.is_empty():
		push_warning("未在所选节点下找到任何 PolygonBrick 节点")
		return false
	var mode := BrickMode.new()
	mode.mode_name = mode_name
	mode.mode_info = infos
	# 确保扩展名为 .tres
	if not save_path.ends_with(".tres"):
		save_path += ".tres"
	var err := ResourceSaver.save(mode, save_path)
	if err != OK:
		push_error("保存失败: %s" % [err])
		return false
	print("砖块模式已保存:", save_path)
	return true

func _gather_brick_infos(node: Node, out: Array[BrickInfo]) -> void:
	for child in node.get_children():
		if child is PolygonBrick:
			var b: PolygonBrick = child
			var info := BrickInfo.new()
			info.brick_position = b.position
			info.brick_hp = b.hits_required
			info.flag = b.flag
			out.append(info)
		# 递归继续向下查找
		if child.get_child_count() > 0:
			_gather_brick_infos(child, out)

func _export_selected_as_brick_mode() -> void:
	var selection := EditorInterface.get_selection()
	var selected := selection.get_selected_nodes()
	if selected.is_empty():
		push_warning("请先在场景树中选择一个节点作为根节点")
		return
	_pending_root = selected[0]
	var suggested_name := _pending_root.name
	if is_instance_valid(_file_dialog):
		_file_dialog.current_dir = "res://resources/bricks_mode"
		_file_dialog.current_file = "%s.tres" % suggested_name
		_file_dialog.popup_centered_ratio(0.5)

func _on_save_path_chosen(path: String) -> void:
	if _pending_root == null:
		return
	var file_path := path
	if not file_path.ends_with(".tres"):
		file_path += ".tres"
	var mode_name := file_path.get_file().get_basename()
	save_brick_info(_pending_root, file_path, mode_name)
	_pending_root = null
