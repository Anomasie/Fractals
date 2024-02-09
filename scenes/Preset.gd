extends MarginContainer

signal pressed

func load_preset(preset):
	$Texture.texture = load(preset["texture"])
	$Button.tooltip_text = self.tooltip_text

func _on_button_pressed():
	pressed.emit()
