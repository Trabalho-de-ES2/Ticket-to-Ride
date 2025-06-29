# PlayerData.gd
class_name PlayerData

# Use 'export' to see these properties in the Inspector if this script is attached to a node.
# In this case, we'll create PlayerData objects in our GameManager script.
@export var player_id: int
@export var player_name: String
@export var player_color: Color
@export var score: int = 0
@export var trains_remaining: int = 45

# These will store the player's cards as arrays of dictionaries.
var train_cards: Array = []
var destination_tickets: Array = []

# You can add functions here for adding/removing cards, etc.
func add_train_card(card_data: Dictionary):
	train_cards.append(card_data)

func remove_train_card(card_data: Dictionary, count: int):
	# TODO: Implement logic to remove 'count' number of cards of a certain color.
	# This is important for claiming routes.
	pass
