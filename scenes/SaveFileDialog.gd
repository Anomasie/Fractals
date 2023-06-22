extends FileDialog

func _ready():
	print(self.current_dir, ": ", self.current_file, " ! ", self.current_path, " - ", self.current_screen)

func open():
	popup()
	invalidate()
	print(self.current_dir, ": ", self.current_file, " ! ", self.current_path, " - ", self.current_screen)

func close():
	hide()

func _on_file_selected(path):
	get_owner().save(current_path)
