extends NewMovementState
class_name DropKillState

var speed: float
var direction: Vector3
var timer: float
var time: float
var anim
var from: Vector3
var target: Vector3
var target_collider: Node3D
var target_rotation: Vector3
var move_timer: float
var move_time = 0.2
var in_animation: bool

func _init(_time: float = 1.4):
	self.time = _time
	self.timer = _time

func enter_state(player: PlayerController):
	player.animation_player.play_anim("FallingAttack")
	player.player_camera.weapon_render(true)
	player.player_camera.bob_end()
	target_collider = (player.drop_kill_detector.get_collider() as Node3D)
	target = target_collider.global_position + Vector3.UP * 0.5
	target_rotation = player.player_camera.rotation
	from = player.global_position
	move_timer = move_time
	timer = time
	in_animation = false
	player.velocity = Vector3.ZERO
	player.player_camera.ignore_rotation = true
	print("ENTERING SLIDING STATE")
	pass

func process_movement(_player: PlayerController, delta: float):
	var t = move_timer / move_time
	t = clamp(t, 0, 1)
	t = Easing.smooth_end(t)
	
	if not in_animation:	
		_player.global_position = lerp(from, target, 1 - t)
		_player.player_camera.rotation = lerp(
			Vector3(0, target_rotation.y, target_rotation.z)
			, target_rotation, t)
	
	if move_timer < -0.8 + move_time and not in_animation:
		target_collider.queue_free()
		in_animation = true
	
	timer -= delta
	move_timer -= delta

func determine_state(player: PlayerController):
	var state: NewMovementState
	
	if timer < 0:
			state = player.jumping_state
		
	if state == null: return
	
	player.player_camera.ignore_rotation = false
	
	player.player_camera.weapon_render(false)
	state.enter_state(player)
	player.movement_state = state

