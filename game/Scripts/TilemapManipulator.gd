extends TileMap

export(int) var tile_num = 16
export(int) var tile_num_crack = 7
export(int) var query_items = 5
export var regen_tiles = true

var test_shape
var test_shape_query

var regen_tile_list = {}
var regen_queue = {}

func _ready():
	test_shape = RectangleShape2D.new()
	test_shape.set_extents(Vector2(get_cell_size().x / 2, get_cell_size().y / 2))
	
	test_shape_query = Physics2DShapeQueryParameters.new()
	test_shape_query.set_shape(test_shape)
	test_shape_query.set_exclude([self])
	#test_shape_query.set_object_type_mask(test_shape_query.get_object_type_mask() | Physics2DDirectSpaceState.TYPE_MASK_AREA)
	test_shape_query.set_object_type_mask(Physics2DDirectSpaceState.TYPE_MASK_KINEMATIC_BODY | Physics2DDirectSpaceState.TYPE_MASK_AREA)
	
func in_spawn_queue(pos):
	return regen_queue.has(pos)
	
# only to be used by player placement
func create_or_destroy_tile(tile_pos, orig_pos, can_create):
	var space_state = get_world_2d().get_direct_space_state()
	
	test_shape_query.set_transform(Matrix32(0, tile_pos * get_cell_size() + test_shape.get_extents()))
	var collisions = space_state.intersect_shape(test_shape_query, query_items)
	
	var query_hit = false
	
	# hacckkkk :( -> since Area doesn't detect StaticBodies which the tiles are using
	for c in collisions:
		var col = c["collider"]
		if col extends preload("Item.gd"):
			if can_create:
				col.reveal()
		else:
			query_hit = true

	var cur_tile = get_cellv(tile_pos)
	
	if cur_tile == tile_num || cur_tile == tile_num_crack:
		clear_cell(tile_pos)
		if regen_tiles:
			if regen_tile_list.has(tile_pos):
				return regen_tile_list[tile_pos]
			else:
				return tile_pos
				
		return null
	elif can_create && cur_tile == -1 && not query_hit && not in_spawn_queue(tile_pos):
		spawn_cell(tile_pos)
		if regen_tiles:
			regen_tile_list[tile_pos] = orig_pos
			
		return true
		
	return false
	
func spawn_cell(tile_pos):
	var e = preload("res://Entities/AppearingBlock.tscn").instance()
	e.set_global_pos(map_to_world(tile_pos) + Vector2(32, 32))
	e.tilemap = self
	
	add_child(e)
	
func clear_cell(tile_pos):
	set_cellv(tile_pos, -1)
	
func tile_on(entity):
	var tile_pos = world_to_map(entity.get_global_pos())
	set_cellv(tile_pos, tile_num)
	
func tile_off(entity):
	pass
	
# used by enemies and player headbutt
func destroy_tile(tile_pos):
	var ret = 0
	
	var cur_tile = get_cellv(tile_pos)
	
	if cur_tile == tile_num || cur_tile == tile_num_crack:
		if regen_tiles && regen_tile_list.has(tile_pos) && regen_tile_list[tile_pos] != null:
			spawn_cell(regen_tile_list[tile_pos])
			regen_tile_list.erase(tile_pos)
			
		clear_cell(tile_pos)
		ret = -1
		
	return ret

func crack_tile(tile_pos):
	if regen_tiles:
		destroy_tile(tile_pos)
		return
	
	var ret = 0
	
	var cur_tile = get_cellv(tile_pos)
	
	if cur_tile == tile_num:
		set_cellv(tile_pos, tile_num_crack)
		ret = 0
	elif cur_tile == tile_num_crack:
		set_cellv(tile_pos, -1)
		ret = -1
		
	return ret