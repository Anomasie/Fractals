extends MarginContainer

signal start_tutorial

const EXPLANATIONS = {
	"fractal": {
		"GER": "Fraktal",
		"EN": "fractal",
		"text": {
			"GER": "Fraktale sind eine Art von Objekten, die vieles in der Natur widerspiegeln können, \
beispielsweise das Aussehen von Wolken oder die Blattstruktur eines Farns. \
Sie haben eine „gebrochene Dimension“ und können nicht einfach aus einzelnen Punkten, \
Kurven und Flächen zusammengesetzt werden. Viele Fraktale haben die Eigenschaft, selbstähnlich zu sein. \
Sie bestehen also aus mehreren kleinen Kopien von sich selbst. \n\n\
Um ein Fraktal zu erzeugen, benutzt diese Website sogenannte iterierte Funktionensysteme \
aus affinen Abbildungen."
		}
	},
	"ifs": {
		"GER": "IFS",
		"EN": "IFS",
		"text": {
			"GER": "Wir wollen ein Fraktal in der Ebene, im ℝ², erstellen. Dazu benötigen wir zunächst \
affine Abbildungen. Das sind Abbildungen, die strecken oder stauchen, \
verschieben, spiegeln oder drehen, in beliebiger Kombination. Sie machen \
Quadrate zu Rechtecken. Um diese Abbildungen zu veranschaulichen, kann man \
sich beispielsweise ansehen, was sie mit dem Einheitsquadrat tun. Endlich \
viele dieser Abbildungen ergeben ein iteriertes Funktionensystem (IFS)."
		}
	}
}

@onready var CursorTexture = load("res://assets/gui/cursor.png")

@onready var Informations = $Margin/Content/Lines/Splitter/Informations
@onready var InfoLabel = $Margin/Content/Lines/Splitter/InfoLabel

var current_info = 0

func _ready():
	for i in len(EXPLANATIONS.keys()):
		# set up button
		var button = Button.new()
		button.name = EXPLANATIONS.keys()[i]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_info_button_pressed.bind(i))
		button.clip_text = true
		# set language
		if EXPLANATIONS[EXPLANATIONS.keys()[i]].has(Global.language):
			button.text =EXPLANATIONS[EXPLANATIONS.keys()[i]][Global.language]
		else:
			button.text = "ERROR in HelpOptions, _ready: no text found for button " + button.name
		# add button
		Informations.add_child(button)

func open():
	set_focus()
	load_text()
	show()

func load_text():
	if EXPLANATIONS[Informations.get_child(current_info).name]["text"].has(Global.language):
		InfoLabel.text = EXPLANATIONS[Informations.get_child(current_info).name]["text"][Global.language]
	else:
		InfoLabel.text = "ERROR in HelpOptions, _ready: no text found for button " + Informations.get_child(current_info).name

func set_focus():
	for i in len(Informations.get_children()):
		if i == current_info:
			Informations.get_child(i).icon = CursorTexture
		else:
			Informations.get_child(i).icon = null

func reload_language():
	# info-buttons
	for button in Informations.get_children():
		match Global.language:
			"GER":
				button.tooltip_text = "Informationen über " + EXPLANATIONS[button.name]["GER"]
			_:
				button.tooltip_text = "informations about " + EXPLANATIONS[button.name]["EN"]
		button.text = EXPLANATIONS[button.name][Global.language]
	# info-text
	load_text()

# signals

func _on_close_button_pressed():
	hide()

func _on_info_button_pressed(pressed_one):
	for i in len(Informations.get_children()):
		if i == pressed_one:
			current_info = i
	set_focus()
	load_text()

func _on_tutorial_button_pressed():
	start_tutorial.emit()
