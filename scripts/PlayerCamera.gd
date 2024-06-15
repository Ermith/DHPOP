extends Node3D
class_name NewPlayerCamera

@export var mouse_sensitivity: float = 4
@export var vertical_bob_scale: float = 0.05
@export var horizontal_bob_scale: float = 0.05

@onready var camera_3d = $Camera3D
@onready var weapon_camera = $Camera3D/SubViewportContainer/SubViewport/WeaponCamera

var last_position: Vector3
var next_position: Vector3
var damp_velocity: Vector3
var previous_bob_offset: Vector3
var previous_bob_rotation: Vector3
var damp_rotation_velocity: Vector3
var bob_time: float = 0.25
var bob_timer: float = 0
var bob_speed: float = 0.1
var bob_offset: Vector3
var bob_rotation_offset: Vector3
var ignore_rotation: bool = false

var camera_effects: Array

var bob_state: BobState = BobState.NONE
enum BobState {
	NONE,
	RIGHT_STEP,
	RIGHT_RISE,
	LEFT_STEP,
	LEFT_RISE
}

func weapon_render(do: bool):
	if do:
		camera_3d.cull_mask = 0xFFFFF
		weapon_camera.cull_mask = 0x0
	else:
		camera_3d.cull_mask = ~(1 << 19) & 0xFFFFF
		weapon_camera.cull_mask = 1 << 19

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion and not ignore_rotation:
		var yaw_input = -deg_to_rad(event.relative.x)
		var pitch_input = -deg_to_rad(event.relative.y)
		
		var m = 0.015
		rotation.y += yaw_input * m * mouse_sensitivity
		rotation.x += pitch_input * m * mouse_sensitivity

func _process(delta):
	camera_3d.position = Vector3.ZERO
	camera_3d.rotation = Vector3.ZERO
	
	var t = Engine.get_physics_interpolation_fraction()
	global_position = lerp(last_position, next_position, t)
	process_bob(delta)
	
	var to_erase = []
	
	for eff in camera_effects:
		var tmp = eff.process(delta)

		camera_3d.position += tmp[0]
		camera_3d.rotation += tmp[1]
		
		if eff.finished:
			to_erase.append(eff)
	
	for eff in to_erase:
		camera_effects.erase(eff)
	
	weapon_camera.global_position = camera_3d.global_position
	weapon_camera.global_rotation = camera_3d.global_rotation

func notify_movement(_position: Vector3):
	last_position = next_position
	next_position = _position

func bob_start(horizontal_scale: float, vertical_scale: float, speed: float):
	if bob_state == BobState.NONE:
		bob_state = BobState.LEFT_STEP
	
	horizontal_bob_scale = horizontal_scale
	vertical_bob_scale = vertical_scale
	bob_speed = speed
	bob_time = speed
	bob_timer = 0
	previous_bob_offset = bob_offset
	previous_bob_rotation = bob_rotation_offset

func bob_end():
	bob_state = BobState.NONE
	bob_timer = 0
	previous_bob_offset = bob_offset
	previous_bob_rotation = bob_rotation_offset

func process_bob(delta: float):
	var left_down = Vector3.LEFT * horizontal_bob_scale + Vector3.DOWN * vertical_bob_scale
	var right_down = Vector3.RIGHT * horizontal_bob_scale + Vector3.DOWN * vertical_bob_scale
	var mid_up = Vector3.UP * vertical_bob_scale
	
	var target_offset: Vector3 
	var target_rotation: Vector3
	var r = deg_to_rad(10)
	match bob_state:
		BobState.RIGHT_STEP:
			target_offset = right_down
			target_rotation = Vector3.UP * r * horizontal_bob_scale
		BobState.LEFT_STEP:
			target_offset = left_down
			target_rotation = -Vector3.UP * r * horizontal_bob_scale
		BobState.RIGHT_RISE:
			target_offset = mid_up
			target_rotation = Vector3.RIGHT * r * vertical_bob_scale
		BobState.LEFT_RISE:
			target_offset = mid_up
			target_rotation = Vector3.RIGHT * r * vertical_bob_scale
		_:
			target_offset = Vector3.ZERO
			target_rotation = Vector3.ZERO
	
	if not bob_state == BobState.NONE:
		target_offset += Vector3.DOWN * 0.15
	
	var t = bob_timer / bob_time
	bob_timer += delta
	t = clamp(t, 0, 1)
	
	if bob_state == BobState.LEFT_STEP or bob_state == BobState.RIGHT_STEP:
		t = Easing.smooth_step(t)
	else:
		t = Easing.smooth_step(t)
	
	
	bob_offset = lerp(previous_bob_offset, target_offset, t)
	bob_rotation_offset = lerp(previous_bob_rotation, target_rotation, t)
	
	camera_3d.position += bob_offset
	camera_3d.rotation += bob_rotation_offset
	
	if t >= 1 and not bob_state == BobState.NONE:
		if bob_state == BobState.LEFT_STEP or bob_state == BobState.RIGHT_STEP:
			AudioManager.play_step_sfx("default")
		bob_timer = 0
		previous_bob_offset = target_offset
		previous_bob_rotation = target_rotation
		
		match bob_state:
			BobState.LEFT_STEP: bob_state = BobState.LEFT_RISE
			BobState.RIGHT_STEP: bob_state = BobState.RIGHT_RISE
			BobState.LEFT_RISE: bob_state = BobState.RIGHT_STEP
			BobState.RIGHT_RISE: bob_state = BobState.LEFT_STEP
			_: bob_state = BobState.NONE

func add_anim(duration: float, position_frames: Array, rotation_frames: Array):
	var eff = CameraEffect.new()
	eff.position_keyframes = position_frames
	eff.rotation_keyframes = rotation_frames
	eff.time = duration
	camera_effects.append(eff)
	return eff

class CameraEffect:
	var time: float
	var timer: float
	var finished: bool = false
	
	var position_keyframes: Array
	var rotation_keyframes: Array
	
	func _init():
		pass
	
	
	func process_frame(frames: Array):
		var from_time = 0
		var to_time = time
		var from_frame = Vector3.ZERO
		var to_frame = Vector3.ZERO
		var easing = Easing.smooth_step
		
		for tmp in frames:
			var frame_time = tmp[0]
			var frame = tmp[1]
			if frame_time > timer:
				to_frame = frame
				to_time = frame_time
				if tmp.size() == 3: easing = tmp[2]
				break
			
			from_frame = frame
			from_time = frame_time
		
		var t = (timer - from_time) / (to_time - from_time)
		if is_nan(t): t = 1
		t = clamp(t, 0, 1)
		t = easing.call(t)
		return lerp(from_frame, to_frame, t)
	
	func process(delta: float):
		
		var position = Vector3.ZERO
		var rotation = Vector3.ZERO
		
		if position_keyframes.size() > 0:
			position = process_frame(position_keyframes)
		
		if rotation_keyframes.size() > 0:
			rotation = process_frame(rotation_keyframes)
		
		finished = timer >= time
		timer += delta
		
		return [position, rotation]
