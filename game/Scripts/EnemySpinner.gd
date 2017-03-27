extends KinematicBody2D

export(Vector2) var speed = Vector2(100, 0)

onready var sprite = get_node("Sprite")
var indicator = null

onready var tile_map = get_tree().get_root().find_node("TileMap", true, false)

var velocity = Vector2()
var ground = Vector2()

var tile_lock_pos = Vector2()
var has_tile_lock = false
var tile_pos = Vector2()

func _ready():
	if has_node("Indicator"): indicator = get_node("Indicator") # to avoid error message
	velocity = speed
	set_process(true)
	set_fixed_process(true)
	
func _process(delta):
	_update_anims(delta)

func _fixed_process(delta):
	_check_state()
	_do_ai(delta)
	_do_movement(delta)

func _get_reach_pos(dir, vel_add = true):
	var reach_pos = get_global_pos()
	reach_pos = reach_pos + dir * 28.0
	if vel_add: reach_pos += Vector2(sign(-velocity.x) * 26, sign(-velocity.y) * 26)
	return reach_pos

func _get_tile(dir, vel_add = true):
	var reach_pos = _get_reach_pos(dir, vel_add)
	return tile_map.get_cellv(tile_map.world_to_map(reach_pos))

func _is_fixed_tile(dir, vel_add = true):
	return (_get_tile(dir, vel_add) != -1)

func _check_state():
	has_tile_lock = false
	
	# normalized vector pointing to ground
	var v_down = Vector2(-velocity.y, velocity.x).normalized()
	# normalized direction vector (pointing towards "floor")
	var v_dir = velocity.normalized()
	
	var col_dir = _is_fixed_tile(v_dir, false)
	var col_down = _is_fixed_tile(v_down, true) 
	var col_down2 = _is_fixed_tile(v_down + v_dir, false)
	
	# are we colliding in front? turn left
	if col_dir:
		has_tile_lock = true
		velocity = Vector2(velocity.y, -velocity.x)
	elif col_down:
		has_tile_lock = true
		tile_lock_pos = tile_map.world_to_map(_get_reach_pos(v_down))
	elif col_down2:
		has_tile_lock = true
		tile_lock_pos = tile_map.world_to_map(_get_reach_pos(v_down + v_dir, false))
	else:
		var next_down = Vector2(-v_down.y, v_down.x)
		var next_dir = Vector2(-v_dir.y, v_dir.x)
		# are we at the edge of a tile when turning right?
		if _is_fixed_tile(next_down + next_dir, false):
			has_tile_lock = true
			tile_lock_pos = tile_map.world_to_map(_get_reach_pos(next_down + next_dir, false))
			velocity = Vector2(-velocity.y, velocity.x)

func _do_ai(delta):
	pass

func _do_movement(delta):
	var motion = velocity * delta
	motion = move(motion)

func _update_anims(delta):
	sprite.set_rotd(sprite.get_rotd() + delta * -speed.length() * (2.0 if has_tile_lock else 4.0))
	
	if indicator != null:
		if has_tile_lock:
			indicator.set_hidden(false)
			indicator.set_global_pos(tile_lock_pos * 64.0 + Vector2(32, 32))
		else:
			indicator.set_hidden(true)
	