extends CanvasLayer

class_name UserInteraface

enum {RUN, PAUSE, STOP, PREVIOUS_STEP, NEXT_STEP}

signal button_pressed(id)



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



