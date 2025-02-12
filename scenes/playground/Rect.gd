extends MarginContainer
class_name ResizableRect

const RECT_OFFSET = Vector2(8,8)

var mouse_in = false

# editing

signal focus_me
@warning_ignore("unused_signal")
signal defocus_others # is connected by Playground
signal changed
signal changed_vastly

signal start_editing_position
signal start_editing_rotation

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
var editing_rotation = false

var edited_position = false

var anchor = Vector2i(1,1)
var rect_origin
var center_origin
var rotation_offset = 0

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
		if editing_position or editing_rotation or editing_width or editing_height:
			if not editing_position and not editing_rotation:
				focus_me.emit()
			changed.emit()
		if editing_position:
			edited_position = true
			self.set_global_position(event.position - rect_origin)
		elif editing_rotation:
			rotate_rect((event.position - center_origin).angle() + PI / 2 + rotation_offset)
		else:
			if editing_width:
				resize_rect((event.position - rect_origin).dot( (anchor.x * Vector2(1, 0)).rotated(self.rotation) ), Rect.custom_minimum_size.y, anchor)
			if editing_height:
				resize_rect(Rect.custom_minimum_size.x, (event.position - rect_origin).dot( (anchor.y * Vector2(0, 1) ).rotated(self.rotation) ), anchor)
	if self.visible and event is InputEventMouseButton and not event.pressed:
		if editing_position or editing_width or editing_height or editing_rotation:
			if not editing_position or editing_position and edited_position:
				changed_vastly.emit()
			editing_position = false
			edited_position = false
			editing_width = false
			editing_height = false
			editing_rotation = false
			for button in [WidthButtonR, WidthButtonL, HeightButtonD, DiagButtonLD, DiagButtonLU, DiagButtonRD, DiagButtonRU, TurnButton]:
				button.disabled = false

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

func rotate_rect(turn, new_origin = false):
	if new_origin or not rect_origin:
		if new_origin is Vector2:
			rect_origin = new_origin
		else:
			rect_origin = self.get_global_position() + (TextureContainer.position + TextureContainer.size/2).rotated(self.rotation)
	# rotate!
	self.rotation = turn
	var current_rect_origin = (TextureContainer.position + TextureContainer.size/2).rotated(self.rotation)
	self.set_global_position(rect_origin - current_rect_origin)

## colors

func color_rect(color):
	Rect.self_modulate = color
	if color.get_luminance() < 0.5:
		Maske.self_modulate = Color.WHITE
	else:
		Maske.self_modulate = Color.BLACK

# get functions

func get_center() -> Vector2:
	return self.get_global_position() + (TextureContainer.position + TextureContainer.size/2).rotated(self.rotation)

func get_corner(upper=true, left=true, origin=Vector2.ZERO) -> Vector2:
	var offset = Vector2.ZERO
	if (TextureContainer.position + Rect.position).length() == 0:
		offset = Vector2(8,8) + Vector2(0,32)
	else:
		offset = TextureContainer.position + Rect.position
	
	if not upper:
		offset += Vector2(0, self.Rect.size.y)
	if not left:
		offset += Vector2(self.Rect.size.x, 0)
	
	return self.get_global_position() - origin + (offset).rotated(self.rotation)

func get_color():
	return Rect.self_modulate

func get_contraction(origin, loupe = Global.LOUPE):
	var contraction = Contraction.new()
	var translation = get_corner(false, true, origin)
	translation.x /= loupe.x
	translation.y /= loupe.y
	
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
	contraction.translation = translation# + Vector2(0, contraction.contract.y).rotated(contraction.rotation)
	contraction.translation.y *= -1
	# if mirrored: change anchor to bottom-right point
	if contraction.mirrored:
		contraction.translation += Vector2(contraction.contract.x, 0).rotated(-contraction.rotation)
	
	# color
	contraction.color = self.Rect.self_modulate
	return contraction

func get_region() -> Rect2:
	return Rect2(
		get_corner(true, true),
		Vector2.ZERO).expand(
			get_corner(true, false)
		).expand(
			get_corner(false, true)
		).expand(
			get_corner(false, false)
	)

# set functions

func set_focus(enabled=true):
	for child in Content.get_children():
		if child != TextureContainer:
			child.visible = enabled
	TurnButton.visible = enabled

func is_focused() -> bool:
	return TurnButton.visible

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

# signals

func _on_move_button_button_down():
	if is_focused():
		start_editing_position.emit()
	else:
		focus_me.emit()
		set_editing_position()

func _on_move_button_button_up() -> void:
	if has_focus():
		focus_me.emit()

func set_editing_position():
	editing_position = true
	rect_origin = get_viewport().get_mouse_position() - self.get_global_position()

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
	start_editing_rotation.emit(get_center(), self.rotation)

func set_editing_rotation(origin, origin_rotation, value=true):
	editing_rotation = value
	TurnButton.disabled = value
	if value:
		rect_origin = get_center()
		center_origin = origin
		# get rotation offset (in case that it is not the emitting rectangle:
		rotation_offset = self.rotation - origin_rotation

func _on_mirror_button_pressed():
	mirror()
	changed.emit()
	changed_vastly.emit()
	focus_me.emit()

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
