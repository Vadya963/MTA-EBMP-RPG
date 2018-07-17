function sendPlayerMessage(playerid, text, r, g, b)
	outputChatBox(text, playerid, r, g, b)
end

function givePlayerWeapon( playerid, weapon, ammo )
	giveWeapon(playerid, weapon, ammo)
end

function isPointInCircle3D(x, y, z, x1, y1, z1, radius)
	return isInsideColShape( createColSphere ( x, y, z, radius ), x1, y1, z1 )
end

local database = dbConnect( "sqlite", "ebmp-ver-4.db" )

local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 17

local state_inv_player = 0
local max_inv = 23

local array_player_1 = {}
local array_player_2 = {}

addEventHandler("onPlayerJoin", getRootElement(),
function()
	local playerid = source
	local playername = getPlayerName ( playerid )

	array_player_1[playername] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_player_2[playername] = {500,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	bindKey(playerid, "tab", "down", tab_down )

	spawnPlayer(playerid, spawnX, spawnY, spawnZ)
	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)

	for _, stat in ipairs({ 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
		setPedStat(playerid, stat, 999)
	end
end)

function quitPlayer ( quitType )
	local playerid = source
	local playername = getPlayerName ( playerid )

	array_player_1[playername] = nil
	array_player_2[playername] = nil
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )


function player_Spawn (playerid)
	spawnPlayer(playerid, spawnX, spawnY, spawnZ)
end


addEventHandler( "onPlayerWasted", getRootElement(),
function(ammo, attacker, weapon, bodypart)
	setTimer( player_Spawn, 2000, 1, source )
end)

function randomize_number()
	math.randomseed(getTickCount())
	local randomize = math.random(0,9999)
	local number_car = {"q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m"}
	local number = ""

	if(randomize >= 0 and randomize <= 9) then
		number = number_car[math.random(#number_car)]..number_car[math.random(#number_car)].."000"..randomize
	elseif(randomize >= 10 and randomize <= 99) then
		number = number_car[math.random(#number_car)]..number_car[math.random(#number_car)].."00"..randomize
	elseif(randomize >= 100 and randomize <= 999) then
		number = number_car[math.random(#number_car)]..number_car[math.random(#number_car)].."0"..randomize
	else
		number = number_car[math.random(#number_car)]..number_car[math.random(#number_car)]..randomize
	end

	return number
end

addCommandHandler ( "v",
function ( playerid, cmd, id )
	local x,y,z = getElementPosition( playerid )
	local vehicleid = createVehicle(tonumber(id), x+5, y, z+2, 0, 0, 0, randomize_number())

	sendPlayerMessage(playerid, "spawn vehicle "..id.." "..getVehicleNameFromModel ( tonumber ( id ) ))
end)

function input_Console ( text )
	if text == "z" then
		local result = dbQuery( database, "SELECT * FROM carnumber_bd WHERE carnumber = 'oh-449'" )
		local result = dbPoll( result, -1 )
		
		print(result[1]["carnumber"])
	elseif text == "x" then
		print(getRealTime())
	end
end
addEventHandler ( "onConsole", getRootElement(), input_Console )

addCommandHandler ( "lis",
function ( playerid, cmd )
	local theVehicle = getPedOccupiedVehicle ( playerid )
	sendPlayerMessage( playerid, ""..tostring(theVehicle) )
end)

local png_number = 35
function tab_down (playerid, key, keyState )
	
local playername = getPlayerName ( playerid )

	if keyState == "down" then
		if state_inv_player == 0 then --инв-рь игрока
			for i=0,max_inv do
				triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, math.random(png_number), math.random(png_number) )
				triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, math.random(png_number), math.random(png_number) )
			end

			triggerClientEvent( playerid, "event_inv_create", playerid )
			state_inv_player = 1
		elseif state_inv_player == 1 then
			triggerClientEvent( playerid, "event_inv_delet", playerid )
			showCursor(playerid, false )
			state_inv_player = 0
		end
	end
end

addCommandHandler ( "sub",
function (playerid, cmd, id1, id2 )
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			array_player_1[playername][i+1] = tonumber(id1)
			array_player_2[playername][i+1] = tonumber(id2)

			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
			if state_inv_player == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, tonumber(id1))
			end

			sendPlayerMessage(playerid, "вы создали ["..i.."] ["..array_player_1[playername][i+1].."] ["..array_player_2[playername][i+1].."]")
			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Инвентарь полон.")
end)

addCommandHandler ( "subt",
function (playerid, cmd, id1, id2 )
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			array_player_1[playername][i+1] = tonumber(id1)
			array_player_2[playername][i+1] = id2

			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
			if state_inv_player == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, tonumber(id1))
			end

			sendPlayerMessage(playerid, "вы создали ["..i.."] ["..array_player_1[playername][i+1].."] ["..array_player_2[playername][i+1].."]")
			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Инвентарь полон.")
end)


addCommandHandler ( "area",
function (playerid, cmd )
	local x, y, z = getElementPosition( playerid )
	sendPlayerMessage(playerid, tostring(isPointInCircle3D(1959.55,-1714.46,17, x,y,z, 5)))
end)
