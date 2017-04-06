extends Area2D

export var y_range_scale = 10.0

onready var VFX_Manager = get_node("/root/VFX_Manager")
onready var player = get_tree().get_root().find_node("Player", true, false)

var entered = false

var prev_dark = 1.1

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	if not entered: return
	
	var d_y = player.get_global_pos().y - get_global_pos().y
	
	var darkness = clamp(d_y / y_range_scale, 0.0, 1.0)

	if prev_dark != darkness:
		VFX_Manager.set_darkness(darkness)
		
	prev_dark = darkness
	#if d_y / y_range_scale > 1.0: entered = false

func _on_body_exit( body ):
	entered = true
