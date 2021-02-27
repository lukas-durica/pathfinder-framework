extends Node2D

var actual_time_step : = 1200
var start_time_step : = 1343
var start_time_step2 : = 1892
var cycle_size : = 500



func _ready():
	var time_step = start_time_step % cycle_size
	#var max_value = 
	print(time_step)
