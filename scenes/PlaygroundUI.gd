extends Control

@onready var Playground = $Playground
@onready var BlueTexture = $Center/Center/BlueTexture
@onready var ColorBar = $Left/Lines/ColorBar
@onready var ColorBarReadyButton = $Left/Lines/ColorBar/ReadyButton

var rot = randi_range(0,360-1)

func _ready():
	resize()
	ColorBar.hide()

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

# colors

var editing_color = false
var rect_editing_color = null

func color(MyRect):
	editing_color = true
	rect_editing_color = MyRect
	ColorBar.show()
	await ColorBarReadyButton.pressed
	editing_color = false
	ColorBar.hide()

func _on_color_picker_color_changed(color):
	if editing_color and rect_editing_color:
		rect_editing_color.color_rect(color)
