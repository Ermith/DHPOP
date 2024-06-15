extends Node3D
class_name AudioManager

@onready var steps: Dictionary
@onready var common_sounds: Dictionary

static var instance: AudioManager
var rng = RandomNumberGenerator.new()

func _ready():
	# Singleton
	instance = self
	
	# Common Sounds
	var common_sounds_array = get_children()
	for sound in common_sounds_array:
		if sound is AudioStreamPlayer:
			common_sounds[sound.name] = sound

	# Steps
	var steps_node = get_node("Steps")
	var step_array = steps_node.get_children()
	
	for step_sound: AudioStreamPlayer in step_array:
		var category = step_sound.name.split("_")[0]
		if not steps.has(category):
			steps[category] = [step_sound]
		else:
			steps[category].append(step_sound)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

static func play_sfx(_name: String):
	if instance == null: return
	var audio: AudioStreamPlayer = instance.common_sounds[_name]
	audio.play()

static func stop_sfx(_name: String):
	instance.common_sounds[_name].stop()

static func play_step_sfx(_name: String):
	var step_array: Array = instance.steps[_name]
	var index: int = instance.rng.randi_range(0, step_array.size() - 1)
	step_array[index].play()
