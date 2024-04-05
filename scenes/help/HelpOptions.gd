extends MarginContainer

const EXPLANATIONS = {
	"fractal": {
		"GER": "Fraktal",
		"EN": "fractal",
		"text": {
			"GER": "Fraktale sind eine Art von Objekten, die vieles in der Natur widerspiegeln können, \
beispielsweise das Aussehen von Wolken oder die Blattstruktur eines Farns. \
Sie haben eine „gebrochene Dimension“ und können nicht einfach aus separierten Punkten, \
Kurven und Flächen zusammengesetzt werden. \
Viele Fraktale haben die Eigenschaft, selbstähnlich zu sein. \
Sie bestehen also aus mehreren kleinen Kopien von sich selbst. \n\n\
Um ein Fraktal zu erzeugen, benutzt diese Website sogenannte iterierte Funktionensysteme \
aus affinen Abbildungen.",
			"EN": "Fractals are a type of object which can mirror many different structures in nature, \
for example clouds or the leaf structure of some ferns. \
They have a dimension which is „fractional“, so they cannot be created by combining finitely many points, \
curves or areas. \
Many fractals are self-similar, which means that they consist of small copies of themselves. \
One way to produce a fractal is to make use of what is called an iterated function system consisting of \
affine maps."
		}
	},
	"ifs": {
		"GER": "IFS",
		"EN": "IFS",
		"text": {
			"GER": "Wir wollen ein Fraktal in der Ebene erstellen. \
Dazu benutzen wir sogenannte affine Abbildungen. \
Das sind Abbildungen, die strecken oder stauchen, \
verschieben, spiegeln oder drehen, in beliebiger Kombination. \
Sie machen Quadrate zu Rechtecken.\n\
Um diese Abbildungen zu veranschaulichen, kann man \
sich beispielsweise ansehen, was sie mit dem Einheitsquadrat tun. \
Endlich viele dieser Abbildungen ergeben ein iteriertes Funktionensystem (IFS).\n\n\
Das Fraktal auf der rechten (bzw. unteren) Seite des Bildschirms entsteht durch das zugehörige IFS auf der \
linken (bzw. oberen) Seite des Bildschirms. \
Jedes Rechteck stellt die Verzerrung des Einheitsquadrates unter einer Funktion des IFS dar.",
		"EN": "Our goal is to create a fractal on a plane. \
We will accomplish this by using so-called affine maps. \
These are functions which stretch or shrink, translate, mirror or rotate, in arbitrary combinations.\n\
One way to illustrate a particular affine map is to examine the effect of the mapping on the unit square. \
Affine maps will map sqares to rectangles. \
Finitely many of those functions are called an iterated function system (IFS).\n\n\
In this program, the IFS used to produce the fractal on the right (or bottom) side of the page \
consists of the functions each represented by a small rectangle on the left (or top) side of the page. \
Each rectangle depicts the image of the unit square under one function in the IFS."
		}
	},
	"calculation": {
		"GER": "Verfahren",
		"EN": "calculation",
		"text": {
			"GER": "Wenn Fraktale mit einem Programm \
berechnet werden sollen, bietet sich das Zufallspunkt-Verfahren an. \
Dabei beginnen wir, indem wir einen zufälligen Punkt p଴ auf eine Ebene zeichnen. \
Das Verfahren besteht aus den folgenden Schritten.\n\n\
1. Wähle zufällig eine der Funktionen aus dem iterierten Funktionensystem aus, z. B. die Funktion f.\n\n\
2. Setze f(p) =: p' und zeichne ihn auf die Ebene, auf der schon p ist.\n\n\
3. Wähle zufällig eine neue Funktion aus, zum Beispiel die Funktion g.\n\n\
4. Setze g(p') =: p'' und zeichne ihn zu p und p'.\n\n\
5. Wiederhole das so lange, bis du genug Punkte für eine detaillierte Zeichnung
bestimmt hast.",
			"EN": "The method of random points is a good way to draw a fractal with a program.\
This method begins by taking a random point p and drawing it on the plane. \
It proceeds by the following steps. \n\n\
1. Choose a random function of your IFS, for example f.\n\n\
2. Let f(p) =: p' and draw p' on the same plane on which p already is.\n\n\
3. Choose another random function of your IFS, say, g.\n\n\
4. Let g(p') =: p''. Draw p'' in addition to p and p'. \n\n\
5. Repeat this procedure until you are satisfied with the number of points."
		}
	},
	"delay": {
		"GER": "Verzögerung\nbeim Zeichnen\nder Punkte",
		"EN": "delay",
		"text": {
			"GER": "Während des Zufallspunktverfahrens können die ersten Punkte \
eventuell noch etwas neben dem eigentlichen Fraktal liegen: \
wir haben die Zufallspunkt-Methode mit einem beliebigen Punkt begonnen; natürlich muss dieser \
zufällige Punkt nicht unbedingt in dem Fraktal liegen, das wir zeichnen wollen.\n\
Dieser Fehler wird nach wenigen Schritten so gering sein, dass wir ihn \
mit dem Auge (bzw. der Computer mit seiner Bildschirmauflösung) nicht mehr wahrnehmen können. \
Eine Möglichkeit, diesen Fehler unsichtbar zu machen, \
ist zum Beispiel, die ersten hundert Punkte nicht zu zeichnen.\n\n\
Auch wenn diese ersten Punkte nicht zum Fraktal gehören, das von dem IFS erzeugt wird, \
kann sich durch das Zeichnen dieser Punkte durchaus interessante Formen ergeben.",
			"EN": "Since we started with a random point, \
it might be the case that the first points drawn do not actually belong to the fractal we want to draw.\n\
However, after a few steps of the method, the error caused by this initial misstep \
will be invisible to the human eye (or to your computer's desktop resolution). 
One possible solution is to not draw the first hundred points calculated.\n\n\
Even though those first points do not necessarily belong to the fractal associated with the IFS,
drawing them can lead to interesting pictures and effects."
		}
	},
	"contact": {
		"GER": "Kontakt",
		"EN": "contact",
		"text": {
			"GER": "Ich freue mich über jegliche Rückmeldungen mit Anmerkungen oder Ideen, Bugs oder Fehlern.

Kontakt:
	Marta Imke
	marta.imke@uni-jena.de
	Friedrich-Schiller-Universität Jena

Lizenz:
	GNU General Public license, Version 3

Github-Seite:
	https://github.com/Anomasie/Fractals",
			"EN": "I look forward to all feedback with comments or ideas, bugs and errors on this page.

contact:
	Marta Imke
	marta.imke@uni-jena.de
	Friedrich-Schiller-Universität Jena

license:
	GNU General Public license, Version 3

github page:
	https://github.com/Anomasie/Fractals",
		}
	},
	"credits": {
		"GER": "Credits",
		"EN": "credits",
		"text": {
			"GER": "",
			"EN": ""
		}
	}
}

