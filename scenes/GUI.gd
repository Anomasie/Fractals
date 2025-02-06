extends Control

@onready var Content = $Lines/Content
@onready var PlaygroundUI = $Lines/Content/Editor/PlaygroundUI
@onready var ResultUI = $Lines/Content/ResultUI
@onready var ResizeTimer = $Lines/Content/ResizeTimer
@onready var Title = $Lines/Title
# share your fractal with the gallery on Global.GALLERY_ADRESS
@onready var ShareDialogue = $ShareDialogue
# for messages
@onready var WarningLabel = $WarningContainer/WarningLabel
@onready var WarningTimer = $WarningContainer/WarningTimer

@onready var LanguageButton = $UIButtons/LanguageButton
@onready var HelpButton = $UIButtons/CornerButtons/HelpButton
@onready var HelpOptions = $HelpOptions
@onready var TxtOptions = $Lines/Content/Editor/TxtOptions

@onready var UndoButton = $UIButtons/CornerButtons/UndoButton
@onready var RedoButton = $UIButtons/CornerButtons/RedoButton

# for loading urls
@onready var URLTimer = $LoadFromURLTimer
var js_callback_on_url_hash_change = JavaScriptBridge.create_callback(_on_url_hash_change)

var loading_url_disabled = 0
var storing_url_disabled = 0

var load_ui_when_txt_options_open = true

var current_ifs_idx = 0
const MAX_LEN_LAST_IFS = 100
var last_ifs = []

func _ready():
	storing_url_disabled += 1 # wait until URLTimer is ready
	# connect signals
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	_on_playground_ui_fractal_changed()
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
	
	# tooltip_text
	Global.tooltip_nodes.append_array([HelpButton, LanguageButton, UndoButton, RedoButton])
	
	UndoButton.disabled = true
	RedoButton.disabled = true
	save_as_last_ifs(IFS.new())

func load_ifs(ifs, overwriting_result_ui=true, overwrite_centered=false):
	PlaygroundUI.set_ifs(ifs)
	ResultUI.open(ifs, overwriting_result_ui, overwrite_centered)

# url stuff

func _on_url_hash_change(_event):
	if loading_url_disabled == 0:
		try_load_from_url()

func store_to_url():
	if storing_url_disabled == 0:
		# get ifs
		var ifs = get_ifs()
		
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

func try_load_from_link(url_link="#"):
	if url_link.find("#") >= 0:
		try_load_from_string(url_link.get_slice("#", 1))

func try_load_from_string(meta_data):
	if meta_data:
		# build code
		var meta_ifs = IFS.from_meta_data(meta_data)
		# valid -> build
		if meta_ifs is IFS:
			load_ifs(meta_ifs, true)

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
	# prevent resizing-bugs
	ResizeTimer.start()

func _on_resize_timer_timeout():
	PlaygroundUI.resize_playground(ResultUI.current_ifs)

# result stuff

func get_ifs():
	return ResultUI.get_ifs(PlaygroundUI.get_ifs())

# playground UI

func _on_playground_ui_break_contraction(index=-1) -> void:
	var current_ifs = get_ifs()
	self.load_ifs(current_ifs.break_contraction(index))

func _on_playground_ui_break_all() -> void:
	var current_ifs = get_ifs()
	self.load_ifs(current_ifs.break_ifs())

func _on_playground_ui_center_all() -> void:
	self.load_ifs(ResultUI.get_center_contraction().apply_on_translations(get_ifs()) )

## ifs loading

func _on_playground_ui_load_ifs(ifs, overwrite_result_ui=false, overwrite_centered=false) -> void:
	self.load_ifs(ifs, overwrite_result_ui, overwrite_centered)

## ifs changing

func _on_playground_ui_fractal_changed() -> void:
	# update result-ui and url
	#store_to_url() # that's mostly spam for the browser history
	var ifs = get_ifs()
	ResultUI.open(ifs)
	if TxtOptions.visible:
		TxtOptions.load_ui(ifs)
	else:
		load_ui_when_txt_options_open = true

func _on_playground_ui_fractal_changed_vastly() -> void:
	save_as_last_ifs(get_ifs())

func _on_result_ui_fractal_changed():
	if TxtOptions.visible:
		TxtOptions.load_ui(ResultUI.get_ifs())
	else:
		load_ui_when_txt_options_open = true

func _on_result_ui_fractal_changed_vastly() -> void:
	save_as_last_ifs(get_ifs())
	store_to_url()

func _on_txt_options_changed(new_ifs):
	load_ifs(new_ifs, true)
	swap_debug_texture()

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

func _on_result_ui_dont_upload_already_uploaded_fractal() -> void:
	match Global.language:
		"GER": WarningLabel.text = "Bitte lade kein Fraktal zweimal hoch."
		_: WarningLabel.text = "Please don't upload the same fractal twice."
	WarningTimer.start()

