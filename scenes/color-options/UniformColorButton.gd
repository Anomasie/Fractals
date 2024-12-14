extends MarginContainer

signal pressed

var uniform = false

@onready var Uniform = $Uniform
@onready var Mix = $Mix

func _ready():
	Uniform.show()
	Mix.hide()
	
	Global.tooltip_nodes.append_array([Uniform, Mix])

func set_uniform_colorong(value):
	uniform = value
	Uniform.visible = not uniform
	Mix.visible = uniform

func _on_center_pressed():
	uniform = true
	pressed.emit()
	Uniform.hide()
	Mix.show()

func _on_mix_pressed():
	uniform = false
	pressed.emit()
	Uniform.show()
	Mix.hide()

func reload_language():
	for node in [Uniform, Mix]:
		match Global.language:
			"GER": node.tooltip_text = "ändere Farbgebung"
			_: node.tooltip_text = "change color algorithm"
