# Based on https://godotengine.org/qa/438/camera2d-screen-shake-extension

extends Node

var _target = null
var _no_offset = false
var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

func _ready():
	set_process(true)

# Shake with decreasing intensity while there's time remaining.
func _process(delta):
    # Only shake when there's shake time remaining.
	if _target == null or _timer == 0:
	    return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		if _no_offset:
			_target.set_pos(_target.get_pos() - _last_offset + new_offset)
		else:
			_target.set_offset(_target.get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
		# Reset the offset when we're done shaking.
		_timer = _timer - delta * 60.0
	if _timer <= 0:
		_timer = 0
		if _no_offset:
			_target.set_pos(_target.get_pos() - _last_offset)
		else:
			_target.set_offset(_target.get_offset() - _last_offset)
		_target = null
		queue_free()

# Kick off a new screenshake effect.
func shake(target, duration, frequency, amplitude):
	# Initialize variables.
	_target = target
	_no_offset = not _target.has_method("set_offset")
	prints(_target, _no_offset)
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	if _no_offset:
		_target.set_pos(_target.get_pos() - _last_offset)
	else:
		_target.set_offset(_target.get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)