extends MarginContainer

signal value_changed
signal close_me
signal switch

@onready var TranslationX = $Content/Options/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Content/Options/Columns/Main/TranslationBox/TranslationY
@onready var MatrixEntries = $Content/Options/Columns/Main/MatrixBox/Matrix.get_children()

@onready var CloseButton = $ElseBox/CloseButton
@onready var RotationButton = $ElseBox/RotationButton

var disabled = false

func _ready():
	for ankle in MatrixEntries:
		ankle.value_changed.connect(_value_changed)
	TranslationX.value_changed.connect(_value_changed)
	TranslationY.value_changed.connect(_value_changed)

func _value_changed(_new_value=0):
	if not disabled:
		value_changed.emit()
		# release focus
		## doesn't work as for now :(
		for button in MatrixEntries:
			button.release_focus()
		TranslationX.release_focus()
		TranslationY.release_focus()

func load_ui(contraction):
	# do not emit value_changed
	disabled = true
	# matrix
	var matrix = contraction.to_matrix()
	MatrixEntries[0].value = matrix[0]
	MatrixEntries[1].value = matrix[1]
	MatrixEntries[2].value = matrix[2]
	MatrixEntries[3].value = matrix[3]
	# translation
	TranslationX.value = contraction.translation.x
	TranslationY.value = contraction.translation.y
	# enable value_changed
	disabled = false

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
