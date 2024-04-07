extends MarginContainer

signal changed

@onready var JsonEdit = $Main/Content/Lines/JsonEdit
@onready var AllMatrixOptions = $Main/Content/Lines/Scroller/AllMatrixOptions
@onready var MyFileDialog = $MyFileDialog

@onready var CloseButton = $CloseButton

@onready var UploadButton = $HBoxContainer/UploadButton
@onready var DownloadButton = $HBoxContainer/DownloadButton

@export var WebFileDialogScene : PackedScene
@onready var WebFileDialog : Node

var current_ifs = IFS.new()
var disabled = 0
var saving = false # for save/load-file-dialog

func _ready():
	# hide & show
	MyFileDialog.close()
	if OS.has_feature("web"):
		var new_child = WebFileDialogScene.instantiate()
		new_child.open_file.connect(_on_web_file_dialog_open_file)
		self.add_child(new_child)
		WebFileDialog = new_child
	# connect tooltips
	Global.tooltip_nodes.append_array([CloseButton, DownloadButton, UploadButton])

func load_ui(new_ifs):
	current_ifs = new_ifs
	if not disabled:
		AllMatrixOptions.update_ui(current_ifs)
	if not JsonEdit.do_i_have_focus():
		JsonEdit.load_text(current_ifs)

func read_ui():
	return AllMatrixOptions.read_ui()

func open(_ifs):
	#load_ui(ifs)
	show()

func _on_close_button_pressed():
	hide()

# matrix options stuff

func _on_all_matrix_options_changed(new_ifs):
	changed.emit(new_ifs)

# python/txt stuff

func _on_python_edit_text_changed():
	var ifs = JsonEdit.read_text()
	load_ui(ifs)
	changed.emit(ifs)

func _on_python_edit_please_reload():
	JsonEdit.load_text(current_ifs)

# saving & loading stuff

func load_json_file(path):
	JsonEdit.text = FileAccess.get_file_as_string(path)
	_on_python_edit_text_changed()

func save_json_file(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JsonEdit.text)

func _on_download_button_pressed():
	if OS.has_feature("web"):
		var filename = "fractal.json"
		var buf = JsonEdit.text.to_utf8_buffer()
		JavaScriptBridge.download_buffer(buf, filename)
	else:
		saving = true
		reload_language_file_dialog()
		MyFileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		MyFileDialog.open()

func _on_upload_button_pressed():
	if OS.has_feature("web"):
		WebFileDialog.load_file()
	else:
		saving = false
		reload_language_file_dialog()
		MyFileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		MyFileDialog.open()

func _on_my_file_dialog_path_selected(path):
	if saving:
		save_json_file(path)
	else:
		load_json_file(path)
	MyFileDialog.close()

func _on_web_file_dialog_open_file(content):
	JsonEdit.text = content
	_on_python_edit_text_changed()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseButton.tooltip_text = "Text-Optionen schließen"
			DownloadButton.tooltip_text = "JSON-Datei herunterladen"
			UploadButton.tooltip_text = "JSON-Datei hochladen"
		_:
			CloseButton.tooltip_text = "close text options"
			DownloadButton.tooltip_text = "download JSON-file"
			UploadButton.tooltip_text = "upload JSON-file"
	# pass on signal
	AllMatrixOptions.reload_language()
	JsonEdit.reload_language()
	reload_language_file_dialog()

func reload_language_file_dialog():
	match Global.language:
		"GER":
			if saving:
				MyFileDialog.title = "Daten als JSON speichern"
			else:
				MyFileDialog.title = "JSON-Datei laden"
		_:
			if saving:
				MyFileDialog.title = "save data as JSON"
			else:
				MyFileDialog.title = "load JSON file"
