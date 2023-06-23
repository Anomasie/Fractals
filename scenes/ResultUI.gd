extends MarginContainer

@onready var Result = $Center/Result
@onready var ResultBackground = $Center/ResultBackground

@onready var SaveButton = $Top/Main/SaveButton
@onready var SaveFileDialog = $Top/FileDialog
@onready var CenterButton = $Top/Main/CenterButton
@onready var ColorButton = $Top/Main/ColorButton
@onready var ColorBar = $ColorBar

@onready var SizeOptions = $SizeOptions

@onready var PointSlider = $Bottom/Lines/PointSlider

var RealImage
var image_size = current_loupe

var current_ifs = IFS.new()
var current_loupe = Global.LOUPE
var current_origin = Vector2.ZERO
var current_size = 1
var file_counter = 0

func _ready():
	PointSlider.value = limit
	SaveFileDialog.hide()
	ColorBar.hide()
	SizeOptions.hide()
	resize()

var delay = 10

var limit = 100000
var frame_limit = 1000 # to manage frame performance
var max_frame_limit = 3000
var min_frame_limit = 100
var counter = 0

func _process(delta):
	if delta > 1.0/60: # too slow
		frame_limit = max(0, frame_limit-10)
	if delta < 1.0/30: # fast enough
		frame_limit = min(frame_limit+10, max_frame_limit)
	if counter < limit:
		var amount = min(frame_limit, limit-counter)
		counter += amount
		# add points
		paint(current_ifs.calculate_fractal( point.new(), delay, amount), CenterButton.button_pressed)

func resize():
	current_loupe = Global.LOUPE
	image_size = current_loupe
	open(current_ifs)

func resize_image(new_size):
	image_size = new_size
	open(current_ifs)

func open(ifs, centered=CenterButton.button_pressed):
	current_ifs = ifs
	var results = ifs.calculate_fractal()
	# create empty, white image
	var image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT) # white
	# "save" image
	RealImage = image
	# scale image for Results:
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
	# set counter and stuff
	counter = 0
	# show
	show()

func paint(results, centered):
	# paint image
	## centered view
	if centered:
		# loupe
		# paint
		for entry in results:
			var real_position = Vector2i(
				(entry.position.x - current_origin.x) / current_size * image_size.x,
				(entry.position.y - current_origin.y) / current_size * image_size.y
			)
			if real_position.x >= 0 and real_position.x < RealImage.get_width():
				if real_position.y >= 0 and real_position.y < RealImage.get_height():
					RealImage.set_pixel(real_position.x, real_position.y, entry.color)
	## normal view: not centered
	else:
		for entry in results:
			var real_position = Vector2i(
				entry.position.x * image_size.x,
				entry.position.y * image_size.y
			)
			if real_position.x >= 0 and real_position.x < image_size.x:
				if real_position.y >= 0 and real_position.y < image_size.y:
					RealImage.set_pixel(real_position.x, real_position.y, entry.color)
	var image = RealImage.duplicate()
	Result.custom_minimum_size = current_loupe
	if image_size.x > current_loupe.x and image_size.y > current_loupe.y:
		image.resize(current_loupe.x, current_loupe.y)
	elif image_size.x > current_loupe.x:
		image.resize(current_loupe.x, image_size.y)
	elif image_size.y > current_loupe.y:
		image.resize(image_size.x, current_loupe.y)
	# set image
	Result.set_texture(ImageTexture.create_from_image(image))

func _on_save_button_pressed():
	if OS.has_feature("web"):
		get_counter()
		var filename = "fractal" + str(counter) + ".png"
		# extract images
		var image = Result.get_texture().get_image()
		var background = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
		background.fill(ResultBackground.self_modulate)
		background.convert(Image.FORMAT_RGBA8)
		# add result (image) onto background
		background.blit_rect_mask(
			image,
			image,
			Rect2i(
				0,
				0,
				image.get_width(),
				image.get_height()),
			Vector2i(
				0,
				0
			)
		)
		background.flip_y()
		# save image
		var buf = background.save_png_to_buffer()
		JavaScriptBridge.download_buffer(buf, filename)
	else:
		SaveFileDialog.open()

func save(path):
	# extract images
	var background = Image.create(RealImage.get_width(), RealImage.get_height(), false, Image.FORMAT_RGBA8)
	background.fill(ResultBackground.self_modulate)
	background.convert(Image.FORMAT_RGBA8)
	# add result (image) onto background
	background.blit_rect_mask(
		RealImage,
		RealImage,
		Rect2i(
			0,
			0,
			RealImage.get_width(),
			RealImage.get_height()),
		Vector2i(
			0,
			0
		)
	)
	background.flip_y()
	# save image
	if not path.ends_with(".png") and not path.ends_with(".PNG"):
		background.save_png(path + ".png")
	else:
		background.save_png(path)

func get_counter():
	while FileAccess.file_exists(Global.SAVE_PATH + "fractal" + str(file_counter) + ".png"):
		file_counter += 1

# change centering picture

func _on_center_button_pressed():
	open(current_ifs, CenterButton.button_pressed)

# more points!

var dragging_point_slider = false

func _on_point_slider_value_changed(value):
	# set new point limit
	limit = value
	# if too many points:
	## restart
	if counter > limit and not dragging_point_slider:
		open(current_ifs)

func _on_point_slider_drag_started():
	dragging_point_slider = true

func _on_point_slider_drag_ended(_value_changed):
	dragging_point_slider = false
	_on_point_slider_value_changed(PointSlider.value)

# more clarity!

func _on_delay_slider_value_changed(value):
	delay = value
	open(current_ifs)

# background color

func _on_color_button_pressed():
	if ColorBar.visible:
		ColorBar.hide()
	else:
		ColorBar.load_color(ResultBackground.self_modulate)
		ColorBar.show()

func _on_color_picker_color_changed(new_color):
	ResultBackground.self_modulate = new_color

func _on_color_bar_finished():
	ColorBar.hide()

# size options

func _on_size_button_pressed():
	if not SizeOptions.visible:
		var image = Result.get_texture().get_image()
		SizeOptions.load_ui(
			Vector2i(image.get_width(), image.get_height())
		)
		SizeOptions.show()
	else:
		SizeOptions.hide()

func _on_size_options_value_changed():
	resize_image(SizeOptions.read_ui())
