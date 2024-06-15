extends AnimationPlayer

var return_animation: String
@export var interruptable: bool

var audio_name: String
@export var audio_play : String:
	get:
		return audio_name
	set(value):
		audio_name = value
		AudioManager.play_sfx(value)
		
@onready var left_hand = $"../ViewPoint/CameraContainer/Camera3D/LeftHand"

var casting: bool = false
var sheathed: bool = true

func _ready():
	interruptable = true
	play("Sheathed")

func play_attack(attack_anim: String):
	if interruptable and not sheathed:
		play(attack_anim)

func stop_magic():
	left_hand.active = false
	if not get_assigned_animation() == "Magic":
		return
	
	play(return_animation)

func _on_animation_finished(anim_name):
	var attack_anims = [
		"LeftToRightAttack",
		"RightToLeftAttack",
		"WallRunLeftAttack",
		"WallRunRightAttack",
		"Unsheath"
	]
	
	if attack_anims.has(anim_name):
		play(return_animation)
		interruptable = true
	
	interruptable = true
	print(anim_name, " animation finished")
	
	if anim_name == "Magic":
		left_hand.active = false

func _on_animation_started(anim_name):
	print("STARTED: ", anim_name)
	interruptable = true
	
	if anim_name == "Magic":
		left_hand.active = true

func sheath():
	if sheathed or not interruptable: return
	
	sheathed = true
	play("Sheath")
	queue("Sheathed")


func unsheath():
	if not sheathed or not interruptable: return
	
	sheathed = false
	play("Unsheath")

# Plays base animation that can be interrupted by attack.
# Returns to this animation when attack is finished
func play_anim(anim: String):
	# TODO: Don't play animation if Magic is in progress and can cast magic...
	if interruptable and not sheathed:
		interruptable = true
		play(anim)
	
	return_animation = anim
