extends KinematicBody2D

export var gravity = Vector2(0, 200.0)
export(float,0,1000,10) var walk_speed = 200.0

export(float,1.0,400.0,1.0) var jump_max_height = 70.0
export(float,1.0,120,1.0) var jump_max_length = 64.0
export(float,0.01,1.0,0.05) var jump_time_to_height = 0.5
export(int,1,10) var jump_count = 1
export(float,0,5.0,0.05) var jump_pause = 0.15
export(float,0,1,0.05) var jump_grace = 0.1

export var crouch_offset = Vector2(0, -4)

export(NodePath) var current_map = null
export(float) var tile_pause = 0.25
export(float) var tile_length = 50.0
export(float) var freeze_time = 0.3 # freeze when manipulating tiles and crashing head in them
export(int,0,10) var tile_count = 0

export(int) var score = 0

export var input_enable = false
export var invincible = false
export var debug_keys = true

signal tile_count_change
signal score_change

var tile_map = null

var move_speed_y = 0.0
var jump_counter = 0
var jump_timer = 0.0
var jump_move_x_scale = 0.0
var jump_grace_counter = 0

var tile_timer = 0.0
var freeze_timer = 0.0

var velocity = Vector2()
var was_airborne = true
var on_ground = false
var is_crouching = false

var face_sign = 1

var orig_pos
var orig_velocity # used for freezing
var orig_offset # used for crouching
var orig_score # level reset

var raycast_left
var raycast_right

onready var global = get_node("/root/Global")

onready var anim = get_node("Sprite")
onready var particles = get_node("../Particles2D")

func _ready():
	orig_pos = get_pos()
	orig_offset = anim.get_offset()
	jump_counter = jump_count
	_set_jump_equation(jump_max_height, jump_max_length, jump_time_to_height)

	raycast_left = get_node("RayLeft")
	raycast_left.add_exception(self)

	raycast_right = get_node("RayRight")
	raycast_right.add_exception(self)

	if current_map != null: tile_map = get_node(current_map)

	score += global.score
	orig_score = score
		
	connect("score_change", get_node("../UI Layer/Money"), "_on_count_change")
	connect("tile_count_change", get_node("../UI Layer/Block Count"), "_on_count_change")
	get_node("../UI Layer/Transition").connect("transition_complete", self, "_on_transition_complete")
	
	emit_signal("tile_count_change", tile_count)
	emit_signal("score_change", score)

	if debug_keys: set_process_input(true)
	set_fixed_process(true)
	
func _on_transition_complete():
	input_enable = true
	
func _input(event):
	if event.type == InputEvent.KEY:
		if event.pressed: return
		
		var key = event.scancode
		
		if key == KEY_R:
			reset_level()

		if key == KEY_I:
			invincible = not invincible
						
		if key == KEY_1:
			add_tilecount(1)
		elif key == KEY_2:
			add_tilecount(-1)


func _fixed_process(delta):
	_do_timers(delta)
	
	if freeze_timer > 0: return
	
	_check_state()
	
	velocity.x = 0
	velocity.y += delta * gravity.y

	if (input_enable && Input.is_action_pressed("ui_left")):
		velocity.x = -walk_speed
		face_sign = -1
	elif (input_enable && Input.is_action_pressed("ui_right")):
		velocity.x = walk_speed
		face_sign = 1

	if (input_enable && Input.is_action_pressed("ui_down") && on_ground):
		is_crouching = true
		velocity.x = 0

	if not on_ground: velocity.x *= jump_move_x_scale
		
	if input_enable && Input.is_action_pressed("ui_up"): _jump()
	
	if input_enable && Input.is_action_pressed("ui_accept"): _do_tile()

	# not sure why this happens TBH
	if is_colliding():
		var n = get_collision_normal()
		if n.x != 0: velocity.x = 0
		if n.y != 0: velocity.y = 0
		var obj = get_collider()
		if obj != tile_map: 
			# TODO: OMMMGG find better solution on this scenario
			# This is probably because the collision test will trigger at on object first and prevent it from colliding with the targetr
			# Therefore only one of the entities tests positive on "is_colliding"...
			if obj.has_node("BasicEnemy") || obj extends preload("Projectile.gd"):
				hit(obj)

	var motion = velocity * delta
	
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		var obj = get_collider()
		if obj != tile_map: 
			if obj.has_node("BasicEnemy") || obj extends preload("Projectile.gd"):
				hit(obj)
			
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

		# ceiling?
		if n.y == 1: _crack_tile()
		
	_update_anim()

	# temp death	
	if get_pos().y > 800: reset_level()

