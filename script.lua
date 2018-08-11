local database = dbConnect( "sqlite", "ebmp-ver-4.db" )

local me_radius = 10--радиус отображения действий игрока в чате
local max_inv = 23--слоты инв-ря

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

-------------------пользовательские функции----------------------------------------------
function sqlite(text)
	local result = dbQuery( database, text )
	local result = dbPoll( result, -1 )
	return result
end

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

function getSpeed(vehicle)
	if vehicle then
		local x, y, z = getElementVelocity(vehicle)
		return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))*111.847*1.61--узнает скорость авто в км/ч
	end
end

function me_chat(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendPlayerMessage(player, text, pink[1], pink[2], pink[3])
		end
	end
end
-----------------------------------------------------------------------------------------

-------------------------------эвенты----------------------------------------------------
function addVehicleUpgrade_fun( vehicleid, value )
	addVehicleUpgrade ( vehicleid, value )
end
addEvent( "event_addVehicleUpgrade", true )
addEventHandler ( "event_addVehicleUpgrade", getRootElement(), addVehicleUpgrade_fun )

function setVehiclePaintjob_fun( vehicleid, value )
	setVehiclePaintjob ( vehicleid, value )
end
addEvent( "event_setVehiclePaintjob", true )
addEventHandler ( "event_setVehiclePaintjob", getRootElement(), setVehiclePaintjob_fun )

function setVehicleColor_fun( vehicleid, r, g, b )
	setVehicleColor( vehicleid, r, g, b, r, g, b, r, g, b, r, g, b )
end
addEvent( "event_setVehicleColor", true )
addEventHandler ( "event_setVehicleColor", getRootElement(), setVehicleColor_fun )

function setVehicleHeadLightColor_fun( vehicleid, r, g, b )
	setVehicleHeadLightColor ( vehicleid, r, g, b )
end
addEvent( "event_setVehicleHeadLightColor", true )
addEventHandler ( "event_setVehicleHeadLightColor", getRootElement(), setVehicleHeadLightColor_fun )
-----------------------------------------------------------------------------------------

local earth = {}--слоты земли
local max_earth = 50

for i=1,max_earth do
	earth[i] = {0,0,0,0,0}
end

function timer_earth()
	for k,playerid in pairs(getElementsByType("player")) do
		for i=1,max_earth do
			triggerClientEvent( playerid, "event_earth_load", playerid, i, earth[i][1], earth[i][2], earth[i][3], earth[i][4], earth[i][5] )
		end
	end
end

function timer_earth_clear()
	for j=1,max_earth do
		earth[j][1] = 0
		earth[j][2] = 0
		earth[j][3] = 0
		earth[j][4] = 0
		earth[j][5] = 0
	end

	for k,playerid in pairs(getElementsByType("player")) do
		sendPlayerMessage(playerid, "[НОВОСТИ] Улицы очищенны от мусора", green[1], green[2], green[3])
	end
end

local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 17

local info_png = {
	[0] = {"", ""},
	[1] = {"деньги", "$"},
	[2] = {"права на имя", ""},
	[3] = {"сигареты Big Break Red", "шт в пачке"},
	[4] = {"аптечка", "шт"},
	[5] = {"канистра с", "галл."},
	[6] = {"ключ от автомобиля с номером", ""},
	[7] = {"сигареты Big Break Blue", "сигарет в пачке"},
	[8] = {"сигареты Big Break White", "сигарет в пачке"},
	[9] = {"граната", "ID"},
	[10] = {"полицейское удостоверение на имя", ""},
	[11] = {"патроны 25 шт для", "ID"},
	[12] = {"colt-45", "ID"},
	[13] = {"deagle", "ID"},
	[14] = {"AK-47", "ID"},
	[15] = {"M4", "ID"},
	[16] = {"tec-9", "ID"},
	[17] = {"MP5", "ID"},
	[18] = {"uzi", "ID"},
	[19] = {"дымовая граната", "ID"},
	[20] = {"наркотики", "гр"},
	[21] = {"пиво старый эмпайр", "шт"},
	[22] = {"пиво штольц", "шт"},
	[23] = {"наручные часы Empire, состояние", "%"},
	[24] = {"ящик, цена продажи", "$"},
	[25] = {"ключ от дома с номером", ""},
	[26] = {"ключ от автомобиля с номером", ""},
	[27] = {"", "одежда"},
	[28] = {"шеврон Офицера", "шт"},
	[29] = {"шеврон Детектива", "шт"},
	[30] = {"шеврон Сержанта", "шт"},
	[31] = {"шеврон Лейтенанта", "шт"},
	[32] = {"шеврон Капитан", "шт"},
	[33] = {"шеврон Шефа полиции", "шт"},
	[34] = {"shotgun", "ID"},
	[35] = {"парашют", "ID"},
	[36] = {"дубинка", "ID"},
	[37] = {"бита", "ID"},
	[38] = {"нож", "ID"},
	[39] = {"бронежилет", "шт"},
}

--инв-рь игрока
local array_player_1 = {}
local array_player_2 = {}

--инв-рь авто
local array_car_1 = {}
local array_car_2 = {}
local fuel = {}

--инв-рь дома
local array_house_1 = {}
local array_house_2 = {}

local state_inv_player = {}--состояние инв-ря 0-выкл, 1-вкл
local state_gui_window = {}--состояние гуи окна 0-выкл, 1-вкл

-----------------------------------------------------------------------------------------
function fuel_down()--система топлива авто
	for k,vehicle in pairs(getElementsByType("vehicle")) do
		local veh = getVehiclePlateText(vehicle)
		local engine = getVehicleEngineState ( vehicle )

		if engine then
			if fuel[veh] <= 0 then
				setVehicleEngineState ( vehicle, false )
			else
				if getSpeed(vehicle) == 0 then
					fuel[veh] = fuel[veh] - 0.001
				elseif getSpeed(vehicle) > 0 and getSpeed(vehicle) <= 100 then
					fuel[veh] = fuel[veh] - 0.01
				elseif getSpeed(vehicle) > 100 and getSpeed(vehicle) <= 150 then
					fuel[veh] = fuel[veh] - 0.02
				elseif getSpeed(vehicle) > 150 and getSpeed(vehicle) <= 200 then
					fuel[veh] = fuel[veh] - 0.03
				elseif getSpeed(vehicle) > 200 and getSpeed(vehicle) <= 250 then
					fuel[veh] = fuel[veh] - 0.04
				elseif getSpeed(vehicle) > 250 and getSpeed(vehicle) <= 300 then
					fuel[veh] = fuel[veh] - 0.05
				end
			end

			for k,playerid in pairs(getElementsByType("player")) do
				local car_player = getPlayerVehicle(playerid)

				if car_player == vehicle then
					triggerClientEvent( playerid, "event_fuel_load", playerid, fuel[veh] )
				end
			end
		end
	end

	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName ( playerid )
		triggerClientEvent( playerid, "event_inv_load", playerid, "player", 0, array_player_1[playername][0+1], array_player_2[playername][0+1] )
	end
end

function search_inv_player( playerid, value1, value2 )--цикл по поиску предмета в инв-ре игрока
	local playername = getPlayerName ( playerid )
	local val = 0

	for i=0,max_inv do
		if array_player_1[playername][i+1] == value1 and array_player_2[playername][i+1] == value2 then
			val = val + 1
		end
	end

	return val
end

function search_inv_car( vehicleid, value1, value2 )--цикл по поиску предмета в инв-ре авто
	local plate = getVehiclePlateText ( vehicleid )
	local val = 0

	for i=0,max_inv do
		if array_car_1[plate][i+1] == value1 and array_car_2[plate][i+1] == value2 then
			val = val + 1
		end
	end

	return val
end

function inv_player_empty(playerid, id1, id2)--выдача предмета игроку
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			inv_server_load( playerid, "player", i, id1, id2 )
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, id1, id2 )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, id1 )
			end

			return true
		end
	end

	return false
