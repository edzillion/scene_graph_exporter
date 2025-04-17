@tool
extends EditorPlugin

enum TreeFormat {
	TEXT,
	MARKDOWN,
	HTML
}
static var TREE_FORMAT: Dictionary = {
	TreeFormat.TEXT: "Text",
	TreeFormat.MARKDOWN: "Markdown",
	TreeFormat.HTML: "HTML"
}

const MENU_ITEM_NAME := "Export Scene Graph Diagram"
const CONFIG_PATH := "res://addons/scene_graph_exporter/settings.cfg"
const CONFIG_SECTION := "export_settings"
const CONFIG_KEY := "export_folder"

var button_export
var button_pick_folder
var export_folder := "res://"
var context_menu_plugin: EditorContextMenuPlugin

func _enter_tree():
	initialize_settings()
	context_menu_plugin = preload("res://addons/scene_graph_exporter/scene_tree_context_menu.gd").new()
	add_context_menu_plugin(EditorContextMenuPlugin.ContextMenuSlot.CONTEXT_SLOT_SCENE_TREE, context_menu_plugin)

func _exit_tree():
	var editor_settings = EditorInterface.get_editor_settings()
	if editor_settings.has_setting("scene_graph_exporter/export_to_file"):
		editor_settings.erase("scene_graph_exporter/export_to_file")
	if editor_settings.has_setting("scene_graph_exporter/export_path"):
		editor_settings.erase("scene_graph_exporter/export_path")
	if editor_settings.has_setting("scene_graph_exporter/tree_format"):
		editor_settings.erase("scene_graph_exporter/tree_format")
	if editor_settings.has_setting("scene_graph_exporter/print_contents_of_scenes"):
		editor_settings.erase("scene_graph_exporter/print_contents_of_scenes")
	if context_menu_plugin:
		remove_context_menu_plugin(context_menu_plugin)
		context_menu_plugin = null

	
func initialize_settings() -> void:
	var editor_settings = EditorInterface.get_editor_settings()
	if not editor_settings.has_setting("scene_graph_exporter/print_contents_of_scenes"):
		editor_settings.set_setting("scene_graph_exporter/print_contents_of_scenes", false)
		editor_settings.add_property_info({
			"name": "scene_graph_exporter/print_contents_of_scenes",
			"type": TYPE_BOOL,
			"default": false
		})
	if not editor_settings.has_setting("scene_graph_exporter/tree_format"):
		editor_settings.set_setting("scene_graph_exporter/tree_format", TreeFormat.TEXT)
		editor_settings.add_property_info({
			"name": "scene_graph_exporter/tree_format",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Text,Markdown,HTML",
			"default": TreeFormat.TEXT
		})
	if not editor_settings.has_setting("scene_graph_exporter/tree_format"):
		editor_settings.set_setting("scene_graph_exporter/tree_format", TreeFormat.TEXT)
		editor_settings.add_property_info({
			"name": "scene_graph_exporter/tree_format",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Text,Markdown,HTML",
			"default": TreeFormat.TEXT
		})
	if not editor_settings.has_setting("scene_graph_exporter/export_to_file"):
		editor_settings.set_setting("scene_graph_exporter/export_to_file", false)
		editor_settings.add_property_info({
			"name": "scene_graph_exporter/export_to_file",
			"type": TYPE_BOOL,
			"default": false
		})
	if not editor_settings.has_setting("scene_graph_exporter/export_path"):
		editor_settings.set_setting("scene_graph_exporter/export_path", export_folder)
		editor_settings.add_property_info({
			"name": "scene_graph_exporter/export_path",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
			"hint_string": ""
		})
