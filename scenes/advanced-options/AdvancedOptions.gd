extends MarginContainer

signal value_changed
signal close_me
signal switch

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
	for child in Main.get_children():
		for ankle in child.get_children():
			if ankle is SpinBox:
				ankle.value_changed.connect(_value_changed)
			elif ankle is CheckButton:
				ankle.pressed.connect(_on_mirror_pressed)

func _value_changed(_new_value=0):
	if not disabled:
		value_changed.emit()
		# release focus
		## doesn't work as for now :(
		for button in [TranslationX, TranslationY, ContractX, ContractY, Rotation]:
			button.release_focus()

func _on_mirror_pressed():
	if not disabled:
		disabled = true
		# change translation
		var vec_to_right = Vector2(ContractX.value, 0).rotated(2 * PI - Rotation.value / 360 * 2 * PI)
		if not Mirror.flip_h:
			TranslationX.value += vec_to_right.x
			TranslationY.value -= vec_to_right.y
		else:
			TranslationX.value -= vec_to_right.x
			TranslationY.value += vec_to_right.y
		Mirror.flip_h = not Mirror.flip_h
		# commit changes
		disabled = false
		value_changed.emit()

func load_ui(contraction):
	# do not emit value_changed
	disabled = true
	# contraction
	ContractX.value = contraction.contract.x
	ContractY.value = contraction.contract.y
	# translation
	TranslationX.value = contraction.translation.x
	TranslationY.value = contraction.translation.y
	# rotation
	## godot rotation: 2pi-scaled
	### and clock-wise!?!
	## user-friendly rotation: 360°-scaled
	### and counter-clock-wise
	if contraction.rotation == 0: # otherwise, weird rounding errors occur
		Rotation.value = 0
	else:
		var rot_value = 360 - contraction.rotation / (2 * PI) * 360
		while rot_value < 0 - 0.5 or rot_value >= 359 + 0.5:
			if rot_value < 0 - 0.5:
				rot_value += 360
			else:
				rot_value -= 360
		Rotation.value = rot_value
	# mirroring
	Mirror.flip_h = contraction.mirrored
	if contraction.mirrored:
		var vec_to_right = Vector2(contraction.contract.x, 0).rotated(contraction.rotation)
		TranslationX.value += vec_to_right.x
		TranslationY.value -= vec_to_right.y
	# enable value_changed
	disabled = false

func read_ui():
	var contraction = Contraction.new()
	# contraction
	contraction.contract = Vector2(ContractX.value, ContractY.value)
	# rotation
	contraction.rotation = 2 * PI - Rotation.value / 360 * 2 * PI
	# translation
	## godot translation: anchor top-left
	## user-friendly translation: anchor bottom-left
	contraction.translation = Vector2(TranslationX.value, TranslationY.value)
	# mirroring
	contraction.mirrored = Mirror.flip_h
	if contraction.mirrored:
		var vec_to_right = Vector2(contraction.contract.x, 0).rotated(-contraction.rotation)
		contraction.translation -= vec_to_right
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
