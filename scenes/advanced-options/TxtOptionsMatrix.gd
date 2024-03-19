extends MarginContainer

@onready var TranslationX = $Main/Columns/Main/TranslationBox/TranslationX
@onready var TranslationY = $Main/Columns/Main/TranslationBox/TranslationY
@onready var Matrix = $Main/Columns/Main/MatrixBox/Matrix.get_children()
@onready var ColorEdit = $Main/Columns/Main/ColorBox/ColorEdit

func load_ui(dict):
	TranslationX.value = float(dict["translation"][0])
	TranslationY.value = float(dict["translation"][1])
	for i in 4:
		Matrix[i].value = float(dict["matrix"][i])
	ColorEdit.placeholder_text = str(dict["color"])
	ColorEdit.text = ""
