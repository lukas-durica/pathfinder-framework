extends CanvasLayer

class_name UserInteraface

enum ButtonID {RUN, PAUSE, STOP, PREVIOUS_STEP, NEXT_STEP}

signal button_pressed(id)
signal menu_item_pressed(id)


func _ready():
	var menu = $UIRoot/PopupMenu
	menu.add_item(Algorithm.to_str(Algorithm.A_STAR_GODOT), 
			Algorithm.A_STAR_GODOT)
	menu.add_item(Algorithm.to_str(Algorithm.A_STAR_DEFAULT),
			Algorithm.A_STAR_DEFAULT)
	menu.add_item(Algorithm.to_str(Algorithm.A_STAR_REDBLOB),
			Algorithm.A_STAR_REDBLOB)

func _on_Run_pressed():
	emit_signal("button_pressed", ButtonID.RUN)

func _on_Pause_pressed():
	emit_signal("button_pressed", ButtonID.PAUSE)

func _on_Stop_pressed():
	emit_signal("button_pressed", ButtonID.STOP)

func _on_PreviousStep_pressed():
	emit_signal("button_pressed", ButtonID.PREVIOUS_STEP)

func _on_NextStep_pressed():
	emit_signal("button_pressed", ButtonID.NEXT_STEP)

func _on_Menu_pressed():
	$UIRoot/PopupMenu.popup()

func _on_PopupMenu_index_pressed(index):
	emit_signal("menu_item_pressed", index)
	
