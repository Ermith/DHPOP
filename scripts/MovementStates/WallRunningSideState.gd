extends NewMovementState
class_name WallRunningSideState

var speed: float
var direction: Vector3
var timer: float
var time: float
var anim
var left: bool
var detector

const easing_time = 0.2

func _init(_speed: float, _time: float = 2):
	self.speed = _speed
	self.time = _time
	self.timer = _time

func enter_state(player: PlayerController):
	if left: player.animation_player.play_anim("WallRunningLeft")
	else: player.animation_player.play_anim("WallRunningRight")
	
	if left: attack = "WallRunLeftAttack"
	else: attack = "WallRunRightAttack"
	
	if left: detector = player.wall_climb_detector_left
	else: detector = player.wall_climb_detector_right
	
	timer = time
	
	# Tilt the camera left of right
	var angle = PI / 20
	var offset = 0.25
	if left: angle *= -1; offset *= -0.5
	
	var position_keyframes = [
		[0, Vector3.ZERO],
		[easing_time, Vector3(offset, 0, 0), Easing.smooth_end],
		[time - easing_time, Vector3(offset, 0, 0)],
		[time, Vector3.ZERO]
	]
	var rotation_keyframes = [
		[0, Vector3.ZERO],
		[easing_time, Vector3(0, 0, angle), Easing.smooth_end],
		[time - easing_time, Vector3(0, 0, angle)],
		[time, Vector3(0, 0, 0)],
	]
	
	anim = player.player_camera.add_anim(time, position_keyframes, rotation_keyframes)
	player.player_camera.bob_start(0.0, 0.03, 0.11)
	
	var s = "RIGHT"
	if left: s = "LEFT"
	print("ENTERING WALL RUNNING ", s, " STATE")

func process_movement(player: PlayerController, delta: float):
	var t = 1 - timer / time
	timer -= delta
	
	# Adjusts the direction to run across the wall.
	# This means it should also work on curved walls.
	var sp = lerp(speed + 1.0, 3.0, Easing.smooth_start3(t))
	var dir = detector.get_collision_normal().cross(Vector3.UP)
	if left: dir *= -1
	
	# Player runs an arc across the wall.
	# Starts fast and slightly upwards and ends slow and downwards.
	var vertical_velocity = lerp(Vector3.UP, Vector3.DOWN, t) * 4
	var horizontal_velocity = dir * sp
	player.velocity =  vertical_velocity + horizontal_velocity
	player.move_and_slide()

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if Input.is_action_just_released("Jump") and timer > 0.5:
		# Sets the timer so player has some time to jump off.
		timer = 0.5
		# Also sets timer so it exactly and smoothly returns the camera tilt.
		anim.timer = time - 0.5 
		
	elif timer < 0 or not detector.is_colliding():
		# Falling down - player was too slow so can't jump or wall run again.
		# This also prevets jus repeatedly climbing on the same wall.
		state = player.jumping_state
		can_wall_run = false
		state.ignore_coyote_timer = true
		
		# Revert camera tilt if stopped early.
		if timer > easing_time: anim.timer = time - easing_time
		
	elif Input.is_action_just_pressed("Jump"):
		# Revert camera tilt.
		anim.timer = time - easing_time
		
		var normal = detector.get_collision_normal()
		var dir = normal.cross(Vector3.UP)
		if left: dir *= -1
		
		# Jump off of the wall.
		state = player.jumping_state
		state.special_jump_dir = normal + Vector3.UP + dir
		AudioManager.play_sfx("squeak")
		
	if state == null: return
	
	wall_running_cooldown = 0.2
	state.enter_state(player)
	player.movement_state = state
