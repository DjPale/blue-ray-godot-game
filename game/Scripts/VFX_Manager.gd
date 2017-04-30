extends Node

var FloatingText = preload("res://Entities/FloatingText.tscn")
var Puff = preload("res://Entities/Puff.tscn")
var Light = preload("res://Entities/Light.tscn")
var Shake = preload("res://Scripts/Shake.gd")

var light_root = null
var darkness = null
var bg_layer = null
var darkness_enable = false

func floating_text(obj, txt):
	var ft = FloatingText.instance()
	ft.set_text(txt)
	obj.add_child(ft)
	
func puff(root, pos):
	var p = Puff.instance()
	p.set_emitting(true)
	p.set_global_pos(pos)
	root.add_child(p)
	
func enable_darkness(enable):
	darkness_enable = enable
	
func set_darkness(amount):
	if not darkness_enable: return
	
	amount = clamp(amount, 0.0, 1.0)
	var rev = 1.0 - amount
	darkness.set_modulate(Color(rev, rev, rev, rev))
	bg_layer.set_darkness(amount)
	get_tree().call_group(0, "Lights", "set_intensity", amount)
		
func add_light(obj, scale = 1.0):
	light_root = get_tree().get_root().find_node("Lights", true, false)
	darkness = get_tree().get_root().find_node("Darkness Overlay", true, false)
	bg_layer = get_tree().get_root().find_node("ParallaxBackground", true, false)
	
	var l = Light.instance()
	l.set_scale(Vector2(scale, scale))
	l.follow_object = obj
	l.add_to_group("Lights")
	l.set_intensity(1.0 - darkness.get_modulate().r)
	
	if light_root != null && not light_root.is_queued_for_deletion(): light_root.add_child(l, true)
	
	#prints("Added light", l.get_name(), " for", obj.get_name())
	
	return l
	
func destroy_light(obj):
	if light_root == null || str(light_root) == "[Deleted Object]" || obj == null: return
	
	for l in light_root.get_children():
		if l != null && l.is_inside_tree() && l.follow_object == obj: 
			#prints("Removed light", l.get_name(), " for", obj.get_name())
			l.queue_free()
			return

func shake(obj, duration = 0.2, frequency = 15.0, amplitude = 8.0):
	var n = Node.new()
	n.set_script(Shake)
	obj.add_child(n)
	n.shake(obj, duration, frequency, amplitude)
