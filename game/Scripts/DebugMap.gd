extends TileMap

export var tile_num = 0

onready var _player = get_node("/root").find_node("Player", true, false)

var core_offset_map = [
	Vector2(-1, 0),
	Vector2(-2, 0),
	Vector2(-1, 1),
	Vector2(-2, 1),
	Vector2(-3, 1),
	
	Vector2(1, 0),
	Vector2(2, 0),
	Vector2(1, 1),
	Vector2(2, 1),
	Vector2(3, 1)
]

func _ready():
	print(_player)
	set_process_input(true)
	
func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			_do_shit(get_global_mouse_pos())
	elif event.type == InputEvent.KEY:
		if not event.pressed and event.scancode == KEY_D:
			_do_shit(_player.get_global_pos())

func _do_shit(pos):
	prints(pos)
	_clear_tiles()
	_update_tiles(pos)
									
func _clear_tiles():
	clear()
	
func _update_tiles(pos):
	var blocks = 0
	if _player != null: blocks = _player.tile_count
	
	var tpos = world_to_map(pos)
	_update_tile(tpos, blocks)
	
func _update_tile(cell, blocks):
	if blocks < 0: return
	
	var nb = blocks - 1
	
	for v in core_offset_map:
		var tpos = cell + v
		var cur = get_cellv(tpos)
		if cur != tile_num: set_cellv(tpos, tile_num)
		var build_y = 0
		if blocks >= 1: build_y = -1
		if v.y == 0: _update_tile(tpos + Vector2(0, v.y + build_y), nb)
		
