tool

class_name DragNotifier2D extends Node2D

signal dragging_started()
signal dragging_ended()

export(NodePath) var sprite_node_path : NodePath setget _set_sprite_node_path

var _is_left_button_down : = false
var _is_object_dragged : = false
var _last_global_pos : = Vector2.ZERO

onready var _sprite : Sprite

func _set_sprite_node_path(value : NodePath):
	sprite_node_path = value
	call_deferred("process_sprite")

func process_sprite():
	if has_node(sprite_node_path):
		_sprite = get_node(sprite_node_path)

func _ready():
	if Engine.editor_hint:
		set_notify_transform(true)
		_last_global_pos = global_position

func _process(delta : float):
	if Engine.editor_hint:
		if was_left_button_just_pressed():
			_is_left_button_down = true
		elif was_left_button_just_released():
			if _is_object_dragged:
				emit_signal("dragging_ended")
				_is_object_dragged = false
				print("dragging ended")
			
			_is_left_button_down = false
			_last_global_pos = global_position

		if does_dragging_started():
			if is_instance_valid(_sprite):
				if is_mouse_on_sprite():
					_is_object_dragged = true
					emit_signal("dragging_started")
					print("dragging_started")
			else:
				push_error(name + " : Assign Sprite Node Path!")
			_last_global_pos = global_position

func was_left_button_just_pressed() -> bool:
	return Input.is_mouse_button_pressed(BUTTON_LEFT) \
			and not _is_left_button_down
			
func was_left_button_just_released() -> bool:
	return not Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and _is_left_button_down

func does_dragging_started() -> bool:
	return _is_left_button_down and not _is_object_dragged \
				and _last_global_pos != global_position

func is_mouse_on_sprite() -> bool:
	return _sprite.get_rect().has_point(to_local(get_global_mouse_position()))


