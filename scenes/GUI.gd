extends Control

@onready var PlaygroundUI = $PlaygroundUI
@onready var ResultUI = $ResultUI
@onready var ResizeTimer = $ResizeTimer

func _ready():
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	show_results(IFS.new())
	
	PlaygroundUI.ResultUI = ResultUI

func _on_viewport_resize():
	var viewport_size = get_viewport().get_size()
	Global.LOUPE = min(viewport_size.x / 2 - 2 * 16 - 2 * 16, viewport_size.y / 2 - 2 * 16) * Vector2i(1,1)
	PlaygroundUI.resize()
	ResultUI.resize()
	ResizeTimer.start()

func show_results(results):
	ResultUI.open(results)

func _on_resize_timer_timeout():
	PlaygroundUI.resize_playground()

func _on_result_ui_color_changed():
	PlaygroundUI._fractal_changed()
