extends MarginContainer

signal pressed

func load_preset(preset):
	$Texture.texture = load(preset["texture"])

func _on_button_pressed():
	pressed.emit()
