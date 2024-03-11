extends MarginContainer

signal sent_away
signal sent_successfully
signal sent_unsuccessfully
signal no_connection_to_server

@onready var ImagePreview = $Container/Content/MarginContainer/Lines/ImagePreview
@onready var GalleryAdressLabel = $Container/Content/MarginContainer/Lines/GalleryAdressLabel

@onready var DescriptionLabel = $Container/Content/MarginContainer/Lines/Tabular/DescriptionLabel
@onready var DescriptionEdit = $Container/Content/MarginContainer/Lines/Tabular/DescriptionEdit
@onready var NameLabel = $Container/Content/MarginContainer/Lines/Tabular/NameLabel
@onready var NameEdit = $Container/Content/MarginContainer/Lines/Tabular/NameEdit
@onready var VenueLabel = $Container/Content/MarginContainer/Lines/Tabular/VenueLabel
@onready var VenueEdit = $Container/Content/MarginContainer/Lines/Tabular/VenueEdit

@onready var ReadyButton = $Container/Content/MarginContainer/Lines/ReadyButton
@onready var CloseButton = $Container/CloseButton

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
	var string = ifs.background_color.to_html()
	for contraction in ifs.systems:
		string += "|"
		string += str(contraction.translation.x) + "," + str(contraction.translation.y) + ","
		string += str(contraction.contract.x) + "," + str(contraction.contract.y) + ","
		string += str(contraction.rotation) + ","
		string += str(int(contraction.mirrored)) + ","
		string += contraction.color.to_html(false)
	return string

func get_ifs(meta_data):
	if meta_data:
		var units = meta_data.split("|", false)
		if len(units) > 0:
			if not Color.html_is_valid(units[0]): # no background color saved :(
				var old_units = units.duplicate()
				units = [Color.WHITE.to_html()] # set it to white
				units.append_array(old_units)
			var systems = []
			for i in len(units)-1:
				var entries = units[i+1].split(",", false)
				if len(entries) < 6: # someone messed up the url! >:(
					return
				var contraction = Contraction.new()
				contraction.translation = Vector2(float(entries[0]), float(entries[1]))
				contraction.contract = Vector2(float(entries[2]), float(entries[3]))
				contraction.rotation = float(entries[4])
				contraction.mirrored = (entries[5] in ["1", "true"])
				contraction.color = Color.from_string(entries[6], Color.BLACK) # black is default
				systems.append(contraction)
			var ifs = IFS.new()
			ifs.systems = systems
			ifs.background_color = Color.from_string(units[0], Color.WHITE)
			return ifs

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
			# Close Button
			CloseButton.tooltip_text = "close without sending"
