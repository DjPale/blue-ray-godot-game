extends StaticBody2D

export var timeout = 0.5
export var is_reverse = false

var tilemap = null;

onready var anim = get_node("AnimationPlayer")

func _ready():
	anim.set_speed(1.0 / timeout)
	if is_reverse: anim.play_backwards("Fade")
	set_process(true)
	
func _process(delta):
	if timeout > 0:
		timeout -= delta
		if timeout <= 0:
			_die()
		
func _die():
	if tilemap != null && not is_reverse: tilemap.tile_on(self)
	queue_free()