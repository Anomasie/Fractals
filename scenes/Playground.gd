extends Node2D

var Rect = load("res://scenes/Rect.tscn")

var counter = 0

func add(pos):
	var Instance = Rect.instantiate()
	Instance.name = "Rect"+str(counter)
	counter += 1
	Instance.position = pos - Vector2(64,64)/2
	Instance.close_me.connect(close.bind(Instance))
	Instance.color_me.connect(color.bind(Instance))
	Instance.focus_me.connect(focus.bind(Instance))
	self.add_child(Instance)
	get_parent().focus(Instance)

func close_all():
	for child in self.get_children():
		close(child)
	get_parent().focus(null)

func close(MyRect):
	MyRect.queue_free()
	if self.get_child_count() <= 1:
		get_parent().focus(null)
	else:
		get_parent().focus(self.get_child(0))

func color(MyRect):
	get_parent().color(MyRect)
	get_parent().focus(MyRect)

func focus(MyRect):
	self.move_child(MyRect, -1)
	get_parent().focus(MyRect)

func get_ifs(origin):
	var ifs = IFS.new()
	# get contractions of ifs
	for child in self.get_children():
		var contraction = child.get_contraction(origin)
		ifs.systems.append(contraction)
	return ifs
