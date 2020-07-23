extends CanvasLayer

class_name UserInteraface

enum {RUN, PAUSE, STOP, PREVIOUS_STEP, NEXT_STEP}

signal button_pressed(id)
signal menu_item_pressed(id)

onready var menu = $UIRoot/PopupMenu

func _ready():
	#User Interface is invisible due to work with the grid in the editor
	$UIRoot.visible = true
	
	
	
	menu.add_radio_check_item(Algorithm.to_str(Algorithm.A_STAR_GODOT), 
			Algorithm.A_STAR_GODOT)
	menu.add_radio_check_item(Algorithm.to_str(Algorithm.A_STAR_DEFAULT),
			Algorithm.A_STAR_DEFAULT)
	menu.add_radio_check_item(Algorithm.to_str(Algorithm.A_STAR_REDBLOB),
			Algorithm.A_STAR_REDBLOB)


func _on_Run_pressed():
	emit_signal("button_pressed", RUN)

func _on_Pause_pressed():
	emit_signal("button_pressed", PAUSE)

func _on_Stop_pressed():
	emit_signal("button_pressed", STOP)

func _on_PreviousStep_pressed():
	emit_signal("button_pressed", PREVIOUS_STEP)

func _on_NextStep_pressed():
	emit_signal("button_pressed", NEXT_STEP)

func _on_Menu_pressed():
	$UIRoot/PopupMenu.popup()

func _on_PopupMenu_index_pressed(index):
	#get_tree().set_input_as_handled()
	for id in menu.get_item_count():
		menu.set_item_checked(id, false)
	
	menu.set_item_checked(index, true)
	
	emit_signal("menu_item_pressed", index)
	
