extends Node

export(bool) var global_key = true
export(String) var persist_key = "Persist"
export(int, "Destroy", "Signal") var persist_mode = 0

signal persisted

onready var Global = get_node("/root/Global")

var persisted = false
var persist_obj = null

func _ready():
	if not global_key: 
		persist_obj = self
	else:
		if persist_key.empty():
			printerr("No key for persistence for object ", get_parent().get_name())
			
	persisted = (Global.get_level_data(persist_obj, persist_key) != null)
	
	if persist_mode == 1:
		if persisted: emit_signal("persisted")
	elif persist_mode == 0:
		if persisted: get_parent().queue_free()

func persist():
	if not persisted:
		Global.set_level_data(persist_obj, persist_key, true)
