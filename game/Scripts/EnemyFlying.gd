extends KinematicBody2D

export var velocity = Vector2(100, 0)
export var destroy_tiles = true

onready var VFX_Manager = get_node("/root/VFX_Manager")

var raycast_left
var raycast_right

onready var anim = get_node("Sprite")
onready var map = get_tree().get_root().find_node("TileMap", true, false)

func _ready():
	raycast_left = get_node("RayLeft")
	raycast_left.add_exception(self)

	raycast_right = get_node("RayRight")
	raycast_right.add_exception(self)
	
	get_node("Sprite").play()
	
	VFX_Manager.add_light(self, 0.5)
	
	set_fixed_process(true)
	
func _exit_tree():
	VFX_Manager.destroy_light(self)
	
func _fixed_process(delta):
	_do_ai(delta)
	
func _do_ai(delta):
	if (velocity.x > 0 && raycast_right.is_colliding()) || (velocity.x < 0 && raycast_left.is_colliding()):
		if destroy_tiles:
			var tpos = map.world_to_map(get_pos())
			tpos.x += (1 * sign(velocity.x))
			map.destroy_tile(tpos)
		
		velocity.x *= -1
		
	var motion = move(velocity * delta)

	anim.set_flip_h(velocity.x < 0)
