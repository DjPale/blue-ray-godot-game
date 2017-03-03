extends Area2D

export var is_open = false

onready var anim = get_node("Sprite")

func _set_anim():
	if is_open:
		anim.set_animation("open")
	else:
		anim.set_animation("closed")

func _ready():
	_set_anim()

func open_door():
	is_open = true
	_set_anim()

func _on_body_enter( body ):
	if is_open && body extends preload("PlayerControl.gd"):
		body.enter_door()
