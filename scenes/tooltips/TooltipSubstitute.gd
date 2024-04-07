extends MarginContainer

@onready var TooltipLabel = $Content/TooltipLabel

func _ready():
	Global.give_tooltip.connect(_give_tooltip)
	Global.hide_tooltip.connect(_hide_tooltip)

func _give_tooltip(text):
	TooltipLabel.text = text
	show()

func _hide_tooltip():
	hide()