func _on_result_ui_dont_upload_empty_fractal() -> void:
	match Global.language:
		"GER": WarningLabel.text = "Bitte lade kein leeres Bild hoch."
		_: WarningLabel.text = "Please don't upload empty images."
	WarningTimer.start()

## result ui suggestions

func _on_result_ui_suggest_changing_background_color() -> void:
	match Global.language:
		"GER": WarningLabel.text = "Wusstest du, dass du auch die Hintergrundfarbe\nändern kannst? (farbiger Knopf rechts)"
		_: WarningLabel.text = "Did you know that you can change the background color?\n(colored button on the right)"
	WarningTimer.start()

func _on_result_ui_suggest_centered_view() -> void:
	match Global.language:
		"GER": WarningLabel.text = "Wusstest du, dass du das Bild auch zentrieren kannst?\nSo sind mehr Punkte zu sehen.\n(vorletzter Knopf rechts)"
		_: WarningLabel.text = "Did you know that you can center the image?\nSometimes, more can be seen this way.\n(second last button on the right)"
	WarningTimer.start()

## close current message

func _on_warning_timer_timeout():
	WarningLabel.text = ""

# help

func _on_help_button_pressed():
	HelpOptions.visible = not HelpOptions.visible

# txt options

func _on_playground_ui_open_txt_options():
	var ifs = get_ifs()
	
	TxtOptions.open(ifs)
	if load_ui_when_txt_options_open:
		TxtOptions.load_ui(ifs)
		load_ui_when_txt_options_open = false

# undo and redo buttons

func save_as_last_ifs(ifs):
	if current_ifs_idx != 0:
		reset_last_ifs_to(current_ifs_idx)
		current_ifs_idx = 0
	
	last_ifs.append(ifs)
	if len(last_ifs) > MAX_LEN_LAST_IFS:
		last_ifs = last_ifs.slice(len(last_ifs)-MAX_LEN_LAST_IFS, len(last_ifs))
	UndoButton.disabled = len(last_ifs) <= 1
	RedoButton.disabled = true

func reset_last_ifs_to(index):
	if len(last_ifs) >= index:
		last_ifs = last_ifs.slice(0, len(last_ifs)-index)
	else:
		print("ERROR in GUI.reset_last_ifs_to: trying to reset to ifs number ", index, ", but there are only ", len(last_ifs), " ifs saved yet.")

func _on_undo_button_pressed() -> void:
	if len(last_ifs) > current_ifs_idx+1:
		current_ifs_idx += 1
		load_ifs(last_ifs[len(last_ifs)-current_ifs_idx-1])
		UndoButton.disabled = (len(last_ifs) <= current_ifs_idx+1)
		RedoButton.disabled = false
	else:
		print("ERROR in GUI._on_undo_button_pressed: Trying to load ifs number ", current_ifs_idx+1, ", but there are ", len(last_ifs), " ifs saved.")

func _on_redo_button_pressed() -> void:
	if 1 <= current_ifs_idx and current_ifs_idx < len(last_ifs):
		current_ifs_idx -= 1
		load_ifs(last_ifs[len(last_ifs)-current_ifs_idx-1])
		
		UndoButton.disabled = (len(last_ifs) <= current_ifs_idx+1)
		RedoButton.disabled = (current_ifs_idx == 0)
	elif len(last_ifs) == 0:
		print("ERROR in GUI._on_redo_button_pressed: No ifs saved yet.")
	else:
		print("ERROR in GUI._on_redo_button_pressed: There is nothing to redo.")

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
			Title.text = "Erstelle dein eigenes Fraktal!"
			HelpButton.tooltip_text = "Informationen"
			UndoButton.tooltip_text = "Rückgängig machen"
			RedoButton.tooltip_text = "Zurück zu Stand vor Rückgängigkeit"
		_:
			Title.text = "Make your own fractal!"
			HelpButton.tooltip_text = "information"
			UndoButton.tooltip_text = "undo"
			RedoButton.tooltip_text = "redo"
	# pass on signal
	for node in [PlaygroundUI, ResultUI, ShareDialogue, HelpOptions, TxtOptions]:
		node.reload_language()

# debugging

@onready var DebugLine = $DebugLineEdit

func _on_debug_button_pressed():
	print("on debug button pressed!")
	var random_point = point.new()
	print("point: ", random_point.position)
	print(
		"-> ",
		ResultUI.current_center_mapping.apply(ResultUI.current_center_inverse.apply(random_point.position))
	)

func _on_debug_edit_text_submitted(new_text):
	print("text on debug edit submitted!")
	try_load_from_link(new_text)
	print("text on debug edit submission process ended!")

@onready var DebugTexture = $DebugTexture

func swap_debug_texture():
	match DebugTexture.modulate:
		Color.WHITE: DebugTexture.modulate = Color.RED
		Color.RED: DebugTexture.modulate = Color.BLUE
		Color.BLUE: DebugTexture.modulate = Color.BLACK
		_: DebugTexture.modulate = Color.WHITE

func debug():
	print("debug!")

func _on_result_ui_debug() -> void:
	debug()
