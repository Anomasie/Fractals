extends Node2D

var Rect = load("res://scenes/Rect.tscn")

var counter = 0

func add(pos, duplicating=false):
	var Instance = Rect.instantiate()
	Instance.name = "Rect"+str(counter)
	counter += 1
	Instance.position = pos - Vector2(64,64)/2
	Instance.close_me.connect(close.bind(Instance))
	Instance.color_me.connect(color.bind(Instance))
	Instance.focus_me.connect(focus.bind(Instance))
	self.add_child(Instance)
	self.focus(Instance)
	get_parent().focus(Instance)
	if duplicating:
		return Instance

func close_all():
	for child in self.get_children():
		close(child)
	get_parent().focus(null)

func close(MyRect):
	MyRect.queue_free()
	get_parent().focus(null)

func color(MyRect):
	get_parent().color(MyRect)
	get_parent().focus(MyRect)

func duplicate_rect(MyRect, origin):
	# add some child
	var Instance = await add(MyRect.position, true)
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
	close_all()
	# add new buttons
	for contraction in ifs:
		var Instance = await add(origin, true)
		Instance.update_to( contraction, origin )
