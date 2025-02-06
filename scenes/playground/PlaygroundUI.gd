extends MarginContainer

signal load_ifs

signal fractal_changed_vastly
signal fractal_changed
signal open_txt_options
signal break_contraction
signal break_all
signal center_all

@onready var Playground = $Playground
# There is no reason to call this a blue texture, as it isn't blue anymore.
# However, it was in a previous version, and I diffuse to change the name.
@onready var BlueTexture = $Right/Center/Center/BlueTexture

# advanced options
@onready var GeomOptions = $GeometricOptions
@onready var MatrixOptions = $MatrixOptions
# rect buttons
@onready var AddButton = $Left/Main/AddButton
@onready var CloseAllButton = $Left/Main/CloseAllButton
@onready var RemoveButton = $Left/Main/RemoveButton
#@onready var DuplicateButton = $Left/Main/DuplicateButton
@onready var OtherOptions = $Left/Main/OtherOptions
# presets
@onready var PresetsButton = $Right/Bottom/Main/PresetsButton
@onready var Presets = $Presets
@onready var PresetTimer = $PresetTimer
# colors
@onready var ColorButton = $Left/Main/ColorButton
@onready var ColorSliders = $ColorSliders

var rot = randi_range(0,360-1)

var rotatoptions_open = false
var matrixoptions_open = false
var colorsliders_open = false

var CurrentRects = []

func _ready():
	# connect
	Playground.fractal_changed.connect(_fractal_changed)
	
	# hide and show
	set_focused_rect_options_disabled(0)
	OtherOptions.close()
	ColorSliders.close()
	GeomOptions.hide()
	MatrixOptions.hide()
	PresetsButton.hide()
	Presets.show()
	focus()
	
	# tooltips
	Global.tooltip_nodes.append_array([
		AddButton, ColorButton,
		RemoveButton, CloseAllButton,
		PresetsButton])

func resize():
	BlueTexture.custom_minimum_size = Global.LOUPE

func resize_playground(ifs):
	Playground.set_ifs(ifs, get_origin())

func get_origin():
	return BlueTexture.get_global_position() + Vector2(0, BlueTexture.size.y)

func get_ifs():
	var ifs = Playground.get_ifs( get_origin() )
	ifs.uniform_coloring = ColorSliders.uniform_coloring
	return ifs

func set_ifs(ifs):
	if len(ifs.systems) > 0:
		CloseAllButton.disabled = false
	Playground.set_ifs(ifs, get_origin())
	ColorSliders.set_uniform_coloring(ifs.uniform_coloring)
	_on_presets_close_me()

# hide and show

func set_focused_rect_options_disabled(length):
	ColorButton.disabled = (length == 0)
	RemoveButton.disabled = (length == 0)
	CloseAllButton.disabled = (Playground.rect_counter == 0)
	OtherOptions.set_disabled(length == 0, Playground.rect_counter)

# focus

func focus(Rects = CurrentRects):
	if typeof(Rects) != TYPE_ARRAY:
		print("ERROR in PlaygroundUI: try to load ", Rects, " (type: ", typeof(Rects), ") as Rects.")
		return
	
	CurrentRects = Rects
	# if nothing in focus:
	## close advanced options
	set_focused_rect_options_disabled(len(CurrentRects))
	Playground.focus(CurrentRects)
	if len(CurrentRects) == 0:
		# and hide advanced option-button
		GeomOptions.hide()
		MatrixOptions.hide()
		ColorSliders.hide()
	# if you are focusing something:
	elif len(CurrentRects) == 1:
		## update AdvancedOptions
		if rotatoptions_open:
			GeomOptions.show()
			MatrixOptions.hide()
			GeomOptions.load_ui(CurrentRects[0].get_contraction( get_origin() ))
		elif matrixoptions_open:
			MatrixOptions.show()
			GeomOptions.hide()
			MatrixOptions.load_ui(CurrentRects[0].get_contraction( get_origin() ))
		else:
			PresetsButton.show()
		# coloring
		if colorsliders_open:
			# load new color
			ColorSliders.open( CurrentRects[0].get_color() )

