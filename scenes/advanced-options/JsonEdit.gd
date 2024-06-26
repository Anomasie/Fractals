extends CodeEdit

signal please_reload

const DIGITS = 0.05

@onready var ReloadButton = $ReloadButton
@onready var RoundButton = $RoundButton

func _ready():
	Global.tooltip_nodes.append_array([ReloadButton, RoundButton])

func do_i_have_focus():
	return self.has_focus() or RoundButton.has_focus()

func get_dict_from_text():
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
	return dict

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
	var dict = get_dict_from_text()
	# read dict -> ifs
	var ifs = IFS.from_dict(dict)
	return ifs

func round_numbers():
	# get dict
	var dict = get_dict_from_text()
	# round
	if dict.has("systems") and typeof(dict["systems"]) == TYPE_ARRAY:
		for system in dict["systems"]:
			# translation
			if system.has("translation") and typeof(system["translation"]) == TYPE_ARRAY and len(system["translation"]) == 2:
				system["translation"] = [
					snapped(system["translation"][0], DIGITS),
					snapped(system["translation"][1], DIGITS)
				]
			# matrix
			if system.has("matrix") and typeof(system["matrix"]) == TYPE_ARRAY and len(system["matrix"]) == 4:
				system["matrix"] = [
					snapped(system["matrix"][0], DIGITS),
					snapped(system["matrix"][1], DIGITS),
					snapped(system["matrix"][2], DIGITS),
					snapped(system["matrix"][3], DIGITS)
				]
	# set text
	text = JSON.stringify(dict, "\t")
	# emit signal
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
			RoundButton.tooltip_text = "runde Zahlen mit Genauigkeit " + str(DIGITS)
		_:
			ReloadButton.tooltip_text = "load text from current ifs"
			RoundButton.tooltip_text = "round numbers with accuracy of " + str(DIGITS)
