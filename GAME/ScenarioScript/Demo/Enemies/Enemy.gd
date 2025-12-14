extends CharacterBody3D

@export var rotation_speed: float = 1.0
@export var scan_angle: float = 45.0
@export var scan_speed: float = 1.5

var is_alerted: bool = false
var base_rotation: float

func _ready():
	base_rotation = rotation.y

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Add detection.
	if is_alerted:
		return

	rotation.y = base_rotation + deg_to_rad(scan_angle) * sin(Time.get_ticks_msec() / 1000.0 * scan_speed)
