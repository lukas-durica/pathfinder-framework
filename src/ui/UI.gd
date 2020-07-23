extends CanvasLayer

class_name UserInteraface

enum {RUN, PAUSE, STOP, PREVIOUS_STEP, NEXT_STEP}

signal button_pressed(id)
signal algorithms_id_pressed(id)
signal options_id_pressed(id)

onready var algorithms = $UIRoot/Algorithms
onready var options = $UIRoot/Options

func _ready():
	#User Interface is invisible due to work with the grid in the editor
	$UIRoot.visible = true
	
	
	algorithms.add_radio_check_item(Algorithm.to_str(Algorithm.A_STAR_GODOT), 
			Algorithm.A_STAR_GODOT)
	algorithms.add_radio_check_item(Algorithm.to_str(Algorithm.A_STAR_DEFAULT),
			Algorithm.A_STAR_DEFAULT)
	algorithms.add_radio_check_item(Algorithm.to_str(Algorithm.A_STAR_REDBLOB),
			Algorithm.A_STAR_REDBLOB)
	
	options.add_check_item("8 directional", 1)


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




func _on_Options_pressed():
	options.popup()


func _on_Algorithm_pressed():
	algorithms.popup()

func check_item(index : int):
	for idx in algorithms.get_item_count():
		algorithms.set_item_checked(idx, false)
		
	algorithms.set_item_checked(index, true)

func _on_Algorithms_id_pressed(id):
	var index = algorithms.get_item_index(id)
	check_item(index)
	emit_signal("algorithms_id_pressed", id)


func _on_Options_id_pressed(id):
	var index = options.get_item_index(id)
	options.toggle_item_checked(index)
	emit_signal("options_id_pressed", id)
