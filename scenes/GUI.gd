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
@onready var HelpButton = $UIButtons/HelpButton
@onready var HelpOptions = $HelpOptions
@onready var TxtOptions = $TxtOptions

# for loading urls
@onready var URLTimer = $LoadFromURLTimer
var js_callback_on_url_hash_change = JavaScriptBridge.create_callback(_on_url_hash_change)

var loading_url_disabled = 0
var storing_url_disabled = 0
var fractal_changed_disabled = 0

var load_ui_when_txt_options_open = true

func _ready():
	storing_url_disabled += 1 # wait until URLTimer is ready
	# connect signals
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	show_results()
	# set variables
	PlaygroundUI.ResultUI = ResultUI
	ResultUI.ShareDialogue = ShareDialogue
	PlaygroundUI.Playground.TxTOptions = TxtOptions
	
	# hide and show
	WarningLabel.text = ""
	TxtOptions.hide()
	HelpOptions.hide()
	ShareDialogue.hide()
	
	# language & translation
	_on_language_button_pressed()
	
	# for loading urls
	URLTimer.start()

func load_ifs(ifs):
	fractal_changed_disabled += 1
	PlaygroundUI.set_ifs(ifs)
	ResultUI.load_color(ifs.background_color)
	ResultUI.DelaySlider.value = ifs.delay
	fractal_changed_disabled -= 1

# url stuff

func _on_url_hash_change(_event):
	if loading_url_disabled == 0:
		try_load_from_url()

func store_to_url():
	if storing_url_disabled == 0:
		# get ifs
		var ifs = PlaygroundUI.get_ifs()
		ifs.background_color = ResultUI.ResultBackground.self_modulate
		ifs.delay = ResultUI.current_ifs.delay
		
		loading_url_disabled += 1
		
		var url_hash = ifs.to_meta_data()
		JavaScriptBridge.eval("location.replace(\"#%s\")" % url_hash)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		
		loading_url_disabled -= 1

func try_load_from_url():
	var url_hash = JavaScriptBridge.get_interface("location")
	if url_hash:
		var url_str = url_hash["hash"].get_slice("#", 1)#.percent_decode()
		try_load_from_string(url_str)

func try_load_from_string(meta_data):
	if meta_data:
		# build code
		var meta_ifs = IFS.from_meta_data(meta_data)
		# valid -> build
		if meta_ifs is IFS:
			load_ifs(meta_ifs)

func _on_load_from_url_timer_timeout():
	var js_window = JavaScriptBridge.get_interface("window")
	if js_window:
		js_window.addEventListener("hashchange", js_callback_on_url_hash_change)
	try_load_from_url()
	storing_url_disabled -= 1

func _on_result_ui_store_to_url():
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
	HelpOptions.custom_minimum_size = Vector2i(
		max( viewport_size.x/3*2, ShareDialogue.Margin.size.x),
		max( viewport_size.y/3*2, ShareDialogue.Margin.size.y)
	)
	TxtOptions.custom_minimum_size = Vector2i(
		max( viewport_size.x/4*3, ShareDialogue.Margin.size.x),
		max( viewport_size.y/4*3, ShareDialogue.Margin.size.y)
	)
	# prevent resizing-bugs
	ResizeTimer.start()

func _on_resize_timer_timeout():
	PlaygroundUI.resize_playground()

# result stuff

func show_results():
	var ifs = PlaygroundUI.get_ifs()
	# update ifs background
	ifs.background_color = ResultUI.ResultBackground.self_modulate
	ifs.delay = ResultUI.current_ifs.delay
	# update result-ui and url
	#store_to_url() # that's mostly spam for the browser history
	ResultUI.open(ifs)
	if TxtOptions.visible:
		TxtOptions.load_ui(ifs)
	else:
		load_ui_when_txt_options_open = true

func _on_result_ui_fractal_changed():
	if TxtOptions.visible and fractal_changed_disabled == 0:
		TxtOptions.load_ui(ResultUI.current_ifs)
	else:
		load_ui_when_txt_options_open = true

# "warning" messages

## share-dialogue

func _on_share_dialogue_sent_away():
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

# help

func _on_help_button_pressed():
	HelpOptions.visible = not HelpOptions.visible

# txt options

func _on_playground_ui_open_txt_options():
	var ifs = PlaygroundUI.get_ifs()
	# update ifs background
	ifs.background_color = ResultUI.ResultBackground.self_modulate
	ifs.delay = ResultUI.current_ifs.delay
	
	TxtOptions.open(ifs)
	if load_ui_when_txt_options_open:
		TxtOptions.load_ui(ifs)
		load_ui_when_txt_options_open = false

func _on_txt_options_changed(new_ifs):
	load_ifs(new_ifs)

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
	match Global.language:
		"GER":
			HelpButton.tooltip_text = "Informationen"
		_:
			HelpButton.tooltip_text = "information"
	# pass on signal
	for node in [PlaygroundUI, ResultUI, ShareDialogue, HelpOptions, TxtOptions]:
		node.reload_language()

# debugging

func _on_debug_button_pressed():
	pass

func _on_debug_edit_text_submitted(new_text):
	try_load_from_string(new_text)
