extends MarginContainer

signal fractal_changed
signal store_to_url

@onready var Result = $Columns/Left/Center/Result
@onready var ResultBackground = $Columns/Left/Center/ResultBackground

@onready var SaveButton = $Columns/Right/Top/Main/SaveButton
@onready var SaveFileDialog = $Columns/Right/Top/SaveFileDialog
@onready var ShareButton = $Columns/Right/Top/Main/ShareButton
@onready var CenterButton = $Columns/Right/Top/Main/CenterButton
@onready var ColorButton = $Columns/Right/Top/Main/ColorButton
@onready var ColorSliders = $ColorSliders
@onready var SizeButton = $Columns/Right/Top/Main/SizeButton

@onready var SizeOptions = $SizeOptions

@onready var PointSlider = $Columns/Left/Bottom/Lines/PointSlider
@onready var PointTexture1 = $Columns/Left/Bottom/Lines/PointTexture1
@onready var PointTexture2 = $Columns/Left/Bottom/Lines/PointTexture2
@onready var PointTeller = $Columns/Left/Bottom/Lines/PointSlider/ActualValueSlider

@onready var DelaySlider = $Columns/Left/Bottom/Lines/DelaySlider
@onready var DelayTexture1 = $Columns/Left/Bottom/Lines/DelayTexture1
@onready var DelayTexture2 = $Columns/Left/Bottom/Lines/DelayTexture2

@onready var ShareDialogue

var RealImage
var image_size = current_loupe

var current_ifs = IFS.new()
var current_loupe = Global.LOUPE
var current_origin = Vector2.ZERO
var current_size = 1
var file_counter = 0

func _ready():
	# set values
	## PointTeller (ActualValueSlider)
	PointSlider.value = limit
	PointTeller.min_value = PointSlider.min_value
	PointTeller.max_value = PointSlider.max_value
	PointTeller.value = 0
	## other sliders
	PointSlider.value = Global.DEFAULT_POINTS
	DelaySlider.value = Global.DEFAULT_DELAY
	# hide & show
	SaveFileDialog.close()
	ColorSliders.hide()
	SizeOptions.hide()
	resize()
	# tooltips
	Global.tooltip_nodes.append_array([
		Result,
		PointTexture1, PointSlider, PointTexture2,
		DelayTexture1, DelaySlider, DelayTexture2,
		ColorButton, ShareButton, SaveButton, SizeButton,
		SaveFileDialog
	])

var limit = 100000
var frame_limit = 1000 # to manage frame performance
var max_frame_limit = 10000
var min_frame_limit = 100
var counter = 0

var new_ifs
var new_ifs_centered

func _process(delta):
	if new_ifs:
		open_new_ifs(new_ifs_centered)
		new_ifs = null
	
	if limit < 0 or counter < limit:
		# decide how many points to be calculated in one frame
		if delta > 1.0/15: # too slow
			frame_limit = max(0, frame_limit-10)
		if delta < 1.0/30: # fast enough
			frame_limit = min(frame_limit+10, max_frame_limit)
		
		# calculate more points
		## how many?
		var amount = frame_limit
		if limit >= 0:
			amount = min(frame_limit, limit-counter)
		counter += amount
		## paint them
		paint(current_ifs.calculate_fractal( point.new(), amount), CenterButton.centered)
		## update slider
		PointTeller.value = point_slider_descaled(counter)

const POINT_LIMIT_HALF_VALUE = 1000000

func point_slider_scaled(x = float( PointSlider.value )):
	if x >= PointSlider.max_value:
		return -1
	else:
		return int(
			- log(float(PointSlider.max_value - x)/PointSlider.max_value) * POINT_LIMIT_HALF_VALUE
		)

func point_slider_descaled(y):
	if y < 0:
		return PointSlider.max_value
	else:
		return int( PointSlider.max_value * (1 - exp( - float(y) / POINT_LIMIT_HALF_VALUE )) ) + 1

func resize():
	current_loupe = Global.LOUPE
	if not SizeOptions.custom_value:
		image_size = current_loupe
		SizeOptions.load_ui(current_loupe)
	if not image_size:
		image_size = current_loupe
	open(current_ifs)

func resize_image(new_size):
	image_size = new_size
	open(current_ifs)

func open(ifs, centered=CenterButton.centered):
	new_ifs = ifs
	new_ifs_centered = centered

func open_new_ifs(centered=CenterButton.centered):
	var ifs = new_ifs
	current_ifs = ifs
	current_ifs.background_color = ResultBackground.self_modulate
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
		var results = ifs.calculate_fractal()
		# get minimum and maximum in current results
		var rect = Rect2(Vector2i(0,0), Vector2i(0,0))
		if len(results) > 0:
			rect = Rect2(results[0].position, Vector2i(0,0))
		for entry in results:
			rect = rect.expand(entry.position)
		# set current_origin and current_size
		## get length
		var length = max(rect.size.x, rect.size.y)
		# set origin
		## shift origin such that boundaries are left and right
		## shift origin such that fractal is centered
		current_origin = rect.position - Vector2(1,1) * length / 10 / 2 - Vector2(
			length - rect.size.x,
			length - rect.size.y
		) / 2
		current_size = length * 1.1
	# set counter
	counter = 0

