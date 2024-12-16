extends MarginContainer

signal please_reload
signal text_changed

const DIGITS = 0.05

var json = JSON.new()

@onready var CodeEditor = $CodeEditor
@onready var ReloadButton = $ReloadButton
@onready var RoundButton = $RoundButton

var disabled = 0

func _ready():
	Global.tooltip_nodes.append_array([ReloadButton, RoundButton])

func do_i_have_focus():
	return self.has_focus() or RoundButton.has_focus()

func get_dict_from_text():
	# read text -> json
	var error = json.parse(CodeEditor.text)
	var dict = {}
	if error == OK:
		dict = json.get_data()
		if typeof(dict) != TYPE_DICTIONARY:
			print("Error in PythonEdit, read_text: Unexpected data type of text")
	else:
		print("Error in PythonEdit, read_text: JSON Parse Error: ", json.get_error_message(), " in text at line ", json.get_error_line())
	return dict

func load_text(ifs):
	if disabled == 0:
		# ifs -> dict
		var dict = ifs.to_dict()
		# dict -> json
		var json = dict
		# json -> text
		var dict_string = JSON.stringify(json, "\t")
		# set text
		CodeEditor.text = dict_string

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
	CodeEditor.text = JSON.stringify(dict, "\t")
	# emit signal
	text_changed.emit()

# signals

func _on_code_editor_text_changed() -> void:
	if json.parse(CodeEditor.text) == OK:
		disabled += 1
		text_changed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		disabled -= 1

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
