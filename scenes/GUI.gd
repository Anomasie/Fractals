extends Control

@onready var PlaygroundUI = $PlaygroundUI
@onready var ResultUI = $ResultUI

func _ready():
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize():
	var viewport_size = get_viewport().get_size()
	Global.LOUPE = min(viewport_size.x / 2 - 2 * 16 - 2 * 16, viewport_size.y / 2 - 2 * 16) * Vector2i(1,1)
	PlaygroundUI.resize()

func show_results(results):
	ResultUI.open(results, true)