func paint(results, centered):
	# paint image
	## centered view
	if centered:
		# loupe
		# paint
		for entry in results:
			@warning_ignore("narrowing_conversion")
			var real_position = Vector2i(
				# doesn't work anymore :(
				#remap(entry.position.x, current_origin.x, current_size, 0, image_size.x),
				#remap(entry.position.y, current_origin.y, current_size, 0, image_size.y)
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

func get_image():
	# extract images
	var image = Image.create(RealImage.get_width(), RealImage.get_height(), false, Image.FORMAT_RGBA8)
	image.fill(ResultBackground.self_modulate)
	image.convert(Image.FORMAT_RGBA8)
	# add result (image) onto background
	image.blit_rect_mask(
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
	image.flip_y()
	return image

# send image to gallery

func _on_share_button_pressed():
	store_to_url.emit()
	ShareDialogue.open(get_image(), current_ifs)

# save image locally

func _on_save_button_pressed():
	store_to_url.emit()
	if OS.has_feature("web"):
		var filename = "fractal" + str(file_counter) + ".png"
		file_counter += 1
		var buf = get_image().save_png_to_buffer()
		JavaScriptBridge.download_buffer(buf, filename)
	else:
		SaveFileDialog.open()

func save(path):
	# save image
	if not path.ends_with(".png") and not path.ends_with(".PNG"):
		get_image().save_png(path + ".png")
	else:
		get_image().save_png(path)

func _on_save_file_dialog_path_selected(path):
	save(path)

# change centering picture

func _on_center_button_pressed():
	open(current_ifs, CenterButton.centered)

# more points!

var dragging_point_slider = false

func _on_point_slider_value_changed(_value=null):
	# set new point limit
	limit = point_slider_scaled()
	# if too many points:
	## restart
	if limit >= 0 and counter > limit and not dragging_point_slider:
		open(current_ifs)
	
	reload_language()

func _on_point_slider_drag_started():
	dragging_point_slider = true

func _on_point_slider_drag_ended(_value_changed):
	dragging_point_slider = false
	_on_point_slider_value_changed()

# more clarity!

func _on_delay_slider_value_changed(value):
	fractal_changed.emit()
	current_ifs.delay = value
	open(current_ifs)
	
	reload_language()

# background color

func load_color(color):
	ResultBackground.self_modulate = color
	current_ifs.background_color = color
	if ColorSliders.visible:
		ColorSliders.open(color)

func _on_color_button_pressed():
	if ColorSliders.visible:
		ColorSliders._on_close_button_pressed()
	else:
		ColorSliders.open(ResultBackground.self_modulate)

func _on_color_sliders_color_changed():
	ResultBackground.self_modulate = ColorSliders.get_color()
	current_ifs.background_color = ResultBackground.self_modulate
	fractal_changed.emit()

func _on_color_sliders_finished():
	ColorSliders.close()

# size options

func _on_size_button_pressed():
	if not SizeOptions.visible:
		SizeOptions.show()
		if not SizeOptions.custom_value:
			var image = Result.get_texture().get_image()
			SizeOptions.load_ui( Vector2i(image.get_width(), image.get_height()) )
	else:
		SizeOptions.hide()

func _on_size_options_value_changed():
	resize_image(SizeOptions.read_ui())

# language & translation

func reload_language():
	match Global.language:
		"GER":
			# Result
			Result.tooltip_text = "aktuelles Fraktal"
			# Sliders
			## Point slider
			PointTexture1.tooltip_text = "0 Punkte"
			if limit >= 0:
				PointSlider.tooltip_text = "ändere maximale Anzahl der Punkte. Aktuell: " + str(limit)
			else:
				PointSlider.tooltip_text = "ändere maximale Anzahl der Punkte. Aktuell: unendlich"
			PointTexture2.tooltip_text = "berechne Punkte ohne Limit"
			## Delay slider
			DelayTexture1.tooltip_text = "zeichne alle Punkte"
			DelaySlider.tooltip_text = "Anzahl der Punkte, die vor dem Zeichnen berechnet werden. Aktuell: " + str(DelaySlider.value)
			DelayTexture2.tooltip_text = "Verzögerung von 100 Punkten"
			# buttons
			ColorButton.tooltip_text = "Hintergrundfarbe ändern"
			ShareButton.tooltip_text = "teile dein Bild auf " + Global.GALLERY_ADRESS
			SaveButton.tooltip_text = "Bild lokal speichern"
			SizeButton.tooltip_text = "Bildgröße ändern"
			# file dialog
			SaveFileDialog.title = "Bild speichern"
		_:
			# Result
			Result.tooltip_text = "current fractal"
			# Sliders
			## Point slider
			PointTexture1.tooltip_text = "0 points"
			if limit >= 0:
				PointSlider.tooltip_text = "change point limit. Current value: " + str(limit)
			else:
				PointSlider.tooltip_text = "change point limit. Current value: infinity"
			PointTexture2.tooltip_text = "do not stop calculating points"
			## Delay slider
			DelayTexture1.tooltip_text = "draw all points"
			DelaySlider.tooltip_text = "change amount of points which will be calculated before drawing to avoid \"stray points\". Current value: " + str(DelaySlider.value)
			DelayTexture2.tooltip_text = "delay of 100 points"
			# buttons
			ColorButton.tooltip_text = "change background color"
			ShareButton.tooltip_text = "share image in gallery"
			SaveButton.tooltip_text = "save image locally"
			SizeButton.tooltip_text = "change image size"
			# file dialog
			SaveFileDialog.title = "save image"
			
	# pass on signal
	CenterButton.reload_language()
	SizeOptions.reload_language()
	ColorSliders.reload_language()
