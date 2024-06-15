extends Node3D

@onready var spraying_sparks: GPUParticles3D = $SprayingSparks
@onready var spraying_fire: GPUParticles3D = $SprayingFire
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

var active = false
var audio: AudioStreamPlayer

func activate():
	spraying_sparks.emitting = true
	spraying_fire.emitting = true
	shape_cast_3d.enabled = true
	active = true
	AudioManager.play_sfx("fire_1")
	
func deactivate():
	spraying_sparks.emitting = false
	spraying_fire.emitting = false
	shape_cast_3d.enabled = false
	active = false
	AudioManager.stop_sfx("fire_1")

func _process(_delta):
	var count = shape_cast_3d.get_collision_count()
	for i in range(0, count):
		var col = shape_cast_3d.get_collider(i) as Node3D
		if col == null: continue
		
		# TODO: Damage instead of delete
		if col.is_in_group("damageable"):
			col.queue_free()
			AudioManager.play_sfx("burn")
