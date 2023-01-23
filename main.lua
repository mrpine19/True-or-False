tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoScore(true)
tfm.exec.disableAutoTimeLeft(true)

-------------------------------------------------------------DEFINIÇÃO DAS VARIAVEIS------------------------------------------------------------
local mestre = nil -- quem vai ser o perguntador. como é randomico, começa nulo
local antigoMestre = ""
local players = {} -- armazena a quantidade de jogadores da sala
local lang = {} -- armazena as mensagens do jogo
local id = {}
local vencedor = nil


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
local helpMenuOpen = false


local resposta = nil
local timerReset = 0
local num_de_jogadores_vivos = 0
local qtd_de_jogadores = 0
local rodada = 0
local pontuacao = 0

lang.br = {

	welcome = "Bem vindo ao jogo! Aguarde a próxima rodada para que o mapa seja carregado 100%!",
	question_button = "Clique aqui para fazer a pergunta",
	more_players = "Deve ter, no mínimo, dois jogadores para o jogo começar!",
	question = "Digite a pergunta: ",
	true_choice = "Verdadeiro",
	false_choice = "Falso",
	map_name = "Verdadeiro ou Falso!",
	live_mices = "Ratos vivos:",
	current_round = "Rodada atual: ",
	actual_shaman = "Shaman: ",
	waiting_question1 = "Aguarde enquanto ",
	waiting_question2 = " faz a pergunta",
	your_question = "Sua pergunta: ",
	next_round = " Próxima rodada em ",
	seconds = " segundos",
	everybody_died = "Todos morreram!",
	winner = "O vencedor é ",
	no_time = "Tempo esgotado!",
	mestre_out = "O shaman abandonou a partida!",
	mestre_skip = " pulou a sua vez!",
	close = "Fechar",
	credit = "Créditos",
	instructions = "Instruções",
	information = "Informações", 
	commands = "Comandos",
	credit_help = "<p align='center'><CE>Créditos<BR><BR><p align='left'><CH>Desenvolvedor: <N>Homerre#0000<BR><p align='left'><CH>Ideia, traduções, layout: <N>Fake_da_annyxd#7479<BR><BR><BR><p align='center'><CE>Agradecimentos<BR><BR><p align='left'><VP>Apoio técnico: <N>Infectsoul#2048, Sklag#2552<BR><p align='left'><VP>Agradecimentos especiais: <N>Fuyunohanashi#5024, Phypoy#0010",
	instructions_help = "<p align='center'><CE>Instruções do jogo <BR><BR><p align='LEFT'><N>Para o jogo começar, o shaman é escolhido de forma aleatória. <BR>O jogador que for escolhido como shaman terá o poder de fazer uma pergunta clicando no botão “Clique aqui para fazer uma pergunta”. <BR>Depois de clicar, uma caixa de texto para o shaman fazer uma pergunta será aberta, em que o shaman deverá escolher se a resposta para a pergunta feita é verdadeira ou falsa. Para fazer essa escolha, basta clicar nos botões “verdadeiro” ou “falso”. <BR>Em seguida, os jogadores terão 10 segundos para decidir se a resposta é verdadeira ou falsa. Quem ficar indeciso e não escolher nenhum lado, morrerá depois desses 10 segundos. <BR>O vencedor será o último sobrevivente e se tornará o próximo shaman. <BR>Se ninguém sobreviver, o próximo shaman será escolhido aleatoriamente.",
	information_help = "<p align='center'><CE>Informações do jogo <BR><BR><p align='LEFT'><N>O tempo para fazer uma pergunta, inicialmente, será de 60 segundos. Porém, quando se passar 10 rodadas, o tempo diminuíra para 45 segundos, e depois de 20 rodadas, caíra para 30 segundos. Portanto, seja rápido para fazer suas perguntas! <BR><BR>Os jogadores terão 10 segundos para decidir se a resposta da pergunta é verdadeiro ou falso. Se não escolher, será considerado que você perdeu a rodada <BR><BR>Cada resposta certa fará que o jogador ganhe um ponto. O próximo shaman será o último sobrevivente, ou seja, o jogador que fez mais pontos! <BR><BR>Evite fazer perguntas de opinião e que não sejam possíveis de responder com verdadeiro ou falso ",
	commands_help = "<p align='center'><CE>Comandos<BR><BR><p align='left'><A:ACTIVE>!help <N>- mostra as informações do jogo<BR><A:ACTIVE>!q <N>- abre a caixa de perguntas<BR><A:ACTIVE>!skip <N>- pula a vez do shaman",
	true_answer = "A resposta é verdadeira!",
	false_answer = "A resposta é falsa!"

}

