extends NewMovementState
class_name RunningState

var speed: float

func _init(_speed:float):
	self.speed = _speed

func enter_state(player: PlayerController):
	player.player_camera.bob_start(0.03, 0.03, 0.12)
	player.animation_player.play_anim("Running")
	print("ENTERING RUNNING STATE")
	pass

func process_movement(player: PlayerController, delta: float):
	var velocity = ground_velocity(player, speed, delta)
	player.velocity = velocity
	player.move_and_slide()

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if not player.is_on_floor() or Input.is_action_just_pressed("Jump"):
		state = player.jumping_state
	
	elif not move_condition(player):
		state = player.standing_state
	
	elif not Input.is_action_pressed("Sprint"):
		state = player.walking_state
	
	elif Input.is_action_pressed("Crouch") and sliding_cooldown <= 0:
		state = player.sliding_state
		
	if state == null: return
	player.player_camera.bob_end()
	state.enter_state(player)
	player.movement_state = state
