extends Node2D

var leveldata = null
var http = HTTPRequest.new()
var loading = false
var button_y_offset = 0
var buttons_on_page = []
var levels_alphabet = []
var pages = 0
var current_page = 0

func dict_sort(diccionario: Dictionary) -> Dictionary:
	var keys = diccionario.keys()
	keys.sort()  # Ordenar las claves alfabéticamente
	
	var diccionario_ordenado = {}
	for key in keys:
		diccionario_ordenado[key] = diccionario[key]
	
	return diccionario_ordenado

func _ready():
	http.connect("request_completed", self, "_http_finished")
	add_child(http)
	reload_levels()

func _on_Search_text_changed(new_text):
	print("XD")

func _process(delta):
	if $ReloadButton.rect_rotation <= -360:
		$ReloadButton.rect_rotation = 0
	if loading:
		$ReloadButton.rect_rotation -= 15
	else:
		if $ReloadButton.rect_rotation != 0:
			$ReloadButton.rect_rotation -= 15

func _on_ReloadButton_button_down():
	if !loading:
		reload_levels()

func list_levels():
	var items = leveldata.size()
	var name_level_alphabet = {}
	for object in leveldata:
		var names = leveldata[object]["name"]
		if names.begins_with("HIDE-"):
			items -= 1
		else:
			name_level_alphabet[object] = names
	name_level_alphabet = dict_sort(name_level_alphabet)
	print(name_level_alphabet)
			

func reload_levels():
	http.request_raw("https://00firebeat99.000webhostapp.com/uploads/levelinfo.json")
	loading = true

func _http_finished(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	if result != OK:
		reload_levels()
		print("Error: ", response_code, " - Trying Again")
	else:
		var data = body.get_string_from_utf8()
		data = parse_json(data)
		print("Data Updated: ", data)
		leveldata = data
		loading = false
		list_levels()
