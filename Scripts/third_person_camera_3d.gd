extends Node3D

@export var enable := false:
	set(value):
			enable = value
			if not Engine.is_editor_hint():
				%Camera3D.current = value

@export var look_sensitivity: float = 0.005
@export var camlimitdeg = 70

func _ready():
	# _ready essentially makes Godot run this function automatically once the project is run.
	# Makes the mouse invisble and locks it to the center of the screen when the code is run.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# This line below is used for the left and right camera rotations.
		rotation.y -= event.relative.x * look_sensitivity
		# This line below is used for the up and down camrea rotations.
		rotation.x -= event.relative.y * look_sensitivity
		# This line below is used to limit the up and down rotation for the camera
		# The player can only look down at most 80 degrees and at highest 80 degrees
		# deg_to_rad means its converting the Degrees to Radians
		rotation.x = clampf(rotation.x, deg_to_rad(-camlimitdeg), deg_to_rad(camlimitdeg))
	
	if Input.is_action_just_pressed("escape"):
		#make mouse visible when escape is pressed
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		#makes mouse invisible again when you click on screen
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
