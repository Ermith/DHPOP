extends NewMovementState
class_name ClimbingState

var climb_start: Vector3
var climb_target: Vector3
var timer: float
var time: float
var climb_time: float

func _init(_time: float):
	self.climb_time = _time


func process_movement(player: PlayerController, delta: float):
	player.velocity = (climb_target - climb_start)
	player.velocity.y = 0
	player.velocity = player.velocity.normalized() * 2
	timer -= delta
		
	var t = 1 - timer / time
	var mid_point = Vector3(climb_start.x, climb_target.y - 0.5, climb_start.z)
		
	if time > climb_time / 2:
		var a = lerp(climb_start, mid_point, Easing.smooth_step(t))
		var b = lerp(mid_point, climb_target, Easing.smooth_step(t))
		player.global_position = lerp(a, b, Easing.smooth_step(t))
	else:
		player.global_position = lerp(climb_start, climb_target, Easing.smooth_step(t))

func enter_state(player: PlayerController):
	player.player_camera.bob_end()
	var climb_area = player.climb_detector_higher.get_collider()
	var fwd = player.climb_detector_higher.get_collision_normal()
	if climb_area == null:
		climb_area = player.climb_detector_lower.get_collider()
		fwd = player.climb_detector_lower.get_collision_normal()
	
	var collision_shape : CollisionShape3D = climb_area.get_child(0)
	var shape: BoxShape3D = collision_shape.shape
	var vertical_y: float = shape.size.y / 2 + (collision_shape as Node3D).global_position.y + 0.1
	#fwd = player.basis * Vector3.FORWARD
	climb_start = player.global_position
	climb_target = Vector3(climb_start.x, vertical_y, climb_start.z) - fwd
		
	var max_dist = 2
	var dist = climb_target.y - climb_start.y
	var m = dist / max_dist
	time = climb_time * m
	timer = time
	AudioManager.play_sfx("thump")
	
	var position_keyframes = [ [0, Vector3.ZERO] ]
	var rotation_keyframes = [ [0, Vector3.ZERO] ]
	
	
	if time > climb_time * 3 / 4:
		player.animation_player.play_anim("Climbing")
		position_keyframes.append([time/4, Vector3(0, 0, 0.2)])
		position_keyframes.append([time / 2, Vector3.ZERO])
		rotation_keyframes.append([time/4, Vector3(-PI/30, 0, -PI/30)])
		rotation_keyframes.append([time/2, Vector3(0,0,0)])
	
		position_keyframes.append([time/2 + time/4, Vector3(0, 0, -0.1)])
		position_keyframes.append([time, Vector3.ZERO])
		rotation_keyframes.append([time/2 + time/4, Vector3(PI/30,0,0)])
		rotation_keyframes.append([time, Vector3(0,0,0)])
	elif time > 0.1:
		player.animation_player.play_anim("ShortClimb")
		position_keyframes.append([time/2, Vector3(0, 0, -0.1)])
		position_keyframes.append([time, Vector3.ZERO])
		rotation_keyframes.append([time/2, Vector3(-PI/60, 0, -PI/60)])
		rotation_keyframes.append([time, Vector3(0,0,0)])
		#Vector3(0, 0, -0.1),
		#Vector3(PI/30, 0, 0),
	player.player_camera.add_anim(time, position_keyframes, rotation_keyframes)
	print("ENTERING CLIMBING STATE")
	pass

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if timer <= 0:
		state = player.jumping_state
	
	if state == null: return
	
	climbing_cooldown = 0.1
	state.enter_state(player)
	player.movement_state = state
