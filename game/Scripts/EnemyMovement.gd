extends KinematicBody2D

export(float,0,300) var walk_speed = 100
export(Vector2) var gravity = Vector2(0, 10)
export(int,"Right","Left") var start_dir = 0
export var destroy_tiles = true
export var stop_on_edges = true

var velocity = Vector2()

var orig_pos

var raycast_left
var raycast_right
var anim

var on_ground = false
var on_left_edge = false
var on_right_edge = false

onready var tile_map = get_tree().get_root().find_node("TileMap", true, false)
onready var VFX_Manager = get_node("/root/VFX_Manager")

var dir

func _ready():
	orig_pos = get_pos()
	
	raycast_left = get_node("RayLeft")
	raycast_left.add_exception(self)

	raycast_right = get_node("RayRight")
	raycast_right.add_exception(self)
	
	anim = get_node("Sprite")
	
	dir = start_dir
	
	if stop_on_edges: VFX_Manager.add_light(self, 2.0)
	
	set_fixed_process(true)

func _exit_tree():
	VFX_Manager.destroy_light(self)

func _fixed_process(delta):
	_check_state()
	_do_ai(delta)
	_update_anims()
	_do_movement(delta)

func _do_ai(delta):
	if stop_on_edges:
		if on_left_edge: 
			dir = 0
			
		if on_right_edge:
			dir = 1
	
	var dir_sign = (1 if dir == 0 else -1)
	velocity.x = (dir_sign * walk_speed)
		
	if not on_ground:
		if stop_on_edges: velocity.x = 0
		velocity.y += gravity.y

func _do_movement(delta):
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		var obj = get_collider()
		
		if (destroy_tiles && obj == tile_map && n.y == 0):
			tile_map.destroy_tile(tile_map.world_to_map(get_collision_pos() + Vector2(sign(velocity.x) * 2, -sign(velocity.y) * 2)))
			
		if obj extends preload("PlayerControl.gd"):
			obj.hit(self)

		if n.x == -1: dir = 1
		if n.x == 1: dir = 0

		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	

func _check_state():
	on_left_edge = not raycast_left.is_colliding() and raycast_right.is_colliding()
	on_right_edge = not raycast_right.is_colliding() and raycast_left.is_colliding()
	
	on_ground = raycast_left.is_colliding() or raycast_right.is_colliding()
	
	if get_global_pos().y > 2000: die()

func _update_anims():
	anim.set_flip_h(dir == 1)
	if velocity.x != 0:
		anim.set_animation("walk")
	else:
		anim.set_animation("standing")

func die():
	VFX_Manager.puff(get_node("/root"), get_global_pos() - Vector2(32, 32))
	queue_free()