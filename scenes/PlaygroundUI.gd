extends Control

@onready var Playground = $Playground

var rot = 0

func _on_add_pressed():
	Playground.add(self.position + self.size / 2 + Vector2(32,0).rotated(rot))
	rot += 10

func _on_close_all_pressed():
	Playground.close_all()
