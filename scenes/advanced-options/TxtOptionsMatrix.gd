extends MarginContainer

signal value_changed
signal remove_me
signal duplicate_me

@onready var TranslationX = $Content/Main/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Content/Main/Columns/Main/TranslationBox/TranslationY
@onready var Matrix = $Content/Main/Columns/Main/MatrixBox/Matrix.get_children()
@onready var ColorEdit = $Content/Main/Columns/Main/ColorBox/ColorEdit

var disabled = 0

func _ready():
	# connect signals
	for node in [TranslationX, TranslationY] + Matrix:
		node.value_changed.connect(_on_edit_value_changed)

func load_ui(contraction):
	# do not emit value_changed
	disabled += 1
	# matrix
	var matrix = contraction.to_matrix()
	Matrix[0].value = matrix[0]
	Matrix[1].value = matrix[1]
	Matrix[2].value = matrix[2]
	Matrix[3].value = matrix[3]
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

func _on_edit_value_changed(_value = 0):
	if disabled == 0:
		value_changed.emit()

func _on_color_edit_text_submitted(new_text):
	if Color.html_is_valid(new_text):
		ColorEdit.text = ""
		ColorEdit.placeholder_text = new_text
		_on_edit_value_changed()
	else:
		ColorEdit.text = ""


func _on_remove_button_pressed():
	remove_me.emit(self)

func _on_duplicate_button_pressed():
	duplicate_me.emit(self)
