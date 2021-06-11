tool

extends EditorPlugin

const CONNECTION_SCENE = preload("res://addons/path_manager/Connection.tscn")

var editor_selection : = get_editor_interface().get_selection()

var edited_path : ConnectablePath = null

var point_area_entered_data : = {}
#var path_area_entered_data : = {}

var is_left_mouse_button_pressed : = false

func _enter_tree():
	print("---===PathManager enabled===---")
	
	Physics2DServer.set_active(true)
	
	add_custom_type("ConnectablePath", "Path2D", 
			preload("ConnectablePath.gd"),
			preload("res://addons/path_manager/Path2D.svg"))
	
	editor_selection.connect("selection_changed", self, "_on_selection_changed")

func apply_changes():
	for point_area in get_tree().get_nodes_in_group("point_areas"):
		point_area.update_connections()
	

func _exit_tree():
	editor_selection.disconnect("selection_changed", self, 
			"_on_selection_changed")
			
	remove_custom_type("ConnectablePath")
	
	Physics2DServer.set_active(false)
	
	print("---===PathManager disabled===---")

#func get_root() -> Node:
#	return get_tree().get_edited_scene_root()
#
# chceck the type of the object, if it will return true the edit(object) is 
# called
func handles(object : Object) -> bool:

	#if the object is the same object as edited path change nothing
	if edited_path:
		deselect_edited_path()
	return object is ConnectablePath

func edit(object : Object):
	select_edited_path(object)

func _on_selection_changed():
	# if unclicked the edited path deselect edited_path
	if edited_path and editor_selection.get_selected_nodes().empty():
		deselect_edited_path()

func select_edited_path(object):
	edited_path = object
	edited_path.color_path(true)
	edited_path.color_passable_connections()
	edited_path.set_marginal_points_labeling(true)
	

func deselect_edited_path():
	edited_path.set_marginal_points_labeling(false)
	edited_path.color_path(false)
	edited_path.color_passable_connections()
	
	edited_path = null
