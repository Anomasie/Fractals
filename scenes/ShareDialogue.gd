extends MarginContainer

@onready var ImagePreview = $Container/Content/MarginContainer/Lines/ImagePreview
@onready var GalleryAdressLabel = $Container/Content/MarginContainer/Lines/GalleryAdressLabel

@onready var DescriptionEdit = $Container/Content/MarginContainer/Lines/Tabular/DescriptionEdit
@onready var NameEdit = $Container/Content/MarginContainer/Lines/Tabular/NameEdit
@onready var VenueEdit = $Container/Content/MarginContainer/Lines/Tabular/VenueEdit

@onready var GalleryContact = $GalleryContact

var current_image
var current_meta

func _ready():
	GalleryAdressLabel.text = Global.GALLERY_ADRESS

func open(image, ifs):
	current_image = image
	current_meta = get_meta_data(ifs)
	var preview_image = current_image.duplicate()
	preview_image.resize(ImagePreview.custom_minimum_size.x, ImagePreview.custom_minimum_size.y)
	ImagePreview.set_texture(ImageTexture.create_from_image(preview_image))
	show()

func get_meta_data(ifs):
	var string = ""
	for contraction in ifs.systems:
		string += str(contraction.translation.x) + "," + str(contraction.translation.y) + ","
		string += str(contraction.contract.x) + "," + str(contraction.contract.y) + ","
		string += str(contraction.rotation) + ","
		string += str(contraction.mirrored) + ","
		string += contraction.color.to_html(false) + "|"
	return string

func get_ifs(meta_data):
	return

func _on_ready_button_pressed():
	GalleryContact.send_image(
		current_image,
		DescriptionEdit.text,
		NameEdit.text,
		VenueEdit.text,
		current_meta
	)
	hide()

func _on_close_button_pressed():
	hide()
