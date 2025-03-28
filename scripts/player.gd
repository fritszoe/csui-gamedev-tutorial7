extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var max_jumps: int = 2  # Jumlah maksimum lompatan
@export var mouse_sensitivity: float = 0.3
@onready var camera: Camera3D = $Head/Camera3D
@export var sprint_multiplier: float = 1.5
@export var walk_multiplier: float = 0.5

var camera_x_rotation: float = 0.0
var jumps_left: int = 2  # Mulai dengan jumlah maksimum lompatan

@onready var head: Node3D = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

func _physics_process(delta):
	var movement_vector = Vector3.ZERO
	var current_speed = speed
	
	if Input.is_action_pressed("walk"):
		current_speed *= walk_multiplier

	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier  # Sprint tetap menang kalau dua-duanya ditekan
	
	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x

	movement_vector = movement_vector.normalized()

	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Reset jump saat menyentuh tanah
	if is_on_floor():
		jumps_left = max_jumps  # Reset ke jumlah maksimum

	# Double jump
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = jump_power
		jumps_left -= 1  # Kurangi jumlah lompatan

	move_and_slide()
