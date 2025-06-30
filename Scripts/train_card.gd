extends PanelContainer

@export var card_data: Dictionary # To hold {"color": GameManager.CardColor.RED}

# Signal to emit when this face-up card is clicked
signal card_clicked(data: Dictionary)

func _ready():
	# Set the card's visual appearance based on card_data.
	# For now, let's just change the background color or texture.
	if card_data.has("color"):
		var card_color_name = GameManager.CardColor.keys()[card_data.color]
		# Example: Change panel background color for debugging
		# A Theme or custom drawing would be better for final visuals.
		# You can also load specific textures here based on color.
		match card_data.color:
			GameManager.CardColor.RED:
				modulate = Color.RED
			GameManager.CardColor.BLUE:
				modulate = Color.BLUE
			# ... add other colors
			GameManager.CardColor.LOCOMOTIVE:
				modulate = Color.GOLD
			_:
				modulate = Color.GRAY

		# To load different textures for each color:
		var texture_path = "res://assets/traincards/" + card_color_name.to_lower() + ".png"
		var texture_node = $TextureRect # Make sure TextureRect is named "TextureRect"
		if texture_node and ResourceLoader.exists(texture_path):
			texture_node.texture = load(texture_path)
		elif texture_node:
			texture_node.texture = load("res://assets/traincards/card_back.png") # Default back

	# Make the card clickable when it's face-up
	if get_parent().name == "FaceUpCardsContainer": # Simple check to only make face-up cards clickable
		# We need an Area2D for clicks if not handled by Control.
		# For a UI Control node like PanelContainer, input events are built-in.
		set_process_input(true) # Enables _input() function for this node

# Handle input events on the card
func _input(event: InputEvent):
	if event.is_action_pressed("click") and get_rect().has_point(event.position):
		# Check if it's a face-up card being clicked
		if get_parent().name == "FaceUpCardsContainer":
			emit_signal("card_clicked", card_data)
			print("Face-up card clicked:", card_data.color)
			get_tree().set_input_as_handled()
		# For player hand cards, they might be draggable, not just clickable.
		# We'll implement drag & drop later.
