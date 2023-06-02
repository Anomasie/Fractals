extends MarginContainer

signal close_me
signal hidden_ui

@onready var Rect = $TextureContainer/Rect
@onready var rect_image = Rect.get_texture().get_image()

var editing_position = false
var editing_width = false
var editing_height = false
var editing_turn = false

var rect_origin

func _input(event):
	if self.visible and event is InputEventMouseMotion:
		if editing_position:
			self.position = event.position - rect_origin
		elif editing_turn:
			turn_rect((event.position - rect_origin).angle() + size.angle())
		else:
			if editing_width:
				resize_rect((event.position - rect_origin).dot(Vector2(1, 0).rotated(self.rotation)), Rect.custom_minimum_size.y)
			if editing_height:
				resize_rect(Rect.custom_minimum_size.x, (event.position - rect_origin).dot(Vector2(0, 1).rotated(self.rotation)))
	if self.visible and event is InputEventMouseButton and not event.pressed:
		editing_position = false
		editing_width = false
		editing_height = false
		editing_turn = false

func _on_move_button_pressed():
	editing_position = true
	rect_origin = get_viewport().get_mouse_position() - self.position

func _on_width_button_pressed():
	editing_width = true
	rect_origin = Rect.get_global_position()

func _on_height_button_pressed():
	editing_height = true
	rect_origin = Rect.get_global_position()

func _on_diag_button_pressed():
	_on_width_button_pressed()
	_on_height_button_pressed()

func _on_turn_button_pressed():
	editing_turn = true
	rect_origin = position + (size/2).rotated(self.rotation)

func resize_rect(width, height):
	paint(rect_image, width, height)
	if width >= 0:
		Rect.custom_minimum_size.x = width
		self.size.x = width
	if height >= 0:
		Rect.custom_minimum_size.y = height
		self.size.y = height

func turn_rect(turn):
	self.rotation = turn
	var current_rect_origin = (size/2).rotated(self.rotation)
	self.position = rect_origin - current_rect_origin

func _on_close_button_pressed():
	close_me.emit()

func paint(image, width=Rect.size.x, height=Rect.size.y):
	rect_image = image.duplicate()
	image.resize(max(1, width), max(1, height))
	var texture = ImageTexture.create_from_image(image)
	Rect.texture= texture
