extends Area2D

export var enable = true

onready var VFX_Manager = get_node("/root/VFX_Manager")
onready var Global = get_node("/root/Global")

func _ready():
	var t = Global.get_level_data(null, "Darkness")
	if t != null:
		VFX_Manager.enable_darkness(t)

func _on_body_exit( body ):
	VFX_Manager.enable_darkness(enable)
	Global.set_level_data(null, "Darkness", enable, 0)
