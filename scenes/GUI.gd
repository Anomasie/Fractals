extends Control

@onready var PlaygroundUI = $PlaygroundUI
@onready var ResultUI = $ResultUI

func _ready():
	show_playground()

func show_playground():
	PlaygroundUI.show()
	ResultUI.hide()

func show_results(results):
	PlaygroundUI.hide()
	ResultUI.open(results)
