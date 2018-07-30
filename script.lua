function sendPlayerMessage(playerid, text, r, g, b)
	outputChatBox(text, playerid, r, g, b)
end

function givePlayerWeapon( playerid, weapon, ammo )
	giveWeapon(playerid, weapon, ammo)
end

function isPointInCircle3D(x, y, z, x1, y1, z1, radius)
	local hash = createColSphere ( x, y, z, radius )
	local area = isInsideColShape( hash, x1, y1, z1 )
	destroyElement(hash)
	return area
end

function getPlayerVehicle( playerid )
	local vehicle = getPedOccupiedVehicle ( playerid )
	return vehicle
end

local database = dbConnect( "sqlite", "ebmp-ver-4.db" )

function sqlite(text)
	local result = dbQuery( database, text )
	local result = dbPoll( result, -1 )
	return result
end

local earth = {}--слоты земли
local max_earth = 50

for i=1,max_earth do
	earth[i] = {0,0,0,0,0}
end

function timer_earth()
	for k,v in pairs(getElementsByType("player")) do
		for i=1,max_earth do
			triggerClientEvent( v, "event_earth_loadd", v, i, earth[i][1], earth[i][2], earth[i][3], earth[i][4], earth[i][5] )
		end
	end
end

local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 17

local info_png = {
	[0] = {"", ""},
	[1] = {"Деньги", "$"},
	[2] = {"Права на имя", ""},
	[3] = {"Сигареты Big Break Red", "шт в пачке"},
	[4] = {"error", ""},
	[5] = {"Канистра с", "галл."},
	[6] = {"Ключ от автомобиля с номером", ""},
	[7] = {"Сигареты Big Break Blue", "сигарет в пачке"},
	[8] = {"Сигареты Big Break White", "сигарет в пачке"},
	[9] = {"Grenade", "ID"},
	[10] = {"Полицейское удостоверение на имя", ""},
	[11] = {"Патроны 25 шт для", "ID"},
	[12] = {"Colt-45", "ID"},
	[13] = {"Deagle", "ID"},
	[14] = {"AK-47", "ID"},
	[15] = {"M4", "ID"},
	[16] = {"Tec-9", "ID"},
	[17] = {"MP5", "ID"},
	[18] = {"Uzi", "ID"},
	[19] = {"Teargas", "ID"},
	[20] = {"Наркотики", "гр"},
	[21] = {"Пиво старый эмпайр", "шт"},
	[22] = {"Пиво штольц", "шт"},
	[23] = {"Наручные часы Empire, состояние", "%"},
	[24] = {"Ящик, цена продажи", "$"},
	[25] = {"Ключ от дома с номером", ""},
	[26] = {"Ключ от автомобиля с номером", ""},
	[27] = {"", "одежда"},
	[28] = {"Шеврон Офицера", "шт"},
	[29] = {"Шеврон Детектива", "шт"},
	[30] = {"Шеврон Сержанта", "шт"},
	[31] = {"Шеврон Лейтенанта", "шт"},
	[32] = {"Шеврон Капитан", "шт"},
	[33] = {"Шеврон Шефа полиции", "шт"},
	[34] = {"Shotgun", "ID"},
	[35] = {"Parachute", "ID"},
	[36] = {"Nightstick", "ID"},
	[37] = {"Bat", "ID"},
	[38] = {"Knife", "ID"}
}

----цвета----
local color_tips = {168,228,160}--бабушкины яблоки
local yellow = {255,255,0}--желтый
local red = {255,0,0}--красный
local blue = {0,150,255}--синий
local white = {255,255,255}--белый
local green = {0,255,0}--зеленый
local turquoise = {0,255,255}--бирюзовый
local orange = {255,100,0}--оранжевый
local pink = {255,100,255}--розовый
local lyme = {130,255,0}--лайм админский цвет
local svetlo_zolotoy = {255,255,130}--светло-золотой

local me_radius = 10--радиус отображения действий игрока в чате

local max_inv = 23--слоты инв-ря

--инв-рь игрока
local array_player_1 = {}
local array_player_2 = {}

