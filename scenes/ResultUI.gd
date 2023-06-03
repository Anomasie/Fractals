extends Control

@onready var Result = $Center/Result

var current_ifs = IFS.new()
var counter = 0

func open(ifs):
	current_ifs = ifs
	var results = ifs.calculate_fractal()
	# create empty, white image
	var image = Image.create(Global.LOUPE.x, Global.LOUPE.y, false, Image.FORMAT_RGB8) # empty
	image.fill(Color.WHITE) # white
	Result.custom_minimum_size = Global.LOUPE
	Result.set_texture(ImageTexture.create_from_image(image))
	# paint results
	paint(results)
	# show
	show()

func paint(results):
	var image = Result.get_texture().get_image()
	# paint image
	for entry in results:
		var real_position = Vector2i(
			entry.position.x * Global.LOUPE.x,
			entry.position.y * Global.LOUPE.y
		)
		if real_position.x >= 0 and real_position.x < Global.LOUPE.x:
			if real_position.y >= 0 and real_position.y < Global.LOUPE.y:
				image.set_pixel(real_position.x, real_position.y, entry.color)
	# set image
	Result.set_texture(ImageTexture.create_from_image(image))

func _on_back_button_pressed():
	self.get_parent().show_playground()

func _on_more_button_pressed():
	paint(current_ifs.calculate_fractal( point.new() ))

func _on_save_button_pressed():
	get_counter()
	var filename = "fractal" + str(counter) + ".png"
	var image = Result.get_texture().get_image()
	var buf = image.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buf, filename)
	image.save_png(Global.SAVE_PATH + filename)

func get_counter():
	while FileAccess.file_exists(Global.SAVE_PATH + "fractal" + str(counter) + ".png"):
		counter += 1
