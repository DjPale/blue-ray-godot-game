extends Node2D

export var start = Vector2(512, 400)
export var scale_y = 600.0

onready var VFX_Manager = get_node("/root/VFX_Manager")

var prev_dark = 1.1

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	var p = get_global_pos()
		
	var d_y = p.y - start.y
	
	if d_y < 0: return
	
	var darkness = clamp(d_y / scale_y, 0.0, 1.0)

	if prev_dark != darkness:
		VFX_Manager.set_darkness(darkness)
		
	prev_dark = darkness