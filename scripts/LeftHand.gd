extends Node3D

var children: Array
@export var index: int
@export var active: bool:
	get:
		if children.size() == 0:
			return false
		return children[index].visible
	
	set(value):
		if children.size() == 0:
			return
		
		if value:
			children[index].activate()
		else:
			children[index].deactivate()

func _ready():
	children = get_children()
	for child: Node3D in children:
		child.visible = false
		
	children[index].visible = true
	
func _process(_delta):
	# Will cycle through things in left hand.
	# Switches between fire and ice magic for now.
	if Input.is_action_just_pressed("Switch Left Hand"):
		children[index].visible = false
		children[index].deactivate()
		index = (index + 1) % children.size()
		children[index].visible = true
