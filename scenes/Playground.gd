extends Node

signal fractal_changed

var Rect = load("res://scenes/Rect.tscn")

var counter = 0

func _input(event):
	if event.is_action_pressed("scroll_up"):
		focus( self.get_child(0) )
	elif event.is_action_pressed("scroll_down"):
		focus( self.get_child(0) )

func _fractal_changed():
	fractal_changed.emit()

func resize(old_origin, old_loupe, new_origin, _new_loupe):
	for child in self.get_children():
		if child is ResizableRect:
			child.update_to(
				child.get_contraction(old_origin, old_loupe),
				new_origin
			)

func add(pos, duplicating=false):
	var Instance = Rect.instantiate()
	Instance.name = "Rect"+str(counter)
	counter += 1
	Instance.position = pos - Vector2(8,8) - Vector2(0,32)
	Instance.focus_me.connect(focus.bind(Instance))
	Instance.changed.connect(_fractal_changed)
	self.add_child(Instance)
	self.focus(Instance)
	get_parent().focus(Instance)
	if duplicating:
		return Instance
	fractal_changed.emit()

func close_all():
	for child in self.get_children():
		close(child)
	get_parent().focus(null)

func close(MyRect):
	MyRect.queue_free()
	get_parent().focus(null)
	fractal_changed.emit()

func duplicate_rect(MyRect, origin):
	# add some child
	var Instance = await add(MyRect.position, true)
	# update child's values to wanted ones
	Instance.update_to(MyRect.get_contraction(origin), origin + Vector2(8,8))
	fractal_changed.emit()

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
	close_all()
	# add new buttons
	for contraction in ifs:
		var Instance = await add(origin, true)
		Instance.update_to( contraction, origin )
