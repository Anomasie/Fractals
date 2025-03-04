extends MarginContainer

signal fractal_changed
signal fractal_changed_vastly
signal store_to_url
signal dont_upload_empty_fractal
signal dont_upload_already_uploaded_fractal
signal suggest_changing_background_color
signal suggest_centered_view

@warning_ignore("unused_signal")
signal debug

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
@onready var PointLineEdit = $Columns/Left/Bottom/Lines/PointLineEdit

@onready var DelaySlider = $Columns/Left/Bottom/Lines/DelaySlider
@onready var DelayTexture1 = $Columns/Left/Bottom/Lines/DelayTexture1
@onready var DelayTexture2 = $Columns/Left/Bottom/Lines/DelayTexture2
@onready var DelayLineEdit = $Columns/Left/Bottom/Lines/Sep/DelayLineEdit

@onready var ReusingLastPointButton = $Columns/Left/Bottom/Lines/Sep/ReusingLastPointButton

@onready var ShareDialogue

var RealImage
var image_size = current_loupe

var current_ifs = IFS.new()
var current_loupe = Global.LOUPE

var current_stretch_mapping = Contraction.new()
var current_stretch_inverse = Contraction.new()

var limit = 0
var frame_limit = 1000 # to manage frame performance
var max_frame_limit = 100000
var frame_step = 100
var counter = 0

var new_ifs
var new_ifs_centered
var new_ifs_overwrite_ui

var first_frame = false
var last_point = point.new()

var loading_ifs = false

const MINIMUM_POINTS_FOR_ULOAD = 10
const MAXIMUM_POINT_COUNTER = 1000
var drawn_point_counter = 0

const MINIMUM_RECT_SIZE = 0.1


var file_counter = 0

func _ready():
	# set values
	## PointTeller (ActualValueSlider)
	PointSlider.value = point_slider_descaled(Global.DEFAULT_POINTS)
	limit = Global.DEFAULT_POINTS
	PointTeller.min_value = PointSlider.min_value
	PointTeller.max_value = PointSlider.max_value
	PointTeller.value = 0
	PointLineEdit.placeholder_text = str(limit)
	CenterButton.set_value(false)
	## other sliders
	DelaySlider.value = Global.DEFAULT_DELAY
	DelayLineEdit.placeholder_text = str(current_ifs.delay)
	# hide & show
	SaveFileDialog.close()
	ColorSliders.hide()
	SizeOptions.hide()
	resize()
	# tooltips
	Global.tooltip_nodes.append_array([
		Result,
		PointTexture1, PointSlider, PointTexture2, PointLineEdit,
		DelayTexture1, DelaySlider, DelayTexture2, DelayLineEdit,
		ColorButton, ShareButton, SaveButton, SizeButton,
		SaveFileDialog
	])

func _process(delta):
	if new_ifs:
		open_new_ifs()
	
	if limit < 0 or counter < limit:
		# decide how many points to be calculated in one frame
		if len(current_ifs.systems) > 0:
			if delta > 1.0/15: # too slow
				frame_limit = max(0, frame_limit-frame_step)
			if delta < 1.0/30: # fast enough
				frame_limit = min(frame_limit+frame_step, max_frame_limit)
				
		# calculate more points
		## how many?
		var amount = frame_limit
		if limit >= 0:
			amount = min(frame_limit, limit-counter)
		counter += amount
		## paint them
		if current_ifs.reusing_last_point:
			var points
			if first_frame: # delay
				var first_point = point.new()
				first_point.color = current_ifs.background_color
				points = current_ifs.calculate_fractal( first_point, amount)
			else: # no delay
				points = current_ifs.calculate_fractal( last_point, amount, 0)
			if len(points) > 0:
				last_point = points[-1]
			first_frame = false
			paint(points)
		else:
			var first_point = point.new()
			first_point.color = current_ifs.background_color
			paint(current_ifs.calculate_fractal( first_point, amount))
		## update slider
		PointTeller.value = point_slider_descaled(counter)

func get_ifs(ifs = current_ifs) -> IFS:
	ifs.delay = DelaySlider.value
	ifs.centered_view = CenterButton.on
	ifs.reusing_last_point = ReusingLastPointButton.on
	ifs.background_color = ColorSliders.get_color()
	return ifs

