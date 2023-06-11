extends MarginContainer
class_name ResizableRect

const RECT_OFFSET = Vector2(8,8)

var mouse_in = false

# editing

signal focus_me

# buttons
@onready var Content = $Content
@onready var TextureContainer = $Content/TextureContainer
@onready var Outline = $Content/OutlineContainer
@onready var Rect = $Content/TextureContainer/Rect
@onready var TurnButton = $TurnButton

var editing_position = false
var editing_width = false
var editing_height = false
var editing_turn = false

var anchor = Vector2i.ZERO
var rect_origin

func _ready():
	color_rect(Color.BLACK)

func _input(event):
	if self.visible and event is InputEventMouseMotion:
		if editing_position or editing_turn or editing_width or editing_height:
			focus_me.emit()
		if editing_position:
			self.position = event.position - rect_origin
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

func _on_move_button_pressed():
	editing_position = true
	rect_origin = get_viewport().get_mouse_position() - self.position
	focus_me.emit()

# stupid width buttons

func _on_width_button_left_pressed():
	editing_width = true
	anchor.x = -1
	rect_origin = Rect.get_global_position() + Vector2(Rect.size.x, 0)
	focus_me.emit()

func _on_width_button_right_pressed():
	editing_width = true
	anchor.x = 1
	rect_origin = Rect.get_global_position()
	focus_me.emit()

func _on_height_button_up_pressed():
	# actually, this method is useless, because I removed the button, but I like to keeep it
	editing_height = true
	anchor.y = -1
	rect_origin = Rect.get_global_position() + Vector2(0, Rect.size.y)
	focus_me.emit()

func _on_height_button_down_pressed():
	editing_height = true
	anchor.y = 1
	rect_origin = Rect.get_global_position()
	focus_me.emit()

func _on_diag_button_rd_pressed():
	editing_width = true
	editing_height = true
	anchor.x = 1
	anchor.y = 1
	rect_origin = Rect.get_global_position()
	focus_me.emit()

func _on_diag_button_ld_pressed():
	editing_width = true
	editing_height = true
	anchor.x = -1
	anchor.y = 1
	rect_origin = Rect.get_global_position() + Vector2(Rect.size.x, 0).rotated(self.rotation)
	focus_me.emit()

func _on_diag_button_ru_pressed():
	editing_width = true
	editing_height = true
	anchor.x = 1
	anchor.y = -1
	rect_origin = Rect.get_global_position() + Vector2(0, Rect.size.y).rotated(self.rotation)
	focus_me.emit()

func _on_diag_button_lu_pressed():
	editing_width = true
	editing_height = true
	anchor.x = -1
	anchor.y = -1
	rect_origin = Rect.get_global_position() + Vector2(Rect.size.x, Rect.size.y).rotated(self.rotation)
	focus_me.emit()

# turning

func _on_turn_button_pressed():
	editing_turn = true
	rect_origin = position + (size/2).rotated(self.rotation)
	focus_me.emit()

# real functions

func resize_rect(width, height, current_anchor=Vector2i(-1,1)):
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
	var current_rect_origin = (size/2).rotated(self.rotation)
	self.position = rect_origin - current_rect_origin

## focus

func set_focus(enabled):
	for child in Content.get_children():
		if child != TextureContainer:
			child.visible = enabled
	TurnButton.visible = enabled

## colors

func color_rect(color):
	Rect.self_modulate = color

# load contraction

func get_contraction(origin):
	var contraction = Contraction.new()
	contraction.translation = Vector2(
		(self.get_global_position().x - origin.x + 8) / Global.LOUPE.x,
		(self.get_global_position().y - origin.y + 8) / Global.LOUPE.y
	)
	contraction.contract = Vector2(
		self.Rect.size.x / Global.LOUPE.x,
		self.Rect.size.y / Global.LOUPE.y
	)
	contraction.rotation = self.rotation
	contraction.color = self.Rect.self_modulate
	return contraction

# advanced options

func update_to(contr, origin):
	# translation
	var real_position = Vector2(
		contr.translation.x * Global.LOUPE.x,
		contr.translation.y * Global.LOUPE.y
	)
	self.set_global_position( (real_position - Vector2(8,8)) + origin )
	# contraction
	resize_rect(contr.contract.x * Global.LOUPE.x, contr.contract.y * Global.LOUPE.y)
	# rotation
	self.rotation = contr.rotation
	# mirror
	
	# color
	Rect.self_modulate = contr.color
