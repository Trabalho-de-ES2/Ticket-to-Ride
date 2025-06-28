extends Node2D

enum RouteColor { RED, BLUE, BLACK, WHITE, YELLOW, ORANGE, GREEN, PINK, PURPLE, GRAY, LOCOMOTIVE, ANY }

# Use export variables to set these properties in the Inspector for each instance.
@export var city_a: String
@export var city_b: String
@export var length: int
@export var color: RouteColor

var claimed_by_player: int = -1 # -1 means unclaimed, 0, 1, 2... for players

# A custom signal to inform the game manager when this route is clicked.
signal route_clicked(route_data: Dictionary)

func _ready():
	# Connect the input_event signal from each Area2D child to this script.
	for child in get_children():
		if child is Area2D:
			child.connect("input_event", _on_area_input_event)

func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	# This function receives signals from all the Area2D children.
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if claimed_by_player == -1:
			# If unclaimed, emit the signal with all the route's data.
			var route_data = {
				"city_a": city_a,
				"city_b": city_b,
				"length": length,
				"color": color
			}
			emit_signal("route_clicked", route_data)

			# Consume the click event to prevent it from propagating.
			get_tree().set_input_as_handled()

			print("Route clicked: ", city_a, " to ", city_b, " (Length: ", length, ")")
		else:
			print("Route from ", city_a, " to ", city_b, " is already claimed!")

# A function to update the route's state when claimed.
func claim_route(player_id: int):
	claimed_by_player = player_id
	# TODO: Add visual feedback later, like changing the color or transparency of the collision shapes.
