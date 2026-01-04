extends CharacterBody3D

@export var scan_angle: float = 30.0
@export var scan_speed: float = 2.0

@onready var vision_mesh := $VisionCone
@onready var vision_hitbox := $VisionCone/Hitbox

const VISION_FAR = 0.8
const VISION_CROUCH_FAR = 0.5
const CONE_LENGTH_STAND = 0.8
const CONE_LENGTH_CROUCH = 0.5

var base_rotation: float
var state := 0
var timer := 0.0

func _ready():
	base_rotation = rotation.y

func _physics_process(delta: float) -> void:
	timer += delta

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var length = CONE_LENGTH_CROUCH if player.is_crouched else CONE_LENGTH_STAND
		vision_mesh.scale.x = length
		if vision_hitbox.shape:
			vision_hitbox.shape.radius = VISION_CROUCH_FAR if player.is_crouched else VISION_FAR

	match state:

		0:
			if timer == 0:
				velocity = Vector3.ZERO
			velocity = -global_transform.basis.z * 3.0
			move_and_slide()
			if timer >= 2.0:
				_next_state()

		1:
			velocity = Vector3.ZERO
			move_and_slide()
			if timer >= 0.5:
				_next_state()

		2:
			rotation.y = base_rotation + deg_to_rad(scan_angle) * sin(timer * scan_speed)
			if timer >= PI * 2 / scan_speed * 2:
				rotation.y = base_rotation
				_next_state()

		3:
			rotation.y = base_rotation
			if timer >= 0.5:
				_next_state()

		4:
			base_rotation += deg_to_rad(90)
			rotation.y = base_rotation
			_next_state()

		5:
			velocity = Vector3.ZERO
			move_and_slide()
			if timer >= 0.5:
				_next_state()

func _next_state():
	timer = 0.0
	state = (state + 1) % 6