--инв-рь авто
local array_car_1 = {}
local array_car_2 = {}

--инв-рь дома
local array_house_1 = {}
local array_house_2 = {}

local state_inv_player = {}--состояние инв-ря 0-выкл, 1-вкл

function displayLoadedRes ( res )--старт ресурсов
	setTimer(timer_earth, 5000, 0)
end
addEventHandler ( "onResourceStart", getRootElement(), displayLoadedRes )

addEventHandler("onPlayerJoin", getRootElement(),--конект игрока на сервер
function()
	local playerid = source
	local playername = getPlayerName ( playerid )

	array_player_1[playername] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_player_2[playername] = {500,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	local result = sqlite( "SELECT * FROM inventory WHERE name = '"..playername.."'" )
	for i=0,max_inv do
		array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
		array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
	end

	array_car_1[1] = {2,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_car_2[1] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	array_house_1[1] = {2,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_house_2[1] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	state_inv_player[playername] = 0

	----бинд клавиш----
	bindKey(playerid, "tab", "down", tab_down )
	bindKey(playerid, "e", "down", e_down )

	spawnPlayer(playerid, spawnX, spawnY, spawnZ)
	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)

	for _, stat in ipairs({ 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
		setPedStat(playerid, stat, 999)
	end
end)

function quitPlayer ( quitType )--дисконект игрока с сервера
	local playerid = source
	local playername = getPlayerName ( playerid )

	array_player_1[playername] = nil
	array_player_2[playername] = nil

	state_inv_player[playername] = nil
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )


function player_Spawn (playerid)--спавн игрока
	spawnPlayer(playerid, spawnX, spawnY, spawnZ)
end


addEventHandler( "onPlayerWasted", getRootElement(),--смерть игрока
function(ammo, attacker, weapon, bodypart)
	setTimer( player_Spawn, 5000, 1, source )
end)

function explode_car()
	local vehicle = source
	destroyElement(vehicle)
	sendPlayerMessage(getRootElement(), "vehicle delet ["..tostring(vehicle).."]")
end
addEventHandler("onVehicleExplode", getRootElement(), explode_car)

function enter_car ( vehicle, seat, jacked )--евент входа в авто
	local playerid = source

	sendPlayerMessage(playerid, "function enter_car" )
	local upgrades = getVehicleUpgrades ( vehicle )
    for v, upgrade in ipairs ( upgrades ) do
        sendPlayerMessage(playerid, getVehicleUpgradeSlotName ( upgrade ) .. ": " .. upgrade )
    end
end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), enter_car )

function exit_car ( vehicle, seat, jacked )--евент выхода из авто
	local playerid = source

	triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )
end
addEventHandler ( "onPlayerVehicleExit", getRootElement(), exit_car )

function randomize_number()--генератор номеров для авто
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

function tab_down (playerid, key, keyState)--открытие инв-ря игрока
local playername = getPlayerName ( playerid )
local vehicleid = getPlayerVehicle(playerid)

	if keyState == "down" then
		if state_inv_player[playername] == 0 then --инв-рь игрока
			for i=0,max_inv do
				triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )

				if vehicleid then
					local plate = getVehiclePlateText ( vehicleid )
					triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[1][i+1], array_car_2[1][i+1] )
					triggerClientEvent( playerid, "event_tab_load", playerid, "car", plate )
				end

				triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, array_house_1[1][i+1], array_house_2[1][i+1] )
				triggerClientEvent( playerid, "event_tab_load", playerid, "house", "0" )
			end

			triggerClientEvent( playerid, "event_inv_create", playerid )
			state_inv_player[playername] = 1
		elseif state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_inv_delet", playerid )
			showCursor(playerid, false )
			state_inv_player[playername] = 0
		end
	end
end

function throw_earth_server (playerid, value, id3, id1, id2)--выброс предмета
	for i=1,max_earth do
		if earth[i][4] == 0 then
			local playername = getPlayerName ( playerid )
			local x,y,z = getElementPosition(playerid)

			earth[i][1] = x
			earth[i][2] = y
			earth[i][3] = z
			earth[i][4] = id1
			earth[i][5] = id2

			inv_server_load(playerid, value, id3, 0, 0)

			triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, 0, 0 )
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, 0 )

			sendPlayerMessage(playerid, "Вы выкинули "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])
			return
		end
	end