func update_stretch_mapping() -> void:
	var results = []
	if len(current_ifs.systems) > 1:
		results = current_ifs.calculate_fractal(point.new(), 2000, 1000) # ignore first delay
	else:
		for _i in 50:
			results += current_ifs.calculate_fractal(point.new(), 10+current_ifs.delay, current_ifs.delay) # ignore first delay
	# get minimum and maximum in current results
	var rect = Rect2(Vector2i(0,0), Vector2i(0,0))
	if len(results) > 0:
		rect = Rect2(results[0].position, Vector2i(0,0))
	for entry in results:
		rect = rect.expand(entry.position)
	# set current_origin and current_size
	## get length
	var length = max(rect.size.x, rect.size.y)
	if length == 0: length = 1
	# set origin
	## shift origin such that boundaries are left and right
	## shift origin such that fractal is centered
	current_stretch_mapping.translation = rect.position - Vector2(1,1) * length / 10 / 2 - length/2 * Vector2(1,1) + rect.size / 2
	current_stretch_mapping.contract = (length * 1.1) * Vector2(1,1)

func update_stretch_inverse() -> void:
	update_stretch_mapping()
	current_stretch_inverse = current_stretch_mapping.get_inverse()

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

func open(ifs, overwrite_ui=false, overwrite_centered=false):
	drawn_point_counter = 0
	first_frame = true
	new_ifs = ifs
	new_ifs_overwrite_ui = overwrite_ui
	if overwrite_ui and not overwrite_centered:
		new_ifs.centered_view = CenterButton.on
	
	if not overwrite_ui:
		new_ifs.reusing_last_point = ReusingLastPointButton.on
		new_ifs.centered_view = CenterButton.on

func open_new_ifs():
	var ifs = new_ifs
	new_ifs = null
	current_ifs = ifs
	
	# overwrite ui?
	if new_ifs_overwrite_ui:
		loading_ifs = true
		DelaySlider.value = current_ifs.delay
		ReusingLastPointButton.set_value(current_ifs.reusing_last_point)
		CenterButton.set_value(current_ifs.centered_view)
		load_color(current_ifs.background_color)
		loading_ifs = false
		new_ifs_overwrite_ui = false
	else:
		# background color
		current_ifs.background_color = ResultBackground.self_modulate
	
	# create empty, white image
	var image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT) # white
	# "save" image
	RealImage = image
	# scale image for Results:
	Result.custom_minimum_size = current_loupe
	Result.set_texture(ImageTexture.create_from_image(image))
	# reload center mapping
	update_stretch_inverse()
	# set counter
	counter = 0

func paint(results, centered=current_ifs.centered_view):
	# paint image
	## centered view
	if centered:
		# loupe
		# paint
		for entry in results:
			var real_position = current_stretch_inverse.apply(entry.position)
			var pixel_position = Vector2i(
				real_position.x * image_size.x,
				real_position.y * image_size.y
			)
			if pixel_position.x >= 0 and pixel_position.x < RealImage.get_width():
				if pixel_position.y >= 0 and pixel_position.y < RealImage.get_height():
					if drawn_point_counter < MAXIMUM_POINT_COUNTER:
						if not Math.are_equal_approx(
							entry.color, RealImage.get_pixel(pixel_position.x, pixel_position.y)
						) and not Math.are_equal_approx(entry.color, current_ifs.background_color):
							drawn_point_counter += 1
					RealImage.set_pixel(pixel_position.x, pixel_position.y, entry.color)
	## normal view: not centered
	else:
		for entry in results:
			var pixel_position = Vector2i(
				entry.position.x * image_size.x,
				entry.position.y * image_size.y
			)
			if pixel_position.x >= 0 and pixel_position.x < image_size.x:
				if pixel_position.y >= 0 and pixel_position.y < image_size.y:
					if drawn_point_counter < MAXIMUM_POINT_COUNTER:
						if not Math.are_equal_approx(
							entry.color, RealImage.get_pixel(pixel_position.x, pixel_position.y)
						) and not Math.are_equal_approx(entry.color, current_ifs.background_color):
							drawn_point_counter += 1
					RealImage.set_pixel(pixel_position.x, pixel_position.y, entry.color)
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
	# check if fractal is valid:
	if drawn_point_counter < MINIMUM_POINTS_FOR_ULOAD:
		dont_upload_empty_fractal.emit()
	elif len(current_ifs.systems) == 0:
		dont_upload_empty_fractal.emit()
	elif Global.already_uploaded(current_ifs.to_meta_data()):
		dont_upload_already_uploaded_fractal.emit()
	else:
		if drawn_point_counter < MAXIMUM_POINT_COUNTER:
			suggest_centered_view.emit()
		elif Math.are_equal_approx(current_ifs.background_color, Color.WHITE):
			suggest_changing_background_color.emit()
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
	current_ifs.centered_view = CenterButton.on
	open(current_ifs)
	fractal_changed.emit()
	fractal_changed_vastly.emit()

