extends Node2D

var player

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	set_process(true)

func _process(delta):
	var v = player.get_global_pos() - get_parent().get_global_pos()
	v = v.normalized()
	var r = atan2(v.x, v.y)
	set_global_rot(r)
	
