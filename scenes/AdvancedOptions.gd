extends HBoxContainer

signal value_changed
signal close_me
signal switch

var disabled = false

func _ready():
	for child in $Main.get_children():
		for ankle in child.get_children():
			if ankle is SpinBox:
				ankle.value_changed.connect(_value_changed)
			elif ankle is CheckButton:
				ankle.pressed.connect(_on_mirror_pressed)

@onready var TranslationX = $Main/TranslationBox/TranslationX
@onready var TranslationY = $Main/TranslationBox/TranslationY
@onready var ContractX = $Main/ContractionBox/ContractionX
@onready var ContractY = $Main/ContractionBox/ContractionY
@onready var Rotation = $Main/RotationBox/Rotation
@onready var Mirror = $Main/RotationBox/Mirror

func _value_changed(_new_value=0):
	if not disabled:
		value_changed.emit()

func _on_mirror_pressed():
	if not disabled:
		disabled = true
		# change translation
		var vec_to_right = Vector2(ContractX.value, 0).rotated(2 * PI - Rotation.value / 360 * 2 * PI)
		if Mirror.button_pressed:
			TranslationX.value += vec_to_right.x
			TranslationY.value -= vec_to_right.y
		else:
			TranslationX.value -= vec_to_right.x
			TranslationY.value += vec_to_right.y
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
			print(rot_value)
			if rot_value < 0 - 0.5:
				rot_value += 360
			else:
				rot_value -= 360
		Rotation.value = rot_value
	# mirroring
	Mirror.button_pressed = contraction.mirrored
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
	contraction.mirrored = Mirror.button_pressed
	if contraction.mirrored:
		var vec_to_right = Vector2(contraction.contract.x, 0).rotated(-contraction.rotation)
		contraction.translation -= vec_to_right
	# color will be added by PlaygroundUI
	return contraction

func _on_close_button_pressed():
	close_me.emit()

func _on_matrix_button_pressed():
	switch.emit()
