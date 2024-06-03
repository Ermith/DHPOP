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
	pass

func _process(_delta):
	pass

func play_attack(attack_anim: String):
	if interruptable and not sheathed:
		play(attack_anim)

func stop_magic():
	play(return_animation)
	left_hand.active = false

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
		print("FUCKING HELL ", interruptable)
	
	interruptable = true
	print(anim_name, " animation finished")
	
	if anim_name == "Magic":
		left_hand.active = false
	pass # Replace with function body.


func _on_animation_started(anim_name):
	print("STARTED: ", anim_name)
	interruptable = true
	
	if anim_name == "Magic":
		left_hand.active = true
		
	
	pass # Replace with function body.


func sheath():
	if sheathed: return
	
	sheathed = true
	play("Sheath")
	queue("Sheathed")
	pass # Replace with function body.


func unsheath():
	if not sheathed: return
	
	sheathed = false
	play("Unsheath")
	#queue("RESET")
	#queue(return_animation)
	
	pass # Replace with function body.

func play_anim(anim: String):
	print(interruptable)
	if interruptable and not sheathed:
		print("A ", anim)
		interruptable = true
		play(anim)
		return_animation = anim
	else:
		print("B ", anim)
		return_animation = anim
		
	
