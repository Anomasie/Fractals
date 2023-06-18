extends HBoxContainer

signal value_changed
signal close_me
signal switch

@onready var TranslationX = $Main/TranslationBox/TranslationX
@onready var TranslationY = $Main/TranslationBox/TranslationY
@onready var MatrixEntries = $Main/MatrixBox/Matrix.get_children()

var disabled = false

func _ready():
	for ankle in MatrixEntries:
		ankle.value_changed.connect(_value_changed)
	TranslationX.value_changed.connect(_value_changed)
	TranslationY.value_changed.connect(_value_changed)

func _value_changed(_new_value=0):
	if not disabled:
		value_changed.emit()

func load_ui(contraction):
	# do not emit value_changed
	disabled = true
	# translation
	TranslationX.value = contraction.translation.x
	TranslationY.value = contraction.translation.y
	# matrix
	var vec_x = Vector2(1,0)
	var vec_y = Vector2(0,1)
	vec_x = (vec_x * contraction.contract.x).rotated(contraction.rotation)
	vec_y = (vec_y * contraction.contract.y).rotated(contraction.rotation)
	MatrixEntries[0].value = vec_x.x
	MatrixEntries[1].value = vec_x.y
	MatrixEntries[2].value = vec_y.x
	MatrixEntries[3].value = vec_y.y
	# enable value_changed
	disabled = false

func read_ui():
	var contraction = Contraction.new()
	# translation
	contraction.translation = Vector2(TranslationX.value, TranslationY.value)
	# get matrix
	var matrix = Transform2D(
		Vector2(MatrixEntries[0].value, MatrixEntries[1].value),
		Vector2(MatrixEntries[2].value, MatrixEntries[3].value),
		Vector2.ZERO
	)
	# contraction
	contraction.contract = Vector2(
		(matrix * Vector2(1,0)).length(),
		(matrix * Vector2(0,1)).length()
	)
	# rotation
	contraction.rotation = (matrix * Vector2(1,0)).angle()
	# mirroring?
	## calculate determinant
	contraction.mirrored = (matrix.x.x * matrix.y.y - matrix.x.y * matrix.y.x) < 0
	# color will be added by PlaygroundUI
	return contraction

func _on_close_button_pressed():
	close_me.emit()

func _on_rotation_button_pressed():
	switch.emit()
