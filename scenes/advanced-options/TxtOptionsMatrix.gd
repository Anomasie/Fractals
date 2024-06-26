extends MarginContainer

signal value_changed
signal remove_me
signal duplicate_me

@onready var TranslationX = $Content/Main/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Content/Main/Columns/Main/TranslationBox/TranslationY
@onready var Matrix = $Content/Main/Columns/Main/MatrixBox/Matrix.get_children()
@onready var ColorEdit = $Content/Main/Columns/Main/ColorBox/ColorEdit

@onready var RemoveButton = $Buttons/RemoveButton
@onready var DuplicateButton = $Buttons/DuplicateButton

var disabled = 0

func _ready():
	# connect signals
	for i in len(Matrix):
		Matrix[i].value_changed.connect(_on_matrix_edit_value_changed.bind(i))
	TranslationX.value_changed.connect(_on_translation_edit_value_changed)
	TranslationY.value_changed.connect(_on_translation_edit_value_changed)

func load_matrix(array):
	disabled += 1
	for i in len(Matrix):
		Matrix[i].value = array[i]
	disabled -= 1

func load_ui(contraction):
	# do not emit value_changed
	disabled += 1
	# matrix
	var matrix = contraction.to_matrix()
	for i in len(Matrix):
		Matrix[i].value = matrix[i]
	# translation
	TranslationX.value = contraction.translation.x
	TranslationY.value = contraction.translation.y
	# color
	ColorEdit.text = ""
	ColorEdit.placeholder_text = "#" + contraction.color.to_html()
	# enable value_changed
	disabled -= 1

func read_ui():
	var contraction = Contraction.from_matrix(
		[Matrix[0].value, Matrix[1].value, Matrix[2].value, Matrix[3].value]
	)
	contraction.translation = Vector2(TranslationX.value, TranslationY.value)
	if ColorEdit.text and Color.html_is_valid(ColorEdit.text):
		contraction.color = Color.from_string(ColorEdit.text, contraction.color)
	else:
		contraction.color = Color.from_string(ColorEdit.placeholder_text, Color.BLACK)
	return contraction

func _on_matrix_edit_value_changed(_value, index):
	if disabled == 0:
		disabled += 1
		
		# set to nearest possible matrix
		var matrix = []
		for i in len(Matrix):
			matrix.append(Matrix[i].value)
		matrix = Contraction.nearest_allowed_matrix(matrix, index)
		load_matrix(matrix)
		value_changed.emit()
		
		disabled -= 1

func _on_translation_edit_value_changed(_value):
	if disabled == 0:
		value_changed.emit()

func _on_color_edit_text_submitted(new_text):
	if Color.html_is_valid(new_text):
		ColorEdit.text = ""
		ColorEdit.placeholder_text = new_text
		value_changed.emit()
	else:
		ColorEdit.text = ""

func _on_remove_button_pressed():
	remove_me.emit(self)

func _on_duplicate_button_pressed():
	duplicate_me.emit(self)

# language & translation

func reload_language():
	match Global.language:
		"GER":
			TranslationX.tooltip_text = "Verschiebung entlang der X-Achse"
			TranslationY.tooltip_text = "Verschiebung entlang der Y-Achse"
			for entry in Matrix:
				entry.tooltip_text = "Transformationsmatrix"
			# buttons
			RemoveButton.tooltip_text = "Diese Funktion nlöschen"
			DuplicateButton.tooltip_text = "Diese Funktion duplizieren"
		_:
			TranslationX.tooltip_text = "enter translation in x-axis"
			TranslationY.tooltip_text = "enter translation in y-axis"
			for entry in Matrix:
				entry.tooltip_text = "transformation matrix"
			# buttons
			RemoveButton.tooltip_text = "delete this function"
			DuplicateButton.tooltip_text = "duplicate this function"
