extends TextEdit

signal please_reload

const SYSTEM_DELIMITER = "# function"

var length_text = 0
var bg_input_pos = [-1,-1]
var delay_input_pos = [-1,-1]

@onready var ReloadButton = $ReloadButton

func find_all(string, what):
	var array = []
	for i in string.length() - what.length() + 1:
		if string.find(what, i) == i:
			array.append(i)
	return array

func get_substring(string, from=0, to=string.length()):
	if to >= from and from >= 0:
		return string.left(to).right(to - from)
	else:
		return ""

func string_for_translation(translation, number = ""):
	return (
		"translation"
		+ number
		+ " = ["
		+ str(translation.x)
		+ ", "
		+ str(translation.y)
		+ "]"
	)

func string_for_matrix(matrix, number = ""):
	return (
		"matrix"
		+ number
		+ " = [["
		+ str(matrix[0])
		+ ", "
		+ str(matrix[1])
		+ "], ["
		+ str(matrix[2])
		+ ", "
		+ str(matrix[3])
		+ "]]"
	)

func string_for_color(color, number=""):
	return (
		"color"
		+ number
		+ " = \"#"
		+ str(color.to_html())
		+ "\""
	)

func string_from_contraction(contraction, number=""):
	var matrix = contraction.to_matrix()
	return (" " + number + "\n"
		+ string_for_translation(contraction.translation, number) + "\n"
		+ string_for_matrix(matrix, number) + "\n"
		+ string_for_color(contraction.color, number) + "\n"
		+ "\n"
	)

func get_vars_for_contraction(substring):
	var pos_dict = {}
	# get all contraction variables
	## translation
	pos_dict["translation"] = [-1,-1]
	var pos_translation = substring.find("translation")
	pos_dict["translation"][0] = substring.find("[", pos_translation)+1 # first "[" after "translation"
	pos_dict["translation"][1] = substring.find("]", pos_dict["translation"][0])
	## matrix
	pos_dict["matrix"] = [-1,-1]
	var pos_matrix = substring.find("matrix") # first "matrix"
	if pos_matrix > 0:
		pos_dict["matrix"][0] = substring.find("[", pos_matrix)+1 # first "[" after "matrix"
		var pos_begin_second_row = substring.find(",", pos_dict["matrix"][0])+1
		if pos_begin_second_row > 0:
			var pos_end_second_row = substring.find("]", pos_begin_second_row)+1
			if pos_end_second_row > 0:
				pos_dict["matrix"][1] = substring.find("]", pos_end_second_row)+1
	## color
	var pos_color = substring.find("color")
	## after that: get position of string with background color information
	pos_dict["color"] = [-1,-1]
	if pos_color >= 0:
		pos_dict["color"][0] = substring.find("#", pos_color) # position of "#"
		pos_dict["color"][1] = substring.find("\"", pos_dict["color"][0]) # find next """
	# return
	return pos_dict

func get_contraction_substrings(string = text, delete_stuff_without_contraction=true):
	var splitted_text_array = string.split(SYSTEM_DELIMITER, true)
	if delete_stuff_without_contraction:
		if len(splitted_text_array) > 0 and len(splitted_text_array[0]) > 0: # text does not begin with a system
			splitted_text_array.remove_at(0) # delete stuff before first system
	return splitted_text_array

