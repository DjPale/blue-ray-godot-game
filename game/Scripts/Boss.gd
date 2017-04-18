extends Node2D

var Fireball = preload("res://Entities/Fireball-Big.tscn")
var Spinner = preload("res://Entities/EnemySpinning-Spawned.tscn")

export var fireball_speed = 150.0
export var spinner_speed = Vector2(-150, 0)

onready var anim = get_node("../AnimationPlayer")
onready var head = get_node("Head")
onready var top = get_node("Top Segment")
onready var mid = get_node("Mid Segment")
onready var bottom = get_node("Bottom Segment")
onready var fb_point = get_node("Head/Flamepoint")
onready var flash_anim = get_node("../FlashPlayer")

onready var enemies = get_tree().get_root().find_node("Enemies", true, false)

var segments = []

var fb_int_duration = 0.5

var fb_counter = 0.0
var fb_int_counter = 0.0

func _ready():
	segments.append(top)
	segments.append(mid)
	#segments.append(bottom)
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
	fb.speed = Vector2(-cos(angle), sin(angle)) * fireball_speed
	fb.set_z(1)
	fb.set_global_pos(fb_point.get_global_pos())
	
func _process(delta):
	_process_fireballs(delta)
	
func fireballs(duration, interval):
	fb_counter = duration
	fb_int_duration = interval
	
func attach_spinners():
	for s in segments:
		var spinner = Spinner.instance()
		s.add_child(spinner)
		spinner.set_name("Spinner-" + s.get_name())
		
func start_spinners():
	for s in segments:
		var spinner = s.find_node("Spinner-*", true, false)
		if spinner != null:
			call_deferred("_reparent", s, enemies, spinner)
			spinner.speed = spinner_speed
			spinner.velocity = spinner.speed
			
func _reparent(old_parent, new_parent, the_node):
	old_parent.remove_child(the_node)
	new_parent.add_child(the_node)
	the_node.set_global_pos(old_parent.get_global_pos())

func flash():
	flash_anim.play("Flash")

func _on_AnimationPlayer_finished():
	anim.play("Bobbing-Sideways")

func _on_Eye__Weak_Spot_body_enter( body ):
	print("Eye enter ", body.get_name())
	if body extends preload("res://Scripts/EnemySpinner.gd"):
		print("OUCH")
		flash()
