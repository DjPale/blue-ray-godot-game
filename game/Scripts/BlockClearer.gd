extends Area2D

onready var anim = get_node("Sprite/AnimationPlayer")

var has_entered = false

func _on_body_enter( body ):
	if not has_entered && body extends preload("PlayerControl.gd"):
		has_entered = true
		body.clear_tilecount()
		anim.play("Close")