end
addEvent( "event_throw_earth_server", true )
addEventHandler ( "event_throw_earth_server", getRootElement(), throw_earth_server )

function e_down (playerid, key, keyState)--подбор предметов с земли
local x,y,z = getElementPosition(playerid)
local playername = getPlayerName ( playerid )

	if keyState == "down" then
		for j=1,max_earth do
			local area = isPointInCircle3D( x, y, z, earth[j][1], earth[j][2], earth[j][3], 20 )

			if area and earth[j][4] ~= 0 then
				for i=0,max_inv do
					if array_player_1[playername][i+1] == 0 then
						inv_server_load( playerid, "player", i, earth[j][4], earth[j][5] )
						triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, earth[j][4], earth[j][5] )

						if state_inv_player[playername] == 1 then
							triggerClientEvent( playerid, "event_change_image", playerid, "player", i, earth[j][4])
						end

						sendPlayerMessage(playerid, "Вы подняли "..info_png[earth[j][4]][1].." "..earth[j][5].." "..info_png[earth[j][4]][2], svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])

						earth[j][1] = 0
						earth[j][2] = 0
						earth[j][3] = 0
						earth[j][4] = 0
						earth[j][5] = 0
						return
					end
				end

				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон.", red[1], red[2], red[3])
			end
		end
	end
end

function inv_server_load (playerid, value, id3, id1, id2 )--изменение инв-ря на сервере
	local playername = getPlayerName ( playerid )

	if value == "player" then
		array_player_1[playername][id3+1] = id1
		array_player_2[playername][id3+1] = id2
		sqlite( "UPDATE inventory SET slot_"..id3.."_1 = '"..array_player_1[playername][id3+1].."', slot_"..id3.."_2 = '"..array_player_2[playername][id3+1].."' WHERE name = '"..playername.."'")
	elseif value == "car" then
		array_car_1[1][id3+1] = id1
		array_car_2[1][id3+1] = id2
	elseif value == "house" then
		array_house_1[1][id3+1] = id1
		array_house_2[1][id3+1] = id2
	end
end
addEvent( "event_inv_server_load", true )
addEventHandler ( "event_inv_server_load", getRootElement(), inv_server_load )

addCommandHandler ( "sub",--выдача предметов с числом
function (playerid, cmd, id1, id2 )
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			array_player_1[playername][i+1] = tonumber(id1)
			array_player_2[playername][i+1] = tonumber(id2)

			inv_server_load( playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, array_player_1[playername][i+1])
			end

			sendPlayerMessage(playerid, "вы создали ["..i.."] ["..array_player_1[playername][i+1].."] ["..array_player_2[playername][i+1].."]", lyme[1], lyme[2], lyme[3])
			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Инвентарь полон.", red[1], red[2], red[3])
end)

addCommandHandler ( "subt",--выдача предметов с текстом
function (playerid, cmd, id1, id2 )
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			array_player_1[playername][i+1] = tonumber(id1)
			array_player_2[playername][i+1] = id2

			inv_server_load( playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, array_player_1[playername][i+1])
			end

			sendPlayerMessage(playerid, "вы создали ["..i.."] ["..array_player_1[playername][i+1].."] ["..array_player_2[playername][i+1].."]", lyme[1], lyme[2], lyme[3])
			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Инвентарь полон.", red[1], red[2], red[3])
end)

addCommandHandler ( "area",
function (playerid, cmd )
	local x, y, z = getElementPosition( playerid )
	sendPlayerMessage(playerid, tostring(isPointInCircle3D(1959.55,-1714.46,17, x,y,z, 5)))
end)

addCommandHandler ( "v",
function ( playerid, cmd, id )
	local x,y,z = getElementPosition( playerid )
	local vehicleid = createVehicle(tonumber(id), x+5, y, z+2, 0, 0, 0, randomize_number())

	sendPlayerMessage(playerid, "spawn vehicle "..id.." ["..tostring(vehicleid).."] "..getVehicleNameFromModel ( tonumber ( id ) ))
end)

