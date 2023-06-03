extends Control

@onready var PlaygroundUI = $PlaygroundUI
@onready var ResultUI = $ResultUI

func _ready():
	PlaygroundUI.show()
	ResultUI.hide()

func show_results(results):
	PlaygroundUI.hide()
	ResultUI.open(results)
