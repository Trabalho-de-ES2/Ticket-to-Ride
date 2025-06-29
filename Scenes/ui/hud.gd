extends CanvasLayer

# --- Signals ---
# Signals emitted by HUD to inform the GameManager about player actions.
signal draw_deck_clicked()
signal draw_destination_ticket_clicked()
# You might add signals for "claim_route_attempted", "card_dragged", etc., later.

# --- Node References (@onready) ---
# Ensure these paths match the exact names and hierarchy in your HUD.tscn!
@onready var player_name_label: Label = $PlayerInfo/PlayerNameLabel
@onready var score_label: Label = $PlayerInfo/ScoreLabel
@onready var trains_label: Label = $PlayerInfo/TrainsLabel

@onready var train_deck_pile_click_area: Area2D = $TrainDeckPile/ClickArea
@onready var face_up_cards_container: HBoxContainer = $FaceUpCardsContainer
@onready var destination_deck_pile_click_area: Area2D = $DestinationDeckPile/ClickArea
@onready var player_hand_container: HBoxContainer = $PlayerHandContainer

# --- Life Cycle Functions ---
func _ready():
	# Connect signals from clickable UI elements to their respective functions in HUD.
	
	# Connect the Train Card Deck click area
	if train_deck_pile_click_area:
		# Verifica se o sinal JÁ está conectado antes de tentar conectar
		if not train_deck_pile_click_area.is_connected("input_event", _on_train_deck_area_input_event):
				train_deck_pile_click_area.connect("input_event", _on_train_deck_area_input_event)
				print("Sinal 'input_event' do TrainDeckPileClickArea conectado com sucesso.")
		else:
			print("Sinal 'input_event' do TrainDeckPileClickArea já estava conectado. Nenhuma nova conexão feita.")
	else:
		print("Erro: train_deck_pile_click_area não foi encontrado!")
		# This will print an error if the path or node name is wrong, helping you debug.
		printerr("Error: 'TrainDeckPile/ClickArea' not found in HUD scene! Check @onready path.")

	# Connect the Destination Ticket Pile click area
	if destination_deck_pile_click_area:
	# Verifica se o sinal 'input_event' já está conectado antes de tentar conectá-lo
		if not destination_deck_pile_click_area.is_connected("input_event", _on_destination_deck_area_input_event):
			destination_deck_pile_click_area.connect("input_event", _on_destination_deck_area_input_event)
			print("Sinal 'input_event' do DestinationDeckPileClickArea conectado com sucesso.")
		else:
			print("Sinal 'input_event' do DestinationDeckPileClickArea já estava conectado. Nenhuma nova conexão feita.")
	else:
		printerr("Error: 'DestinationDeckPile/ClickArea' not found in HUD scene! Check @onready path.")
	
	# Initial UI updates based on GameManager's initial state
	# Ensure GameManager.players and GameManager.face_up_train_cards are initialized before this.
	# This might require a 'call_deferred' or a signal from GameManager after its setup.
	# For now, we assume GameManager's _ready() runs first due to Autoload order.
	if GameManager.players.size() > 0:
		update_player_info(GameManager.players[GameManager.current_player_index])
		update_face_up_cards_display(GameManager.face_up_train_cards)
		update_player_hand_display(GameManager.players[GameManager.current_player_index].train_cards)
	else:
		print("HUD: Waiting for GameManager to initialize players data.")


# --- Update UI Display Functions ---

# Updates the current player's name, score, and trains remaining.
func update_player_info(player_data: PlayerData):
	if player_name_label:
		player_name_label.text = player_data.player_name
	if score_label:
		score_label.text = "Score: " + str(player_data.score)
	if trains_label:
		trains_label.text = "Trains: " + str(player_data.trains_remaining)
	print("HUD: Updated player info for " + player_data.player_name)

# Updates the display of cards in the current player's hand.
func update_player_hand_display(hand_cards: Array):
	# Clear any existing cards in the container.
	for child in player_hand_container.get_children():
		child.queue_free() # Safely remove and free the old card instances.
	
	# Add new card instances based on the current hand_cards array.
	for card_data in hand_cards:
		var card_instance = preload("res://Scenes/components/TrainCard.tscn").instantiate()
		card_instance.card_data = card_data # Pass the card data to the card instance.
		player_hand_container.add_child(card_instance)
	print("HUD: Updated player hand display. Cards: ", hand_cards.size())

# Updates the display of the five face-up train cards.
func update_face_up_cards_display(face_up_cards: Array):
	# Clear any existing cards in the container.
	for child in face_up_cards_container.get_children():
		child.queue_free()
	
	# Add new card instances.
	for i in range(face_up_cards.size()):
		var card_data = face_up_cards[i]
		if card_data: # If there's a card in this slot (not null)
			var card_instance = preload("res://Scenes/components/TrainCard.tscn").instantiate()
			card_instance.card_data = card_data
			face_up_cards_container.add_child(card_instance)
			
			# Connect the card's click signal directly to GameManager.
			# We use a 'func(data)' wrapper to also pass the 'i' (index) of the card.
			card_instance.connect("card_clicked", Callable(GameManager, "_on_face_up_card_clicked").bind(i))
			
			# You might need to adjust card_instance.rect_min_size if cards are tiny initially
			# card_instance.custom_minimum_size = Vector2(80, 120) 
		else: # If the slot is empty (e.g., after drawing a card and deck is empty)
			# Add a placeholder (e.g., a blank panel) to maintain layout.
			var empty_slot = Panel.new()
			empty_slot.custom_minimum_size = Vector2(80, 120) # Match card size
			empty_slot.set_modulate(Color.DARK_GRAY) # Make it visually distinct
			face_up_cards_container.add_child(empty_slot)
	print("HUD: Updated face-up cards display.")

# --- Signal Handling Functions (from UI Elements) ---

# Handles input from the Train Card Deck clickable area.
func _on_train_deck_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		print("HUD: Train Deck clicked. Emitting 'draw_deck_clicked' signal.")
		emit_signal("draw_deck_clicked") # Inform GameManager
		get_tree().set_input_as_handled() # Consume the event

# Handles input from the Destination Ticket Pile clickable area.
func _on_destination_deck_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		print("HUD: Destination Deck clicked. Emitting 'draw_destination_ticket_clicked' signal.")
		emit_signal("draw_destination_ticket_clicked") # Inform GameManager
		get_tree().set_input_as_handled() # Consume the event