end

function inv_car_empty(playerid, id1, id2)--выдача предмета авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	
	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		for i=0,max_inv do
			if array_car_1[plate][i+1] == 0 then
				inv_server_load( playerid, "car", i, id1, id2 )
				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, id1, id2 )

				if state_inv_player[playername] == 1 then
					triggerClientEvent( playerid, "event_change_image", playerid, "car", i, id1 )
				end

				return true
			end
		end

		return false
	end
end
-----------------------------------------------------------------------------------------

function displayLoadedRes ( res )--старт ресурсов
	setTimer(timer_earth, 1000, 0)--передача слотов земли на клиент
	setTimer(timer_earth_clear, 300000, 0)--очистка земли от предметов
	setTimer(fuel_down, 500, 0)--система топлива
end
addEventHandler ( "onResourceStart", getRootElement(), displayLoadedRes )

addEventHandler("onPlayerJoin", getRootElement(),--конект игрока на сервер
function()
	local playerid = source
	local playername = getPlayerName ( playerid )

	array_player_1[playername] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_player_2[playername] = {500,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	local result = sqlite( "SELECT COUNT() FROM inventory WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM inventory WHERE name = '"..playername.."'" )
		for i=0,max_inv do
			array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
			array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
		end
	end

	array_house_1[1] = {2,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_house_2[1] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	state_inv_player[playername] = 0
	state_gui_window[playername] = 0

	----бинд клавиш----
	bindKey(playerid, "tab", "down", tab_down )
	bindKey(playerid, "e", "down", e_down )
	bindKey(playerid, "z", "down", z_down )

	spawnPlayer(playerid, spawnX, spawnY, spawnZ)
	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)

	for _, stat in pairs({ 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
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

------------------------------------взрыв авто-------------------------------------------
function explode_car()
	local vehicleid = source
	local plate = getVehiclePlateText ( vehicleid )

	array_car_1[plate] = nil
	array_car_2[plate] = nil
	fuel[plate] = nil

	destroyElement(vehicleid)
	sendPlayerMessage(getRootElement(), "vehicle delet ["..plate.."]")
end
addEventHandler("onVehicleExplode", getRootElement(), explode_car)

--------------------------------------вход и выход в авто--------------------------------
function enter_car ( vehicle, seat, jacked )--евент входа в авто
	local playerid = source

end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), enter_car )

function exit_car ( vehicle, seat, jacked )--евент выхода из авто
	local playerid = source
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, 0, 0 )

		if state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_change_image", playerid, "car", i, 0)
		end
	end

	triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )
