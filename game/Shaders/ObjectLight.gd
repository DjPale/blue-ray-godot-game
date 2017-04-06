extends Node2D

export var follow = "Camera2D"

var enabled = false

var follow_object = null

var rand_cnt = 0.1
var orig_scale
var material = get_material()
var orig_color = material.get_shader_param("tint")


func _ready():
	if follow_object == null: follow_object = get_tree().get_root().find_node(follow, true, false)
	
	orig_scale = get_scale()
	set_fixed_process(true)
	set_process(true)
	
func set_intensity(amount):
	amount = clamp(amount, 0.0, 1.0)
	orig_color.a = amount
	material.set_shader_param("tint", orig_color)
	enabled = (amount > 0.0)
	#prints("set_intensity", amount, orig_color, enabled)
	
func trigger_anim():
	material.set_shader_param("noise", rand_range(0.005, 0.03))

	var s = rand_range(-0.1, 0.1)
	set_scale(orig_scale + Vector2(s, s))
	
func _process(delta):
	if not enabled: return
	
	rand_cnt -= delta
	if rand_cnt <= 0:
		trigger_anim()
		rand_cnt = rand_range(0.02, 0.1)
	
	
func _fixed_process(delta):
	if not enabled: return
	
	var vp = follow_object.get_viewport_transform()
	
	if follow_object != null:
		var gt = vp * follow_object.get_global_pos()
		
		if follow_object extends Camera2D:
			gt = vp * (follow_object.get_global_transform_with_canvas() * follow_object.get_camera_pos())
			gt -= Vector2(512, 300)
			
		set_pos(gt)
