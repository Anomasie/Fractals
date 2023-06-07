extends VBoxContainer

signal close_me
signal load_preset

const PRESETS = {
	"Sierpinski": {
		"texture": "res://assets/presets/SierpinskiCarpet.png",
		"ifs": [
			{
				"translation": Vector2(0, 0),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(1.0/3, 0),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 0),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(0, 1.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 1.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(0, 2.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(1.0/3, 2.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 2.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			}
		]
	}
}

@onready var Preset = load("res://scenes/Preset.tscn")
@onready var CloseButton = $CloseButton

func _ready():
	for preset in PRESETS.keys():
		var Instance = Preset.instantiate()
		Instance.name = preset
		Instance.pressed.connect(_on_preset_pressed.bind(preset))
		self.add_child(Instance)
		Instance.load_preset(PRESETS[preset])
	self.move_child(CloseButton, -1)

func _on_preset_pressed(preset):
	load_preset.emit( IFS.from_dict( PRESETS[preset]["ifs"]) )

func _on_close_button_pressed():
	close_me.emit()
