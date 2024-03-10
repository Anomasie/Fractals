extends MarginContainer

signal close_me
signal load_preset

var PRESETS = {
	"Sierpinski carpet": {
		"EN": "Sierpinski carpet",
		"GER": "Sierpinski-Teppich",
		"texture": "res://assets/presets/SierpinskiCarpet.png",
		"ifs": [
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
			}
		]
	},
	"Koch snowflake": {
		"EN": "Koch snowflake",
		"GER": "Koch-Schneeflocke",
		"texture": "res://assets/presets/KochSnowflake.png",
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
				"rotation": -(60*PI) / 180,
				"mirrored": false
			},
			{
				"translation": Vector2(1.0/3, 0) + Vector2(1.0/3, 0).rotated((60*PI) / 180),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": (60*PI) / 180,
				"mirrored": false
			},
			{
				"translation": Vector2(2.0/3, 0),
				"contract": Vector2(1.0/3, 1.0/3),
				"rotation": 0,
				"mirrored": false
			}
		]
	},
#	"Whirl": {
#		"texture": "res://assets/presets/Whirl.png",
#		"ifs": [
#			{ # main leafs
#				"translation": Vector2(0.27, 1.089),
#				"contract": Vector2(0.872, 0.804),
#				"rotation": 2 * PI - 345.0 / 360 * 2 * PI,
#				"mirrored": false
#			},
#			{ # first left leaf
#				"translation": Vector2(0.066, 0.3),
#				"contract": Vector2( 0.269, 0.49 ),
#				"rotation": 2 * PI - 48.0 / 360 * 2 * PI,
#				"mirrored": false
#			},
#			{ # first right leaf
#				"translation": Vector2(0.813, 0.391),#Vector2(0.937, 0.232),
#				"contract": Vector2(0.202, 0.465),
#				"rotation": 2 * PI - 308.0 / 360 * 2 * PI,
#				"mirrored": true
#			},
#						{ # Stiel
#				"translation": Vector2(0.463, 0.266),
#				"contract": Vector2(0.085, 0.29),
#				"rotation": 2 * PI - 1.0 / 360 * 2 * PI,
#				"mirrored": false
#			}
#		]
#	},
	"Bernsley fern": {
		"EN": "Bernsley fern",
		"GER": "Barnsley-Farn",
		"texture": "res://assets/presets/BernsleyFern.png",
		"ifs": [
			{ # stem
				"translation": Vector2(0, 0),
				"contract": Vector2(0.05, 0.16),
				"rotation": 0,
				"mirrored": false
			},
			{ # main leaf
				"translation": Vector2(0, 0.8),
				"contract": Vector2(0.851, 0.851),
				"rotation": 2 * PI - 357.0 / 360 * 2 * PI,
				"mirrored": false
			},
			{ # first right leaf
				"translation": Vector2(0, 0.22),
				"contract": Vector2(0.318, 0.354),
				"rotation": 2 * PI - 298.0 / 360 * 2 * PI,
				"mirrored": true
			},
			{ # first left leaf
				"translation": Vector2(0, 0.8),
				"contract": Vector2(0.328, 0.318),
				"rotation": 2 * PI - 52.0 / 360 * 2 * PI,
				"mirrored": false
			}
		]
	}
}


@onready var Preset = load("res://scenes/presets/Preset.tscn")
@onready var CloseButton = $CloseButton
@onready var Presets = $Margin/Content/Presets

func _ready():
	load_presets()

func load_presets():
	# delete presets
	for child in Presets.get_children():
		if child != CloseButton:
			child.queue_free()
	# load new presets
	for preset in PRESETS.keys():
		var Instance = Preset.instantiate()
		Instance.name = preset
		match Global.language:
			"GER": Instance.tooltip_text = PRESETS[preset]["GER"]
			_: Instance.tooltip_text = PRESETS[preset]["EN"]
		Instance.pressed.connect(_on_preset_pressed.bind(preset))
		Presets.add_child(Instance)
		Instance.load_preset(PRESETS[preset])

func _on_preset_pressed(preset):
	load_preset.emit( IFS.from_dict( PRESETS[preset]["ifs"]) )

func _on_close_button_pressed():
	close_me.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseButton.tooltip_text = "Vorlagen schließen"
		_:
			CloseButton.tooltip_text = "close presets"
	load_presets()
