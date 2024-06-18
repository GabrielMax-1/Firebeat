extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Dev_button_down():
	var tween = Tween.new()
	tween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(0, 0), 1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	Knuckles.resource_load("res://GUI/Debug/test.tscn", false, 0.0)
	yield(Knuckles, "finished")
	var scene = Knuckles.get_last_asset()
	if scene is PackedScene:
		var scn = scene.instance()
		scn.z_index = -1
		get_parent().add_child(scn)
		add_child(tween)
		tween.start()
		yield(get_tree().create_timer(10.0), "timeout")
		queue_free()
	else:
		Knuckles._restart_redirect("res://GUI/Debug/test.tscn")
	
