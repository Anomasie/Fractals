extends Node

signal on_response(result, response_code, response)

var http: HTTPRequest

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._http_request_completed)

func _add_field(body: PackedByteArray, key: String, value: String) -> void:
	var content = \
	"\r\n--boundary\r\n" + \
	"Content-Disposition: form-data; name=\"%s\"\r\n" % key + \
	"Content-Type: text/plain; charset=UTF-8\r\n\r\n" + \
	value
	body.append_array(content.to_utf8_buffer())
  
func _add_file(body: PackedByteArray, key: String, file: PackedByteArray, filename: String, content_type: String) -> void:
	var content = \
	"\r\n--boundary\r\n" + \
	"Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\n" % [key, filename] + \
	"Content-Type: %s\r\n\r\n" % content_type
	body.append_array(content.to_utf8_buffer())
	body.append_array(file)
  
func _end_body(body: PackedByteArray):
	body.append_array("\r\n--boundary--\r\n".to_utf8_buffer())
  
func send_image(url: String, image: Image, description: String = "", nickname: String = "", venue: String = "", meta: String = "") -> Error:
	var headers = [
		"Content-Type: multipart/form-data; boundary=\"boundary\""
	]
	var body = PackedByteArray()
	_add_file(body, "file", image.save_webp_to_buffer(), "upload.webp", "image/webp")
	if description != "":
		_add_field(body, "description", description)
	if nickname != "":
		_add_field(body, "nickname", nickname)
	if venue != "":
		_add_field(body, "venue", venue)
	if meta != "":
		_add_field(body, "meta", meta)
	_end_body(body)
	
	return http.request_raw(url, headers, HTTPClient.METHOD_POST, body)
  
func _http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		on_response.emit(result, 0, {})
	else:
		on_response.emit(result, response_code, JSON.parse_string(body.get_string_from_utf8()))
