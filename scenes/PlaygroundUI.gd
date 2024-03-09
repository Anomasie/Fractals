extends MarginContainer

@onready var Playground = $Playground
# There is no reason to call this a blue texture, as it isn't blue anymore.
# However, it was in a previous version, and I diffuse to change the name.
@onready var BlueTexture = $Columns/Right/Center/Center/BlueTexture

@onready var ButtonOptions = $Columns/Left/Main/ButtonOptions
@onready var AdvancedButton = $Columns/Left/Main/ButtonOptions/AdvancedButton
@onready var RotatOptions = $RotatOptions
@onready var MatrixOptions = $MatrixOptions
@onready var AddButton = $Columns/Left/Main/AddButton
@onready var CloseAllButton = $Columns/Left/Main/CloseAllButton
@onready var RemoveButton = $Columns/Left/Main/ButtonOptions/RemoveButton
@onready var DuplicateButton = $Columns/Left/Main/ButtonOptions/DuplicateButton

@onready var PresetsButton = $Columns/Right/Bottom/Main/PresetsButton
@onready var Presets = $Presets
@onready var PresetTimer = $PresetTimer

@onready var ColorButton = $Columns/Left/Main/ButtonOptions/ColorButton
@onready var ColorSliders = $ColorSliders

var disabled = 0
var rot = randi_range(0,360-1)

var old_loupe = Global.LOUPE
var old_origin

func _ready():
	Playground.fractal_changed.connect(_fractal_changed)
	# hide and show
	ColorSliders.close()
	PresetsButton.hide()
	CloseAllButton.hide()
	Presets.show()
	focus()

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
	CloseAllButton.show()
	
	disabled -= 1

func _on_close_all_pressed():
	disabled += 1
	
	Playground.close_all()
	CurrentRect = null
	# buttons
	CloseAllButton.hide()
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
	
	await Playground.close(CurrentRect)
	CloseAllButton.visible = ( Playground.current_rect_counter > 0 )
	
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

func open_advanced_options():
	# visibility
	RotatOptions.visible = not matrix_options
	MatrixOptions.visible = matrix_options
	# load data
	RotatOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	MatrixOptions.load_ui(CurrentRect.get_contraction( get_origin() ))
	# hide presets, because why not?
#	PresetsButton.hide()

func _on_advanced_button_pressed():
	disabled += 1
	
	if RotatOptions.visible or MatrixOptions.visible:
		_on_advanced_options_close_me()
	else:
		open_advanced_options()
	
	disabled -= 1

func _on_advanced_options_close_me():
	RotatOptions.hide()
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
	disabled += 1
	
	CloseAllButton.show()
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
		# show results
		self.get_parent().get_owner().show_results()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			AddButton.tooltip_text = "füge neues Rechteck hinzu"
			CloseAllButton.tooltip_text = "lösche alle Rechtecke"
			RemoveButton.tooltip_text = "lösche markiertes Rechteck"
			ColorButton.tooltip_text = "ändere Farbe des markierten Rechtecks"
			DuplicateButton.tooltip_text = "dupliziere markiertes Rechteck"
			AdvancedButton.tooltip_text = "fortgeschrittene Einstellungen"
			PresetsButton.text = "Vorlagen"
			PresetsButton.tooltip_text = "wähle ein Fraktal aus einer Vorlage"
		_:
			AddButton.tooltip_text = "add new rectangle"
			CloseAllButton.tooltip_text = "delete all rectangles"
			RemoveButton.tooltip_text = "delete selected rectangle"
			ColorButton.tooltip_text = "change color of selected rectangle"
			DuplicateButton.tooltip_text = "duplicate selected rectangle"
			AdvancedButton.tooltip_text = "open advanced options"
			PresetsButton.text = "Presets"
			PresetsButton.tooltip_text = "choose fractal from a preset"
	# pass on signal
	Playground.reload_language()
	Presets.reload_language()
	MatrixOptions.reload_language()
	RotatOptions.reload_language()
	ColorSliders.reload_language()
