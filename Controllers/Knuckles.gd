extends Node

var timer
var resource_result
var loader
var wait_time = 0.0
var calculating = false
signal finished(error, result)
signal updated(stage, stage_count)

func _process(delta):
	if wait_time < 0.05:
		_timeout()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	timer = Timer.new()
	timer.wait_time = 0
	timer.connect("timeout", self, "_timeout")
	add_child(timer)
	timer.start()

func resource_load(path : String, pause : bool = true, wait_between_poll : float = 0.0):
	if calculating:
		return ERR_BUSY
	if !ResourceLoader.exists(path):
		return ERR_DOES_NOT_EXIST
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		return loader
	calculating = true
	get_tree().paused = pause
	wait_time = wait_between_poll
	return OK
	

#func instant_resource_load(path : String, pause : bool = true, wait_between_poll : float = 0.0):
#	if calculating:
#		return ERR_BUSY
#	if !ResourceLoader.exists(path):
#		return ERR_DOES_NOT_EXIST
#	loader = ResourceLoader.load_interactive(path)
#	if loader == null:
#		return loader
#	calculating = true
#	get_tree().paused = pause
#	wait_time = wait_between_poll
#	var chunks = 0
#	var result
#	var asset
#	var max_steps = loader.get_stage_count()
#	for i in range(0, max_steps + 1):
#		if calculating and loader != null:
#			if !loader == null:
#				result = loader.poll()
#			else:
#				return
#			if result == OK:
#				pass
#			elif result == ERR_FILE_EOF:
#				calculating = false
#				asset = loader.get_resource()
#				loader = null
#				get_tree().paused = false
#				break
#			else:
#				calculating = false
#				loader = null
#				get_tree().paused = false
#				break
#		yield(get_tree().create_timer(wait_between_poll), "timeout")
#	return [result, asset]

func get_last_asset():
	return resource_result

func _restart_redirect(redirect : String):
	Knuckles.resource_load("res://Main.tscn", true, 0.0)
	yield(Knuckles, "finished")
	var scene = Knuckles.get_last_resource()
	if scene is PackedScene:
		var scn = scene.instance()
		scn.redirect = redirect
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(scn)
	else:
		OS.alert("The game is having multiple errors. Please restart manually", "Crash")
		get_tree().quit()
	

func _timeout():
	if calculating and loader != null:
		var result
		if !loader == null:
			result = loader.poll()
		else:
			return
		if result == OK:
			emit_signal("updated", loader.get_stage(), loader.get_stage_count())
		elif result == ERR_FILE_EOF:
			calculating = false
			var asset = loader.get_resource()
			resource_result = asset
			emit_signal("finished", OK, asset)
			emit_signal("updated", loader.get_stage(), loader.get_stage_count())
			loader = null
			get_tree().paused = false
		else:
			emit_signal("finished", result, null)
			calculating = false
			loader = null
			get_tree().paused = false
			
	
