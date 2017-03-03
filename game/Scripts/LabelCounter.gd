extends Label

export var prefix = ""

func _on_count_change(count):
	set_text(prefix + String(count)) 
