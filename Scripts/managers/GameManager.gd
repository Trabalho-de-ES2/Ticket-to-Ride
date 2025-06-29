# GameManager.gd
extends Node

# This is a state machine for the game loop.
enum GameState { START, PLAYER_TURN, CLAIM_ROUTE, DRAW_TRAIN_CARDS, DRAW_DESTINATION_TICKETS, END_GAME }
var current_state: GameState = GameState.START

# An array to hold all the players.
var players: Array[PlayerData] = []
var current_player_index: int = 0

# Decks of cards. We'll manage them here.
var train_card_deck: Array = []
var destination_ticket_deck: Array = []
var train_card_discard_pile: Array = []

# We will need to keep track of the face-up cards.
var face_up_train_cards: Array = []

# Define card colors as a dictionary or enum for consistency.
enum CardColor { RED, BLUE, BLACK, WHITE, YELLOW, ORANGE, GREEN, PURPLE, LOCOMOTIVE }

var hud: CanvasLayer # This will hold a reference to your HUD scene.

func _ready():
	print("GameManager loaded!")
	# Find the HUD instance in the scene tree once the main scene is loaded.
	await get_tree().process_frame # Wait a frame for other nodes to be ready
	hud = get_tree().get_first_node_in_group("hud_group") # More robust if HUD is in a group
	if hud:
		# Connect signals from UI elements to GameManager functions
		hud.connect("draw_deck_clicked", _on_train_deck_draw_clicked)
		# Connect signals from face-up cards as they are added
		# This will be done in the HUD script, which then forwards to GameManager
		print("HUD found and signals connected.")
	else:
		print("Error: HUD not found!")


# --- New Functions for Player Actions ---

func _on_train_deck_draw_clicked():
	if current_state == GameState.PLAYER_TURN: # Or GameState.DRAW_TRAIN_CARDS
		var player = players[current_player_index]
		var card = draw_train_card_from_deck()
		if card:
			player.add_train_card(card)
			print(player.player_name, " drew a card from deck: ", card.color)
			hud.update_player_hand_display(player.train_cards)
			# If player needs to draw a second card, transition state or check count
			# For TTR, player draws 2 cards, unless one is locomotive from face-up.
			# This logic will get complex and depend on your turn state.
			end_turn() # For simple testing, end turn after 1 card.
		else:
			print("Train deck is empty!")

func _on_face_up_card_clicked(card_data: Dictionary, card_index: int):
	if current_state == GameState.PLAYER_TURN: # Or GameState.DRAW_TRAIN_CARDS
		var player = players[current_player_index]

		# Transfer card from face-up to player's hand
		face_up_train_cards.remove_at(card_index)
		player.add_train_card(card_data)

		# Replace the face-up card
		var new_card = draw_train_card_from_deck()
		if new_card:
			face_up_train_cards.insert(card_index, new_card)
		else:
			face_up_train_cards.insert(card_index, null) # Placeholder if deck empty

		print(player.player_name, " drew face-up card: ", card_data.color)
		hud.update_player_hand_display(player.train_cards)
		hud.update_face_up_cards_display(face_up_train_cards)

		# Handle drawing two cards, locomotive rules etc.
		# This is complex TTR logic, for now, just end turn.
		end_turn()

#TODO resolver a funcao
## Function to be called from Route.gd when a route is clicked
#func _on_route_clicked_from_board(route_data: Dictionary):
	#if current_state == GameState.PLAYER_TURN:
		#var player = players[current_player_index]
		#print(player.player_name, " attempting to claim route: ", route_data)
#
		## TODO: Implement complex logic for checking if player has cards
		#var has_enough_cards = true # Placeholder for now
		#if has_enough_cards:
			## Find the actual Route node instance on the GameBoard scene
			#var route_node = find_route_node_by_data(route_data) # You'll need to write this helper
			#if route_node:
				#route_node.claim_route(player.player_id)
				#player.score += calculate_route_points(route_data.length)
				#player.trains_remaining -= route_data.length
				#print(player.player_name, " claimed route! Score: ", player.score)
				#hud.update_player_info(player)
				## TODO: Discard used cards
				#end_turn()
			#else:
				#print("Error: Route node not found in scene for claiming.")
		#else:
			#print(player.player_name, " does not have enough cards for this route.")

