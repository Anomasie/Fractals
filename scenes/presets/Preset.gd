@tool
extends MarginContainer

signal pressed

func _ready():
	if not Engine.is_editor_hint():
		Global.add_to_tooltip_nodes([$Button])

func load_preset(preset):
	$Texture.texture = load(preset["texture"])
	$Button.tooltip_text = self.tooltip_text

func _on_button_pressed():
	pressed.emit()
