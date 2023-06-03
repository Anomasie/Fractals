extends Control

@onready var Result = $Center/Result

func open(results):
	# create empty, white image
	var image = Image.create(Global.LOUPE.x, Global.LOUPE.y, false, Image.FORMAT_RGB8) # empty
	image.fill(Color.WHITE) # white
	# paint image
	for entry in results:
		entry = Vector2i(
			entry.x * Global.LOUPE.x,
			entry.y * Global.LOUPE.y
		)
		if entry.x >= 0 and entry.x <= Global.LOUPE.x:
			if entry.y >= 0 and entry.y <= Global.LOUPE.y:
				image.set_pixel(entry.x, entry.y, Color.BLACK)
	# set image
	Result.set_texture(ImageTexture.create_from_image(image))
	Result.custom_minimum_size = Global.LOUPE
	show()
