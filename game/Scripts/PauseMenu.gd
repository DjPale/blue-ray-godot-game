extends PanelContainer

var paused = false
var pause_pressed = false

onready var popup_menu = find_node("Popup")

signal menu_restart
signal menu_quit

func _ready():
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed("ui_pause"):
		if not pause_pressed:
			_toggle_pause()

		pause_pressed = true
	else:
		pause_pressed = false
		
func _grab_focus():
	find_node("Resume").grab_focus()
	
func _toggle_pause():
	paused = not paused
	get_tree().set_pause(paused)
	set_hidden(not paused)
		
	if paused: 
		_grab_focus()
	else:
		popup_menu.set_hidden(true)

func _toggle_popup():
	if not paused: return
	popup_menu.popup_centered()

func _on_Credits_pressed():
	_toggle_popup()

func _on_Resume_pressed():
	_toggle_pause()

func _on_Restart_pressed():
	_toggle_pause()
	emit_signal("menu_restart")

func _on_Quit_pressed():
	_toggle_pause()
	emit_signal("menu_quit")
