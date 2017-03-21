extends Node

var FloatingText = preload("res://Entities/FloatingText.tscn")
var Puff = preload("res://Entities/Puff.tscn")

func floating_text(obj, txt):
	var ft = FloatingText.instance()
	ft.set_text(txt)
	obj.add_child(ft)
	
func puff(root, pos):
	var p = Puff.instance()
	p.set_emitting(true)
	p.set_global_pos(pos)
	root.add_child(p)