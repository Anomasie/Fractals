extends Node

signal open_file

var _js_handle_upload_callback = JavaScriptBridge.create_callback(_handle_upload)
var _js_file_read_callback = JavaScriptBridge.create_callback(_file_read)
var document = JavaScriptBridge.get_interface("document")
var window = JavaScriptBridge.get_interface("window")
var input = document.createElement("input")

func _ready():
	input.setAttribute("id", "fileUpload")
	input.setAttribute("type", "file")
	input.setAttribute("accept", "application/json")
	input.setAttribute("style", "display:none")
	document.body.append(input)
	input.addEventListener("change", _js_handle_upload_callback, false)

func load_file():
	input.click()

func _handle_upload(_args):
	var file = input.files[0]
	var fileReader = JavaScriptBridge.create_object("FileReader")
	fileReader.onload = _js_file_read_callback # onload wird aufgerufen, wenn readAsText fertig
	fileReader.readAsText(file)

func _file_read(args):
	var fileContent = args[0].target.result
	open_file.emit(fileContent)
