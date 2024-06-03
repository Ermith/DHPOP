extends NewMovementState
class_name WallRunningFrontState

var speed: float
var direction: Vector3
var timer: float
var time: float
var anim

func _init(_speed: float, _time: float = 2):
	self.speed = _speed
	self.time = _time
	self.timer = _time

func enter_state(player: PlayerController):
	player.animation_player.play_anim("Climbing")
	can_side_wall_run = false
	player.player_camera.bob_end()
	timer = time
	var position_keyframes = []
	var rotation_keyframes = [
		[0.2, Vector3(PI/30, 0, PI/40)],
		[0.4, Vector3(0, 0, 0)],
		[0.6, Vector3(PI/30, 0, -PI/40)],
		[0.8, Vector3(0, 0, 0)]
	]
	
	anim = player.player_camera.add_anim(0.8, position_keyframes, rotation_keyframes)
	print("ENTERING WALL RUNNING FRONT STATE")
	pass

func process_movement(player: PlayerController, delta: float):
	var t = timer / time
	timer -= delta
	player.velocity = lerp(Vector3.DOWN, Vector3.UP, t) * speed
	print(player.velocity)
	player.move_and_slide()

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if climbing_cooldown < 0 and Input.is_action_pressed("Jump") and player.climb_detector_higher.is_colliding() or player.climb_detector_lower.is_colliding():
		state = player.climbing_state
	
	elif Input.is_action_just_released("Jump") and timer > 0.5:
		timer = 0.5
		
	elif timer < 0 or not player.wall_climb_detector_front.is_colliding():
		state = player.jumping_state
		can_wall_run = false
		state.ignore_coyote_timer = true
	elif Input.is_action_just_pressed("Jump"):
		var normal = player.wall_climb_detector_front.get_collision_normal()
		state = player.jumping_state
		state.special_jump_dir = normal + Vector3.UP
		AudioManager.play_sfx("squeak")
		
	if state == null: return
	
	wall_running_cooldown = 0.2
	state.enter_state(player)
	player.movement_state = state
