static func timer(obj, seconds):
	var t = Timer.new()
	t.set_wait_time(seconds)
	t.set_one_shot(true)
	
	obj.add_child(t)

	t.start()
	
	return t