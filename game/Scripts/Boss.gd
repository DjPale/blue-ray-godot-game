extends Node2D

var Fireball = preload("res://Entities/Fireball-Big.tscn")
var Spinner = preload("res://Entities/EnemySpinning-Spawned.tscn")
var Key = preload("res://Entities/Key.tscn")

export var segment_start_key = "start"
export var fireball_speed = 150.0
export var spinner_speed = Vector2(-150, 0)
export var hitpoints = 3

onready var anim = get_node("../AnimationPlayer")
onready var head = get_node("Head")
onready var top = get_node("Top Segment")
onready var mid = get_node("Mid Segment")
onready var bottom = get_node("Bottom Segment")
onready var fb_point = get_node("Head/Flamepoint")
onready var flash_anim = get_node("../FlashPlayer")

onready var enemies = get_tree().get_root().find_node("Enemies", true, false)
onready var player = get_tree().get_root().find_node("Player", true, false)

onready var VFX_Manager = get_node("/root/VFX_Manager")

var segments = {
	"start": {name: "Appear-Start", next: ["idle"]},
	"idle": {name: "Bobbing-Sideways", next: ["idle", "fireball"]},
	"fireball": {name: "Fireball-RightToLeft", next: ["idle", "idle", "attach"]},
	"attach": {name: "Disappear-Attach-Appear", next: ["spinners"]},
	"spinners": {name: "Fire-Spinners", next: ["idle"]}
}

var fb_int_duration = 0.5

var fb_counter = 0.0
var fb_int_counter = 0.0

var cur_segment = null
var dying = false

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

func start_segments():
	anim.stop()
	if not segments.has(segment_start_key):
		print("cannot find segment start key " + segment_start_key)
		return
	
	var cur_segment = segments[segment_start_key]
	anim.play(cur_segment.name)

func next_segment():
	if cur_segment == null:
		print("no active segment for next_segment")
		return

	var nxt = cur_segment.next	
	if nxt == null or nxt.size() == 0:
		print("segments ended")
		return

	var r = int(rand_range(0, nxt.size()))
	cur_segment = segments[nxt[r]]
	
	anim.play(cur_segment.name)
	
func _on_AnimationPlayer_finished():
	if dying:
		return
		
	next_segment()

func _on_Eye__Weak_Spot_body_enter( body ):
	if dying: return
	print("Eye enter ", body.get_name())
	if body extends preload("res://Scripts/EnemySpinner.gd"):
		flash()
		hitpoints -= 1
		if hitpoints <= 0:
			die()

func flash():
	flash_anim.play("Flash")
	
func shake(duration, frequency = 50.0, amplitude = 6.0):
	VFX_Manager.shake(player.get_node("Camera2D"), duration, frequency, amplitude)

func player_input(enable_input):
	player.input_enable = enable_input
	
func die():
	if dying: return
	dying = true
	var key = Key.instance()
	get_tree().get_root().find_node("Pickups", true, false).add_child(key)
	
	key.set_global_pos(head.get_global_pos())
	key.set_z(-1)
	
	anim.play("Disappear-Death", 0.5)
