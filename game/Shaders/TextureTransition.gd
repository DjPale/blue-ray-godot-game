extends Sprite

export(float) var duration_seconds = 1
export(float) var pre_delay_seconds = 2
export var auto_start = true
export var fade_in = true

var cnt = 0
var pre_cnt = 0

signal transition_complete

onready var mat = get_material()

func _ready():
	var tex = get_texture()
	
	if tex != null:
		var r = get_viewport_rect().size
		set_scale(Vector2(r.width / tex.get_width(), r.height / tex.get_height()))
	else:
		print("Missing texture on transition, ignoring")
	
	set_process(true)
	if auto_start: start()
	
func _process(delta):
	if pre_cnt > 0:
		pre_cnt -= delta
	
	if pre_cnt <= 0 && cnt > 0:
		cnt -= delta

		if cnt <= 0:
			cnt = 0
			emit_signal("transition_complete")
		else:
			var t = cnt / duration_seconds
			if not fade_in: t = 1 - t
			mat.set_shader_param("cutoff", t)
	
func start():
	mat.set_shader_param("cutoff", (1 if fade_in else 0))
	pre_cnt = pre_delay_seconds
	cnt = duration_seconds
