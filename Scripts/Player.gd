extends CharacterBody3D

var input_direction : Vector2
var speed : float

@export var walk_speed = 5.0
@export var sprint_speed = 10.0
@export var sneak_speed = 2.0
@export var acceleration = 60.0
@export var jump_velocity = 4.5
@export var air_control = 5.0
@export var air_resistance = 2.0

@onready var first_person_camera_3d: Camera3D = $Head/FirstPersonCamera3D

func _ready():
	#Sets mouse to center of scree and makes it invisible
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("end_run"):
		get_tree().quit()


func _physics_process(delta):
	#apply gravity when in the air
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle Sprint
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
	input_direction = Input.get_vector("left", "right", "up", "down")
	var direction = (first_person_camera_3d.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
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
