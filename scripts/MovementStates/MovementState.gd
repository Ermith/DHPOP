class_name NewMovementState

const GRAVITY = Vector3.DOWN * 10
static var damp_velocity: Vector3
static var wall_running_cooldown: float
static var sliding_cooldown: float
static var can_wall_run: bool = true
static var can_side_wall_run: bool = true
static var climbing_cooldown: float

var attack: String = ""

func _get_ground_dir(player: PlayerController):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	return player.basis * direction

func get_input_direction(player: PlayerController):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var dir = player.basis * Vector3(input_dir.x, 0, input_dir.y)
	return dir

func move_condition(player: PlayerController):
	return not get_input_direction(player).is_zero_approx()

func ground_velocity(player: PlayerController, speed: float, delta: float):
	var dir = get_input_direction(player)
	var ground_vel = Vector3(player.velocity.x, 0, player.velocity.z)
	var tmp = Math.smooth_damp_vec(ground_vel, dir * speed, damp_velocity, 0.055, delta)
	ground_vel = tmp[0]
	damp_velocity = tmp[1]
	
	return ground_vel

func wall_run_front_condition(player: PlayerController):
	var climb_detection = player.wall_climb_detector_front.is_colliding()
	var jump_request = Input.is_action_pressed("Jump")
	var precondition = can_wall_run and wall_running_cooldown <= 0
	return climb_detection and jump_request and precondition
		

func wall_run_side_condition(player: PlayerController, left: bool):
	var climb_detection: bool
	if left:
		climb_detection = player.wall_climb_detector_left.is_colliding()
	else:
		climb_detection = player.wall_climb_detector_right.is_colliding()
		
	var jump_request = Input.is_action_pressed("Jump")
	var precondition = can_wall_run and can_side_wall_run and wall_running_cooldown <= 0
	return climb_detection and jump_request and precondition

func climb_condition(player: PlayerController):
	var climb_request = Input.is_action_pressed("Jump")
	var higher_detection = player.climb_detector_higher.is_colliding()
	var lower_detection = player.climb_detector_lower.is_colliding()
	return climbing_cooldown < 0 and climb_request and (higher_detection or lower_detection)

func process_movement(_player: PlayerController, _delta: float):
	pass

func process_rotation(player: PlayerController):
	player.global_rotation.y = player.player_camera.global_rotation.y
	pass

func enter_state(_player: PlayerController):
	pass

func determine_state(_player: PlayerController):
	pass

static func static_process(delta: float):
	if wall_running_cooldown >= 0: wall_running_cooldown -= delta
	if sliding_cooldown >= 0: sliding_cooldown -= delta
	if climbing_cooldown >= 0: climbing_cooldown -= delta
