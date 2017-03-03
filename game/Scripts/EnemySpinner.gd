extends KinematicBody2D

export(float) var rot_speed = 2;

func _ready():
	set_process(true)
	
	
func _process(delta):
	set_rotd(get_rotd() + delta * rot_speed)