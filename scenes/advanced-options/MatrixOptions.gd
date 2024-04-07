extends MarginContainer

signal value_changed
signal close_me
signal switch

@onready var TranslationX = $Content/Options/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Content/Options/Columns/Main/TranslationBox/TranslationY
@onready var MatrixEntries = $Content/Options/Columns/Main/MatrixBox/Matrix.get_children()

@onready var CloseButton = $ElseBox/CloseButton
@onready var RotationButton = $ElseBox/RotationButton

var disabled = 0

func _ready():
	for i in len(MatrixEntries):
		MatrixEntries[i].value_changed.connect(_matrix_value_changed.bind(i))
	TranslationX.value_changed.connect(_translation_value_changed)
	TranslationY.value_changed.connect(_translation_value_changed)
	# tooltips
	Global.tooltip_nodes.append_array([
		TranslationX, TranslationY,
		CloseButton, RotationButton
	]+ MatrixEntries)

func _matrix_value_changed(_new_value, index):
	if disabled == 0:
		disabled += 1
		
		# set to nearest possible matrix
		var matrix = []
		for i in len(MatrixEntries):
			matrix.append(MatrixEntries[i].value)
		matrix = Contraction.nearest_allowed_matrix(matrix, index)
		load_matrix(matrix)
		# changed
		value_changed.emit()
		# release focus
		## doesn't work as for now :(
		for button in MatrixEntries:
			button.release_focus()
		TranslationX.release_focus()
		TranslationY.release_focus()
		
		disabled -= 1

func _translation_value_changed(_new_value):
	if disabled == 0:
		# changed
		value_changed.emit()
		# release focus
		## doesn't work as for now :(
		for button in MatrixEntries:
			button.release_focus()
		TranslationX.release_focus()
		TranslationY.release_focus()

func load_matrix(array):
	if typeof(array) != TYPE_ARRAY or len(array) != 4:
		print("ERROR in MatrixOptions, load_matrix: ", array, " is not an array of length 4")
		return
	# set values
	for i in len(array):
		MatrixEntries[i].value = array[i]

func load_ui(contraction):
	# do not emit value_changed
	disabled += 1
	# matrix
	var matrix = contraction.to_matrix()
	for i in len(matrix):
		MatrixEntries[i].value = matrix[i]
	# translation
	TranslationX.value = contraction.translation.x
	TranslationY.value = contraction.translation.y
	# enable value_changed
	disabled -= 1

func read_ui():
	var contraction = Contraction.from_matrix([
		MatrixEntries[0].value, MatrixEntries[1].value,
		MatrixEntries[2].value, MatrixEntries[3].value
	])
	contraction.translation = Vector2(TranslationX.value, TranslationY.value)
	return contraction

func _on_close_button_pressed():
	close_me.emit()

func _on_rotation_button_pressed():
	switch.emit()

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
