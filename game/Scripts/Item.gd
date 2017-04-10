extends Area2D

var Util = preload("res://Scripts/Util.gd")

export var points = 0
export var hidden = false
export(float) var appear_timeout = 0.3

var persistant = null

func _ready():
	if has_node("Persistant"): persistant = get_node("Persistant")
	
	_set_visibility(!hidden)
	
func _set_visibility(visible):
	get_node("Sprite").set_hidden(!visible)
	get_node("Particles2D").set_hidden(!visible)

func _on_body_enter(body):
	if hidden: return
	
	if body extends preload("PlayerControl.gd"):
		body.collect(points)
		if persistant != null: persistant.persist()
		queue_free()
	
func reveal():
	if hidden:
		hidden = false
		if appear_timeout > 0:
			yield(Util.timer(self, appear_timeout), "timeout")
			_set_visibility(true)