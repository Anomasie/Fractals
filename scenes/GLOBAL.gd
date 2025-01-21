extends Node
# script for global variables

signal user_saved_colors_changed
signal give_tooltip
signal hide_tooltip

# constants
## paths
const SAVE_PATH = "res://"
const GALLERY_ADRESS = "https://gallery.fracmi.cc/g/ifs"
## ResultUI
const DEFAULT_DELAY = 10
const DEFAULT_POINTS = 1000000

var language = "GER"

var LOUPE = Vector2i(512,512)

var user_saved_colors = []

var tooltip_nodes = []

var uploaded_links = []

func _ready():
	await get_tree().process_frame
	var done_nodes = []
	for node in tooltip_nodes:
		if is_instance_valid(node) and not node in done_nodes:
			node.mouse_entered.connect(_give_tooltip.bind(node))
			node.mouse_exited.connect(_hide_tooltip)
			done_nodes.append(node)
	tooltip_nodes = []

func add_to_tooltip_nodes(array):
	for entry in array:
		entry.mouse_entered.connect(_give_tooltip.bind(entry))
		entry.mouse_exited.connect(_hide_tooltip)

func _give_tooltip(node):
	give_tooltip.emit(node.tooltip_text)

func _hide_tooltip():
	hide_tooltip.emit()

func already_uploaded(link):
	return link in uploaded_links

func add_uploaded_link(link):
	uploaded_links.append(link)
