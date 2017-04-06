extends Area2D

onready var Global = get_node("/root/Global")

onready var anim = get_node("Sprite/AnimationPlayer")

var has_entered = false

func _ready():
	var f = Global.get_level_data(self, "closed")
	if f != null && f: _close_door()

func _close_door(body = null):
	has_entered = true
	if body != null: body.clear_tilecount()
	anim.play("Close")
	Global.set_level_data(self, "closed", true)

func _on_body_enter( body ):
	if not has_entered && body extends preload("PlayerControl.gd"): _close_door(body)
