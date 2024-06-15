extends NewMovementState
class_name ClimbingState

var climb_start: Vector3
var climb_target: Vector3
var timer: float
var time: float
var climb_time: float
const climb_treshold: float = 0.8

func _init(_time: float):
	self.climb_time = _time


func process_movement(player: PlayerController, delta: float):
	# Retain some velocity in direction of climbing to continue walking/sprinting
	player.velocity = (climb_target - climb_start)
	player.velocity.y = 0
	player.velocity = player.velocity.normalized() * 4
	
	# Advance the time
	var t = 1 - timer / time
	timer -= delta
	
	# Longer time goes int L pattern, first up then forward
	if time > climb_time * climb_treshold:
		var mid_point = Vector3(climb_start.x, climb_target.y - 0.5, climb_start.z)
		var a = lerp(climb_start, mid_point, Easing.smooth_step(t))
		var b = lerp(mid_point, climb_target, Easing.smooth_step(t))
		player.global_position = lerp(a, b, Easing.smooth_step(t))
		
	# Shorter time means lower height.
	# Goes straight towards the endpoint.
	# This means lower part of the player phases through the object.
	else:
		player.global_position = lerp(climb_start, climb_target, Easing.smooth_step(t))
	
func enter_state(player: PlayerController):
	# Determine climb direction
	# Higher detector for climbing higher ledges.
	var climb_area = player.climb_detector_higher.get_collider()
	var fwd = -player.climb_detector_higher.get_collision_normal()
	
	# Lower detectior for low ledges player is not looking at.
	if climb_area == null:
		climb_area = player.climb_detector_lower.get_collider()
		fwd = -player.climb_detector_lower.get_collision_normal()
	
	# TODO: What if a ledge is inbetween the top the bottom detector.
	# TODO: But does it matter?
	
	var collision_shape : CollisionShape3D = climb_area.get_child(0)
	var shape: BoxShape3D = collision_shape.shape
	var target_y: float = shape.size.y / 2 + (collision_shape as Node3D).global_position.y + 0.15
	
	climb_start = player.global_position
	climb_target = Vector3(climb_start.x, target_y, climb_start.z) + fwd
	
	var max_dist = player.standing_collision_shape.shape.height
	var dist = climb_target.y - climb_start.y
	var multiplier = dist / max_dist
	
	# Shorter time with lower height
	time = climb_time * multiplier
	timer = time
	
	var position_keyframes = [ [0, Vector3.ZERO] ]
	var rotation_keyframes = [ [0, Vector3.ZERO] ]
	
	if time > climb_time * climb_treshold:
		player.animation_player.play_anim("Climbing")
		position_keyframes.append([time/4, Vector3(0, 0, 0.0)])
		position_keyframes.append([time/2, Vector3.ZERO])
		rotation_keyframes.append([time/4, Vector3(-PI/30, 0, -PI/30)])
		rotation_keyframes.append([time/2, Vector3(0,0,0)])
	
		position_keyframes.append([time/2 + time/4, Vector3(0, 0, -0.0)])
		position_keyframes.append([time, Vector3.ZERO])
		rotation_keyframes.append([time/2 + time/4, Vector3(PI/30,0,0)])
		rotation_keyframes.append([time, Vector3(0,0,0)])
		
	elif time > 0.1:
		player.animation_player.play_anim("ShortClimb")
		position_keyframes.append([time/2, Vector3(0, 0, -0.0)])
		position_keyframes.append([time, Vector3.ZERO])
		rotation_keyframes.append([time/2, Vector3(-PI/30, 0, PI/40)])
		rotation_keyframes.append([time, Vector3(0,0,0)])

	player.player_camera.add_anim(time, position_keyframes, rotation_keyframes)
	AudioManager.play_sfx("thump")
	print("ENTERING CLIMBING STATE")

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if timer <= 0:
		if not player.is_on_floor():
			state = player.jumping_state
		elif not move_condition(player):
			state = player.standing_state
		elif Input.is_action_pressed("Sprint"):
			state = player.running_state
		else:
			state = player.walking_state
	
	if state == null: return
	
	climbing_cooldown = 0.1
	state.enter_state(player)
	player.movement_state = state
