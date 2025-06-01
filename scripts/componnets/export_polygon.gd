@tool
extends EditorScript
class_name PolygonExporter

# 将Polygon2D导出为PolyResource的解决方案
static func export_polygon_to_resource(
	polygon_node: Polygon2D, 
	save_directory: String, 
	resource_name: String, 
	resource_type: PolyResource.type_of_res = PolyResource.type_of_res.MAP
) -> PolyResource:
	# 参数验证
	if not is_instance_valid(polygon_node):
		push_error("无效的Polygon2D节点")
		return null
		
	if not polygon_node is Polygon2D:
		push_error("目标节点不是Polygon2D类型")
		return null
		
	if polygon_node.polygon.size() < 3:
		push_error("多边形需要至少3个顶点")
		return null
		
	if resource_name.is_empty():
		push_error("资源名称不能为空")
		return null
		
	# 创建资源实例
	var poly_res = PolyResource.new()
	
	# 设置资源属性
	poly_res.name = resource_name
	poly_res.self_type = resource_type
	poly_res.self_polygon = polygon_node.polygon
	
	# 创建安全文件名（移除非法字符）
	var safe_name = resource_name.to_snake_case()
	safe_name = safe_name.replace(" ", "_")
	safe_name = safe_name.replace(":", "")
	safe_name = safe_name.replace("/", "")
	safe_name = safe_name.replace("\\", "")
	safe_name = safe_name.replace("*", "")
	safe_name = safe_name.replace("?", "")
	safe_name = safe_name.replace("\"", "")
	safe_name = safe_name.replace("<", "")
	safe_name = safe_name.replace(">", "")
	safe_name = safe_name.replace("|", "")
	
	# 确保目录存在
	var dir = DirAccess.open(save_directory)
	if not dir:
		if DirAccess.make_dir_recursive_absolute(save_directory) != OK:
			push_error("无法创建目录: " + save_directory)
			return null
	
	# 构建完整路径
	var save_path = save_directory.path_join(safe_name + ".tres")
	
	# 保存资源
	var error = ResourceSaver.save(poly_res, save_path)
	if error != OK:
		push_error("保存资源失败，错误码: %d" % error)
		return null
	
	print("成功导出资源: ", save_path)
	return poly_res

# 编辑器菜单集成
func _run():
	# 获取编辑器选择的节点
	var selected = EditorInterface.get_selection().get_selected_nodes()
	if selected.size() == 0:
		print("请先选择一个Polygon2D节点")
		return
		
	var target_node = selected[0]
	
	# 创建资源类型选择对话框
	var type_dialog = AcceptDialog.new()
	type_dialog.title = "选择资源类型"
	type_dialog.size = Vector2(300, 200)
	
	var vbox = VBoxContainer.new()
	type_dialog.add_child(vbox)
	
	var label = Label.new()
	label.text = "为 '%s' 选择资源类型:" % target_node.name
	vbox.add_child(label)
	
	var type_options = OptionButton.new()
	for i in PolyResource.type_of_res.size():
		type_options.add_item(PolyResource.type_of_res.keys()[i], i)
	vbox.add_child(type_options)
	
	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "输入资源名称"
	name_edit.text = target_node.name
	vbox.add_child(name_edit)
	
	# 类型选择后的文件保存对话框
	type_dialog.confirmed.connect(func():
		var resource_type = type_options.get_selected_id()
		var resource_name = name_edit.text.strip_edges()
		
		if resource_name.is_empty():
			push_error("资源名称不能为空")
			return
			
		var default_dir = "res://resources/polygons/"
		var dialog = EditorFileDialog.new()
		dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		dialog.access = EditorFileDialog.ACCESS_RESOURCES
		dialog.current_dir = default_dir
		dialog.current_file = resource_name + ".tres"
		dialog.add_filter("*.tres", "Godot Resource Files")
		
		dialog.file_selected.connect(func(path):
			var dir_path = path.get_base_dir()
			var result = export_polygon_to_resource(
				target_node, 
				dir_path,
				resource_name,
				resource_type
			)
			if result:
				EditorInterface.get_resource_filesystem().scan()
				print("资源导出成功!")
		)
		
		EditorInterface.get_base_control().add_child(dialog)
		dialog.popup_centered_ratio(0.7)
		type_dialog.queue_free()
	)
	
	type_dialog.canceled.connect(func():
		type_dialog.queue_free()
	)
	
	EditorInterface.get_base_control().add_child(type_dialog)
	type_dialog.popup_centered()
