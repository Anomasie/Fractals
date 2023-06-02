extends Node2D

var Rect = load("res://scenes/Rect.tscn")

func add(pos):
	var Instance = Rect.instantiate()
	Instance.position = pos
	Instance.close_me.connect(close.bind(Instance))
	self.add_child(Instance)

func close_all():
	for child in self.get_children():
		close(child)

func close(MyRect):
	MyRect.queue_free()
