extends Label

onready var global = get_node("/root/Global")

func _ready():
	set_text(get_node("../..").get_name())