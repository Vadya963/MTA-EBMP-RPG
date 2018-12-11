function onChat(message, messageType)
	local playerid = source
	local playername = getPlayerName(playerid)

	outputServerLog("CHAT ".. playername ..": ".. message)

	if (messageType == 0) then
		for k,player in pairs(getElementsByType("player")) do
			local player_name = getPlayerName ( player )
			local result = sqlite_save_ignore_player( "SELECT COUNT() FROM "..player_name.." WHERE player_ignore = '"..playername.."'" )
			if result[1]["COUNT()"] == 0 then
				outputChatBox(playername..": "..message, player)
			end
		end
	elseif (messageType == 1) then
		for k,player in pairs(getElementsByType("player")) do
			local player_name = getPlayerName ( player )
			local result = sqlite_save_ignore_player( "SELECT COUNT() FROM "..player_name.." WHERE player_ignore = '"..playername.."'" )
			if result[1]["COUNT()"] == 0 then
				outputChatBox("* "..playername..": "..message, player)
			end
		end
	elseif (messageType == 2) then
		local team = getPlayerTeam(source)
		if (team) then
			for k,player in pairs(getElementsByType("player")) do
				local player_name = getPlayerName ( player )
				local result = sqlite_save_ignore_player( "SELECT COUNT() FROM "..player_name.." WHERE player_ignore = '"..playername.."'" )
				if result[1]["COUNT()"] == 0 then
					outputChatBox("(Team) "..playername..": "..message, player)
				end
			end
		end
	end

	cancelEvent()
end
addEventHandler("onPlayerChat", getRootElement(), onChat)

addEventHandler("onPlayerCommand",root,
function(command)
	local playerid = source
	local playername = getPlayerName(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local player_name = getPlayerName ( player )
		local result = sqlite_save_ignore_player( "SELECT COUNT() FROM "..player_name.." WHERE player_ignore = '"..playername.."'" )
		if result[1]["COUNT()"] == 1 and (command == "me" or command == "msg" or command == "pm") then
			cancelEvent()
		end
	end
end)

local database_save_ignore_player = dbConnect( "sqlite", "save_ignore_player.db" )
function sqlite_save_ignore_player(text)
	local result = dbQuery( database_save_ignore_player, text )
	local result = dbPoll( result, -1 )
	return result
end

addEventHandler("onPlayerJoin", getRootElement(),--конект игрока на сервер
function()
	local playerid = source
	local playername = getPlayerName ( playerid )

	local result = sqlite_save_ignore_player( "SELECT * FROM "..playername.."" )
	if not result then
		sqlite_save_ignore_player( "CREATE TABLE "..playername.." (player_ignore TEXT)" )
	end
end)

addCommandHandler ("blocked",
function (playerid, cmd, text)
	local playername = getPlayerName(playerid)

	if not text then
		outputChatBox("[ERROR] /"..cmd.." [ник игрока]")
		return
	end

	local player = getPlayerFromName ( text )
	if player then
		local player_name = getPlayerName ( player )

		if text == player_name then
			local result = sqlite_save_ignore_player( "SELECT COUNT() FROM "..playername.." WHERE player_ignore = '"..text.."'" )
			if result[1]["COUNT()"] == 0 then
				sqlite_save_ignore_player( "INSERT INTO "..playername.." (player_ignore) VALUES ('"..text.."')" )
				outputChatBox("заблочил игрока")
			else
				sqlite_save_ignore_player( "DELETE FROM "..playername.." WHERE player_ignore = '"..text.."'" )
				outputChatBox("разблочил игрока")
			end
		else
			outputChatBox("[ERROR] Такого игрока нет")
		end
	else
		outputChatBox("[ERROR] Такого игрока нет")
	end
end)