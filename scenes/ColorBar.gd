extends Node2D

signal finished

@onready var ColorBarPicker = $Lines/ColorContainer/ColorPicker
@onready var ColorBarReadyButton = $Lines/ReadyButton
@onready var WaitTimer = $WaitTimer

func _on_ready_button_pressed():
	finished.emit()

func _on_color_picker_color_changed(new_color):
	self.get_owner()._on_color_picker_color_changed(new_color)

func load_color(new_color):
	ColorBarPicker.color = new_color

@onready var load_position = self.get_global_position()

func load_new_position(new_position):
	load_position = new_position
	WaitTimer.start()

func _on_wait_timer_timeout():
	self.set_global_position(
		load_position
	)