const ADDITIONAL_TEXT = {
	
}

@onready var CursorTexture = load("res://assets/gui/cursor.png")

@onready var TitleLabel = $Top/Conent/TitleLabel
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
			button.text = "???"
			print("ERROR in HelpOptions, _ready: no name found for button " + button.name)
		# add button
		Informations.add_child(button)
	set_focus()

func open():
	set_focus()
	load_text()
	show()

func load_text():
	if EXPLANATIONS[Informations.get_child(current_info).name]["text"].has(Global.language):
		InfoLabel.text = EXPLANATIONS[Informations.get_child(current_info).name]["text"][Global.language]
	else:
		InfoLabel.text = "no text available"
		print("ERROR in HelpOptions, load_text: no text found for button " + Informations.get_child(current_info).name)

func set_focus():
	for i in len(Informations.get_children()):
		if i == current_info:
			Informations.get_child(i).icon = CursorTexture
		else:
			Informations.get_child(i).icon = null

func reload_language():
	# tutorial-buggon
	match Global.language:
		"GER":
			TitleLabel.text = "Allgemeine Informationen"
		_:
			TitleLabel.text = "general informations"
	# info-buttons
	for button in Informations.get_children():
		match Global.language:
			"GER":
				if EXPLANATIONS[button.name].has(Global.language):
					button.text = EXPLANATIONS[button.name][Global.language]
					button.tooltip_text = "Informationen über " + EXPLANATIONS[button.name][Global.language]
				else:
					button.text = "???"
					print("ERROR in HelpOptions, _ready: no name found for button " + button.name)
			_:
				if EXPLANATIONS[button.name].has(Global.language):
					button.text =EXPLANATIONS[button.name][Global.language]
					button.tooltip_text = "informations about " + EXPLANATIONS[button.name][Global.language]
				else:
					button.text = "???"
					print("ERROR in HelpOptions, _ready: no name found for button " + button.name)
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
