extends Node2D

var step = 0
var loader
var loaded = false
var error_confirm = false
var scene
export var redirect = "res://GUI/Main/Menu.tscn"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$LoadMain/Icon.modulate.a = 0

func _process(delta):
	if step == 3:
		scene = scene.instance()
		scene.z_index = -1
		add_child(scene)
		$AnimationPlayer.play("Animation")
		step = 4
	
	if loader == null and step == 0:
		if !ResourceLoader.exists(redirect):
			get_tree().paused = true
			$LoadMain/Loaderror.dialog_text = "ERROR:\nCant load the following resources:\n- " + str(redirect) + "\n\nReason: " + str("ERROR REDIRECT PATH: DONT EXIST OR DONT RECOGNIZED")
			$LoadMain/Loaderror.show()
		loader = ResourceLoader.load_interactive(redirect)
		step = 1
	elif loader == null and !step == 0 and !loaded:
		get_tree().paused = true
		$LoadMain/Loaderror.dialog_text = "ERROR:\nCant load the following resources:\n- " + str(redirect) + "\n\nReason: " + str("RESOURCELOADER NULL STEP NOT ZERO AND NOT LOADED")
		$LoadMain/Loaderror.show()
	
	if !loader == null:
		var err = loader.poll()
		match err:
			ERR_FILE_EOF:
				loaded = true
				scene = loader.get_resource()
				loader = null
				step = 3
				return
			OK:
				step = 2
				return
			_:
				get_tree().paused = true
				$LoadMain/Loaderror.dialog_text = "ERROR:\nCant load the following resources:\n- " + str(redirect) + "\n\nReason: " + str(err)
				$LoadMain/Loaderror.show()
				
			
				

func _on_Loaderror_custom_action(action):
	print(action)


func _on_Loaderror_confirmed():
	get_tree().reload_current_scene()


func _on_AnimationPlayer_animation_finished(anim_name):
	$LoadMain.queue_free()
