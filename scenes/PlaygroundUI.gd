extends Control

@onready var Playground = $Playground
@onready var BlueTexture = $Center/Center/BlueTexture

var rot = randi_range(0,360-1)

func _ready():
	resize()

func _on_add_pressed():
	Playground.add(self.get_global_position() + self.size / 2 + Vector2(128,0).rotated(rot))
	rot += 4
	if rot >= 360:
		rot -= 360

func _on_close_all_pressed():
	Playground.close_all()

func _on_results_pressed():
	var ifs = Playground.get_ifs(BlueTexture.get_global_position())
	self.get_parent().show_results(ifs)

func resize():
	BlueTexture.custom_minimum_size = Global.LOUPE
