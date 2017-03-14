extends KinematicBody2D

export(float) var spawn_interval = 3.0
export(Vector2) var fireball_speed = Vector2(100, 0)
export(float) var fireball_lifetime = 6.0
export(float) var spawn_cnt = 0

onready var anim = find_node("AnimationPlayer")
var cur_projectile = null

func _ready():
	if spawn_cnt == 0: spawn_cnt = spawn_interval
	set_process(true)

func _process(delta):
	if spawn_cnt > 0:
		spawn_cnt -= delta
		if spawn_cnt <= 0:
			_start_spawn()
			spawn_cnt = spawn_interval

			
func _start_spawn():
	var p = preload("res://Entities/Fireball.tscn").instance()
	p.speed = Vector2()
	p.lifetime = fireball_lifetime
	add_child(p)
	p.set_global_pos(get_global_pos())
	cur_projectile = p
			
	anim.play("Fire")
	
func _do_spit():
	if cur_projectile != null:
		cur_projectile.speed = fireball_speed
		cur_projectile = null
