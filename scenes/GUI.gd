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

@onready var LanguageButton = $UIButtons/LanguageButton

# for loading urls
@onready var URLTimer = $LoadFromURLTimer
var js_callback_on_url_hash_change = JavaScriptBridge.create_callback(_on_url_hash_change)

var loading_url_disabled = 0
var storing_url_disabled = 0

func _ready():
	storing_url_disabled += 1 # wait until URLTimer is ready
	# connect signals
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	show_results()
	# set variables
	PlaygroundUI.ResultUI = ResultUI
	ResultUI.ShareDialogue = ShareDialogue
	
	# hide and show
	WarningLabel.text = ""
	ShareDialogue.hide()
	
	# language & translation
	_on_language_button_pressed()
	
	# for loading urls
	URLTimer.start()

# url stuff

func _on_url_hash_change(_event):
	if loading_url_disabled == 0:
		try_load_from_url()

func store_to_url():
	if storing_url_disabled == 0:
		# get ifs
		var ifs = PlaygroundUI.get_ifs()
		ifs.background_color = ResultUI.ResultBackground.self_modulate
		
		loading_url_disabled += 1
		
		var url_hash = ShareDialogue.get_meta_data(ifs)
		JavaScriptBridge.eval("location.replace(\"#%s\")" % url_hash)
		
		loading_url_disabled -= 1

## is the url-code valid?
func try_load_from_url():
	var url_hash = JavaScriptBridge.get_interface("location")
	if url_hash:
		if url_hash:
			var url_str = url_hash["hash"].get_slice("#", 1)#.percent_decode()
			# build code
			var url_ifs = ShareDialogue.get_ifs(url_str)
			# valid -> build
			if url_ifs is IFS:
				PlaygroundUI._on_presets_load_preset(url_ifs.systems)
				ResultUI.load_color(url_ifs.background_color)

func _on_load_from_url_timer_timeout():
	var js_window = JavaScriptBridge.get_interface("window")
	if js_window:
		js_window.addEventListener("hashchange", js_callback_on_url_hash_change)
	try_load_from_url()
	storing_url_disabled -= 1

func _on_result_ui_saved_image():
	store_to_url()

# resizing stuff

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

func _on_resize_timer_timeout():
	PlaygroundUI.resize_playground()

# result stuff

func show_results():
	var ifs = PlaygroundUI.get_ifs()
	# update ifs background
	ifs.background_color = ResultUI.ResultBackground.self_modulate
	# update result-ui and url
	#store_to_url() # that's mostly spam for the browser history
	ResultUI.open(ifs)

func _on_result_ui_color_changed():
	# update result-ui and url
	store_to_url()

# "warning" messages

## share-dialogue

func _on_share_dialogue_sent_away():
	store_to_url()
	match Global.language:
		"GER": WarningLabel.text = "Dein Bild wird an " + Global.GALLERY_ADRESS + " gesendet ..."
		_: WarningLabel.text = "Sending your image to " + Global.GALLERY_ADRESS + "..."
	WarningTimer.start()

func _on_share_dialogue_sent_successfully():
	match Global.language:
		"GER": WarningLabel.text = "Dein Bild wurde erfolgreich an " + Global.GALLERY_ADRESS + " gesendet."
		_: WarningLabel.text = "Your image has been sent successfully to " + Global.GALLERY_ADRESS + "."
	WarningTimer.start()

func _on_share_dialogue_sent_unsuccessfully(response_code):
	match Global.language:
		"GER": WarningLabel.text = "Beim Senden an " + Global.GALLERY_ADRESS + " trat ein Fehler auf. Fehlercode: " + str(response_code)
		_: WarningLabel.text = "Failed to send your image to " + Global.GALLERY_ADRESS + ". Error code: " + str(response_code)
	WarningTimer.start()

func _on_share_dialogue_no_connection_to_server(response):
	match Global.language:
		"GER": WarningLabel.text = "Verbindung zu " + Global.GALLERY_ADRESS + " fehlgeschlagen. Antwort des Servers: " + str(response)
		_: WarningLabel.text = "Failed to connect to " + Global.GALLERY_ADRESS + ". Response: " + str(response)
	WarningTimer.start()

## close current message

func _on_warning_timer_timeout():
	WarningLabel.text = ""

# language & translation

func _on_language_button_pressed():
	match LanguageButton.text:
		"GER":
			Global.language = "GER"
			LanguageButton.text = "EN"
			LanguageButton.tooltip_text = "switch to English"
		_:
			Global.language = "EN"
			LanguageButton.text = "GER"
			LanguageButton.tooltip_text = "switch to German"
	reload_language()

func reload_language():
	for node in [PlaygroundUI, ResultUI, ShareDialogue]:
		node.reload_language()
