extends MarginContainer

@onready var ImagePreview = $Container/Content/MarginContainer/Lines/ImagePreview
@onready var GalleryAdressLabel = $Container/Content/MarginContainer/Lines/GalleryAdressLabel

@onready var GalleryContact = $GalleryContact

var current_image

func _ready():
	GalleryAdressLabel.text = Global.GALLERY_ADRESS

func open(image):
	current_image = image
	var preview_image = current_image.duplicate()
	preview_image.resize(ImagePreview.custom_minimum_size.x, ImagePreview.custom_minimum_size.y)
	ImagePreview.set_texture(ImageTexture.create_from_image(preview_image))
	show()

func _on_ready_button_pressed():
	GalleryContact.send_image(current_image)
	hide()

func _on_close_button_pressed():
	hide()