#TODO resolver esse erro aqui
## Helper to find a Route node instance (you might need to adjust this)
#func find_route_node_by_data(data: Dictionary) -> Node2D:
	#var game_board = get_tree().get_first_node_in_group("game_board_group") # If GameBoard is in a group
	#if game_board:
		#for child in game_board.get_children():
			#if child is Route and \
			   #((child.city_a == data.city_a and child.city_b == data.city_b) or \
				#(child.city_a == data.city_b and child.city_b == data.city_a)) and \
			   #child.length == data.length and \
			   #child.color == data.color:
				#return child
	#return null

func calculate_route_points(length: int) -> int:
	match length:
		1: return 1
		2: return 2
		3: return 4
		4: return 7
		5: return 10
		6: return 15
		_: return 0 # For lengths > 6 (e.g., 8 segments on some maps)

# --- Game Setup Functions ---
func start_game():
	print("Starting new game...")

	# 1. Create players
	# For now, let's create 2 players.
	var player_1 = PlayerData.new()
	player_1.player_id = 0
	player_1.player_name = "Player 1"
	player_1.player_color = Color.BLUE
	players.append(player_1)

	var player_2 = PlayerData.new()
	player_2.player_id = 1
	player_2.player_name = "Player 2"
	player_2.player_color = Color.RED
	players.append(player_2)

	# 2. Initialize and shuffle decks
	initialize_train_deck()
	initialize_destination_ticket_deck()

	# 3. Deal starting cards
	deal_starting_cards()

	# 4. Draw face-up cards
	draw_initial_face_up_cards()

	# 5. Transition to the first player's turn
	current_state = GameState.PLAYER_TURN
	print("Game started. It's now Player ", players[current_player_index].player_name, "'s turn.")

func initialize_train_deck():
	# TODO: This will need to be filled with the correct number of each card.
	# 12 of each color (Red, Blue, etc.) + 14 Locomotives.
	for color_name in CardColor:
		if color_name != CardColor.LOCOMOTIVE:
			for i in range(12):
				train_card_deck.append({"color": color_name})
		else: # For Locomotives
			for i in range(14):
				train_card_deck.append({"color": color_name})
	train_card_deck.shuffle()
	print("Train deck initialized and shuffled. Total cards: ", train_card_deck.size())

