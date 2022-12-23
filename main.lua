
	tfm.exec.disableAfkDeath(true)
	tfm.exec.disableAutoShaman(true)
	tfm.exec.disableAutoNewGame(true)
	tfm.exec.disableAutoScore(true)
	tfm.exec.disableAutoTimeLeft(true)

	-------------------------------------------------------------DEFINIÇÃO DAS VARIAVEIS------------------------------------------------------------
	local mestre = "" -- quem vai ser o perguntador. como é randomico, começa nulo
	players = {} -- armazena a quantidade de jogadores da sala
	lang = {} -- armazena as mensagens do jogo
	id = {}


	perguntaFeita = false
	necessarioResetar = false
	fimDoTempo = false
	hasLost = false
	hasToReset = false
	mestreSkip = false


	atualSituacao = "começo"
	boolean = resposta
	timer = 0
	timerReset = 0
	num_de_jogadores_vivos = 0
	qtd_de_jogadores = -1
	rodada = 0
	pontuacao = -1

	lang.br = {

		botao_pergunta = "Clique aqui para fazer a pergunta",
		pergunta = "Digite a pergunta: ",
		more_players = "Deve ter, no mínimo, dois jogadores para o jogo começar!",
		question = "Digite a pergunta: ",
		verdadeiro = "Verdadeiro",
		falso = "Falso"
		
	}

	pisoTrue = {type = 12,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = false}
	pisoFalse = {type = 12,width = 281,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0xFF0000',miceCollision = true,groundCollision = true,dynamic = false}
	pisoGelo = {type = 10,width = 152,height = 10,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
	pisoParede = {type = 10,width = 40,height = 400,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
	pisoTransparente = {type = 8,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = false,groundCollision = true,dynamic = false}
	pisoAcido = {type = 19,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = false}
	pisoAgua = {type = 9,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = false,groundCollision = true,dynamic = false}


	text = lang.br

	imagens = {img="174042eda4f.png", w=28, h=29}



	id["question_button"] = 1
	id["one_player_label"] = 2
	id["turn_label1"] = 3
	id["turn_label2"] = 4
	id["ask_word_popup"] = 5
	id["question_label"] = 6
	id["resposta_true"] = 7
	id["resposta_false"] = 8
	id["piso_verdadeiro"] = 9
	id["piso_falso"] = 10
	id["piso_gelo"] = 11
	id["question_reset"] = 12
	id["jogo_vencido"] = 13
	id["parede1"] = 14
	id["parede2"] = 15
	id["botao_help"] = 16
	id["help_label"] = 17
	id["botao_fechar"] = 18
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------função que dá as configurações iniciais do jogo------------------------------------------------------------
	function eventNewGame()

		perguntaFeita = false

		num_de_jogadores_vivos = 0
		--DEFININDO A QUANTIDADE DE JOGADORES
		for name,player in next,tfm.get.room.playerList do
			num_de_jogadores_vivos=num_de_jogadores_vivos+1
		end 
		updatePlayersList()
		--tfm.exec.addImage(String nomeDaImagem, String target, Int posiçãoX, Int posiçãoY, String targetPlayer)
		--tfm.exec.addImage("174042eda4f.png", "%Fake_da_annyxd#7479", -21, -30)
		tfm.exec.addImage("1845194669a.png", "?2", 0, 20)
		--tfm.exec.addImage("15150c10e92.png", "?2", 0, 0)

		--tfm.exec.addImage("1651b3019c0.png", "+9", 0, 0)
			
		if numeroDeJogadores() > 1 then --MUDAR PARA 2 DEPOIS QUE TERMINAR TUDO
			mestre = randomPlayer()
			tfm.exec.killPlayer(mestre)
			fazerPergunta()
			ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" .."Aguarde enquanto "..mestre.." faz a pergunta".. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
		else
			ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.more_players.. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)	
		end

		--BOTÃO DE AJUDA
		ui.addTextArea(id["botao_help"], "<p align='center'><a href='event:callbackHelp'>".."?".."</a></p>", nil, 730, 35, 10, 20, 0x595959, 0x595959, 1f)

	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------ATUALIZA A LISTA DE JOGADORES DA SALA------------------------------------------------------------
	function updatePlayersList()
	  players = {}
		  
	  for p,_ in pairs(tfm.get.room.playerList) do
	  	table.insert(players, p)
	  end
	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------BOTÃO PERGUNTA-----------------------------------------------------------------------------------------------------------------
	function fazerPergunta()
		if not perguntaFeita then
			--BOTÃO PERGUNTA:
			ui.addTextArea(id["question_button"], "<p align='center'><a href='event:callbackAskWord'><font size='12'>"..text.botao_pergunta.."</a></p>", mestre, 300, 120, 210, 20, 0x595959, 0x595959, 1f) --BOTÃO PERGUNTA
	    ui.addTextArea(id["turn_label1"], "<font size='13'><p align='center'><BL><font color='#8B008B'>".."É a vez de: "..mestre.."</font></font></p>", p, -230, 30, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)      		
		end
	end
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------FUNCTIONS SOBRE A ENTRADA E SAIDA DE JOGADORES------------------------------------------------------------

	function numeroDeJogadores() -- pega a quantidade de jogadores da sala
		return #players
	end

	function eventNewPlayer(nomeDoJogador)
	  qtd_de_jogadores = qtd_de_jogadores + 1
	end

	for name,player in next,tfm.get.room.playerList do
		eventNewPlayer(name)
	end
	function eventPlayerLeft(name)
		qtd_de_jogadores = qtd_de_jogadores - 1
		if name == mestre then
			mestreSkip = true
			resetTodosMorrem()
		end
	end
	function eventPlayerDied(name)
		num_de_jogadores_vivos = num_de_jogadores_vivos - 1
	end

	--------------------------------------------FALTA DEFINIR QUANDO O JOGADOR SAIR DA SALA------------------------------------------------------------

	--------------------------------------------------------FUNCTION PARA DEFINIR O MESTRE------------------------------------------------------------
	function randomPlayer()
		return players[math.random(1,#players)]
	end


	-----------------------------------------------------QUANDO O MESTRE DECIDE SE É TRUE OR FALSE------------------------------------------------------------
	function eventTextAreaCallback(textAreaId, playerName, callback)
	  if callback=="callbackAskWord" and playerName==mestre then
	  		--addPopup(Int id, Int type, String text, String targetPlayer, Int x, Int y, Int width, Boolean fixedPos (false))
	    	ui.addPopup(id["ask_word_popup"], 2, text.question, mestre, 300, 120, 200) 
	  	end

	  if callback == "callbackTrue" then
	  	tfm.exec.setGameTime(10)
	  	tfm.exec.removePhysicObject(id["piso_gelo"])
	   	ui.addTextArea(id["question_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..questionPlayer.. "</font></font></p>", nil, 20, 300, 750, 100, 0xC0C0C0, 0xC0C0C0, 0f)
	 	 	ui.removeTextArea(id["question_button"])
	 	 	ui.removeTextArea(id["resposta_true"])
	  	ui.removeTextArea(id["resposta_false"])
	  	perguntaFeita = true
	  	resposta = true
	  end	

	  if callback == "callbackFalse" then
	  	tfm.exec.setGameTime(10)
	  	tfm.exec.removePhysicObject(id["piso_gelo"])
	  	ui.addTextArea(id["question_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..questionPlayer.. "</font></font></p>", nil, 20, 300, 750, 100, 0xC0C0C0, 0xC0C0C0, 0f)
	  	ui.removeTextArea(id["question_button"])
	  	ui.removeTextArea(id["resposta_true"])
	  	ui.removeTextArea(id["resposta_false"])
	  	perguntaFeita = true
	  	resposta = false
	  end	

	  if callback == "callbackHelp" then
	  	local help = "O jogo começa com 2 pessoas ou mais na mesma partida. A ideia do jogo é ser colocada a pergunta pelo shaman, de resposta verdadeiro ou falso. Para responder à pergunta do shaman como verdadeiro, (assumindo que “verdadeiro” é a resposta correta), o jogador deve poder escolher cair para a esquerda. No caso inverso, deve poder escolher cair para a direita. O jogador não deve conseguir voltar à sua posição inicial nem sair da área que escolheu a resposta, de modo a ser coroado vencedor da rodada ou ser eliminado. A eliminação acontece quando o jogador erra a resposta (escolheu verdadeiro, mas o shaman determinou que era falso). O shaman não deve conseguir sair fora da sua área de spawn. Os jogadores só devem conseguir sair fora da sua área de spawn quando for para se dirigirem ao local da resposta."
	  	ui.addTextArea(id["help_label"], "<p align='center'><font size='12'>" .. help .. "</a></p>", playerName, 140, 60, 575, 250, 0xf, 0xf, 2, true)
	  	ui.addTextArea(id["botao_fechar"], "<a href='event:callbackClose'><p align='center'><font size='30'>" .. "Fechar" .. "</a></p>", playerName, 350, 330, 150, 50, 0x595959, 0x595959, 1f)
	  end

	  if callback == "callbackClose" then
	  	ui.removeTextArea(id["help_label"])
	  	ui.removeTextArea(id["botao_fechar"])
	  end
	end

	function eventPopupAnswer(popupId, playerName, answer)
	  if popupId==id["ask_word_popup"] and mestre==playerName then
	  	--criar cenário pós pergunta ser enviada
	  	questionPlayer = answer
	  	ui.addTextArea(id["resposta_true"], "<p align='center'><a href='event:callbackTrue'>"..text.verdadeiro.."</a></p>", mestre, 330, 150, 80, 20, 0x595959, 0x595959, 1f)
	  	ui.addTextArea(id["resposta_false"], "<p align='center'><a href='event:callbackFalse'>"..text.falso.."</a></p>", mestre, 430, 150, 50, 20, 0x595959, 0x595959, 1f)
	    ui.removeTextArea(id["one_player_label"]) 
	  end
	end


	function eventLoop(tempoAtual, tempoRestante)
		ui.setMapName("<N>Verdadeiro ou falso! <VP><b>v1.0</b> <N>por <ROSE>Homerre Lindão   <BL>| <N>Ratos vivos <V>"..num_de_jogadores_vivos.." de <J>"..qtd_de_jogadores.." <BL>| <N>Rodada atual: <V>"..rodada.."<")
		timer = timer + 0.5

		--ALTERANDO A SITUAÇÃO DA PARTIDA
		if tempoAtual < 2000 and atualSituacao == "começo" then
			atualSituacao = "pergunta"
			novaPergunta()
		end


		if tempoRestante < 1250 and atualSituacao == "pergunta" then
			for name,player in next,tfm.get.room.playerList do
				if tfm.get.room.playerList[name].y >= 0 and tfm.get.room.playerList[name].y <= 200 then
					tfm.exec.killPlayer(name)
				end
			end
			tfm.exec.setGameTime(6)

			morte(resposta,math.random(1,5))
		end

		if atualSituacao == "pergunta" and tempoRestante >= 1 then
			-----------------------------------AQUI O TEMPO
			ui.addTextArea(33,"<p align='center'><font size='45'>"..math.floor((tempoRestante/1000)-1).."",nil,360,215,80,60,0x000001,0x494949,1.0,true)
		end

		--1 segundo = 1000 milisegundos 0,00
		if tempoRestante < 1 and atualSituacao == "intervalo" then
					novaPergunta()
		end


		if num_de_jogadores_vivos == 0 then
					tfm.exec.setGameTime(5)
					ui.removeTextArea(id["question_label"])
					resetTodosMorrem()
		end
		--FAZ PARTE PARA DEFINIR O VENCEDOR
		--if num_de_jogadores_vivos == 1 then
					--tfm.exec.setGameTime(5)
					--ui.removeTextArea(id["question_label"])
					--resetTodosMorrem()
		--end

		if timer==59 and not perguntaFeita and num_de_jogadores_vivos > 0 then --MUDAR A QUANTIDADE DE JOGADORES QUANDO O JOGO ESTIVER PRONTO
	    fimDoTempo = true
	    resetTodosMorrem()
	  end

		if necessarioResetar == true then
			ui.removeTextArea(id["one_player_label"])
			ui.removeTextArea(id["question_label"])
			timerReset = timerReset + 0.5
			if num_de_jogadores_vivos == 0 then
					ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" .."Todos morreram! Próxima rodada em "..math.floor(5 - timerReset).." segundos".."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
			end
			--DEFININDO O VENCEDOR! FUNCIONA
			--if num_de_jogadores_vivos == 1 then
					--for nome, player in next, tfm.get.room.playerList do
						--if not tfm.get.room.playerList[nome].isDead then
							--ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" .."O vencedor é "..nome.."! Próxima rodada em "..math.floor(5 - timerReset).." segundos".."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
						--end
					--end		
			--end
			if fimDoTempo then 
				ui.removeTextArea(id["question_button"])
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" .."Fim do tempo! Próxima rodada em "..math.floor(5 - timerReset).." segundos".."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f) 
			end
			if mestreSkip then ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" .."O mestre abandonou a partida! Próxima rodada em "..math.floor(5 - timerReset).." segundos".."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f) end
		end

		if timerReset==5 then
			hasToReset = true
			fimDoTempo = false
			mestreSkip = false
	    resetTodosMorrem()
	  end
	 end

	 --CRIANDO OS DIFERENTES CENÁRIOS DE MORTE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	function morte(condicao, numero)
		if condicao == true then
			texto = "verdadeiro"
		elseif condicao == false then
			texto = "falso"
		else
			texto = "invalido"
		end

		--ui.addTextArea(id["turn_label1"], "<font size='13'><p align='center'><BL><font color='#8B008B'>".."O número foi: "..numero.." E a resposta é "..texto.."</font></font></p>", p, -230, 30, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
		if condicao == true then
			if numero == 1 then
				tfm.exec.removePhysicObject(id["piso_falso"])
			end
			if numero == 2 then
				tfm.exec.removePhysicObject(id["piso_falso"])
				tfm.exec.addPhysicObject(id["piso_falso"], 180, 275, pisoTransparente)
			end
			if numero == 3 then
				tfm.exec.addPhysicObject(id["piso_falso"], 618, 273, pisoAcido)		
			end	
			if numero == 4 then
				tfm.exec.removePhysicObject(id["parede2"])
				tfm.exec.addShamanObject(17, 480, 210, 90, 50, 0, false)
				tfm.exec.addShamanObject(17, 480, 230, 90, 50, 0, false)
				tfm.exec.addShamanObject(17, 480, 250, 90, 50, 0, false)
			end
			if numero == 5 then
				for name,player in next,tfm.get.room.playerList do
					if tfm.get.room.playerList[name].x >= 470 and tfm.get.room.playerList[name].x <= 800 then
						tfm.exec.giveCheese(name)
					end
				end
				tfm.exec.addPhysicObject(id["piso_falso"], 618, 275, pisoAgua)
			end
			

			atualSituacao = "intervalo"
		end

		if condicao == false then
			if numero == 1 then
				tfm.exec.removePhysicObject(id["piso_verdadeiro"])
			end	
			if numero == 2 then
				tfm.exec.removePhysicObject(id["piso_verdadeiro"])
				tfm.exec.addPhysicObject(id["piso_verdadeiro"], 618, 275, pisoTransparente)
			end
			if numero == 3 then
				tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoAcido)		
			end	
			if numero == 4 then
				tfm.exec.removePhysicObject(id["parede1"])
				tfm.exec.addShamanObject(17, 315, 210, 270, 50, 0, false)
				tfm.exec.addShamanObject(17, 315, 230, 270, 50, 0, false)
				tfm.exec.addShamanObject(17, 315, 250, 270, 50, 0, false)
			end
			if numero == 5 then
				for name,player in next,tfm.get.room.playerList do
					if tfm.get.room.playerList[name].x >= 0 and tfm.get.room.playerList[name].x <= 330 then
						tfm.exec.giveCheese(name)
					end
				end
				tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoAgua)
			end

			atualSituacao = "intervalo"
		end
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	------------------------------------------------DEPOIS QUE A GALERA MORRE E PRECISA DE UMA NOVA PERGUNTA------------------------------------------------------------
	function novaPergunta()
		perguntaFeita = false
		timer = 0
		rodada = rodada + 1
		pontuacao = pontuacao + 1
		ui.removeTextArea(id["question_label"])

		--tfm.get.room.playerList[name].y >=0
		for name,player in next,tfm.get.room.playerList do
			tfm.exec.movePlayer(name,400,60,false)
			if not tfm.get.room.playerList[name].isDead then
				if (rodada == 1) then
					tfm.exec.setPlayerScore(name, 0, false)
				else
	  			tfm.exec.setPlayerScore(name, pontuacao, false)
	  		end
			end
			if (name~=mestre) then
				ui.removeTextArea(id["question_button"])
	  	end
		end
		atualSituacao = "pergunta"
		resposta = ""
		tfm.exec.setGameTime(60)
		tfm.exec.addPhysicObject(id["piso_gelo"], 400, 120, pisoGelo)
		tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoTrue)
		tfm.exec.addPhysicObject(id["piso_falso"], 618, 275, pisoFalse)
		tfm.exec.addPhysicObject(id["parede1"], 20, 200, pisoParede)
		tfm.exec.addPhysicObject(id["parede2"], 780, 200, pisoParede)
		fazerPergunta()
		atualSituacao = "pergunta"
		ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" .."Aguarde enquanto "..mestre.." faz a pergunta".. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
	end

	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	------------------------------------------------------------PRECISA MELHORAR O RESET---------------------------------------------------------------------------------------------------------------

	function resetTodosMorrem()
		atualSituacao ="começo"
		necessarioResetar = true

		updatePlayersList()

		ui.removeTextArea(id["question_reset"])
		ui.removeTextArea(id["ask_word_popup"])
		ui.removeTextArea(id["question_button"])
		ui.removeTextArea(id["resposta_true"])
		ui.removeTextArea(id["resposta_false"])
		rodada = 0
		pontuacao = -1

		if hasToReset then
			if numeroDeJogadores() < 2 then
				tfm.exec.newGame("@7917347")
			else
				eventNewGame()
				tfm.exec.newGame("@7917347")
				hasToReset = false 
				necessarioResetar = false 
				atualSituacao ="começo"
				timer = 0
				timerReset = 0
			end
		end
	end

	tfm.exec.newGame("@7917347")

	--Posições: X=20; Y=200; L=40; H=400
	--					X=780; Y=200; L=4-; H=400
