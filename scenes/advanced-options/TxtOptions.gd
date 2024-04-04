extends MarginContainer

signal changed

@onready var PythonEdit = $Main/Content/Lines/PythonEdit

@onready var TxtOptionsMatrix = load("res://scenes/advanced-options/TxtOptionsMatrix.tscn")
@onready var MatrixContainer = $Main/Content/Lines/Scroller/Lines/MatrixContainer

@onready var ColorEdit = $Main/Content/Lines/Scroller/Lines/General/ColorEdit
@onready var DelayEdit = $Main/Content/Lines/Scroller/Lines/General/DelayEdit

@onready var CloseButton = $CloseButton
@onready var CloseAllButton = $Main/Content/Lines/Scroller/Lines/PlaygroundButtons/CloseAllButton
@onready var AddButton = $Main/Content/Lines/Scroller/Lines/PlaygroundButtons/AddButton

var current_ifs = IFS.new()

var disabled = 0

func _ready():
	# connect
	for child in MatrixContainer.get_children():
		child.value_changed.connect(_on_matrix_value_changed)
		child.remove_me.connect(_on_matrix_remove_me)
		child.duplicate_me.connect(_on_matrix_duplicate_me)

func update_ui():
	disabled += 1
	
	# background color
	ColorEdit.text = ""
	ColorEdit.placeholder_text = "#" + current_ifs.background_color.to_html()
	# delay
	DelayEdit.value = current_ifs.delay
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

func load_ui(new_ifs):
	current_ifs = new_ifs
	if not disabled:
		update_ui()
	if not PythonEdit.do_i_have_focus():
		PythonEdit.load_text(current_ifs)

func read_ui():
	var ifs = IFS.new()
	# background color
	if ColorEdit.text:
		ifs.background_color = Color.from_string(ColorEdit.text, Color.WHITE)
	else:
		ifs.background_color = Color.from_string(ColorEdit.placeholder_text, Color.WHITE)
	# delay
	ifs.delay = int(DelayEdit.value)
	# systems
	for child in MatrixContainer.get_children():
		if child.visible:
			ifs.systems.append(child.read_ui())
	return ifs

func open(ifs):
	load_ui(ifs)
	PythonEdit.load_text(ifs)
	show()

func _on_close_button_pressed():
	hide()

# Matrix-Stuff

## buttons

func _on_add_button_pressed():
	current_ifs.systems.append(Contraction.new())
	update_ui()
	changed.emit(read_ui())

func _on_close_all_button_pressed():
	current_ifs.systems = []
	update_ui()
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
	update_ui()
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

# python/txt stuff

func _on_python_edit_text_changed():
	var ifs = PythonEdit.read_text()
	load_ui(ifs)
	changed.emit(ifs)

func _on_python_edit_please_reload():
	PythonEdit.load_text(current_ifs)

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseButton.tooltip_text = "Text-Optionen schließen"
			CloseAllButton.tooltip_text = "Alle Funktionen löschen"
			AddButton.tooltip_text = "Funktion hinzufügen"
			DelayEdit.tooltip_text = "Verzögerung der Berechnung eingeben"
			ColorEdit.tooltip_text = "Hintergrundfarbe des Fraktals"
		_:
			CloseButton.tooltip_text = "close text options"
			CloseAllButton.tooltip_text = "delete all functions"
			AddButton.tooltip_text = "add function"
			DelayEdit.tooltip_text = "enter delay of the ifs calculation"
			ColorEdit.tooltip_text = "enter background color of the fractal"
	# pass on signal
	PythonEdit.reload_language()
	for child in MatrixContainer.get_children():
		child.reload_language()
