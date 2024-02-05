extends MarginContainer

@onready var Preview = $Content/Columns/Preview

@onready var HueTexture = $Content/Columns/Sliders/Hue/Texture
@onready var HueSlider = $Content/Columns/Sliders/Hue/Slider
@onready var SatTexture = $Content/Columns/Sliders/Saturation/Texture
@onready var SatSlider = $Content/Columns/Sliders/Saturation/Slider
@onready var ValueTexture = $Content/Columns/Sliders/Value/Texture
@onready var ValueSlider = $Content/Columns/Sliders/Value/Slider

@onready var Presets = $Content/Columns/Sliders/Presets.get_children()
@onready var UserPresetNode = $Content/Columns/Sliders/UserPresets
@onready var UserPresets = $Content/Columns/Sliders/UserPresets.get_children()

var saved_colors = [Color.MIDNIGHT_BLUE, Color.WEB_GRAY, Color.ANTIQUE_WHITE, Color.CRIMSON, Color.GOLD, Color.LIME_GREEN, Color.AQUA, Color.ROYAL_BLUE]
var user_saved_colors = []

func _ready():
	# connect preset-colors
	for i in len(Presets):
		Presets[i].pressed.connect(_on_preset_pressed.bind(i))
	for i in len(UserPresets):
		UserPresets[i].pressed.connect(_on_user_preset_pressed.bind(i))
	# load ui
	set_color()
	load_preset_colors()
	load_user_preset_colors()

func load_preset_colors():
	for i in len(Presets):
		Presets[i].modulate = saved_colors[ min(len(saved_colors) - 1,  i) ]

func load_user_preset_colors():
	for i in len(UserPresets):
		if i < len(user_saved_colors):
			UserPresets[i].modulate = user_saved_colors[i]
			UserPresets[i].show()
		else:
			UserPresets[i].hide()
	UserPresetNode.visible = (len(user_saved_colors) > 0)

func set_color(color = get_color()):
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

func get_color():
	return Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		float(SatSlider.value) / SatSlider.max_value,
		float(ValueSlider.value) / ValueSlider.max_value
	)

func _on_slider_value_changed(_value):
	set_color()

func _on_preset_pressed(i):
	set_color(Presets[i].modulate)

func _on_user_preset_pressed(i):
	if UserPresets[i].visible:
		set_color(UserPresets[i].modulate)

func _on_add_button_pressed():
	user_saved_colors.push_front(get_color())
	while len(user_saved_colors) > len(UserPresets):
		user_saved_colors.pop_back()
	load_user_preset_colors()
