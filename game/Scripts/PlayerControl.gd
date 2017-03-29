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
export(bool) var head_crack_tiles = true
export(bool) var regain_destroyed_tiles = true
export(int) var tile_count = 0
export(float) var tile_pause = 0.25
export(float) var tile_length = 50.0
export(float) var freeze_time = 0.3 # freeze when manipulating tiles and crashing head in them

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

var orig_velocity # used for freezing
var orig_offset # used for crouching
var orig_score # level reset

var raycast_left
var raycast_right

onready var Global = get_node("/root/Global")
onready var VFX_Manager = get_node("/root/VFX_Manager")

onready var camera = get_node("Camera2D")
onready var anim = get_node("Sprite")
onready var indicator = get_node("Indicator")
onready var beam = get_node("Beam")

func _ready():
	if Global.spawn_point != Vector2():
		set_global_pos(Global.spawn_point)
	
	orig_offset = anim.get_offset()
	jump_counter = jump_count
	_set_jump_equation(jump_max_height, jump_max_length, jump_time_to_height)

	raycast_left = get_node("RayLeft")
	raycast_left.add_exception(self)

	raycast_right = get_node("RayRight")
	raycast_right.add_exception(self)

	if current_map != null: tile_map = get_node(current_map)

	score += Global.score
	orig_score = score
		
	if regain_destroyed_tiles: tile_map.connect("tile_destroyed", self, "_on_tile_destroyed")
		
	connect("score_change", get_node("../UI Layer/Money"), "_on_count_change")
	connect("tile_count_change", get_node("../UI Layer/Block Count"), "_on_count_change")

	get_node("../UI Layer/Pause Menu").connect("menu_restart", self, "reset_level")
	get_node("../UI Layer/Pause Menu").connect("menu_quit", self, "quit_game")
	get_node("../UI Layer/Transition").connect("transition_complete", self, "_on_transition_complete")

	_emit_count_change()
	emit_signal("score_change", score)

	if debug_keys: 
		set_process_input(true)
		get_parent().call_deferred("add_child", preload("res://Entities/Debug-Tilemap.tscn").instance())
		
	set_process(true)
	set_fixed_process(true)
	
func _on_transition_complete():
	input_enable = true
	
func _on_tile_destroyed():
	add_tiles(1)
	
func _input(event):
	if event.type == InputEvent.KEY:
		if event.pressed: return
		
		var key = event.scancode
		
		if key == KEY_R:
			reset_level()

		if key == KEY_I:
			invincible = not invincible
			
		if key == KEY_N:
			next_level()
						
		if key == KEY_1:
			add_tiles(1)
		elif key == KEY_2:
			add_tiles(-1)

func _process(delta):
	var reach_pos = get_reach_pos()
	indicator.set_global_pos(reach_pos * Vector2(64, 64) + Vector2(32, 32))

func _fixed_process(delta):
	_do_timers(delta)
	
	if freeze_timer > 0: return
	
	_check_state()
		
	velocity.x = 0
	if on_ground: 
		velocity.y = 0
	else:
		velocity.y += delta * gravity.y

	if (input_enable && Input.is_action_pressed("player_left")):
		velocity.x = -walk_speed
		face_sign = -1
	elif (input_enable && Input.is_action_pressed("player_right")):
		velocity.x = walk_speed
		face_sign = 1

	if (input_enable && Input.is_action_pressed("player_crouch") && on_ground):
		is_crouching = true
		velocity.x = 0

	if not on_ground: velocity.x *= jump_move_x_scale
		
	if input_enable && Input.is_action_pressed("player_jump"): _jump()
	
	if input_enable && Input.is_action_pressed("player_action"): _do_tile()

	if on_ground:
		var vel_add = false
		
		if raycast_left.is_colliding(): 
			var obj = raycast_left.get_collider()
			_deadly_collision_check(obj)
			if obj != null && "velocity" in obj: 
				velocity.x += obj.velocity.x
				vel_add = true
			
		if raycast_right.is_colliding(): 
			var obj = raycast_left.get_collider()
			_deadly_collision_check(obj)
			if not vel_add && obj != null && "velocity" in obj: 
				velocity.x += obj.velocity.x

	var motion = velocity * delta
	motion = move(motion)

	if (is_colliding()):
		var n = get_collision_normal()
		var obj = get_collider()
		_deadly_collision_check(obj)
			
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

		# ceiling?
		if n.y == 1: _crack_tile()
		
	_update_anim()

	# temp death
	if camera != null:
		if get_pos().y > camera.get_limit(MARGIN_BOTTOM): hit(self)
	else:
		if get_pos().y > 1500: hit(self)

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
	if not head_crack_tiles: return
	
	var reach_pos = tile_map.world_to_map(get_pos() )

	reach_pos.y -= 1
	
	tile_map.crack_tile(reach_pos)
	
	# _freeze(true)
	
func get_reach_pos():
	var tile_point = get_pos() + Vector2(face_sign * tile_length, 0)
	var reach_pos = tile_map.world_to_map(tile_point)

	reach_pos.x += face_sign
	if is_crouching: reach_pos.y += 1
	
	return reach_pos
	
func add_tiles(num):
	tile_count += num
	if tile_count < 0: tile_count = 0
	if num != 0: VFX_Manager.floating_text(self, String(num))
	_emit_count_change()
	
func clear_tilecount():
	add_tiles(-tile_count)
		
func get_tile_count():
	return tile_count
	
func _emit_count_change():
	# indicator.set_hidden(get_tile_count() == 0)
	emit_signal("tile_count_change", get_tile_count())

func _do_beam():
	var deg = 45 if is_crouching else 90
	deg *= face_sign
	
	beam.set_param(Particles2D.PARAM_DIRECTION, deg)
	beam.set_emitting(true)

func _do_tile():
	if tile_timer > 0 || tile_map == null: return
	
	var reach_pos = get_reach_pos()
	
	_do_beam()

	var tiles_ret = tile_map.create_or_destroy_tile(reach_pos, (get_tile_count() > 0))
	add_tiles(-tiles_ret)

	if tiles_ret == 0: VFX_Manager.puff(get_parent(), reach_pos * 64)

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
	if score + points < 0:
		points = -score
	
	if points != 0:
		VFX_Manager.floating_text(self, String(points))
		score += points
		emit_signal("score_change", score)
	
func _deadly_collision_check(obj):
	if obj != null && obj != tile_map: 
		if obj.has_node("BasicEnemy") || obj extends preload("Projectile.gd"):
			hit(obj)
	
func hit(obj):
	if invincible: return
	
	input_enable = false
	
	#collect(-1000)
	
	reset_level()
	
func enter_door():
	next_level()
	
func quit_game():
	get_tree().quit()

func reset_level():
	Global.score = orig_score
	Global.reset_level()

func next_level():
	Global.score = score
	Global.next_level()
	
func set_spawn(obj):
	Global.spawn_point = obj.get_global_pos()
	
func _set_jump_equation(max_height, max_length, time_to_height):
	gravity.y = (2.0 * max_height) / (time_to_height * time_to_height)
	
	move_speed_y = sqrt(2 * gravity.y * max_height)
	jump_move_x_scale = (max_length / time_to_height) / walk_speed
	