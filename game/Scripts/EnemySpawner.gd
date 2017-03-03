extends Node2D

export(int) var max_spawns = 2
export(float) var spawn_interval = 0.0
export(float) var spawn_counter = 3.0
export(float) var lifetime = 6.0
export var group_name = "Spawned"

var spawn_entities = 0

var prefab

func _ready():
	prefab = preload("res://Entities/EnemyWalking.tscn")

	spawn_counter = spawn_interval
			
	set_process(true)
	
func _process(delta):
	if spawn_counter >= 0:
		spawn_counter -= delta
		if spawn_counter <= 0:
			do_spawn()
			spawn_counter = spawn_interval
			
func do_spawn():
	if max_spawns > 0 && spawn_entities >= max_spawns: return
	
	var enemy = prefab.instance()
	enemy.set_pos(get_pos())
	enemy.add_to_group(group_name)
	
	spawn_entities += 1
	
	var spawn_node = Node.new()
	spawn_node.set_script(preload("SpawnedEnemy.gd"))
	spawn_node.spawner = self
	spawn_node.lifetime = lifetime
	enemy.add_child(spawn_node)
	
	get_parent().add_child(enemy)

	
func free_pool():
	spawn_entities -= 1
	
