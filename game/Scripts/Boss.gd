extends Node2D

var Fireball = preload("res://Entities/Fireball.tscn")

onready var anim = get_node("../AnimationPlayer")
onready var head = get_node("Head")
onready var fb_point = get_node("Head/Flamepoint")

var fb_int_duration = 0.5

var fb_counter = 0.0
var fb_int_counter = 0.0

func _ready():
	set_process(true)
	
func _process_fireballs(delta):
	if fb_counter > 0: 
		fb_counter -= delta
		
		if fb_counter < 0: return
		
		fb_int_counter -= delta
		
		if fb_int_counter <= 0:
			_fireball()
			fb_int_counter = fb_int_duration
			
func _fireball():
	var fb = Fireball.instance()
	add_child(fb, true)

	var angle = head.get_rot()
	fb.speed = Vector2(-cos(angle), sin(angle)) * 150.0
	fb.set_z(1)
	fb.set_global_pos(fb_point.get_global_pos())
	
func _process(delta):
	_process_fireballs(delta)
	
func fireballs(duration, interval):
	fb_counter = duration
	fb_int_duration = interval

func _on_AnimationPlayer_finished():
	anim.play("Bobbing-Sideways")
