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

func landing_anim(player: PlayerController):
		var position_frames: Array
		var rotation_frames: Array
		var anim_time: float
		
		# ROLL
		if gravity_timer < -0.75:
			position_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.25, Vector3(0, -0.7, 0), Easing.smooth_end ],
				[0.5, Vector3(0, 0, 0) ]
			]
			
			rotation_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.5, Vector3(-PI*2, 0, 0), Easing.smooth_end],
			]
			anim_time = 0.5
		
		# Little bump
		else:
			position_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.1, Vector3(0, -0.4, 0), Easing.smooth_end ],
				[0.3, Vector3(0, 0, 0) ]
			]
		
			rotation_frames = [
				[0, Vector3.ZERO, Easing.linear],
				[0.1, Vector3(-PI/100, 0, 0), Easing.smooth_end],
				[0.3, Vector3.ZERO]
			]
			anim_time = 0.3
			
		player.player_camera.add_anim(anim_time, position_frames, rotation_frames)

func try_jump(player: PlayerController, delta: float):
	if coyote_timer > 0 and Input.is_action_just_pressed("Jump"):
		coyote_timer = -1
		
		# Special direction overrides normal jump force.
		if not special_jump_dir == Vector3.INF:
			player.velocity = special_jump_dir * force
			special_jump_dir = Vector3.INF
		
		# Standard jump
		else:
			player.velocity.y = force
	
	# Advance time
	if coyote_timer > 0:
		coyote_timer -= delta

func apply_gravity(velocity: Vector3, delta: float):
	var t = gravity_timer / gravity_time
	t = clampf(t, 0, 1)
	
	# Gravity gets stronger with time - More satisfying jump
	gravity_timer -= delta
	var multiplier = 1 + (gravity_multiplier - 1) * (1 - t)
	velocity += GRAVITY * delta * multiplier
	
	return velocity

func process_movement(player: PlayerController, delta: float):
	var velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	
	# Air control - only 'x' and 'z' velocity.
	var dir = get_input_direction(player)
	var altered_velocity = velocity + dir * acceleration * delta
	
	# In air, player can move above 'max_velocity',
	# but can not speed up above it through air control.
	var slow_down = velocity.length() > altered_velocity.length()
	if velocity.length() < max_speed or slow_down:
		velocity = altered_velocity
	
	velocity.y = player.velocity.y
	player.velocity = apply_gravity(velocity, delta)
	
	# Override 'y' velcity to jump force in coyote time.
	# When jumping off of the ground, coyote time also applies.
	# Therefore no special handling is needed for jumping off the ground
	# or in the air during coyote time.
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
	print("ENTERING JUMP")

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if climb_condition(player):
		state = player.climbing_state
		
	elif wall_run_front_condition(player):
		state = player.wall_running_front_state
		
	elif wall_run_side_condition(player, true):
		state = player.wall_running_side_state
		state.left = true

	elif wall_run_side_condition(player, false):
		state = player.wall_running_side_state
		state.left = false
		
	elif Input.is_action_pressed("Attack") and player.drop_kill_detector.is_colliding():
		state = player.drop_kill_state

	# Landing
	elif player.is_on_floor():
		can_wall_run = true
		can_side_wall_run = true
		
		if gravity_timer < gravity_time - 0.05:
			landing_anim(player)
			AudioManager.play_sfx("land")
		else:
			AudioManager.play_step_sfx("default")
		
		if not move_condition(player):
			state = player.standing_state
		elif Input.is_action_pressed("Sprint"):
			state = player.running_state
		else:
			state = player.walking_state
	
	if state == null: return
	
	state.enter_state(player)
	player.movement_state = state
