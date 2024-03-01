extends Control

@onready var Content = $Lines/Content
@onready var PlaygroundUI = $Lines/Content/PlaygroundUI
@onready var ResultUI = $Lines/Content/ResultUI
@onready var ResizeTimer = $Lines/Content/ResizeTimer
@onready var Title = $Lines/Title
# share your fractal with the gallery on Global.GALLERY_ADRESS
@onready var ShareDialogue = $ShareDialogue
# for messages
@onready var WarningLabel = $WarningContainer/WarningLabel
@onready var WarningTimer = $WarningContainer/WarningTimer

func _ready():
	# connect signals
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	show_results(IFS.new())
	# set variables
	PlaygroundUI.ResultUI = ResultUI
	ResultUI.ShareDialogue = ShareDialogue
	
	# hide and show
	WarningLabel.text = ""
	ShareDialogue.hide()

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

# "warning" messages

## share-dialogue

func _on_share_dialogue_sent_away():
	WarningLabel.text = "Sending your image to " + Global.GALLERY_ADRESS + "..."
	WarningTimer.start()

func _on_share_dialogue_sent_successfully():
	WarningLabel.text = "Your image has been sent successfully to " + Global.GALLERY_ADRESS + "."
	WarningTimer.start()

func _on_share_dialogue_sent_unsuccessfully(response_code):
	WarningLabel.text = "Failed to send your image to " + Global.GALLERY_ADRESS + ". Error code: " + str(response_code)
	WarningTimer.start()

func _on_share_dialogue_no_connection_to_server(response):
	WarningLabel.text = "Failed to connect to " + Global.GALLERY_ADRESS + ". Response: " + str(response)
	WarningTimer.start()

## close current message

func _on_warning_timer_timeout():
	WarningLabel.text = ""
