extends KinematicBody2D

const Util = preload("Util.gd")

export(Vector2) var speed = Vector2(100, 0)
export var destroy_tiles = true
export(float) var lifetime = 6.0
export(float) var die_time = 0.5

onready var tile_map = get_tree().get_root().find_node("TileMap", true, false)

var velocity = Vector2()
var is_dead = false
var lifetime_cnt = 0

func _ready():
	lifetime_cnt = lifetime
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	if is_dead: return
	
	#_check_state()
	_do_ai(delta)
	#_update_anims()
	_do_movement(delta)

func _do_ai(delta):
	velocity = speed
	
	if lifetime_cnt > 0:
		lifetime_cnt -= delta
		if lifetime_cnt <= 0: _die()

func _do_movement(delta):
	move(velocity * delta)
	
	if is_colliding():
		var obj = get_collider()
		print("projectile#", self.get_name(), "->", obj)
		
		if (destroy_tiles && obj == tile_map):
			tile_map.destroy_tile(tile_map.world_to_map(get_collision_pos() + Vector2(sign(velocity.x) * 2, sign(velocity.y))))
			
		if obj extends preload("PlayerControl.gd"):
			obj.hit(self)
		
		_die()
		
func _die():
	if is_dead: return
	is_dead = true
	get_node("CollisionShape2D").queue_free()
	get_node("Particles2D").set_emitting(false)
	yield(Util.timer(self, die_time), "timeout")
	#print("projectile died")
	self.queue_free()