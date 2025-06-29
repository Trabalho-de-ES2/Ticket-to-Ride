extends CanvasLayer


#Funcao para o botao de sair fechar o jogo
func _on_sair_button_pressed() -> void:
	get_tree().quit() #Acessa a arvore de cenas e fecha o jogo


#Funcao para fechar o jogo ao apertar Esc
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): #Ui cancel = Esc
		get_tree().quit() #Acessa a arvore de cenas e fecha o jogo


# In MainMenu.gd
func _on_criar_sala_button_pressed():
	# Tell the GameManager to start the game logic.
	GameManager.start_game()
	# Then, change the scene to the game board.
	get_tree().change_scene_to_file("res://Scenes/game_board.tscn")
