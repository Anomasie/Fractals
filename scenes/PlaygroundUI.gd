extends Control

@onready var Playground = $Playground
@onready var BlueTexture = $Center/Center/BlueTexture

var rot = 0

func _ready():
	BlueTexture.custom_minimum_size = Global.LOUPE

func _on_add_pressed():
	Playground.add(self.position + self.size / 2 + Vector2(32,0).rotated(rot))
	rot += 10

func _on_close_all_pressed():
	Playground.close_all()

func _on_results_pressed():
	var ifs = Playground.get_ifs(BlueTexture.get_global_position())
	var results = ifs.calculate_fractal()
	self.get_parent().show_results(results)