end
addEventHandler ( "onPlayerVehicleExit", getRootElement(), exit_car )
-----------------------------------------------------------------------------------------

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
		if state_gui_window[playername] == 0 then--гуи окно
			if state_inv_player[playername] == 0 then--инв-рь игрока
				for i=0,max_inv do
					triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
				end

				if vehicleid then
					local plate = getVehiclePlateText ( vehicleid )

					if search_inv_player(playerid, 6, plate) ~= 0 or search_inv_player(playerid, 26, plate) ~= 0 then
						for i=0,max_inv do
							triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )
						end
						triggerClientEvent( playerid, "event_tab_load", playerid, "car", plate )
					end
				end

				for i=0,max_inv do
					triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, array_house_1[1][i+1], array_house_2[1][i+1] )
				end
				triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )

				triggerClientEvent( playerid, "event_inv_create", playerid )
				state_inv_player[playername] = 1
			elseif state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_inv_delet", playerid )
				state_inv_player[playername] = 0
			end
		end
	end
end

function throw_earth_server (playerid, value, id3, id1, id2)--выброс предмета
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)

	for i=1,max_earth do
		if earth[i][4] == 0 then

			earth[i][1] = x
			earth[i][2] = y
			earth[i][3] = z
			earth[i][4] = id1
			earth[i][5] = id2

			inv_server_load(playerid, value, id3, 0, 0)

			triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, 0, 0 )
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, 0 )

			sendPlayerMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])
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

				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
			end
		end

		if state_inv_player[playername] == 0 then--инв-рь игрока
			if state_gui_window[playername] == 0 then
				triggerClientEvent( playerid, "event_tune_create", playerid )
				state_gui_window[playername] = 1
			else
				triggerClientEvent( playerid, "event_tune_delet", playerid )
				state_gui_window[playername] = 0
			end
		end
	end
end

function z_down (playerid, key, keyState)--тюнинг окно
local playername = getPlayerName ( playerid )

	if keyState == "down" then
		
	end
end

function inv_server_load (playerid, value, id3, id1, id2 )--изменение инв-ря на сервере
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)

	if value == "player" then
		array_player_1[playername][id3+1] = id1
		array_player_2[playername][id3+1] = id2
		local result = sqlite( "UPDATE inventory SET slot_"..id3.."_1 = '"..array_player_1[playername][id3+1].."', slot_"..id3.."_2 = '"..array_player_2[playername][id3+1].."' WHERE name = '"..playername.."'")
	elseif value == "car" then
		if vehicleid then
			local plate = getVehiclePlateText ( vehicleid )

			array_car_1[plate][id3+1] = id1
			array_car_2[plate][id3+1] = id2
		end
	elseif value == "house" then
		array_house_1[1][id3+1] = id1
		array_house_2[1][id3+1] = id2
	end
end
addEvent( "event_inv_server_load", true )
addEventHandler ( "event_inv_server_load", getRootElement(), inv_server_load )