lang.en = {

	welcome = "Welcome! Wait for the next round for the map to be fully loaded!", 
	question_button = "Press here to ask the question!",
	more_players = "There must be a minimum of two players for the game to start!",
	question = "Type the question: ",
	true_choice = "True",
	false_choice = "False",
	map_name = "True or False!",
	live_mices = "Mice alive:",
	current_round = "Current round: ",
	actual_shaman = "Shaman: ",
	waiting_question1 = "Wait while ",
	waiting_question2 = " is doing the question",
	your_question = "Your question: ",
	next_round = " Next round in ",
	seconds = " seconds",
	everybody_died = "Everybody died!",
	winner = "The winner is ",
	no_time = "Time’s up!",
	mestre_out = "The shaman left the game!",
	mestre_skip = " skipped his turn!",
	close = "Close",
	credit = "Credits",
	instructions = "Instructions",
	information = "Informations",
	commands = "Commands",
	credit_help = "<p align='center'><CE>Credits<BR><BR><p align='left'><CH>Developer: <N>Homerre#0000<BR><p align='left'><CH>Idea, translations, layout: <N>Fake_da_annyxd#7479<BR><BR><BR><p align='center'><CE>Acknowledgment<BR><BR><p align='left'><VP>Technical support: <N>Infectsoul#2048, Sklag#2552<BR><p align='left'><VP>Special thanks: <N>Fuyunohanashi#5024, Phypoy#0010",
	instructions_help = "<p align='center'><CE>Game instructions<BR><BR><p align='LEFT'><N>The game starts with two or more mice, when the shaman asks a question. After asking the question, the shaman must choose whether the answer is true or false. Players will have 10 seconds to choose between true or false. Whoever remains undecided and chooses no side loses.<BR>The winner will be the last survivor and become the next shaman. <BR>If no one survives, the shaman is chosen randomly.",
	information_help = "<p align='center'><CE>Game information<BR><BR><p align='LEFT'><N>The time to ask a question will initially be 60 seconds. However, when 10 rounds pass, the time will decrease to 45 seconds, and after 20 rounds, it will drop to 30 seconds. Therefore, be quick to ask your questions!<BR><BR>Players will have 10 seconds to decide whether the question's answer is true or false. If not, it will be considered that you lost the round.<BR><BR>Each correct answer earns the player a point. The next shaman will be the last survivor, that is, the player who has scored the most points!<BR><BR>Avoid asking opinion questions or questions that are not possible to answer with true or false.",
	commands_help = "<p align='center'><CE>Commands<BR><BR><p align='left'><A:ACTIVE>!help <N>- shows more information about the minigame<BR><A:ACTIVE>!q <N>- do a question while being shaman<BR><A:ACTIVE>!skip <N>- skips the shaman’s turn",
	true_answer = "The answer is true!",
	false_answer = "The answer is false!"

}

