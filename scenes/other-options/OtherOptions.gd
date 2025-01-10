@tool
extends HBoxContainer

signal duplicate
signal mirror_x
signal mirror_y
signal break_focused
signal break_all

@onready var OpenButton = $OpenButton

@onready var Content = $Content

@onready var DuplicateButton = $Content/DuplicateButton
@onready var YMirrorButton = $Content/YMirrorButton
@onready var XMirrorButton = $Content/XMirrorButton
@onready var BreakButton = $Content/BreakButton
@onready var BreakAllButton = $Content/BreakAllButton

func _ready() -> void:
	Content.hide()
	Global.tooltip_nodes.append_array([
		OpenButton, DuplicateButton, XMirrorButton, YMirrorButton, BreakButton, BreakAllButton])

func set_disabled(nothing_focused=false, ifs_size=1) -> void:
	if Content.visible:
		OpenButton.disabled = ifs_size==0
	DuplicateButton.disabled = nothing_focused
	YMirrorButton.disabled = nothing_focused
	XMirrorButton.disabled = nothing_focused
	BreakButton.disabled = nothing_focused
	BreakAllButton.disabled = ifs_size > 10 or ifs_size == 0

func close():
	OpenButton.button_pressed = false
	Content.hide()

func _on_open_button_pressed() -> void:
	Content.visible = OpenButton.button_pressed

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

func reload_language():
	match Global.language:
		"GER":
			OpenButton.tooltip_text = "öffne weitere Optionen"
			DuplicateButton.tooltip_text = "dupliziere ausgewähltes Rechteck"
			YMirrorButton.tooltip_text = "spiegele ausgewähltes Rechteck an der vertikalen Achse"
			XMirrorButton.tooltip_text = "spiegele ausgewähltes Rechteck an der horizontalen Achse"
			BreakButton.tooltip_text = "zerteile dieses Rechteck in die Bilder unter den anderen Funktionen"
			BreakAllButton.tooltip_text = "wende jede Funktion auf jedes Rechteck einmal an"
		_:
			OpenButton.tooltip_text = "open other options"
			DuplicateButton.tooltip_text = "duplicate selected rectangle"
			YMirrorButton.tooltip_text = "mirror selected rectangle vertically"
			XMirrorButton.tooltip_text = "mirror selected rectangle horizontally"
			BreakButton.tooltip_text = "split selected rectangle into images under all functions"
			BreakAllButton.tooltip_text = "split all rectangles into images under all functions"