func _do_timers(delta):
	if jump_timer > 0:
		jump_timer -= delta
		if jump_timer < 0: jump_timer = 0
		
	if tile_timer > 0:
		tile_timer -= delta
		if tile_timer < 0: tile_timer = 0
		
	if jump_grace_counter > 0:
		jump_grace_counter -= delta
		if jump_grace_counter < 0: jump_grace_counter = 0

	if freeze_timer > 0:
		freeze_timer -= delta
		if freeze_timer <= 0:
			_freeze(false)

func _check_state():
	is_crouching = false # will be updated on input stage
	on_ground = _is_on_ground()
	
	if on_ground:
		jump_counter = jump_count
		jump_grace_counter = jump_grace
		
		if was_airborne: 
			jump_timer = jump_pause
		
	was_airborne = !on_ground

func _is_on_ground():
	return raycast_left.is_colliding() || raycast_right.is_colliding()

func _jump():
	if (jump_counter == 0 || jump_timer > 0 || (not on_ground and jump_grace_counter <= 0)) : return
	
	if was_airborne: velocity.y = 0
	
	jump_counter -= 1
	jump_timer = jump_pause
	
	velocity.y -= move_speed_y
	
func _crack_tile():
	var reach_pos = tile_map.world_to_map(get_pos() )

	reach_pos.y -= 1
	
	tile_map.crack_tile(reach_pos)
	
	# _freeze(true)
	
func add_tilecount(cnt):
	tile_count += cnt
	if tile_count < 0: tile_count = 0
	emit_signal("tile_count_change", tile_count)
	
func clear_tilecount():
	tile_count = 0
	emit_signal("tile_count_change", tile_count)

func _do_tile():
	if tile_timer > 0 || tile_map == null: return
	
	var tile_point = get_pos() + Vector2(face_sign * tile_length, 0)
	var reach_pos = tile_map.world_to_map(tile_point)

	reach_pos.x += face_sign
	if is_crouching: reach_pos.y += 1
	
	if particles != null:
		particles.set_pos(reach_pos * 64)
		particles.set_emitting(true)
	
	var tiles_added = tile_map.create_or_destroy_tile(reach_pos, (tile_count > 0))
	
	add_tilecount(-tiles_added)
		
	_freeze(true)

func _freeze(f):
	if f:
		orig_velocity = velocity
		freeze_timer = freeze_time
	else:
		velocity = orig_velocity
		tile_timer = tile_pause

func _update_anim():
	anim.set_flip_h(face_sign == -1)
	anim.set_offset(orig_offset)
	
	if not on_ground:
		anim.set_animation("jumping")
	elif is_crouching:
		anim.set_animation("crouching")
		anim.set_offset(orig_offset + crouch_offset)
	else:
		if velocity.x != 0:
			anim.set_animation("walking")
		else:
			anim.set_animation("standing")
		
func collect(points):
	score += points
	emit_signal("score_change", score)
	
func hit(obj):
	if invincible: return
	
	reset_level()
	
func enter_door():
	next_level()

func reset_level():
	global.score = orig_score
	global.reset_level()

func next_level():
	global.score = score
	global.next_level()
	
func _set_jump_equation(max_height, max_length, time_to_height):
	gravity.y = (2.0 * max_height) / (time_to_height * time_to_height)
	
	move_speed_y = sqrt(2 * gravity.y * max_height)
	jump_move_x_scale = (max_length / time_to_height) / walk_speed
	