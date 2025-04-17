extends EditorContextMenuPlugin

const SGExporter = preload("res://addons/scene_graph_exporter/scene_graph_exporter.gd")
var tree_format := SGExporter.TreeFormat.TEXT
var export_to_file := false
var export_path := "res://"

func _popup_menu(paths):
	var icon = EditorInterface.get_base_control().get_theme_icon("FileTree", "EditorIcons")
	add_context_menu_item("Export Scene Graph", _on_menu_item_pressed, icon)

func _on_menu_item_pressed(paths) -> void:
	var editor_settings = EditorInterface.get_editor_settings()
	tree_format = editor_settings.get("scene_graph_exporter/tree_format")
	export_to_file = editor_settings.get("scene_graph_exporter/export_to_file")
	export_path = editor_settings.get("scene_graph_exporter/export_path")
	var print_contents_of_scenes = editor_settings.get("scene_graph_exporter/print_contents_of_scenes")
	var selection = EditorInterface.get_selection()
	var selected_nodes = selection.get_selected_nodes()
	
	if selected_nodes.size() > 0:
		var root_node = selected_nodes[0]
		var output = print_scene_graph(root_node, tree_format, print_contents_of_scenes)
		if export_to_file:
			var ext := ".md"
			if tree_format == SGExporter.TreeFormat.TEXT:
				ext = ".txt"

			var folder := export_path
			if not folder.ends_with("/") and not folder.ends_with("\\"):
				folder += "/"

			var idx := 1
			var candidate := folder + "%s_%s_%d%s" % [root_node.name, SGExporter.TreeFormat.keys()[tree_format], idx, ext]
			while FileAccess.file_exists(candidate):
				idx += 1
				candidate = folder + "%s_%s_%d%s" % [root_node.name, SGExporter.TreeFormat.keys()[tree_format], idx, ext]

			var file = FileAccess.open(candidate, FileAccess.WRITE)
			if file:
				file.store_string("\n".join(output))
				file.close()
				print("Scene graph exported to %s" % candidate)
			else:
				push_error("Failed to open file for writing: %s" % candidate)
		else:
			print("\n".join(output))


func print_scene_graph(
	node: Node,
	tree_format: int,
	print_contents_of_scenes: bool = false,
	prefix: String = "",
	is_last: bool = true,
	output: Array[String] = [],
	depth: int = 0
) -> Array[String]:
	const CONNECTOR_LAST: String = "└── "
	const CONNECTOR_MID: String = "├── "
	const PREFIX_PIPE: String = "│   "
	const PREFIX_SPACE: String = "    "

	var is_instanced: bool = node.scene_file_path != ""
	var node_label: String = node.name

	if tree_format != SGExporter.TreeFormat.HTML:
		if is_instanced:
			node_label = "*%s*" % node_label
	else:
		if is_instanced:
			node_label = "<i>%s</i>" % node_label

	var connector := ""
	var line := ""
	match tree_format:
		SGExporter.TreeFormat.TEXT:
			connector = CONNECTOR_LAST if (depth > 0 and is_last) else CONNECTOR_MID if (depth > 0) else ""
			line = "%s%s%s (%s)" % [prefix, connector, node_label, node.get_class()]
		SGExporter.TreeFormat.MARKDOWN:
			var md_prefix = "    ".repeat(depth)
			line = "%s- %s (%s)" % [md_prefix if depth > 0 else "", node_label, node.get_class()]
		SGExporter.TreeFormat.HTML:
			connector = CONNECTOR_LAST if (depth > 0 and is_last) else CONNECTOR_MID if (depth > 0) else ""
			line = "%s%s%s (%s)" % [prefix, connector, node_label, node.get_class()]

	output.append(line)

	var children: Array = node.get_children()
	var count: int = children.size()
	var should_recurse: bool = print_contents_of_scenes or (not is_instanced or depth == 0)
	if should_recurse:
		for i in count:
			var child: Node = children[i]
			var is_child_last: bool = (i == count - 1)
			var new_prefix = prefix
			if tree_format == SGExporter.TreeFormat.TEXT or tree_format == SGExporter.TreeFormat.HTML:
				new_prefix += PREFIX_SPACE if is_last else PREFIX_PIPE
			print_scene_graph(child, tree_format, print_contents_of_scenes, new_prefix, is_child_last, output, depth + 1)

	if tree_format == SGExporter.TreeFormat.HTML and prefix == "" and is_last:
		output.insert(0, "<pre>")
		output.append("</pre>")

	return output
