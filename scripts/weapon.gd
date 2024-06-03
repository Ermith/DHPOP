extends Node3D

var _attacking = false

@export var attacking: bool:
	get: return _attacking
	set(val):
		_attacking = val
		if val:
			start_attack()
		else:
			stop_attack()
		
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_attacking(val: bool):
	if val:
		start_attack()
	else:
		stop_attack()

func start_attack():
	AudioManager.play_sfx("sword_woosh")
	
func stop_attack():
	pass
func _on_area_3d_body_entered(body):
	if not attacking: return
	print("ATTACK")
	
	print(body.name)
	if body.has_method("take_damage"):
		body.take_damage(1)
		AudioManager.play_sfx("sword_hit")
	
	if body.is_in_group("damageable"):
		AudioManager.play_sfx("sword_hit")
		body.queue_free()
	pass


func _on_area_3d_area_entered(area):
	print(area.name)
	if area.has_method("take_damage"):
		area.take_damage(1)
		AudioManager.play_sfx("sword_hit")
	pass # Replace with function body.
