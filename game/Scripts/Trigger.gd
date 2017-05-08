extends Area2D

export var player_freeze = false
export var player_freeze_timeout = 0.0
export var trigger_once = true

export var object_name = ""
export var object_func = ""

onready var player = get_tree().get_root().find_node("Player", true, false)

var freeze_cnt = 0
var was_triggered = false

func _ready():
	set_process(true)

func _process(delta):
	if freeze_cnt > 0:
		freeze_cnt -= delta
		
		if freeze_cnt <= 0:
			player.input_enable = true

func do_trigger():
	if trigger_once and was_triggered:
		return
		
	was_triggered = true
	
	if player_freeze:
		player.input_enable = false
		
		if player_freeze_timeout > 0:
			freeze_cnt = player_freeze_timeout
			
	if object_name.empty() or object_func.empty():
		print("empty object name or func name")
		return
		
	var obj = get_tree().get_root().find_node(object_name, true, false)
	if obj != null and obj.has_method(object_func):
		obj.call(object_func)
	else:
		print("object / function not found " + object_name + "." + object_func)

func _on_body_enter( body ):
	do_trigger()
