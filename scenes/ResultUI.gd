extends MarginContainer

@onready var Result = $Center/Result
@onready var SaveButton = $Right/Lines/SaveButton
@onready var MoreButton = $Right/Lines/MoreButton

var current_ifs = IFS.new()
var current_loupe = Global.LOUPE
var current_origin = Vector2.ZERO
var current_size = 1
var counter = 0

func _ready():
	var viewport_size = get_viewport().get_size()
	current_loupe = min(viewport_size.x - 2 * 16 - 2 * 16, viewport_size.y - 2 * 16) * Vector2i(1,1)
	#SizeOptions.load_ui(current_loupe)

func open(ifs, reload_size=false, centered=CenterButton.button_pressed):
	current_ifs = ifs
	var results = ifs.calculate_fractal()
	# load size
	if reload_size:
		SizeOptions.load_ui(Global.LOUPE)
	# create empty, white image
	var image = Image.create(current_loupe.x, current_loupe.y, false, Image.FORMAT_RGB8)
	image.fill(Color.WHITE) # white
	Result.custom_minimum_size = current_loupe
	Result.set_texture(ImageTexture.create_from_image(image))
	# calculate min and max bounds in results
	if centered:
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
		current_origin = min_bounds
		current_size = max( (max_bounds-min_bounds).x, (max_bounds-min_bounds).y)
	# paint results
	paint(results, CenterButton.button_pressed)
	# show
	show()

func paint(results, centered):
	var image = Result.get_texture().get_image()
	# paint image
	## centered view
	if centered:
		# loupe
		# paint
		for entry in results:
			var real_position = Vector2i(
				(entry.position.x - current_origin.x) / current_size * current_loupe.x,
				(entry.position.y - current_origin.y) / current_size * current_loupe.y
			)
			if real_position.x >= 0 and real_position.x < image.get_width():
				if real_position.y >= 0 and real_position.y < image.get_height():
					image.set_pixel(real_position.x, real_position.y, entry.color)
	## normal view: not centered
	else:
		for entry in results:
			var real_position = Vector2i(
				entry.position.x * current_loupe.x,
				entry.position.y * current_loupe.y
			)
			if real_position.x >= 0 and real_position.x < current_loupe.x:
				if real_position.y >= 0 and real_position.y < current_loupe.y:
					image.set_pixel(real_position.x, real_position.y, entry.color)
	# set image
	Result.set_texture(ImageTexture.create_from_image(image))

func _on_more_button_pressed():
	paint(current_ifs.calculate_fractal( point.new() ), CenterButton.button_pressed)

func _on_save_button_pressed():
	get_counter()
	var filename = "fractal" + str(counter) + ".png"
	var image = Result.get_texture().get_image()
	image.flip_y()
	var buf = image.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buf, filename)
	image.save_png(Global.SAVE_PATH + filename)

func get_counter():
	while FileAccess.file_exists(Global.SAVE_PATH + "fractal" + str(counter) + ".png"):
		counter += 1

# Right

## changing result size

@onready var SizeButton = $Right/Lines/SizeButton
@onready var SizeOptions = $Right/Lines/SizeOptions

func _on_size_button_pressed():
	SizeButton.hide()
	MoreButton.hide()
	SaveButton.hide()
	SizeOptions.show()

func _on_size_options_close_me():
	SizeOptions.hide()
	SizeButton.show()
	MoreButton.show()
	SaveButton.show()

func _on_size_options_value_changed():
	current_loupe = SizeOptions.read_ui()
	if self.visible:
		open(current_ifs, false)

# Bottom

## change centering picture

@onready var CenterButton = $Bottom/Sep/CenterButton

func _on_center_button_pressed():
	open(current_ifs, false, CenterButton.button_pressed)
