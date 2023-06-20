extends Node2D

signal finished

@onready var ColorBarPicker = $Lines/ColorContainer/ColorPicker
@onready var ColorBarReadyButton = $Lines/ReadyButton

func _on_ready_button_pressed():
	finished.emit()

func _on_color_picker_color_changed(new_color):
	self.get_owner()._on_color_picker_color_changed(new_color)

func load_color(new_color):
	ColorBarPicker.color = new_color
