# Em scripts/ui/DestinationTicketChooser.gd
extends ColorRect

# Sinal emitido para o HUD quando o jogador confirma a escolha.
signal tickets_confirmed(chosen_tickets, discarded_tickets)

# Precarrega a cena do card para podermos criar instâncias dela.
const DestinationTicketCard = preload("res://scenes/components/DestinationTicketCard.tscn")

# Referências para os nós filhos.
# Estes caminhos correspondem EXATAMENTE à sua imagem.
@onready var card_container = $CenterContainer/VBoxContainer/CardContainer
@onready var confirm_button = $CenterContainer/VBoxContainer/ConfirmButton


func _ready():
	# A linha que estava dando erro.
	# Se 'confirm_button' for encontrado, a conexão funcionará.
	confirm_button.connect("pressed", _on_confirm_button_pressed)


# --- Funções Públicas ---

# Função principal chamada pelo HUD para mostrar esta tela.
# Em DestinationTicketChooser.gd

func present_tickets(ticket_options: Array):
	print("Chooser: Recebi a ordem de apresentar ", ticket_options.size(), " bilhetes.") # <-- ADICIONE AQUI
	
	# 1. Limpa quaisquer cards antigos.
	for child in card_container.get_children():
		child.queue_free()

	# 2. Cria os novos cards com base nos dados recebidos.
	for ticket_data in ticket_options:
		print("Chooser: Criando card com os dados: ", ticket_data) # <-- ADICIONE AQUI
		var card_instance = DestinationTicketCard.instantiate()
		card_instance.set_ticket_info(ticket_data)
		card_container.add_child(card_instance)
	
	# 3. Torna a UI inteira visível.
	self.show()


# --- Funções de Sinal ---

# Roda quando o botão "Confirmar" é clicado.
func _on_confirm_button_pressed():
	var chosen_tickets = []
	var discarded_tickets = []

	for card in card_container.get_children():
		if card.is_selected():
			chosen_tickets.append(card.ticket_data)
		else:
			discarded_tickets.append(card.ticket_data)
	
	# Validação: O jogador precisa escolher pelo menos 1 bilhete.
	if chosen_tickets.is_empty():
		print("AVISO: Você precisa escolher pelo menos um bilhete de destino!")
		return # Para a execução aqui para deixar o jogador corrigir.

	# Emite o sinal com os resultados.
	emit_signal("tickets_confirmed", chosen_tickets, discarded_tickets)
	
	# Esconde o pop-up.
	self.hide()
