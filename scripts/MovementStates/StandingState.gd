extends NewMovementState
class_name StandingState

func _init():
	attack = "RightToLeftAttack"

func process_movement(player: PlayerController, delta: float):
	# Slow down to zero.
	player.velocity = ground_velocity(player, 0, delta)
	player.move_and_slide()

func enter_state(player: PlayerController):
	player.animation_player.play_anim("Idle")
	print("ENTERING STANDING STATE")

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if climb_condition(player):
		state = player.climbing_state
	
	if not player.is_on_floor() or Input.is_action_just_pressed("Jump"):
		state = player.jumping_state
	
	elif not get_input_direction(player).is_zero_approx():
		state = player.walking_state
	
	if state == null: return
	
	state.enter_state(player)
	player.movement_state = state
