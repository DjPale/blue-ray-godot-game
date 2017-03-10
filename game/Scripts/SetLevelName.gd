extends Label

onready var global = get_node("/root/Global")

func _ready():
	set_text(global.get_level_name())