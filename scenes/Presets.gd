extends VBoxContainer

signal close_me
signal load_preset

var PRESETS = {
	"Sierpinski": {
		"texture": "res://assets/presets/SierpinskiCarpet.png",
		"ifs": [
			{
				"translation": Vector2(0, 1),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(1.0/3, 1),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 1),
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
				"translation": Vector2(2.0/3, 2.0/3),
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
				"translation": Vector2(1.0/3, 1.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 1.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			}
		]
	},
	"Koch": {
		"texture": "res://assets/presets/KochSnowflake.png",
		"ifs": [
			{
				"translation": Vector2(0, 1.0/3),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			},
			{
				"translation": Vector2(1.0/3, 0) + Vector2(1.0/3, 0).rotated((60*PI) / 180) + Vector2(1.0/3, 0).rotated((30*PI) / 180),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": (60*PI) / 180,
				"mirrored": false
			},
			{
				"translation": Vector2(1.0/3, 0) + Vector2(0, 1.0/3).rotated((60*PI) / 180),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": -(60*PI) / 180,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 1.0/3),
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
