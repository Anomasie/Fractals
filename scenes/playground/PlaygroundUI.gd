extends MarginContainer

signal open_txt_options

@onready var Playground = $Playground
# There is no reason to call this a blue texture, as it isn't blue anymore.
# However, it was in a previous version, and I diffuse to change the name.
@onready var BlueTexture = $Right/Center/Center/BlueTexture

# advanced options
## buttons
@onready var AdvancedOptions = $Left/Main/AdvancedOptions # VBoxContainer
@onready var AdvancedButton = $Left/Main/AdvancedOptions/AdvancedButton
@onready var AdvButOpt = $Left/Main/AdvancedOptions/AdvButOpt
@onready var RotationButton = $Left/Main/AdvancedOptions/AdvButOpt/RotationButton
@onready var MatrixButton = $Left/Main/AdvancedOptions/AdvButOpt/MatrixButton
@onready var TxtButton = $Left/Main/AdvancedOptions/AdvButOpt/TxtButton
## options
@onready var RotatOptions = $RotatOptions
@onready var MatrixOptions = $MatrixOptions
# rect buttons
@onready var AddButton = $Left/Main/AddButton
@onready var CloseAllButton = $Left/Main/CloseAllButton
@onready var RemoveButton = $Left/Main/RemoveButton
@onready var DuplicateButton = $Left/Main/DuplicateButton
# presets
@onready var PresetsButton = $Right/Bottom/Main/PresetsButton
@onready var Presets = $Presets
@onready var PresetTimer = $PresetTimer
# colors
@onready var ColorButton = $Left/Main/ColorButton
@onready var ColorSliders = $ColorSliders

var disabled = 0
var rot = randi_range(0,360-1)

var old_loupe = Global.LOUPE
var old_origin

var rotatoptions_open = false
var matrixoptions_open = false
var colorsliders_open = false

func _ready():
	# connect
	Playground.fractal_changed.connect(_fractal_changed)
	
	# set minimal size
	## Advanced Options
	AdvancedOptions.custom_minimum_size = AdvancedOptions.size
	
	# hide and show
	AdvButOpt.hide()
	set_focused_rect_options_disabled(true)
	ColorSliders.close()
	RotatOptions.hide()
	MatrixOptions.hide()
	PresetsButton.hide()
	Presets.show()
	focus()
	
	# tooltips
	Global.tooltip_nodes.append_array([
		AddButton, DuplicateButton, ColorButton,
		RemoveButton, CloseAllButton,
		AdvancedButton, RotationButton, MatrixButton, TxtButton,
		PresetsButton])

func resize():
	BlueTexture.custom_minimum_size = Global.LOUPE
	#resize_playground()

func resize_playground():
	disabled += 1
	
	if typeof(old_origin) == TYPE_NIL:
		old_origin = get_origin()
	Playground.resize(old_origin, old_loupe, get_origin(), Global.LOUPE)
	old_loupe = Global.LOUPE
	old_origin = get_origin()
	
	disabled -= 1

func get_origin():
	return BlueTexture.get_global_position() + Vector2(0, BlueTexture.size.y)

func get_ifs():
	return Playground.get_ifs( get_origin() )

func set_ifs(ifs):
	disabled += 1
	
	if len(ifs.systems) > 0:
		CloseAllButton.disabled = false
	Playground.set_ifs(ifs, get_origin())
	_on_presets_close_me()
	PresetTimer.start()
	
	disabled -= 1

# hide and show

func set_focused_rect_options_disabled(disable = true):
	for button in [DuplicateButton, ColorButton, RemoveButton, RotationButton, MatrixButton]:
		button.disabled = disable
	CloseAllButton.disabled = (Playground.current_rect_counter == 0)

# focus

signal focus_ready

var CurrentRect = null

func focus(Rect = CurrentRect):
	CurrentRect = Rect
	# if nothing in focus:
	## close advanced options
	if typeof(CurrentRect) == TYPE_NIL:
		# and hide advanced option-button
		set_focused_rect_options_disabled(true)
		RotatOptions.hide()
		MatrixOptions.hide()
		ColorSliders.hide()
	# if you are focusing something:
	else:
		## update AdvancedOptions
		if rotatoptions_open:
			set_focused_rect_options_disabled(false)
			RotatOptions.show()
			MatrixOptions.hide()
			RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
		elif matrixoptions_open:
			set_focused_rect_options_disabled(false)
			MatrixOptions.show()
			RotatOptions.hide()
			MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
		else:
			set_focused_rect_options_disabled(false)
			PresetsButton.show()
		# coloring
		if colorsliders_open:
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
	CloseAllButton.show()
	
	disabled -= 1

