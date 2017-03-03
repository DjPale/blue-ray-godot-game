extends Node

var lifetime = 0
var spawner = null

var life_counter

func _ready():
	if lifetime > 0: 
		life_counter = lifetime
		set_process(true)

func _process(delta):
	if life_counter > 0:
		life_counter -= delta
		if life_counter <= 0:
			deallocate()
			get_parent().queue_free()

func deallocate():
	if spawner != null: 
		spawner.free_pool()
		spawner = null

func _exit_tree():
	deallocate()