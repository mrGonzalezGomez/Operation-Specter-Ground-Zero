extends CharacterBody3D

const CROUCH_SPEED = 1.0
const WALK_SPEED = 3.0
const RUN_SPEED = 5.0
const CROUCH_CAM_Y = 0.5
const STAND_CAM_Y = 1.0

var mouse_sensitivity := 0.003
var current_speed := WALK_SPEED
var is_running := false
var is_crouched := false

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$FirstPersonCamera.rotate_x(-event.relative.y * mouse_sensitivity)
		$FirstPersonCamera.rotation.x = clamp($FirstPersonCamera.rotation.x, deg_to_rad(-70), deg_to_rad(70))

	if event.is_action_pressed("crouch"):
		is_crouched = !is_crouched
		$FirstPersonCamera.position.y = CROUCH_CAM_Y if is_crouched else STAND_CAM_Y

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_crouched:
		is_running = false
		current_speed = CROUCH_SPEED
	else:
		is_running = Input.is_action_pressed("ui_shift")
		current_speed = RUN_SPEED if is_running else WALK_SPEED

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func _restart_level() -> void:
	get_tree().reload_current_scene()

func _on_vision_cone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		call_deferred("_restart_level")
