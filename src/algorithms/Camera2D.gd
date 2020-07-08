extends Camera2D

const MIN_ZOOM = 0.4
const MAX_ZOOM = INF
const ZOOM_SENSITIVITY = 0.1

var zoom_ratio : = 1.0

var is_middle_button_pressed : = false

func _ready():
	pass # Replace with function body.


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
		move(event.relative)

func zoom(direction):
	#the further is the camera from the screen (i.e. the smaller is the zoom -
	#greater zoom variable) the greater is the zoomed distance 
	#thats the reason ZOOM_SENSITIVITY is multiplied by zoom_ratio
	zoom_ratio = clamp(zoom_ratio + ZOOM_SENSITIVITY * direction * zoom_ratio, 
			MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2.ONE * zoom_ratio


func move(direction):
	position -= direction * zoom_ratio
	
