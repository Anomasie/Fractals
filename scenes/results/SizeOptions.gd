extends MarginContainer

signal value_changed

@onready var SizeXEdit = $Container/Content/Main/SizeX/Edit
@onready var SizeYEdit = $Container/Content/Main/SizeY/Edit
@onready var ReloadButton = $ReloadButton
@onready var CloseButton = $CloseButton

var disabled = 0
var custom_value = false

func _ready():
	Global.tooltip_nodes.append_array([SizeXEdit, SizeYEdit, ReloadButton, CloseButton])

func load_ui(new_size):
	disabled += 1
	
	SizeXEdit.placeholder_text = str(new_size.x)
	SizeYEdit.placeholder_text = str(new_size.y)
	
	disabled -= 1

func read_ui():
	var array = []
	for edit in [SizeXEdit, SizeYEdit]:
		if int(edit.text) > 0:
			array.append(int(edit.text))
		else:
			edit.text = ""
			if int(edit.placeholder_text) > 0:
				array.append(int(edit.placeholder_text))
			else:
				edit.placeholder_text = "1"
				array.append(1)
	return Vector2i(array[0], array[1])

func _on_edit_focus_exited():
	_on_edit_text_submitted()

func _on_edit_text_submitted(_some_text = ""):
	# delete text
	for edit in [SizeXEdit, SizeYEdit]:
		var valid_changes = true
		if not edit.text or not int(edit.text) > 0:
			valid_changes = false
		custom_value = custom_value or valid_changes
		disabled += 1
		edit.release_focus()
		disabled -= 1
	# commit text
	if disabled == 0:
		value_changed.emit()

func _on_reload_button_pressed():
	disabled += 1
	
	custom_value = false
	var new_size = get_owner().current_loupe
	# reset edits
	SizeXEdit.placeholder_text = str(new_size.x)
	SizeYEdit.placeholder_text = str(new_size.y)
	SizeXEdit.text = ""
	SizeYEdit.text = ""
	
	disabled -= 1
	
	value_changed.emit()

func _on_close_button_pressed():
	hide()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			SizeXEdit.tooltip_text = "Bildgröße im Export"
			SizeYEdit.tooltip_text = "Bildgröße im Export"
			ReloadButton.tooltip_text = "Bildgröße zurücksetzen"
			CloseButton.tooltip_text = "Größeneinstellungen schließen"
		_:
			SizeXEdit.tooltip_text = "image size for export"
			SizeYEdit.tooltip_text = "image size for export"
			ReloadButton.tooltip_text = "reset to original image size"
			CloseButton.tooltip_text = "close size settings"