func focus_region(rect):
	focus(Playground.get_rects_in_region(rect))

func _on_playground_defocus() -> void:
	focus([])

func _on_playground_focus_this(object) -> void:
	if typeof(object) == TYPE_ARRAY:
		focus(object)
	else:
		focus([object])

# left

## general options

func _on_add_pressed():
	Playground.add(Vector2(0.4,0.35) + Vector2(0.25,0).rotated(rot), get_origin())
	rot += PI / 4
	if rot >= 2 * PI:
		rot -= 2 * PI
	_on_presets_close_me()
	CloseAllButton.show()
	
	fractal_changed_vastly.emit()

func _on_close_all_pressed():
	Playground.close_all()
	CurrentRects = []
	# buttons
	CloseAllButton.disabled = true
	ColorSliders.close()
	GeomOptions.hide()
	MatrixOptions.hide()
	Presets.hide()
	PresetsButton.show()
	# reload fractal
	PresetTimer.start()

## remove button

func _on_remove_button_pressed():
	# hide advanced options
	set_focused_rect_options_disabled(0) # no focus anymore
	GeomOptions.hide()
	MatrixOptions.hide()
	ColorSliders.hide()
	# close rect
	await Playground.close(CurrentRects)
	CloseAllButton.disabled = (Playground.rect_counter == 0)
	
	fractal_changed_vastly.emit()

## colors

func _on_color_button_pressed():
	# hide all other options
	_on_advanced_options_close_me()
	# open color options
	colorsliders_open = not colorsliders_open
	if colorsliders_open:
		ColorSliders.open(CurrentRects[0].get_color())
	else:
		ColorSliders._on_close_button_pressed()

func _on_color_sliders_color_changed():
	for rect in CurrentRects:
		rect.color_rect(ColorSliders.get_color())
	_fractal_changed()

func _on_color_sliders_finished():
	colorsliders_open = false
	ColorSliders.close()

## other options

### duplicating
func _on_other_options_duplicate() -> void:
	for rect in CurrentRects:
		Playground.duplicate_rect(rect, get_origin())
	fractal_changed_vastly.emit()

### mirroring
func _on_other_options_mirror_y() -> void:
	for rect in CurrentRects:
		rect.mirror()
	fractal_changed.emit()
	fractal_changed_vastly.emit()

func _on_other_options_mirror_x() -> void:
	for rect in CurrentRects:
		rect.mirror()
		rect.turn_rect(rect.rotation + PI, true)
	fractal_changed.emit()
	fractal_changed_vastly.emit()

### breaking
func _on_other_options_break_focused() -> void:
	break_contraction.emit()
	fractal_changed.emit()
	fractal_changed_vastly.emit()

func _on_other_options_break_all() -> void:
	break_all.emit()

### rotating
func _on_other_options_rotate_45() -> void:
	for rect in CurrentRects:
		rect.turn_rect(rect.rotation - PI/4, true)
	fractal_changed.emit()
	fractal_changed_vastly.emit()

### centering
func _on_other_options_center_all() -> void:
	center_all.emit()

func _on_other_options_center_x() -> void:
	for rect in CurrentRects:
		var current_contraction = rect.get_contraction(get_origin())
		current_contraction.translation.y += 0.5 - current_contraction.apply(Vector2(0.5,0.5)).y
		rect.update_to(current_contraction, get_origin())
	fractal_changed.emit()
	fractal_changed_vastly.emit()

func _on_other_options_center_y() -> void:
	for rect in CurrentRects:
		var current_contraction = rect.get_contraction(get_origin())
		current_contraction.translation.x += 0.5 - current_contraction.apply(Vector2(0.5,0.5)).x
		rect.update_to(current_contraction, get_origin())
	fractal_changed.emit()
	fractal_changed_vastly.emit()

### advanced options

var matrix_options = false

