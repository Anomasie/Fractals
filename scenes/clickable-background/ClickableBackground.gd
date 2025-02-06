extends Button

signal start_marking
signal marked_this

@onready var Marker = $Marker

var origin = Vector2i.ZERO
var marking = false

func _ready() -> void:
	Marker.hide()

func _process(_delta: float) -> void:
	if marking:
		var mouse_pos = get_viewport().get_mouse_position()
		# x axis
		if mouse_pos.x >= origin.x:
			Marker.size.x = mouse_pos.x - origin.x
			Marker.position.x = origin.x # logically not important, but sometimes necessary
			# probably due to the fact that fast mouse movements break the mouse_pos-accuracy
		else:
			Marker.size.x = origin.x - mouse_pos.x
			Marker.position.x = mouse_pos.x
		# y axis
		if mouse_pos.y >= origin.y:
			Marker.size.y = mouse_pos.y - origin.y
			Marker.position.y = origin.y # see above
		else:
			Marker.size.y = origin.y - mouse_pos.y
			Marker.position.y = mouse_pos.y

func _on_button_down() -> void:
	marking = true
	# set marker
	origin = get_viewport().get_mouse_position()
	Marker.position = origin
	Marker.size = Vector2i.ZERO
	Marker.show()
	start_marking.emit()

func _on_button_up() -> void:
	marking = false
	Marker.hide()
	marked_this.emit(Rect2(Marker.position, Marker.size))
