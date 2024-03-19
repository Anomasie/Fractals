extends MarginContainer

@onready var TxtOptionsMatrix = load("res://scenes/advanced-options/TxtOptionsMatrix.tscn")
@onready var MatrixContainer = $Main/Content/Lines/Scroller/MatrixContainer

var current_dict = {
	"background color": "#ffffff",
	"delay": 20,
	"systems": [
		{
			"translation": ["0.5", 0.5],
			"matrix": [0.5, 0, 0, 0.20001],
			"color": "#000000"
		}
	]
}

# to-do: func dict_from_string, func string_from_dict.

func dict_from_ifs(ifs):
	var dict = {}
	dict["background color"] = ifs.background_color
	dict["delay"] = ifs.delay
	dict["systems"] = []
	for contraction in ifs.systems:
		var vec_x = Vector2(1,0)
		var vec_y = Vector2(0,1)
		vec_x = (vec_x * contraction.contract.x).rotated(contraction.rotation)
		vec_y = (vec_y * contraction.contract.y).rotated(contraction.rotation)
		dict["systems"].append(
			{
				"translation": [contraction.translation.x, contraction.translation.y],
				"matrix": [vec_x.x, vec_x.y, vec_y.x, vec_y.y],
				"color": contraction.color.to_html()
			}
		)
	return dict

func ifs_from_dict(dict):
	var ifs = IFS.new()
	if dict.has("background color"):
		ifs.background_color = Color.from_string(dict["background color"], Color.WHITE)
	if dict.has("delay"):
		ifs.delay = int(dict["delay"])
	if dict.has("systems"):
		for system in dict["systems"]:
			var contraction = Contraction.new()
			if system.has("translation") and typeof(system["translation"]) == TYPE_ARRAY and len(system["translation"]) == 2:
				contraction.translation = Vector2(
					float(system["translation"][0]),
					float(system["translation"][1])
				)
			if system.has("matrix") and typeof(system["matrix"]) == TYPE_ARRAY and len(system["matrix"] == 4):
				var matrix = Transform2D(
					Vector2(float(system["matrix"][0]), float(system["matrix"][1])),
					Vector2(float(system["matrix"][2]), float(system["matrix"][3])),
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
				if contraction.mirrored:
					contraction.rotation = PI - contraction.rotation
			if system.has("color"):
				contraction.color = Color.from_string(str(system["color"]), Color.BLACK)
			ifs.systems.append(contraction)

func load_dict(dict = current_dict):
	current_dict = dict
	# delete old matrices
	for i in len(MatrixContainer.get_children()):
		MatrixContainer.get_child(i).visible = i < len(dict["systems"])
	if len(dict["systems"]) > len(MatrixContainer.get_children()):
		for _i in len(dict["systems"]) - len(MatrixContainer.get_children()):
			var new_child = TxtOptionsMatrix.instantiate()
			MatrixContainer.add_child(new_child)
	# add new matrix
	for i in len(dict["systems"]):
		MatrixContainer.get_child(i).load_ui(dict["systems"][i])

func open(ifs):
	load_dict(dict_from_ifs(ifs))

func _on_close_button_pressed():
	hide()
