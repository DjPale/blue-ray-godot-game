extends Node2D

# assume child of KinematicBody2D
onready var body = get_parent()

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	if body.is_colliding():
		var obj = body.get_collider()
		if obj extends preload("PlayerControl.gd"):
			obj.hit(self)
			
	if get_pos().y > 800: queue_free()
