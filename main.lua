
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
local necessarioResetar = false
local fimDoTempo = false
local hasLost = false
local hasToReset = false
local mestreSkip = false
local mestreOut = false
local temVencedor = false


local atualSituacao = "começo"
local boolean = resposta
local timer = 0
local timerReset = 0
local num_de_jogadores_vivos = 0
local qtd_de_jogadores = -1
local rodada = 0
local pontuacao = -1

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


local text = lang.br

local imagens = {img="174042eda4f.png", w=28, h=29}

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

---------------------------------------------FUNCTIONS SOBRE A ENTRADA E SAIDA DE JOGADORES------------------------------------------------------------

function numeroDeJogadores() -- pega a quantidade de jogadores da sala
	return qtd_de_jogadores + 1
end

function eventPlayerDied(name)
	num_de_jogadores_vivos = num_de_jogadores_vivos - 1
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function eventNewPlayer(nomeDoJogador)
  qtd_de_jogadores = qtd_de_jogadores + 1
  if numeroDeJogadores() == 2 then
  	tfm.exec.newGame("@7917347")
  end
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
		
	if numeroDeJogadores() >= 1 and not temVencedor then --MUDAR PARA 2 DEPOIS QUE TERMINAR TUDO
		antigoMestre = mestre

		while(antigoMestre == mestre) do
			mestre = randomPlayer()
		end
		tfm.exec.killPlayer(mestre)
	end

	if numeroDeJogadores() < 1 and not temVencedor then
		mestre = ""
		ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.more_players.. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)	
	end

	if numeroDeJogadores() >= 1 and temVencedor then
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
function novaPergunta()
	perguntaFeita = false

	if numeroDeJogadores() >= 1 then --MUDAR PARA 2 DEPOIS QUE TERMINAR TUDO
		timer = 0
		rodada = rodada + 1
		pontuacao = pontuacao + 1
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

		if rodada <= 10 then
			tfm.exec.setGameTime(62)
		elseif rodada > 10 and rodada <=20 then
			tfm.exec.setGameTime(47)
		elseif rodada > 20 then
			tfm.exec.setGameTime(32)
		end

		ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.waiting_question1..mestre..text.waiting_question2.. "</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
		atualSituacao = "pergunta"
		resposta = ""
		fazerPergunta()
	else
		ui.addTextArea(id["time"],"<p align='center'><font size='45'>".."0".."",nil,360,213,80,60,0x000001,0x494949,1.0)
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
  	tfm.exec.setGameTime(12)
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
  	tfm.exec.setGameTime(12)
  	tfm.exec.removePhysicObject(id["piso_gelo"])
  	ui.addTextArea(id["question_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..questionPlayer.. "</font></font></p>", nil, 40, 300, 720, 100, 0xC0C0C0, 0xC0C0C0, 0f)
  	ui.removeTextArea(id["question_button"])
  	ui.removeTextArea(id["resposta_true"])
  	ui.removeTextArea(id["resposta_false"])
  	perguntaFeita = true
  	resposta = false
  end	

  if callback == "callbackHelp" then
  	local help = "<p align='left'><ROSE>Idea, mapa e regras do jogo: <N>Fake_da_annyxd#7479 <BR><BV>Programador: <N>Homerre#0000 <BR><BR><p align='center'><CE>Regras do module <BR><BR><p align='LEFT'><N>O jogo tem como objetivo responder às perguntas do shaman como verdadeiro ou falso. O shaman tem determinado tempo para colocar a pergunta, que deve ser possível responder com verdadeiro ou falso. Quem responder a todas as perguntas certo é o shaman na próxima rodada. (pode melhorar)<BR><BR><p align='center'><CE>Comandos<BR><BR><p align='left'><A:ACTIVE>!help <N>- mostra as informações do jogo<BR><A:ACTIVE>!q <N>- abre a caixa de perguntas<BR><A:ACTIVE>!skip <N>- pula a vez do mestre<BR>"
		ui.addTextArea(id["fundo_help"], " ", playerName, 112, 50, 575, 320, nil, nil, 1.0, true)
  	ui.addTextArea(id["help_label"], "<font size='12'>" ..help.. "</a></p>", playerName, 140, 60, 530, 300, 0xf, 0xf, 2, true)
  	ui.addTextArea(id["botao_fechar"], "<a href='event:callbackClose'><p align='center'><font size='20'>" ..text.close.. "</a></p>", playerName, 359, 330, 80, 30, nil, nil, 1f, true)
  
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
  end
  if callback == "callbackBr" then
  	ui.removeTextArea(id["fundo_help"])
  	ui.removeTextArea(id["help_label"])
  	ui.removeTextArea(id["botao_fechar"])
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


function eventLoop(tempoAtual, tempoRestante)
	ui.setMapName("<N><J>"..text.map_name.." <N>   "..text.live_mices.." <V>"..num_de_jogadores_vivos.."</V> de <J>"..qtd_de_jogadores.." <BL>|<N> Rodada atual: <V>"..rodada.." | <VP><b>Mestre atual: </b><N><ROSE>"..mestre.."<BL><")
	timer = timer + 0.5

	--ALTERANDO A SITUAÇÃO DA PARTIDA
	if tempoAtual < 2000 and atualSituacao == "começo" and numeroDeJogadores() >= 1 then
		atualSituacao = "pergunta"
		novaPergunta()
	end

	if tempoRestante < 1250 and atualSituacao == "pergunta" and perguntaFeita then
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
		ui.addTextArea(id["time"],"<p align='center'><font size='45'>"..math.floor((tempoRestante/1000)-1).."",nil,360,213,80,60,0x000001,0x494949,1.0)
	end

	if tempoRestante < 1 and atualSituacao == "intervalo" then
			novaPergunta()
	end

	if num_de_jogadores_vivos == 0 then
				tfm.exec.setGameTime(5)
				ui.removeTextArea(id["question_label"])
				reset()
	end
	--FAZ PARTE PARA DEFINIR O VENCEDOR
	--if num_de_jogadores_vivos == 1 and tempoRestante <= 1 then
				--tfm.exec.setGameTime(5)
				--ui.removeTextArea(id["question_label"])
				--reset()
	--end

	if math.floor((tempoRestante/1000)-1) == 0 and not perguntaFeita and num_de_jogadores_vivos >= 1 then --MUDAR A QUANTIDADE DE JOGADORES QUANDO O JOGO ESTIVER PRONTO
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
		--if num_de_jogadores_vivos == 1 then
				--for nome, player in next, tfm.get.room.playerList do
					--if not tfm.get.room.playerList[nome].isDead then
						--ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..text.winner..nome.."!"..text.next_round..math.floor(6 - timerReset)..text.seconds.."</font></font></p>", nil, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
						--vencedor = nome
						--temVencedor = true
					--end
				--end		
		--end
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

		tfm.exec.chatMessage("<CR>A resposta é falsa",nil)
	end
	atualSituacao = "intervalo"
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------PRECISA MELHORAR O RESET---------------------------------------------------------------------------------------------------------------

function reset()
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
		tfm.exec.newGame("@7917347")
		hasToReset = false 
		necessarioResetar = false 
		atualSituacao ="começo"
		timer = 0
		timerReset = 0
		for name,player in next,tfm.get.room.playerList do
			tfm.exec.setPlayerScore(name, 0, false)
		end
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
