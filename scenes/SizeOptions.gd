extends MarginContainer

signal value_changed

@onready var SizeX = $Main/SizeX
@onready var SizeY = $Main/SizeY

var disabled = false

func load_ui(new_size):
	disabled = true
	SizeX.value = new_size.x
	SizeY.value = new_size.y
	disabled = false

func read_ui():
	return Vector2i(SizeX.value, SizeY.value)

func _on_size_x_value_changed(_value):
	if not disabled:
		value_changed.emit()

func _on_size_y_value_changed(_value):
	if not disabled:
		value_changed.emit()

func _on_reload_button_pressed():
	load_ui( get_owner().current_loupe )
	value_changed.emit()
