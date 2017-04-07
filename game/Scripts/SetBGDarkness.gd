extends ParallaxBackground

onready var bg1 = get_node("ParallaxLayer/Sprite")
onready var bg2 = get_node("ParallaxLayer 2/Sprite")
onready var bg3 = get_node("ParallaxLayer 3/Sprite")

func set_darkness(amount):
	var rev = 1.0 - amount
	
	var c1 = bg1.get_modulate()
	var c2 = bg2.get_modulate()
	var c3 = bg3.get_modulate()
	
	c1.a = rev
	c2.a = rev
	c3.a = amount
	
	bg1.set_modulate(c1)
	bg2.set_modulate(c2)
	bg3.set_modulate(c3)