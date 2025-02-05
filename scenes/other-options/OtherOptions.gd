@tool
extends HBoxContainer

signal opened

signal duplicate
signal mirror_x
signal mirror_y
signal break_focused
signal break_all

signal open_geometric_options
signal open_matrix_options
signal open_txt_options

@onready var OpenButton = $OpenButton

@onready var Content = $Content

@onready var EditButtons = $Content/EditButtons
@onready var DuplicateButton = $Content/EditButtons/DuplicateButton
@onready var YMirrorButton = $Content/EditButtons/YMirrorButton
@onready var XMirrorButton = $Content/EditButtons/XMirrorButton
@onready var BreakButton = $Content/EditButtons/BreakButton
@onready var BreakAllButton = $Content/EditButtons/BreakAllButton

@onready var GeomOptButton = $Content/AdvOptions/GeomOptButton
@onready var MatrixOptButton = $Content/AdvOptions/MatrixOptButton
@onready var TxtOptButton = $Content/AdvOptions/TxtOptButton

@export var open = false

func _ready() -> void:
	OpenButton.custom_minimum_size.y = int( len(EditButtons.get_children()) / EditButtons.columns ) * 32
	if not Engine.is_editor_hint():
		Global.tooltip_nodes.append_array([
			OpenButton, DuplicateButton, XMirrorButton, YMirrorButton, BreakButton, BreakAllButton,
			GeomOptButton, MatrixOptButton, TxtOptButton])

func _process(_delta):
	if Engine.is_editor_hint():
		if open: Content.show()
		else: Content.hide()

func set_disabled(nothing_focused=false, ifs_size=1) -> void:
	if not Content.visible:
		OpenButton.disabled = (ifs_size==0)
	for button in [
		DuplicateButton, YMirrorButton, XMirrorButton,
		BreakButton,
		GeomOptButton,
		MatrixOptButton
		]:
		button.disabled = nothing_focused
	BreakAllButton.disabled = ifs_size > 10 or ifs_size == 0

func close():
	OpenButton.button_pressed = false
	Content.hide()

func set_advanced_options_pressed(geom_options, matrix_options, txt_options=false):
	GeomOptButton.button_pressed = geom_options
	MatrixOptButton.button_pressed = matrix_options
	TxtOptButton.button_pressed = txt_options

func _on_open_button_pressed() -> void:
	Content.visible = OpenButton.button_pressed
	opened.emit()

# buttons

func _on_duplicate_button_pressed() -> void:
	duplicate.emit()

func _on_y_mirror_button_pressed() -> void:
	mirror_y.emit()

func _on_x_mirror_button_pressed() -> void:
	mirror_x.emit()

func _on_break_button_pressed() -> void:
	break_focused.emit()

func _on_break_all_button_pressed() -> void:
	break_all.emit()

# advanced options buttons

func _on_geom_opt_button_pressed() -> void:
	open_geometric_options.emit()

func _on_matrix_opt_button_pressed() -> void:
	open_matrix_options.emit()

func _on_txt_opt_button_pressed() -> void:
	open_txt_options.emit()

# language

func reload_language():
	match Global.language:
		"GER":
			OpenButton.tooltip_text = "öffne weitere Optionen"
			DuplicateButton.tooltip_text = "dupliziere ausgewähltes Rechteck"
			YMirrorButton.tooltip_text = "spiegele ausgewähltes Rechteck an der vertikalen Achse"
			XMirrorButton.tooltip_text = "spiegele ausgewähltes Rechteck an der horizontalen Achse"
			BreakButton.tooltip_text = "zerteile dieses Rechteck in die Bilder unter den anderen Funktionen"
			BreakAllButton.tooltip_text = "wende jede Funktion auf jedes Rechteck einmal an"
			# advanced options
			GeomOptButton.tooltip_text = "Rechteck bearbeiten"
			MatrixOptButton.tooltip_text = "Matrix bearbeiten"
			TxtOptButton.tooltip_text = "System bearbeiten"
		_:
			OpenButton.tooltip_text = "open other options"
			DuplicateButton.tooltip_text = "duplicate selected rectangle"
			YMirrorButton.tooltip_text = "mirror selected rectangle vertically"
			XMirrorButton.tooltip_text = "mirror selected rectangle horizontally"
			BreakButton.tooltip_text = "split selected rectangle into images under all functions"
			BreakAllButton.tooltip_text = "split all rectangles into images under all functions"
			# advanced options
			GeomOptButton.tooltip_text = "edit rectangle"
			MatrixOptButton.tooltip_text = "edit matrix"
			TxtOptButton.tooltip_text = "edit system"
