extends NewMovementState
class_name JumpingState

var acceleration: float
var max_speed: float
var force: float
var coyote_time: float
var coyote_timer: float
var ignore_coyote_timer: bool
var special_jump_dir: Vector3

var gravity_time: float = 0.2
var gravity_multiplier: float = 7
var gravity_timer: float = 0

func _init(_force: float, _acceleration: float, _max_speed: float, _coyote_time: float, _gravity_time: float, _gravity_multiplier: float):
	self.acceleration = _acceleration
	self.max_speed = _max_speed
	self.force = _force
	self.coyote_time = _coyote_time
	self.gravity_time = _gravity_time
	self.gravity_multiplier = _gravity_multiplier
	self.special_jump_dir = Vector3.INF
	self.ignore_coyote_timer = false
	
func try_jump(player: PlayerController, delta: float):
	if coyote_timer > 0 and Input.is_action_just_pressed("Jump"):
		if not special_jump_dir == Vector3.INF:
			player.velocity = special_jump_dir * force
			special_jump_dir = Vector3.INF
		else:
			player.velocity.y = force
		
		coyote_timer = -1
	
	if coyote_timer > 0:
		coyote_timer -= delta

func apply_gravity(velocity: Vector3, delta: float):
	var t = gravity_timer / gravity_time
	t = clampf(t, 0, 1)
	gravity_timer -= delta
	var multiplier = 1 + (gravity_multiplier - 1) * (1 - t)
	velocity += GRAVITY * delta * multiplier
	return velocity

func process_movement(player: PlayerController, delta: float):
	
	var dir = get_input_direction(player)
	var velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var altered_velocity = velocity + dir * acceleration * delta
	
	if velocity.length() < max_speed or velocity.length() > altered_velocity.length():
		velocity = altered_velocity
		
	velocity.y = player.velocity.y
	player.velocity = apply_gravity(velocity, delta)
	
	try_jump(player, delta)
	player.move_and_slide()

func enter_state(player: PlayerController):
	player.animation_player.play_anim("Jumping")
	
	if ignore_coyote_timer:
		coyote_timer = -1
		ignore_coyote_timer = false
	else:
		coyote_timer = coyote_time
		
	gravity_timer = gravity_time
	player.player_camera.bob_end()
	print("ENTERING JUMP")

func determine_state(player: PlayerController):
	if climbing_cooldown < 0 and Input.is_action_pressed("Jump") and player.climb_detector_higher.is_colliding() or player.climb_detector_lower.is_colliding():
			player.movement_state = player.climbing_state
			player.movement_state.enter_state(player)
	
	elif player.is_on_floor():
		can_wall_run = true
		can_side_wall_run = true
		
		if _get_ground_dir(player).is_zero_approx():
			player.movement_state = player.standing_state
		elif Input.is_action_pressed("Sprint"):
			player.movement_state = player.running_state
		else:
			player.movement_state = player.walking_state
			
		player.movement_state.enter_state(player)
		damp_velocity = Vector3.ZERO
		AudioManager.play_sfx("land")
		var position_frames: Array
		var rotation_frames: Array
		var anim_time: float
		
		if gravity_timer < -0.75:
			position_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.25, Vector3(0, -0.7, 0), Easing.smooth_end ],
				#[0.3, Vector3(0, 0.1, 0) ],
				[0.5, Vector3(0, 0, 0) ]
			]
			
			rotation_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.5, Vector3(-PI*2, 0, 0), Easing.smooth_end],
			]
			anim_time = 0.5
		else:
			position_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.1, Vector3(0, -0.4, 0), Easing.smooth_end ],
				#[0.3, Vector3(0, 0.1, 0) ],
				[0.3, Vector3(0, 0, 0) ]
			]
		
			rotation_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.1, Vector3(-PI/100, 0, 0), Easing.smooth_end],
				#[0.3, Vector3(PI/200, 0, 0)],
				[0.3, Vector3.ZERO]
			]
			anim_time = 0.3
		
		if gravity_timer < gravity_time - 0.05:
			player.player_camera.add_anim(anim_time, position_frames, rotation_frames)
	
	elif player.wall_climb_detector_front.is_colliding() and Input.is_action_pressed("Jump") and wall_running_cooldown <= 0 and can_wall_run:
		player.movement_state = player.wall_running_front_state
		player.movement_state.enter_state(player)
	elif player.wall_climb_detector_left.is_colliding() and Input.is_action_pressed("Jump") and wall_running_cooldown <= 0 and can_wall_run and can_side_wall_run:
		player.movement_state = player.wall_running_side_state
		player.movement_state.left = true
		player.movement_state.enter_state(player)
	elif player.wall_climb_detector_right.is_colliding() and Input.is_action_pressed("Jump") and wall_running_cooldown <= 0 and can_wall_run and can_side_wall_run:
		player.movement_state = player.wall_running_side_state
		player.movement_state.left = false
		player.movement_state.enter_state(player)
	elif Input.is_action_pressed("Attack") and player.drop_kill_detector.is_colliding():
		player.movement_state = player.drop_kill_state
		player.movement_state.enter_state(player)