func open_advanced_options():
	# hide all other options
	_on_color_sliders_finished()
	# visibility
	rotatoptions_open = not matrix_options
	matrixoptions_open = matrix_options
	# load data
	OtherOptions.set_advanced_options_pressed(rotatoptions_open, matrixoptions_open)
	if rotatoptions_open:
		GeomOptions.load_ui(CurrentRects[0].get_contraction( get_origin() ))
		GeomOptions.show()
		MatrixOptions.hide()
	elif matrixoptions_open:
		MatrixOptions.load_ui(CurrentRects[0].get_contraction( get_origin() ))
		MatrixOptions.show()
		GeomOptions.hide()
	# hide presets, because why not?
#	PresetsButton.hide()

func _on_other_options_opened() -> void:
	PresetsButton.show()
	Presets.hide()

func _on_other_options_open_geometric_options() -> void:
	if GeomOptions.visible:
		_on_advanced_options_close_me()
	else:
		matrix_options = false
		open_advanced_options()

func _on_other_options_open_matrix_options() -> void:
	if MatrixOptions.visible:
		_on_advanced_options_close_me()
	else:
		matrix_options = true
		open_advanced_options()

func _on_other_options_open_txt_options() -> void:
	# close all other options
	_on_color_sliders_finished()
	_on_advanced_options_close_me()
	# open txt options
	open_txt_options.emit()
	OtherOptions.close()

func _on_advanced_options_close_me():
	rotatoptions_open = false
	GeomOptions.hide()
	matrixoptions_open = false
	OtherOptions.set_advanced_options_pressed(rotatoptions_open, matrixoptions_open)
	MatrixOptions.hide()
	PresetsButton.show()

## changed values

func _on_advanced_options_value_changed():
	# editing the rect using the rect-ui will update advanced-uptions-ui
	# however, this change should not be driven back to rect-ui
	# which would provide no further information but make the animation chunky
	if not CurrentRects[0].editing_position and not CurrentRects[0].editing_width and not CurrentRects[0].editing_height and not CurrentRects[0].editing_turn:
		var new_contraction
		if matrix_options:
			new_contraction = MatrixOptions.read_ui()
		else:
			new_contraction = GeomOptions.read_ui()
		new_contraction.color = CurrentRects[0].get_color()
		CurrentRects[0].update_to(new_contraction, get_origin())
	
		fractal_changed_vastly.emit()

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
	load_ifs.emit(ifs, true, false)

func _on_preset_timer_timeout():
	_fractal_changed()
	fractal_changed_vastly.emit()

# RESULTS

@onready var ResultUI

func _fractal_changed():
	fractal_changed.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			AddButton.tooltip_text = "füge neues Rechteck hinzu"
			CloseAllButton.tooltip_text = "lösche alle Rechtecke"
			RemoveButton.tooltip_text = "lösche ausgewähltes Rechteck"
			ColorButton.tooltip_text = "ändere Farbe des ausgewählten Rechtecks"
#			DuplicateButton.tooltip_text = "dupliziere ausgewähltes Rechteck"
			PresetsButton.text = "Vorlagen"
			PresetsButton.tooltip_text = "wähle ein Fraktal aus einer Vorlage"
		_:
			AddButton.tooltip_text = "add new rectangle"
			CloseAllButton.tooltip_text = "delete all rectangles"
			RemoveButton.tooltip_text = "delete selected rectangle"
			ColorButton.tooltip_text = "change color of selected rectangle"
#			DuplicateButton.tooltip_text = "duplicate selected rectangle"
			PresetsButton.text = "Presets"
			PresetsButton.tooltip_text = "choose fractal from a preset"
	# pass on signal
	Playground.reload_language()
	OtherOptions.reload_language()
	Presets.reload_language()
	MatrixOptions.reload_language()
	GeomOptions.reload_language()
	ColorSliders.reload_language()

func _on_playground_fractal_changed_vastly() -> void:
	fractal_changed_vastly.emit()

func _on_color_sliders_color_changed_vastly() -> void:
	fractal_changed_vastly.emit()
