extends CanvasLayer

# --- Signals ---
# Sinais emitidos pelo HUD para informar o GameManager sobre as ações do jogador.
signal draw_deck_clicked()
# NOVO: Sinal emitido após o jogador confirmar sua escolha de bilhetes de destino.
signal destination_tickets_selected(chosen_tickets, discarded_tickets)

# --- Node References (@onready) ---
@onready var player_name_label: Label = $PlayerInfo/PlayerNameLabel
@onready var score_label: Label = $PlayerInfo/ScoreLabel
@onready var trains_label: Label = $PlayerInfo/TrainsLabel

@onready var train_deck_pile_click_area: Area2D = $TrainDeckPile/ClickArea
@onready var face_up_cards_container: HBoxContainer = $FaceUpCardsContainer
@onready var destination_deck_pile_click_area: Area2D = $DestinationDeckPile/ClickArea
@onready var player_hand_container: HBoxContainer = $PlayerHandContainer

# NOVO: Referência para a nossa tela de escolha de bilhetes.
@onready var destination_ticket_chooser = $DestinationTicketChooser


# --- Life Cycle Functions ---
func _ready():
	# Conecta os sinais dos elementos de UI clicáveis.
	train_deck_pile_click_area.connect("input_event", _on_train_deck_area_input_event)
	destination_deck_pile_click_area.connect("input_event", _on_destination_deck_area_input_event)
	
	# NOVO: Conecta o sinal da tela de escolha à uma função neste script.
	# Quando o chooser confirmar a seleção, ele chamará _on_destination_tickets_confirmed.
	destination_ticket_chooser.connect("tickets_confirmed", _on_destination_tickets_confirmed)
	
	# Seu código de inicialização existente (mantido como está).
	if GameManager.players.size() > 0:
		update_player_info(GameManager.players[GameManager.current_player_index])
		update_face_up_cards_display(GameManager.face_up_train_cards)
		update_player_hand_display(GameManager.players[GameManager.current_player_index].train_cards)
	else:
		print("HUD: Waiting for GameManager to initialize players data.")


# --- Update UI Display Functions ---
# Nenhuma alteração necessária aqui, suas funções estão perfeitas.
func update_player_info(player_data: PlayerData):
	player_name_label.text = player_data.player_name
	score_label.text = "Score: " + str(player_data.score)
	trains_label.text = "Trains: " + str(player_data.trains_remaining)

func update_player_hand_display(hand_cards: Array):
	for child in player_hand_container.get_children():
		child.queue_free()
	for card_data in hand_cards:
		var card_instance = preload("res://scenes/components/TrainCard.tscn").instantiate()
		card_instance.card_data = card_data
		player_hand_container.add_child(card_instance)

func update_face_up_cards_display(face_up_cards: Array):
	for child in face_up_cards_container.get_children():
		child.queue_free()
	for i in range(face_up_cards.size()):
		var card_data = face_up_cards[i]
		if card_data:
			var card_instance = preload("res://scenes/components/TrainCard.tscn").instantiate()
			card_instance.card_data = card_data
			face_up_cards_container.add_child(card_instance)
			card_instance.connect("card_clicked", Callable(GameManager, "_on_face_up_card_clicked").bind(i))
		else:
			var empty_slot = Panel.new()
			empty_slot.custom_minimum_size = Vector2(80, 120)
			empty_slot.modulate = Color.DARK_GRAY
			face_up_cards_container.add_child(empty_slot)


# --- Signal Handling Functions (from UI Elements) ---

func _on_train_deck_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("draw_deck_clicked")
		get_tree().set_input_as_handled()

# MODIFICADO: Esta função agora abre a tela de escolha.
func _on_destination_deck_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		print("HUD: Destination Deck clicked. Presenting ticket options...")
		
		# Cria dados de exemplo para os bilhetes.
		# O GameManager fornecerá os dados reais aqui no futuro.
		# !!! IMPORTANTE: Substitua estes caminhos pelos caminhos reais das suas imagens!!!
		var placeholder_tickets = [
			{ "texture_path": "res://assets/destinations/path684.png", "points": 22, "id": "ticket1" },
			{ "texture_path": "res://assets/destinations/path714.png", "points": 22, "id": "ticket2" },
			{ "texture_path": "res://assets/destinations/path2659.png", "points": 7, "id": "ticket3" }
		]
		
		# Manda a tela de escolha se apresentar com os dados de exemplo.
		destination_ticket_chooser.present_tickets(placeholder_tickets)
		
		get_tree().set_input_as_handled()

# NOVO: Esta função é chamada quando o jogador confirma sua escolha na tela de bilhetes.
func _on_destination_tickets_confirmed(chosen, discarded):
	print("HUD: Player confirmed ticket selection.")
	print("Tickets chosen by player: ", chosen)
	print("Tickets discarded by player: ", discarded)
	
	# Agora, informamos ao GameManager sobre a escolha final do jogador.
	emit_signal("destination_tickets_selected", chosen, discarded)