lang.fr = {

	welcome = "Bienvenue! Attendez le prochain tour pour que la carte soit entièrement chargée!",
	question_button = "Appuyez ici pour poser la question!",
	more_players = "Il doit y avoir un minimum de deux joueurs pour que le jeu commence!",
	question = "Tapez la question",
	true_choice = "Vrai",
	false_choice = "Fraux",
	map_name = "Vrai ou faux",
	live_mices = "Souris:",
	current_round = "Ronde actuel: ",
	actual_shaman = "Chamane: ",
	waiting_question1 = "Attendez pendant que ",
	waiting_question2 = " pose la question",
	your_question = "Ta question ",
	next_round = " Prochain tour dans ",
	seconds = " secondes",
	everybody_died = "Tout le monde est mort!",
	winner = "Le gagnant est ",
	no_time = "Le temps est écoulé.",
	mestre_out = "Le chaman a abandonné le jeu!",
	mestre_skip = " sauté à votre tour!",
	close = "Fermer",
	credit ="Crédits",
	instructions = "Instructions",
	information = "Informations",
	commands = "Commandes",
	credit_help = "<p align='center'><CE>Crédits<BR><BR><p align='left'><CH>Développeur: <N>Homerre#0000<BR><p align='left'><CH>Idée, traductions, layout: <N>Fake_da_annyxd#7479<BR><BR><BR><p align='center'><CE>Remerciementl<BR><BR><p align='left'><VP>Soutien technique: <N>Infectsoul#2048, Sklag#2552<BR><p align='left'><VP>Remerciement spécial: <N>Fuyunohanashi#5024, Phypoy#0010",
	instructions_help = "<p align='center'><CE>Instructions de jeu<BR><BR><p align='LEFT'><N>Le jeu commence avec deux souris ou plus, lorsque le chamane pose une question. Après avoir posé la question, le chaman doit choisir si la réponse est vraie ou fausse. Les joueurs auront 10 secondes pour choisir entre vrai ou faux. Celui qui reste indécis et ne choisit aucun camp perd.<BR>Le gagnant sera le dernier survivant et deviendra le prochain chamane.<BR>Si personne ne survit, le chaman est choisi au hasard.",
	information_help = "<p align='center'><CE>Informations sur le jeu<BR><BR><p align='LEFT'><N>Le temps pour poser une question sera initialement de 60 secondes. Cependant, lorsque 10 tours passent, le temps diminue à 45 secondes et après 20 tours, il tombe à 30 secondes. Alors n'hésitez pas à poser vos questions!<BR><BR>Les joueurs auront 10 secondes pour décider si la réponse à la question est vraie ou fausse. Sinon, on considérera que vous avez perdu la manche.<BR><BR>Chaque bonne réponse rapporte un point au joueur. Le prochain chaman sera le dernier survivant, c'est-à-dire le joueur qui aura marqué le plus de points! <BR><BR>Évitez de poser des questions d'opinion ou des questions auxquelles il n'est pas possible de répondre par vrai ou faux.",
	commands_help = "<p align='center'><CE>Commandes<BR><BR><p align='left'><A:ACTIVE>!help <N>- affiche plus d'informations sur le mini-jeu<BR><A:ACTIVE>!q <N>- faire une question<BR><A:ACTIVE>!skip <N>- passe le tour de le chamane",
	true_answer = "La réponse est vraie!",
	false_answer = "La réponse est fausse!"

}

lang.es = {

	welcome = "¡Bienvenidos! ¡Espera a la siguiente ronda para que el mapa esté completamente cargado!",
	question_button = "¡Presiona aquí para hacer la pregunta!",
	more_players = "¡Debe haber un mínimo de dos jugadores para que comience el juego!",
	question = "Escriba la pregunta: ",
	true_choice = "Verdadero",
	false_choice = "Falso",
	map_name = "Verdadero o falso",
	live_mices = "Ratónes vivos: ",
	current_round = "Ronda actual: ",
	actual_shaman = "Chamán: ",
	waiting_question1 = "Espera mientras ",
	waiting_question2 = " esta haciendo la pregunta",
	your_question = "Su pregunta: ",
	next_round = " Próxima ronda en ",
	seconds = " segundos",
	everybody_died = "¡Todos murieron!",
	winner = "El ganador es ",
	no_time = "¡Tiempo agotado!",
	mestre_out = "¡El chamán abandonó el juego!",
	mestre_skip = " saltó su turno!",
	close = "Cierra",
	credit = "Creditos",
	instructions = "Instrucciones",
	information = "Informaciones",
	commands = "Comandos",
	credit_help = "<p align='center'><CE>Credits<BR><BR><p align='left'><CH>Programador: <N>Homerre#0000<BR><p align='left'><CH>Idea, traducciones, layout: <N>Fake_da_annyxd#7479<BR><BR><BR><p align='center'><CE>Agradecimientos<BR><BR><p align='left'><VP>Apoyo técnico: <N>Infectsoul#2048, Sklag#2552<BR><p align='left'><VP>Gracias especiales: <N>Fuyunohanashi#5024, Phypoy#0010",
	instructions_help = "<p align='center'><CE>Instrucciones del juego <BR><BR><p align='LEFT'><N>El juego se inicia con dos o más ratones, cuando el chamán hace una pregunta. Después de hacer la pregunta, el chamán debe elegir si la respuesta es verdadera o falsa. Los jugadores tendrán 10 segundos para elegir entre verdadero o falso. El que permanece indeciso y elige ningún lado pierde.<BR>El ganador será el último sobreviviente y se convertirá en el próximo chamán. <BR>Si nadie sobrevive, se elige al chamán al azar.",
	information_help = "<p align='center'><CE>Información del juego<BR><BR><p align='LEFT'><N>El tiempo para hacer una pregunta será inicialmente de 60 segundos. Sin embargo, cuando pasen 10 rondas, el tiempo se reducirá a 45 segundos, y después de 20 rondas, se reducirá a 30 segundos. Por lo tanto, sea rápido para hacer sus preguntas! <BR><BR>Los jugadores tendrán 10 segundos para decidir si la respuesta de la pregunta es verdadera o falsa. De lo contrario, se considerará que perdiste la ronda.<BR><BR>Cada respuesta correcta le da al jugador un punto. El próximo chamán será el último superviviente, es decir, ¡el jugador que haya sumado más puntos! <BR><BR>Evite hacer preguntas de opinión o preguntas que no sea posible responder con verdadero o falso.",
	commands_help = "<p align='center'><CE>Comandos<BR><BR><p align='left'><A:ACTIVE>!help <N>-muestra más información sobre el minijuego<BR><A:ACTIVE>!q <N>- haz una pregunta siendo chamán<BR><A:ACTIVE>!skip <N>- se salta el turno del chamán",
	true_answer = "¡La respuesta es verdadera!",
	false_answer = "¡La respuesta es falsa!"

}

