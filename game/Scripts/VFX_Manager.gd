extends Node

var FloatingText = preload("res://Entities/FloatingText.tscn")

func floating_text(obj, txt):
	var ft = FloatingText.instance()
	ft.set_text(txt)
	obj.add_child(ft)