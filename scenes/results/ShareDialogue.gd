extends MarginContainer

signal sent_away
signal sent_successfully
signal sent_unsuccessfully
signal no_connection_to_server

@onready var ImagePreview = $Container/Content/MarginContainer/Lines/ImagePreview
@onready var GalleryAdressLabel = $Container/Content/MarginContainer/Lines/GalleryAdressLabel

@onready var Margin = $Container/Content/MarginContainer

@onready var DescriptionLabel = $Container/Content/MarginContainer/Lines/Tabular/DescriptionLabel
@onready var DescriptionEdit = $Container/Content/MarginContainer/Lines/Tabular/DescriptionEdit
@onready var NameLabel = $Container/Content/MarginContainer/Lines/Tabular/NameLabel
@onready var NameEdit = $Container/Content/MarginContainer/Lines/Tabular/NameEdit
@onready var VenueLabel = $Container/Content/MarginContainer/Lines/Tabular/VenueLabel
@onready var VenueEdit = $Container/Content/MarginContainer/Lines/Tabular/VenueEdit
@onready var LegalLabel = $Container/Content/MarginContainer/Lines/LegalLabel

@onready var ReadyButton = $Container/Content/MarginContainer/Lines/ReadyButton
@onready var CloseButton = $Container/CloseButton

@onready var GalleryContact = $GalleryContact

var current_image
var current_meta

func _ready():
	GalleryAdressLabel.text = Global.GALLERY_ADRESS
	# tooltips
	Global.tooltip_nodes.append_array([
		ImagePreview,
		DescriptionEdit, NameEdit, VenueEdit,
		CloseButton
	])

func open(image, ifs):
	current_image = image
	current_meta = ifs.to_meta_data()
	var preview_image = current_image.duplicate()
	preview_image.resize(ImagePreview.custom_minimum_size.x, ImagePreview.custom_minimum_size.y)
	ImagePreview.set_texture(ImageTexture.create_from_image(preview_image))
	show()

func _on_ready_button_pressed():
	GalleryContact.send_image(
		current_image,
		DescriptionEdit.text,
		NameEdit.text,
		VenueEdit.text,
		current_meta
	)
	hide()
	sent_away.emit()

func _on_close_button_pressed():
	hide()

func _on_gallery_contact_sent_successfully():
	sent_successfully.emit()

func _on_gallery_contact_sent_unsuccessfully(response_code):
	sent_unsuccessfully.emit(response_code)

func _on_gallery_contact_no_connection_to_server(result):
	no_connection_to_server.emit(result)

# language & translation

func reload_language():
	match Global.language:
		"GER":
			# preview
			ImagePreview.tooltip_text = "Bild, das an die Galerie gesendet wird"
			# description
			DescriptionLabel.text = "Beschreibung"
			DescriptionEdit.placeholder_text = "mein Lieblingsfraktal"
			DescriptionEdit.tooltip_text = "gib die Bildbeschreibung hier ein"
			# name
			NameLabel.text = "erstellt von"
			NameEdit.tooltip_text = "gib hier dein Pseudonym ein"
			NameEdit.placeholder_text = "mein Name"
			# venue
			VenueLabel.text = "Event"
			VenueEdit.tooltip_text = "gib hier das Event ein, auf dem du das Fraktal erstellt hast (falls vorhanden)"
			VenueEdit.placeholder_text = "keines"
			# Ready Button
			ReadyButton.text = "Sende Bild an Galerie"
			# GalleryAdress label
			GalleryAdressLabel.tooltip_text = "Link zur Galerie"
			# Legal label
			LegalLabel.text = "Alle Fraktale in der Galerie dürfen von allen benutzt und verändert werden."
			# Close Button
			CloseButton.tooltip_text = "abbrechen"
		_:
			# preview
			ImagePreview.tooltip_text = "image you are about to send to the gallery"
			# description
			DescriptionLabel.text = "Description"
			DescriptionEdit.placeholder_text = "my favorite fractal"
			DescriptionEdit.tooltip_text = "enter description here"
			# name
			NameLabel.text = "Nickname"
			NameEdit.tooltip_text = "enter your nickname here"
			NameEdit.placeholder_text = "my name"
			# venue
			VenueLabel.text = "Venue"
			VenueEdit.tooltip_text = "enter venue here (if existing)"
			VenueEdit.placeholder_text = "none"
			# Ready Button
			ReadyButton.text = "Share on website"
			# GalleryAdress label
			GalleryAdressLabel.tooltip_text = "link to gallery"
			# Legal label
			LegalLabel.text = "All fractals uploaded to the gallery are free to use and modify for everyone."
			# Close Button
			CloseButton.tooltip_text = "close without sending"
