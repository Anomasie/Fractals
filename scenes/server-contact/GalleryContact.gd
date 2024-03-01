extends Node

signal sent_successfully
signal sent_unsuccessfully
signal no_connection_to_server

@onready var PolaroidsApi = $PolaroidsApi

func _ready() -> void:
	PolaroidsApi.on_response.connect(_on_response)

func send_image(image = Image.load_from_file("res://assets/icon.png"), description="", nickname="", venue="", meta=""):
	PolaroidsApi.send_image(Global.GALLERY_ADRESS, image, description, nickname, venue, meta)

func _on_response(result: int, response_code: int, response: Dictionary) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 200:
			sent_successfully.emit()
			#print(response)
		else:
			sent_unsuccessfully.emit(response_code)
			# error message returned by server, so contacting the server worked
			push_error("Failed to upload image with error code %d: %s" % [response_code, response["errors"]["detail"]])
	else:
		no_connection_to_server.emit(result)
		# error code returned by HTTPRequest, so communicating with server failed
		push_error("Could not connect to server: HTTPRequest.Result %d" % result)