# more points!

var dragging_point_slider = false

func _on_point_slider_value_changed(_value=null):
	# set new point limit
	limit = point_slider_scaled()
	PointLineEdit.placeholder_text = str(limit)
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
	fractal_changed_vastly.emit()

# more clarity!

func _on_delay_slider_value_changed(value):
	if not loading_ifs and value != current_ifs.delay:
		fractal_changed.emit()
		current_ifs.delay = value
		DelayLineEdit.placeholder_text = str(current_ifs.delay)
		open(current_ifs)
		reload_language()

func _on_delay_slider_drag_ended(_value_changed: bool) -> void:
	fractal_changed_vastly.emit()

## enter exact digits for points and delay

func _on_point_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		_on_point_slider_value_changed()
		fractal_changed_vastly.emit()
	
	var value
	if new_text in [-1, "infty", "infinity", "infinite", "inf", "unendlich"]:
		value = -1
		PointSlider.value = PointSlider.max_value
	else:
		value = int(new_text)
		PointSlider.value = point_slider_descaled(value)
	_on_point_slider_value_changed()
	# set text
	PointLineEdit.placeholder_text = str(value)
	PointLineEdit.text = ""

func _on_delay_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		_on_delay_slider_value_changed(DelaySlider.value)
		fractal_changed_vastly.emit()
	
	var value = int(new_text)
	DelaySlider.value = value
	_on_delay_slider_value_changed(DelaySlider.value)
	# set text
	DelayLineEdit.placeholder_text = str(DelaySlider.value)
	DelayLineEdit.text = ""

# background color

func load_color(color):
	ResultBackground.self_modulate = color
	current_ifs.background_color = color
	if ColorSliders.visible:
		ColorSliders.open(color)
	else:
		ColorSliders.set_color(color)

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

# re-usage of last calculated point

func _on_reusing_last_point_button_pressed() -> void:
	current_ifs.reusing_last_point = ReusingLastPointButton.on
	fractal_changed.emit()
	fractal_changed_vastly.emit()
	open(current_ifs)

# language & translation

func reload_language():
	match Global.language:
		"GER":
			# Result
			Result.tooltip_text = "aktuelles Fraktal"
			# Sliders
			## Point slider
			PointTexture1.tooltip_text = "zeichne 0 Punkte"
			if limit >= 0:
				PointSlider.tooltip_text = "ändere maximale Anzahl der Punkte. Aktuell: " + str(limit) + " Punkte."
			else:
				PointSlider.tooltip_text = "ändere maximale Anzahl der Punkte. Aktuell: unendlich"
			PointTexture2.tooltip_text = "berechne Punkte ohne Limit"
			PointLineEdit.tooltip_text = "aktuelle Anzahl zu berechnender Punkte"
			## Delay slider
			DelayTexture1.tooltip_text = "zeichne alle Punkte"
			DelaySlider.tooltip_text = "Anzahl der Punkte, die vor dem Zeichnen berechnet werden. Aktuell: " + str(DelaySlider.value) + " Punkte."
			DelayTexture2.tooltip_text = "Verzögerung von 100 Punkten"
			DelayLineEdit.tooltip_text = "aktuelle Verzögerung"
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
			PointTexture1.tooltip_text = "draw 0 points"
			if limit >= 0:
				PointSlider.tooltip_text = "change point limit. Current value: " + str(limit) + " points."
			else:
				PointSlider.tooltip_text = "change point limit. Current value: infinity"
			PointTexture2.tooltip_text = "do not stop calculating points"
			PointLineEdit.tooltip_text = "current point limit"
			## Delay slider
			DelayTexture1.tooltip_text = "draw all points"
			DelaySlider.tooltip_text = "change amount of points which will be calculated before drawing to avoid \"stray points\". Current value: " + str(DelaySlider.value) + " points."
			DelayTexture2.tooltip_text = "delay of 100 points"
			DelayLineEdit.tooltip_text = "current delay"
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
	ReusingLastPointButton.reload_language()


func _on_color_sliders_color_changed_vastly() -> void:
	fractal_changed_vastly.emit()
