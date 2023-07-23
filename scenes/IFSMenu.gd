extends MarginContainer

signal change_ifs
signal close_me

@onready var StoredIFS = $IFSMenu/Cols/StoredIFS

@onready var AddButton = $IFSMenu/Cols/Buttons/AddButton
@onready var RandomButton = $IFSMenu/Cols/Buttons/RandomButton

var current_ifs = 0

func _ready():
	hide()

func add_system(ifs = IFS.new()):
	var NewChild = load("res://scenes/StoredIFS.tscn").instantiate()
	# set variables
	NewChild.ifs = ifs
	# connect signals
	NewChild.pressed.connect(ifs_pressed.bind(len(StoredIFS.get_children())))
	NewChild.remove_me.connect(remove_ifs.bind(NewChild))
	# add
	StoredIFS.add_child(NewChild)
	# hide add-button?
	AddButton.visible = len(StoredIFS.get_children()) < 3
	# focus
	ifs_pressed( len(StoredIFS.get_children()) - 1 )

func get_current_ifs():
	return StoredIFS.get_child(current_ifs).ifs

func get_systems():
	var systems = []
	for stored_ifs in StoredIFS.get_children():
		systems.append(stored_ifs.ifs)
	return systems

func load_systems(systems):
	# delete old systems
	for OldChild in StoredIFS.get_children():
		OldChild.queue_free()
	# add new ones
	for ifs in systems:
		add_system(ifs)

func update_ifs(updated_ifs):
	if visible:
		StoredIFS.get_child(current_ifs).set_ifs(updated_ifs)
	else:
		StoredIFS.get_child(current_ifs).ifs = updated_ifs

func update_systems():
	for Child in StoredIFS.get_children():
		Child.paint_ifs()

# button control
## stored ifs-buttons

func ifs_pressed(no):
	current_ifs = no
	change_ifs.emit()

func remove_ifs(Trash):
	if len(StoredIFS.get_children()) > 1:
		Trash.queue_free()
	AddButton.visible = len(StoredIFS.get_children()) <= 3

## general buttons

func _on_close_button_pressed():
	close_me.emit()

func _on_add_button_pressed():
	add_system()

# draw points

func _on_visibility_changed():
	if typeof(StoredIFS) != TYPE_NIL:
		update_systems()
