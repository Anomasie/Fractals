extends Node

signal fractal_changed
signal fractal_changed_vastly

signal focus_this
signal defocus

signal start_editing_position
signal start_editing_rotation
signal resize_focused
signal mirror_focused

signal edited_position

var Rect = load("res://scenes/playground/Rect.tscn")

var rect_counter = 0
var counter = 0

var emit_fractal_changed_next_frame = false

var editing_position = false
var editing_rotation = false
var editing_width = false

@onready var TxTOptions # to disable scrolling if they are visible

func _process(_delta):
	if emit_fractal_changed_next_frame:
		fractal_changed.emit()
		emit_fractal_changed_next_frame = false

func _input(event):
	if rect_counter > 0:
		if not TxTOptions.visible:
			if event.is_action_pressed("scroll_up"):
				focus_only( self.get_child(0) )
			elif event.is_action_pressed("scroll_down"):
				focus_only( self.get_child(0) )
	if editing_position and event is InputEventMouseMotion:
		edited_position.emit()
	if event is InputEventMouseButton and not event.pressed:
		editing_position = false

func _fractal_changed():
	emit_fractal_changed_next_frame = true

func _fractal_changed_vastly():
	fractal_changed_vastly.emit()

func resize(old_origin, old_loupe, new_origin, _new_loupe):
	for child in self.get_children():
		if child is ResizableRect:
			child.update_to(
				child.get_contraction(old_origin, old_loupe),
				new_origin
			)

func add(pos, origin, duplicating=false, emit_fractal_changed=true):
	var Instance = Rect.instantiate()
	Instance.name = "Rect"+str(counter)
	counter += 1
	# set ifs information for child
	var contr = Contraction.new()
	contr.translation = pos
	contr.contract = Vector2(0.25,0.25)
	rect_counter += 1
	
	Instance.focus_me.connect(focus_only.bind(Instance))
	Instance.defocus_others.connect(focus_only.bind(Instance))
	Instance.start_editing_position.connect(_on_rect_start_editing_position)
	Instance.start_editing_rotation.connect(_on_rect_start_editing_rotation)
	Instance.resize_focused.connect(_on_rect_resize_focused)
	Instance.mirror_focused.connect(_on_rect_mirror_focused)
	Instance.changed.connect(_fractal_changed)
	Instance.changed_vastly.connect(_fractal_changed_vastly)
	self.add_child(Instance)
	Instance.update_to(contr, origin)
	self.focus_only(Instance)
	focus_this.emit(Instance)
	
	if emit_fractal_changed:
		emit_fractal_changed_next_frame = true
	
	if duplicating:
		return Instance

func close_all(emit_fractal_changed=true):
	for child in self.get_children():
		if child is ResizableRect:
			close(child, emit_fractal_changed)
	defocus.emit()
	
	rect_counter = 0 # just for savety

func close(MyRect, emit_fractal_changed=true):
	if typeof(MyRect) == TYPE_ARRAY:
		for child in MyRect:
			close(child)
	else:
		MyRect.queue_free()
		defocus.emit()
		if emit_fractal_changed:
			emit_fractal_changed_next_frame = true
		rect_counter -= 1

func duplicate_rect(MyRect, origin):
	# add some child
	var Instance = await add(Vector2.ZERO, origin, true)
	# update child's values to wanted ones
	Instance.update_to(MyRect.get_contraction(origin), origin + Vector2(8,8))

# focus

func focus(MyRects):
	for child in self.get_children():
		if child is ResizableRect:
			child.set_focus( child in MyRects )

func focus_only(MyRect):
	self.move_child(MyRect, -1)
	for child in self.get_children():
		if child is ResizableRect:
			child.set_focus(false)
	MyRect.set_focus(true)
	focus_this.emit(MyRect)

func _on_rect_start_editing_position():
	start_editing_position.emit()
	editing_position = true

func _on_rect_start_editing_rotation(origin, origin_rotation):
	start_editing_rotation.emit(origin, origin_rotation)
	editing_rotation = true

func _on_rect_resize_focused(width, height, anchor):
	resize_focused.emit(width, height, anchor)

func _on_rect_mirror_focused():
	mirror_focused.emit()

# get & set

func get_ifs(origin):
	var ifs = IFS.new()
	# get contractions of ifs
	for child in self.get_children():
		if child is ResizableRect:
			var contraction = child.get_contraction(origin)
			ifs.systems.append(contraction)
	return ifs

func set_ifs(ifs, origin):
	# remove all buttons
	close_all(false)
	# add new buttons
	for contraction in ifs.systems:
		var Instance = add(origin, origin, true, false)
		Instance.update_to( contraction, origin )

func get_rects_in_region(rect):
	var list = []
	for child in self.get_children():
		if child is ResizableRect:
			if rect.encloses(child.get_region()):
				list.append(child)
	return list

# language & translation

func reload_language():
	for child in self.get_children():
		if child is ResizableRect:
			child.reload_language()
