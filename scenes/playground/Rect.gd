extends MarginContainer
class_name ResizableRect

const RECT_OFFSET = Vector2(8,8)

var mouse_in = false

# editing

signal focus_me
signal changed

# buttons
@onready var MoveButton = $Content/TextureContainer/MoveButton
@onready var WidthButtonR = $Content/WidthButtonRight
@onready var WidthButtonL = $Content/WidthButtonLeft
@onready var HeightButtonD = $Content/HeightButtonDown
@onready var DiagButtonRD = $Content/DiagButtonRD
@onready var DiagButtonLD = $Content/DiagButtonLD
@onready var DiagButtonRU = $Content/DiagButtonRU
@onready var DiagButtonLU = $Content/DiagButtonLU
@onready var MirrorButton = $Content/MirrorButton

@onready var Content = $Content
@onready var TextureContainer = $Content/TextureContainer
@onready var Outline = $Content/OutlineContainer
@onready var Rect = $Content/TextureContainer/Rect
@onready var Maske = $Content/TextureContainer/Maske
@onready var TurnButton = $TurnButton

var editing_position = false
var editing_width = false
var editing_height = false
var editing_turn = false

var anchor = Vector2i(1,1)
var rect_origin

var disabled = 0

func _ready():
	color_rect(Color.BLACK)
	reload_language()
	
	# tooltips
	Global.add_to_tooltip_nodes([
		MoveButton, WidthButtonR, WidthButtonL, HeightButtonD,
		DiagButtonLD, DiagButtonLU, DiagButtonRD, DiagButtonRU,
		MirrorButton, TurnButton,
		Outline])

func _input(event):
	if self.visible and event is InputEventMouseMotion:
		if editing_position or editing_turn or editing_width or editing_height:
			focus_me.emit()
			changed.emit()
		if editing_position:
			self.set_global_position(event.position - rect_origin)
		elif editing_turn:
			turn_rect((event.position - rect_origin).angle() + PI / 2)
		else:
			if editing_width:
				resize_rect((event.position - rect_origin).dot( (anchor.x * Vector2(1, 0)).rotated(self.rotation) ), Rect.custom_minimum_size.y, anchor)
			if editing_height:
				resize_rect(Rect.custom_minimum_size.x, (event.position - rect_origin).dot( (anchor.y * Vector2(0, 1) ).rotated(self.rotation) ), anchor)
	if self.visible and event is InputEventMouseButton and not event.pressed:
			editing_position = false
			editing_width = false
			editing_height = false
			editing_turn = false
			for button in [WidthButtonR, WidthButtonL, HeightButtonD, DiagButtonLD, DiagButtonLU, DiagButtonRD, DiagButtonRU, TurnButton]:
				button.disabled = false

func _on_move_button_pressed():
	editing_position = true
	rect_origin = get_viewport().get_mouse_position() - self.get_global_position()
	focus_me.emit()

# stupid width buttons

func _on_width_button_left_pressed():
	editing_width = true
	WidthButtonL.disabled = true
	anchor.x = -1
	rect_origin = Rect.get_global_position() + Vector2(Rect.size.x, 0).rotated(self.rotation)
	focus_me.emit()

func _on_width_button_right_pressed():
	editing_width = true
	WidthButtonR.disabled = true
	anchor.x = 1
	rect_origin = Rect.get_global_position()
	focus_me.emit()

# this function is useless, because I removed the button, but I like to keeep it anyway
func _on_height_button_up_pressed():
	editing_height = true
	anchor.y = -1
	rect_origin = Rect.get_global_position() + Vector2(0, Rect.size.y)
	focus_me.emit()

func _on_height_button_down_pressed():
	editing_height = true
	HeightButtonD.disabled = true
	anchor.y = 1
	rect_origin = Rect.get_global_position()
	focus_me.emit()

func _on_diag_button_rd_pressed():
	editing_width = true
	editing_height = true
	DiagButtonRD.disabled = true
	anchor.x = 1
	anchor.y = 1
	rect_origin = Rect.get_global_position()
	focus_me.emit()

func _on_diag_button_ld_pressed():
	editing_width = true
	editing_height = true
	DiagButtonLD.disabled = true
	anchor.x = -1
	anchor.y = 1
	rect_origin = Rect.get_global_position() + Vector2(Rect.size.x, 0).rotated(self.rotation)
	focus_me.emit()

func _on_diag_button_ru_pressed():
	editing_width = true
	editing_height = true
	DiagButtonRU.disabled = true
	anchor.x = 1
	anchor.y = -1
	rect_origin = Rect.get_global_position() + Vector2(0, Rect.size.y).rotated(self.rotation)
	focus_me.emit()

func _on_diag_button_lu_pressed():
	editing_width = true
	editing_height = true
	DiagButtonLU.disabled = true
	anchor.x = -1
	anchor.y = -1
	rect_origin = Rect.get_global_position() + Vector2(Rect.size.x, Rect.size.y).rotated(self.rotation)
	focus_me.emit()

# turning

func _on_turn_button_pressed():
	editing_turn = true
	TurnButton.disabled = true
	rect_origin = self.get_global_position() + (TextureContainer.position + TextureContainer.size/2).rotated(self.rotation)
	focus_me.emit()

