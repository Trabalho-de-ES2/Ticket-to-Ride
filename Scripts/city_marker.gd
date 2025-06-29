extends Area2D

@export var city_name: String

signal city_clicked(city_name: String) # We will need this later

func _on_CityMarker_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on: ", city_name)
			# Emit the signal so the GameManager can hear it
			emit_signal("city_clicked", city_name)
			# Mark the event as handled to stop propagation
			get_tree().set_input_as_handled()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_route_clicked_from_board(route_data: Dictionary) -> void:
	pass # Replace with function body.
