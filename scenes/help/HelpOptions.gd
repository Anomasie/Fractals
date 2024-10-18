extends MarginContainer

const EXPLANATIONS = {
	"fractal": {
		"GER": "Fraktal",
		"EN": "fractal",
		"tooltip": {
			"GER": "Was ist ein Fraktal?",
			"EN": "What is a fractal?"
		},
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
		"tooltip": {
			"GER": "Was ist ein IFS?",
			"EN": "What is an IFS?"
		},
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
		"tooltip": {
			"GER": "Erklärung der Punkteberechnung",
			"EN": "explanation of calculation of points"
		},
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
		"tooltip": {
			"GER": "Informationen über die Verzögerung beim Zeichnen der Punkte",
			"EN": "information about the delay in drawing the points"
		},
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
	"FAQ": {
		"GER": "FAQ",
		"EN": "FAQ",
		"tooltip": {
			"GER": "Häufig gestellte Fragen (und Antworten darauf)",
			"EN": "Frequently asked questions (and answers to them)"
		},
		"text": {
			"GER": "\
Wie kann ich meine Fraktale speichern, wenn ich sie später neu im Editor öffnen möchte?
-> Es gibt verschiedene Möglichkeiten:
- Du kannst es in die Galerie hochladen (rechts). In der Galerie gibt es die Möglichkeit, \
hochgeladene Fraktale neu im Editor zu laden. \
ACHTUNG: Bilder in der Galerie sind öffentlich und frei benutzbar für jede*n.
- Unter \"Fortgeschrittene Einstellungen (links) -> System bearbeiten (unten)\" gibt es die Möglichkeit, das \
gesamte IFS als JSON-Datei zu speichern (ganz unten). Wenn du es wieder laden möchtest, kannst du unter derselben \
Einstellung die gespeicherte JSON-Datei wieder hochladen und so das IFS laden.
- Wenn du das Programm im Web benutzt, kannst du den Link speichern. WICHTIG: Davor musst du den Link erneuert werden. \
Das geht zum Beispiel, indem du auf \"Bild lokal speichern\" klickst (unabhängig davon, ob du es danach speicherst oder nicht).

Warum ändern sich, wenn ich in der Matrix-Ansicht eine Zahl ändere, auch andere Einträge der Matrix?
-> Das liegt daran, dass die hier verwendeten Matrizen die Einheitsvektoren auf zueinander senkrechte Vektoren abbilden \
(deshalb lassen sich die Abbildungen durch Rechtecke darstellen und nicht durch unregelmäßige Vierecke). \
Eine gegebene Matrix abzutippen sollte in der Reihenfolge \"oben links, oben rechts, unten links, unten rechts\" möglich sein.

Warum sind nicht alle Werte in der geometrischen Ansicht oder der Matrix-Ansicht erlaubt?
-> Die Einträge müssen Kontraktionen ergeben, können also nicht zu groß werden. \
Außerdem dürfen sie nicht zu klein sein, da die Rechtecke sonst nicht mehr darstellbar wären.",
			"EN": "\
How can I save a fractal to open it later again in the editor?
-> There are different possible ways to do this.
- You can upload your fractal to the gallery. In the gallery, it is possible to open all uploaded fractals. \
NOTE: Images in the gallery are public and free to use for everyone.
- Under \"advanced settings -> edit system\", there is an option to download the IFS as a JSON file. \
You can save your fractal locally this way and load it using the same JSON file and the upload-button there.
- If you are using the web version, you can save the link. NOTE: Before that, you have to reload the link. \
The easiest way to do that is to click on \"save image locally\" (independent on whether you actually save the image or not).

In matrix view, why do some entries change if I change unrelated matrix entries?
-> This is due to the matrix having to map the unit vectors onto orthogonal vectors. (Which is why we can use \
rectangles to describe the functions involved, and not arbitrary quadrangles.) \
You can enter a known matrix in the order \"upper left, upper right, lower left, lower right\".

Why are some entry values not allowed in matrix and geometric view?
-> The mapping has to be a contraction, so the matrix or contraction entries are not permitted to be too high, \
and they cannot be to small in order to display the rectangles.",
		}
	},
	"contact": {
		"GER": "Kontakt",
		"EN": "contact",
		"tooltip": {
			"GER": "Kontaktinformationen",
			"EN": "contact information"
		},
		"text": {
			"GER": "\
Ich freue mich über jegliche Rückmeldungen mit Anmerkungen oder Ideen, Bugs oder Fehlern.

Kontakt:
	Marta Imke
	marta.imke@gmail.com
	Friedrich-Schiller-Universität Jena

Lizenz:
	GNU General Public license, Version 3

Quellcode:
	Editor: https://github.com/Anomasie/Fractals
	Galerie: https://github.com/hermlon/polaroids",
			"EN": "\
I look forward to all feedback with comments or ideas, bugs and errors on this page.

contact:
	Marta Imke
	marta.imke@gmail.com
	Friedrich-Schiller-Universität Jena
	Germany

license:
	GNU General Public license, Version 3

source code:
	Editor: https://github.com/Anomasie/Fractals
	Gallery: https://github.com/hermlon/polaroids",
		}
	},
	"credits": {
		"GER": "Credits",
		"EN": "credits",
		"tooltip": {
			"GER": "Credits und verwendete Software",
			"EN": "credits to co-workers and information about software"
		},
		"text": {
			"GER": "\
Erstellt von:
	Marta Imke

Galerie und JavaScript:
	hermlon
	https://github.com/hermlon/

Engine:
	Godot

Schriftart basiert auf:
	Dogicapixel
	von Roberto Mocci auf DaFont
	https://www.dafont.com/dogica.font

Benutzte Software:
	Aseprite (Bilder für das Design)
	BitFontMaker2 (Schriftartentwicklung)
	Godot 4 (Programmierung)",
			"EN": "\
Created by:
	Marta Imke

Gallery and JavaScript:
	hermlon
	https://github.com/hermlon/

Engine:
	Godot

Font based on:
	Dogicapixel
	by Roberto Mocci on DaFont
	https://www.dafont.com/dogica.font

Software used:
	Aseprite (Button images)
	BitFontMaker2 (Font design)
	Godot 4 (programming)"
		}
	}
}

const ADDITIONAL_TEXT = {
	
}

@export var HelpOptionsButton: PackedScene

@onready var TitleLabel = $Top/Conent/TitleLabel
@onready var Informations = $Margin/Content/Lines/Splitter/Informations
@onready var InfoLabel = $Margin/Content/Lines/Splitter/InfoLabel

@onready var CloseButton = $CloseButton

var current_info = 0

func _ready():
	for i in len(EXPLANATIONS.keys()):
		# set up button
		var button = HelpOptionsButton.instantiate()
		button.name = EXPLANATIONS.keys()[i]
		button.pressed.connect(_on_info_button_pressed.bind(i))
		# set language
		if EXPLANATIONS[EXPLANATIONS.keys()[i]].has(Global.language):
			button.text =EXPLANATIONS[EXPLANATIONS.keys()[i]][Global.language]
		else:
			button.text = "???"
			print("ERROR in HelpOptions, _ready: no name found for button " + button.name)
		# add button
		Informations.add_child(button)
	set_focus()
	# tooltips
	Global.tooltip_nodes.append_array([CloseButton] + Informations.get_children())

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
			Informations.get_child(i).disabled = true
		else:
			Informations.get_child(i).disabled = false

func reload_language():
	# tutorial-buggon
	match Global.language:
		"GER":
			TitleLabel.text = "Allgemeine Informationen"
			CloseButton.tooltip_text = "Informationen schließen"
		_:
			TitleLabel.text = "general information"
			CloseButton.tooltip_text = "close general information"
	# info-buttons
	for button in Informations.get_children():
		if EXPLANATIONS[button.name].has("tooltip") and EXPLANATIONS[button.name]["tooltip"].has(Global.language):
			button.tooltip_text = EXPLANATIONS[button.name]["tooltip"][Global.language]
		match Global.language:
			"GER":
				if EXPLANATIONS[button.name].has(Global.language):
					button.text = EXPLANATIONS[button.name][Global.language]
				else:
					button.text = "???"
					print("ERROR in HelpOptions, _ready: no name found for button " + button.name)
			_:
				if EXPLANATIONS[button.name].has(Global.language):
					button.text =EXPLANATIONS[button.name][Global.language]
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
