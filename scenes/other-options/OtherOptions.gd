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

func set_disabled(nothing_focused=false, ifs_empty=false) -> void:
	if Content.visible:
		OpenButton.disabled = ifs_empty
	DuplicateButton.disabled = nothing_focused
	YMirrorButton.disabled = nothing_focused
	XMirrorButton.disabled = nothing_focused
	BreakButton.disabled = nothing_focused
	BreakAllButton.disabled = ifs_empty

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
