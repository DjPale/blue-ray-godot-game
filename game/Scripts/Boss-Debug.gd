extends Node2D

onready var anim = get_node("AnimationPlayer")
onready var flash = get_node("FlashPlayer")
onready var boss = get_node("BossBase")

func _ready():
	set_process_input(true)
	
func _input(event):
	if event.type == InputEvent.KEY and not event.pressed:
		if event.scancode == KEY_F:
			boss.flash()
	
