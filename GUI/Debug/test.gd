extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Knuckles.connect("finished", self, "finished")
	Knuckles.connect("updated", self, "polled")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_down():
	var a  = Knuckles.resource_load($TextEdit.text, true, 0)
	print(a)


func _on_Button2_button_down():
	$FileDialog.show()



func _on_FileDialog_file_selected(path):
	$TextEdit.text = path

func polled(stage, stage_count):
	print("polled ", stage, " / ", stage_count)
	$ProgressBar.max_value = stage_count
	$ProgressBar.value = stage
	
func finished(error, result):
	print("finished")
	if result is Texture:
		$Sprite.texture = result
	if result is PackedScene:
		add_child(result.instance())




func _on_Button3_button_down():
	Networking.send_level($TextEdit.text, "HIDE-Test", "Devmenu")
