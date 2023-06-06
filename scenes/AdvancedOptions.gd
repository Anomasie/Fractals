extends VBoxContainer

signal value_changed
signal close_me

func _ready():
	for child in self.get_children():
		for ankle in child.get_children():
			if ankle is SpinBox:
				ankle.value_changed.connect(_value_changed)
			elif ankle is CheckButton:
				ankle.pressed.connect(_value_changed)

@onready var TranslationX = $TranslationBox/TranslationX
@onready var TranslationY = $TranslationBox/TranslationY
@onready var ContractX = $ContractionBox/ContractionX
@onready var ContractY = $ContractionBox/ContractionY
@onready var Rotation = $RotationBox/Rotation
@onready var Mirror = $MirrorBox/Mirror

func _value_changed(_new_value=0):
	value_changed.emit()

func load_ui(contraction):
	TranslationX.value = contraction.translation.x
	TranslationY.value = 1 - contraction.translation.y
	ContractX.value = contraction.contract.x
	ContractY.value = contraction.contract.y
	# see below
	if contraction.rotation / (2 * PI) * 360 < 0:
		Rotation.value = - contraction.rotation / (2 * PI) * 360
	else:
		Rotation.value = 360 - contraction.rotation / (2 * PI) * 360
	Mirror.button_pressed = contraction.mirrored

func read_ui():
	var contraction = Contraction.new()
	# godot translation: anchor top-left
	# user-friendly translation: anchor bottom-left
	contraction.translation = Vector2(TranslationX.value, 1 - TranslationY.value)
	contraction.contract = Vector2(ContractX.value, ContractY.value)
	# godot rotation: 2pi-scaled
	## and clock-wise!?!
	# user-friendly rotation: 360°-scaled
	## and counter-clock-wise
	contraction.rotation = 2 * PI - Rotation.value / 360 * 2 * PI
	contraction.mirrored = Mirror.button_pressed
	# the color will be added by PlaygroundUI
	return contraction

func _on_close_button_pressed():
	close_me.emit()
