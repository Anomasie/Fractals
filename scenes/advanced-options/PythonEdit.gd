extends TextEdit

signal please_reload

var begin_bg_input
var end_bg_input
var begin_delay_input
var end_delay_input

func read_vars():
	var begin_bg_string = text.find("background_color")
	if begin_bg_string >= 0:
		begin_bg_input = text.find("#", begin_bg_string) # background_color |= "#ffaabbff"
		if begin_bg_input >= 0:
			end_bg_input = text.right(text.length()-begin_bg_input-1).find("\"")
	
	# search delay
	var begin_delay_string = text.find("delay")
	if begin_delay_string >= 0:
		begin_delay_input = text.find("=", begin_delay_string) # delay |=   20
		begin_delay_input = text.rfind(" ", begin_delay_input) # delay =  |20
		end_delay_input = text.right(-begin_delay_input-1).find("\n")

func read_text():
	var ifs = IFS.new()
	read_vars()
	# search background
	var begin_bg_string = text.find("background_color")
	if begin_bg_string >= 0:
		begin_bg_input = text.find("#", begin_bg_string) # background_color |= "#ffaabbff"
		if begin_bg_input >= 0:
			var text_from_begin = text.right(text.length()-begin_bg_input-1)
			end_bg_input = text_from_begin.find("\"")
			if end_bg_input >= 0:
				ifs.background_color = Color.from_string(
					text_from_begin.left(end_bg_input),
					Color.WHITE)
			else:
				ifs.background_color = Color.from_string(
					text_from_begin,
					Color.WHITE)
	# search delay
	var begin_delay_string = text.find("delay")
	if begin_delay_string >= 0:
		begin_delay_input = text.find("=", begin_delay_string) # delay |=   20
		begin_delay_input = text.rfind(" ", begin_delay_input) # delay =  |20
		var text_from_begin = text.right(-begin_delay_input-1)
		end_delay_input = text_from_begin.find("\n")
		if end_delay_input >= 0:
			ifs.delay = int(text_from_begin.left(end_delay_input))
		else:
			ifs.delay = int(text_from_begin)
		print(ifs.delay)
	return ifs

func load_text(ifs):
	read_vars()
	if begin_bg_input:
		var text_before_input = text.left(begin_bg_input-1)
		var text_after_input = text.right(-(begin_bg_input+end_bg_input)-1)
		text = text_before_input + "#\"" + ifs.background_color.to_html() + "\"" + text_after_input
	else:
		text = "background_color = #\"ifs.background_color.to_html()\"\n" + text


func _on_reload_button_pressed():
	please_reload.emit()
