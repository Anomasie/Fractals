extends VBoxContainer

@onready var Playground = $Playground
# There is no reason to call this a blue texture, as it isn't blue anymore.
# However, it was in a previous version, and I diffuse to change the name.
@onready var BlueTexture = $Center/Center/BlueTexture
@onready var ResultButton = $Bottom/Lines/ResultButton

var rot = randi_range(0,360-1)

func _ready():
	resize()
	# hide and show
	ColorBar.hide()
	focus()

var old_loupe = Global.LOUPE
var old_origin

func resize():
	BlueTexture.custom_minimum_size = Global.LOUPE

func resize_playground():
	Playground.resize(old_origin, old_loupe, get_origin(), Global.LOUPE)
	old_loupe = Global.LOUPE
	old_origin = get_origin()

func get_origin():
	return BlueTexture.get_global_position() + Vector2(0, BlueTexture.size.y)

# focus

signal focus_ready

var CurrentRect = null

func focus(Rect = CurrentRect):
	CurrentRect = Rect
	# if nothing in focus:
	## close advanced options
	if typeof(CurrentRect) == TYPE_NIL:
		# and hide advanced option-button
		ButtonOptions.hide()
		AdvancedButton.hide()
	# if you are focusing something:
	## update AdvancedOptions
	elif RotatOptions.visible or MatrixOptions.visible:
		ButtonOptions.show()
		RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
		MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	## open advanced option-button
	else:
		ButtonOptions.show()
		AdvancedButton.show()
		PresetsButton.show()
	focus_ready.emit()

# left

@onready var ButtonOptions = $Top/Lines/ButtonOptions

## general options

func _on_add_pressed():
	Playground.add(self.get_global_position() + self.size / 2 + Vector2(128,0).rotated(rot))
	rot += PI / 4
	if rot >= 2 * PI:
		rot -= 2 * PI
	_on_presets_close_me()

func _on_close_all_pressed():
	Playground.close_all()
	editing_color = false
	rect_editing_color = null
	CurrentRect = null
	# left
	ColorButton.hide()
	ColorBar.hide()
	# right
	RotatOptions.hide()
	MatrixOptions.hide()
	AdvancedButton.hide()
	Presets.hide()
	PresetsButton.show()
	ResultButton.show()

## remove button


func _on_remove_button_pressed():
	Playground.close(CurrentRect)

## colors

@onready var ColorButton = $Top/Lines/ButtonOptions/ColorButton
@onready var ColorBar = $Top/Lines/ButtonOptions/ColorBar
@onready var ColorBarPicker = $Top/Lines/ButtonOptions/ColorBar/ColorContainer/ColorPicker
@onready var ColorBarReadyButton = $Top/Lines/ButtonOptions/ColorBar/ReadyButton

var editing_color = false
var rect_editing_color = null

func _on_color_button_pressed():
	color(CurrentRect)
	ColorButton.hide()

func color(MyRect):
	editing_color = true
	rect_editing_color = MyRect
	MyRect.Rect.self_modulate = ColorBarPicker.color
	ColorBar.show()
	await ColorBarReadyButton.pressed
	editing_color = false
	rect_editing_color = null
	ColorBar.hide()
	ColorButton.show()

func _on_color_picker_color_changed(new_color):
	if editing_color and rect_editing_color:
		rect_editing_color.color_rect(new_color)

## duplicate button

func _on_duplicate_button_pressed():
	Playground.duplicate_rect(CurrentRect, get_origin())

# right

func _on_results_pressed():
	var ifs = Playground.get_ifs( get_origin() )
	self.get_parent().show_results(ifs)

## advanced options

@onready var AdvancedButton = $Bottom/Lines/AdvancedButton
@onready var RotatOptions = $Bottom/Lines/RotatOptions
@onready var MatrixOptions = $Bottom/Lines/MatrixOptions
@onready var DuplicateButton = $Top/Lines/ButtonOptions/DuplicateButton

var matrix_options = false

func _on_advanced_button_pressed():
	AdvancedButton.hide()
	RotatOptions.visible = not matrix_options
	MatrixOptions.visible = matrix_options
	RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	ResultButton.hide()
	PresetsButton.hide()

func _on_advanced_options_close_me():
	RotatOptions.hide()
	MatrixOptions.hide()
	AdvancedButton.show()
	ResultButton.show()
	PresetsButton.show()

func _on_advanced_options_value_changed():
	# editing the rect using the rect-ui will update advanced-uptions-ui
	# however, this change should not be driven back to rect-ui
	# which would provide no further information but make the animation chunky
	if not CurrentRect.editing_position and not CurrentRect.editing_width and not CurrentRect.editing_height and not CurrentRect.editing_turn:
		var new_contraction
		if matrix_options:
			new_contraction = MatrixOptions.read_ui()
		else:
			new_contraction = RotatOptions.read_ui()
		new_contraction.color = CurrentRect.Rect.self_modulate
		CurrentRect.update_to(new_contraction, get_origin())

func _on_advanced_options_switch():
	matrix_options = true
	RotatOptions.hide()
	MatrixOptions.show()

func _on_matrix_options_switch():
	matrix_options = false
	RotatOptions.show()
	MatrixOptions.hide()


## presets

@onready var PresetsButton = $Bottom/Lines/PresetsButton
@onready var Presets = $Bottom/Lines/Presets

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
	Playground.set_ifs(ifs, get_origin())
	_on_presets_close_me()
