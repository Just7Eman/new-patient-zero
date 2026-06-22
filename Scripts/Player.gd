extends CharacterBody3D

@onready var first_person_camera_3d: Camera3D = $FirstPersonCamera3D
@onready var third_person_camera_3d: Node3D = $ThirdPersonCamera3D


var input_direction : Vector2
var speed : float

@export var walk_speed = 5.0
@export var sprint_speed = 10.0
@export var sneak_speed = 2.0
@export var acceleration = 60.0
@export var jump_velocity = 4.5
@export var air_control = 5.0
@export var air_resistance = 2.0

func _unhandled_input(_event):
	if Input.is_action_just_pressed("escape"):
		_mouse_control()
	
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _mouse_control():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("end_run"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("cam_swap"):
		_change_camera()
		
func _change_camera():
	# This just decides which camera will currently be used by the player at the moment.
	if first_person_camera_3d.current:
		first_person_camera_3d.enable = false
		third_person_camera_3d.enable = true
	else:
		first_person_camera_3d.enable = true
		third_person_camera_3d.enable = false


func _physics_process(delta):
	#apply gravity when in the air
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle Sprint, Sneak, and Walk
	if Input.is_action_pressed("sprint") and is_on_floor():
		speed = sprint_speed
	elif Input.is_action_pressed("sneak"):
		speed = sneak_speed
	else:
		speed = walk_speed
	
	# Handles Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	#Get Direction Input
	input_direction = Input.get_vector("left", "right", "down", "up")
	var cam_basis = _get_camera_transform()


# Camera's left and right direction
	var cam_right = cam_basis.x
# Camera's Forward direction
	var cam_forward = -cam_basis.z

	# flatten to ground plane
	cam_right.y = 0
	cam_forward.y = 0
# What the 2 lines above do is remove the up and down tilt components, which stops looking up or down from changing the "ground direction"
	cam_right = cam_right.normalized()
	cam_forward = cam_forward.normalized()
	# Makes the direction have consistent length

	var direction = (cam_right * input_direction.x + cam_forward * input_direction.y)
	if direction.length_squared() > 0.000001:
		direction = direction.normalized()

	
	#Calculate movement
	var target_velocity = direction * speed
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if is_on_floor():
		#Ground Movement
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
		#Using X and Z axis since this is on the ground
	else:
		#Air Movement
		if direction:
			horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_control * delta)
		
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, air_resistance * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	
	move_and_slide()
	
	
func _get_camera_transform():
	# This just determine which cameras global transform will be called, depending on which camera is currently being used.
	# This is used for getting direction of the Player
	if first_person_camera_3d.current:
		return first_person_camera_3d.transform.basis
	else:
		return third_person_camera_3d.transform.basis
		
