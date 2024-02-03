extends Control

@onready var Content = $Lines/Content
@onready var PlaygroundUI = $Lines/Content/PlaygroundUI
@onready var ResultUI = $Lines/Content/ResultUI
@onready var ResizeTimer = $Lines/Content/ResizeTimer
@onready var Title = $Lines/Title

func _ready():
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	show_results(IFS.new())
	
	PlaygroundUI.ResultUI = ResultUI

func _on_viewport_resize():
	# get new size of viewport
	var viewport_size = get_viewport().get_size()
	# landscape format or portrait format?
	## landscape format
	if viewport_size.x >= viewport_size.y:
		Content.columns = 2
		# set minimal window size
		DisplayServer.window_set_min_size(Vector2i(900, 420))
		# get maximal size of unitary sqare
		## -2*16: for seperation
		## in x-axis: -2*32 because of ui elements
		Global.LOUPE = min(viewport_size.x / 2 - 2 * 16 - 2 * 64, viewport_size.y - 4 * 16 - 160) * Vector2i(1,1)
	## portrait format
	else:
		Content.columns = 1
		# set minimal window size
		DisplayServer.window_set_min_size(Vector2i(400, 800))
		# get maximal size of unitary sqare
		## -2*16: for seperation
		## in x-axis: -2*64 because of buttons
		## in y-axis: -2*64 because of sliders
		Global.LOUPE = min(viewport_size.x - 4 * 16 - 2 * 64, viewport_size.y / 2 - 4 * 16 - 80 - Title.size.y) * Vector2i(1,1)
	if Global.LOUPE.x < 1:
		Global.LOUPE.x = 1
	if Global.LOUPE.y < 1:
		Global.LOUPE.y = 1
	# resize everything
	PlaygroundUI.resize()
	ResultUI.resize()
	# prevent resizing-bugs
	ResizeTimer.start()

func show_results(results):
	ResultUI.open(results)

func _on_resize_timer_timeout():
	PlaygroundUI.resize_playground()

func _on_result_ui_color_changed():
	PlaygroundUI._fractal_changed()
