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

func get_ifs(origin):
	var ifs = IFS.new()
	# get contractions of ifs
	for child in self.get_children():
		var contraction = Contraction.new()
		contraction.translation = Vector2(
			(child.position.x - origin.x) / Global.LOUPE.x,
			(child.position.y - origin.y) / Global.LOUPE.y
		)
		contraction.contract = Vector2(
			child.Rect.size.x / Global.LOUPE.x,
			child.Rect.size.y / Global.LOUPE.y
		)
		contraction.rotation = child.rotation
		ifs.systems.append(contraction)
	return ifs
