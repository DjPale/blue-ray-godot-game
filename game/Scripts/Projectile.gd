extends KinematicBody2D

const Util = preload("Util.gd")

export(Vector2) var speed = Vector2(100, 0)
export var destroy_tiles = true
export(float) var lifetime = 6.0
export(float) var die_time = 0.5
export(Vector2) var hitbox_offset = Vector2(3, 3)

onready var tile_map = get_tree().get_root().find_node("TileMap", true, false)

var velocity = Vector2()
var is_dead = false
var lifetime_cnt = 0

var prev_speed = Vector2()

onready var coll_shape = get_node("CollisionShape2D")
onready var VFX_Manager = get_node("/root/VFX_Manager")

func _ready():
	lifetime_cnt = lifetime
	VFX_Manager.add_light(self, 0.5)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if is_dead: return
	
	#_check_state()
	_do_ai(delta)
	#_update_anims()
	_do_movement(delta)

func _do_ai(delta):
	_check_hitbox_adjust()
	
	velocity = speed
	
	if lifetime_cnt > 0:
		lifetime_cnt -= delta
		if lifetime_cnt <= 0: _die()

# very hacky and picky, but hitboxes are important - they need to be "connected" to visuals properly
func _check_hitbox_adjust():
	if prev_speed == speed: return
	
	coll_shape.set_pos(Vector2(-sign(speed.x) * hitbox_offset.x, -sign(speed.y) * hitbox_offset.y))
	
	prev_speed = speed

func _do_movement(delta):
	move(velocity * delta)
	
	if is_colliding():
		var obj = get_collider()
		#print("projectile#", self.get_name(), "->", obj)
		
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
	VFX_Manager.destroy_light(self)
	self.queue_free()