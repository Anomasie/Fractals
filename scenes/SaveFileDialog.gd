extends FileDialog

func open():
	popup()
	invalidate() # it was supposed to help fixing a bug, but I am not sure what it does
	# but everyone seems to recommend it, so I guess I'll leave it in

func close():
	hide()

func _on_file_selected(_path):
	get_owner().save(current_path)
