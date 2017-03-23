extends Area2D

func _on_body_enter( body ):
	if body extends preload("PlayerControl.gd"):
		body.set_spawn(self)
