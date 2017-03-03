extends Node

export var draw_tile = 27

onready var map = find_node("TileMap")
onready var debug_map = find_node("Debug-TileMap")
onready var player = find_node("Player")

func _ready():
	set_process_input(true)
	
func _input(event):	
	if event.type == InputEvent.MOUSE_BUTTON:
		var released = not event.pressed
		
		if released and event.button_index == BUTTON_RIGHT:
			var tpos = map.world_to_map(map.get_global_mouse_pos())
			var cur = map.get_cellv(tpos)
			if cur != draw_tile:
				map.set_cellv(tpos, draw_tile)
			else:
				map.set_cellv(tpos, -1)
	elif event.type == InputEvent.KEY:
		var released = not event.pressed
		
		if released:
			if event.scancode == KEY_1:
				player.add_tilecount(1)
			elif event.scancode == KEY_2:
				player.add_tilecount(-1)
