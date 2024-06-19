extends Node

var nm
var ct

func send_level(file_path: String, name: String, creator: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	nm = name
	ct = creator

	var url = "https://00firebeat99.000webhostapp.com/upload.php"  # Reemplaza con la URL correcta de tu servidor

	# Configurar la solicitud POST
	var headers = ["Content-Type: multipart/form-data; boundary=boundary"]  # Tipo de contenido para subir archivos

	# Crear el cuerpo de la solicitud para subir el archivo
	var form_data = create_multipart_form_data("file", file_path)

	# Conectar la señal de solicitud completada
	http_request.connect("request_completed", self, "_on_request_completed")

	# Enviar la solicitud
	http_request.request_raw(url, headers, true, HTTPClient.METHOD_POST, form_data)

func create_multipart_form_data(field_name, file_path):
	var boundary = "boundary"
	var form_data = PoolByteArray()

	# Abrir el archivo
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		print("Error al abrir el archivo:", file_path)
		return form_data  # Devolver un bytearray vacío si hay un error

	# Leer el contenido del archivo
	var file_content = file.get_buffer(file.get_len())
	file.close()

	# Crear la parte inicial del cuerpo del formulario multipart
	var form_start = "--" + boundary + "\r\n"
	form_start += "Content-Disposition: form-data; name=\"" + field_name + "\"; filename=\"" + file_path.get_file() + "\"\r\n"
	form_start += "Content-Type: application/octet-stream\r\n\r\n"

	# Crear la parte final del cuerpo del formulario multipart
	var form_end = "\r\n--" + boundary + "--\r\n"

	# Convertir las partes a PoolByteArray y agregarlas al form_data
	var form_start_bytearray = form_start.to_utf8()
	var form_end_bytearray = form_end.to_utf8()

	form_data.append_array(form_start_bytearray)
	form_data.append_array(file_content)
	form_data.append_array(form_end_bytearray)

	return form_data

func _on_request_completed(result, response_code, headers, body):
	if result == OK:
		var response_body = body.get_string_from_utf8()
		print("Respuesta del servidor:", response_body)
		var regex = RegEx.new()
		regex.compile("El archivo ha sido subido como: (\\d+\\.\\w+)")
		var matchs = regex.search(response_body)
		send_level_data(matchs.get_string(1), nm, ct)
		# Aquí puedes manejar la respuesta del servidor según tus necesidades
	else:
		print("Error en la solicitud:")
		print("Código de respuesta:", response_code)
		print("Cuerpo de respuesta:", body.get_string_from_utf8())

func send_level_data(lid: String, name: String, creator: String):
	var http_request2 = HTTPRequest.new()
	add_child(http_request2)
	
	var url = "https://00firebeat99.000webhostapp.com/levelset.php"
	
	# Crear un diccionario con los datos a enviar
	var request_data = {
		"lid": lid,
		"name": name,
		"creator": creator,
		"time": str(OS.get_unix_time()),
		"version": 1
	}
	
	# Convertir el diccionario a una cadena JSON
	var json_request_data = JSON.print(request_data)
	
	# Conectar la señal de solicitud completada
	http_request2.connect("request_completed", self, "_on_request2_completed")
	
	# Enviar la solicitud con el método POST y los datos JSON
	var custom_headers = ["Content-Type: application/json"]
	http_request2.request(url, custom_headers, true, HTTPClient.METHOD_POST, json_request_data)
	
	print(request_data)
func _on_request2_completed(result, response_code, headers, body):
	if result == OK:
		var response_body = body.get_string_from_utf8()
		print("Respuesta del servidor:", response_body)
		# Aquí puedes manejar la respuesta del servidor según tus necesidades
	else:
		print("Error en la solicitud:")
		print("Código de respuesta:", response_code)
		print("Cuerpo de respuesta:", body.get_string_from_utf8())
