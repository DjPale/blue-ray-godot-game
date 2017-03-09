extends AnimationPlayer

export var anim_name = ""

func _ready():
	play(anim_name)