addCommandHandler ( "paint",
function ( playerid, cmd, id )
	local vehicleid = getPlayerVehicle(playerid)
	local value = tonumber(id)
	if vehicleid then
		setVehiclePaintjob ( vehicleid, value )
	end
end)

addCommandHandler ( "upd",
function ( playerid, cmd, id )
	local vehicleid = getPlayerVehicle(playerid)
	local value = tonumber(id)
	local text = ""
	if vehicleid then
		addVehicleUpgrade ( vehicleid, value )

		local model = getElementModel ( vehicleid )

		sendPlayerMessage(playerid, "addCommandHandler upd" )
		sendPlayerMessage(playerid, "model - "..model )

		local upgrades = getVehicleUpgrades ( vehicleid )
		for _, upgrade in pairs ( upgrades ) do
			if value == upgrade then
				text = text..upgrade..","
			end
		end

		sendPlayerMessage(playerid, text)
	end
end)

addCommandHandler ( "getupd",
function ( playerid )
	local text = ""
	local vehicleid = getPlayerVehicle(playerid)
	if vehicleid then
		local model = getElementModel ( vehicleid )

		sendPlayerMessage(playerid, "addCommandHandler getupd" )
		sendPlayerMessage(playerid, "model - "..model )	

		for i=1000,1193 do
			addVehicleUpgrade ( vehicleid, i )

			local upgrades = getVehicleUpgrades ( vehicleid )
			for _, upgrade in pairs ( upgrades ) do
				if i == upgrade then
					text = text..upgrade..","
				end
			end
		end

		sendPlayerMessage(playerid, text)
	end
end)

addCommandHandler ( "getupd2",
function ( playerid )
	local text = ""
	local vehicleid = getPlayerVehicle(playerid)
	if vehicleid then
		local model = getElementModel ( vehicleid )

		sendPlayerMessage(playerid, "addCommandHandler getupd2" )
		sendPlayerMessage(playerid, "model - "..model )	

			local upgrades = getVehicleUpgrades ( vehicleid )
			for _, upgrade in pairs ( upgrades ) do
				text = text..upgrade..","
			end

		sendPlayerMessage(playerid, text)
	end
end)

addCommandHandler( "color",
function( playerid )
	if isPedInVehicle( playerid ) then
		local uVehicle = getPlayerVehicle( playerid )
		if uVehicle then
			local r, g, b = math.random( 255 ), math.random( 255 ), math.random( 255 )
			setVehicleColor( uVehicle, r, g, b, r, g, b, r, g, b, r, g, b )
			setVehicleHeadLightColor ( uVehicle, r, g, b )
			sendPlayerMessage(playerid, r.." "..g.." "..b)
		end
	end
end)

addCommandHandler ( "go",
function ( playerid, cmd, x, y, z )
	spawnPlayer(playerid, tonumber(x), tonumber(y), tonumber(z))
end)

function input_Console ( text )
	if text == "z" then
		print(white[1])
	elseif text == "x" then
		
	end
end
addEventHandler ( "onConsole", getRootElement(), input_Console )

addCommandHandler("hp",
function (source)
	local vehicle = getPlayerVehicle(source)
	local playerHealth = getElementHealth(source)
	
	if vehicle then
		local vehicleHP = getElementHealth(vehicle)
		if vehicleHP == 1000 then
			outputChatBox("[Ошибка] #FFFFFFВаш транспорт не нуждаетсая в ремонте!",source, 180,0,0, true)
		else
			fixVehicle(vehicle)
			outputChatBox("Ваш транспорт отремонтирован!",source, 7,145,0)
		end
	else
		if playerHealth == 100 then
			outputChatBox("[Ошибка] #FFFFFFВаше здоровье не нуждается в пополнении!",source, 180,0,0, true)
		else
			setElementHealth(source, 100)
			outputChatBox("Ваше здоровье полностью пополнено!",source, 7,145,0)
		end
	end
end)
