extends Area2D

func _on_body_enter(body):
	if body extends preload("PlayerControl.gd"):
		get_node("../Door").open_door()
		queue_free()