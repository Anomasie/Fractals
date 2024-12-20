extends Node

signal fractal_changed

var Rect = load("res://scenes/playground/Rect.tscn")

var current_rect_counter = 0
var counter = 0

var emit_fractal_changed_next_frame = false

@onready var TxTOptions # to disable scrolling if they are visible

func _process(_delta):
	if emit_fractal_changed_next_frame:
		fractal_changed.emit()
		emit_fractal_changed_next_frame = false

func _input(event):
	if current_rect_counter > 0:
		if not TxTOptions.visible:
			if event.is_action_pressed("scroll_up"):
				focus( self.get_child(0) )
			elif event.is_action_pressed("scroll_down"):
				focus( self.get_child(0) )

func _fractal_changed():
	emit_fractal_changed_next_frame = true

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
	current_rect_counter += 1
	
	Instance.focus_me.connect(focus.bind(Instance))
	Instance.changed.connect(_fractal_changed)
	self.add_child(Instance)
	Instance.update_to(contr, origin)
	self.focus(Instance)
	get_parent().focus(Instance)
	
	if emit_fractal_changed:
		emit_fractal_changed_next_frame = true
	
	if duplicating:
		return Instance

func close_all(emit_fractal_changed=true):
	for child in self.get_children():
		close(child, emit_fractal_changed)
	get_parent().focus(null)
	
	current_rect_counter = 0 # just for savety

func close(MyRect, emit_fractal_changed=true):
	MyRect.queue_free()
	get_parent().focus(null)
	if emit_fractal_changed:
		emit_fractal_changed_next_frame = true
	
	current_rect_counter -= 1

func duplicate_rect(MyRect, origin):
	# add some child
	var Instance = await add(Vector2.ZERO, origin, true)
	# update child's values to wanted ones
	Instance.update_to(MyRect.get_contraction(origin), origin + Vector2(8,8))

func focus(MyRect):
	self.move_child(MyRect, -1)
	for child in self.get_children():
		child.set_focus(false)
	MyRect.set_focus(true)
	get_parent().focus(MyRect)

func get_ifs(origin):
	var ifs = IFS.new()
	# get contractions of ifs
	for child in self.get_children():
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

# language & translation

func reload_language():
	for child in self.get_children():
		child.reload_language()