func _on_close_all_pressed():
	disabled += 1
	
	Playground.close_all()
	CurrentRect = null
	# buttons
	CloseAllButton.disabled = true
	ColorSliders.close()
	RotatOptions.hide()
	MatrixOptions.hide()
	Presets.hide()
	PresetsButton.show()
	# reload fractal
	PresetTimer.start()
	
	disabled -= 1

## remove button

func _on_remove_button_pressed():
	disabled += 1
	
	# hide advanced options
	set_focused_rect_options_disabled(true) # no focus anymore
	RotatOptions.hide()
	MatrixOptions.hide()
	ColorSliders.hide()
	# close rect
	await Playground.close(CurrentRect)
	CloseAllButton.disabled = (Playground.current_rect_counter == 0)
	
	disabled -= 1
	_fractal_changed()

## colors

func _on_color_button_pressed():
	colorsliders_open = not colorsliders_open
	if colorsliders_open:
		ColorSliders.open(CurrentRect.get_color())
	else:
		ColorSliders._on_close_button_pressed()

func _on_color_sliders_color_changed():
	CurrentRect.color_rect(ColorSliders.get_color())
	_fractal_changed()

func _on_color_sliders_finished():
	colorsliders_open = false
	ColorSliders.close()

## duplicate button

func _on_duplicate_button_pressed():
	Playground.duplicate_rect(CurrentRect, get_origin())

## advanced options

var matrix_options = false

func open_advanced_options():
	AdvButOpt.hide()
	# visibility
	rotatoptions_open = not matrix_options
	matrixoptions_open = matrix_options
	# load data
	if rotatoptions_open:
		RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
		RotatOptions.show()
		MatrixOptions.hide()
	elif matrixoptions_open:
		MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
		MatrixOptions.show()
		RotatOptions.hide()
	# hide presets, because why not?
#	PresetsButton.hide()

func _on_advanced_button_pressed():
	AdvButOpt.visible = not AdvButOpt.visible
	Presets.hide()

func _on_rotation_button_pressed():
	disabled += 1
	
	matrix_options = false
	open_advanced_options()
	
	disabled -= 1

func _on_matrix_button_pressed():
	disabled += 1
	
	matrix_options = true
	open_advanced_options()
	
	disabled -= 1

func _on_txt_button_pressed():
	open_txt_options.emit()
	AdvButOpt.hide()

func _on_advanced_options_close_me():
	rotatoptions_open = false
	RotatOptions.hide()
	matrixoptions_open = false
	MatrixOptions.hide()
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
	open_advanced_options()

func _on_matrix_options_close_me():
	_on_advanced_options_close_me()

func _on_matrix_options_value_changed():
	_on_advanced_options_value_changed()

func _on_matrix_options_switch():
	matrix_options = false
	open_advanced_options()

## presets

func _on_presets_button_pressed():
	Presets.show()
	PresetsButton.hide()

func _on_presets_close_me():
	Presets.hide()
	PresetsButton.show()

func _on_presets_load_preset(ifs):
	set_ifs(ifs)

func _on_preset_timer_timeout():
	_fractal_changed()

# RESULTS

@onready var ResultUI

func _fractal_changed():
	if not disabled:
		# show results
		self.get_parent().get_owner().show_results()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			AddButton.tooltip_text = "füge neues Rechteck hinzu"
			CloseAllButton.tooltip_text = "lösche alle Rechtecke"
			RemoveButton.tooltip_text = "lösche ausgewähltes Rechteck"
			ColorButton.tooltip_text = "ändere Farbe des ausgewählten Rechtecks"
			DuplicateButton.tooltip_text = "dupliziere ausgewähltes Rechteck"
			AdvancedButton.tooltip_text = "fortgeschrittene Einstellungen"
			RotationButton.tooltip_text = "Rechteck bearbeiten"
			MatrixButton.tooltip_text = "Matrix bearbeiten"
			TxtButton.tooltip_text = "System bearbeiten"
			PresetsButton.text = "Vorlagen"
			PresetsButton.tooltip_text = "wähle ein Fraktal aus einer Vorlage"
		_:
			AddButton.tooltip_text = "add new rectangle"
			CloseAllButton.tooltip_text = "delete all rectangles"
			RemoveButton.tooltip_text = "delete selected rectangle"
			ColorButton.tooltip_text = "change color of selected rectangle"
			DuplicateButton.tooltip_text = "duplicate selected rectangle"
			AdvancedButton.tooltip_text = "advanced options"
			RotationButton.tooltip_text = "edit rectangle"
			MatrixButton.tooltip_text = "edit matrix"
			TxtButton.tooltip_text = "edit system"
			PresetsButton.text = "Presets"
			PresetsButton.tooltip_text = "choose fractal from a preset"
	# pass on signal
	Playground.reload_language()
	Presets.reload_language()
	MatrixOptions.reload_language()
	RotatOptions.reload_language()
	ColorSliders.reload_language()
