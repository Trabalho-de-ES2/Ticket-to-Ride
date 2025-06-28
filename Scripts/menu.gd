extends CanvasLayer


#Funcao para o botao de sair fechar o jogo
func _on_sair_button_pressed() -> void:
	get_tree().quit() #Acessa a arvore de cenas e fecha o jogo


#Funcao para fechar o jogo ao apertar Esc
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): #Ui cancel = Esc
		get_tree().quit() #Acessa a arvore de cenas e fecha o jogo
