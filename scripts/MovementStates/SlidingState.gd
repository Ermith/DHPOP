extends NewMovementState
class_name SlidingState

var speed: float
var direction: Vector3
var timer: float
var time: float
var anim

func _init(_speed:float, _time: float = 1):
	self.speed = _speed
	self.time = _time
	self.timer = _time

func enter_state(player: PlayerController):
	player.animation_player.play_anim("Slide")
	player.standing_collision_shape.disabled = true
	player.crouching_collision_shape.disabled = false
	
	player.player_camera.bob_end()
	direction = _get_ground_dir(player)
	timer = time
	AudioManager.play_sfx("slide")
	
	var position_keyframes = [
		[0.0, Vector3(0, 0, 0)],
		[0.15, Vector3(0, -1, 0)],
		[0.95, Vector3(0, -1, 0)],
		[1.2, Vector3(0, 0, 0)]
	]
	
	var rotation_keyframes = [
		[0.0, Vector3(0, 0, 0)],
		[0.15, Vector3(PI/20, 0, -PI/30)],
		[0.95, Vector3(PI/20, 0, -PI/30)],
		[1.2, Vector3(0, 0, 0)],
	]
	
	anim = player.player_camera.add_anim(time + 0.2, position_keyframes, rotation_keyframes)
	print("ENTERING SLIDING STATE")
	pass

func process_movement(player: PlayerController, delta: float):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	if input_dir.x > -0.1: attack = "RightToLeftAttack"
	else: attack = "LeftToRightAttack"
	
	var t = timer / time
	timer -= delta
	player.velocity = direction * speed * t
	player.move_and_slide()

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if not player.is_on_floor():
		state = player.jumping_state
		if anim.timer < 0.95:
			anim.timer = 0.95
	
	elif timer < 0:
		if _get_ground_dir(player).is_zero_approx():
			state = player.standing_state
		elif Input.is_action_pressed("Sprint"):
			state = player.running_state
		else:
			state = player.walking_state
		
	if state == null: return
	
	player.standing_collision_shape.disabled = false
	player.crouching_collision_shape.disabled = true
	
	state.enter_state(player)
	player.movement_state = state
	sliding_cooldown = 0.7