--local pisoTrue = {type = 12,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x008000',miceCollision = true,groundCollision = true,dynamic = false}
--local pisoFalse = {type = 12,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x8B0000',miceCollision = true,groundCollision = true,dynamic = false}
local pisoResposta = {type = 10,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
local pisoBloqueio = {type = 10,width = 152,height = 10,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
local pisoParede = {type = 10,width = 40,height = 400,foregound = 1,friction = 0,restitution = 0.0,angle = 0,color = 0,miceCollision = true,groundCollision = true,dynamic = false}
local pisoTransparente = {type = 8,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = false}
local pisoAcido = {type = 19,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = false}
local pisoAgua = {type = 9,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = false,groundCollision = true,dynamic = false}
local pisoFalso = {type = 10,width = 285,height = 30,foregound = 1,friction = 1.0,restitution = 0.0,angle = 0,color = '0x00FF7F',miceCollision = true,groundCollision = true,dynamic = true}


id["label_question_button"] = 1
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
id["boasvindas_label"] = 29

---------------------------------------------FUNCTIONS SOBRE A ENTRADA E SAIDA DE JOGADORES------------------------------------------------------------

function translate(player, key)
	local community = tfm.get.room.playerList[player].community
	
	if community ~= "pt" then
		return lang.br[key]
	end
	if community ~= "en" and community ~= "br" and community ~= "fr" and community ~= "es" then
		return lang.en[key]
	end

	--return lang[community][key]
	return lang.bt[key]
end

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

  tfm.exec.addImage("185c708dd6f.jpg", "?1", 0, 20)
  ui.addTextArea(id["boasvindas_label"], "<font size='20'>"..translate(nomeDoJogador, "welcome").."</font></p>", nomeDoJogador, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
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
	--perguntaFeita = false
	num_de_jogadores_vivos = 0
	for name,player in next,tfm.get.room.playerList do
		num_de_jogadores_vivos=num_de_jogadores_vivos+1
	end

	updatePlayersList()
	tfm.exec.addImage("174042eda4f.png", "%Fake_da_annyxd#7479", -21, -30)
	tfm.exec.addImage("185c708dd6f.jpg", "?1", 0, 20)

	if numeroDeJogadores() >= 2 and not temVencedor then --MUDAR PARA 2 DEPOIS QUE TERMINAR TUDO
		antigoMestre = mestre
		while(antigoMestre == mestre) do
			mestre = randomPlayer()
		end
		tfm.exec.killPlayer(mestre)
	end

	if numeroDeJogadores() >= 2 and temVencedor then
		mestre = vencedor
		temVencedor = false
		tfm.exec.killPlayer(mestre)
	end


	novaPergunta()

	ui.addTextArea(id["botao_help"], "<font size='18'><p align='center'><a href='event:callbackHelp'>".."?".."</font></a></p>", nil, 720, 35, 20, 25, nil, nil, 1f)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------CRIAÇÃO DO CENÁRIO DA PERGUNTA------------------------------------------------------------
function novaPergunta()
	ui.removeTextArea(id["boasvindas_label"])
	perguntaFeita = false
	intervalo = false

	if numeroDeJogadores() >= 2 then 
		ui.removeTextArea(id["question_label"])

		for name,player in next,tfm.get.room.playerList do
			tfm.exec.movePlayer(name,400,60,false)
			if not tfm.get.room.playerList[name].isDead then
  			tfm.exec.setPlayerScore(name, pontuacao, false)
			end

			if (name~=mestre) then
				ui.removeTextArea(id["label_question_button"])
  		end
  		ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..translate(name,"waiting_question1")..mestre..translate(name,"waiting_question2").. "</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
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
		
		resposta = nil
		fazerPergunta()
	else
		onePlayer = true
		ui.addTextArea(id["time"],"<p align='center'><font size='45'>".."?".."",nil,360,213,80,60,0x000001,0x494949,1.0)
		for name,player in next,tfm.get.room.playerList do	
			ui.addTextArea(id["one_player_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..translate(name, "more_players").. "</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)	
		end
	end

	tfm.exec.addPhysicObject(id["piso_gelo"], 400, 120, pisoBloqueio)
	tfm.exec.addPhysicObject(id["piso_verdadeiro"], 182, 275, pisoResposta)
	tfm.exec.addPhysicObject(id["piso_falso"], 618, 275, pisoResposta)
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
		for name,player in next,tfm.get.room.playerList do
			ui.addTextArea(id["label_question_button"], "<p align='center'><a href='event:callbackAskWord'><font size='11'>"..translate(mestre, "question_button").."</a></p>", mestre, 295, 150, 210, 20, nil, nil, 1f) --BOTÃO PERGUNTA
  	end
  end
end

-----------------------------------------------------QUANDO O MESTRE DECIDE SE É TRUE OR FALSE------------------------------------------------------------
function eventTextAreaCallback(textAreaId, playerName, callback)
  if callback=="callbackAskWord" and playerName==mestre then
  	--addPopup(Int id, Int type, String text, String targetPlayer, Int x, Int y, Int width, Boolean fixedPos (false))
    ui.addPopup(id["ask_word_popup"], 2, translate(mestre, "question"), mestre, 300, 120, 200) 
  end

  if callback == "callbackTrue" then
  	ui.removeTextArea(id["one_player_label"]) 
  	tfm.exec.setGameTime(10)
  	tfm.exec.removePhysicObject(id["piso_gelo"])
   	ui.addTextArea(id["question_label"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..questionPlayer.. "</font></font></p>", nil, 40, 300, 720, 100, 0xC0C0C0, 0xC0C0C0, 0f)
 	 	ui.removeTextArea(id["label_question_button"])
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
  	ui.removeTextArea(id["label_question_button"])
  	ui.removeTextArea(id["resposta_true"])
  	ui.removeTextArea(id["resposta_false"])
  	perguntaFeita = true
  	resposta = false
  end	

  if callback == "callbackHelp" then
  	helpMenuOpen = true
  	ui.addTextArea(id["fundo_help"], " ", playerName, 112, 50, 575, 320, nil, nil, 1.0, true)
  	ui.addTextArea(id["botao_fechar"], "<a href='event:callbackClose'><p align='center'><font size='20'>" ..translate(playerName, "close").. "</a></p>", playerName, 359, 330, 80, 30, nil, nil, 1f, true)
  	ui.addTextArea(id["botao_creditos"], "<font size='12'><p align='center'><a href='event:callbackCreditos'>"..translate(playerName, "credit").."</font></a></p>", playerName, 132, 60, 85, 20, nil, nil, 1f, true)
  	ui.addTextArea(id["botao_intrucoes"], "<font size='12'><p align='center'><a href='event:callbackInstrucoes'>"..translate(playerName, "instructions").."</font></a></p>", playerName, 276, 60, 85, 20, nil, nil, 1f, true)
  	ui.addTextArea(id["botao_informacoes"], "<font size='12'><p align='center'><a href='event:callbackInformacoes'>"..translate(playerName, "information").."</font></a></p>", playerName, 420, 60, 85, 20, nil, nil, 1f, true)
  	ui.addTextArea(id["botao_comandos"], "<font size='12'><p align='center'><a href='event:callbackComandos'>"..translate(playerName, "commands").."</font></a></p>", playerName, 564, 60, 85, 20, nil, nil, 1f, true)
  	ui.addTextArea(id["help_label"], "<font size='12'>" ..translate(playerName, "credit_help").. "</a></p>", playerName, 140, 100, 530, 230, 0xf, 0xf, 2, true)
  end

  if callback == "callbackClose" then
  	helpMenuOpen = false
  	ui.removeTextArea(id["fundo_help"], playerName)
  	ui.removeTextArea(id["help_label"], playerName)
  	ui.removeTextArea(id["botao_fechar"], playerName)
  	ui.removeTextArea(id["botao_creditos"], playerName)
  	ui.removeTextArea(id["botao_intrucoes"], playerName)
  	ui.removeTextArea(id["botao_informacoes"], playerName)
  	ui.removeTextArea(id["botao_comandos"], playerName)
  end

  if callback == "callbackCreditos" then
  	ui.addTextArea(id["help_label"], "<font size='12'>" ..translate(playerName, "credit_help").. "</a></p>", playerName, 140, 100, 520, 230, 0xf, 0xf, 2, true)
  end
  if callback == "callbackInstrucoes" then
		ui.addTextArea(id["help_label"], "<font size='12'>" ..translate(playerName, "instructions_help").. "</a></p>", playerName, 140, 100, 520, 230, 0xf, 0xf, 2, true)
  end
  if callback == "callbackInformacoes" then
  	ui.addTextArea(id["help_label"], "<font size='12'>" ..translate(playerName, "information_help").. "</a></p>", playerName, 140, 100, 520, 230, 0xf, 0xf, 2, true)
  end
  if callback == "callbackComandos" then
  	ui.addTextArea(id["help_label"], "<font size='12'>" ..translate(playerName, "commands_help").. "</a></p>", playerName, 140, 100, 520, 230, 0xf, 0xf, 2, true)
  end
end

function eventPopupAnswer(popupId, playerName, answerPopUp)
  if popupId==id["ask_word_popup"] and mestre==playerName and not perguntaFeita then
  	--criar cenário pós pergunta ser enviada
  	if answerPopUp ~= "" then
  		tfm.exec.chatMessage("<VP>"..translate(playerName, "your_question")..answerPopUp,playerName)
	  	questionPlayer = answerPopUp
	  	ui.addTextArea(id["resposta_true"], "<p align='center'><a href='event:callbackTrue'>"..translate(mestre, "true_choice").."</a></p>", mestre, 142, 200, 80, 20, nil, nil, 1f)
	  	ui.addTextArea(id["resposta_false"], "<p align='center'><a href='event:callbackFalse'>"..translate(mestre, "false_choice").."</a></p>", mestre, 593, 200, 50, 20, nil, nil, 1f)
  	end
  end
end

----------------------------------------------------------------------------------------------------------
function eventLoop(tempoAtual, tempoRestante)
	ui.setMapName("<N><J>"..lang.br.map_name.." <N>   "..lang.br.live_mices.." <V>"..num_de_jogadores_vivos.."</V> / <J>"..(qtd_de_jogadores-1).." <BL>|<N> "..lang.br.current_round.."<V>"..rodada.." | <VP><b>"..lang.br.actual_shaman.."</b><N><ROSE>"..mestre.."<BL><")

	if tempoRestante < 500 and perguntaFeita and not intervalo then
		for name,player in next,tfm.get.room.playerList do
			if tfm.get.room.playerList[name].y >= 0 and tfm.get.room.playerList[name].y <= 200 then
				tfm.exec.killPlayer(name)
			end
		end
		tfm.exec.setGameTime(5)
		if math.floor(tempoRestante/1000) == 1 then
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
		intervalo = true
		morte(resposta, 7)
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
			for name,player in next,tfm.get.room.playerList do
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..translate(name, "everybody_died")..translate(name, "next_round")..math.floor(6 - timerReset)..translate(name, "seconds").."</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
			end
		end
		--DEFININDO O VENCEDOR! FUNCIONA
		if num_de_jogadores_vivos == 1 and numeroDeJogadores() > 2 then
				for name, player in next, tfm.get.room.playerList do
					ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..translate(name, "winner")..name.."!"..translate(name, "next_round")..math.floor(6 - timerReset)..translate(name, "seconds").."</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
					if not tfm.get.room.playerList[name].isDead then
						vencedor = name
						temVencedor = true
					end
				end		
		end
		if fimDoTempo then 
			ui.removeTextArea(id["label_question_button"])
			for name,player in next,tfm.get.room.playerList do	
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..translate(name, "no_time")..translate(name, "next_round")..math.floor(6 - timerReset)..translate(name, "seconds").."</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f) 
			end
		end
		if mestreOut then 
			for name,player in next,tfm.get.room.playerList do
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..translate(name, "mestre_out")..translate(name, "next_round")..math.floor(6 - timerReset)..translate(name, "seconds").."</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f) 
			end
		end
		if mestreSkip then
			for name,player in next,tfm.get.room.playerList do
				ui.addTextArea(id["question_reset"], "<font size='20'><p align='center'><BL><font color='#DCDCDC'>" ..mestre..translate(name, "mestre_skip")..translate(name, "next_round")..math.floor(6 - timerReset)..translate(name, "seconds").."</font></font></p>", name, 20, 340, 750, 30, 0xC0C0C0, 0xC0C0C0, 0f)
			end
		end	
	end

	if timerReset==5 then
		hasToReset = true
		fimDoTempo = false
		mestreOut = false
		mestreSkip = false
    reset()
  end

  if not intervalo and not necessarioResetar and not onePlayer and math.floor(tempoRestante/1000) > 0 then
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
			tfm.exec.removePhysicObject(id["piso_verdadeiro"])
			tfm.exec.addPhysicObject(id["piso_falso"], 180, 275, pisoTransparente)
		end
		if numero == 3 then
			tfm.exec.addPhysicObject(id["piso_falso"], 618, 273, pisoFalso)		
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
		if numero == 7 then
			for name,player in next,tfm.get.room.playerList do
				if tfm.get.room.playerList[name].x >= 470 and tfm.get.room.playerList[name].x <= 800 then
					tfm.exec.setPlayerGravityScale(name, -1)
				end
			end
		end

		for name,player in next,tfm.get.room.playerList do
			tfm.exec.chatMessage("<VP>"..translate(name, "true_answer"),name)
		end
	end

	if condicao == false then
		if numero == 1 then
			tfm.exec.removePhysicObject(id["piso_verdadeiro"])
		end	
		if numero == 2 then
			tfm.exec.removePhysicObject(id["piso_falso"])
			tfm.exec.removePhysicObject(id["piso_verdadeiro"])
			tfm.exec.addPhysicObject(id["piso_verdadeiro"], 618, 275, pisoTransparente)
		end
		if numero == 3 then
			tfm.exec.addPhysicObject(id["piso_verdadeiro"], 180, 275, pisoFalso)		
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
		if numero == 7 then
			for name,player in next,tfm.get.room.playerList do
				if tfm.get.room.playerList[name].x >= 0 and tfm.get.room.playerList[name].x <= 330 then
					tfm.exec.setPlayerGravityScale(name, -1)
				end
			end
		end

		for name,player in next,tfm.get.room.playerList do
			tfm.exec.chatMessage("<CR>"..translate(name, "false_answer"),name)
		end
	end
	intervalo = true
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------PRECISA MELHORAR O RESET---------------------------------------------------------------------------------------------------------------
function reset()
	necessarioResetar = true

	ui.removeTextArea(id["question_reset"])
	ui.removeTextArea(id["ask_word_popup"])
	ui.removeTextArea(id["label_question_button"])
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
	if message == "q" and playerName == mestre and not perguntaFeita then
		eventTextAreaCallback(0, mestre, "callbackAskWord")
	end
	if message == "help" then
		if not helpMenuOpen then
			eventTextAreaCallback(0, playerName, "callbackHelp")
		else
			eventTextAreaCallback(0, playerName, "callbackClose")
		end
	end
end

system.disableChatCommandDisplay(skip, true)
system.disableChatCommandDisplay(q, true)
system.disableChatCommandDisplay(help, true)

tfm.exec.newGame("@7917347")