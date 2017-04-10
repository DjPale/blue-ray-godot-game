extends Node

var score = 0
var level = 0
var spawn_point = Vector2()

var level_list = [
	"Blind leading the Blind",
	"The Beginning",
	"Spin Spin Sugar",
	"Firestarter",
	"The Tower",
	"Do not go with the flow",
	"Outside the box",
	"Shields Aligned",
	"Downhill"
]

var level_data = {}
var spawn_data = {}

func _ready():
	var level_name = get_tree().get_current_scene().get_name()
	print("Global ready")
	
	for l in range(0, level_list.size()):
		if level_name == level_list[l]: level = l

func reset_level():
	spawn_data.clear()
	get_tree().reload_current_scene()
	
func restart_level():
	clear_level_data()
	reset_level()
	
func next_level():
	level += 1
	if level >= level_list.size(): level = 0
	
	clear_level_data()
	get_tree().change_scene("res://Levels/" + level_list[level] + ".tscn")
	
func clear_level_data():
	spawn_point = Vector2()
	level_data.clear()
	
func set_spawn(pos):
	spawn_point = pos
	for k in spawn_data.keys():
		level_data[k] = spawn_data[k]
		
	spawn_data.clear()
	
func create_key(obj, key):
	if obj == null: return key
	return str(obj.get_path()) + key
	
func set_level_data(obj, key, val, scope):
	var rkey = create_key(obj, key)
	
	if scope == 0:
		level_data[rkey] = val
		prints("PERSIST[LEVEL]:", rkey, val)
	else:
		spawn_data[rkey] = val
		prints("PERSIST[SPAWN]:", rkey, val)
	
func get_level_data(obj, key):
	var rkey = create_key(obj, key)
	if level_data.has(rkey): return level_data[rkey]
	return null

