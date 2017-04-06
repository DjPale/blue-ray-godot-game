extends ParallaxBackground

onready var bg1 = get_node("ParallaxLayer/Sprite")
onready var bg2 = get_node("ParallaxLayer 2/Sprite")

func set_darkness(amount):
	var rev = 1.0 - amount
	
	var c1 = bg1.get_modulate()
	var c2 = bg2.get_modulate()
	
	c1.a = rev
	c2.a = rev
	
	bg1.set_modulate(c1)
	bg2.set_modulate(c2)