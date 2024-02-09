extends MarginContainer

@onready var Playground = $Playground
# There is no reason to call this a blue texture, as it isn't blue anymore.
# However, it was in a previous version, and I diffuse to change the name.
@onready var BlueTexture = $Columns/Right/Center/Center/BlueTexture

@onready var ButtonOptions = $Columns/Left/Main/ButtonOptions
@onready var AdvancedButton = $Columns/Right/Bottom/Main/AdvancedButton
@onready var RotatOptions = $Bottom/RotatOptions
@onready var MatrixOptions = $Bottom/MatrixOptions
@onready var DuplicateButton = $Columns/Left/Main/ButtonOptions/DuplicateButton

@onready var PresetsButton = $Columns/Right/Bottom/Main/PresetsButton
@onready var Presets = $Bottom/Presets
@onready var PresetTimer = $Bottom/PresetTimer

@onready var ColorButton = $Columns/Left/Main/ButtonOptions/ColorButton
@onready var ColorSliders = $ColorSliders

var disabled = 0
var rot = randi_range(0,360-1)

func _ready():
	Playground.fractal_changed.connect(_fractal_changed)
	# hide and show
	ColorSliders.close()
	PresetsButton.hide()
	Presets.show()
	focus()

var old_loupe = Global.LOUPE
var old_origin

func resize():
	BlueTexture.custom_minimum_size = Global.LOUPE
	#resize_playground()

func resize_playground():
	disabled += 1
	
	Playground.resize(old_origin, old_loupe, get_origin(), Global.LOUPE)
	old_loupe = Global.LOUPE
	old_origin = get_origin()
	
	disabled -= 1

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
	else:
		## update AdvancedOptions
		if RotatOptions.visible or MatrixOptions.visible:
			ButtonOptions.show()
			RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
			MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
		## open advanced option-button
		else:
			ButtonOptions.show()
			AdvancedButton.show()
			PresetsButton.show()
		# coloring
		if ColorSliders.visible:
			# load new color
			ColorSliders.open( Rect.get_color() )
	focus_ready.emit()

# left

## general options

func _on_add_pressed():
	disabled += 1
	
	Playground.add(Vector2(0.4,0.35) + Vector2(0.25,0).rotated(rot), get_origin())
	rot += PI / 4
	if rot >= 2 * PI:
		rot -= 2 * PI
	_on_presets_close_me()
	
	disabled -= 1

func _on_close_all_pressed():
	disabled += 1
	
	Playground.close_all()
	CurrentRect = null
	# left
	ColorButton.hide()
	ColorSliders.close()
	# right
	RotatOptions.hide()
	MatrixOptions.hide()
	AdvancedButton.hide()
	Presets.hide()
	PresetsButton.show()
	# reload fractal
	PresetTimer.start()
	
	disabled -= 1

## remove button

func _on_remove_button_pressed():
	disabled += 1
	await Playground.close(CurrentRect)
	disabled -= 1
	_fractal_changed()

## colors

func _on_color_button_pressed():
	if not ColorSliders.visible:
		ColorSliders.open(CurrentRect.get_color())
	else:
		ColorSliders._on_close_button_pressed()

func _on_color_sliders_color_changed():
	CurrentRect.color_rect(ColorSliders.get_color())
	_fractal_changed()

func _on_color_sliders_finished():
	ColorSliders.close()

## duplicate button

func _on_duplicate_button_pressed():
	Playground.duplicate_rect(CurrentRect, get_origin())

## advanced options

var matrix_options = false

func _on_advanced_button_pressed():
	disabled += 1
	
	AdvancedButton.hide()
	RotatOptions.visible = not matrix_options
	MatrixOptions.visible = matrix_options
	RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	PresetsButton.hide()
	
	disabled -= 1

func _on_advanced_options_close_me():
	RotatOptions.hide()
	MatrixOptions.hide()
	AdvancedButton.show()
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
		new_contraction.color = CurrentRect.get_color()
		CurrentRect.update_to(new_contraction, get_origin())

func _on_advanced_options_switch():
	matrix_options = true
	_on_advanced_button_pressed()

func _on_matrix_options_switch():
	matrix_options = false
	_on_advanced_button_pressed()


## presets

func _on_presets_button_pressed():
	Presets.show()
	AdvancedButton.hide()
	PresetsButton.hide()

func _on_presets_close_me():
	Presets.hide()
	if typeof(CurrentRect) != TYPE_NIL:
		AdvancedButton.show()
	PresetsButton.show()

func _on_presets_load_preset(ifs):
	disabled += 1
	
	Playground.set_ifs(ifs, get_origin())
	_on_presets_close_me()
	PresetTimer.start()
	
	disabled -= 1

func _on_preset_timer_timeout():
	_fractal_changed()

# RESULTS

@onready var ResultUI

func _fractal_changed():
	if not disabled:
		var ifs = Playground.get_ifs( get_origin() )
		# update ifs_menu
		ifs.background_color = ResultUI.ResultBackground.self_modulate
		# show results
		self.get_parent().get_owner().show_results(ifs)
