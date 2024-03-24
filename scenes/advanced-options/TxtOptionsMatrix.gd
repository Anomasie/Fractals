extends MarginContainer

signal value_changed

@onready var TranslationX = $Main/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Main/Columns/Main/TranslationBox/TranslationY
@onready var Matrix = $Main/Columns/Main/MatrixBox/Matrix.get_children()
@onready var ColorEdit = $Main/Columns/Main/ColorBox/ColorEdit

var disabled = 0

func _ready():
	# connect signals
	for node in [TranslationX, TranslationY] + Matrix:
		node.value_changed.connect(_on_edit_value_changed)

func load_ui(dict):
	disabled += 1
	
	TranslationX.value = float(dict["translation"][0])
	TranslationY.value = float(dict["translation"][1])
	for i in 4:
		Matrix[i].value = float(dict["matrix"][i])
	ColorEdit.placeholder_text = str(dict["color"])
	ColorEdit.text = ""
	
	disabled -= 1

func read_ui():
	var contraction = Contraction.from_matrix(
		[Matrix[0].value, Matrix[1].value, Matrix[2].value, Matrix[3].value]
	)
	contraction.translation = Vector2(TranslationX.value, TranslationY.value)
	if contraction.mirrored:
		contraction.translation -= Vector2(contraction.contract.x, 0).rotated(-contraction.rotation)
	contraction.color = Color.from_string(ColorEdit.text, contraction.color)
	return contraction

func _on_edit_value_changed(_value = 0):
	if disabled == 0:
		value_changed.emit()
