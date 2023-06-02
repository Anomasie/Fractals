extends Control

@onready var Playground = $Playground
@onready var BlueTexture = $Center/Center/BlueTexture

var rot = 0

func _on_add_pressed():
	Playground.add(self.position + self.size / 2 + Vector2(32,0).rotated(rot))
	rot += 10

func _on_close_all_pressed():
	Playground.close_all()

func _on_screenshot_pressed():
	Playground.screenshot(BlueTexture.get_global_position(), BlueTexture.size)
