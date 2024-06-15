extends NewMovementState
class_name WalkingState

var speed: float

func _init(_speed:float):
	self.speed = _speed

func enter_state(player: PlayerController):
	player.player_camera.bob_start(0.0, 0.02, 0.2)
	player.animation_player.play_anim("Walking")
	print("ENTERING WALKING STATE")

func process_movement(player: PlayerController, delta: float):
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	if input_dir.x > 0.1: attack = "LeftToRightAttack"
	else: attack = "RightToLeftAttack"
	
	player.velocity = ground_velocity(player, speed, delta)
	player.move_and_slide()

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if not player.is_on_floor() or Input.is_action_just_pressed("Jump"):
		state = player.jumping_state
	
	elif Input.is_action_pressed("Sprint"):
		state = player.running_state
		
	elif not move_condition(player):
		state = player.standing_state
		
	if state == null: return
	
	player.player_camera.bob_end()
	state.enter_state(player)
	player.movement_state = state
