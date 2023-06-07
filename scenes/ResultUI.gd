extends Control

@onready var Result = $Center/Result
@onready var SaveButton = $Right/Lines/SaveButton
@onready var MoreButton = $Right/Lines/MoreButton

var current_ifs = IFS.new()
var current_loupe = Global.LOUPE
var counter = 0

func _ready():
	var viewport_size = get_viewport().get_size()
	current_loupe = min(viewport_size.x - 2 * 16 - 2 * 16, viewport_size.y - 2 * 16) * Vector2i(1,1)
	SizeOptions.load_ui(current_loupe)

func open(ifs, reload_size):
	current_ifs = ifs
	var results = ifs.calculate_fractal()
	# load size
	if reload_size:
		SizeOptions.load_ui(Global.LOUPE)
	# create empty, white image
	var image = Image.create(current_loupe.x, current_loupe.y, false, Image.FORMAT_RGB8) # empty
	image.fill(Color.WHITE) # white
	Result.custom_minimum_size = current_loupe
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
			entry.position.x * current_loupe.x,
			entry.position.y * current_loupe.y
		)
		if real_position.x >= 0 and real_position.x < current_loupe.x:
			if real_position.y >= 0 and real_position.y < current_loupe.y:
				image.set_pixel(real_position.x, real_position.y, entry.color)
	# set image
	Result.set_texture(ImageTexture.create_from_image(image))

func _on_back_button_pressed():
	self.get_parent().show_playground()
	_on_size_options_close_me()

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


# changing result size

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