function use_inv (playerid, value, id3, id_1, id_2 )--использование предметов
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local id1, id2 = id_1, id_2

	if value == "player" then

		if id1 == 6 or id1 == 26 then
			if vehicleid then
				local plate = getVehiclePlateText ( vehicleid )

				if plate == id2 then
					if getVehicleEngineState(vehicleid) then
						setVehicleEngineState(vehicleid, false)
						me_chat(playerid, playername.." заглушил двигатель")
					else
						setVehicleEngineState(vehicleid, true)
						me_chat(playerid, playername.." завел двигатель")
					end
				else
					sendPlayerMessage(playerid, "[ERROR] Этот ключ не подходит", red[1], red[2], red[3] )
				end
				return
			end
		end

		-----------------------------------------------------------------------------------------------------------------------
		if id2 == 0 then
			id1, id2 = 0, 0
		end

		if state_inv_player[playername] == 1 and id2 == 0 then
			triggerClientEvent( playerid, "event_change_image", playerid, "player", id3, id1)
		end

		inv_server_load(playerid, "player", id3, id1, id2)
		triggerClientEvent( playerid, "event_inv_load", playerid, "player", id3, id1, id2 )

	elseif value == "car" then
		if vehicleid then
			
			-----------------------------------------------------------------------------------------------------------------------
			if id2 == 0 then
				id1, id2 = 0, 0
			end

			if state_inv_player[playername] == 1 and id2 == 0 then
				triggerClientEvent( playerid, "event_change_image", playerid, "car", id3, id1)
			end

			inv_server_load(playerid, "car", id3, id1, id2)
			triggerClientEvent( playerid, "event_inv_load", playerid, "car", id3, id1, id2 )
		end
	elseif value == "house" then

		-----------------------------------------------------------------------------------------------------------------------
		if id2 == 0 then
			id1, id2 = 0, 0
		end

		if state_inv_player[playername] == 1 and id2 == 0 then
			triggerClientEvent( playerid, "event_change_image", playerid, "house", id3, id1)
		end

		inv_server_load(playerid, "house", id3, id1, id2)
		triggerClientEvent( playerid, "event_inv_load", playerid, "house", id3, id1, id2 )
	end
end
addEvent( "event_use_inv", true )
addEventHandler ( "event_use_inv", getRootElement(), use_inv )

addCommandHandler ( "sub",--выдача предметов с числом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), tonumber(id2)

	if val1 == nil or val2 == nil then
		return
	end

	if inv_player_empty(playerid, val1, val2) then
		sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "subt",--выдача предметов с текстом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), id2

	if val1 == nil or val2 == nil then
		return
	end

	if inv_player_empty(playerid, val1, val2) then
		sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "v",
function ( playerid, cmd, id )
	local x,y,z = getElementPosition( playerid )
	local vehicleid = createVehicle(tonumber(id), x+5, y, z+2, 0, 0, 0, randomize_number())
	local plate = getVehiclePlateText ( vehicleid )

	array_car_1[plate] = {2,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	fuel[plate] = 50

	local val1, val2 = 6, plate
	if inv_player_empty(playerid, val1, val2) then
		sendPlayerMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
	end

	sendPlayerMessage(playerid, "spawn vehicle "..id.." ["..plate.."] "..getVehicleNameFromModel ( tonumber ( id ) ))
end)

addCommandHandler ( "getupd",
function ( playerid )
	local text = ""
	local vehicleid = getPlayerVehicle(playerid)
	if vehicleid then
		local model = getElementModel ( vehicleid )

		sendPlayerMessage(playerid, "addCommandHandler getupd" )
		sendPlayerMessage(playerid, "model - "..model )

		local upgrades = getVehicleCompatibleUpgrades ( vehicleid )
		for v, upgrade in pairs ( upgrades ) do
			text = text..upgrade..","
		end
		sendPlayerMessage(playerid, text )
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

addCommandHandler ( "go",
function ( playerid, cmd, x, y, z )
	spawnPlayer(playerid, tonumber(x), tonumber(y), tonumber(z))
end)

addCommandHandler("hp",
function (playerid)
	setElementHealth(playerid, 100)
	sendPlayerMessage(playerid, "+100 hp", lyme[1], lyme[2], lyme[3])
end)

function input_Console ( text )
	local x = "1 2 3"
	local number = split(x, " ")
	if text == "z" then
		print(number[4])
	elseif text == "x" then
		
	end
end
addEventHandler ( "onConsole", getRootElement(), input_Console )