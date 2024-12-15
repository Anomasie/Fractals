@tool
extends MarginContainer

signal pressed

@export var tooltip_ = ""
@export var tooltip_ger = ""

@onready var On = $On
@onready var Off = $Off

@export var on = false

@export var tex_on : AtlasTexture
@export var tex_off : AtlasTexture

var value = true

func _process(_delta):
	if Engine.is_editor_hint() and tex_on and tex_off:
		set_value(bool(on))
		set_textures()

func _ready():
	set_value(bool(on))
	set_textures()
	set_texture_angles()
	Global.tooltip_nodes.append_array([On, Off])

func set_textures():
	On.texture_normal = tex_on.duplicate()
	Off.texture_normal = tex_off.duplicate()

func set_texture_angles():
	var anchor_on = On.texture_normal.region.position.y
	On.texture_hover = tex_on.duplicate()
	On.texture_pressed = tex_on.duplicate()
	On.texture_disabled = tex_on.duplicate()
	On.texture_normal.region = Rect2(0, anchor_on, 32, 32)
	On.texture_hover.region = Rect2(32, anchor_on, 32, 32)
	On.texture_pressed.region = Rect2(64, anchor_on, 32, 32)
	On.texture_disabled.region  = Rect2(96, anchor_on, 32, 32)
	
	var anchor_off = Off.texture_normal.region.position.y
	Off.texture_hover = tex_off.duplicate()
	Off.texture_pressed = tex_off.duplicate()
	Off.texture_disabled = tex_off.duplicate()
	Off.texture_normal.region = Rect2(0, anchor_off, 32, 32)
	Off.texture_hover.region = Rect2(32, anchor_off, 32, 32)
	Off.texture_pressed.region = Rect2(64, anchor_off, 32, 32)
	Off.texture_disabled.region  = Rect2(96, anchor_off, 32, 32)

func set_value(val) -> void:
	On.visible = not val
	Off.visible = val
	value = val

func _on_on_pressed() -> void:
	value = true
	pressed.emit()
	On.hide()
	Off.show()

func _on_off_pressed() -> void:
	value = false
	pressed.emit()
	Off.hide()
	On.show()

func reload_language():
	for node in [On, Off]:
		match Global.language:
			"GER": node.tooltip_text = tooltip_ger
			_: node.tooltip_text = tooltip_
