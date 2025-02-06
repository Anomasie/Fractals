extends MarginContainer

signal close_me
signal switch

signal t_x_changed
signal t_y_changed
signal c_x_changed
signal c_y_changed
signal rot_changed
signal mirror_changed

@onready var Main = $Content/MarginContainer/AdvancedOptions/Main

@onready var TranslationX = $Content/MarginContainer/AdvancedOptions/Main/TranslationBox/TranslationX
@onready var TranslationY = $Content/MarginContainer/AdvancedOptions/Main/TranslationBox/TranslationY
@onready var ContractX = $Content/MarginContainer/AdvancedOptions/Main/ContractionBox/ContractionX
@onready var ContractY = $Content/MarginContainer/AdvancedOptions/Main/ContractionBox/ContractionY
@onready var Rotation = $Content/MarginContainer/AdvancedOptions/Main/RotationBox/Rotation
@onready var Mirror = $Content/MarginContainer/AdvancedOptions/Main/RotationBox/Mirror

@onready var CloseButton = $ElseBox/CloseButton
@onready var MatrixButton = $ElseBox/MatrixButton

var disabled = false

func _ready():
	# tooltips
	Global.tooltip_nodes.append_array([
		TranslationX, TranslationY,
		ContractX, ContractY,
		Rotation, Mirror,
		CloseButton, MatrixButton
	])

func _on_mirror_pressed():
	if not disabled:
		mirror_changed.emit()

func load_ui_of_one(contraction):
	# do not emit value_changed
	disabled = true
	# contraction(s)
	ContractX.placeholder_text = str(contraction.contract.x)
	ContractY.placeholder_text = str(contraction.contract.y)
	# translation
	TranslationX.placeholder_text = str(contraction.translation.x)
	TranslationY.placeholder_text = str(contraction.translation.y)
	# rotation
	## godot rotation: 2pi-scaled
	### and clock-wise!?!
	## user-friendly rotation: 360°-scaled
	### and counter-clock-wise
	if contraction.rotation == 0: # otherwise, weird rounding errors occur
		Rotation.placeholder_text = "0"
	else:
		var rot_value = 360 - contraction.rotation / (2 * PI) * 360
		while rot_value < 0 - 0.5 or rot_value >= 359 + 0.5:
			if rot_value < 0 - 0.5:
				rot_value += 360
			else:
				rot_value -= 360
		Rotation.placeholder_text = str(rot_value)
	# mirroring
	Mirror.flip_h = contraction.mirrored
	# enable value_changed
	disabled = false

func compare_and_set(node, values):
	if values.max() - values.min() < 0.0001:
		node.placeholder_text = str(values[0])
	else:
		node.placeholder_text = ""

func load_ui_of_list(contractions):
	# do not emit value_changed
	disabled = true
	# translation
	var list_x = []
	var list_y = []
	for entry in contractions:
		list_x.append(entry.translation.x)
		list_y.append(entry.translation.y)
	compare_and_set(TranslationX, list_x)
	compare_and_set(TranslationY, list_y)
	# contraction(s)
	list_x = []
	list_y = []
	for entry in contractions:
		list_x.append(entry.contract.x)
		list_y.append(entry.contract.y)
	compare_and_set(ContractX, list_x)
	compare_and_set(ContractY, list_y)
	# rotation
	## godot rotation: 2pi-scaled
	### and clock-wise!?!
	## user-friendly rotation: 360°-scaled
	### and counter-clock-wise
	var list_rotations = []
	for entry in contractions:
		list_rotations.append(entry.rotation)
	compare_and_set(Rotation, list_rotations)
	if Rotation.placeholder_text != "" and float(Rotation.placeholder_text) != 0:
		var rot_value = 360 - float(Rotation.placeholder_text) / (2 * PI) * 360
		while rot_value < 0 - 0.5 or rot_value >= 359 + 0.5:
			if rot_value < 0 - 0.5:
				rot_value += 360
			else:
				rot_value -= 360
		Rotation.placeholder_text = str(int(rot_value))
	# mirroring
#	Mirror.flip_h = contraction.mirrored
	# enable value_changed
	disabled = false

func load_ui(contractions):
	if len(contractions) == 1:
		load_ui_of_one(contractions[0])
	else:
		load_ui_of_list(contractions)

func read_ui():
	var contraction = Contraction.new()
	# contraction
	contraction.contract = Vector2(float(ContractX.placeholder_text), float(ContractY.placeholder_text))
	# rotation
	contraction.rotation = 2 * PI - float(Rotation.placeholder_text) / 360 * 2 * PI
	# translation
	## godot translation: anchor top-left
	## user-friendly translation: anchor bottom-left
	contraction.translation = Vector2(float(TranslationX.placeholder_text), float(TranslationY.placeholder_text))
	# mirroring
	contraction.mirrored = Mirror.flip_h
	# color will be added by PlaygroundUI
	return contraction

func _on_close_button_pressed():
	close_me.emit()

func _on_matrix_button_pressed():
	switch.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			# settings
			TranslationX.tooltip_text = "Verschiebung entlang der X-Achse"
			TranslationY.tooltip_text = "Verschiebung entlang der Y-Achse"
			ContractX.tooltip_text = "Verzerrung entlang der X-Achse"
			ContractY.tooltip_text = "Verzerrung entlang der Y-Achse"
			Rotation.tooltip_text = "Rotation in °"
			Mirror.tooltip_text = "Rechteck spiegeln"
			# buttons
			CloseButton.tooltip_text = "erweiterte Optionen schließen"
			MatrixButton.tooltip_text = "Matrix-Ansicht"
		_:
			# settings
			TranslationX.tooltip_text = "enter translation in x-axis"
			TranslationY.tooltip_text = "enter translation in y-axis"
			ContractX.tooltip_text = "enter distortion along x-axis"
			ContractY.tooltip_text = "enter distortion along y-axis"
			Rotation.tooltip_text = "enter rotation degree"
			Mirror.tooltip_text = "flip rectangle"
			# buttons
			CloseButton.tooltip_text = "close advanced options"
			MatrixButton.tooltip_text = "swtich to matrix view"


func _on_rotation_text_submitted(new_text: String) -> void:
	var value = int(new_text)
	Rotation.placeholder_text = str(value)
	Rotation.text = ""
	Rotation.release_focus()
	rot_changed.emit(- value / 180.0 * PI)

func text_to_translation_value(text):
	var value = float(text)
	if value < -1:
		value = -1
	elif value > 2:
		value = 2
	return value

func _on_translation_x_text_submitted(new_text: String) -> void:
	var value = text_to_translation_value(new_text)
	TranslationX.placeholder_text = str(value)
	TranslationX.text = ""
	TranslationX.release_focus()
	t_x_changed.emit(value)

func _on_translation_y_text_submitted(new_text: String) -> void:
	var value = text_to_translation_value(new_text)
	TranslationY.placeholder_text = str(value)
	TranslationY.text = ""
	TranslationY.release_focus()
	t_y_changed.emit(value)

func text_to_contraction_value(text):
	var value = float(text)
	if value < 0:
		value = 0
	elif value > 1:
		value = 1
	return value

func _on_contraction_x_text_submitted(new_text: String) -> void:
	var value = text_to_contraction_value(new_text)
	ContractX.placeholder_text = str(value)
	ContractX.text = ""
	ContractX.release_focus()
	c_x_changed.emit(value)

func _on_contraction_y_text_submitted(new_text: String) -> void:
	var value = text_to_contraction_value(new_text)
	ContractY.placeholder_text = str(value)
	ContractY.text = ""
	ContractY.release_focus()
	c_y_changed.emit(value)
