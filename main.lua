
	tfm.exec.disableAfkDeath(true)
	tfm.exec.disableAutoShaman(true)
	tfm.exec.disableAutoNewGame(true)
	tfm.exec.disableAutoScore(true)
	tfm.exec.disableAutoTimeLeft(true)

	-------------------------------------------------------------DEFINIÇÃO DAS VARIAVEIS------------------------------------------------------------
	local mestre = "" -- quem vai ser o perguntador. como é randomico, começa nulo
	local antigoMestre = ""
	local players = {} -- armazena a quantidade de jogadores da sala
	local lang = {} -- armazena as mensagens do jogo
	local id = {}
	local vencedor = ""


	local perguntaFeita = false
	local intervalo = false
	local necessarioResetar = false
	local fimDoTempo = false
	local hasLost = false
	local hasToReset = false
	local mestreSkip = false
	local mestreOut = false
	local temVencedor = false
	local onePlayer = false


	local resposta = ""
	local timerReset = 0
	local num_de_jogadores_vivos = 0
	local qtd_de_jogadores = 0
	local rodada = 0
	local pontuacao = 0

	lang.br = {

		question_button = "Clique aqui para fazer a pergunta",
		more_players = "Deve ter, no mínimo, dois jogadores para o jogo começar!",
		question = "Digite a pergunta: ",
		true_answer = "Verdadeiro",
		false_answer = "Falso",
		map_name = "Verdadeiro ou Falso!",
		live_mices = "Ratos vivos:",
		waiting_question1 = "Aguarde enquanto ",
		waiting_question2 = " faz a pergunta",
		next_round = " Próxima rodada em ",
		seconds = " segundos",
		everybody_died = "Todos morreram!",
		winner = "O vencedor é ",
		no_time = "Tempo esgotado!",
		mestre_out = "O mestre abandonou a partida!",
		mestre_skip = " pulou a sua vez!",
		close = "Fechar",
		
	}

	local pisoTrue = {type = 12,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x008000',miceCollision = true,groundCollision = true,dynamic = false}
	local pisoFalse = {type = 12,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x8B0000',miceCollision = true,groundCollision = true,dynamic = false}
	local pisoGelo = {type = 10,width = 152,height = 10,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
	local pisoParede = {type = 10,width = 40,height = 400,foregound = 1,friction = 0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
	local pisoTransparente = {type = 8,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = false,groundCollision = true,dynamic = false}
	local pisoAcido = {type = 19,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = false}
	local pisoAgua = {type = 9,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = false,groundCollision = true,dynamic = false}
	local pisoLava = {type = 3,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = false}


	local text = lang.br

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
	id["fundo_help"] = 19
	id["br"] = 20
	id["uk"] = 21
	id["es"] = 22
	id["fr"] = 23
	id["time"] = 24
	id["botao_creditos"] = 25
	id["botao_intrucoes"] = 26
	id["botao_informacoes"] = 27
	id["botao_comandos"] = 28

	---------------------------------------------FUNCTIONS SOBRE A ENTRADA E SAIDA DE JOGADORES------------------------------------------------------------

	function numeroDeJogadores() -- pega a quantidade de jogadores da sala
		return qtd_de_jogadores 
	end

	function eventPlayerDied(name)
		num_de_jogadores_vivos = num_de_jogadores_vivos - 1
	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	function eventNewPlayer(nomeDoJogador)
	  qtd_de_jogadores = qtd_de_jogadores + 1
	  if numeroDeJogadores() == 2 then
	  	onePlayer = false
	  	tfm.exec.newGame("@7917347")
	  end
	  novoJogador(nomeDoJogador)
	end

	function novoJogador(player)
		tfm.exec.addImage("1845194669a.png", "?1", 0, 20)
	  tfm.exec.addPhysicObject(id["piso_gelo"], 400, 120, pisoGelo)
		tfm.exec.addPhysicObject(id["piso_verdadeiro"], 182, 275, pisoTrue)
		tfm.exec.addPhysicObject(id["piso_falso"], 618, 275, pisoFalse)
		tfm.exec.addPhysicObject(id["parede1"], 20, 200, pisoParede)
		tfm.exec.addPhysicObject(id["parede2"], 780, 200, pisoParede)
	end


	for name,player in next,tfm.get.room.playerList do
		eventNewPlayer(name)
	end

	function eventPlayerLeft(name)
		qtd_de_jogadores = qtd_de_jogadores - 1
		if name == mestre then
			mestreOut = true
			reset()
		end
		if numeroDeJogadores() == 1 then
			reset()
		end
	end
	--------------------------------------------------------FUNCTION PARA DEFINIR O MESTRE------------------------------------------------------------
	function randomPlayer()
		return players[math.random(1,#players)]
	end
	--------------------------------------------------------------função que dá as configurações iniciais do jogo------------------------------------------------------------
	function eventNewGame()
		perguntaFeita = false
		
		num_de_jogadores_vivos = 0
		for name,player in next,tfm.get.room.playerList do
			num_de_jogadores_vivos=num_de_jogadores_vivos+1
		end 

		updatePlayersList()
		tfm.exec.addImage("174042eda4f.png", "%Fake_da_annyxd#7479", -21, -30)
		tfm.exec.addImage("1845194669a.png", "?1", 0, 20)
			
		if numeroDeJogadores() >= 2 and not temVencedor then --MUDAR PARA 2 DEPOIS QUE TERMINAR TUDO
			antigoMestre = mestre

			while(antigoMestre == mestre) do
				mestre = randomPlayer()
			end
			tfm.exec.killPlayer(mestre)
		end

		--tfm.exec.respawnPlayer(mestre)

		if numeroDeJogadores() >= 2 and temVencedor then
			mestre = vencedor
			temVencedor = false
			tfm.exec.killPlayer(mestre)
		end

		novaPergunta()
		--BOTÃO DE AJUDA
		ui.addTextArea(id["botao_help"], "<font size='18'><p align='center'><a href='event:callbackHelp'>".."H".."</font></a></p>", nil, 720, 35, 20, 25, nil, nil, 1f)

	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------CRIAÇÃO DO CENÁRIO DA PERGUNTA------------------------------------------------------------
	function eventPlayerRespawn(playerName)
		tfm.exec.movePlayer(playerName,400,60,false)	
	end	
	function novaPergunta()
		perguntaFeita = false
		intervalo = false

		if numeroDeJogadores() >= 2 then --MUDAR PARA 2 DEPOIS QUE TERMINAR TUDO
			
			ui.removeTextArea(id["question_label"])

			for name,player in next,tfm.get.room.playerList do
				tfm.exec.movePlayer(name,400,60,false)
				if not tfm.get.room.playerList[name].isDead then
	  			tfm.exec.setPlayerScore(name, pontuacao, false)
				end
				if (name~=mestre) then
					ui.removeTextArea(id["question_button"])
	  		end
			end

			timer = 0
			rodada = rodada + 1
			pontuacao = pontuacao + 1

			if rodada <= 10 then
				tfm.exec.setGameTime(60)
			elseif rodada > 10 and rodada <=20 then
				tfm.exec.setGameTime(45)
			elseif rodada > 20 then
				tfm.exec.setGameTime(30)
			end

			ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.waiting_question1..mestre..text.waiting_question2.. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
			resposta = ""
			fazerPergunta()
		else
			onePlayer = true
			ui.addTextArea(id["time"],"<p align='center'><font size='45'>".."?".."",nil,360,213,80,60,0x000001,0x494949,1.0)
			ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.more_players.. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)	
		end

		tfm.exec.addPhysicObject(id["piso_gelo"], 400, 120, pisoGelo)
		tfm.exec.addPhysicObject(id["piso_verdadeiro"], 182, 275, pisoTrue)
		tfm.exec.addPhysicObject(id["piso_falso"], 618, 275, pisoFalse)
		tfm.exec.addPhysicObject(id["parede1"], 20, 200, pisoParede)
		tfm.exec.addPhysicObject(id["parede2"], 780, 200, pisoParede)
	end
	--------------------------------------------------------------ATUALIZA A LISTA DE JOGADORES DA SALA------------------------------------------------------------
	function updatePlayersList()
	  for p,_ in pairs(tfm.get.room.playerList) do
	  	table.insert(players, p)
	  end
	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------BOTÃO PERGUNTA-----------------------------------------------------------------------------------------------------------------
	function fazerPergunta()
		if not perguntaFeita and numeroDeJogadores() > 1 then
			--BOTÃO PERGUNTA:
			ui.addTextArea(id["question_button"], "<p align='center'><a href='event:callbackAskWord'><font size='11'>"..text.question_button.."</a></p>", mestre, 295, 150, 210, 20, nil, nil, 1f) --BOTÃO PERGUNTA
	    end
	end

	-----------------------------------------------------QUANDO O MESTRE DECIDE SE É TRUE OR FALSE------------------------------------------------------------
	function eventTextAreaCallback(textAreaId, playerName, callback)
	  if callback=="callbackAskWord" and playerName==mestre then
	  	--addPopup(Int id, Int type, String text, String targetPlayer, Int x, Int y, Int width, Boolean fixedPos (false))
	    ui.addPopup(id["ask_word_popup"], 2, text.question, mestre, 300, 120, 200) 
	  end

	  if callback == "callbackTrue" then
	  	ui.removeTextArea(id["one_player_label"]) 
	  	tfm.exec.setGameTime(10)
	  	tfm.exec.removePhysicObject(id["piso_gelo"])
	   	ui.addTextArea(id["question_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..questionPlayer.. "</font></font></p>", nil, 40, 300, 720, 100, 0xC0C0C0, 0xC0C0C0, 0f)
	 	 	ui.removeTextArea(id["question_button"])
	 	 	ui.removeTextArea(id["resposta_true"])
	  	ui.removeTextArea(id["resposta_false"])
	  	perguntaFeita = true
	  	resposta = true
	  end	

	  if callback == "callbackFalse" then
	  	ui.removeTextArea(id["one_player_label"]) 
	  	tfm.exec.setGameTime(10)
	  	tfm.exec.removePhysicObject(id["piso_gelo"])
	  	ui.addTextArea(id["question_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..questionPlayer.. "</font></font></p>", nil, 40, 300, 720, 100, 0xC0C0C0, 0xC0C0C0, 0f)
	  	ui.removeTextArea(id["question_button"])
	  	ui.removeTextArea(id["resposta_true"])
	  	ui.removeTextArea(id["resposta_false"])
	  	perguntaFeita = true
	  	resposta = false
	  end	

	  if callback == "callbackHelp" then
	  	ui.addTextArea(id["fundo_help"], " ", playerName, 112, 50, 575, 320, nil, nil, 1.0, true)
	  	ui.addTextArea(id["botao_fechar"], "<a href='event:callbackClose'><p align='center'><font size='20'>" ..text.close.. "</a></p>", playerName, 359, 330, 80, 30, nil, nil, 1f, true)
	  	
	  	ui.addTextArea(id["botao_creditos"], "<font size='12'><p align='center'><a href='event:callbackCreditos'>".."Créditos".."</font></a></p>", playerName, 132, 60, 85, 20, nil, nil, 1f, true)
	  	ui.addTextArea(id["botao_intrucoes"], "<font size='12'><p align='center'><a href='event:callbackInstrucoes'>".."Instruções".."</font></a></p>", playerName, 276, 60, 85, 20, nil, nil, 1f, true)
	  	ui.addTextArea(id["botao_informacoes"], "<font size='12'><p align='center'><a href='event:callbackInformacoes'>".."Informações".."</font></a></p>", playerName, 420, 60, 85, 20, nil, nil, 1f, true)
	  	ui.addTextArea(id["botao_comandos"], "<font size='12'><p align='center'><a href='event:callbackComandos'>".."Comandos".."</font></a></p>", playerName, 564, 60, 85, 20, nil, nil, 1f, true)



	  	--IMAGENS DAS BANDEIRAS:
	  	--tfm.exec.addImage("1651b3019c0.png", "&19", 390, 65, playerName)
	  	--tfm.exec.addImage("1651b30da90.png", "&2", 415, 65, playerName)
	  	--tfm.exec.addImage("1651b309222.png", "&2", 440, 65, playerName)
	  	--tfm.exec.addImage("1651b30c284.png", "&2", 465, 65, playerName)

	  end

	  if callback == "callbackClose" then
	  	ui.removeTextArea(id["fundo_help"])
	  	ui.removeTextArea(id["help_label"])
	  	ui.removeTextArea(id["botao_fechar"])
	  	ui.removeTextArea(id["botao_creditos"])
	  	ui.removeTextArea(id["botao_intrucoes"])
	  	ui.removeTextArea(id["botao_informacoes"])
	  	ui.removeTextArea(id["botao_comandos"])
	  end
	  if callback == "callbackCreditos" then
	  end
	  if callback == "callbackInstrucoes" then
	  	local help = "<p align='center'><CE>Instruções do jogo <BR><BR><p align='LEFT'><N>Para o jogo começar, o shaman é escolhido de forma aleatória. <BR>O jogador que for escolhido como shaman terá o poder de fazer uma pergunta clicando no botão “Clique aqui para fazer uma pergunta”. <BR>Depois de clicar, uma caixa de texto para o shaman fazer uma pergunta será aberta, em que o shaman deverá escolher se a resposta para a pergunta feita é verdadeira ou falsa. Para fazer essa escolha, basta clicar nos botões “verdadeiro” ou “falso”. <BR>Em seguida, os jogadores terão 10 segundos para decidir se a resposta é verdadeira ou falsa. Quem ficar indeciso e não escolher nenhum lado, morrerá depois desses 10 segundos. <BR>O vencedor será o último sobrevivente e se tornará o próximo shaman. <BR>Se ninguém sobreviver, o próximo shaman será escolhido aleatoriamente."
			ui.addTextArea(id["help_label"], "<font size='12'>" ..help.. "</a></p>", playerName, 140, 90, 530, 250, 0xf, 0xf, 2, true)
	  end
	  if callback == "callbackInformacoes" then
	  	local help = "<p align='center'><CE>Informações do jogo <BR><BR><p align='LEFT'><N>O tempo para fazer uma pergunta, inicialmente, será de 60 segundos. Porém, quando se passar 10 rodadas, o tempo diminuíra para 45 segundos, e depois de 20 rodadas, caíra para 30 segundos. Portanto, seja rápido para fazer suas perguntas! <BR><BR>Os jogadores terão 10 segundos para decidir se a respsota da pergunta é verdadeiro ou falso. Se não escolher, será considerado que você perdeu a rodada <BR><BR>Cada resposta certa fará que o jogador ganhe um ponto. O próximo shaman será o último sobrevivente, ou seja, o jogador que fez mais pontos! <BR><BR>Evite fazer perguntas de opinião e que não sejam possíveis de responder com verdadeiro ou falso "
	  	ui.addTextArea(id["help_label"], "<font size='12'>" ..help.. "</a></p>", playerName, 140, 90, 530, 250, 0xf, 0xf, 2, true)
	  end
	  if callback == "callbackComandos" then
	  	local help = "<p align='center'><CE>Comandos<BR><BR><p align='LEFT'><N><BR><p align='left'><A:ACTIVE>!help <N>- mostra as informações do jogo<BR><A:ACTIVE>!q <N>- abre a caixa de perguntas<BR><A:ACTIVE>!skip <N>- pula a vez do shaman<BR>"
	  	ui.addTextArea(id["help_label"], "<font size='12'>" ..help.. "</a></p>", playerName, 140, 90, 530, 250, 0xf, 0xf, 2, true)
	  end
	end

	function eventPopupAnswer(popupId, playerName, answer)
	  if popupId==id["ask_word_popup"] and mestre==playerName then
	  	--criar cenário pós pergunta ser enviada
	  	questionPlayer = answer
	  	ui.addTextArea(id["resposta_true"], "<p align='center'><a href='event:callbackTrue'>"..text.true_answer.."</a></p>", mestre, 142, 200, 80, 20, nil, nil, 1f)
	  	ui.addTextArea(id["resposta_false"], "<p align='center'><a href='event:callbackFalse'>"..text.false_answer.."</a></p>", mestre, 593, 200, 50, 20, nil, nil, 1f)
	  end
	end

	----------------------------------------------------------------------------------------------------------
	function eventLoop(tempoAtual, tempoRestante)
		ui.setMapName("<N><J>"..text.map_name.." <N>   "..text.live_mices.." <V>"..num_de_jogadores_vivos.."</V> de <J>"..(qtd_de_jogadores-1).." <BL>|<N> Rodada atual: <V>"..rodada.." | <VP><b>Shaman atual: </b><N><ROSE>"..mestre.."<BL><")
		
		

		if math.floor(tempoRestante/1000) == 0 and perguntaFeita and not intervalo then
			for name,player in next,tfm.get.room.playerList do
				if tfm.get.room.playerList[name].y >= 0 and tfm.get.room.playerList[name].y <= 200 then
					tfm.exec.killPlayer(name)
				end
			end
			tfm.exec.setGameTime(5)
			if math.floor(tempoRestante/1000) == 0 then
				if resposta == true then
					for name,player in next,tfm.get.room.playerList do
						if tfm.get.room.playerList[name].x >= 475 and tfm.get.room.playerList[name].x <= 760 then
							tfm.exec.killPlayer(name)
						end
					end
				else 
					for name,player in next,tfm.get.room.playerList do
						if tfm.get.room.playerList[name].x >= 40 and tfm.get.room.playerList[name].x <= 325 then
							tfm.exec.killPlayer(name)
						end
					end
				end
			end
			morte(resposta,math.random(1,6))
		end

		if tempoRestante < 1 and intervalo then
				novaPergunta()
		end

		if num_de_jogadores_vivos == 0 then
					tfm.exec.setGameTime(5)
					ui.removeTextArea(id["question_label"])
					reset()
		end
		--FAZ PARTE PARA DEFINIR O VENCEDOR
		if num_de_jogadores_vivos == 1 and numeroDeJogadores() > 2 and tempoRestante <= 1 then
					tfm.exec.setGameTime(5)
					ui.removeTextArea(id["question_label"])
					reset()
		end

		if math.floor(tempoRestante/1000) == 0 and not perguntaFeita and num_de_jogadores_vivos >= 1 and not intervalo and not temVencedor then --MUDAR A QUANTIDADE DE JOGADORES QUANDO O JOGO ESTIVER PRONTO
	    fimDoTempo = true
	    reset()
	  end

		if necessarioResetar == true then
			ui.removeTextArea(id["one_player_label"])
			ui.removeTextArea(id["question_label"])
			timerReset = timerReset + 0.5
			if num_de_jogadores_vivos == 0 then
					ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.everybody_died..text.next_round..math.floor(6 - timerReset)..text.seconds.."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
			end
			--DEFININDO O VENCEDOR! FUNCIONA
			if num_de_jogadores_vivos == 1 and numeroDeJogadores() > 2 then
					for nome, player in next, tfm.get.room.playerList do
						if not tfm.get.room.playerList[nome].isDead then
							ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.winner..nome.."!"..text.next_round..math.floor(6 - timerReset)..text.seconds.."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
							vencedor = nome
							temVencedor = true
						end
					end		
			end
			if fimDoTempo then 
				ui.removeTextArea(id["question_button"])
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.no_time..text.next_round..math.floor(6 - timerReset)..text.seconds.."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f) 
			end
			if mestreOut then 
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.mestre_out..text.next_round..math.floor(6 - timerReset)..text.seconds.."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f) 
			end
			if mestreSkip then
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..mestre..text.mestre_skip..text.next_round..math.floor(6 - timerReset)..text.seconds.."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
			end	
		end

		if timerReset==5 then
			hasToReset = true
			fimDoTempo = false
			mestreOut = false
			mestreSkip = false
	    reset()
	  end

	  if not intervalo and not necessarioResetar and not onePlayer then
			ui.addTextArea(id["time"],"<p align='center'><font size='45'>"..math.floor(tempoRestante/1000).."",nil,360,213,80,60,0x000001,0x494949,1.0)
		end

	 end

	 --CRIANDO OS DIFERENTES CENÁRIOS DE MORTE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	function morte(condicao, numero)

		if condicao == true then
			if numero == 1 then
				tfm.exec.removePhysicObject(id["piso_falso"])
			end
			if numero == 2 then
				tfm.exec.removePhysicObject(id["piso_falso"])
				tfm.exec.addPhysicObject(id["piso_falso"], 180, 275, pisoTransparente)
			end
			if numero == 3 then
				tfm.exec.addPhysicObject(id["piso_falso"], 618, 273, pisoLava)		
			end	
			if numero == 4 then
				tfm.exec.addPhysicObject(id["piso_falso"], 618, 273, pisoAcido)		
			end	
			if numero == 5 then
				tfm.exec.removePhysicObject(id["parede2"])
				tfm.exec.addShamanObject(17, 480, 210, 90, 50, 0, false)
				tfm.exec.addShamanObject(17, 480, 230, 90, 50, 0, false)
				tfm.exec.addShamanObject(17, 480, 250, 90, 50, 0, false)
			end
			if numero == 6 then
				for name,player in next,tfm.get.room.playerList do
					if tfm.get.room.playerList[name].x >= 470 and tfm.get.room.playerList[name].x <= 800 then
						tfm.exec.giveCheese(name)
					end
				end
				tfm.exec.addPhysicObject(id["piso_falso"], 618, 275, pisoAgua)
			end
			
			tfm.exec.chatMessage("<VP>A resposta é verdadeira",nil)
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
				tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoLava)		
			end	
			if numero == 4 then
				tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoAcido)		
			end	
			if numero == 5 then
				tfm.exec.removePhysicObject(id["parede1"])
				tfm.exec.addShamanObject(17, 315, 210, 270, 50, 0, false)
				tfm.exec.addShamanObject(17, 315, 230, 270, 50, 0, false)
				tfm.exec.addShamanObject(17, 315, 250, 270, 50, 0, false)
			end
			if numero == 6 then
				for name,player in next,tfm.get.room.playerList do
					if tfm.get.room.playerList[name].x >= 0 and tfm.get.room.playerList[name].x <= 330 then
						tfm.exec.giveCheese(name)
					end
				end
				tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoAgua)
			end

			tfm.exec.chatMessage("<CR>A resposta é falsa",nil)
		end
		intervalo = true
	end

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	------------------------------------------------------------PRECISA MELHORAR O RESET---------------------------------------------------------------------------------------------------------------

	function reset()
		necessarioResetar = true

		updatePlayersList()

		ui.removeTextArea(id["question_reset"])
		ui.removeTextArea(id["ask_word_popup"])
		ui.removeTextArea(id["question_button"])
		ui.removeTextArea(id["resposta_true"])
		ui.removeTextArea(id["resposta_false"])
		rodada = 0
		pontuacao = 0

		if hasToReset then
			tfm.exec.newGame("@7917347")
			hasToReset = false 
			necessarioResetar = false 
			timerReset = 0
		end
	end

	function eventChatCommand(playerName, message)
		if message == "skip" and playerName == mestre then
			mestreSkip = true
			reset()
		end
		if message == "q" and playerName == mestre then
			eventTextAreaCallback(0, mestre, "callbackAskWord")
		end
		if message == "help"then
			eventTextAreaCallback(0, playerName, "callbackHelp")
		end
	end

	system.disableChatCommandDisplay(skip, true)
	system.disableChatCommandDisplay(q, true)
	system.disableChatCommandDisplay(help, true)
	tfm.exec.newGame("@7917347")