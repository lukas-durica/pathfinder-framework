extends Camera2D
"""
Zoom - Scrolling the wheel
Movement - pressing the wheel and moving
"""

const MIN_ZOOM = 0.4
const MAX_ZOOM = INF
const ZOOM_SENSITIVITY = 0.1

# variable that holds actual zoom (the further is the camera from the screen 
# the greater the number)
var zoom_factor : = 1.0

var is_middle_button_pressed : = false

# movement and zooming of the camera
func _input(event : InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			zoom(-1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom(1)
		if event.button_index == BUTTON_MIDDLE:
			is_middle_button_pressed = true
	elif event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == BUTTON_MIDDLE:
			is_middle_button_pressed = false
		
	if is_middle_button_pressed and event is InputEventMouseMotion:
		#get position relative to the previous position (position at the last 
		#frame)
		move(event.relative)

func zoom(direction):
	#set the zoom_factor and clamp it between MIN_ZOOM and MAX_ZOOM
	#the further is the camera from the screen (i.e. the smaller is the zoom -
	#greater zoom variable) the greater is the zoomed distance 
	#thats the reason ZOOM_SENSITIVITY is multiplied by zoom_factor
	zoom_factor = clamp(zoom_factor + ZOOM_SENSITIVITY * direction * zoom_factor, 
			MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2.ONE * zoom_factor


func move(direction):
	position -= direction * zoom_factor
	
