extends Node

var score = 0
var level = 0

var level_list = [
	"Level1",
	"Level2",
	"Level3",
	"Level4"
]

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
	
	get_tree().change_scene("res://Levels/" + level_list[level] + ".tscn")
	
func get_level_name():
	return "Level " + String(level + 1)