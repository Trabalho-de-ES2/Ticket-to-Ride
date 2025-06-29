extends PanelContainer

# This will still hold the data, but now it includes an image path.
var ticket_data: Dictionary

# References to our new UI nodes
@onready var route_image = $VBoxContainer/RouteImage
@onready var keep_check_box = $VBoxContainer/KeepCheckBox


# This function is called from the outside to set up the card's appearance.
# It now loads an image texture instead of setting text.
# Em DestinationTicketCard.gd

func set_ticket_info(data: Dictionary):
	print("Card: Recebi os dados: ", data) # <-- ADICIONE AQUI
	ticket_data = data
	
	if ticket_data.has("texture_path"):
		var path = ticket_data.texture_path
		print("Card: Tentando carregar a textura de: ", path) # <-- ADICIONE AQUI
		route_image.texture = load(path)
		print("Card: A textura agora é: ", route_image.texture) # <-- ADICIONE AQUI (MUITO IMPORTANTE)


# This function allows another script to check if this card is selected.
# It has not changed.
func is_selected() -> bool:
	return keep_check_box.button_pressed
