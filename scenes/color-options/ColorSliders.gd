extends MarginContainer

signal color_changed
signal finished

@export var BACKGROUND_COLOR_SLIDER = false

@onready var Preview = $Dialogue/Content/Columns/Preview

@onready var HueTexture = $Dialogue/Content/Columns/Sliders/Hue/Texture
@onready var HueSlider = $Dialogue/Content/Columns/Sliders/Hue/Slider
@onready var SatTexture = $Dialogue/Content/Columns/Sliders/Saturation/Texture
@onready var SatSlider = $Dialogue/Content/Columns/Sliders/Saturation/Slider
@onready var ValueTexture = $Dialogue/Content/Columns/Sliders/Value/Texture
@onready var ValueSlider = $Dialogue/Content/Columns/Sliders/Value/Slider

@onready var Presets = $Dialogue/Content/Columns/Sliders/Presets.get_children()
@onready var UserPresetNode = $Dialogue/Content/Columns/Sliders/UserPresets
@onready var UserPresetsLabel = $Dialogue/Content/Columns/Sliders/UserPresets/UserPresetsLabel
@onready var UserPresets = $Dialogue/Content/Columns/Sliders/UserPresets.get_children()

@onready var Hash = $Dialogue/Content/Columns/Sliders/Presets/Hash

@onready var AddButton = $Dialogue/Content/Columns/Buttons/AddButton
@onready var UniformColorButton = $Dialogue/Content/Columns/Buttons/UniformButton
@onready var CloseButton = $CloseButton

var saved_colors = [
	Color("#faf3d4"),
	Color("#e6c853"),
	Color("#e0003f"),
	Color("#007bde"),
	Color("#282445"),
	Color("#2a7336"),
	Color("#3ccf53")
	]
var uniform_coloring = false

var disabled = 0

func _ready():
	# connect preset-colors
	for i in len(Presets):
		if Presets[i] is TextureButton:
			Presets[i].pressed.connect(_on_preset_pressed.bind(i))
	UserPresets.pop_front()
	for i in len(UserPresets):
		if UserPresets[i] is TextureButton:
			UserPresets[i].pressed.connect(_on_user_preset_pressed.bind(i))
	# connect with global
	## preset colors
	Global.user_saved_colors_changed.connect(load_user_preset_colors)
	## tooltips
	Global.tooltip_nodes.append_array([
		Preview, HueSlider, ValueSlider, SatSlider,
		Hash, AddButton, CloseButton
	] + Presets + UserPresets)
	# open something
	open(Color.BLUE)
	
	UniformColorButton.visible = not self.BACKGROUND_COLOR_SLIDER

# open and close

func open(color):
	# load ui
	set_color(color)
	load_preset_colors()
	load_user_preset_colors()
	show()

func close():
	hide()

# content

func load_preset_colors():
	for i in len(Presets):
		if Presets[i] is TextureButton:
			Presets[i].modulate = saved_colors[ min(len(saved_colors) - 1,  i) ]

func load_user_preset_colors():
	for i in len(UserPresets):
		if i < len(Global.user_saved_colors):
			UserPresets[i].modulate = Global.user_saved_colors[i]
			UserPresets[i].show()
		else:
			UserPresets[i].hide()
	UserPresetNode.visible = (len(Global.user_saved_colors) > 0)

func set_color(color = get_color()):
	disabled += 1
	
	# preview picture
	Preview.modulate = color
	# update backgrounds
	## value slider
	ValueTexture.texture.gradient.colors[0] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		color.s,
		0)
	ValueTexture.texture.gradient.colors[1] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		color.s,
		1)
	## saturation slider
	SatTexture.texture.gradient.colors[0] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		0,
		color.v)
	SatTexture.texture.gradient.colors[1] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		1,
		color.v)
	# update slider values
	if color.v > 0 and color.s > 0:
		HueSlider.value = color.h * HueSlider.max_value
	if color.v > 0:
		SatSlider.value = color.s * SatSlider.max_value
	ValueSlider.value = color.v * ValueSlider.max_value
	# update hash
	delete_hash_text()
	
	disabled -= 1

func get_color():
	return Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		float(SatSlider.value) / SatSlider.max_value,
		float(ValueSlider.value) / ValueSlider.max_value
	)

func _on_slider_value_changed(_value):
	set_color()
	if disabled == 0:
		color_changed.emit()

func _on_preset_pressed(i):
	set_color(Presets[i].modulate)
	if disabled == 0:
		color_changed.emit()

func _on_user_preset_pressed(i):
	if UserPresets[i].visible:
		set_color(UserPresets[i].modulate)
		if disabled == 0:
			color_changed.emit()

func _on_add_button_pressed():
	Global.user_saved_colors.push_front(get_color())
	while len(Global.user_saved_colors) > len(UserPresets):
		Global.user_saved_colors.pop_back()
	Global.user_saved_colors_changed.emit()

# html text

func delete_hash_text():
	Hash.text = ""
	Hash.placeholder_text = Preview.modulate.to_html(false)

func _on_hash_text_submitted(new_text):
	Hash.release_focus()
	if len(new_text) == 6:
		set_color(Color.from_string(new_text, Preview.modulate))
		color_changed.emit()
	else:
		delete_hash_text()

func _on_hash_focus_exited():
	_on_hash_text_submitted(Hash.text)

# end dialogue

func _on_close_button_pressed():
	finished.emit()

# color algorithm

func set_uniform_coloring(value) -> void:
	uniform_coloring = value
	UniformColorButton.set_value(value)

func _on_uniform_button_pressed() -> void:
	uniform_coloring = UniformColorButton.on
	color_changed.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			Preview.tooltip_text = "aktuelle Farbe"
			HueSlider.tooltip_text = "Farbton"
			ValueSlider.tooltip_text = "Helligkeit"
			SatSlider.tooltip_text = "Sättigung"
			for preset in Presets:
				preset.tooltip_text = "klicke um diese Farbe zu wählen"
			Hash.tooltip_text = "HTML-Farbcode"
			UserPresetsLabel.text = "Gespeichert:"
			for user_preset in UserPresets:
				user_preset.tooltip_text = "gespeicherte Farbe\n(max. 8)"
			AddButton.tooltip_text = "speichere aktuelle Farbe"
			CloseButton.tooltip_text = "Farbansicht schließen"
		_:
			Preview.tooltip_text = "preview of selected color"
			HueSlider.tooltip_text = "hue (\"color tone\") of selected color"
			ValueSlider.tooltip_text = "brightness"
			SatSlider.tooltip_text = "saturation or intensity of the color"
			for preset in Presets:
				preset.tooltip_text = "preset color"
			Hash.tooltip_text = "enter html-color-code here"
			UserPresetsLabel.text = "Saved:"
			for user_preset in UserPresets:
				user_preset.tooltip_text = "colors you saved\n(max. 8)"
			AddButton.tooltip_text = "save current color"
			CloseButton.tooltip_text = "close color settings"
