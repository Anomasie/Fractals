extends Node
# script for global variables

signal user_saved_colors_changed

# constants
## paths
const SAVE_PATH = "res://"
const GALLERY_ADRESS = "https://gallery.fracmi.cc/g/ifs"
## ResultUI
const DEFAULT_DELAY = 10
const DEFAULT_POINTS = 100000

var language = "GER"

var LOUPE = Vector2i(512,512)

var user_saved_colors = []