func _on_mirror_button_pressed():
	mirror()
	changed.emit()
	focus_me.emit()

# "important" functions

func mirror():
	Maske.flip_h = not Maske.flip_h

func resize_rect(width, height, current_anchor=Vector2i(1,1)):
	var old_size = self.size
	# prevent rect from being negative sized
	# or too big (i.e. not a contraction)
	width = max(min(width, Global.LOUPE.x-1), 0)
	height = max(min(height, Global.LOUPE.y-1), 0)
	# change size
	Rect.custom_minimum_size.x = width
	self.size.x = width
	Rect.custom_minimum_size.y = height
	self.size.y = height
	# change position
	if current_anchor.x < 0:
		self.position -= Vector2((self.size - old_size).x, 0).rotated(self.rotation)
	if current_anchor.y < 0:
		self.position -= Vector2(0, (self.size - old_size).y).rotated(self.rotation)

func turn_rect(turn):
	self.rotation = turn
	var current_rect_origin = (TextureContainer.position + TextureContainer.size/2).rotated(self.rotation)
	self.set_global_position(rect_origin - current_rect_origin)

## focus

func set_focus(enabled):
	for child in Content.get_children():
		if child != TextureContainer:
			child.visible = enabled
	TurnButton.visible = enabled

## colors

func get_color():
	return Rect.self_modulate

func color_rect(color):
	Rect.self_modulate = color
	if color.get_luminance() < 0.5:
		Maske.self_modulate = Color.WHITE
	else:
		Maske.self_modulate = Color.BLACK

# load contraction

func get_contraction(origin, loupe = Global.LOUPE):
	var contraction = Contraction.new()
	
	var translation = Vector2.ZERO
	if (TextureContainer.position + Rect.position).length() == 0:
		translation = Vector2(
			(self.get_global_position().x - origin.x + (Vector2(8,8) + Vector2(0,32)).rotated(self.rotation).x) / loupe.x,
			(self.get_global_position().y - origin.y + (Vector2(8,8) + Vector2(0,32)).rotated(self.rotation).y) / loupe.y
		)
	else:
		translation = Vector2(
			(self.get_global_position().x - origin.x + (TextureContainer.position + Rect.position).rotated(self.rotation).x) / loupe.x,
			(self.get_global_position().y - origin.y + (TextureContainer.position + Rect.position).rotated(self.rotation).y) / loupe.y
		)
	
	# contract
	contraction.contract = Vector2(
		self.Rect.size.x / loupe.x,
		self.Rect.size.y / loupe.y
	)
	
	# rotation
	contraction.rotation = self.rotation
	
	# mirror
	contraction.mirrored = Maske.flip_h
	
	# current translation: position of top-left-edge
	## wanted translation: position of bottom-left-edge
	contraction.translation = translation + Vector2(0, contraction.contract.y).rotated(contraction.rotation)
	contraction.translation.y *= -1
	# if mirrored: change anchor to bottom-right point
	if contraction.mirrored:
		contraction.translation += Vector2(contraction.contract.x, 0).rotated(-contraction.rotation)
	
	# color
	contraction.color = self.Rect.self_modulate
	return contraction

# advanced options

func update_to(contr, origin):
	var translation = Vector2.ZERO
	if contr.mirrored:
		translation = contr.apply(Vector2(1,0))
	else:
		translation = contr.translation
	# translation
	var scaled_position = Vector2(
		translation.x * Global.LOUPE.x,
		-translation.y * Global.LOUPE.y
	)
	var real_position
	# not loaded
	if (TextureContainer.position + Rect.position).length() == 0:
		real_position = scaled_position + origin - (Vector2(8,8) + Vector2(0,32)).rotated(contr.rotation)
	# positions loaded
	else:
		real_position = scaled_position + origin - (TextureContainer.position + Rect.position).rotated(contr.rotation)
	# contraction
	resize_rect(contr.contract.x * Global.LOUPE.x, contr.contract.y * Global.LOUPE.y)
	# rotation
	self.rotation = contr.rotation
	# current position: just scaled
	## origin: bottom-left-edge
	## but we want the origin to be the top-left-edge
	self.set_global_position(real_position + Vector2(0, -Rect.custom_minimum_size.y).rotated(self.rotation))
	# mirror
	Maske.flip_h = contr.mirrored
	#if contr.mirrored:
		#self.position -= Vector2(size.x, 0).rotated(self.rotation)
	# color
	color_rect(contr.color)
	
	#changed.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			Outline.tooltip_text = "dieses Rechteck ist ausgewählt"
			MoveButton.tooltip_text = "bewege das Rechteck, indem du klickst und ziehst"
			for button in [WidthButtonR, WidthButtonL, HeightButtonD, DiagButtonLD, DiagButtonLU, DiagButtonRD, DiagButtonRU]:
				button.tooltip_text = "vergrößern oder verkleinern"
			TurnButton.tooltip_text = "rotieren"
		_:
			Outline.tooltip_text = "this rectangle is selected"
			MoveButton.tooltip_text = "move by dragging and dropping"
			for button in [WidthButtonR, WidthButtonL, HeightButtonD, DiagButtonLD, DiagButtonLU, DiagButtonRD, DiagButtonRU]:
				button.tooltip_text = "shrink or expand"
			TurnButton.tooltip_text = "rotate"
