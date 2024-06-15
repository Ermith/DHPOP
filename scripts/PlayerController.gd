extends CharacterBody3D
class_name PlayerController

#region EXPOSED PARAMETERS
@export var walking_speed: float = 6
@export var sprinting_speed: float = 10
@export var air_speed: float = 2
@export var jump_force: float = 15
@export var coyote_time: float = 0.4
@export var gravity_time: float = 0.2
@export var gravity_multiplier: float = 7
#endregion

#region ON READY
@onready var player_camera = $ViewPoint/CameraContainer
@onready var view_point = $ViewPoint
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var wall_climb_detector_front = $ViewPoint/WallClimbDetectorFront
@onready var wall_climb_detector_left = $ViewPoint/WallClimbDetectorLeft
@onready var wall_climb_detector_right = $ViewPoint/WallClimbDetectorRight
@onready var climb_detector_higher = $ViewPoint/ClimbDetectorHigher
@onready var climb_detector_lower = $ViewPoint/ClimbDetectorLower
@onready var animation_player = $AnimationPlayer
@onready var red_pointer = $HUD/RedPointer
@onready var pointer = $HUD/Pointer
@onready var drop_kill_detector = $ViewPoint/CameraContainer/DropKillDetector
#endregion

#region STATES
var movement_state: NewMovementState
var standing_state: StandingState
var walking_state: WalkingState
var running_state: RunningState
var jumping_state: JumpingState
var sliding_state: SlidingState
var wall_running_front_state: WallRunningFrontState
var wall_running_side_state: WallRunningSideState
var climbing_state: ClimbingState
var drop_kill_state: DropKillState
#endregion

var gravity = Vector3.DOWN * 10
var prev_input = Vector3.ZERO
var speed: float = 0
var current_vel = Vector3.ZERO

func _ready():
	# TODO: Move this line to Game Controller
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	standing_state = StandingState.new()
	walking_state = WalkingState.new(walking_speed)
	running_state = RunningState.new(sprinting_speed)
	sliding_state = SlidingState.new(20)
	jumping_state = JumpingState.new(jump_force, 10.0, 12.0, coyote_time, gravity_time, gravity_multiplier)
	wall_running_front_state = WallRunningFrontState.new(walking_speed)
	wall_running_side_state = WallRunningSideState.new(sprinting_speed)
	climbing_state = ClimbingState.new(0.65)
	drop_kill_state = DropKillState.new()
	
	# This will be the starting state when spawned
	movement_state = standing_state

func _process(_delta):
	# TODO: Move somewhere else... Maybe based on the weapon and range?
	red_pointer.visible = drop_kill_detector.is_colliding()
	
	
	if Input.is_action_just_pressed("Interact"):
		if animation_player.sheathed:
			animation_player.unsheath()
		else:
			animation_player.sheath()
	

	# Can Attack also means - can use left hand - magic
	# TODO: rework "Magic" to more general "Left Hand"	
	if not movement_state.attack == "":
		if Input.is_action_just_pressed("Attack"):
			animation_player.play_attack(movement_state.attack)
		elif Input.is_action_just_pressed("Magic"):
			animation_player.play_attack("Magic")

	# Also stops magic when changes to state that can't attack, like sprinting
	if Input.is_action_just_released("Magic") or movement_state.attack == "":
			animation_player.stop_magic()

func _physics_process(delta):
	NewMovementState.static_process(delta)
	movement_state.determine_state(self)
	movement_state.process_rotation(self)
	movement_state.process_movement(self, delta)
	
	player_camera.notify_movement(view_point.global_position)
