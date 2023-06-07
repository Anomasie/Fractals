extends Control

@onready var Playground = $Playground
# There is no reason to call this a blue texture, as it isn't blue anymore.
# However, it was in a previous version, and I diffuse to change the name.
@onready var BlueTexture = $Center/Center/BlueTexture
@onready var ColorBar = $Left/Lines/ColorBar
@onready var ColorBarPicker = $Left/Lines/ColorBar/ColorPicker
@onready var ColorBarReadyButton = $Left/Lines/ColorBar/ReadyButton
@onready var ResultButton = $Right/Lines/ResultButton

var rot = randi_range(0,360-1)

func _ready():
	resize()
	# hide and show
	ColorBar.hide()
	focus()

func _on_add_pressed():
	Playground.add(self.get_global_position() + self.size / 2 + Vector2(128,0).rotated(rot))
	rot += 4
	if rot >= 360:
		rot -= 360
	_on_presets_close_me()

func _on_close_all_pressed():
	Playground.close_all()
	editing_color = false
	rect_editing_color = null
	ColorBar.hide()
	_on_presets_close_me()

func _on_results_pressed():
	var ifs = Playground.get_ifs( BlueTexture.get_global_position() )
	self.get_parent().show_results(ifs)

func resize():
	BlueTexture.custom_minimum_size = Global.LOUPE

# colors

var editing_color = false
var rect_editing_color = null

func color(MyRect):
	editing_color = true
	rect_editing_color = MyRect
	print(MyRect, " wants a color")
	MyRect.Rect.self_modulate = ColorBarPicker.color
	ColorBar.show()
	await ColorBarReadyButton.pressed
	editing_color = false
	rect_editing_color = null
	ColorBar.hide()

func _on_color_picker_color_changed(new_color):
	if editing_color and rect_editing_color:
		rect_editing_color.color_rect(new_color)

# advanced options

signal focus_ready

@onready var AdvancedButton = $Right/Lines/AdvancedButton
@onready var AdvancedOptions = $Right/Lines/AdvancedOptions
@onready var DuplicateButton = $Left/Lines/DuplicateButton

var CurrentRect = null

func focus(Rect = CurrentRect):
	CurrentRect = Rect
	# if nothing in focus:
	## close advanced options
	if typeof(CurrentRect) == TYPE_NIL:
		_on_advanced_options_close_me()
		# and hide advanced option-button
		AdvancedButton.hide()
		DuplicateButton.hide()
	# if you are focusing something:
	## update AdvancedOptions
	elif AdvancedOptions.visible:
		AdvancedOptions.load_ui(CurrentRect.get_contraction( BlueTexture.get_global_position() ))
	## open advanced option-button
	else:
		AdvancedButton.show()
		PresetsButton.show()
		DuplicateButton.show()
	focus_ready.emit()

func _on_advanced_button_pressed():
	AdvancedButton.hide()
	AdvancedOptions.show()
	AdvancedOptions.load_ui(CurrentRect.get_contraction( BlueTexture.get_global_position() ))
	ResultButton.hide()
	PresetsButton.hide()

func _on_advanced_options_close_me():
	AdvancedOptions.hide()
	AdvancedButton.show()
	ResultButton.show()
	PresetsButton.show()

func _on_advanced_options_value_changed():
	# editing the rect using the rect-ui will update advanced-uptions-ui
	# however, this change should not be driven back to rect-ui
	# which would provide no further information but make the animation chunky
	if not CurrentRect.editing_position and not CurrentRect.editing_width and not CurrentRect.editing_height and not CurrentRect.editing_turn:
		var new_contraction = AdvancedOptions.read_ui()
		new_contraction.color = CurrentRect.Rect.self_modulate
		CurrentRect.update_to(new_contraction, BlueTexture.get_global_position())

func _on_duplicate_button_pressed():
	Playground.duplicate_rect(CurrentRect, BlueTexture.get_global_position())

# presets

@onready var PresetsButton = $Right/Lines/PresetsButton
@onready var Presets = $Right/Lines/Presets

func _on_presets_button_pressed():
	Presets.show()
	AdvancedButton.hide()
	PresetsButton.hide()
	ResultButton.hide()

func _on_presets_close_me():
	Presets.hide()
	AdvancedButton.show()
	PresetsButton.show()
	ResultButton.show()

func _on_presets_load_preset(ifs):
	Playground.set_ifs(ifs, BlueTexture.get_global_position())
	_on_presets_close_me()
