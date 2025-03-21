@tool
extends MarginContainer

signal close_me
signal load_preset

var PRESETS = {
	"Sierpinski carpet": {
		"EN": "Sierpinski carpet",
		"GER": "Sierpinski-Teppich",
		"texture": "res://assets/presets/SierpinskiCarpet.png",
		"meta_data": "0,0.66666662693024,0.33333334326744,0.33333334326744,0,0,000000|0.33333334326744,0.66666662693024,0.33333334326744,0.33333334326744,0,0,000000|0.66666668653488,0.66666662693024,0.33333334326744,0.33333334326744,0,0,000000|0,0.33333340287209,0.33333334326744,0.33333334326744,0,0,000000|0.66666668653488,0.33333340287209,0.33333334326744,0.33333334326744,0,0,000000|0,-0,0.33333334326744,0.33333334326744,0,0,000000|0.33333334326744,-0,0.33333334326744,0.33333334326744,0,0,000000|0.66666668653488,-0,0.33333334326744,0.33333334326744,0,0,000000"
	},
	"Koch snowflake": {
		"EN": "Koch snowflake",
		"GER": "Koch-Schneeflocke",
		"texture": "res://assets/presets/KochSnowflake.png",
		"meta_data": "0.66666668653488,-0,0.33333334326744,0.33333334326744,0,0,000000|0.49999997019768,0.28867518901825,0.33333334326744,0.33333334326744,1.04719758033752,0,000000|0.33333334326744,0.00000001490116,0.33333334326744,0.33333334326744,-1.04719758033752,0,000000|0,-0,0.33333334326744,0.33333334326744,0,0,000000"
	},
	"Bernsley fern": {
		"EN": "Barnsley fern",
		"GER": "Barnsley-Farn",
		"texture": "res://assets/presets/BernsleyFern.png",
		"meta_data": "0,0,0.05000000074506,0.15999999642372,0,0,000000|0,0.8,0.85099995136261,0.85099995136261,0.05235987901688,0,000000|0,0.22000005841255,0.31799998879433,0.35400000214577,1.08210408687592,1,000000|0,0.80000001192093,0.32800000905991,0.31799998879433,5.37561416625977,0,000000"
	}
}


@onready var Preset = load("res://scenes/presets/Preset.tscn")
@onready var CloseButton = $CloseButton
@onready var Presets = $Margin/Content/Sep/Presets
@onready var PresetLabel = $Top/Content/PresetLabel
@onready var RandomButton = $Margin/Content/Sep/RandomButton

func _ready():
	load_presets()
	# tooltips
	if not Engine.is_editor_hint():
		Global.tooltip_nodes.append_array([
			CloseButton, RandomButton
		])

func load_presets():
	# delete presets
	for child in Presets.get_children():
		if child != CloseButton:
			child.queue_free()
	# load new presets
	for preset in PRESETS.keys():
		var Instance = Preset.instantiate()
		Instance.name = preset
		# add tooltips
		if not Engine.is_editor_hint():
			if PRESETS[preset].has(Global.language):
				Instance.tooltip_text = PRESETS[preset][Global.language]
		# connect & add node
		Instance.pressed.connect(_on_preset_pressed.bind(preset))
		Presets.add_child(Instance)
		Instance.load_preset(PRESETS[preset])

func _on_preset_pressed(preset):
	load_preset.emit( IFS.from_meta_data( PRESETS[preset]["meta_data"]) )

func _on_random_button_pressed() -> void:
	load_preset.emit( IFS.random_ifs(false) )

func _on_close_button_pressed():
	close_me.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseButton.tooltip_text = "Vorlagen schließen"
			PresetLabel.text = "Vorlagen"
			RandomButton.tooltip_text = "zufälliges Fraktal laden"
		_:
			CloseButton.tooltip_text = "close presets"
			PresetLabel.text = "Presets"
			RandomButton.tooltip_text = "load random ifs"
	load_presets()
