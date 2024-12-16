extends VBoxContainer

signal changed

@onready var TxtOptionsMatrix = load("res://scenes/advanced-options/TxtOptionsMatrix.tscn")
@onready var MatrixContainer = $MatrixContainer

@onready var ColorEdit = $General/ColorEdit
@onready var ColorLabel = $General/ColorLabel
@onready var DelayEdit = $General/DelayEdit
@onready var DelayLabel = $General/Delaylabel
@onready var CenterButton = $PlaygroundButtons/CenterButton
@onready var UniformButton = $PlaygroundButtons/UniformButton
@onready var ReusingLastPointButton = $PlaygroundButtons/ReusingLastPointButton

@onready var CloseAllButton = $PlaygroundButtons/CloseAllButton
@onready var AddButton = $PlaygroundButtons/AddButton

var disabled = 0
var current_ifs = IFS.new()

func _ready():
	# connect
	for child in MatrixContainer.get_children():
		child.value_changed.connect(_on_matrix_value_changed)
		child.remove_me.connect(_on_matrix_remove_me)
		child.duplicate_me.connect(_on_matrix_duplicate_me)
	# tooltips
	Global.tooltip_nodes.append_array([ColorEdit, DelayEdit, CloseAllButton, AddButton])

func update_ui(new_ifs):
	disabled += 1
	
	current_ifs = new_ifs
	# background color
	ColorEdit.text = ""
	ColorEdit.placeholder_text = "#" + current_ifs.background_color.to_html()
	# delay
	DelayEdit.value = current_ifs.delay
	# extra options
	CenterButton.on = current_ifs.centered_view 
	UniformButton.on = current_ifs.uniform_coloring
	ReusingLastPointButton.on = current_ifs.reusing_last_point
	# systems
	## hide unused matrices
	for i in len(MatrixContainer.get_children()):
		MatrixContainer.get_child(i).visible = (i < len(current_ifs.systems))
	# not enough matrices? -> add them
	if len(current_ifs.systems) > len(MatrixContainer.get_children()):
		for _i in len(current_ifs.systems) - len(MatrixContainer.get_children()):
			var new_child = TxtOptionsMatrix.instantiate()
			new_child.value_changed.connect(_on_matrix_value_changed)
			new_child.remove_me.connect(_on_matrix_remove_me)
			new_child.duplicate_me.connect(_on_matrix_duplicate_me)
			MatrixContainer.add_child(new_child)
	## add new matrix
	for i in len(current_ifs.systems):
		MatrixContainer.get_child(i).load_ui(current_ifs.systems[i])
	
	disabled -= 1

func read_ui():
	var ifs = IFS.new()
	# background color
	if ColorEdit.text:
		ifs.background_color = Color.from_string(ColorEdit.text, Color.WHITE)
	else:
		ifs.background_color = Color.from_string(ColorEdit.placeholder_text, Color.WHITE)
	# delay
	ifs.delay = int(DelayEdit.value)
	# extra options
	ifs.centered_view = CenterButton.on
	ifs.uniform_coloring = UniformButton.on
	ifs.reusing_last_point = ReusingLastPointButton.on
	# systems
	for child in MatrixContainer.get_children():
		if child.visible:
			ifs.systems.append(child.read_ui())
	return ifs

# Matrix-Stuff

## buttons

func _on_add_button_pressed():
	current_ifs.systems.append(Contraction.new())
	update_ui(current_ifs)
	changed.emit(read_ui())

func _on_close_all_button_pressed():
	current_ifs.systems = []
	update_ui(current_ifs)
	changed.emit(read_ui())

## matrix entries

func _on_matrix_value_changed():
	if disabled == 0:
		changed.emit(read_ui())

func _on_matrix_remove_me(node):
	node.hide()
	changed.emit(read_ui())

func _on_matrix_duplicate_me(node):
	current_ifs.systems.append(node.read_ui())
	update_ui(current_ifs)
	changed.emit(read_ui())

## background color

func _on_color_edit_text_submitted(new_text):
	if Color.html_is_valid(new_text):
		ColorEdit.text = ""
		ColorEdit.placeholder_text = new_text
		changed.emit(read_ui())
	else:
		ColorEdit.text = ""

## delay

func _on_delay_edit_value_changed(_value):
	if disabled == 0:
		changed.emit(read_ui())

# other buttons

func _on_center_button_pressed() -> void:
	changed.emit(read_ui())

func _on_uniform_button_pressed() -> void:
	changed.emit(read_ui())

func _on_reusing_last_point_button_pressed() -> void:
	changed.emit(read_ui())

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseAllButton.tooltip_text = "Alle Funktionen löschen"
			AddButton.tooltip_text = "Funktion hinzufügen"
			DelayLabel.text = "Verzögerung:"
			DelayEdit.tooltip_text = "Verzögerung der Berechnung eingeben"
			ColorLabel.text = "Hintergrundfarbe:"
			ColorEdit.tooltip_text = "Hintergrundfarbe des Fraktals"
		_:
			CloseAllButton.tooltip_text = "delete all functions"
			AddButton.tooltip_text = "add function"
			DelayLabel.text = "Delay:"
			DelayEdit.tooltip_text = "enter delay of the ifs calculation"
			ColorLabel.text = "Background color:"
			ColorEdit.tooltip_text = "enter background color of the fractal"
	# pass on signal
	for child in MatrixContainer.get_children():
		child.reload_language()
