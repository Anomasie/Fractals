extends FileDialog

signal path_selected

func open():
	popup()
	invalidate() # it was supposed to help fixing a bug, but I am not sure what it does
	# but everyone seems to recommend it, so I guess I'll leave it in

func close():
	hide()

func _on_file_selected(path):
	path_selected.emit(path)