func read_vars():
	length_text = text.length()
	# background color
	## get position of "backgroound_color"-string
	var position_of_string_background_color = text.find("background_color")
	## after that: get position of string with background color information
	if position_of_string_background_color >= 0:
		bg_input_pos[0] = text.find("#", position_of_string_background_color) # position of "#"
		bg_input_pos[1] = text.find("\"", bg_input_pos[0]) # find next """
	# delay
	var position_of_string_delay = text.find("delay")
	if position_of_string_delay >= 0:
		delay_input_pos[0] = text.find("=", position_of_string_delay) # first "=" after "delay"
		var last_possible_one = length_text
		delay_input_pos[1] = last_possible_one
		for c in last_possible_one - delay_input_pos[0]:
			if text[delay_input_pos[0] + c] not in [" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ":", "="]:
				delay_input_pos[1] = delay_input_pos[0] + c
				break

func read_text():
	var ifs = IFS.new()
	read_vars()
	# set background color
	if bg_input_pos[0] >= 0:
		ifs.background_color = Color.from_string(
			get_substring(text, bg_input_pos[0], bg_input_pos[1]),
			Color.WHITE)
	# delay
	if delay_input_pos[0] >= 0:
		ifs.delay = int(get_substring(text, delay_input_pos[0], delay_input_pos[1]))
	# contraction variables
	var substrings = get_contraction_substrings()
	for substring in substrings:
		var contraction = Contraction.new()
		# get positions of strings
		var vars = get_vars_for_contraction(substring)
		# load contraction values
		## matrix
		var m_row_strings = get_substring(substring, vars["matrix"][0], vars["matrix"][1]).split(",", true)
		if len(m_row_strings) == 4:
			m_row_strings = [
				",".join([m_row_strings[0], m_row_strings[1]]),
				",".join([m_row_strings[2], m_row_strings[3]])
			]
			var matrix = []
			for m_row_string in m_row_strings:
				m_row_string = m_row_string.erase(m_row_string.length()-1).erase(0) # delete "[" and "]"
				var m_row_string_array = m_row_string.split(",", true)
				if len(m_row_string_array) == 2:
					matrix.append(float(m_row_string_array[0]))
					matrix.append(float(m_row_string_array[1]))
				else:
					matrix.append(0)
					matrix.append(0)
			# transform matrix into contraction
			matrix = Contraction.nearest_allowed_matrix(matrix) # transform into allowed one
			contraction = Contraction.from_matrix(matrix) # save it
		## translation
		var t_string_array = get_substring(substring, vars["translation"][0], vars["translation"][1]).split(",", true)
		if len(t_string_array) == 2:
			contraction.translation = Vector2(
				float(t_string_array[0]),
				float(t_string_array[1])
			)
		## color
		if vars["color"][0] >= 0:
			contraction.color = Color.from_string(
				get_substring(substring, vars["color"][0], vars["color"][1]),
				Color.BLACK)
		ifs.systems.append(contraction)
	return ifs

func load_text(ifs):
	var text_before_new
	var text_after_new
	# add background
	read_vars()
	text_before_new = text.left(bg_input_pos[0])
	text_after_new = text.right(length_text - bg_input_pos[1])
	text = text_before_new + "#" + ifs.background_color.to_html() + text_after_new
	# add delay
	read_vars()
	text_before_new = text.left(delay_input_pos[0])
	text_after_new = text.right(length_text - delay_input_pos[1])
	text = text_before_new + "= " + str(ifs.delay) + text_after_new
	# contraction stuff
	var contraction_substring_array = get_contraction_substrings(text, false)
	var substring_array = [] # the array containing all function-parts
	if len(contraction_substring_array) > 0: # "preliminaries" or something
		substring_array.append(contraction_substring_array[0])
	# add substrings for each ifs
	for i in len(ifs.systems):
		if i < len(contraction_substring_array)-1:
			var substring = contraction_substring_array[i+1]
			var new_substring = ""
			# change translation
			var vars = get_vars_for_contraction(substring)
			if vars["translation"][0] >= 0 and vars["translation"][1] >= 0:
				new_substring += get_substring(substring, 0, vars["translation"][0]) # before translation values
				new_substring += str(ifs.systems[i].translation.x) + ", " + str(ifs.systems[i].translation.y) # t values
				new_substring += get_substring(substring, vars["translation"][1], substring.length()) # after t values
				substring = new_substring
			else: # no translation values found! :(
				substring += string_for_translation(ifs.systems[i].translation, str(i+1)) + "\n"
			# change matrix
			vars = get_vars_for_contraction(substring)
			new_substring = ""
			var matrix = ifs.systems[i].to_matrix()
			if vars["matrix"][0] >= 0 and vars["matrix"][1] >= 0:
				new_substring += get_substring(substring, 0, vars["matrix"][0]) # before m values
				new_substring += "[" + str(matrix[0]) + ", " + str(matrix[1]) + "], " # first row
				new_substring += "[" + str(matrix[2]) + ", " + str(matrix[3]) + "]"
				new_substring += get_substring(substring, vars["matrix"][1], substring.length()) # after m values
				substring = new_substring
			else:
				substring += string_for_matrix(matrix, str(i+1)) + "\n"
			# change color
			vars = get_vars_for_contraction(substring)
			new_substring = ""
			if vars["color"][0] >= 0 and vars["color"][1] >= 0:
				new_substring += get_substring(substring, 0, vars["color"][0]-1) # before color value
				new_substring += "\"#" + ifs.systems[i].color.to_html() + "\""
				new_substring += get_substring(substring, vars["color"][1]+1, substring.length()) # after c value
				substring = new_substring
			else:
				substring += string_for_color(ifs.systems[i].color, str(i+1)) + "\n"
			# save substring
			if not substring.ends_with("\n\n"):
				if not substring.ends_with("\n"):
					substring += "\n"
				substring += "\n"
			substring_array.append(substring)
		else:
			substring_array.append(string_from_contraction(ifs.systems[i], str(i+1)))
	# set text
	text = (SYSTEM_DELIMITER).join(substring_array)

func _on_reload_button_pressed():
	please_reload.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			ReloadButton.tooltip_text = "lade Text aus aktuellem IFS"
		_:
			ReloadButton.tooltip_text = "load text from current ifs"
