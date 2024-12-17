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

@export var reverse_textures = true

func _process(_delta):
	if Engine.is_editor_hint() and tex_on and tex_off:
		set_value(bool(on))
		set_textures()

func _ready():
	set_value(bool(on))
	set_textures()
	set_texture_angles()
	if not Engine.is_editor_hint():
		Global.add_to_tooltip_nodes([On, Off])

func set_textures():
	if not reverse_textures:
		On.texture_normal = tex_on.duplicate()
		Off.texture_normal = tex_off.duplicate()
	else:
		On.texture_normal = tex_off.duplicate()
		Off.texture_normal = tex_on.duplicate()

func set_texture_angles():
	var anchor_on = On.texture_normal.region.position.y
	On.texture_hover = On.texture_normal.duplicate()
	On.texture_pressed = On.texture_normal.duplicate()
	On.texture_disabled = On.texture_normal.duplicate()
	On.texture_normal.region = Rect2(0, anchor_on, 32, 32)
	On.texture_hover.region = Rect2(32, anchor_on, 32, 32)
	On.texture_pressed.region = Rect2(64, anchor_on, 32, 32)
	On.texture_disabled.region  = Rect2(96, anchor_on, 32, 32)
	
	var anchor_off = Off.texture_normal.region.position.y
	Off.texture_hover = Off.texture_normal.duplicate()
	Off.texture_pressed = Off.texture_normal.duplicate()
	Off.texture_disabled = Off.texture_normal.duplicate()
	Off.texture_normal.region = Rect2(0, anchor_off, 32, 32)
	Off.texture_hover.region = Rect2(32, anchor_off, 32, 32)
	Off.texture_pressed.region = Rect2(64, anchor_off, 32, 32)
	Off.texture_disabled.region  = Rect2(96, anchor_off, 32, 32)

func set_value(val) -> void:
	On.visible = not val
	Off.visible = val
	on = val

func _on_on_pressed() -> void:
	on = true
	pressed.emit()
	On.hide()
	Off.show()

func _on_off_pressed() -> void:
	on = false
	pressed.emit()
	Off.hide()
	On.show()

func reload_language():
	for node in [On, Off]:
		match Global.language:
			"GER": node.tooltip_text = tooltip_ger
			_: node.tooltip_text = tooltip_
