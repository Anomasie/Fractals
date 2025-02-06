extends MarginContainer

signal close_me
signal switch

signal t_x_changed
signal t_y_changed
signal matrix_changed

@onready var TranslationX = $Content/Options/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Content/Options/Columns/Main/TranslationBox/TranslationY
@onready var MatrixEntries = $Content/Options/Columns/Main/MatrixBox/Matrix.get_children()

@onready var CloseButton = $ElseBox/CloseButton
@onready var RotationButton = $ElseBox/RotationButton

var disabled = 0

func _ready():
	for i in len(MatrixEntries):
		MatrixEntries[i].text_submitted.connect(_matrix_value_changed.bind(i))
	# tooltips
	Global.tooltip_nodes.append_array([
		TranslationX, TranslationY,
		CloseButton, RotationButton
	]+ MatrixEntries)

func load_matrix(array):
	if typeof(array) != TYPE_ARRAY or len(array) != 4:
		print("ERROR in MatrixOptions, load_matrix: ", array, " is not an array of length 4")
		return
	# set values
	for i in len(array):
		MatrixEntries[i].placeholder_text = str(array[i])

func compare_and_set(node, values):
	if values.max() - values.min() < 0.0001:
		node.placeholder_text = str(values[0])
	else:
		node.placeholder_text = ""

func compare_and_set_matrix(matrices):
	for i in len(MatrixEntries): # 4 times
		var list = []
		for entry in matrices:
			list.append(entry[i])
		if list.max() - list.min() < 0.0001:
			MatrixEntries[i].placeholder_text = str(list[0])
		else:
			MatrixEntries[i].placeholder_text = ""

func load_ui_of_list(contractions):
	disabled += 1
	# set values
	var list_x = []
	var list_y = []
	var list = []
	for entry in contractions:
		list_x.append(entry.translation.x)
		list_y.append(entry.translation.y)
		list.append(entry.to_matrix())
	compare_and_set(TranslationX, list_x)
	compare_and_set(TranslationY, list_y)
	compare_and_set_matrix(list)
	# disable
	disabled -= 1

func load_ui_of_one(contraction):
	# do not emit value_changed
	disabled += 1
	# matrix
	var matrix = contraction.to_matrix()
	for i in len(matrix):
		MatrixEntries[i].text = str(matrix[i])
	# translation
	TranslationX.text = str(contraction.translation.x)
	TranslationY.text = str(contraction.translation.y)
	# enable value_changed
	disabled -= 1

func load_ui(object):
	if len(object) == 0:
		load_ui_of_one(object[0])
	else:
		load_ui_of_list(object)

func _on_close_button_pressed():
	close_me.emit()

func _on_rotation_button_pressed():
	switch.emit()

# values changed

func text_to_translation_value(text):
	var value = float(text)
	if value < -1:
		value = -1
	elif value > 2:
		value = 2
	return value

func _on_translation_x_text_submitted(new_text: String) -> void:
	if new_text:
		var value = text_to_translation_value(new_text)
		TranslationX.placeholder_text = str(value)
		TranslationX.text = ""
		t_x_changed.emit(value)
	TranslationX.release_focus()

func _on_translation_y_text_submitted(new_text: String) -> void:
	if new_text:
		var value = text_to_translation_value(new_text)
		TranslationY.placeholder_text = str(value)
		TranslationY.text = ""
		t_y_changed.emit(value)
	TranslationY.release_focus()

func text_to_matrix_value(text):
	var value = float(text)
	if value < -1:
		value = -1
	elif value > 1:
		value = 1
	return value

func _matrix_value_changed(new_value, index):
	if new_value and disabled == 0:
		disabled += 1
		
		var matrix = []
		for i in len(MatrixEntries):
			if MatrixEntries[i].text:
				matrix.append(float(MatrixEntries[i].text))
			else:
				matrix.append(float(MatrixEntries[i].placeholder_text))
		matrix = Contraction.nearest_allowed_matrix(matrix, index)
		print("new matrix: ", matrix)
#		# set to nearest possible matrix
#		var matrix = []
#		for i in len(MatrixEntries):
#			matrix.append(text_to_matrix_value(MatrixEntries[i].text))
#			MatrixEntries[i].text = ""
#		matrix = Contraction.nearest_allowed_matrix(matrix, index)
		load_matrix(matrix)
		# changed
		matrix_changed.emit(matrix)
		# release focus
		for i in len(MatrixEntries):
			MatrixEntries[i].placeholder_text = str(matrix[i])
			MatrixEntries[i].text = ""
			MatrixEntries[i].release_focus()
		
		disabled -= 1

# language & translation

func reload_language():
	match Global.language:
		"GER":
			TranslationX.tooltip_text = "Verschiebung entlang der X-Achse"
			TranslationY.tooltip_text = "Verschiebung entlang der Y-Achse"
			for entry in MatrixEntries:
				entry.tooltip_text = "Transformationsmatrix"
			# buttons
			CloseButton.tooltip_text = "Matrix-Optionen schließen"
			RotationButton.tooltip_text = "geometrische Ansicht"
		_:
			TranslationX.tooltip_text = "enter translation in x-axis"
			TranslationY.tooltip_text = "enter translation in y-axis"
			for entry in MatrixEntries:
				entry.tooltip_text = "transformation matrix"
			# buttons
			CloseButton.tooltip_text = "close matrix options"
			RotationButton.tooltip_text = "switch to geometric view"
