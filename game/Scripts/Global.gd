extends Node

var score = 0
var level = 0
var spawn_point = Vector2()

var level_list = [
	"Blind leading the Blind",
	"The Beginning",
	"Spin Spin Sugar",
	"Firestarter",
	"Do not go with the flow",
	"The Tower",
	"Shields Aligned",
	"Outside the box",
	"Downhill"
]

var level_data = {}

func _ready():
	var level_name = get_tree().get_current_scene().get_name()
	print("Global ready")
	
	for l in range(0, level_list.size()):
		if level_name == level_list[l]: level = l

func reset_level():
	get_tree().reload_current_scene()
	
func next_level():
	level += 1
	if level >= level_list.size(): level = 0
	
	clear_level_data()
	spawn_point = Vector2()
	get_tree().change_scene("res://Levels/" + level_list[level] + ".tscn")
	
func clear_level_data():
	level_data.clear()
	
func create_key(obj, key):
	if obj == null: return key
	return String(obj.get_rid().get_id()) + key
	
func set_level_data(obj, key, val):
	var rkey = create_key(obj, key)
	level_data[key] = val
	
func get_level_data(obj, key):
	var rkey = create_key(obj, key)
	if level_data.has(rkey): return level_data[rkey]
	return null