func initialize_destination_ticket_deck():
	# Each ticket can be a dictionary: {"from": "CityA", "to": "CityB", "points": 10}
	destination_ticket_deck.append({"from": "Saquarema", "to": "Rio das Ostras", "points": 9})
	destination_ticket_deck.append({"from": "Mangaratiba", "to": "Rio das Ostras", "points": 22})
	destination_ticket_deck.append({"from": "Valença", "to": "Armação de Búzios", "points": 22})
	destination_ticket_deck.append({"from": "Rio de Janeiro", "to": "Cachoeiras de Macacu", "points": 7})
	destination_ticket_deck.append({"from": "Japeri", "to": "Rio de Janeiro", "points": 5})
	destination_ticket_deck.append({"from": "Miguel Pereira", "to": "Casimiro de Abreu", "points": 15})
	destination_ticket_deck.append({"from": "Itaguaí", "to": "Maricá", "points": 9})
	destination_ticket_deck.append({"from": "Valença", "to": "São Gonçalo", "points": 12})
	destination_ticket_deck.append({"from": "Três Rios", "to": "Teresópolis", "points": 5})
	destination_ticket_deck.append({"from": "Belford Roxo", "to": "Cabo Frio", "points": 13})
	destination_ticket_deck.append({"from": "Miguel Pereira", "to": "Itaboraí", "points": 7})
	destination_ticket_deck.append({"from": "Barra do Piraí", "to": "Araruama", "points": 15})
	destination_ticket_deck.append({"from": "Petrópolis", "to": "São Gonçalo", "points": 5})
	destination_ticket_deck.append({"from": "Japeri", "to": "Rio Bonito", "points": 10})
	destination_ticket_deck.append({"from": "Mangaratiba", "to": "Três Rios", "points": 13})
	destination_ticket_deck.append({"from": "Itaguaí", "to": "Valença", "points": 7})
	destination_ticket_deck.append({"from": "Belford Roxo", "to": "Rio das Ostras", "points": 16})
	destination_ticket_deck.append({"from": "Rio de Janeiro", "to": "Casimiro de Abreu", "points": 11})
	destination_ticket_deck.append({"from": "Rio Bonito", "to": "Nova Friburgo", "points": 5})
	destination_ticket_deck.append({"from": "Piraí", "to": "Saquarema", "points": 13})
	destination_ticket_deck.append({"from": "Seropédica", "to": "Petrópolis", "points": 7})
	destination_ticket_deck.append({"from": "Valença", "to": "Saquarema", "points": 16})
	destination_ticket_deck.append({"from": "Guapimirim", "to": "Rio das Ostras", "points": 13})
	destination_ticket_deck.append({"from": "Valença", "to": "Três Rios", "points": 6})
	destination_ticket_deck.append({"from": "Rio de Janeiro", "to": "Araruama", "points": 8})
	destination_ticket_deck.append({"from": "Nova Friburgo", "to": "Cabo Frio", "points": 11})
	destination_ticket_deck.append({"from": "Mangaratiba", "to": "Nova Friburgo", "points": 17})
	destination_ticket_deck.append({"from": "Piraí", "to": "Miguel Pereira", "points": 6})
	destination_ticket_deck.append({"from": "Petrópolis", "to": "Armação de Búzios", "points": 14})
	destination_ticket_deck.append({"from": "Itaboraí", "to": "Cabo Frio", "points": 8})
	destination_ticket_deck.append({"from": "Piraí", "to": "Guapimirim", "points": 11})
	destination_ticket_deck.append({"from": "Rio Bonito", "to": "Casimiro de Abreu", "points": 6})
	destination_ticket_deck.append({"from": "Seropédica", "to": "Armação de Búzios", "points": 17})
	destination_ticket_deck.append({"from": "Cachoeiras de Macacu", "to": "Armação de Búzios", "points": 11})
	destination_ticket_deck.append({"from": "Japeri", "to": "Três Rios", "points": 8})
	destination_ticket_deck.append({"from": "Japeri", "to": "Nova Friburgo", "points": 14})
	destination_ticket_deck.append({"from": "Petrópolis", "to": "Nova Friburgo", "points": 8})
	destination_ticket_deck.append({"from": "Cachoeiras de Macacu", "to": "Araruama", "points": 6})
	destination_ticket_deck.append({"from": "Vassouras", "to": "Cabo Frio", "points": 18})
	destination_ticket_deck.append({"from": "Volta Redonda", "to": "Cachoeiras de Macacu", "points": 15})
	destination_ticket_deck.append({"from": "Miguel Pereira", "to": "Araruama", "points": 12})
	destination_ticket_deck.append({"from": "Volta Redonda", "to": "Casimiro de Abreu", "points": 19})
	destination_ticket_deck.shuffle()
	print("Destination ticket deck initialized. Total tickets: ", destination_ticket_deck.size())

func deal_starting_cards():
	# Deal 4 train cards to each player.
	for player in players:
		for i in range(4):
			var card = draw_train_card_from_deck()
			if card:
				player.add_train_card(card)
		print("Dealt 4 cards to ", player.player_name, ". Hand size: ", player.train_cards.size())

	# TODO: Deal destination tickets. This requires player choice.
	# We will implement the UI for this in the next part.

func draw_initial_face_up_cards():
	# Draw 5 face-up cards from the deck.
	for i in range(5):
		var card = draw_train_card_from_deck()
		if card:
			face_up_train_cards.append(card)

	# TODO: Check if more than 3 Locomotives are face-up and reshuffle.

	print("Initial face-up cards drawn: ", face_up_train_cards)

# --- Card Drawing Logic ---
func draw_train_card_from_deck():
	if not train_card_deck.is_empty():
		return train_card_deck.pop_front()
	else:
		# The deck is empty, reshuffle the discard pile.
		reshuffle_discard_pile_into_deck()
		return draw_train_card_from_deck() # Try again with the new deck
	return null # Should not happen if deck is handled correctly

func reshuffle_discard_pile_into_deck():
	print("Train deck is empty. Reshuffling discard pile.")
	train_card_deck = train_card_discard_pile
	train_card_discard_pile = []
	train_card_deck.shuffle()
	print("Discard pile reshuffled into deck. New deck size: ", train_card_deck.size())

# --- Turn Management ---
func end_turn():
	current_player_index = (current_player_index + 1) % players.size()
	print("End of turn. It's now Player ", players[current_player_index].player_name, "'s turn.")
	current_state = GameState.PLAYER_TURN
	
