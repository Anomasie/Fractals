extends MarginContainer

signal pressed

var centered = false

@onready var Center = $Center
@onready var Normal = $Normal

func _ready():
	Center.show()
	Normal.hide()

func _on_center_pressed():
	centered = true
	pressed.emit()
	Center.hide()
	Normal.show()

func _on_normal_pressed():
	centered = false
	pressed.emit()
	Center.show()
	Normal.hide()
