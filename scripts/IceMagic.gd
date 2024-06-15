extends Node3D

@onready var spraying_icicles: GPUParticles3D = $SprayingIcicles
@onready var spraying_mist: GPUParticles3D = $SprayingMist
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

var active = false

func activate():
	spraying_icicles.emitting = true
	spraying_mist.emitting = true
	shape_cast_3d.enabled = true
	active = true
	AudioManager.play_sfx("wind")
	
func deactivate():
	spraying_icicles.emitting = false
	spraying_mist.emitting = false
	shape_cast_3d.enabled = false
	active = false
	AudioManager.stop_sfx("wind")

func _process(_delta):
	var count = shape_cast_3d.get_collision_count()
	for i in range(0, count):
		var col = shape_cast_3d.get_collider(i) as Node3D
		if col == null: continue
		
		# TODO: Damage instead of delete
		if col.is_in_group("damageable"):
			col.queue_free()
			AudioManager.play_sfx("freeze")
