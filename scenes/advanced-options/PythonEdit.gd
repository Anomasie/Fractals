extends TextEdit

signal please_reload

var length_text = 0
# ifs
var bg_input_pos = [-1,-1]
var delay_input_pos = [-1,-1]
# systems
var color_pos_array = []

func find_all(string, what):
	var array = []
	for i in string.length() - what.length() + 1:
		if string.find(what, i) == i:
			array.append(i)
	return array

func get_substring(string, from=0, to=string.length()):
	return string.left(to).right(to - from)

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
		var last_possible_one = text.find("\n", delay_input_pos[0]) # first "\n" after "delay ="
		delay_input_pos[1] = last_possible_one
		for char in last_possible_one - delay_input_pos[0]:
			if char not in [" ", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]:
				delay_input_pos[1] = char - 1
				break
	# get all contraction variables
	color_pos_array = find_all(text, "color")
	color_pos_array.erase(position_of_string_background_color)

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
	for i in len(color_pos_array):
		var contraction = Contraction.new()
		if i < len(color_pos_array):
			# find color input position
			var color_input_pos = [-1, -1]
			color_input_pos[0] = text.find("#", color_pos_array[i]) # position of "#"
			color_input_pos[1] = text.find("\"", bg_input_pos[0]) # find next """
			# set color
			contraction.color = Color.from_string(
				get_substring(text, color_input_pos[0], color_input_pos[1]),
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
	print(text_after_new)
	text = text_before_new + "#" + ifs.background_color.to_html() + text_after_new

func _on_reload_button_pressed():
	please_reload.emit()
