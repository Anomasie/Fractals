extends MarginContainer

signal changed

@onready var JsonEdit = $Main/Content/Lines/JsonEdit
@onready var AllMatrixOptions = $Main/Content/Lines/Scroller/AllMatrixOptions
@onready var MyFileDialog = $MyFileDialog

@onready var CloseButton = $CloseButton

var current_ifs = IFS.new()
var disabled = 0
var saving = false # for save/load-file-dialog

func _ready():
	# hide & show
	MyFileDialog.close()

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
	saving = true
	reload_language_file_dialog()
	MyFileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	MyFileDialog.open()

func _on_upload_button_pressed():
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

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseButton.tooltip_text = "Text-Optionen schließen"
		_:
			CloseButton.tooltip_text = "close text options"
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
