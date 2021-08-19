tool

class_name DragNotifier2D extends Node2D

signal dragging_started()
signal dragging_ended()

export(NodePath) var sprite_node_path setget _set_sprite_node_path


var _sprite : Sprite
var _is_left_button_down : = false
var _is_object_dragged : = false
var _last_global_pos : = Vector2.ZERO
var _is_ready : = false

func _set_sprite_node_path(value : NodePath):
	
	#print("_set_sprite_node_path value: ", value)
	
		
	
	if not value.is_empty() and get_node_or_null(value):
		_sprite = get_node(value)
		sprite_node_path = value
		

func _ready():
	if Engine.editor_hint:
		print(name, ": ready")
		_last_global_pos = global_position
		set_notify_transform(true)
		_is_ready = true
		

func _process(delta : float):
	if Engine.editor_hint:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and not _is_left_button_down:
			_is_left_button_down = true
		elif not Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and _is_left_button_down:
			if _is_object_dragged:
				emit_signal("dragging_ended")
				print("dragging ended")
			_is_left_button_down = false
			_is_object_dragged = false

		if _is_left_button_down and not _is_object_dragged \
				and _last_global_pos != global_position:
			if is_instance_valid(_sprite):
				if is_mouse_on_sprite():
					_is_object_dragged = true
					emit_signal("dragging_started")
					print("dragging_started")
			else:
				push_error(name + " : Assign Sprite Node Path!")

func is_mouse_on_sprite() -> bool:
	return _sprite.get_rect().has_point(to_local(get_global_mouse_position()))
