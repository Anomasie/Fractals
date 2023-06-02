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

func screenshot(pos, size):
	var scr = self.get_viewport().get_texture().get_image()
	var final = scr.get_region(Rect2i(
		pos.x,
		pos.y,
		size.x,
		size.y
	))
	for x in final.get_width():
		for y in final.get_height():
			if final.get_pixel(x,y).get_luminance() > 0.5:
				final.set_pixel(x,y, Color.TRANSPARENT)
	# draw children
	for child in self.get_children():
		if child is MarginContainer:
			child.paint(final)
