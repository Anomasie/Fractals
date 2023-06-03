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

func close_all():
	for child in self.get_children():
		close(child)

func close(MyRect):
	MyRect.queue_free()

func color(MyRect):
	get_parent().color(MyRect)

func focus(MyRect):
	self.move_child(MyRect, -1)

func get_ifs(origin):
	var ifs = IFS.new()
	# get contractions of ifs
	for child in self.get_children():
		var contraction = Contraction.new()
		contraction.translation = Vector2(
			(child.Rect.get_global_position().x - origin.x) / Global.LOUPE.x,
			(child.Rect.get_global_position().y - origin.y) / Global.LOUPE.y
		)
		contraction.contract = Vector2(
			child.Rect.size.x / Global.LOUPE.x,
			child.Rect.size.y / Global.LOUPE.y
		)
		contraction.rotation = child.rotation
		contraction.color = child.Rect.self_modulate
		ifs.systems.append(contraction)
	return ifs
