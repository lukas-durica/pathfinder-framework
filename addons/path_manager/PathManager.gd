tool

extends EditorPlugin

var editor_selection : = get_editor_interface().get_selection()

var edited_path : ConnectablePath = null

func _enter_tree():
	print("---===PathManager enabled===---")
	
	Physics2DServer.set_active(true)
	
	add_custom_type("ConnectablePath", "Path2D", 
			preload("ConnectablePath.gd"),
			preload("res://addons/path_manager/Path2D.svg"))
	
	#cannot use add_castom_type for PathfindingPath due to this bug/lack of
	#feature
	#https://github.com/godotengine/godot/issues/29548
	
	editor_selection.connect("selection_changed", self, "_on_selection_changed")

func _exit_tree():
	editor_selection.disconnect("selection_changed", self, 
			"_on_selection_changed")
	
	remove_custom_type("ConnectablePath")
	
	Physics2DServer.set_active(false)
	
	print("---===PathManager disabled===---")

func apply_changes():
	for point_area in get_tree().get_nodes_in_group("point_areas"):
		point_area.update_connections()

func handles(object : Object) -> bool:

	#if the object is the same object as edited path change nothing
	if is_instance_valid(edited_path):
		deselect_edited_path()
	return object is ConnectablePath

func edit(object : Object):
	select_edited_path(object)

func _on_selection_changed():
	# if unclicked the edited path deselect edited_path
	if is_instance_valid(edited_path) \
			and editor_selection.get_selected_nodes().empty():
		deselect_edited_path()

func select_edited_path(object):
	# wait one frame, if scene is open, one idle frame is needed
	# for areas to detect overlaps
	print(name, " select_edited_path: ", object.name)
	edited_path = object
	edited_path.set_path_selected(true)
	
func deselect_edited_path():
	print(name, " deselect_edited_path: ", edited_path.name)
	edited_path.set_path_selected(false)
	edited_path = null
	print(name, " deselected!")
