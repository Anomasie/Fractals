extends CodeEdit

signal please_reload

const DIGITS = 0.05
const MATH_SYMBOLS = [" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ":", "="]

var length_text = 0
var bg_input_pos = [-1,-1]
var delay_input_pos = [-1,-1]

@onready var ReloadButton = $ReloadButton
@onready var RoundButton = $RoundButton

func do_i_have_focus():
	return self.has_focus() or RoundButton.has_focus()

func load_text(ifs):
	# ifs -> dict
	var dict = ifs.to_dict()
	# dict -> json
	var json = dict
	# json -> text
	var dict_string = JSON.stringify(json, "\t")
	# set text
	text = dict_string

func read_text():
	# read text -> json
	var json = JSON.new()
	var error = json.parse(text)
	var dict = {}
	if error == OK:
		dict = json.get_data()
		if typeof(dict) != TYPE_DICTIONARY:
			print("Error in PythonEdit, read_text: Unexpected data type of text")
	else:
		print("Error in PythonEdit, read_text: JSON Parse Error: ", json.get_error_message(), " in text at line ", json.get_error_line())
	# read dict -> ifs
	var ifs = IFS.from_dict(dict)
	return ifs

func round_numbers():
	text = "rounded numbers"
	text_changed.emit()

# signals

func _on_reload_button_pressed():
	please_reload.emit()

func _on_round_button_pressed():
	round_numbers()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			ReloadButton.tooltip_text = "lade Text aus aktuellem IFS"
			RoundButton.tooltip_text = "runde Zahlen auf " + str(DIGITS) + " Nachkommastellen"
		_:
			ReloadButton.tooltip_text = "load text from current ifs"
			RoundButton.tooltip_text = "round numbers to " + str(DIGITS) + " decimal places"
