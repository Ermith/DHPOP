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
	
	player.player_camera.bob_end()
	timer = time
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
	
	player.player_camera.bob_start(0.0, 0.03, 0.11)
	
	anim = player.player_camera.add_anim(time, position_keyframes, rotation_keyframes)
	var s = "RIGHT"
	if left: s = "LEFT"
	print("ENTERING WALL RUNNING ", s, " STATE")
	
	if left: detector = player.wall_climb_detector_left
	else: detector = player.wall_climb_detector_right

func process_movement(player: PlayerController, delta: float):
	var t = timer / time
	timer -= delta
	
	var sp = lerp(speed + 1.0, 3.0, Easing.smooth_start3(1 - t))
	var vel = detector.get_collision_normal().cross(Vector3.UP) * sp
	if left: vel *= -1
	player.velocity = lerp(Vector3.DOWN, Vector3.UP, t) * 4 + vel
	player.move_and_slide()

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if Input.is_action_just_released("Jump") and timer > 0.5:
		timer = 0.5
		anim.timer = time - 0.5
		
	elif timer < 0 or not detector.is_colliding():
		state = player.jumping_state
		can_wall_run = false
		state.ignore_coyote_timer = true
		if timer > easing_time: anim.timer = time - easing_time
		
	elif Input.is_action_just_pressed("Jump"):
		var normal = detector.get_collision_normal()
		state = player.jumping_state
		var dir = detector.get_collision_normal().cross(Vector3.UP)
		if left: dir *= -1
		state.special_jump_dir = (normal * 1.1 + Vector3.UP).normalized() * state.force * 1.3 + dir * speed
		state.special_jump_dir = normal + Vector3.UP + dir
		anim.timer = time - easing_time
		AudioManager.play_sfx("squeak")
		
	if state == null: return
	
	wall_running_cooldown = 0.2
	state.enter_state(player)
	player.movement_state = state
