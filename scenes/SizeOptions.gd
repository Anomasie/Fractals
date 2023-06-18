extends HBoxContainer

signal value_changed
signal close_me

@onready var SizeX = $Columns/SizeX
@onready var SizeY = $Columns/SizeY

func _on_size_x_value_changed(_value):
	value_changed.emit()

func _on_size_y_value_changed(_value):
	value_changed.emit()

func read_ui():
	return Vector2i(SizeX.value, SizeY.value)

func load_ui(new_size):
	SizeX.max_value = max(Global.LOUPE.x, new_size.x+1)
	SizeY.max_value = max(Global.LOUPE.y, new_size.y+1)
	SizeX.value = new_size.x
	SizeY.value = new_size.y

func _on_reset_button_pressed():
	SizeX.max_value = Global.LOUPE.x
	SizeY.max_value = Global.LOUPE.y
	SizeX.value = Global.LOUPE.x
	SizeY.value = Global.LOUPE.y

func _on_close_button_pressed():
	close_me.emit()
