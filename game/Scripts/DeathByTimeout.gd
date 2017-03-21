extends Node

export(float) var timeout = 1.0

var cnt

func _ready():
	cnt = timeout
	set_process(true)
	
func _process(delta):
	if cnt > 0:
		cnt -= delta
		if cnt <= 0:
			queue_free()