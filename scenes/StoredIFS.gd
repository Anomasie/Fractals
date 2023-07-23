extends MarginContainer

const IMAGE_SIZE = Vector2i(128,128)

signal pressed
signal remove_me

@onready var ifs = IFS.new()

@onready var Preview = $MarginContainer/MarginContainer/Preview

func _ready():
	paint_ifs()

func paint_ifs(points=1024*2):
	var results = ifs.calculate_fractal(point.new(), 10, points)
	# create empty, white image
	var image = Image.create(IMAGE_SIZE.x, IMAGE_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(ifs.background_color) # background color
	# scale image for Results:
	# get minimum and maximum in current results
	## really small/big start numbers, just to cover the case of results = []
	var max_bounds = Vector2(-100, -100)# = Vector2(results[0].position.x, results[0].position.y)
	var min_bounds = Vector2(100, 100)# = Vector2(results[0].position.x, results[0].position.y)
	for entry in results:
		max_bounds.x = max(max_bounds.x, entry.position.x)
		max_bounds.y = max(max_bounds.y, entry.position.y)
		min_bounds.x = min(min_bounds.x, entry.position.x)
		min_bounds.y = min(min_bounds.y, entry.position.y)
	max_bounds.x += (max_bounds.x - min_bounds.x)/ 20
	min_bounds.x -= (max_bounds.x - min_bounds.x)/ 20
	max_bounds.y += (max_bounds.y - min_bounds.y)/ 20
	min_bounds.y -= (max_bounds.y - min_bounds.y)/ 20
	# set current_origin and current_size
	var current_origin = min_bounds
	var current_size = max( (max_bounds-min_bounds).x, (max_bounds-min_bounds).y)
	# paint image
	## centered view
	# loupe
	# paint
	for entry in results:
		var real_position = Vector2i(
			(entry.position.x - current_origin.x) / current_size * IMAGE_SIZE.x,
			(entry.position.y - current_origin.y) / current_size * IMAGE_SIZE.y
		)
		if real_position.x >= 0 and real_position.x < image.get_width():
			if real_position.y >= 0 and real_position.y < image.get_height():
				image.set_pixel(real_position.x, real_position.y, entry.color)
	Preview.set_texture(ImageTexture.create_from_image(image))

func set_ifs(new_ifs):
	ifs = new_ifs
	paint_ifs()

func _on_button_pressed():
	pressed.emit()

func _on_remove_button_pressed():
	remove_me.emit()
