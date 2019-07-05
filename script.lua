local database = dbConnect( "sqlite", "ebmp-rpg.db" )
function sqlite(text)
	local result = dbQuery( database, text )
	local result = dbPoll( result, -1 )

	if string.find(text, "UPDATE") or string.find(text, "INSERT") or string.find(text, "DELETE") then
		local time = getRealTime()
		local hour = time["hour"]
		local minute = time["minute"]
		local second = time["second"]

		if time["hour"] < 10 then
			hour = "0"..hour
		end

		if time["minute"] < 10 then
			minute = "0"..minute
		end

		if time["second"] < 10 then
			second = "0"..second
		end

		local client_time = "[Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..hour..":"..minute..":"..second.."] "
		local hFile = fileOpen(":ebmp/save_sqlite.sql")
		fileSetPos( hFile, fileGetSize( hFile ) )
		fileWrite(hFile, client_time..text.."\n" )
		fileClose(hFile)
	end

	return result
end
addEvent("event_sqlite", true)
addEventHandler("event_sqlite", getRootElement(), sqlite)

addEvent( "event_destroyElement", true )
addEventHandler ( "event_destroyElement", getRootElement(), destroyElement )

addEvent( "event_removePedFromVehicle", true )
addEventHandler ( "event_removePedFromVehicle", getRootElement(), removePedFromVehicle )

addEvent( "event_setElementDimension", true )
addEventHandler ( "event_setElementDimension", getRootElement(), setElementDimension )

local upgrades_car_table = {}
local uc_txt = fileOpen(":ebmp/upgrade/upgrades_car.txt")
for k,v in pairs(split(fileRead ( uc_txt, fileGetSize( uc_txt ) ), "|")) do
	local spl = split(v, ",")
	upgrades_car_table[tonumber(spl[1])] = spl[3]
end
fileClose(uc_txt)

local earth = {}--слоты земли
local earth_true = true--очищать ли землю
local max_earth = 0--мак-ое кол-во выброшенных предметов на землю
local count_player = 0--кол-во подключенных игроков
local me_radius = 10--радиус отображения действий игрока в чате
local max_inv = 23--слоты инв-ря
local max_fuel = 50--объем бака авто
local car_spawn_value = 0--чтобы ресурсы не запускались два раза
local max_blip = 250--радиус блипов
local house_bussiness_radius = 5--радиус размещения бизнесов и домов
local tomorrow_weather = 0--погода
local spawnX, spawnY, spawnZ = 1672.5390625,1447.8193359375,10.788088798523--стартовая позиция
local max_heal = 200--макс здоровье игрока
local house_icon = 1273--пикап дома
local business_icon = 1274--пикап бизнеса
local job_icon = 1318--пикап работ
local time_nalog = 12--время когда будет взиматься налог
local price_hotel = 100--цена в отеле
local crimes_giuseppe = 25--//прес-ия для джузеппе
local crimes_capture = crimes_giuseppe*2--прес-ия для захвата
local car_theft_time = 10--время для угона
local day_nalog = 7--кол-во дней для оплаты налога
local business_pos = {}--позиции бизнесов
local house_pos = {}--позиции домов
local police_chanel = 1--канал копов
local admin_chanel = 2--канал админов
local car_stage_coef = 0.33--коэф-нт прокачки двигла
local ferm_etap = 1--этап фермы, всего 3
local grass_pos_count = 0--кол-во растений на ферме
local ferm_etap_count = 255--кол-во этапов за раз
local no_ped_damage = {--таблица нпс по которым не будет проходить дамаг
	[1] = 2,--кол-во нпс добавленных в таблицу
	[2] = {
			[1] = createPed ( 312, 2435.337890625,-2704.7568359375,3, 180.0, true ),
			[2] = createPed ( 312, -1632.9775390625,-2239.0263671875,31.4765625, 90.0, true ),
			}--таблица нпс
}

--законы
local zakon_alcohol = 1
local zakon_alcohol_crimes = 1
local zakon_drugs = 10
local zakon_drugs_crimes = 1
local zakon_kill_crimes = 1
local zakon_robbery_crimes = 1
local zakon_65_crimes = 1
local zakon_66_crimes = 1
local zakon_car_theft_crimes = 1
local zakon_nalog_car = 500
local zakon_nalog_house = 1000
local zakon_nalog_business = 2000
local zakon_price_house = 300000
local zakon_price_business = 300000
--зп
local zp_player_taxi = 2500
local zp_player_plane = 2000
local zp_player_sas = 200
local zp_player_medic = 5000
local zp_player_fire = 5000
local zp_player_police = 5000
local zp_player_busdriver = 12000
local money_guns_zone = 5000
local money_guns_zone_business = 1000
local zp_player_ferm = 100
local zp_player_ferm_etap = 10000
local zp_player_bamby = 5000
local zp_player_box = 5000
--вместимость складов бизнесов
local max_business = 100
local max_cf = 1000

----цвета----
local color_tips = {168,228,160}--бабушкины яблоки
local yellow = {255,255,0}--желтый
local red = {255,0,0}--красный
local red_try = {200,0,0}--красный
local blue = {0,150,255}--синий
local white = {255,255,255}--белый
local green = {0,255,0}--зеленый
local green_try = {0,200,0}--зеленый
local turquoise = {0,255,255}--бирюзовый
local orange = {255,100,0}--оранжевый
local orange_do = {255,150,0}--оранжевый do
local pink = {255,100,255}--розовый
local lyme = {130,255,0}--лайм админский цвет
local svetlo_zolotoy = {255,255,130}--светло-золотой
local crimson = {220,20,60}--малиновый
local purple = {175,0,255}--фиолетовый
local gray = {150,150,150}--серый
local green_rc = {115,180,97}--темно зеленый

--капты-----------------------------------------------------------------------------------------------------------
local point_guns_zone = {0,0, 0,0, 0,0}--1-идет ли захват, 2-номер зоны, 3-атакующие, 4-очки захвата, 5-защищающие, 6-очки захвата
local time_gz = 1*60
local time_guns_zone = time_gz
local name_mafia = {
	[0] = {"no", {255,255,255}},
	[1] = {"Grove Street Familes", {0,255,0}},
	[2] = {"Vagos", {255,255,0}},
	[3] = {"Ballas", {175,0,255}},
	[4] = {"Rifa", {0,0,255}},
	[5] = {"Varrios Los Aztecas", {0,255,255}},
	[6] = {"Triads", {50,50,50}},
	[7] = {"Da Nang Boys", {255,0,0}},
}
local guns_zone = {}
------------------------------------------------------------------------------------------------------------------

-------------------пользовательские функции----------------------------------------------
function sendMessage(playerid, text, color)
	local time = getRealTime()
	local hour = time["hour"]
	local minute = time["minute"]
	local second = time["second"]

	if time["hour"] < 10 then
		hour = "0"..hour
	end

	if time["minute"] < 10 then
		minute = "0"..minute
	end

	if time["second"] < 10 then
		second = "0"..second
	end

	outputChatBox("["..hour..":"..minute..":"..second.."] "..text, playerid, color[1], color[2], color[3])
end

function earth_true(playerid)
	local playername = getPlayerName(playerid)
	earth_true = not earth_true
	admin_chat(playerid, "[ADMIN] "..playername.." ["..getElementData(playerid, "player_id")[1].."] использовал function earth_true(playerid) return "..tostring(earth_true).." end")
end
addEvent( "event_earth_true", true )
addEventHandler ( "event_earth_true", getRootElement(), earth_true )

function player_position( playerid )
	local x,y,z = getElementPosition(playerid)
	local x_table = split(x, ".")
	local y_table = split(y, ".")

	return x_table[1],y_table[1]
end

local car_shtraf_stoyanka = createColRectangle( 2054.1,2367.5, 62, 70 )
local ls_airport = createColRectangle( 1364.041015625,-2766.3720703125, 789, 581 )
local lv_airport = createColRectangle( 1258.2685546875,1143.7607421875, 473, 719 )
local sf_airport = createColRectangle( -1734.609375,-695.794921875, 680, 1156 )
function isPointInCircle3D(x, y, z, x1, y1, z1, radius)
	if getDistanceBetweenPoints3D(x, y, z, x1, y1, z1) <= radius then
		return true
	else
		return false
	end
end

function isPointInCircle2D(x, y, x1, y1, radius)
	if getDistanceBetweenPoints2D(x, y, x1, y1) <= radius then
		return true
	else
		return false
	end
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

function getVehicleNameFromPlate( number )
	local number = tostring(number)

	for i,vehicleid in pairs(getElementsByType("vehicle")) do
		local plate = getVehiclePlateText(vehicleid)
		if number == plate then
			return getVehicleNameFromModel(getElementModel(vehicleid))
		end
	end
end

function getVehicleidFromPlate( number )
	local number = tostring(number)

	for i,vehicleid in pairs(getElementsByType("vehicle")) do
		local plate = getVehiclePlateText(vehicleid)
		if number == plate then
			return vehicleid
		end
	end
end

math.randomseed(getTickCount())
function random(min, max)
	return math.random(min, max)
end

function me_chat(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendMessage(player, text, pink)
		end
	end
end

function me_chat_player(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendMessage(player, "[ME] "..text, pink)
		end
	end
end

function do_chat(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendMessage(player, text, orange_do)
		end
	end
end

function do_chat_player(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendMessage(player, "[DO] "..text, orange_do)
		end
	end
end

function b_chat_player(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendMessage(player, text, gray)
		end
	end
end

function try_chat_player(playerid, text)
	local x,y,z = getElementPosition(playerid)
	local randomize = random(0,1)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			if randomize == 1 then
				sendMessage(player, "[TRY] "..text.." [УДАЧНО]", green_try)
			else
				sendMessage(player, "[TRY] "..text.." [НЕУДАЧНО]", red_try)
			end
		end
	end

	if randomize == 1 then
		return true
	else
		return false
	end
end

function ic_chat(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendMessage(player, text, white)
		end
	end
end

function admin_chat(playerid, text)
	for k,player in pairs(getElementsByType("player")) do
		local playername = getPlayerName(player)

		if search_inv_player_2_parameter(player, 44) ~= 0 and search_inv_player(player, 80, admin_chanel) ~= 0 then
			sendMessage(player, text, lyme)
		end
	end
end
addEvent("event_admin_chat", true)
addEventHandler("event_admin_chat", getRootElement(), admin_chat)

function police_chat(playerid, text)
	for k,player in pairs(getElementsByType("player")) do
		local playername = getPlayerName(player)

		if search_inv_player_2_parameter(player, 10) ~= 0 and search_inv_player(player, 80, police_chanel) ~= 0 then
			sendMessage(player, text, blue)
		end
	end
end

function radio_chat(playerid, text, color)
	for k,player in pairs(getElementsByType("player")) do
		local playername = getPlayerName(player)

		if search_inv_player(player, 80, search_inv_player_2_parameter(playerid, 80)) ~= 0 then
			sendMessage(player, text, color[1], color[2], color[3])
		end
	end
end

function set_weather()
	local hour, minute = getTime()

	if hour == 0 and minute == 0 then
		setWeatherBlended(tomorrow_weather)

		tomorrow_weather = random(0,22)
		print("[tomorrow_weather] "..tomorrow_weather)

		timer_earth_clear()--очистка земли от предметов
	end
end

--[[Bone IDs:
1: глава
2: шея
3: позвоночник
4: таз
5: левой ключицы
6: правой ключице
7: левое плечо
8: правое плечо
9: левым локтем
10: правым локтем
11: левой рукой
12: правой рукой
13: левое бедро
14: правое бедро
15: левое колено
16: правое колено
17: левой лодыжке
18: правую лодыжку
19: левая нога
20: правая нога]]
function object_attach( playerid, model, bone, x,y,z, rx,ry,rz, time )--прикрепление объектов к игроку
	local x1, y1, z1 = getElementPosition (playerid)
	local objPick = createObject (model, x1, y1, z1)

	attachElementToBone (objPick, playerid, bone, x,y,z, rx,ry,rz)

	setTimer(function ()
		detachElementFromBone(objPick)
		destroyElement(objPick)
	end, time, 1)

	return objPick
end

--[[function string.split(input, separator)
	
	if type(input) ~= "string" then error("type mismatch in argument #1", 3) end
	if (separator and type(separator) ~= "string") then error("type mismatch in argument #2", 3) end

	if not separator then
		separator = "%s"
	end
	local t = {}
	local i = 1
	for str in string.gmatch(input, "([^"..separator.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end]]

function add_ped_in_no_ped_damage(ped)--добавление нпс
	no_ped_damage[1] = no_ped_damage[1]+1
	no_ped_damage[2][no_ped_damage[1]] = ped
end

function delet_ped_in_no_ped_damage(ped)--удаление нпс
	for k,v in pairs(no_ped_damage[2]) do
		if v == ped then
			no_ped_damage[2][k] = nil
			break
		end
	end
end
-----------------------------------------------------------------------------------------

local info_png = {
	[0] = {"", ""},
	[1] = {"чековая книжка", "$ в банке"},
	[2] = {"права", "шт"},
	[3] = {"сигареты Big Break Red", "сигарет"},
	[4] = {"аптечка", "шт"},
	[5] = {"канистра с", "лит."},
	[6] = {"ключ от автомобиля с номером", ""},
	[7] = {"сигареты Big Break Blue", "сигарет"},
	[8] = {"сигареты Big Break White", "сигарет"},
	[9] = {"Граната", "боеприпасов"},
	[10] = {"полицейский жетон", "ранг"},
	[11] = {"планшет", "шт"},
	[12] = {"Кольт-45", "боеприпасов"},
	[13] = {"Дигл", "боеприпасов"},
	[14] = {"AK-47", "боеприпасов"},
	[15] = {"M4", "боеприпасов"},
	[16] = {"уголь", "кг"},
	[17] = {"МП5", "боеприпасов"},
	[18] = {"Узи", "боеприпасов"},
	[19] = {"Слезоточивый газ", "боеприпасов"},
	[20] = {"наркотики", "гр"},
	[21] = {"пиво старый эмпайр", "шт"},
	[22] = {"пиво штольц", "шт"},
	[23] = {"ремонтный набор", "шт"},
	[24] = {"ящик с товаром", "$ за штуку"},
	[25] = {"ключ от дома с номером", ""},
	[26] = {"Кольт-45 с глушителем", "боеприпасов"},
	[27] = {"одежда", ""},
	[28] = {"тушка оленя", "$ за штуку"},
	[29] = {"охотничий рожок", "%"},
	[30] = {"нож мясника", "шт"},
	[31] = {"пицца", "$ за штуку"},
	[32] = {"потерянный груз", "$ за штуку"},
	[33] = {"сонар", "%"},
	[34] = {"Дробовик", "боеприпасов"},
	[35] = {"парашют", "шт"},
	[36] = {"дубинка", "шт"},
	[37] = {"бита", "шт"},
	[38] = {"нож", "шт"},
	[39] = {"бронежилет", "шт"},
	[40] = {"лом", "%"},
	[41] = {"Винтовка", "боеприпасов"},
	[42] = {"таблетки от наркозависимости", "шт"},
	[43] = {"документы на бизнес под номером", ""},
	[44] = {"админский жетон", "ранг"},
	[45] = {"риэлторская лицензия", "шт"},
	[46] = {"радар", "шт"},
	[47] = {"перцовый балончик", "мл"},
	[48] = {"мясо", "$ за штуку"},
	[49] = {"лопата", "шт"},
	[50] = {"лицензия на оружие", "шт"},
	[51] = {"jetpack", "шт"},
	[52] = {"кислородный балон на 5 мин", "шт"},
	[53] = {"бургер", "шт"},
	[54] = {"пицца", "шт"},
	[55] = {"мыло", "%"},
	[56] = {"пижама", "%"},
	[57] = {"алкотестер", "шт"},
	[58] = {"наркотестер", "шт"},
	[59] = {"квитанция для оплаты дома на", "дней"},
	[60] = {"квитанция для оплаты бизнеса на", "дней"},
	[61] = {"квитанция для оплаты т/с на", "дней"},
	[62] = {"коробка с продуктами", "$ за штуку"},
	[63] = {"GPS навигатор", "шт"},
	[64] = {"лицензия на работу", "вид работы"},
	[65] = {"инкассаторская сумка", "$ в сумке"},
	[66] = {"ящик с оружием", "$ за штуку"},
	[67] = {"бензопила", "шт"},
	[68] = {"дрова", "кг"},
	[69] = {"пустая коробка", "шт"},
	[70] = {"кирка", "шт"},
	[71] = {"железная руда", "кг"},
	[72] = {"виски", "шт"},
	[73] = {"бочка с нефтью", "$ за штуку"},
	[74] = {"#1 маршрутный лист", "ост."},
	[75] = {"мусор", "кг"},
	[76] = {"антипохмелин", "шт"},
	[77] = {"проездной билет", "шт"},
	[78] = {"рыба", "кг"},
	[79] = {"банковский чек на", "$"},
	[80] = {"рация", "канал"},
	[81] = {"динамит", "шт"},
	[82] = {"шнур", "шт"},
	[83] = {"тратил", "гр"},
	[84] = {"отмычка", "процентов"},
	[85] = {"повязка", "опг"},
	[86] = {"документы на скотобойню под номером", ""},
	[87] = {"трудовой договор забойщика скота на", "скотобойне"},
	[88] = {"тушка коровы", "$ за штуку"},
	[89] = {"мешок с кормом", "$ за штуку"},
	[90] = {"колба", "реагент"},
	[91] = {"ордер на обыск", "", "гражданина", "т/с", "дома"},
	[92] = {"наручники", "шт"},
}

local craft_table = {--[предмет 1, рецепт 2, предметы для крафта 3, кол-во предметов для крафта 4, предмет который скрафтится 5]
	{info_png[81][1].." 1 "..info_png[81][2].." ", info_png[82][1].." 1 "..info_png[82][2].." + "..info_png[83][1].." 100 "..info_png[83][2], "82,83", "1,100", "81,1"},
	{info_png[20][1].." 1 "..info_png[20][2].." ", info_png[90][1].." 3 "..info_png[90][2].." + "..info_png[90][1].." 78 "..info_png[90][2], "90,90", "3,78", "20,1"},
}

local quest_table = {--1 название, 2 описание, 3 кол-во, 5 предмет засчитывания, 6 награда $, 7 награда предметом, 8 массив имен кто выполнил квест
	[1] = {"Мясник", "Обработать ", math.random(1,5), " кусков мяса", 48, math.random(1000,5000), {79,10000}, {}},
	[2] = {"Рудокоп", "Добыть ", math.random(1,5), " кг железной руды", 71, math.random(1000,5000), {0,0}, {}},
}

local weapon = {
	[9] = {info_png[9][1], 16, 360, 5},
	[12] = {info_png[12][1], 22, 240, 25},
	[13] = {info_png[13][1], 24, 1440, 25},
	[14] = {info_png[14][1], 30, 4200, 25},
	[15] = {info_png[15][1], 31, 5400, 25},
	[17] = {info_png[17][1], 29, 2400, 25},
	[18] = {info_png[18][1], 28, 600, 25},
	[19] = {info_png[19][1], 17, 360, 5},
	[26] = {info_png[26][1], 23, 720, 25},
	[34] = {info_png[34][1], 25, 720, 25},
	[35] = {info_png[35][1], 46, 200, 1},
	[36] = {info_png[36][1], 3, 150, 1},
	[37] = {info_png[37][1], 5, 150, 1},
	[38] = {info_png[38][1], 4, 150, 1},
	[41] = {info_png[41][1], 33, 6000, 25},
	[47] = {info_png[47][1], 41, 50, 25},
	[49] = {info_png[49][1], 6, 50, 1},
}

local shop = {
	[3] = {info_png[3][1], 20, 5},
	[4] = {info_png[4][1], 1, 250},
	[7] = {info_png[7][1], 20, 10},
	[8] = {info_png[8][1], 20, 15},
	[11] = {info_png[11][1], 1, 100},
	[21] = {info_png[21][1], 1, 45},
	[22] = {info_png[22][1], 1, 60},
	[23] = {info_png[23][1], 1, 100},
	[29] = {info_png[29][1], 100, 500},
	[33] = {info_png[33][1], 100, 500},
	[40] = {info_png[40][1], 10, 500},
	[42] = {info_png[42][1], 1, 5000},
	[46] = {info_png[46][1], 1, 100},
	[47] = {info_png[47][1], 500, 50},
	[52] = {info_png[52][1], 1, 1000},
	[53] = {info_png[53][1], 1, 100},
	[54] = {info_png[54][1], 1, 50},
	[55] = {info_png[55][1], 100, 50},
	[56] = {info_png[56][1], 100, 100},
	[63] = {info_png[63][1], 1, 100},
	[72] = {info_png[72][1], 1, 500},
	[76] = {info_png[76][1], 1, 250},
	[80] = {info_png[80][1], 10, 500},
}

local gas = {
	[5] = {info_png[5][1].." 25 "..info_png[5][2], 25, 250},
}

local giuseppe = {
	{info_png[64][1].." Угонщик", 6, 5000, 64},
	{info_png[83][1], 100, 1000, 83},
	{info_png[84][1], 10, 500, 84},
	{info_png[85][1].." "..name_mafia[1][1], 1, 5000, 85},
	{info_png[85][1].." "..name_mafia[2][1], 2, 5000, 85},
	{info_png[85][1].." "..name_mafia[3][1], 3, 5000, 85},
	{info_png[85][1].." "..name_mafia[4][1], 4, 5000, 85},
	{info_png[85][1].." "..name_mafia[5][1], 5, 5000, 85},
	{info_png[85][1].." "..name_mafia[6][1], 6, 5000, 85},
	{info_png[85][1].." "..name_mafia[7][1], 7, 5000, 85},
	{info_png[90][1].." 78 "..info_png[90][2], 78, 1000, 90},
}

local mayoralty_shop = {
	{info_png[2][1], 1, 1000, 2},
	{info_png[50][1], 1, 10000, 50},
	{info_png[64][1].." Таксист", 1, 5000, 64},
	{info_png[64][1].." Мусоровозчик", 2, 5000, 64},
	{info_png[64][1].." Инкассатор", 3, 5000, 64},
	{info_png[64][1].." Рыболов", 4, 5000, 64},
	{info_png[64][1].." Пилот", 5, 5000, 64},
	{info_png[64][1].." Дальнобойщик", 7, 5000, 64},
	{info_png[64][1].." Перевозчик оружия", 8, 5000, 64},
	{info_png[64][1].." Водитель автобуса", 9, 5000, 64},
	{info_png[64][1].." Парамедик", 10, 5000, 64},
	{info_png[64][1].." Уборщик улиц", 11, 5000, 64},
	{info_png[64][1].." Пожарный", 12, 5000, 64},
	{info_png[64][1].." SWAT", 13, 5000, 64},
	{info_png[64][1].." Фермер", 14, 5000, 64},
	{info_png[64][1].." Охотник", 15, 5000, 64},
	{info_png[64][1].." Развозчик пиццы", 16, 5000, 64},
	{info_png[64][1].." Уборщик морского дна", 17, 5000, 64},
	{info_png[77][1], 100, 100, 77},

	{"квитанция для оплаты дома на "..day_nalog.." дней", day_nalog, (zakon_nalog_house*day_nalog), 59},
	{"квитанция для оплаты бизнеса на "..day_nalog.." дней", day_nalog, (zakon_nalog_business*day_nalog), 60},
	{"квитанция для оплаты т/с на "..day_nalog.." дней", day_nalog, (zakon_nalog_car*day_nalog), 61},
}

local weapon_cops = {
	[9] = {info_png[9][1], 16, 360, 5},
	[12] = {info_png[12][1], 22, 240, 25},
	[15] = {info_png[15][1], 31, 5400, 25},
	[17] = {info_png[17][1], 29, 2400, 25},
	[19] = {info_png[19][1], 17, 360, 5},
	[34] = {info_png[34][1], 25, 720, 25},
	[36] = {info_png[36][1], 3, 150, 1},
	[41] = {info_png[41][1], 34, 6000, 25},
	[47] = {info_png[47][1], 41, 50, 25},
	[39] = {info_png[39][1], 39, 50, 1},
}

local sub_cops = {
	{info_png[10][1].." Офицера", 1, 10},
	{info_png[10][1].." Детектива", 2, 10},
	{info_png[10][1].." Сержанта", 3, 10},
	{info_png[10][1].." Лейтенанта", 4, 10},
	{info_png[10][1].." Капитана", 5, 10},
	{info_png[57][1], 1, 57},
	{info_png[58][1], 1, 58},
}

local deathReasons = {
	[19] = "Rocket",
	[37] = "Burnt",
	[49] = "Rammed",
	[50] = "Ranover/Helicopter Blades",
	[51] = "Explosion",
	[52] = "Driveby",
	[53] = "Drowned",
	[54] = "Fall",
	[55] = "Unknown",
	[56] = "Melee",
	[57] = "Weapon",
	[59] = "Tank Grenade",
	[63] = "Blown"
}

local interior = {
	{1, "Ammu-nation 1",	285.7870,	-41.7190,	1001.5160},
	{1, "Burglary House 1",	224.6351,	1289.012,	1082.141},
	{1, "Caligulas Casino",	2235.2524,	1708.5146,	1010.6129},
	{1, "Denise's Place",	244.0892,	304.8456,	999.1484},--комната со срачем
	{1, "Shamal cabin",	1.6127,	34.7411,	1199.0},
	{1, "Safe House 4",	2216.5400,	-1076.2900,	1050.4840},--комната в отеле
	{1, "Sindacco Abatoir",	963.6078,	2108.3970,	1011.0300},--мясокомбинат
	{1, "Sub Urban",	203.8173,	-46.5385,	1001.8050},--магаз одежды
	{1, "Wu Zi Mu's Betting place",	-2159.9260,	641.4587,	1052.3820},--9 бук-ая контора с комнатой

	{2, "Ryder's House",	2464.2110,	-1697.9520,	1013.5080},
	{2, "The Pig Pen",	1213.4330,	-6.6830,	1000.9220},--стриптиз бар
	{2, "Big Smoke's Crack Palace",	2570.33,	-1302.31,	1044.12},--хата биг смоука
	{2, "Burglary House 2",	225.756,	1240.000,	1082.149},
	{2, "Burglary House 3",	447.470,	1398.348,	1084.305},
	{2, "Burglary House 4",	491.740,	1400.541,	1080.265},
	{2, "Katie's Place	", 267.2290,	304.7100,	999.1480},--16 комната

	{3, "Jizzy's Pleasure Domes",	-2636.7190,	1402.9170,	906.4609},--стриптиз бар
	{3, "Bike School",	1494.3350,	1305.6510,	1093.2890},
	{3, "Big Spread Ranch",	1210.2570,	-29.2986,	1000.8790},--стриптиз бар
	{3, "LV Tattoo Parlour",	-204.4390,	-43.6520,	1002.2990},
	{3, "LVPD HQ",	289.7703,	171.7460,	1007.1790},
	{3, "Pro-Laps",	207.3560,	-138.0029,	1003.3130},--магаз одежды
	{3, "Las Venturas Planning Dep.",	374.6708,	173.8050,	1008.3893},--мэрия
	{3, "Driving School",	-2027.9200,	-105.1830,	1035.1720},
	{3, "Johnson House",	2496.0500,	-1693.9260,	1014.7420},
	{3, "Burglary House 5",	234.733,	1190.391,	1080.258},
	{3, "Gay Gordo's Barbershop",	418.6530,	-82.6390,	1001.8050},--парик-ая
	{3, "Helena's Place",	292.4459,	308.7790,	999.1484},--амбар
	{3, "Inside Track Betting",	826.8863,	5.5091,	1004.4830},--букм-ая контора 2
	{3, "Sex Shop",	-106.7268,	-19.6444,	1000.7190},--30

	{4, "24/7 shop 1",	-27.3769,	-27.6416,	1003.5570},
	{4, "Ammu-Nation 2",	285.8000,	-84.5470,	1001.5390},
	{4, "Burglary House 6",	-262.91,	1454.966,	1084.367},
	{4, "Burglary House 7",	221.4296,	1142.423,	1082.609},
	{4, "Burglary House 8",	261.1168,	1286.519,	1080.258},
	{4, "Diner 2",	460.0,	-88.43,	999.62},
	{4, "Dirtbike Stadium",	-1435.8690,	-662.2505,	1052.4650},
	{4, "Michelle's Place",	302.6404,	304.8048,	999.1484},--38 странная хата, на одном сервере это пж-ая часть)

	{5, "Madd Dogg's Mansion",	1298.9116,	-795.9028,	1084.5097},--огромный особняк
	{5, "Well Stacked Pizza Co.",	377.7758,	-126.2766,	1001.4920},
	{5, "Victim",	225.3310,	-8.6169,	1002.1977},--магаз одежды
	{5, "Burglary House 9",	22.79996,	1404.642,	1084.43},
	{5, "Burglary House 10",	228.9003,	1114.477,	1080.992},
	{5, "Burglary House 11",	140.5631,	1369.051,	1083.864},
	{5, "The Crack Den",	322.1117,	1119.3270,	1083.8830},--наркопритон
	{5, "Police Station (Barbara's)",	322.72,	306.43,	999.15},
	{5, "Ganton Gym",	768.0793,	5.8606,	1000.7160},--тренажорка
	{5, "Vank Hoff Hotel",	2232.8210,	-1110.0180,	1050.8830},--48 комната в отеле

	{6, "Ammu-Nation 3",	297.4460,	-109.9680,	1001.5160},
	{6, "Ammu-Nation 4",	317.2380,	-168.0520,	999.5930},--инт для военного склада
	{6, "LSPD HQ",	246.4510,	65.5860,	1003.6410},
	{6, "Safe House 3",	2333.0330,	-1073.9600,	1049.0230},
	{6, "Safe House 5",	2194.2910,	-1204.0150,	1049.0230},
	{6, "Safe House 6",	2308.8710,	-1210.7170,	1049.0230},
	{6, "Cobra Marital Arts Gym",	774.0870,	-47.9830,	1000.5860},--тренажорка
	{6, "24/7 shop 2",	-26.7180,	-55.9860,	1003.5470},--буду юзать это инт
	{6, "Millie's Bedroom",	344.5200,	304.8210,	999.1480},--плохая комната)
	{6, "Fanny Batter's Brothel",	744.2710,	1437.2530,	1102.7030},
	{6, "Burglary House 15",	234.319,	1066.455,	1084.208},
	{6, "Burglary House 16",	-69.049,	1354.056,	1080.211},--60

	{7, "Ammu-Nation 5 (2 Floors)",	315.3850,	-142.2420,	999.6010},
	{7, "8-Track Stadium", -1417.8720,	-276.4260,	1051.1910},
	{7, "Below the Belt Gym",	774.2430,	-76.0090,	1000.6540},--63 тренажорка

	{8, "Colonel Fuhrberger's House",	2807.8990,	-1172.9210,	1025.5700},--дом с пушкой
	{8, "Burglary House 22",	-42.490,	1407.644,	1084.43},--65

	{9, "Burglary House 12",	85.32596,	1323.585,	1083.859},
	{9, "Burglary House 13",	260.3189,	1239.663,	1084.258},
	{9, "Cluckin' Bell",	365.67,	-11.61,	1001.87},--68

	{10, "Four Dragons Casino",	2009.4140,	1017.8990,	994.4680},
	{10, "RC Zero's Battlefield",	-975.5766,	1061.1312,	1345.6719},
	{10, "Burger Shot",	366.4220,	-73.4700,	1001.5080},
	{10, "Burglary House 14",	21.241,	1342.153,	1084.375},
	{10, "Hashbury safe house",	2264.5231,	-1210.5229,	1049.0234},
	{10, "24/7 shop 3",	6.0780,	-28.6330,	1003.5490},
	{10, "Abandoned AC Tower",	419.6140,	2536.6030,	10.0000},
	{10, "SFPD HQ",	246.4410,	112.1640,	1003.2190},--76

	{11, "Ten Green Bottles Bar",	502.3310,	-70.6820,	998.7570},--77

	{12, "The Casino", 1132.9450,	-8.6750,	1000.6800},
	{12, "Macisla's Barbershop",	411.6410,	-51.8460,	1001.8980},--парик-ая
	{12, "Modern safe house",	2324.4990,	-1147.0710,	1050.7100},--80

	{14, "Kickstart Stadium",	-1464.5360,	1557.6900,	1052.5310},
	{14, "Didier Sachs",	204.1789,	-165.8740,	1000.5230},--82 --магаз одежды

	{15, "Binco",	207.5430,	-109.0040,	1005.1330},--магаз одежды
	{15, "Blood Bowl Stadium",	-1394.20,	987.62,	1023.96},--дерби арена
	{15, "Jefferson Motel",	2217.6250,	-1150.6580,	1025.7970},
	{15, "Burglary House 18",	327.808,	1479.74,	1084.438},
	{15, "Burglary House 19",	375.572,	1417.439,	1081.328},
	{15, "Burglary House 20",	384.644,	1471.479,	1080.195},
	{15, "Burglary House 21",	295.467,	1474.697,	1080.258},--89

	{16, "24/7 shop 4",	-25.3730,	-139.6540,	1003.5470},
	{16, "LS Tattoo Parlour",	-204.5580,	-25.6970,	1002.2730},
	{16, "Sumoring? stadium",	-1400,	1250,	1040},--92

	{17, "24/7 shop 5",	-25.3930,	-185.9110,	1003.5470},
	{17, "Club",	493.4687,	-23.0080,	1000.6796},
	{17, "Rusty Brown's - Ring Donuts",	377.0030,	-192.5070,	1000.6330},--кафешка
	{17, "The Sherman's Dam Generator Hall",	-942.1320,	1849.1420,	5.0050},--96 дамба

	{18, "Lil Probe Inn",	-227.0280,	1401.2290,	27.7690},--бар
	{18, "24/7 shop 6",	-30.9460,	-89.6090,	1003.5490},
	{18, "Atrium",	1726.1370,	-1645.2300,	20.2260},--отель
	{18, "Warehouse 2",	1296.6310,	0.5920,	1001.0230},
	{18, "Zip",	161.4620,	-91.3940,	1001.8050},--101 магаз одежды
}

local cash_car = {
	[400] = {"LANDSTAL", 25000},
	[401] = {"BRAVURA", 9000},
	[402] = {"BUFFALO", 35000},
	[403] = {"LINERUN", 35000},
	[404] = {"PEREN", 10000},
	[405] = {"SENTINEL", 35000},
	--[406] = {"DUMPER", 50000},--самосвал
	[407] = {"FIRETRUK", 45000},
	[408] = {"TRASH", 35000},--мусоровоз
	[409] = {"STRETCH", 40000},--лимузин
	[410] = {"MANANA", 9000},
	[411] = {"INFERNUS", 95000},
	[412] = {"VOODOO", 30000},
	[413] = {"PONY", 20000},--грузовик с колонками
	--[414] = {"MULE", 22000},--грузовик развозчика
	[415] = {"CHEETAH", 105000},
	[416] = {"AMBULAN", 30000},--скорая
	[418] = {"MOONBEAM", 16000},
	[419] = {"ESPERANT", 19000},
	[420] = {"TAXI", 20000},
	[421] = {"WASHING", 18000},
	[422] = {"BOBCAT", 26000},
	--[423] = {"MRWHOOP", 29000},--грузовик мороженого
	[424] = {"BFINJECT", 15000},
	[426] = {"PREMIER", 25000},
	[428] = {"SECURICA", 40000},--инкассаторский грузовик
	[429] = {"BANSHEE", 45000},
	--[431] = {"BUS", 15000},
	--[432] = {"RHINO", 110000},--танк
	--[433] = {"BARRACKS", 10000},--военный грузовик
	[434] = {"HOTKNIFE", 35000},
	[436] = {"PREVION", 9000},
	[437] = {"COACH", 20000},--автобус
	--[438] = {"CABBIE", 10000},--такси
	[439] = {"STALLION", 19000},
	[440] = {"RUMPO", 26000},--грузовик развозчика в сампрп
	--[442] = {"ROMERO", 10000},--гробовозка
	--[443] = {"PACKER", 20000},--фура с траплином
	[444] = {"MONSTER", 40000},
	[445] = {"ADMIRAL", 35000},
	[451] = {"TURISMO", 95000},
	[455] = {"FLATBED", 10000},--пустой грузовик
	[456] = {"YANKEE", 22000},--грузовик
	--[457] = {"CADDY", 9000},--гольфкар
	[458] = {"SOLAIR", 18000},
	[459] = {"TOPFUN", 20000},--грузовик с игру-ми машинами
	[466] = {"GLENDALE", 20000},
	[467] = {"OCEANIC", 20000},
	--[470] = {"PATRIOT", 40000},--военный хамер
	[471] = {"QUADBIKE", 9000},--квадроцикл
	[474] = {"HERMES", 19000},
	[475] = {"SABRE", 19000},
	[477] = {"ZR350", 45000},
	[478] = {"WALTON", 26000},
	[479] = {"REGINA", 18000},
	[480] = {"COMET", 35000},
	[482] = {"BURRITO", 26000},
	[483] = {"CAMPER", 26000},
	--[485] = {"BAGGAGE", 9000},--погрузчик багажа
	--[486] = {"DOZER", 50000},--бульдозер
	[489] = {"RANCHER", 40000},
	[491] = {"VIRGO", 9000},
	[492] = {"GREENWOO", 19000},
	[494] = {"HOTRING", 145000},--гоночная
	[495] = {"SANDKING", 40000},
	[496] = {"BLISTAC", 35000},
	[498] = {"BOXVILLE", 22000},
	[499] = {"BENSON", 22000},
	[500] = {"MESA", 25000},
	[502] = {"Hotring Racer 2", 145000},--гоночная
	[503] = {"Hotring Racer 3", 145000},--гоночная
	[504] = {"BLOODRA", 45000},--дерби тачка
	[506] = {"SUPERGT", 105000},
	[507] = {"ELEGANT", 35000},
	[508] = {"JOURNEY", 22000},
	--[514] = {"Tanker", 30000},--тягач
	--[515] = {"RDTRAIN", 35000},--тягач
	[516] = {"NEBULA", 35000},
	[517] = {"MAJESTIC", 35000},
	[518] = {"BUCCANEE", 19000},
	--[524] = {"CEMENT", 50000},
	[526] = {"FORTUNE", 19000},
	[527] = {"CADRONA", 9000},
	[529] = {"WILLARD", 19000},
	--[530] = {"FORKLIFT", 9000},--вилочный погр-ик
	--[531] = {"TRACTOR", 9000},
	--[532] = {"COMBINE", 10000},
	[533] = {"FELTZER", 35000},
	[534] = {"REMINGTN", 30000},
	[535] = {"SLAMVAN", 19000},
	[536] = {"BLADE", 19000},
	[540] = {"VINCENT", 19000},
	[541] = {"BULLET", 105000},
	[542] = {"CLOVER", 19000},
	[543] = {"SADLER", 26000},
	--[544] = {"Fire Truck", 15000},--с лестницей
	[545] = {"HUSTLER", 20000},
	[546] = {"INTRUDER", 19000},
	[547] = {"PRIMO", 19000},
	[549] = {"TAMPA", 19000},
	[550] = {"SUNRISE", 19000},
	[551] = {"MERIT", 35000},
	--[552] = {"UTILITY", 20000},--санитарный фургон
	[554] = {"YOSEMITE", 40000},
	[555] = {"WINDSOR", 35000},
	[556] = {"Monster 2", 40000},
	[557] = {"Monster 3", 40000},
	[558] = {"URANUS", 35000},
	[559] = {"JESTER", 35000},
	[560] = {"SULTAN", 35000},
	[561] = {"STRATUM", 35000},
	[562] = {"ELEGY", 35000},
	[565] = {"FLASH", 35000},
	[566] = {"TAHOMA", 35000},
	[567] = {"SAVANNA", 19000},
	[568] = {"BANDITO", 15000},
	--[571] = {"KART", 15000},
	--[572] = {"MOWER", 15000},--газонокосилка
	[573] = {"DUNE", 40000},
	[574] = {"SWEEPER", 15000},--очистка улиц
	[575] = {"BROADWAY", 19000},
	[576] = {"TORNADO", 19000},
	--[578] = {"DFT30", 5000},--3 колесная тачка
	[579] = {"HUNTLEY", 40000},
	[580] = {"STAFFORD", 35000},
	--[582] = {"NEWSVAN", 20000},--фургон новостей
	--[583] = {"TUG", 15000},--буксир
	--[584] = {"PETROTR", 35000},--трейлер бензина
	[585] = {"EMPEROR", 35000},
	[587] = {"EUROS", 35000},
	--[588] = {"HOTDOG", 22000},
	[589] = {"CLUB", 35000},
	[600] = {"PICADOR", 26000},
	[602] = {"ALPHA", 35000},
	[603] = {"PHOENIX", 35000},
	[604] = {"Damaged Glendale", 5000},
	[605] = {"Damaged Sadler", 5000},

	--тачки копов
	[596] = {"Police LS", 25000},
	[597] = {"Police SF", 25000},
	[598] = {"Police LV", 25000},
	[599] = {"Police Ranger", 25000},
	[427] = {"ENFORCER", 40000},--пол-ий грузовик
	[601] = {"S.W.A.T.", 40000},
	[490] = {"FBIRANCH", 40000},
	[525] = {"TOWTRUCK", 20000},--эвакуатор для копов
	[523] = {"HPV1000", 10000},--мотик полиции
	[528] = {"FBITRUCK", 40000},

	--bikes
	[586] = {"WAYFARER", 10000},
	[468] = {"Sanchez", 15000},
	[448] = {"Pizza Boy", 1000},
	[461] = {"PCJ-600", 20000},
	[521] = {"FCR900", 20000},
	[522] = {"NRG500", 90000},
	[462] = {"Faggio", 1000},
	[463] = {"FREEWAY", 10000},
	[581] = {"BF400", 20000},
}

local cash_boats = {
	--[472] = {"COASTGRD", 10000},--лодка берег-ой охраны
	[473] = {"DINGHY", 5000},--моторная лодка
	[493] = {"Jetmax", 60000},--лодка
	--[595] = {"LAUNCH", 30000},--военная лодка
	[484] = {"MARQUIS", 99000},--яхта с парусом
	[430] = {"PREDATOR", 40000},--поли-ая лодка
	[452] = {"SPEEDER", 30000},--лодка
	[453] = {"REEFER", 25000},--рыболовное судно
	[454] = {"TROPIC", 73000},--яхта
	[446] = {"SQUALO", 60000},--лодка
	[539] = {"VORTEX", 26000},--возд-ая подушка
}

local cash_helicopters = {
	--[[[548] = {"CARGOBOB", 25000},
	[425] = {"HUNTER", 99000},--верт военный с ракетами
	[417] = {"LEVIATHN", 25000},--верт военный
	[488] = {"News Chopper", 45000},--верт новостей
	[563] = {"RAINDANC", 99000},--верт спасателей
	[469] = {"SPARROW", 25000},--верт без пушки
	[447] = {"SEASPAR", 28000},--верт с пуляметом]]
	[497] = {"Police Maverick", 45000},
	[519] = {"SHAMAL", 45000},
	[487] = {"MAVERICK", 45000},--верт
	--[553] = {"NEVADA", 45000},--самолет
}

local cash_airplanes = {
	[592] = {"ANDROM", 45000},--андромада
	[593] = {"DODO", 45000},
	[577] = {"AT400", 45000},
	[511] = {"BEAGLE", 45000},--самолет
	[512] = {"CROPDUST", 45000},--кукурузник
	[513] = {"STUNT", 45000},--спорт самолет
	[520] = {"HYDRA", 45000},
	[476] = {"RUSTLER", 45000},--самолет с пушками
	[460] = {"Skimmer", 30000},--самолет садится на воду
}

local car_cash_coef = 10
local car_cash_no = {456,428,420,574,416,408,437,453,519,407,448}
for k,v in pairs(cash_car) do
	local count = 0
	for _,v1 in pairs(car_cash_no) do
		if k ~= v1 then
			count = count+1
		end
	end

	if count == #car_cash_no then
		cash_car[k][2] = v[2]*car_cash_coef
	end
end
for k,v in pairs(cash_boats) do
	local count = 0
	for _,v1 in pairs(car_cash_no) do
		if k ~= v1 then
			count = count+1
		end
	end

	if count == #car_cash_no then
		cash_boats[k][2] = v[2]*car_cash_coef
	end
end
for k,v in pairs(cash_helicopters) do
	local count = 0
	for _,v1 in pairs(car_cash_no) do
		if k ~= v1 then
			count = count+1
		end
	end

	if count == #car_cash_no then
		cash_helicopters[k][2] = v[2]*car_cash_coef
	end
end
for k,v in pairs(cash_airplanes) do
	local count = 0
	for _,v1 in pairs(car_cash_no) do
		if k ~= v1 then
			count = count+1
		end
	end

	if count == #car_cash_no then
		cash_airplanes[k][2] = v[2]*car_cash_coef
	end
end

local interior_business = {
	{1, "Магазин оружия", 285.7870,-41.7190,1001.5160, 6},
	{5, "Магазин одежды", 225.3310,-8.6169,1002.1977, 45},
	{6, "Магазин 24/7", -26.7180,-55.9860,1003.5470, 50},--буду юзать это инт
	{0, "Заправка", 0,0,0, 56},
	{0, "Автомастерская", 0,0,0, 27},
}

local interior_house = {
	{5, "The Crack Den",	322.1117,	1119.3270,	1083.8830},--наркопритон
	{1, "Burglary House 1",	224.6351,	1289.012,	1082.141},
	{2, "Burglary House 2",	225.756,	1240.000,	1082.149},
	{2, "Burglary House 3",	447.470,	1398.348,	1084.305},
	{2, "Burglary House 4",	491.740,	1400.541,	1080.265},
	{3, "Burglary House 5",	234.733,	1190.391,	1080.258},
	{4, "Burglary House 6",	-262.91,	1454.966,	1084.367},
	{4, "Burglary House 7",	221.4296,	1142.423,	1082.609},
	{4, "Burglary House 8",	261.1168,	1286.519,	1080.258},
	{5, "Burglary House 9",	22.79996,	1404.642,	1084.43},
	{5, "Burglary House 10",	228.9003,	1114.477,	1080.992},
	{9, "Burglary House 12",	85.32596,	1323.585,	1083.859},
	{9, "Burglary House 13",	260.3189,	1239.663,	1084.258},
	{10, "Burglary House 14",	21.241,		1342.153,	1084.375},
	{6, "Burglary House 16",	-69.049,	1354.056,	1080.211},
	{15, "Burglary House 18",	327.808,	1479.74,	1084.438},
	{15, "Burglary House 19",	375.572,	1417.439,	1081.328},
	{15, "Burglary House 20",	384.644,	1471.479,	1080.195},
	{15, "Burglary House 21",	295.467,	1474.697,	1080.258},
	{8, "Burglary House 22",	-42.490,	1407.644,	1084.43},
	{6, "Safe House 3",	2333.0330,	-1073.9600,	1049.0230},
	{6, "Safe House 5",	2194.2910,	-1204.0150,	1049.0230},
	{6, "Safe House 6",	2308.8710,	-1210.7170,	1049.0230},
	{8, "Colonel Fuhrberger's House",	2807.8990,	-1172.9210,	1025.5700},--дом с пушкой
	{2, "Ryder's House",	2464.2110,	-1697.9520,	1013.5080},
	{3, "Johnson House",	2496.0500,	-1693.9260,	1014.7420},
	{6, "Burglary House 15",	234.319,	1066.455,	1084.208},--дорогой дом
	{5, "Burglary House 11",	140.5631,	1369.051,	1083.864},--дорогой дом
	{5, "Madd Dogg's Mansion",	1298.9116,	-795.9028,	1084.00},--огромный особняк
}

--здания для работ и фракций
local interior_job = {--12
	{1, "Мясокомбинат", 963.6078,2108.3970,1011.0300, 966.2333984375,2160.5166015625,10.8203125, 51, 1, "", 5},
	{6, "Лос Сантос ПД", 246.4510,65.5860,1003.6410, 1555.494140625,-1675.5419921875,16.1953125, 30, 2, ", Меню - X", 5},
	{10, "Сан Фиерро ПД", 246.4410,112.1640,1003.2190, -1605.7109375,710.28515625,13.8671875, 30, 3, ", Меню - X", 5},
	{3, "Лас Вентурас ПД", 238.384765625,140.4052734375,1003.0234375, 2287.1005859375,2432.3642578125,10.8203125, 30, 4, ", Меню - X", 5},
	{3, "Мэрия ЛС", 374.6708,173.8050,1008.3893, 1481.0576171875,-1772.3115234375,18.795755386353, 19, 5, ", Меню - X", 5},
	{2, "Завод продуктов", 2570.33,-1302.31,1044.12, -86.208984375,-299.36328125,2.7646157741547, 51, 6, "", 5},
	{3, "Мэрия СФ", 374.6708,173.8050,1008.3893, -2766.55078125,375.60546875,6.3346824645996, 19, 7, ", Меню - X", 5},
	{3, "Мэрия ЛВ", 374.6708,173.8050,1008.3893, 2447.6826171875,2376.3037109375,12.163512229919, 19, 8, ", Меню - X", 5},
	{4, "Гонки на мотоциклах", -1435.8690,-662.2505,1052.4650, -2109.66796875,-444.0263671875,38.734375, 33, 9, "", 5},
	{7, "Гонки на автомобилях", -1406.8232421875,-255.7607421875,1043.6507568359, 1097.6357421875,1597.7431640625,12.546875, 33, 10, "", 5},
	{15, "Дерби арена", -1394.20,987.62,1023.96, 2794.310546875,-1723.8642578125,11.84375, 33, 11, "", 5},
	{16, "Последний выживший", -1400,1250,1040, 2685.4638671875,-1802.6201171875,11.84375, 33, 12, "", 5},
	{10, "Казино 4 Дракона", 2009.4140,1017.8990,994.4680, 2019.3134765625,1007.6728515625,10.8203125, 43, 13, "", 5},
	{1, "Казино Калигула", 2235.2524,1708.5146,1010.6129, 2196.9619140625,1677.1708984375,12.3671875, 44, 14, ", Разгрузить товар - E", 5},
	{5, "Эль Кебрадос ПД", 322.72,306.43,999.15, -1389.66015625,2644.005859375,55.984375, 30, 15, ", Меню - X", 5},
	{5, "Форт Карсон ПД", 322.72,306.43,999.15, -217.837890625,979.171875,19.504064559937, 30, 16, ", Меню - X", 5},
	{5, "Диллимор ПД", 322.72,306.43,999.15, 626.9697265625,-571.796875,17.920680999756, 30, 17, ", Меню - X", 5},
	{5, "Эйнджел Пайн ПД", 322.72,306.43,999.15, -2161.2099609375,-2384.9052734375,30.893091201782, 30, 18, ", Меню - X", 5},
	{18, "Отель Атриум", 1726.1370,-1645.2300,20.2260, 1727.0732421875,-1637.03515625,20.217393875122, 35, 19, "", 5},
	{18, "Отель Сфинкс", 1726.1370,-1645.2300,20.2260, 2239.05078125,1285.7119140625,10.8203125, 35, 20, "", 5},
	{18, "Отель Виктория", 1726.1370,-1645.2300,20.2260, -2463.44140625,131.7275390625,35.171875, 35, 21, "", 5},
	{5, "Черный рынок", 322.1117,1119.3270,1083.8830, 2165.9541015625,-1671.1748046875,15.07315826416, 18, 22, ", Меню - X", 5},
	{3, "Зона 51", 374.6708,173.8050,1008.3893, 333.18359375,1951.68359375,17.640625, 20, 23, ", Меню - X", 5},
	{18, "Казарма", 1726.1370,-1645.2300,20.2260, 233.2578125,1840.21875,17.640625, 35, 24, "", 5},
	{6, "Тренажорный зал ЛС", 774.0870,-47.9830,1000.5860, 2229.9140625,-1721.26953125,13.561408996582, 54, 25, "", 5},
	{6, "Тренажорный зал СФ", 774.0870,-47.9830,1000.5860, -2270.642578125,-155.955078125,35.3203125, 54, 26, "", 5},
	{6, "Тренажорный зал ЛВ", 774.0870,-47.9830,1000.5860, 1968.7275390625,2295.87109375,16.455863952637, 54, 27, "", 5},
}

--пикапы для работ и фракций
local interior_job_pickup = {
	{createPickup ( 292.31268310547,1833.2623291016,18.05459022522, 3, job_icon, 10000 ), 279.1279296875,1833.1435546875,18.08740234375},--кпп1
	{createPickup ( 279.1279296875,1833.1435546875,18.08740234375, 3, job_icon, 10000 ), 292.31268310547,1833.2623291016,18.05459022522}--кпп2
}

local t_s_salon = {
	{2131.9775390625,-1151.322265625,24.062105178833, 55},--авто
	{1590.1689453125,1170.60546875,14.224066734314, 5},--верт
	{-2187.46875,2416.5576171875,5.1651339530945, 9},--лодки
}

--места поднятия предметов
local up_car_subject = {--{x,y,z, радиус 4, ид пнг 5, ид тс 6, зп 7}
	{89.9423828125,-304.623046875,1.578125, 15, 24, 456, 100},--склад продуктов
	{260.4326171875,1409.2626953125,10.506074905396, 15, 73, 456, 200},--нефтезавод
	{-1061.6103515625,-1195.5166015625,129.828125, 15, 88, 456, 200},--скотобойня
	{1461.939453125,974.8876953125,10.30264377594, 15, 89, 456, 50},--склад корма для коров
	{2492.3974609375,2773.46484375,10.803514480591, 15, 66, 428, 200},--kacc
	{2122.8994140625,-1790.56640625,13.5546875, 15, 31, 448, 200},--pizza
}

local up_player_subject = {--{x,y,z, радиус 4, ид пнг 5, зп 6, интерьер 7, мир 8, скин 9}
	{2559.1171875,-1287.2275390625,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2551.1318359375,-1287.2294921875,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2543.0859375,-1287.2216796875,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2543.166015625,-1300.0927734375,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2551.09375,-1300.09375,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2559.0185546875,-1300.0927734375,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{-491.4609375,-194.43359375,78.394332885742, 5, 67, 1, 0, 0, 27},--лесоповал
	{576.8212890625,846.5732421875,-42.264389038086, 5, 70, 1, 0, 0, 260},--рудник лв
	{1743.0302734375,-1864.4560546875,13.573830604553, 5, 74, 1, 0, 0, 253},--автобусник
	{964.064453125,2117.3544921875,1011.0302734375, 1, 30, 1, 1, 1, 0},--мясокомбинат
}

--места сброса предметов
local down_car_subject = {--{x,y,z, радиус 4, ид пнг 5, ид тс 6}
	{2787.8974609375,-2455.974609375,13.633636474609, 15, 24, 456},--порт лс
	{2787.8974609375,-2455.974609375,13.633636474609, 15, 73, 456},--порт лс
	{966.951171875,2132.8623046875,10.8203125, 15, 88, 456},--мясокомбинат
	{-1079.947265625,-1195.580078125,129.79998779297, 15, 89, 456},--скотобойня корм
}

--места разгрузки
local down_car_subject_pos = {--{x,y,z, радиус 4, ид пнг 5, ид тс 6, зп 7}
	{-1813.2890625,-1654.3330078125,22.398532867432, 15, 75, 408, 200},--свалка
	{2315.595703125,6.263671875,26.484375, 15, 65, 428, 200},--банк
	{2463.7587890625,-2716.375,1.1451852619648, 15, 78, 453, 200},--доки лс
}

local down_player_subject = {--{x,y,z, радиус 4, ид пнг 5, интерьер 6, мир 7}
	{942.4775390625,2117.900390625,1011.0302734375, 5, 48, 1, 1},--мясокомбинат
	{2564.779296875,-1293.0673828125,1044.125, 2, 62, 2, 6},--завод продуктов
	{681.7744140625,823.8447265625,-26.840600967407, 5, 71, 0, 0},--рудник лв
	{-488.2119140625,-176.8603515625,78.2109375, 5, 68, 0, 0},--склад бревен
	{-1633.845703125,-2239.08984375,31.4765625, 5, 28, 0, 0},--охотничий дом
	{681.7744140625,823.8447265625,-26.840600967407, 5, 16, 0, 0},--рудник лв
	{2435.361328125,-2705.46484375,3, 5, 32, 0, 0},--доки лc
}

local anim_player_subject = {--{x,y,z, радиус 4, ид пнг1 5, ид пнг2 6, зп 7, анимация1 8, анимация2 9, интерьер 10, мир 11, время работы анимации 12} также нужно прописать ид пнг 
	--завод продуктов
	{2558.6474609375,-1291.0029296875,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2556.080078125,-1290.9970703125,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2553.841796875,-1291.0048828125,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2544.4326171875,-1291.00390625,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2541.9169921875,-1290.9951171875,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2541.9091796875,-1295.8505859375,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2544.427734375,-1295.8505859375,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2553.7578125,-1295.8505859375,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2556.2578125,-1295.8544921875,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},
	{2558.5478515625,-1295.8505859375,1044.125, 1, 69, 62, 1, "int_house", "wash_up", 2, 6, 5},

	--лесоповал
	{-511.3896484375,-193.8212890625,78.391899108887, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-515.8330078125,-194.17578125,78.40625, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-521.138671875,-194.4169921875,78.40625, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-525.8740234375,-194.6396484375,78.40625, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-530.169921875,-194.83984375,78.40625, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-535.298828125,-195.0869140625,78.40625, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-547.07421875,-158.0869140625,77.827285766602, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-542.3623046875,-157.970703125,77.814529418945, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-536.755859375,-158.0146484375,77.819396972656, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-531.126953125,-157.77734375,77.626838684082, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-525.6103515625,-157.7939453125,77.082763671875, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-494.0009765625,-154.6943359375,76.312866210938, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-487.8037109375,-154.35546875,76.055053710938, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-482.490234375,-154.0693359375,75.835266113281, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-477.3134765625,-153.7890625,75.568603515625, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},
	{-471.2958984375,-153.5048828125,75.246078491211, 1, 67, 68, 1, "chainsaw", "weapon_csaw", 0, 0, 5},

	--рудник лв
	{630.7001953125,865.71032714844,-42.660102844238, 1, 70, 16, 1, "baseball", "bat_4", 0, 0, 5},
	{619.72265625,873.4443359375,-42.9609375, 1, 70, 16, 1, "baseball", "bat_4", 0, 0, 5},
	{607.9052734375,864.9892578125,-42.809223175049, 1, 70, 16, 1, "baseball", "bat_4", 0, 0, 5},
	{610.1083984375,845.86267089844,-42.524024963379, 1, 70, 16, 1, "baseball", "bat_4", 0, 0, 5},
	{627.5458984375,844.70349121094,-42.33695602417, 1, 70, 16, 1, "baseball", "bat_4", 0, 0, 5},
	{579.53356933594,874.83459472656,-43.100883483887, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{574.99548339844,889.15100097656,-42.958339691162, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{559.23962402344,892.81115722656,-42.695762634277, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{552.41442871094,878.68420410156,-42.364948272705, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{563.02087402344,863.94885253906,-42.350147247314, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
}

for k=1,10 do
	anim_player_subject[k][7] = 100
	anim_player_subject[k][12] = 10
end

for k=11,26 do
	anim_player_subject[k][7] = 100
	anim_player_subject[k][12] = 10
end

for k=27,36 do
	anim_player_subject[k][7] = 100
	anim_player_subject[k][12] = 10
end

--камеры полиции
local prison_cell = {
	{interior_job[2][1], interior_job[2][10], "кпз_лс",		263.84765625,	77.6044921875,	1001.03906},
	{interior_job[3][1], interior_job[3][10], "кпз_сф1",	227.5947265625,	110.0537109375,	999.015625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф2",	223.373046875,	110.0986328125,	999.015625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф3",	219.337890625,	110.4619140625,	999.015625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф4",	215.59375,		109.8916015625,	999.015625},
	{interior_job[4][1], interior_job[4][10], "кпз_лв",		198.283203125,	162.1220703125,	1003.02996},
	{interior_job[4][1], interior_job[4][10], "кпз_лв2",	198.0390625,	174.78125,		1003.02343},
	{interior_job[4][1], interior_job[4][10], "кпз_лв3",	193.6708984375,	176.7255859375,	1003.02343},
}

--места спавна у госпиталя
local hospital_spawn = {
	{1607.423828125,1815.244140625,10.8203125},
	{-2654.4873046875,640.1650390625,14.454549789429},
	{1172.0771484375,-1323.28125,15.402851104736},
	{2027.0,-1412.3037109375,16.9921875},
	{-320.17578125,1048.234375,20.340259552002},
	{-1514.671875,2518.9306640625,56.0703125},
}

local station = {
	{1743.119140625,-1943.5732421875,13.569796562195, 10, "вокзал лс"},
	{-1973.22265625,116.78515625,27.6875, 10, "вокзал сф"},
	{2848.4521484375,1291.462890625,11.390625, 10, "вокзал лв"},
}

local roulette_pos = {}
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'roulette'" )) do
	local spl = split(v["pos"], ",")
	roulette_pos[k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end

local clear_street_pos = {
	["Los Santos"] = { [1] = {}, [2] = {} },
	["San Fierro"] = { [1] = {}, [2] = {} },
	["Las Venturas"] = { [1] = {}, [2] = {} },
}
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Los Santos"][1][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street2'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Los Santos"][2][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street3'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["San Fierro"][1][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street4'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["San Fierro"][2][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street5'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Las Venturas"][1][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street6'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Las Venturas"][2][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end

local plane_job = {
	{1532.904296875,1449.3662109375,11.769500732422, "Лас Вентурас"},
	{-1339.0771484375,-225.6962890625,15.069016456604, "Сан Фиерро"},
	{1940.416015625,-2326.716796875,14.466937065125, "Лос Сантос"},
}

local sell_car_theft = {
	{-1106.65234375,-1620.943359375,76.3671875},
}

local original_business_pos = {
	{1315.389648, -898.885803, 39.578125},
	{1199.693847, -919.824829, 43.107589},
	{1087.605468, -922.871948, 43.390625},
	{927.423706, -1352.795166, 13.376624},
	{953.874816, -1336.391479, 13.538938},
	{2421.620361, -1509.163085, 23.992208},
	{2309.676757, -1644.051757, 14.827047},
	{2421.507324, -1219.351928, 25.554723},
	{1835.677490, -1682.488403, 13.379734},
	{-2026.599121, -101.420875, 35.164062},
	{-2243.077392, -88.254119, 35.320312},
	{2020.498535, 1007.743408, 10.820312},
	{2195.840087, 1677.150512, 12.367187},
	{2083.363037, 2223.861572, 11.023437},
	{1872.878784, 2071.857666, 11.062500},
	{2507.153076, 2121.128173, 10.840013},
	{2637.511718, 1671.698120, 11.023437},
	{2546.290283, 1971.762695, 10.820312},
	{-2672.043945, 258.937194, 4.632812},
	{-2356.885498, 1008.085449, 50.898437},
	{-1911.886352, 828.324584, 35.190605},
	{-1808.028808, 945.119873, 24.890625},
	{-1816.763427, 617.589660, 35.171875},
	{-1721.932250, 1359.860717, 7.185316},
	{-2154.623535, -2460.848876, 30.851562},
	{203.338851, -203.111373, 1.578125},
	{-2336.397460, -166.919891, 35.554687},
	{172.669723, 1176.409179, 14.764543},
	{-2624.398925, 1411.984985, 7.093750},
	{ 2332.967041, 75.052017, 26.620975},
	{ 1367.071044, 248.593109, 19.566932},
	{ 810.959289, -1616.228393, 13.546875},
	{ 2366.433105, 2071.120605, 10.820312},
	{ 2472.081542, 2034.191772, 11.062500},
	{ 2393.012207, 2043.314697, 10.820312},
	{ 2846.259521, 2414.882568, 11.068956},
	{ 2756.376708, 2476.747314, 11.062500},
	{ 2885.277587, 2453.478271, 11.068956},
	{ -2242.484130, 128.449966, 35.320312},
	{ -2442.768310, 754.327941, 35.171875},
	{ 1631.911132, -1172.027099, 24.078125},
	{ 1289.185424, 270.880920, 19.554687},
	{ 1038.215576, -1339.617309, 13.726562},
	{ 2094.657714, 2122.192871, 10.820312},
	{ 2085.687255, 2074.024902, 11.054687},
	{ 693.628173, 1966.920166, 5.539062},
	{ 1158.547973, 2072.261474, 11.062500},
	{ 2170.229003, 2795.691894, 10.820312},
	{ 2330.606201, 2532.529785, 10.820312},
	{2825.737060, 2407.213623, 11.062500},
	{ 2802.501220, 2430.280273, 11.062500},
	{ 2779.359375, 2453.658691, 11.062500},
	{ 2102.554687, 2228.759033, 11.023437},
	{ 2102.572265, 2257.474365, 11.023437},
	{ 2097.767578, 2223.978515, 11.023437},
	{ 2090.559570, 2224.423828, 11.023437},
	{ 2194.563720, 1991.017944, 12.296875},
	{ 2452.393310, 2064.608154, 10.820312},
	{ 2441.232421, 2064.397949, 10.820312},
	{ 2080.458740, 2121.975341, 10.812517},
	{ -2571.014892, 246.275955, 10.185619},
	{ -2492.447998, -38.669422, 25.765625},
	{ -2492.282470, -29.028230, 25.765625},
	{ -1883.063476, 865.582031, 35.172843},
	{ -1693.950805, 950.370056, 24.890625},
	{ -2374.904052, 910.287475, 45.445312},
	{ 2069.536621, -1779.876708, 13.559158},
	{ 2071.437255, -1793.805786, 13.553277},
	{ 2104.495605, -1806.595214, 13.554687},
	{ 453.227142, -1478.244018, 30.812078},
	{ 1368.388671, -1279.795898, 13.546875},
	{ 2397.941406, -1898.133666, 13.546875},
	{ -1561.987426, -2733.466552, 48.743457},
	{ -2093.248046, -2464.454589, 30.625000},
	{ 1975.763061, -2036.651611, 13.546875},
	{ 1941.082763, -2116.011474, 13.695312},
	{ 1832.444946, -1842.604736, 13.578125},
	{ 2158.767333, 943.083129, 10.820312},
	{ 2638.084228, 1849.809326, 11.023437},
	{ -143.945327, 1224.217529, 19.899219},
	{ 1969.270507, 2294.182617, 16.455863},
	{ 1937.173583, 2307.304931, 10.820312},
	{ -1508.861572, 2609.611572, 55.835937},
	{ 2247.947509, 2397.572998, 10.820312},
	{ 2722.694335, -2026.645629, 13.547199},
	{ 2538.900878, 2084.042968, 10.820312},
	{ 823.392944, -1588.984252, 13.554450},
	{ -2767.562500, 788.794433, 52.781250},
	{ -2551.652832, 193.638565, 6.190325},
	{ 1070.058349, -1221.396118, 16.890625},
	{ 811.207946, -1060.040649, 24.946811},
	{ 499.961059, -1359.307128, 16.257724},
	{ 460.946624, -1500.953002, 31.058170},
	{ 681.296936, -474.303710, 16.536296},
	{ 2244.590820, -1664.513061, 15.476562},
	{ 674.178527, -497.001251, 16.335937},
	{ 661.015319, -573.572692, 16.335937},
	{ 2354.133056, -1512.185668, 24.000000},
	{ -2626.432128, 209.431488, 4.601754},
	{ 2400.531738, -1980.582885, 13.546875},
	{ 778.146789, 1871.564575, 4.907619},
	{ -314.774688, 829.901977, 14.242187},
	{ 241.099655, -178.363815, 1.578125},
	{ 2334.055664, 61.541301, 26.484687},
}

local gans_pos = {
	{-2626.432128, 209.431488, 4.601754},
	{2400.531738, -1980.582885, 13.546875},
	{778.146789, 1871.564575, 4.907619},
	{-314.774688, 829.901977, 14.242187},
	{241.099655, -178.363815, 1.578125},
	{2334.055664, 61.541301, 26.484687},
	{2538.900878, 2084.042968, 10.820312},
	{-1508.861572, 2609.611572, 55.835937},
	{2158.767333, 943.083129, 10.820312},
	{-2093.248046, -2464.454589, 30.625000},
	{1368.388671, -1279.795898, 13.546875},
}

local busdriver_pos = {
	{1776.921875,-1897.3623046875,13.520164489746},
	{2832.11328125,1291.9189453125,10.908647537231},
	{-1993.9208984375,144.396484375,27.685970306396},
	{1743.0302734375,-1864.4560546875,13.573830604553},
}

local korovi_pos = {}
local grass_pos = {}

--инв-рь игрока
local array_player_1 = {}
local array_player_2 = {}

local state_inv_player = {}--состояние инв-ря игрока 0-выкл, 1-вкл
local state_gui_window = {}--состояние гуи окна 0-выкл, 1-вкл
local logged = {}--0-не вошел, 1-вошел
local enter_house = {}--0-не вошел, 1-вошел (не удалять)
local enter_business = {}--0-не вошел, 1-вошел (не удалять)
local enter_job = {}--0-не вошел, 1-вошел (не удалять)
local speed_car_device = {}--отображение скорости авто, 0-выкл, 1-вкл
local arrest = {}--арест игрока, 0-нет, 1-да, 2-да админом
local crimes = {}--преступления
local robbery_player = {}--ограбление, 0-нет, 1-да
local robbery_timer = {}--таймер ограбления
local gps_device = {}--отображение координат игрока, 0-выкл, 1-вкл
local job = {}--переменная работ
local job_call = {}--переменная для работ
local job_ped = {}--создан ли нпс, 0-нет
local job_blip = {}--создан ли блип, 0-нет
local job_marker = {}--создан ли маркер, 0-нет
local job_pos = {}--позиция места назначения
local job_vehicleid = {}--позиция авто
local job_timer = {}--таймер угона
local job_object = {}--создан ли объект, 0-нет
local armour = {}--броня

--нужды
local alcohol = {}
local satiety = {}
local hygiene = {}
local sleep = {}
local drugs = {}
local max_alcohol = 500
local max_satiety = 100
local max_hygiene = 100
local max_sleep = 100
local max_drugs = 100

--инв-рь авто
local array_car_1 = {}
local array_car_2 = {}
local fuel = {}--топливный бак
local probeg = {}--пробег

--инв-рь дома
local array_house_1 = {}
local array_house_2 = {}

-------------------пользовательские функции 2----------------------------------------------
function debuginfo ()
	if(point_guns_zone[1] == 1) then
	
		time_guns_zone = time_guns_zone-1

		if(time_guns_zone == 0) then
		
			time_guns_zone = time_gz

			if(point_guns_zone[4] > point_guns_zone[6]) then
			
				guns_zone[point_guns_zone[2]][2] = point_guns_zone[3]

				setRadarAreaColor ( guns_zone[point_guns_zone[2]][1], name_mafia[point_guns_zone[3]][2][1], name_mafia[point_guns_zone[3]][2][2], name_mafia[point_guns_zone[3]][2][3], 100 )

				sendMessage(getRootElement(), "[НОВОСТИ] "..name_mafia[point_guns_zone[3]][1].." захватила территорию", green)

				sqlite( "UPDATE guns_zone SET mafia = '"..point_guns_zone[3].."' WHERE number = '"..point_guns_zone[2].."'")
			
			else
			
				guns_zone[point_guns_zone[2]][2] = point_guns_zone[5]

				setRadarAreaColor ( guns_zone[point_guns_zone[2]][1], name_mafia[point_guns_zone[5]][2][1], name_mafia[point_guns_zone[5]][2][2], name_mafia[point_guns_zone[5]][2][3], 100 )

				sendMessage(getRootElement(), "[НОВОСТИ] "..name_mafia[point_guns_zone[5]][1].." удержала территорию", green)
			end

			setRadarAreaFlashing ( guns_zone[point_guns_zone[2]][1], false )

			point_guns_zone[1] = 0
			point_guns_zone[2] = 0--gz

			point_guns_zone[3] = 0--mafia A
			point_guns_zone[4] = 0--points

			point_guns_zone[5] = 0--mafia D
			point_guns_zone[6] = 0--points
		end
	end

	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)
		local hour, minute = getTime()

		if(point_guns_zone[1] == 1) then
			points_add_in_gz(playerid, 1)
		end

		setElementData(playerid, "crimes_data", crimes[playername])
		setElementData(playerid, "alcohol_data", alcohol[playername])
		setElementData(playerid, "satiety_data", satiety[playername])
		setElementData(playerid, "hygiene_data", hygiene[playername])
		setElementData(playerid, "sleep_data", sleep[playername])
		setElementData(playerid, "drugs_data", drugs[playername])
		setElementData(playerid, "tomorrow_weather_data", tomorrow_weather)
		setElementData(playerid, "speed_car_device_data", speed_car_device[playername])
		setElementData(playerid, "gps_device_data", gps_device[playername])
		setElementData(playerid, "timeserver", hour..":"..minute)
		setElementData(playerid, "earth", earth)
		setElementData(playerid, "no_ped_damage", no_ped_damage)
		setElementData(playerid, "job_player", job[playername])

		--позиции домов, бизнесов, зданий
		setElementData(playerid, "house_pos", house_pos)
		setElementData(playerid, "business_pos", business_pos)

		local vehicleid = getPlayerVehicle(playerid)
		if (vehicleid) then
			local plate = getVehiclePlateText(vehicleid)
			setElementData(playerid, "fuel_data", fuel[plate])
			setElementData(playerid, "probeg_data", probeg[plate])
		end

		if search_inv_player_2_parameter(playerid, 85) ~= 0 then
			setElementData(playerid, "guns_zone2", {point_guns_zone, time_guns_zone})
		else
			setElementData(playerid, "guns_zone2", false)
		end

		sqlite_load(playerid, "cow_farms_db")

		if armour[playername] ~= 0 and getPedArmor(playerid) == 0 then
			destroyElement(armour[playername])
			armour[playername] = 0
		end
	end
end

function job_timer2 ()
	--места для таксистов
	local taxi_pos = {
		{2308.81640625,-13.25,26.7421875},--банк
	}

	local fire_pos = {}

	for k,v in pairs(house_pos) do
		taxi_pos[#taxi_pos+1] = {v[1],v[2],v[3]}
		fire_pos[#fire_pos+1] = {v[1],v[2],v[3]}
	end

	for k,v in pairs(interior_job) do
		if k ~= 23 then
			taxi_pos[#taxi_pos+1] = {v[6],v[7],v[8]}
		end
	end

	for k,v in pairs(original_business_pos) do
		taxi_pos[#taxi_pos+1] = {v[1],v[2],v[3]}
		fire_pos[#fire_pos+1] = {v[1],v[2],v[3]}
	end

	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)

		if logged[playername] == 1 then
			if job[playername] == 1 then--работа таксиста
				if vehicleid then
					if getElementModel(vehicleid) == 420 then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#taxi_pos)

								sendMessage(playerid, "Езжайте на вызов", yellow)

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = random(1,#taxi_pos)
									local randomize_skin = 1

									while true do
										local skin_table = getValidPedModels()
										local random1 = random(1,312)
										if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 then
											randomize_skin = skin_table[random1]
											break
										else
											random1 = random(1,#skin_table)
										end
									end

									sendMessage(playerid, "Отвезите клиента", yellow)

									job_call[playername] = 2
									job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
									job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0.0, true )

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								
									if not getVehicleOccupant ( vehicleid, 1 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 1 )
									elseif not getVehicleOccupant ( vehicleid, 2 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 2 )
									elseif not getVehicleOccupant ( vehicleid, 3 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 3 )
									end
								end

							elseif job_call[playername] == 2 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = random(zp_player_taxi/2,zp_player_taxi)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", green)

									destroyElement(job_ped[playername])
									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									job_ped[playername] = 0
									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end

						end
					end
				end

			elseif job[playername] == 2 then--работа водителя мусоровоза
				if vehicleid then
					if getElementModel(vehicleid) == down_car_subject_pos[1][6] then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#taxi_pos)

								sendMessage(playerid, "Соберите мусор, потом доставьте его на свалку", yellow)

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize_zp = random(down_car_subject_pos[1][7]/2,down_car_subject_pos[1][7])
									local randomize = random(1,#taxi_pos)

									give_subject( playerid, "car", down_car_subject_pos[1][5], randomize_zp, false )

									job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

							if isPointInCircle3D(x,y,z, down_car_subject_pos[1][1],down_car_subject_pos[1][2],down_car_subject_pos[1][3], down_car_subject_pos[1][4]) and amount_inv_car_1_parameter(vehicleid, down_car_subject_pos[1][5]) ~= 0 then
								local randomize = amount_inv_car_2_parameter(vehicleid, down_car_subject_pos[1][5])

								inv_car_delet_1_parameter(playerid, down_car_subject_pos[1][5], true)

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", green)

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_marker[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
							end

						end
					end
				end

			elseif job[playername] == 3 then--работа инкассатора
				if vehicleid then
					if getElementModel(vehicleid) == down_car_subject_pos[2][6] then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#original_business_pos)

								sendMessage(playerid, "Соберите деньги, потом доставьте их в банк (BS на карте)", yellow)

								job_call[playername] = 1
								job_pos[playername] = {original_business_pos[randomize][1],original_business_pos[randomize][2],original_business_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize_zp = random(down_car_subject_pos[2][7]/2,down_car_subject_pos[2][7])
									local randomize = random(1,#original_business_pos)

									give_subject( playerid, "car", down_car_subject_pos[2][5], randomize_zp, false )

									job_pos[playername] = {original_business_pos[randomize][1],original_business_pos[randomize][2],original_business_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

							if isPointInCircle3D(x,y,z, down_car_subject_pos[2][1],down_car_subject_pos[2][2],down_car_subject_pos[2][3], down_car_subject_pos[2][4]) and amount_inv_car_1_parameter(vehicleid, down_car_subject_pos[2][5]) ~= 0 then
								local randomize = amount_inv_car_2_parameter(vehicleid, down_car_subject_pos[2][5])

								inv_car_delet_1_parameter(playerid, down_car_subject_pos[2][5], true)

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", green)

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_marker[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
							end

						end
					end
				end

			elseif job[playername] == 4 then--работа рыболова
				if vehicleid then
					if getElementModel(vehicleid) == down_car_subject_pos[3][6] then
						if getSpeed(vehicleid) <= 5 then

							if job_call[playername] == 0 then
								local fish_pos = {random(3000,4000), random(-3000,500), 0}

								sendMessage(playerid, "Соберите рыбу, потом доставьте её в доки Лос Сантоса", yellow)

								job_call[playername] = 1
								job_pos[playername] = {fish_pos[1],fish_pos[2],fish_pos[3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize_zp = random(down_car_subject_pos[3][7]/2,down_car_subject_pos[3][7])
									local fish_pos = {random(3000,4000), random(-3000,500), 0}

									give_subject( playerid, "car", down_car_subject_pos[3][5], randomize_zp, false )

									job_pos[playername] = {fish_pos[1],fish_pos[2],fish_pos[3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

							if isPointInCircle3D(x,y,z, down_car_subject_pos[3][1],down_car_subject_pos[3][2],down_car_subject_pos[3][3], down_car_subject_pos[3][4]) and amount_inv_car_1_parameter(vehicleid, down_car_subject_pos[3][5]) ~= 0 then
								local randomize = amount_inv_car_2_parameter(vehicleid, down_car_subject_pos[3][5])

								inv_car_delet_1_parameter(playerid, down_car_subject_pos[3][5], true)

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", green)

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_marker[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
							end

						end
					end
				end

			elseif job[playername] == 5 then--работа пилота
				if vehicleid then
					if getElementModel(vehicleid) == 519 and getElementModel(playerid) == 61 then
						if getSpeed(vehicleid) <= 5 then

							if job_call[playername] == 0 then
								job_call[playername] = 1
								local randomize = job_call[playername]

								sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], yellow)

								job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then--лв
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									local randomize = random(zp_player_plane/2,zp_player_plane)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", green)

									job_call[playername] = 2
									local randomize = job_call[playername]

									sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], yellow)

									job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername] == 2 then--сф
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									local randomize = random(zp_player_plane/2,zp_player_plane)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", green)

									job_call[playername] = 3
									local randomize = job_call[playername]

									sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], yellow)

									job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername] == 3 then--лс
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									local randomize = random(zp_player_plane/2,zp_player_plane)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", green)

									job_call[playername] = 1
									local randomize = job_call[playername]

									sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], yellow)

									job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

						end
					end
				end

			elseif (job[playername] == 6) then --работа Угонщик
			
				if (job_call[playername] == 0) then 
				
					local vehicleid = player_car_theft()
					local pos = {getElementPosition(vehicleid)}
					local rot = {getElementRotation(vehicleid)}

					job_call[playername] = 1
					job_pos[playername] = {pos[1],pos[2],pos[3]}

					job_vehicleid[playername] = {vehicleid,pos[1],pos[2],pos[3],rot[3]}
					job_timer[playername] = setTimer(car_theft_fun, (car_theft_time*60000), 1, playername)

					sendMessage(playerid, "Угоните т/с гос.номер "..getVehiclePlateText(job_vehicleid[playername][1])..", у вас есть "..car_theft_time.." мин", yellow)

					job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
					job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, yellow[1],yellow[2],yellow[3], 255, playerid )
					
				elseif (job_call[playername] == 1) then
				
					if (job_vehicleid[playername][1] == vehicleid) then
					
						local x1,y1 = player_position( playerid )

						job_call[playername] = 2

						local randomize = random(1,#sell_car_theft)

						sendMessage(playerid, "Езжайте в отстойник", yellow)

						police_chat(playerid, "[ДИСПЕТЧЕР] Угон "..getVehicleNameFromModel(getElementModel(vehicleid)).." гос.номер "..getVehiclePlateText(vehicleid)..", координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

						job_pos[playername] = {sell_car_theft[randomize][1],sell_car_theft[randomize][2],sell_car_theft[randomize][3]}

						setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
						setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
					end
				
				elseif (job_call[playername] == 2) then
				
					if (isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5.0) and job_vehicleid[playername][1] == vehicleid) then
					
						if (getSpeed(vehicleid) < 1) then
						
							local randomize = cash_car[getElementModel(vehicleid)][2]*0.05

							inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

							sendMessage(playerid, "Вы получили "..randomize.."$", green)

							job_pos[playername] = 0
							job_call[playername] = 3

							local crimes_plus = zakon_car_theft_crimes
							crimes[playername] = crimes[playername]+crimes_plus
							sendMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername], blue)

							car_theft_fun(playername)

							job_blip[playername] = 0
							job_marker[playername] = 0
						end
					end
				end

			elseif job[playername] == 7 then--забойщик скота
				if job_call[playername] == 0 then
					job_call[playername] = 1
					local randomize = random(1,#korovi_pos)

					sendMessage(playerid, "Убейте корову", yellow)

					job_pos[playername] = {korovi_pos[randomize][1],korovi_pos[randomize][2],korovi_pos[randomize][3]-1}
					job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
					job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, yellow[1],yellow[2],yellow[3], 255, playerid )

				elseif job_call[playername] == 1 then
					local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, 87).."'" )

					if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) and result[1] and getPedWeapon(playerid) == weapon[38][2] then
						if result[1]["warehouse"] < max_cf and result[1]["money"] >= result[1]["price"] and result[1]["nalog"] ~= 0 and result[1]["prod"] ~= 0 then
							local randomize = result[1]["price"]

							job_call[playername] = 2

							setPedAnimation(playerid, "knife", "knife_3", -1, true, false, false, false)

							setTimer(function ()
								if isElement(playerid) then
									setPedAnimation(playerid, nil, nil)
								end
							end, (10*1000), 1)

							sqlite( "UPDATE cow_farms_db SET warehouse = warehouse + '1', prod = prod - '1', money = money - '"..randomize.."' WHERE number = '"..search_inv_player_2_parameter(playerid, 87).."'" )

							inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

							sendMessage(playerid, "Вы получили "..randomize.."$", green)
						end
					end

				elseif job_call[playername] == 2 then
					destroyElement(job_blip[playername])
					destroyElement(job_marker[playername])

					job_blip[playername] = 0
					job_marker[playername] = 0
					job_pos[playername] = 0
					job_call[playername] = 0
				end

			elseif job[playername] == 8 then--работа перевозчика оружия
				if vehicleid then
					if getElementModel(vehicleid) == up_car_subject[5][6] then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#gans_pos)

								sendMessage(playerid, "Езжайте на завод KACC чтобы загрузить ящики с оружием, а потом развезите их по аммунациям", yellow)

								job_call[playername] = 1
								job_pos[playername] = {gans_pos[randomize][1],gans_pos[randomize][2],gans_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) and amount_inv_car_1_parameter(vehicleid, up_car_subject[5][5]) ~= 0 then
									local randomize = random(1,#gans_pos)
									local sic2p = search_inv_car_2_parameter(vehicleid, up_car_subject[5][5])

									job_pos[playername] = {gans_pos[randomize][1],gans_pos[randomize][2],gans_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])

									inv_car_delet(playerid, up_car_subject[5][5], sic2p, true, false)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+sic2p, playername )

									sendMessage(playerid, "Вы получили "..sic2p.."$", green)
								end
							end

						end
					end
				end

			elseif job[playername] == 9 then--работа автобусник
				if vehicleid then
					if getElementModel(vehicleid) == 437 and getElementModel(playerid) == 253 then
						if getSpeed(vehicleid) < 1 and search_inv_player_2_parameter(playerid, up_player_subject[9][5]) ~= 0 then

							if job_call[playername] == 0 then

								sendMessage(playerid, "Езжайте по маршруту", yellow)

								job_call[playername] = search_inv_player_2_parameter(playerid, up_player_subject[9][5])
								job_pos[playername] = {busdriver_pos[ job_call[playername] ][1],busdriver_pos[ job_call[playername] ][2],busdriver_pos[ job_call[playername] ][3]-1}

								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 15.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] >= 1 and job_call[playername] <= 3 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 15) then

									inv_player_delet(playerid, up_player_subject[9][5], job_call[playername], true)

									job_call[playername] = job_call[playername]+1

									inv_player_empty(playerid, up_player_subject[9][5], job_call[playername])

									job_pos[playername] = {busdriver_pos[ job_call[playername] ][1],busdriver_pos[ job_call[playername] ][2],busdriver_pos[ job_call[playername] ][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername] == 4 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 15) then
									local randomize = random(zp_player_busdriver/2,zp_player_busdriver)

									inv_player_delet(playerid, up_player_subject[9][5], job_call[playername], true)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили за маршрут "..randomize.."$", green)

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end

						end
					end
				end

			elseif job[playername] == 10 then--работа парамедик
				if vehicleid then
					if getElementModel(vehicleid) == 416 and (getElementModel(playerid) == 274 or getElementModel(playerid) == 275 or getElementModel(playerid) == 276) then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#taxi_pos)

								sendMessage(playerid, "Езжайте на вызов", yellow)

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = random(1,#taxi_pos)
									local randomize_skin = 1

									while true do
										local skin_table = getValidPedModels()
										local random1 = random(1,312)
										if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 then
											randomize_skin = skin_table[random1]
											break
										else
											random1 = random(1,#skin_table)
										end
									end

									sendMessage(playerid, "Отвезите пациента в ближайшую больницу", yellow)

									job_call[playername] = 2
									job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0.0, true )

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])
									job_blip[playername] = 0
									job_marker[playername] = 0
								
									if not getVehicleOccupant ( vehicleid, 2 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 2 )
									elseif not getVehicleOccupant ( vehicleid, 3 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 3 )
									end
								end

							elseif job_call[playername] == 2 then
								for k,v in pairs(hospital_spawn) do
									if isPointInCircle3D(x,y,z, v[1],v[2],v[3], 40) then
										local randomize = random(zp_player_medic/2,zp_player_medic)

										inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

										sendMessage(playerid, "Вы получили "..randomize.."$", green)

										destroyElement(job_ped[playername])

										job_ped[playername] = 0
										job_pos[playername] = 0
										job_call[playername] = 0
									end
								end
							end

						end
					end
				end

			elseif job[playername] == 11 then--работа sas
				if vehicleid then
					if getElementModel(vehicleid) == 574 then
						if getSpeed(vehicleid) < 61 then

							if job_call[playername] == 0 then

								sendMessage(playerid, "Езжайте по маршруту", yellow)

								job_call[playername] = {getElementZoneName ( playerid, true ), random(1,2), 1}
								job_pos[playername] = {clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][1],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][2],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][3]-1}

								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername][3] >= 1 and job_call[playername][3] <= #clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ]-1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then

									job_call[playername][3] = job_call[playername][3]+1

									job_pos[playername] = {clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][1],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][2],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername][3] == #clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ] then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then
									local randomize = random(zp_player_sas*job_call[playername][3]/2,zp_player_sas*job_call[playername][3])

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили за маршрут "..randomize.."$", green)

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end

						end
					end
				end

			elseif job[playername] == 12 then--работа пожарный
				if vehicleid then
					if getElementModel(vehicleid) == 407 and (getElementModel(playerid) == 277 or getElementModel(playerid) == 278 or getElementModel(playerid) == 279) then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#fire_pos)

								sendMessage(playerid, "Езжайте на вызов", yellow)

								job_call[playername] = 1
								job_pos[playername] = {fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3]-1}

								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] >= 1 and job_call[playername] <= 59 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									if getControlState ( playerid, "vehicle_fire" ) then
										job_call[playername] = job_call[playername]+1
									end

									triggerClientEvent( playerid, "event_createFire", playerid, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40, 10, 1)
								end

							elseif job_call[playername] == 60 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = random(zp_player_fire/2,zp_player_fire)

									triggerClientEvent( playerid, "event_extinguishFire", playerid, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendMessage(playerid, "Вы получили за вызов "..randomize.."$", green)

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end

						end
					end
				end

			elseif job[playername] == 13 then--работа swat
				if (getElementModel(playerid) == 285) and search_inv_player_2_parameter(playerid, 10) ~= 0 then
					if job_call[playername] == 0 then
						local randomize = random(1,#fire_pos)

						--[[while true do
							if getZoneName ( fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3], true ) == "Los Santos" and "Los Santos" == getZoneName ( x,y,z, true ) then
								break
							elseif getZoneName ( fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3], true ) == "San Fierro" and "San Fierro" == getZoneName ( x,y,z, true ) then
								break
							elseif getZoneName ( fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3], true ) == "Las Venturas" and "Las Venturas" == getZoneName ( x,y,z, true ) then
								break
							else
								randomize = random(1,#fire_pos)
							end
						end]]

						sendMessage(playerid, "Езжайте на вызов", yellow)

						job_call[playername] = {1,0,random(5,30)--[[n секунд чтобы преступник подумал]]}
						job_pos[playername] = {fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3]-1}

						job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )

					elseif job_call[playername][1] >= 1 and job_call[playername][1] <= job_call[playername][3] then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

							if job_call[playername][1] == 1 then
								local randomize_skin = 1

								while true do
									local skin_table = getValidPedModels()
									local random1 = random(1,312)
									if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 then
										randomize_skin = skin_table[random1]
										break
									else
										random1 = random(1,#skin_table)
									end
								end

								job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3]+1, 0.0, true )

								add_ped_in_no_ped_damage(job_ped[playername])

								me_chat(playerid, playername.." взял мегафон")
								do_chat(playerid, "говорит в мегафон - "..playername)
								ic_chat(playerid, "Это полиция, положите оружие на землю и поднимите руки вверх")
							end

							job_call[playername][1] = job_call[playername][1]+1
						end

					elseif job_call[playername][1] == job_call[playername][3]+1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							local randomize = random(1,2)

							triggerClientEvent(playerid, "event_givePedWeapon", playerid, job_ped[playername], weapon[18][2], 1000, true)

							if randomize == 1 then
								sendMessage(playerid, "Преступник сдается", yellow)

								--setPedAnimation(job_ped[playername], "rob_bank", "shp_handsup_scr", -1, false, false, false, true)

								job_call[playername][1] = job_call[playername][3]+3
								job_call[playername][2] = randomize
							else
								sendMessage(playerid, "Устраните преступника", yellow)

								delet_ped_in_no_ped_damage(job_ped[playername])

								--setPedAnimation(job_ped[playername], "ped", "gang_gunstand", -1, false, false, false, true)

								triggerClientEvent(playerid, "event_setPedControlState", playerid, job_ped[playername], "fire", true)

								job_call[playername][1] = job_call[playername][3]+2
								job_call[playername][2] = randomize
							end
						end

					elseif job_call[playername][1] == job_call[playername][3]+2 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							triggerClientEvent(playerid, "event_setPedAimTarget", playerid, job_ped[playername], x, y, z)
						end

						function died()
							job_call[playername][1] = job_call[playername][3]+3
						end
						addEventHandler("onPedWasted", job_ped[playername], died)

					elseif job_call[playername][1] == job_call[playername][3]+3 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							local randomize = random(zp_player_police/2,zp_player_police)

							inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

							sendMessage(playerid, "Вы получили за вызов "..randomize.."$", green)

							delet_ped_in_no_ped_damage(job_ped[playername])

							destroyElement(job_blip[playername])
							destroyElement(job_ped[playername])

							job_blip[playername] = 0
							job_pos[playername] = 0
							job_call[playername] = 0
							job_ped[playername] = 0
						end
					end
				end

			elseif job[playername] == 14 then--работа фермер
				if getElementModel(playerid) == 158 then
					if ferm_etap == 1 then
						if job_call[playername] == 0 then

							job_call[playername] = 1
							job_pos[playername] = {-108.6884765625,-3.3505859375,3.1171875-1}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 1.0, yellow[1],yellow[2],yellow[3], 255, playerid )

						elseif job_call[playername] == 1 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(1,#grass_pos)

								job_call[playername] = 2

								job_pos[playername] = {grass_pos[randomize][2],grass_pos[randomize][3],grass_pos[randomize][4]+1.5}

								setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							end

						elseif job_call[playername] == 2 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(zp_player_ferm/2,zp_player_ferm)

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", green)

								setPedAnimation(playerid, "BOMBER", "BOM_Plant", -1, true, false, false, false)

								setTimer(function ()
									if isElement(playerid) then
										setPedAnimation(playerid, nil, nil)
									end
								end, (5*1000), 1)

								grass_pos_count = grass_pos_count+ferm_etap_count

								if grass_pos_count == #grass_pos then
									ferm_etap = 2
									grass_pos_count = 0

									for k,v in pairs(grass_pos) do
										setElementPosition(v[1], v[2],v[3],v[4]+0.2)
									end

									for _,i in pairs(getElementsByType("player")) do
										if job[getPlayerName(i)] == 14 then
											job_call[getPlayerName(i)] = 0

											local randomize = zp_player_ferm_etap

											inv_server_load( i, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

											sendMessage(i, "Вы получили премию "..randomize.."$", green)
										end
									end
								end

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
								job_marker[playername] = 0
							end
						end

					elseif ferm_etap == 2 then
						if job_call[playername] == 0 then

							job_call[playername] = 1
							job_pos[playername] = {-108.6884765625,-3.3505859375,3.1171875-1}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 1.0, yellow[1],yellow[2],yellow[3], 255, playerid )

						elseif job_call[playername] == 1 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(1,#grass_pos)

								job_call[playername] = 2

								job_pos[playername] = {grass_pos[randomize][2],grass_pos[randomize][3],grass_pos[randomize][4]+1.3}

								setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							end

						elseif job_call[playername] == 2 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(zp_player_ferm/2,zp_player_ferm)

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", green)

								object_attach(playerid, 321, 12, 0.15,0,0.3, 0,-90,0, (5*1000))

								setPedAnimation(playerid, "camera", "camstnd_idleloop", -1, true, false, false, false)

								setTimer(function ()
									if isElement(playerid) then
										setPedAnimation(playerid, nil, nil)
									end
								end, (5*1000), 1)

								grass_pos_count = grass_pos_count+ferm_etap_count

								if grass_pos_count == #grass_pos then
									ferm_etap = 3
									grass_pos_count = 0

									for k,v in pairs(grass_pos) do
										setElementPosition(v[1], v[2],v[3],v[4]+0.6)
									end

									for _,i in pairs(getElementsByType("player")) do
										if job[getPlayerName(i)] == 14 then
											job_call[getPlayerName(i)] = 0

											local randomize = zp_player_ferm_etap

											inv_server_load( i, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

											sendMessage(i, "Вы получили премию "..randomize.."$", green)
										end
									end
								end

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
								job_marker[playername] = 0
							end
						end

					elseif ferm_etap == 3 then
						if job_call[playername] == 0 then
							local randomize = random(1,#grass_pos)

							job_call[playername] = {1,randomize}
							job_pos[playername] = {grass_pos[randomize][2],grass_pos[randomize][3],grass_pos[randomize][4]}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 1.0, yellow[1],yellow[2],yellow[3], 255, playerid )

						elseif job_call[playername][1] == 1 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(1,#grass_pos)

								setPedAnimation(playerid, "rob_bank", "cat_safe_rob", -1, true, false, false, false)

								setTimer(function ()
									if isElement(playerid) then
										setPedAnimation(playerid, nil, nil)
									end
								end, (5*1000), 1)

								job_call[playername][1] = 2

								job_pos[playername] = {-108.6884765625,-3.3505859375,3.1171875-1}

								setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							end

						elseif job_call[playername][1] == 2 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(zp_player_ferm/2,zp_player_ferm)

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", green)

								grass_pos_count = grass_pos_count+ferm_etap_count

								if grass_pos_count == #grass_pos then
									ferm_etap = 1
									grass_pos_count = 0

									for k,v in pairs(grass_pos) do
										setElementPosition(v[1], v[2],v[3],v[4]-1.5)
									end

									for _,i in pairs(getElementsByType("player")) do
										if job[getPlayerName(i)] == 14 then
											job_call[getPlayerName(i)] = 0

											local randomize = zp_player_ferm_etap

											inv_server_load( i, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

											sendMessage(i, "Вы получили премию "..randomize.."$", green)
										end
									end
								end

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
								job_marker[playername] = 0
							end
						end
					end
				end

			elseif job[playername] == 15 then--работа охотник
				if (getElementModel(playerid) == 312) then
					if job_call[playername] == 0 then
						local bamby_pos = getElementData(playerid, "BambyPosition")
						local randomize = random(1,#bamby_pos.X)

						sendMessage(playerid, "Найдите оленя", yellow)

						job_call[playername] = 1
						job_pos[playername] = {bamby_pos.X[randomize],bamby_pos.Y[randomize],bamby_pos.Z[randomize]+0.5}

						job_ped[playername] = createPed ( 264, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0.0, true )
						setElementFrozen(job_ped[playername], true)
						setPedAnimation(job_ped[playername], "crack", "crckidle4", -1, true, false, false, false)
						add_ped_in_no_ped_damage(job_ped[playername])

					elseif job_call[playername] == 1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							sendMessage(playerid, "Убейте оленя", yellow)

							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3]-1.5, "cylinder", 1.0, yellow[1],yellow[2],yellow[3], 255, playerid )
						
							delet_ped_in_no_ped_damage(job_ped[playername])

							job_call[playername] = 2
						end

					elseif job_call[playername] == 2 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) and isPedDead ( job_ped[playername] ) then
							local randomize = random(zp_player_bamby/2,zp_player_bamby)

							give_subject(playerid, "player", down_player_subject[5][5], randomize)

							destroyElement(job_ped[playername])
							destroyElement(job_marker[playername])

							job_ped[playername] = 0
							job_pos[playername] = 0
							job_call[playername] = 0
							job_marker[playername] = 0
						end
					end
				end

			elseif job[playername] == 16 then--работа развозчик пиццы
				if vehicleid then
					if getElementModel(vehicleid) == up_car_subject[6][6] and getElementModel(playerid) == 155 then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#house_pos)

								sendMessage(playerid, "Езжайте к пиццерии в гетто чтобы загрузить пиццу, а потом развезите их по домам", yellow)

								job_call[playername] = 1
								job_pos[playername] = {house_pos[randomize][1],house_pos[randomize][2],house_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 4, yellow[1],yellow[2],yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, yellow[1],yellow[2],yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) and amount_inv_car_1_parameter(vehicleid, up_car_subject[6][5]) ~= 0 then
									local randomize = random(1,#house_pos)
									local sic2p = search_inv_car_2_parameter(vehicleid, up_car_subject[6][5])

									job_pos[playername] = {house_pos[randomize][1],house_pos[randomize][2],house_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])

									inv_car_delet(playerid, up_car_subject[6][5], sic2p, true, false)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+sic2p, playername )

									sendMessage(playerid, "Вы получили "..sic2p.."$", green)
								end
							end

						end
					end
				end

			elseif job[playername] == 17 then--работа умд
				if (getElementModel(playerid) == 311) then
					if job_call[playername] == 0 then
						local box_pos = {random(-3000,3000), random(-4000,-3000), -68,9}

						sendMessage(playerid, "Соберите потерянный груз, потом доставьте его к NPC в доки Лос Сантоса", yellow)

						job_call[playername] = 1
						job_pos[playername] = {box_pos[1],box_pos[2],box_pos[3]-1}

						job_object[playername] = createObject(3798, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0,0,0)
						
					elseif job_call[playername] == 1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then
							local randomize = random(zp_player_box/2,zp_player_box)
							local box_pos = {random(-3000,3000), random(-4000,-3000), -68,9}

							job_pos[playername] = {box_pos[1],box_pos[2],box_pos[3]-1}

							give_subject(playerid, "player", down_player_subject[7][5], randomize)

							setElementPosition(job_object[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
						end
					end
				end

			elseif job[playername] == 0 then--нету рыботы
				job_0( playername )
			end
		end
	end
end

function job_0( playername )
	if job_ped[playername] ~= 0 then
		destroyElement(job_ped[playername])

		delet_ped_in_no_ped_damage(job_ped[playername])
	end

	if job_blip[playername] ~= 0 then
		destroyElement(job_blip[playername])
	end

	if job_marker[playername] ~= 0 then
		destroyElement(job_marker[playername])
	end

	if job_object[playername] ~= 0 then
		destroyElement(job_object[playername])
	end

	job[playername] = 0
	job_pos[playername] = 0
	job_call[playername] = 0

	job_ped[playername] = 0
	job_blip[playername] = 0
	job_marker[playername] = 0
	job_object[playername] = 0
end

function car_theft_fun(playername)

	if(job_vehicleid[playername] ~= 0) then

		for k,v in pairs(getElementsByType("player")) do
		
			if(getPlayerVehicle(v) == job_vehicleid[playername][1]) then
			
				removePedFromVehicle(v)
			end
		end

		setTimer(function() 
			setElementPosition(job_vehicleid[playername][1],job_vehicleid[playername][2],job_vehicleid[playername][3],job_vehicleid[playername][4])
			setElementRotation(job_vehicleid[playername][1], 0,0,job_vehicleid[playername][5])

			local plate = getVehiclePlateText(job_vehicleid[playername][1])
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
			if (result[1]["COUNT()"] == 1) then
			
				sqlite( "UPDATE car_db SET x = '"..job_vehicleid[playername][2].."', y = '"..job_vehicleid[playername][3].."', z = '"..job_vehicleid[playername][4].."', rot = '"..job_vehicleid[playername][5].."', fuel = '"..fuel[plate].."', probeg = '"..probeg[plate].."' WHERE number = '"..plate.."'")
			end

			job_vehicleid[playername] = 0
			job_call[playername] = 0
		end, 1000, 1)

		if(isTimer(job_timer[playername])) then
		
			killTimer(job_timer[playername])
		end

		job_timer[playername] = 0

		if job_blip[playername] ~= 0 then
			destroyElement(job_blip[playername])
		end

		if job_marker[playername] ~= 0 then
			destroyElement(job_marker[playername])
		end

		job_blip[playername] = 0
		job_marker[playername] = 0
	end
end

function player_car_theft()
	local vehicleid = random(1,#getElementsByType("vehicle"))

	for k,v in pairs(getElementsByType("vehicle")) do
		if vehicleid == k then
			vehicleid = v
			break
		end
	end

	while (true) do
	
		if(getVehicleType(vehicleid) == "Automobile" or getVehicleType(vehicleid) == "Bike" or getVehicleType(vehicleid) == "Monster Truck" or getVehicleType(vehicleid) == "Quad") then
		
			return vehicleid
		
		else 
		
			vehicleid = random(1,#getElementsByType("vehicle"))

			for k,v in pairs(getElementsByType("vehicle")) do
				if vehicleid == k then
					vehicleid = v
					break
				end
			end
		end
	end
end

function player_in_car_theft(plate) 

	local count = 0

	for k,v in pairs(getElementsByType("player")) do
		local playername = getPlayerName(v)
		if(job_vehicleid[playername] ~= 0) then
		
			if( getVehiclePlateText(job_vehicleid[playername][1]) == plate ) then
			
				count = count+1
			end
		end
	end

	return count
end

function need_1 ()
	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)

		if logged[playername] == 1 then
			local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

			--нужды
			if hygiene[playername] == 0 and getElementModel(playerid) ~= 230 then
				setElementModel(playerid, 230)
			elseif hygiene[playername] > 0 and getElementModel(playerid) ~= result[1]["skin"] then
				setElementModel(playerid, result[1]["skin"])
			end
		end
	end
end

function need()--нужды
	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)

		if logged[playername] == 1 then
			if alcohol[playername] == 500 then
				local hygiene_minys = 25

				setElementHealth( playerid, getElementHealth(playerid)-100 )

				sendMessage(playerid, "-100 хп", yellow)

				if hygiene[playername]-hygiene_minys >= 0 then
					hygiene[playername] = hygiene[playername]-hygiene_minys
					sendMessage(playerid, "-"..hygiene_minys.." ед. чистоплотности", yellow)
				end

				me_chat(playerid, playername.." стошнило")

				setPedAnimation(playerid, "food", "eat_vomit_p", -1, false, false, false, false)
			end


			if drugs[playername] == 100 then
				setElementHealth( playerid, getElementHealth(playerid)-200 )
				sendMessage(playerid, "-200 хп", yellow)
			end


			if alcohol[playername] ~= 0 then
				alcohol[playername] = alcohol[playername]-10
			end


			if drugs[playername]-0.1 >= 0 then
				drugs[playername] = drugs[playername]-0.1
			else
				drugs[playername] = 0
			end


			if satiety[playername] == 0 then
				setElementHealth( playerid, getElementHealth(playerid)-1 )
			else
				satiety[playername] = satiety[playername]-1
			end


			if hygiene[playername] == 0 then

			else
				hygiene[playername] = hygiene[playername]-1
			end


			if sleep[playername] == 0 then
				setElementHealth( playerid, getElementHealth(playerid)-1 )
			else
				sleep[playername] = sleep[playername]-1
			end
		end
	end
end

function fuel_down()--система топлива авто
	for k,vehicleid in pairs(getElementsByType("vehicle")) do
		local plate = getVehiclePlateText(vehicleid)
		local engine = getVehicleEngineState ( vehicleid )
		local fuel_down_number = 0.0002

		if engine then
			if fuel[plate] <= 0 then
				setVehicleEngineState ( vehicleid, false )
			else
				if getSpeed(vehicleid) == 0 then
					fuel[plate] = fuel[plate] - fuel_down_number
				else
					fuel[plate] = fuel[plate] - (fuel_down_number*getSpeed(vehicleid))
					probeg[plate] = probeg[plate] + (getSpeed(vehicleid)/3600)
				end
			end
		end
	end
end

function timer_earth_clear()--очистка земли
	local hour, minute = getTime()

	if hour == 0 and earth_true then
		local count_earth = 0

		for i,v in pairs(earth) do
			count_earth = count_earth+1
		end

		print("[timer_earth_clear] max_earth "..max_earth..", count_earth "..count_earth)

		earth = {}
		max_earth = 0

		for k,playerid in pairs(getElementsByType("player")) do
			sendMessage(playerid, "[НОВОСТИ] Улицы очищенны от мусора", green)
		end
	end
end

function prison_timer()--античит если не в тюрьме
	for i,playerid in pairs(getElementsByType("player")) do
		local count = 0
		local playername = getPlayerName(playerid)
		local x,y,z = getElementPosition(playerid)

		if arrest[playername] ~= 0 then
			for k,v in pairs(prison_cell) do
				if not isPointInCircle3D(x,y,z, v[4],v[5],v[6], 5) then
					count = count+1
				end
			end

			if count == #prison_cell then
				local randomize = random(1,#prison_cell)

				if getPlayerVehicle(playerid) then
					removePedFromVehicle(playerid)
				end

				triggerClientEvent( playerid, "event_inv_delet", playerid )
				state_inv_player[playername] = 0

				triggerClientEvent( playerid, "event_gui_delet", playerid )
				state_gui_window[playername] = 0

				enter_house[playername] = {0,0}
				enter_business[playername] = 0
				enter_job[playername] = 0

				takeAllWeapons ( playerid )
				job_0(playername)
				car_theft_fun(playername)
				robbery_kill( playername )

				setElementDimension(playerid, prison_cell[randomize][2])
				setElementInterior(playerid, 0)
				setElementInterior(playerid, prison_cell[randomize][1], prison_cell[randomize][4], prison_cell[randomize][5], prison_cell[randomize][6])
			end
		end
	end
end

function prison()--таймер заключения
	for i,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)

		if arrest[playername] == 1 then
			if crimes[playername] == 1 then
				arrest[playername] = 0
				crimes[playername] = 0

				local randomize = random(2,4)

				setElementDimension(playerid, 0)
				setElementInterior(playerid, 0, interior_job[randomize][6], interior_job[randomize][7], interior_job[randomize][8])

				sendMessage(playerid, "Вы свободны, больше не нарушайте", yellow)

			elseif crimes[playername] > 1 then
				crimes[playername] = crimes[playername]-1

				sendMessage(playerid, "Вам сидеть ещё "..(crimes[playername]).." мин", yellow)
			end

		elseif arrest[playername] == 2 then
			if array_player_2[playername][25] == 1 then
				arrest[playername] = 0

				local randomize = random(2,4)

				setElementDimension(playerid, 0)
				setElementInterior(playerid, 0, interior_job[randomize][6], interior_job[randomize][7], interior_job[randomize][8])

				sendMessage(playerid, "Вы свободны, больше не нарушайте", yellow)

				inv_server_load(playerid, "player", 24, 0, 0, playername)

			elseif array_player_2[playername][25] > 1 then
				array_player_2[playername][25] = array_player_2[playername][25]-1

				sendMessage(playerid, "Вам сидеть ещё "..array_player_2[playername][25].." мин", yellow)

				inv_server_load(playerid, "player", 24, 92, array_player_2[playername][25], playername)
			end
		end
	end
end

function pay_nalog()
	local time = getRealTime()

	if time["hour"] == time_nalog then
		local result = sqlite( "SELECT * FROM car_db" )
		for k,v in pairs(result) do
			if v["nalog"] > 0 then
				sqlite( "UPDATE car_db SET nalog = nalog - '1' WHERE number = '"..v["number"].."'")
			end
		end

		local result = sqlite( "SELECT * FROM house_db" )
		for k,v in pairs(result) do
			if v["nalog"] > 0 then
				sqlite( "UPDATE house_db SET nalog = nalog - '1' WHERE number = '"..v["number"].."'")
			end
		end

		local result = sqlite( "SELECT * FROM business_db" )
		for k,v in pairs(result) do
			if v["nalog"] > 0 then
				sqlite( "UPDATE business_db SET nalog = nalog - '1' WHERE number = '"..v["number"].."'")
			end
		end

		local result = sqlite( "SELECT * FROM cow_farms_db" )
		for k,v in pairs(result) do
			if v["nalog"] > 0 then
				sqlite( "UPDATE cow_farms_db SET nalog = nalog - '1' WHERE number = '"..v["number"].."'")
			end
		end

		print("[pay_nalog]")
	end
end

function onChat(message, messageType)
	local playerid = source
	local playername = getPlayerName(playerid)

	cancelEvent()

	if logged[playername] == 0 or arrest[playername] ~= 0 then
		return
	end

	if messageType ~= 1 then
		local count = 0
		local say = "(Всем OOC) "..getPlayerName( playerid ).." ["..getElementData(playerid, "player_id")[1].."]: " .. message
		local say_10_r = "(Ближний IC) "..getPlayerName( playerid ).." ["..getElementData(playerid, "player_id")[1].."]: " .. message

		for k,player in pairs(getElementsByType("player")) do
			local x,y,z = getElementPosition(playerid)
			local x1,y1,z1 = getElementPosition(player)
			local player_name = getPlayerName(player)

			if(logged[player_name] == 1 and isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) and player ~= playerid) then
			
				count = count + 1
			end
		end
		
		if (count == 0) then
		
			sendMessage( getRootElement(), say, gray )

			print("[CHAT] "..say)
		
		else 
		
			ic_chat( playerid, say_10_r )
			print("[CHAT] "..say_10_r)
		end

	else 
		me_chat_player(playerid, playername.." "..message)
	end
end
addEventHandler("onPlayerChat", getRootElement(), onChat)

addEventHandler("onPlayerCommand",getRootElement(),
function(command)
	local playerid = source
	local playername = getPlayerName(playerid)

	if command == "msg" then
		cancelEvent()
	end
end)

function load_inv(val, value, text)
	if value == "player" then
		for k,v in pairs(split(text, ",")) do
			local spl = split(v, ":")
			array_player_1[val][k] = tonumber(spl[1])
			array_player_2[val][k] = tonumber(spl[2])
		end
	elseif value == "car" then
		for k,v in pairs(split(text, ",")) do
			local spl = split(v, ":")
			array_car_1[val][k] = tonumber(spl[1])
			array_car_2[val][k] = tonumber(spl[2])
		end
	elseif value == "house" then
		for k,v in pairs(split(text, ",")) do
			local spl = split(v, ":")
			array_house_1[val][k] = tonumber(spl[1])
			array_house_2[val][k] = tonumber(spl[2])
		end
	end
end

function save_inv(val, value)
	if value == "player" then
		local text = ""
		for i=0,max_inv+1 do
			text = text..array_player_1[val][i+1]..":"..array_player_2[val][i+1]..","
		end
		return text
	elseif value == "car" then
		local text = ""
		for i=0,max_inv do
			text = text..array_car_1[val][i+1]..":"..array_car_2[val][i+1]..","
		end
		return text
	elseif value == "house" then
		local text = ""
		for i=0,max_inv do
			text = text..array_house_1[val][i+1]..":"..array_house_2[val][i+1]..","
		end
		return text
	end
end

---------------------------------------игрок------------------------------------------------------------
function search_inv_player( playerid, id1, id2 )--цикл по поиску предмета в инв-ре игрока
	local playername = getPlayerName ( playerid )
	local val = 0

	for i=0,max_inv do
		if array_player_1[playername][i+1] == id1 and array_player_2[playername][i+1] == id2 then
			val = val + 1
		end
	end

	return val
end

function search_inv_player_police( playerid, id )--цикл по выводу предметов
	local playername = getPlayerName ( playerid )

	for i=1,max_inv do
		if array_player_1[id][i+1] ~= 0 then
			do_chat(playerid, info_png[ array_player_1[id][i+1] ][1].." "..array_player_2[id][i+1].." "..info_png[ array_player_1[id][i+1] ][2].." - "..playername)
		end
	end
end

function search_inv_player_2_parameter(playerid, id1)--вывод 2 параметра предмета в инв-ре игрока
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == id1 then
			return array_player_2[playername][i+1]
		end
	end

	return 0
end

function amount_inv_player_1_parameter(playerid, id1)--выводит коли-во предметов
	local playername = getPlayerName ( playerid )
	local val = 0

	for i=0,max_inv do
		if (array_player_1[playername][i+1] == id1) then
		
			val = val + 1
		end
	end

	return val
end

function amount_inv_player_2_parameter(playerid, id1)--выводит сумму всех 2-ых параметров предмета
	local playername = getPlayerName ( playerid )
	local val = 0

	for i=0,max_inv do
		if (array_player_1[playername][i+1] == id1) then
		
			val = val + array_player_2[playername][i+1]
		end
	end

	return val
end

function inv_player_empty(playerid, id1, id2)--выдача предмета игроку
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			inv_server_load( playerid, "player", i, id1, id2, playername )

			return true
		end
	end

	return false
end

function inv_player_delet(playerid, id1, id2, delet_inv)--удаления предмета игрока
	local playername = getPlayerName ( playerid )

	if delet_inv then
		triggerClientEvent( playerid, "event_inv_delet", playerid )
		state_inv_player[playername] = 0
	end

	for i=0,max_inv do
		if array_player_1[playername][i+1] == id1 and array_player_2[playername][i+1] == id2 then
			inv_server_load( playerid, "player", i, 0, 0, playername )

			return true
		end
	end

	return false
end

function robbery(playerid, zakon, money, x1,y1,z1, radius, text)
	local playername = getPlayerName ( playerid )

	if isElement ( playerid ) then
		if robbery_player[playername] == 1 then
			local x,y,z = getElementPosition(playerid)
			local crimes_plus = zakon
			local cash = random(money/2,money)

			if isPointInCircle3D(x1,y1,z1, x,y,z, radius) then
				crimes[playername] = crimes[playername]+crimes_plus
				sendMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername], blue)

				sendMessage(playerid, "Вы унесли "..cash.."$", green )

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+cash, playername )
			else
				sendMessage(playerid, "[ERROR] Вы покинули место ограбления", red)
			end

			robbery_kill( playername )
		end
	end
end

function robbery_kill( playername )
	if robbery_player[playername] == 1 then
		robbery_player[playername] = 0

		if isTimer(robbery_timer[playername]) then
			killTimer(robbery_timer[playername])
		end

		robbery_timer[playername] = 0
	end
end

function select_sqlite(id1, id2)--выводит имя владельца любого предмета
	for k,result in pairs(sqlite( "SELECT * FROM account" )) do
		for k,v in pairs(split(result["inventory"], ",")) do
			local spl = split(v, ":")
			if tonumber(spl[1]) == id1 and tonumber(spl[2]) == id2 then
				return result["name"]
			end
		end
	end

	return false
end

function player_hotel (playerid, id)
	local playername = getPlayerName(playerid)

	if ((price_hotel) <= array_player_2[playername][1]) then

		local sleep_hygiene_plus = 100

		if (id == 55) then

			hygiene[playername] = sleep_hygiene_plus
			sendMessage(playerid, "+"..sleep_hygiene_plus.." ед. чистоплотности", yellow)
			me_chat(playerid, playername.." помылся(ась)")

		elseif (id == 56) then

			sleep[playername] = sleep_hygiene_plus
			sendMessage(playerid, "+"..sleep_hygiene_plus.." ед. сна", yellow)
			me_chat(playerid, playername.." вздремнул(а)")
		end

		sendMessage(playerid, "Вы заплатили "..(price_hotel).."$", orange )

		inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(price_hotel), playerid )
					
		return true

	else 

		sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
		return false
	end
end

function random_sub (playerid, id)--выпадение предметов

	local random_sub_array = {
		{69, { {82,1,20} }},
		{48, { {90,3,20} }},
	}

	local playername = getPlayerName ( playerid )
	local randomize1 = -1
	local randomize2 = random(1,100)
	for k,v in pairs(random_sub_array) do
		if (id == v[1]) then
		
			randomize1 = random(1,#v[2])
			if (randomize2 <= v[2][randomize1][3]) then
			
				local id1 = v[2][randomize1][1]
				local id2 = v[2][randomize1][2]
				if (inv_player_empty(playerid, id1, id2)) then
				
					sendMessage(playerid, "Вы получили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], svetlo_zolotoy)
				end
			end
			break
		end
	end
end

function getPlayerId( id )--узнать имя игрока из ид
	for k,player in pairs(getElementsByType("player")) do
		if getElementData(player, "player_id")[1] == tonumber(id) then
			return getPlayerName(player), player
		end
	end

	return false
end

function points_add_in_gz(playerid, value) 

	local x,y,z = getElementPosition(playerid)

	for k,v in pairs(guns_zone) do
		if(isInsideRadarArea (v[1], x,y) and k == point_guns_zone[2]) then
		
			if (search_inv_player_2_parameter(playerid, 85) ~= 0 and search_inv_player_2_parameter(playerid, 85) == point_guns_zone[3]) then
			
				point_guns_zone[4] = point_guns_zone[4]+1*value
			
			elseif(search_inv_player_2_parameter(playerid, 85) ~= 0 and search_inv_player_2_parameter(playerid, 85) == point_guns_zone[5]) then
			
				point_guns_zone[6] = point_guns_zone[6]+1*value
			end
		end
	end
end

function setPlayerNametagColor_fun( playerid )
	if (search_inv_player_2_parameter(playerid, 44) ~= 0) then
		setPlayerNametagColor(playerid, lyme[1],lyme[2],lyme[3])
		setElementData(playerid, "admin_data", search_inv_player_2_parameter(playerid, 44))
		return
	elseif (search_inv_player(playerid, 45, 1) ~= 0) then
		setPlayerNametagColor(playerid, green[1],green[2],green[3])
	elseif (search_inv_player_2_parameter(playerid, 10) ~= 0) then
		setPlayerNametagColor(playerid, blue[1],blue[2],blue[3])
	elseif (search_inv_player_2_parameter(playerid, 85) ~= 0) then
		setPlayerNametagColor(playerid, name_mafia[search_inv_player_2_parameter(playerid, 85)][2][1],name_mafia[search_inv_player_2_parameter(playerid, 85)][2][2],name_mafia[search_inv_player_2_parameter(playerid, 85)][2][3])
	else 
		setPlayerNametagColor(playerid, white[1],white[2],white[3])
	end

	setElementData(playerid, "admin_data", search_inv_player_2_parameter(playerid, 44))
end

function quest_player(playerid, id)
	local playername = getPlayerName(playerid)

	if getElementData(playerid, "quest_select") ~= "0:0" then
		local spl = split(getElementData(playerid, "quest_select"), ":")
		local quest = tonumber(spl[1])
		local quest_progress = tonumber(spl[2])

		if 1 <= quest and quest <= 2 then
			if id == quest_table[quest][5] then
				quest_progress = quest_progress+1
				setElementData(playerid, "quest_select", quest..":"..quest_progress)
			end
			
			if quest_table[quest][3] == quest_progress then
				if quest_table[quest][7][1] ~= 0 then
					if not inv_player_empty(playerid, quest_table[quest][7][1], quest_table[quest][7][2]) then
						sendMessage(playerid, "[ERROR] Для завершения квеста освободите инвентарь", red)
						return
					else
						sendMessage(playerid, "[QUEST] Вы получили "..info_png[quest_table[quest][7][1]][1].." "..quest_table[quest][7][2].." "..info_png[quest_table[quest][7][1]][2], svetlo_zolotoy)
					end
				end

				setElementData(playerid, "quest_select", "0:0")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+quest_table[quest][6], playername )

				sendMessage(playerid, "[QUEST] Вы получили "..quest_table[quest][6].."$", green)

				table.insert(quest_table[quest][8], playername)
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------

---------------------------------------авто-------------------------------------------------------------
function search_inv_car( vehicleid, id1, id2 )--цикл по поиску предмета в инв-ре авто
	local val = 0
	local plate = getVehiclePlateText ( vehicleid )

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
			val = val + 1
		end
	end

	return val
end

function search_inv_car_police( playerid, id )--цикл по выводу предметов
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_car_1[id][i+1] ~= 0 then
			do_chat(playerid, info_png[ array_car_1[id][i+1] ][1].." "..array_car_2[id][i+1].." "..info_png[ array_car_1[id][i+1] ][2].." - "..playername)
		end
	end
end

function search_inv_car_2_parameter(vehicleid, id1)--вывод 2 параметра предмета в авто
	local plate = getVehiclePlateText ( vehicleid )

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 then
			return array_car_2[plate][i+1]
		end
	end

	return 0
end

function amount_inv_car_1_parameter(vehicleid, id1)--выводит коли-во предметов

	local plate = getVehiclePlateText ( vehicleid )
	local val = 0

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 then
			val = val + 1
		end
	end

	return val
end

function amount_inv_car_2_parameter(vehicleid, id1)--выводит сумму всех 2-ых параметров предмета

	local plate = getVehiclePlateText ( vehicleid )
	local val = 0

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 then
			val = val + array_car_2[plate][i+1]
		end
	end

	return val
end

function inv_car_empty(playerid, id1, id2, load_value)--выдача предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local plate = getVehiclePlateText ( vehicleid )
	local count = 0

	if load_value then
		for i=0,max_inv do
			if array_car_1[plate][i+1] == 0 then
				array_car_1[plate][i+1] = id1
				array_car_2[plate][i+1] = id2

				count = count+1

				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )

				if state_inv_player[playername] == 1 then
					triggerClientEvent( playerid, "event_change_image", playerid, "car", i, array_car_1[plate][i+1] )
				end
			end
		end
	else
		for i=0,max_inv do
			if array_car_1[plate][i+1] == 0 then
				array_car_1[plate][i+1] = id1
				array_car_2[plate][i+1] = id2

				count = count+1

				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )

				if state_inv_player[playername] == 1 then
					triggerClientEvent( playerid, "event_change_image", playerid, "car", i, array_car_1[plate][i+1] )
				end
				break
			end
		end
	end

	if (count ~= 0) then
	
		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
		if (result[1]["COUNT()"] == 1) then
		
			sqlite( "UPDATE car_db SET inventory = '"..save_inv(plate, "car").."' WHERE number = '"..plate.."'")
		end
	end

	return count
end

function inv_car_delet(playerid, id1, id2, delet_inv, unload_value)--удаления предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local plate = getVehiclePlateText ( vehicleid )

	if delet_inv then
		triggerClientEvent( playerid, "event_inv_delet", playerid )
		state_inv_player[playername] = 0
	end

	if unload_value then
		for i=0,max_inv do
			if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
				array_car_1[plate][i+1] = 0
				array_car_2[plate][i+1] = 0

				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )
			end
		end
	else
		for i=0,max_inv do
			if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
				array_car_1[plate][i+1] = 0
				array_car_2[plate][i+1] = 0

				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )
				break
			end
		end
	end

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
	if (result[1]["COUNT()"] == 1) then
		sqlite( "UPDATE car_db SET inventory = '"..save_inv(plate, "car").."' WHERE number = '"..plate.."'")
	end
end

function inv_car_delet_1_parameter(playerid, id1, delet_inv)--удаление всех предметов по ид
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local plate = getVehiclePlateText ( vehicleid )

	if delet_inv then
		triggerClientEvent( playerid, "event_inv_delet", playerid )
		state_inv_player[playername] = 0
	end

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 then
			array_car_1[plate][i+1] = 0
			array_car_2[plate][i+1] = 0

			triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )
		end
	end

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
	if (result[1]["COUNT()"] == 1) then
		sqlite( "UPDATE car_db SET inventory = '"..save_inv(plate, "car").."' WHERE number = '"..plate.."'")
	end
end

function inv_car_throw_earth(vehicleid, id1, id2)--выброс предмета из авто на землю
	local plate = getVehiclePlateText ( vehicleid )
	local x,y,z = getElementPosition(vehicleid)
	local count = 0

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
			array_car_1[plate][i+1] = 0
			array_car_2[plate][i+1] = 0

			count = count+1

			max_earth = max_earth+1
			earth[max_earth] = {x,y,z,id1,id2}
		end
	end

	if count ~= 0 then
		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET inventory = '"..save_inv(plate, "car").."' WHERE number = '"..plate.."'")
		end
	end
end

function setVehicleDoorOpenRatio_fun(playerid, value)--открывает багажник
	local vehicleid = getPlayerVehicle(playerid)
	if vehicleid then
		setVehicleDoorOpenRatio ( vehicleid, 1, value )
	end
end
addEvent("event_setVehicleDoorOpenRatio_fun", true)
addEventHandler("event_setVehicleDoorOpenRatio_fun", getRootElement(), setVehicleDoorOpenRatio_fun)
--------------------------------------------------------------------------------------------------------

---------------------------------------дом-------------------------------------------------------------
function search_inv_house( house, id1, id2 )--цикл по поиску предмета в инв-ре
	local val = 0

	for i=0,max_inv do
		if array_house_1[house][i+1] == id1 and array_house_2[house][i+1] == id2 then
			val = val + 1
		end
	end

	return val
end

function search_inv_house_police( playerid, id )--цикл по выводу предметов
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_house_1[id][i+1] ~= 0 then
			do_chat(playerid, info_png[ array_house_1[id][i+1] ][1].." "..array_house_2[id][i+1].." "..info_png[ array_house_1[id][i+1] ][2].." - "..playername)
		end
	end
end

function search_inv_house_2_parameter(house, id1)--вывод 2 параметра предмета

	for i=0,max_inv do
		if array_house_1[house][i+1] == id1 then
			return array_house_2[house][i+1]
		end
	end

	return 0
end

function amount_inv_house_1_parameter(house, id1)--выводит коли-во предметов

	local val = 0

	for i=0,max_inv do
		if array_house_1[house][i+1] == id1 then
			val = val + 1
		end
	end

	return val
end

function amount_inv_house_2_parameter(house, id1)--выводит сумму всех 2-ых параметров предмета

	local val = 0

	for i=0,max_inv do
		if array_house_1[house][i+1] == id1 then
			val = val + array_house_2[house][i+1]
		end
	end

	return val
end
--------------------------------------------------------------------------------------------------------

function info_bisiness( number )
	local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
	return "[business "..number..", type "..result[1]["type"]..", price "..result[1]["price"]..", money "..result[1]["money"]..", warehouse "..result[1]["warehouse"].."]"
end

function pickupUse( playerid )
	local pickup = source
	local x,y,z = getElementPosition(playerid)
	local px,py,pz = getElementPosition(pickup)

	if getElementModel(pickup) == business_icon then
		for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
			if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
				sendMessage(playerid, " ", yellow)

				local s_sql = select_sqlite(43, v["number"])
				if s_sql then
					sendMessage(playerid, "Владелец бизнеса "..s_sql, yellow)
				else
					sendMessage(playerid, "Владелец бизнеса нету", yellow)
				end

				sendMessage(playerid, "Тип "..v["type"], yellow)
				sendMessage(playerid, "Товаров на складе "..v["warehouse"].." шт", yellow)
				sendMessage(playerid, "Стоимость товара (надбавка в N раз) "..v["price"].."$", green)
				--sendMessage(playerid, "Цена закупки товара "..v["buyprod"].."$", green)

				if search_inv_player(playerid, 43, v["number"]) ~= 0 then
					sendMessage(playerid, "Состояние кассы "..split(v["money"],".")[1].."$", green)
					sendMessage(playerid, "Налог бизнеса оплачен на "..v["nalog"].." дней", yellow)
				end
				return
			end
		end

	elseif getElementModel(pickup) == house_icon then
		for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
				sendMessage(playerid, " ", yellow)

				local s_sql = select_sqlite(25, v["number"])
				if s_sql then
					sendMessage(playerid, "Владелец дома "..s_sql, yellow)
				else
					sendMessage(playerid, "Владелец дома нету", yellow)
				end

				if search_inv_player(playerid, 25, v["number"]) ~= 0 then
					sendMessage(playerid, "Налог дома оплачен на "..v["nalog"].." дней", yellow)
				end
				return
			end
		end

	elseif getElementModel(pickup) == job_icon then
		for k,v in pairs(interior_job) do 
			if isPointInCircle3D(v[6],v[7],v[8], x,y,z, v[12]) then
				sendMessage(playerid, " ", yellow)
				sendMessage(playerid, v[2], yellow)
				return
			end
		end
	end
end
addEventHandler( "onPickupUse", getRootElement(), pickupUse )

function pickedUpWeaponCheck( playerid )
	local pickup = source

    for k,v in pairs(interior_job_pickup) do
    	if pickup == v[1] then
    		setElementPosition(playerid, v[2],v[3],v[4])
    		break
    	end
    end
end
addEventHandler( "onPickupHit", getRootElement(), pickedUpWeaponCheck )

function sqlite_load(playerid, value)
	if value == "cow_farms_table1" then
		local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, 86).."'" )
		if result[1] then
			local farms = {
				{result[1]["number"], "Зарплата", result[1]["price"].."$"},
				{result[1]["number"], "Баланс", split(result[1]["money"],".")[1].."$"},
				{result[1]["number"], "Доход от продаж", result[1]["coef"].." процентов"},
				{result[1]["number"], "Налог", result[1]["nalog"].." дней"},
				{result[1]["number"], "Склад", result[1]["warehouse"].." тушек"},
				{result[1]["number"], "Склад", result[1]["prod"].." мешков с кормом"},
			}
			
			setElementData(playerid, "cow_farms_table1", farms)
		end

	elseif value == "quest_table" then
		setElementData(playerid, "quest_table", quest_table)

	elseif value == "auc" then
		local result = sqlite( "SELECT * FROM auction" )
		setElementData(playerid, "auc", result)

	elseif value == "carparking_table" then
		local result_car = sqlite( "SELECT * FROM car_db WHERE nalog = '0'" )
		setElementData(playerid, "carparking_table", result_car)

	elseif value == "cow_farms_table2" then
		local result_cow_farms = sqlite( "SELECT * FROM cow_farms_db" )
		setElementData(playerid, "cow_farms_table2", result_cow_farms)

	elseif value == "account_db" then
		local result = sqlite( "SELECT * FROM account" )
		setElementData(playerid, "account_db", result)

	elseif value == "house_db" then
		local result = sqlite( "SELECT * FROM house_db" )
		setElementData(playerid, "house_db", result)

	elseif value == "business_db" then
		local result = sqlite( "SELECT * FROM business_db" )
		setElementData(playerid, "business_db", result)

	elseif value == "car_db" then
		local result = sqlite( "SELECT * FROM car_db" )
		setElementData(playerid, "car_db", result)

	elseif value == "cow_farms_db" then
		local result = sqlite( "SELECT * FROM cow_farms_db" )
		setElementData(playerid, "cow_farms_db", result)
	end
end
addEvent("event_sqlite_load", true)
addEventHandler("event_sqlite_load", getRootElement(), sqlite_load)

function auction_buy_sell(playerid, value, i, id1, id2, money, name_buy)--продажа покупка вещей
	local playername = getPlayerName ( playerid )
	local randomize = random(1,99999)
	local count = 0

	if value == "sell" then
		if inv_player_delet(playerid, id1, id2) then
			while (true) do
				local result = sqlite( "SELECT COUNT() FROM auction WHERE i = '"..randomize.."'" )
				if result[1]["COUNT()"] == 0 then
					break
				else
					randomize = random(1,99999)
				end
			end

			sendMessage(playerid, "Вы выставили на аукцион "..info_png[id1][1].." "..id2.." "..info_png[id1][2].." за "..money.."$", green)

			sqlite( "INSERT INTO auction (i, name_sell, id1, id2, money, name_buy) VALUES ('"..randomize.."', '"..playername.."', '"..id1.."', '"..id2.."', '"..money.."', '"..name_buy.."')" )
		else
			sendMessage(playerid, "[ERROR] У вас нет такого предмета", red)
		end

	elseif value == "buy" then
		local result = sqlite( "SELECT COUNT() FROM auction WHERE i = '"..i.."'" )

		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM auction WHERE i = '"..i.."'" )

			if (result[1]["name_buy"] ~= playername and result[1]["name_buy"] ~= "all") then
			
				sendMessage(playerid, "[ERROR] Вы не можете купить этот предмет", red)
				return
			end

			if array_player_2[playername][1] >= result[1]["money"] then

				if inv_player_empty(playerid, result[1]["id1"], result[1]["id2"]) then
					sendMessage(playerid, "Вы купили у "..result[1]["name_sell"].." "..info_png[result[1]["id1"]][1].." "..result[1]["id2"].." "..info_png[result[1]["id1"]][2].." за "..result[1]["money"].."$", orange)

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-result[1]["money"], playername )

					for i,playerid in pairs(getElementsByType("player")) do
						local playername_sell = getPlayerName(playerid)
						if playername_sell == result[1]["name_sell"] then
							sendMessage(playerid, playername.." купил у вас "..info_png[result[1]["id1"]][1].." "..result[1]["id2"].." "..info_png[result[1]["id1"]][2].." за "..result[1]["money"].."$", green)
							inv_server_load( playerid, "player", 0, 1, array_player_2[playername_sell][1]+result[1]["money"], playername_sell )
							count = count+1
							break
						end
					end

					if count == 0 then
						local result_sell = sqlite( "SELECT COUNT() FROM account WHERE name = '"..result[1]["name_sell"].."'" )
						if result_sell[1]["COUNT()"] == 1 then
							array_player_1[result[1]["name_sell"]] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
							array_player_2[result[1]["name_sell"]] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

							local result_sell = sqlite( "SELECT * FROM account WHERE name = '"..result[1]["name_sell"].."'" )
							load_inv(result[1]["name_sell"], "player", result_sell[1]["inventory"])

							array_player_2[result[1]["name_sell"]][1] = array_player_2[result[1]["name_sell"]][1]+result[1]["money"]

							sqlite( "UPDATE account SET inventory = '"..save_inv(result[1]["name_sell"], "player").."' WHERE name = '"..result[1]["name_sell"].."'")
						end
					end

					sqlite( "DELETE FROM auction WHERE i = '"..i.."'" )
				else
					sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] Лот не найден", red)
		end

	elseif value == "return" then
		local result = sqlite( "SELECT COUNT() FROM auction WHERE i = '"..i.."'" )

		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM auction WHERE i = '"..i.."'" )

			if playername == result[1]["name_sell"] then

				if inv_player_empty(playerid, result[1]["id1"], result[1]["id2"]) then
					sendMessage(playerid, "Вы забрали "..info_png[result[1]["id1"]][1].." "..result[1]["id2"].." "..info_png[result[1]["id1"]][2], orange)

					sqlite( "DELETE FROM auction WHERE i = '"..i.."'" )
				else
					sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				end
			else
				sendMessage(playerid, "[ERROR] Имена не совпадают", red)
			end
		else
			sendMessage(playerid, "[ERROR] Лот не найден", red)
		end
	end
end
addEvent( "event_auction_buy_sell", true )
addEventHandler ( "event_auction_buy_sell", getRootElement(), auction_buy_sell )
---------------------------------------------------------------------------------------------------------


-------------------------------эвенты автомастерской-----------------------------------------------------
function addVehicleUpgrade_fun( vehicleid, value, value1, playerid, number )

	if value1 == "save" then
		local playername = getPlayerName(playerid)
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		local plate = getVehiclePlateText ( vehicleid )
		local text = ""
		local prod = 1
		local cash = result[1]["price"]

		if prod <= result[1]["warehouse"] then
			if cash == 0 then
				sendMessage(playerid, "[ERROR] Не установлена стоимость товара", red)
				return
			end

			if cash <= array_player_2[playername][1] then

				addVehicleUpgrade ( vehicleid, value )

				setElementData(playerid, "car_upgrades_save", getVehicleUpgrades(vehicleid))

				for k,v in pairs(getVehicleUpgrades(vehicleid)) do
					text = text..v..","
				end

				sendMessage(playerid, "Вы установили апгрейд за "..cash.."$", orange)

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE number = '"..plate.."'")
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
		end
	end
end
addEvent( "event_addVehicleUpgrade", true )
addEventHandler ( "event_addVehicleUpgrade", getRootElement(), addVehicleUpgrade_fun )

function removeVehicleUpgrade_fun( vehicleid, value, value1, playerid, number )

	if value1 == "save" then
		local playername = getPlayerName(playerid)
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		local plate = getVehiclePlateText ( vehicleid )
		local text = ""
		local prod = 1
		local cash = result[1]["price"]

		if prod <= result[1]["warehouse"] then
			if cash == 0 then
				sendMessage(playerid, "[ERROR] Не установлена стоимость товара", red)
				return
			end

			if cash <= array_player_2[playername][1] then

				removeVehicleUpgrade ( vehicleid, value )

				for k,v in pairs(getVehicleUpgrades(vehicleid)) do
					text = text..v..","
				end

				if text == "" then
					text = "0"
				end

				sendMessage(playerid, "Вы удалили апгрейд за "..cash.."$", orange)

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE number = '"..plate.."'")
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
		end
	end
end
addEvent( "event_removeVehicleUpgrade", true )
addEventHandler ( "event_removeVehicleUpgrade", getRootElement(), removeVehicleUpgrade_fun )

function setVehiclePaintjob_fun( vehicleid, value, value1, playerid, number )

	if value1 == "save" then
		local playername = getPlayerName(playerid)
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		local plate = getVehiclePlateText ( vehicleid )
		local text = value
		local prod = 1
		local cash = result[1]["price"]/2

		if prod <= result[1]["warehouse"] then
			if cash == 0 then
				sendMessage(playerid, "[ERROR] Не установлена стоимость товара", red)
				return
			end

			if cash <= array_player_2[playername][1] then

				setVehiclePaintjob ( vehicleid, value )

				setElementData(playerid, "car_upgrades_save", getVehiclePaintjob(vehicleid))

				sendMessage(playerid, "Вы установили покрасочную работу за "..cash.."$", orange)

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET paintjob = '"..text.."' WHERE number = '"..plate.."'")
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
		end
	end
end
addEvent( "event_setVehiclePaintjob", true )
addEventHandler ( "event_setVehiclePaintjob", getRootElement(), setVehiclePaintjob_fun )

function setVehicleStage_fun( vehicleid, value, value1, playerid, number )

	if value1 == "save" then
		local playername = getPlayerName(playerid)
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		local plate = getVehiclePlateText ( vehicleid )
		local text = value
		local prod = 1
		local cash = result[1]["price"]*text

		if prod <= result[1]["warehouse"] then
			if cash == 0 then
				sendMessage(playerid, "[ERROR] Не установлена стоимость товара", red)
				return
			end

			for k,v in pairs(car_cash_no) do
				if v == getElementModel(vehicleid) then
					sendMessage(playerid, "[ERROR] На это т/с нельзя установить stage", red)
					return
				end
			end

			if cash <= array_player_2[playername][1] then

				setVehicleHandling(vehicleid, "engineAcceleration", getOriginalHandling(getElementModel(vehicleid))["engineAcceleration"]*(text*car_stage_coef)+getOriginalHandling(getElementModel(vehicleid))["engineAcceleration"])
				setVehicleHandling(vehicleid, "maxVelocity", getOriginalHandling(getElementModel(vehicleid))["maxVelocity"]*(text*car_stage_coef)+getOriginalHandling(getElementModel(vehicleid))["maxVelocity"])

				sendMessage(playerid, "Вы установили stage "..text.." за "..cash.."$", orange)

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET stage = '"..text.."' WHERE number = '"..plate.."'")
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
		end
	end
end
addEvent( "event_setVehicleStage_fun", true )
addEventHandler ( "event_setVehicleStage_fun", getRootElement(), setVehicleStage_fun )

function setVehicleColor_fun( vehicleid, r, g, b, value1, playerid, number )

	if value1 == "save" then
		local playername = getPlayerName(playerid)
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		local plate = getVehiclePlateText ( vehicleid )
		local text = r..","..g..","..b
		local prod = 1
		local cash = result[1]["price"]/2

		if prod <= result[1]["warehouse"] then
			if cash == 0 then
				sendMessage(playerid, "[ERROR] Не установлена стоимость товара", red)
				return
			end

			if cash <= array_player_2[playername][1] then

				setVehicleColor( vehicleid, r, g, b, r, g, b, r, g, b, r, g, b )

				sendMessage(playerid, "Вы перекрасили т/с за "..cash.."$", orange)

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET car_rgb = '"..text.."' WHERE number = '"..plate.."'")
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
		end
	end
end
addEvent( "event_setVehicleColor", true )
addEventHandler ( "event_setVehicleColor", getRootElement(), setVehicleColor_fun )

function setVehicleHeadLightColor_fun( vehicleid, r, g, b, value1, playerid, number )

	if value1 == "save" then
		local playername = getPlayerName(playerid)
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		local plate = getVehiclePlateText ( vehicleid )
		local text = r..","..g..","..b
		local prod = 1
		local cash = result[1]["price"]/2

		if prod <= result[1]["warehouse"] then
			if cash == 0 then
				sendMessage(playerid, "[ERROR] Не установлена стоимость товара", red)
				return
			end

			if cash <= array_player_2[playername][1] then

				setVehicleHeadLightColor ( vehicleid, r, g, b )

				sendMessage(playerid, "Вы поменяли цвет фар т/с за "..cash.."$", orange)

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET headlight_rgb = '"..text.."' WHERE number = '"..plate.."'")
				end
			else
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
			end
		else
			sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
		end
	end
end
addEvent( "event_setVehicleHeadLightColor", true )
addEventHandler ( "event_setVehicleHeadLightColor", getRootElement(), setVehicleHeadLightColor_fun )
------------------------------------------------------------------------------------------------------------


---------------------------------------магазины-------------------------------------------------------------
function buy_subject_fun( playerid, text, number, value )
	local playername = getPlayerName(playerid)

	if value == "pd" then
		if search_inv_player(playerid, 50, 1) == 0 then
			sendMessage(playerid, "[ERROR] У вас нет лицензии на оружие, приобрести её можно в Мэрии", red)
			return
		end

		if text == weapon_cops[39][1] then
			if inv_player_empty(playerid, 39, 1) then
				sendMessage(playerid, "Вы получили "..text, orange)
			else
				sendMessage(playerid, "[ERROR] Инвентарь полон", red)
			end
			return
		end

		for k,v in pairs(weapon_cops) do
			if v[1] == text then
				if inv_player_empty(playerid, k, v[4]) then
					sendMessage(playerid, "Вы получили "..text, orange)
				else
					sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				end
			end
		end

		for k,v in pairs(sub_cops) do
			if v[1] == text then
				if search_inv_player(playerid, 10, 6) == 0 then
					sendMessage(playerid, "[ERROR] Вы не Шеф полиции", red)
					return
				end

				if inv_player_empty(playerid, v[3], v[2]) then
					sendMessage(playerid, "Вы получили "..text, orange)
				else
					sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				end
			end
		end

		return

	elseif value == "mer" then
		for k,v in pairs(mayoralty_shop) do
			if v[1] == text then
				if v[3] <= array_player_2[playername][1] then
					if inv_player_empty(playerid, v[4], v[2]) then
						sendMessage(playerid, "Вы купили "..text.." за "..v[3].."$", orange)

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(v[3]), playername )
					else
						sendMessage(playerid, "[ERROR] Инвентарь полон", red)
					end
				else
					sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				end
			end
		end
		
		return

	elseif value == "giuseppe" then
		for k,v in pairs(giuseppe) do
			if v[1] == text then
				if v[3] <= array_player_2[playername][1] then
					if inv_player_empty(playerid, v[4], v[2]) then
						sendMessage(playerid, "Вы купили "..text.." за "..v[3].."$", orange)

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(v[3]), playername )
					else
						sendMessage(playerid, "[ERROR] Инвентарь полон", red)
					end
				else
					sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				end

				return
			end
		end
		
		return
	end

	local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
	local prod = 1
	local cash = result[1]["price"]

	if prod <= result[1]["warehouse"] then
		if cash == 0 then
			sendMessage(playerid, "[ERROR] Не установлена стоимость товара (надбавка в N раз)", red)
			return
		end

			if value == 1 then
				if search_inv_player(playerid, 50, 1) == 0 then
					sendMessage(playerid, "[ERROR] У вас нет лицензии на оружие, приобрести её можно в Мэрии", red)
					return
				end

				for k,v in pairs(weapon) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[4]) then
								sendMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange)

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )
							else
								sendMessage(playerid, "[ERROR] Инвентарь полон", red)
							end
						else
							sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
						end
					end
				end

			elseif value == 2 then
				if text == "мужская одежда" or text == "женская одежда" then
					return
				end

				if cash <= array_player_2[playername][1] then
					if inv_player_empty(playerid, 27, text) then
						sendMessage(playerid, "Вы купили "..text.." скин за "..cash.."$", orange)

						sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )
					else
						sendMessage(playerid, "[ERROR] Инвентарь полон", red)
					end
				else
					sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				end

			elseif value == 3 then
				for k,v in pairs(shop) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[2]) then
								sendMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange)

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )
							else
								sendMessage(playerid, "[ERROR] Инвентарь полон", red)
							end
						else
							sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
						end
					end
				end

			elseif value == 4 then
				for k,v in pairs(gas) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[2]) then
								sendMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange)

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )
							else
								sendMessage(playerid, "[ERROR] Инвентарь полон", red)
							end
						else
							sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
						end
					end
				end

			end

	else
		sendMessage(playerid, "[ERROR] На складе недостаточно товаров", red)
	end	
end
addEvent( "event_buy_subject_fun", true )
addEventHandler ( "event_buy_subject_fun", getRootElement(), buy_subject_fun )
------------------------------------------------------------------------------------------------------------


--------------------------эвент по кассе для бизнесов-------------------------------------------------------
function till_fun( playerid, number, money, value )
	local playername = getPlayerName(playerid)

	if value == "withdraw" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		if money <= result[1]["money"] then
			sqlite( "UPDATE business_db SET money = money - '"..money.."' WHERE number = '"..number.."'")

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

			sendMessage(playerid, "Вы забрали из кассы "..money.."$", green)
		else
			sendMessage(playerid, "[ERROR] В кассе недостаточно средств", red)
		end

	elseif value == "deposit" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		if money <= array_player_2[playername][1] then
			sqlite( "UPDATE business_db SET money = money + '"..money.."' WHERE number = '"..number.."'")

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-money, playername )

			sendMessage(playerid, "Вы положили в кассу "..money.."$", orange)
		else
			sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
		end

	elseif value == "price" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )

		sqlite( "UPDATE business_db SET price = '"..money.."' WHERE number = '"..number.."'")

		sendMessage(playerid, "Вы установили стоимость товара "..money.."$", yellow)

	--[[elseif value == "buyprod" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )

		sqlite( "UPDATE business_db SET buyprod = '"..money.."' WHERE number = '"..number.."'")

		sendMessage(playerid, "Вы установили цену закупки товара "..money.."$", yellow)]]
	end
end
addEvent( "event_till_fun", true )
addEventHandler ( "event_till_fun", getRootElement(), till_fun )


----------------------------------крафт предметов -----------------------------------------------------------
function craft_fun( playerid, text )
	local playername = getPlayerName(playerid)

	if enter_house[playername][1] == 0 then
		sendMessage(playerid, "[ERROR] Вы не в доме", red)
		return
	end

	for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do 
		if search_inv_player(playerid, 25, v["number"]) ~= 0 then

			for k,v in pairs(craft_table) do
				if text == v[1] then
					local split_sub = split(v[3], ",")
					local split_res = split(v[4], ",")
					local split_sub_create = split(v[5], ",")
					local len = #split_sub
					local count = 0

					for i=1,len do
						if search_inv_player(playerid, tonumber(split_sub[i]), tonumber(split_res[i])) >= 1 then
							count = count + 1
						end
					end
					
					if count == len then
						if inv_player_empty(playerid, tonumber(split_sub_create[1]), tonumber(split_sub_create[2])) then

							for i=1,len do
								if inv_player_delet(playerid, tonumber(split_sub[i]), tonumber(split_res[i])) then
								end
							end

							sendMessage(playerid, "Вы создали "..v[1], orange)
						else
							sendMessage(playerid, "[ERROR] Инвентарь полон", red)
						end
					else
						sendMessage(playerid, "[ERROR] Недостаточно ресурсов", red)
					end
				end
			end

			return
		end
	end

	sendMessage(playerid, "[ERROR] У вас нет ключа от дома", red)
end
addEvent( "event_craft_fun", true )
addEventHandler ( "event_craft_fun", getRootElement(), craft_fun )
-------------------------------------------------------------------------------------------------------------


----------------------------------------------скотобойня-----------------------------------------------------
function cow_farms(playerid, value, val1, val2)
	local playername = getPlayerName(playerid)
	local x,y,z = getElementPosition(playerid)
	local cash = 50000
	local doc = 86
	local lic = 87

	if value == "buy" then
		local result = sqlite( "SELECT COUNT() FROM cow_farms_db" )
		result = result[1]["COUNT()"]+1
		if cash*result > array_player_2[playername][1] then
			sendMessage(playerid, "[ERROR] У вас недостаточно средств, необходимо "..cash*result.."$", red)
			return
		end

		if inv_player_empty(playerid, doc, result) then
			sqlite( "INSERT INTO cow_farms_db (number, price, coef, money, nalog, warehouse, prod) VALUES ('"..result.."', '0', '50', '0', '5', '0', '0')" )

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash*result, playername )

			sendMessage(playerid, "Вы купили скотобойню за "..cash*result.."$", orange)

			sendMessage(playerid, "Вы получили "..info_png[doc][1].." "..result.." "..info_png[doc][2], svetlo_zolotoy)
		else
			sendMessage(playerid, "[ERROR] Инвентарь полон", red)
		end

	elseif value == "menu" then

		if val1 == "Зарплата" then
			if val2 < 1 then
				return
			end

			local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

			if not result[1] then
				return
			end

			sqlite( "UPDATE cow_farms_db SET price = '"..val2.."' WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

			sendMessage(playerid, "Вы установили зарплату "..val2.."$", yellow)

		elseif val1 == "Доход от продаж" then
			if val2 < 1 or val2 > 100 then
				return
			end

			local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

			if not result[1] then
				return
			end

			sqlite( "UPDATE cow_farms_db SET coef = '"..val2.."' WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

			sendMessage(playerid, "Вы установили доход от продаж "..val2.." процентов", yellow)

		elseif val1 == "Баланс" then
			if val2 == 0 then
				return
			end

			if val2 < 1 then
				local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

				if not result[1] then
					return
				end

				if (val2*-1) <= result[1]["money"] then
					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+(val2*-1), playername )

					sqlite( "UPDATE cow_farms_db SET money = money - '"..(val2*-1).."' WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

					sendMessage(playerid, "Вы забрали из кассы "..(val2*-1).."$", green)
				else
					sendMessage(playerid, "[ERROR] Недостаточно средств на балансе бизнеса", red)
				end
			else
				if val2 <= array_player_2[playername][1] then
					local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

					if not result[1] then
						return
					end

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-val2, playername )

					sqlite( "UPDATE cow_farms_db SET money = money + '"..val2.."' WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

					sendMessage(playerid, "Вы положили в кассу "..val2.."$", orange)
				else
					sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				end
			end

		elseif val1 == "Налог" then
			local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'" )

			if not result[1] then
				return
			end

			if search_inv_player(playerid, 60, 7) ~= 0 then
				if inv_player_delet(playerid, 60, 7) then
					sqlite( "UPDATE cow_farms_db SET nalog = nalog + '7' WHERE number = '"..search_inv_player_2_parameter(playerid, doc).."'")

					sendMessage(playerid, "Вы оплатили налог "..search_inv_player_2_parameter(playerid, doc).." скотобойни", yellow)
				end
			else
				sendMessage(playerid, "[ERROR] У вас нет "..info_png[60][1].." 7 "..info_png[60][2], red)
			end
		end

	elseif value == "job" then
		give_subject(playerid, "player", lic, val1, true)

	elseif value == "load" then
		local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, lic).."'" )

		if not result[1] then
			return false
		elseif result[1]["warehouse"]-val1 < 0 then
			sendMessage(playerid, "[ERROR] Склад пуст", red)
			return false
		end

		sqlite( "UPDATE cow_farms_db SET warehouse = warehouse - '"..val1.."' WHERE number = '"..search_inv_player_2_parameter(playerid, lic).."'")

		return true

	elseif value == "unload" then
		local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, lic).."'" )

		if not isPointInCircle3D(x,y,z, down_car_subject[3][1],down_car_subject[3][2],down_car_subject[3][3], down_car_subject[3][4]) then
			return false
		end

		if not result[1] then
			return true
		end

		inv_car_delet(playerid, 88, val2, true, true)

		local money = val1*val2

		local cash2 = (money*((100-result[1]["coef"])/100))
		local cash = (money*(result[1]["coef"]/100))

		inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+cash, playername )

		sendMessage(playerid, "Вы разгрузили из т/с "..info_png[88][1].." "..val1.." шт за "..cash.."$", green)

		sqlite( "UPDATE cow_farms_db SET money = money + '"..cash2.."' WHERE number = '"..search_inv_player_2_parameter(playerid, lic).."'")

		return true

	elseif value == "unload_prod" then
		local money = val1*val2
		local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, lic).."'" )

		if not isPointInCircle3D(x,y,z, down_car_subject[4][1],down_car_subject[4][2],down_car_subject[4][3], down_car_subject[4][4]) then
			return false
		end

		if not result[1] then
			return true
		elseif result[1]["money"] < money then
			sendMessage(playerid, "[ERROR] Недостаточно средств на балансе бизнеса", red)
			return true
		elseif result[1]["prod"] >= max_cf then
			sendMessage(playerid, "[ERROR] Склад полон", red)
			return true
		end

		inv_car_delet(playerid, 89, val2, true, true)

		inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

		sendMessage(playerid, "Вы разгрузили из т/с "..info_png[89][1].." "..val1.." шт за "..money.."$", green)

		sqlite( "UPDATE cow_farms_db SET money = money - '"..money.."', prod = prod + '"..val1.."' WHERE number = '"..search_inv_player_2_parameter(playerid, lic).."'")

		return true
	end
end
addEvent( "event_cow_farms", true )
addEventHandler ( "event_cow_farms", getRootElement(), cow_farms )
-------------------------------------------------------------------------------------------------------------

function displayLoadedRes ( res )--старт ресурсов
	if car_spawn_value == 0 then
		car_spawn_value = 1

		setTime(0,0)
		setGameType ( "discord.gg/000000" )--ссылка на дискорд

		setTimer(debuginfo, 1000, 0)--дебагинфа
		setTimer(freez_car, 1000, 0)--заморозка авто и не только
		setTimer(need, 60000, 0)--уменьшение потребностей
		setTimer(need_1, 10000, 0)--смена скина на бомжа
		setTimer(fuel_down, 1000, 0)--система топлива
		setTimer(set_weather, 1000, 0)--погода сервера
		setTimer(prison, 60000, 0)--таймер заключения в тюрьме
		setTimer(prison_timer, 1000, 0)--античит если не в тюрьме
		setTimer(pay_nalog, (60*60000), 0)--списание налогов
		setTimer(job_timer2, 1000, 0)--работы в цикле

		setWeather(tomorrow_weather)
		setGlitchEnabled ( "quickreload", true )


		for k,v in pairs(no_ped_damage[2]) do--заморозка нпс
			setElementFrozen(v, true)
		end


		local result = sqlite( "SELECT COUNT() FROM account" )
		print("[account] "..result[1]["COUNT()"])


		local banned = 0
		for k,v in pairs(sqlite( "SELECT * FROM account WHERE ban = '1'" )) do
			banned = banned+1
		end
		print("[account_banned] "..banned)


		local result = sqlite( "SELECT COUNT() FROM banserial_list" )
		print("[account_banserial] "..result[1]["COUNT()"])


		carnumber_number = 0
		for k,v in pairs(sqlite( "SELECT * FROM car_db" )) do
			car_spawn(v["number"])
		end
		print("[number_car_spawn] "..carnumber_number)


		local house_number = 0
		for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			local h = v["number"]
			house_pos[v["number"]] = {v["x"], v["y"], v["z"], createBlip ( v["x"], v["y"], v["z"], 32, 0, 0,0,0,0, 0, max_blip ), createPickup (  v["x"], v["y"], v["z"], 3, house_icon, 10000 )}

			array_house_1[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

			load_inv(h, "house", v["inventory"])

			house_number = house_number+1
		end
		print("[house_number] "..house_number)


		local business_number = 0
		for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
			business_pos[v["number"]] = {v["x"], v["y"], v["z"], createBlip ( v["x"], v["y"], v["z"], interior_business[v["interior"]][6], 0, 0,0,0,0, 0, max_blip ), createPickup ( v["x"], v["y"], v["z"], 3, business_icon, 10000 )}

			business_number = business_number+1
		end
		print("[business_number] "..business_number)
		

		local cow_farms_db = 0
		for k,v in pairs(sqlite( "SELECT * FROM cow_farms_db" )) do
			cow_farms_db = cow_farms_db+1
		end
		print("[cow_farms_db] "..cow_farms_db)
		print("")


		for k,v in pairs(sqlite( "SELECT * FROM guns_zone" )) do
			guns_zone[v["number"]] = {createRadarArea (v["x1"], v["y1"], v["x2"], v["y2"], name_mafia[v["mafia"]][2][1],name_mafia[v["mafia"]][2][2],name_mafia[v["mafia"]][2][3], 100), v["mafia"]}
		end


		--создание блипов
		for k,v in pairs(interior_job) do 
			createBlip ( v[6], v[7], v[8], v[9], 0, 0,0,0,0, 0, max_blip )
			createPickup ( v[6], v[7], v[8], 3, job_icon, 10000 )
		end

		createBlip ( 2308.81640625,-13.25,26.7421875, 8, 0, 0,0,0,0, 0, max_blip )--банк штата

		for k,v in pairs(up_car_subject) do
			createBlip ( v[1], v[2], v[3], 51, 0, 0,0,0,0, 0, max_blip )
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
		end

		for k,v in pairs(down_car_subject) do
			createBlip ( v[1], v[2], v[3], 52, 0, 0,0,0,0, 0, max_blip )
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
		end

		for k,v in pairs(down_car_subject_pos) do
			createBlip ( v[1], v[2], v[3], 52, 0, 0,0,0,0, 0, max_blip )
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
		end

		for k,v in pairs(t_s_salon) do
			createBlip ( v[1], v[2], v[3], v[4], 0, 0,0,0,0, 0, max_blip )--салоны продажи
		end

		for k,v in pairs(station) do
			createBlip ( v[1], v[2], v[3], 42, 0, 0,0,0,0, 0, max_blip )--вокзалы
		end

		for k,v in pairs(hospital_spawn) do
			createBlip ( v[1], v[2], v[3], 22, 0, 0,0,0,0, 0, max_blip )--больницы
		end

		for j=0,1 do
			for i=0,4 do
				local obj = createObject(2804, 954.90002+(j*6.5),2143.5-(3*i),1010.9, 0,180,270)
				setElementInterior(obj, interior_job[1][1])
				setElementDimension(obj, interior_job[1][10])

				local obj = createObject(941, 955.79999+(j*6.5),2143.6001-(3*i),1010.5, 0,0,0)
				setElementInterior(obj, interior_job[1][1])
				setElementDimension(obj, interior_job[1][10])

				anim_player_subject[#anim_player_subject+1] = {956.0166015625+(j*6.5),2142.6650390625-(3*i),1011.0181274414, 1, 30, 48, 100, "knife", "knife_4", 1, 1, 10}
			end
		end


		--создание маркеров
		for k,v in pairs(up_player_subject) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
			setElementInterior(marker, v[7])
			setElementDimension(marker, v[8])

			if v[7] == 0 then
				createBlip ( v[1], v[2], v[3], 51, 0, 0,0,0,0, 0, max_blip )
			end
		end

		for k,v in pairs(down_player_subject) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
			setElementInterior(marker, v[6])
			setElementDimension(marker, v[7])

			if v[6] == 0 then
				createBlip ( v[1], v[2], v[3], 52, 0, 0,0,0,0, 0, max_blip )
			end
		end

		for k,v in pairs(anim_player_subject) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
			setElementInterior(marker, v[10])
			setElementDimension(marker, v[11])
		end

		for k,v in pairs(t_s_salon) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1],yellow[2],yellow[3] )
		end

		for i=1,50 do
			local x,y,z = math.random(-1189,-1007), math.random(-1061,-916), 129.51875
			local obj = createObject(16442, x,y,z, 0,0,math.random(0,360))
			setObjectScale (obj, 0.7)
			korovi_pos[i] = {x,y,z}
		end

		for j=0,29 do
			for i=0,16 do
				local x,y,z = -181.125-(i*5)+(j*1.92),-83.888671875+(1.66*i)+(j*5),3.11-1.5
				local obj = createObject(323, x,y,z, 0,180,0)
				grass_pos[#grass_pos+1] = {obj, x,y,z}
			end
		end
	end
end
addEventHandler ( "onResourceStart", getRootElement(), displayLoadedRes )

addEventHandler("onPlayerJoin", getRootElement(),--конект игрока на сервер
function()
	local playerid = source
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP ( playerid )

	--o_pos(playerid)

	array_player_1[playername] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_player_2[playername] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	state_inv_player[playername] = 0
	state_gui_window[playername] = 0
	logged[playername] = 0
	enter_house[playername] = {0,0}
	enter_business[playername] = 0
	enter_job[playername] = 0
	speed_car_device[playername] = 0
	arrest[playername] = 0
	crimes[playername] = 0
	robbery_player[playername] = 0
	robbery_timer[playername] = 0
	gps_device[playername] = 0
	job[playername] = 0
	job_call[playername] = 0
	job_ped[playername] = 0
	job_blip[playername] = 0
	job_marker[playername] = 0
	job_pos[playername] = 0
	job_vehicleid[playername] = 0
	job_timer[playername] = 0
	job_object[playername] = 0
	armour[playername] = 0

	--нужды
	alcohol[playername] = 0
	satiety[playername] = 0
	hygiene[playername] = 0
	sleep[playername] = 0
	drugs[playername] = 0

	local result = sqlite( "SELECT COUNT() FROM banserial_list WHERE serial = '"..serial.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM banserial_list WHERE serial = '"..serial.."'" )
		kickPlayer(playerid, "ban serial reason: "..result[1]["reason"])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		if result[1]["ban"] ~= "0" then
			kickPlayer(playerid, "ban player reason: "..result[1]["reason"])
			return
		end
	end

	if not string.find(playername, "^%u%l+_%u%l+$") then
		kickPlayer(playerid, "Неправильный формат ника (Имя_Фамилия)")
		return
	end

	----бинд клавиш----
	bindKey(playerid, "tab", "down", tab_down )
	bindKey(playerid, "e", "down", e_down )
	bindKey(playerid, "x", "down", x_down )
	bindKey(playerid, "lalt", "down", left_alt_down )
	bindKey(playerid, "h", "down", h_down )

	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)
	setPlayerHudComponentVisible ( playerid, "money", false )
	setPlayerHudComponentVisible ( playerid, "health", false )
	setPlayerHudComponentVisible ( playerid, "area_name", false )
	setPlayerHudComponentVisible ( playerid, "vehicle_name", true )
	setPlayerNametagShowing ( playerid, false )
	count_player = count_player+1

	for _, stat in pairs({ 22, 24, 225, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
		setPedStat(playerid, stat, 1000)
	end

	for _, stat in pairs({ 69, 75 }) do
		setPedStat(playerid, stat, 998)
	end

	sendMessage(playerid, "[TIPS] F1 - скрыть или показать курсор", color_tips)
	sendMessage(playerid, "[TIPS] F2 - скрыть или показать худ", color_tips)
	sendMessage(playerid, "[TIPS] F3 - меню т/с и анимаций", color_tips)
	sendMessage(playerid, "[TIPS] TAB - открыть инвентарь, ПКМ - использовать предмет, чтобы выкинуть переместите его за пределы инвентаря", color_tips)
	sendMessage(playerid, "[TIPS] X - крафт предметов", color_tips)
	sendMessage(playerid, "[TIPS] Листать чат page up и page down", color_tips)
	sendMessage(playerid, "[TIPS] Команды сервера находятся в WIKI в планшете", color_tips)
	sendMessage(playerid, "[TIPS] Первоначальная работа находится в ЛВ мясокомбинат", color_tips)
	sendMessage(playerid, "[TIPS] Граждане не имеющий дом, могут помыться и выспаться в отелях", color_tips)
	sendMessage(playerid, "[TIPS] Права можно купить в Мэрии", color_tips)

	reg_or_login(playerid)
end)

function quitPlayer ( quitType )--дисконект игрока с сервера
	local playerid = source
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)

	if logged[playername] == 1 then
		for k,v in pairs(sqlite("SELECT * FROM business_db")) do
			if getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_business[v["interior"]][1] and enter_business[playername] == 1 then
				x,y,z = v["x"],v["y"],v["z"]
				break
			end
		end

		for k,v in pairs(sqlite("SELECT * FROM house_db")) do
			if getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_house[v["interior"]][1] and enter_house[playername][1] == 1 then
				x,y,z = v["x"],v["y"],v["z"]
				break
			end
		end

		for id,v in pairs(interior_job) do
			if getElementInterior(playerid) == interior_job[id][1] and getElementDimension(playerid) == v[10] and enter_job[playername] == 1 then
				x,y,z = v[6],v[7],v[8]
				break
			end
		end

		if armour[playername] ~= 0 then
			destroyElement(armour[playername])
			armour[playername] = 0
		end

		local heal = getElementHealth( playerid )
		sqlite( "UPDATE account SET heal = '"..heal.."', x = '"..x.."', y = '"..y.."', z = '"..z.."', arrest = '"..arrest[playername].."', crimes = '"..crimes[playername].."', alcohol = '"..alcohol[playername].."', satiety = '"..satiety[playername].."', hygiene = '"..hygiene[playername].."', sleep = '"..sleep[playername].."', drugs = '"..drugs[playername].."' WHERE name = '"..playername.."'")

		exit_car_fun(playerid)
		job_0( playername )
		car_theft_fun(playername)
		robbery_kill( playername )

		logged[playername] = 0
	else
		
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )

function player_Spawn (playerid)--спавн игрока
	if isElement ( playerid ) then
		local playername = getPlayerName ( playerid )
		local randomize = random(1,3)

		if logged[playername] == 1 then
			local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

			spawnPlayer(playerid, hospital_spawn[randomize][1], hospital_spawn[randomize][2], hospital_spawn[randomize][3], 0, result[1]["skin"])

			setElementHealth( playerid, 100 )
		end
	end
end

addEventHandler( "onPlayerWasted", getRootElement(),--смерть игрока
function(ammo, attacker, weapon, bodypart)
	local playerid = source
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local playername_a = nil
	local reason = weapon
	local cash = 100

	for k,v in pairs(deathReasons) do
		if k == reason then
			reason = v
		end
	end

	if tonumber(reason) then
		reason = getWeaponNameFromID(reason)
	end

	if attacker then
		if getElementType ( attacker ) == "player" then
			playername_a = getPlayerName ( attacker )

			if playername_a ~= playername then
				if search_inv_player_2_parameter(attacker, 10) == 0 then
					local crimes_plus = zakon_kill_crimes
					crimes[playername_a] = crimes[playername_a]+crimes_plus
					sendMessage(attacker, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername_a], blue)
				else
					if crimes[playername] ~= 0 then
						arrest[playername] = 1

						sendMessage(attacker, "Вы получили премию "..(cash*(crimes[playername])).."$", green )

						inv_server_load( attacker, "player", 0, 1, array_player_2[playername_a][1]+(cash*(crimes[playername])), playername_a )
					end
				end

				if(point_guns_zone[1] == 1 and search_inv_player_2_parameter(playerid, 85) ~= 0 and search_inv_player_2_parameter(attacker, 85) ~= 0) then
				
					for k,v in pairs(guns_zone) do
						if(isInsideRadarArea(v[1], x,y) and k == point_guns_zone[2]) then
						
							if(search_inv_player_2_parameter(playerid, 85) == point_guns_zone[5] and search_inv_player_2_parameter(attacker, 85) ~= point_guns_zone[5]) then
							
								points_add_in_gz(attacker, 2)
							end
						end
					end
				end
			end

		elseif getElementType ( attacker ) == "vehicle" then
			for i,player_id in pairs(getElementsByType("player")) do
				local vehicleid = getPlayerVehicle(player_id)

				if attacker == vehicleid then
					playername_a = getPlayerName ( player_id )

					if playername_a ~= playername then
						if search_inv_player_2_parameter(player_id, 10) == 0 then
							local crimes_plus = zakon_kill_crimes
							crimes[playername_a] = crimes[playername_a]+crimes_plus
							sendMessage(player_id, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername_a], blue)
						else
							if crimes[playername] ~= 0 then
								arrest[playername] = 1

								sendMessage(attacker, "Вы получили премию "..(cash*(crimes[playername])).."$", green )

								inv_server_load( attacker, "player", 0, 1, array_player_2[playername_a][1]+(cash*(crimes[playername])), playername_a )
							end
						end
					end

					break
				end
			end
		end
	end

	robbery_kill( playername )
	job_0( playername )
	car_theft_fun(playername)
	
	setTimer( player_Spawn, 5000, 1, playerid )

	--[[if not playername_a then
		sendMessage(getRootElement(), "[НОВОСТИ] "..playername.." умер Причина: "..tostring(reason).." Часть тела: "..tostring(getBodyPartName ( bodypart )), green )
	else
		sendMessage(getRootElement(), "[НОВОСТИ] "..playername_a.." убил "..playername.." Причина: "..tostring(reason).." Часть тела: "..tostring(getBodyPartName ( bodypart )), green )
	end]]

	print("[onPlayerWasted] "..playername.." [ammo - "..tostring(ammo)..", attacker - "..tostring(playername_a)..", reason - "..tostring(reason)..", bodypart - "..tostring(getBodyPartName ( bodypart )).."]")
end)

function frozen_false_fun( playerid )
	if isElement ( playerid ) then
		if isElementFrozen(playerid) then
			setElementFrozen( playerid, false )
			sendMessage(playerid, "Вы можете двигаться", yellow)
		end
	end
end

function playerDamage_text ( attacker, weapon, bodypart, loss )--получение урона
	local playerid = source
	local playername = getPlayerName ( playerid )
	local reason = weapon

	if attacker then
		if getElementType ( attacker ) == "player" then
			triggerClientEvent( attacker, "event_body_hit_sound", playerid )

		elseif getElementType ( attacker ) == "vehicle" then
			for i,playerid in pairs(getElementsByType("player")) do
				local vehicleid = getPlayerVehicle(playerid)

				if attacker == vehicleid then
					triggerClientEvent( playerid, "event_body_hit_sound", playerid )
					break
				end
			end
		end
	end

	if (reason == 16 or reason == 3) and not isElementFrozen(playerid) then--удар дубинкой оглушает игрока на 15 сек
		local playername_attacker = getPlayerName ( attacker )
		setElementFrozen( playerid, true )
		setTimer(frozen_false_fun, 15000, 1, playerid)--разморозка
		me_chat(playerid, playername_attacker.." оглушил(а) "..playername)
	end
end
addEventHandler ( "onPlayerDamage", getRootElement(), playerDamage_text )

function nickChangeHandler(oldNick, newNick)
	local playerid = source
	local playername = getPlayerName ( playerid )

	--kickPlayer( playerid, "kick for Change Nick" )
	cancelEvent()
end
addEventHandler("onPlayerChangeNick", getRootElement(), nickChangeHandler)

function onStealthKill(targetPlayer)
	cancelEvent() -- Aborts the stealth-kill.
end
addEventHandler("onPlayerStealthKill", getRootElement(), onStealthKill) -- Adds a handler for the stealth kill event.

----------------------------------Регистрация-Авторизация--------------------------------------------
function reg_or_login(playerid)
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP(playerid)

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 0 then

		local result = sqlite( "SELECT COUNT() FROM account WHERE reg_serial = '"..serial.."'" )
		if result[1]["COUNT()"] >= 1 then
			kickPlayer(playerid, "Регистрация твинков запрещена")
			return
		end
		
		local result = sqlite( "INSERT INTO account (name, ban, reason, x, y, z, reg_ip, reg_serial, heal, alcohol, satiety, hygiene, sleep, drugs, skin, arrest, crimes, inventory) VALUES ('"..playername.."', '0', '0', '"..spawnX.."', '"..spawnY.."', '"..spawnZ.."', '"..ip.."', '"..serial.."', '"..max_heal.."', '0', '100', '100', '100', '0', '26', '0', '0', '1:500,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,')" )

		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

		load_inv(playername, "player", result[1]["inventory"])

		logged[playername] = 1
		alcohol[playername] = result[1]["alcohol"]
		satiety[playername] = result[1]["satiety"]
		hygiene[playername] = result[1]["hygiene"]
		sleep[playername] = result[1]["sleep"]
		drugs[playername] = result[1]["drugs"]

		spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"], 0, result[1]["skin"], 0, 0)
		setElementHealth( playerid, result[1]["heal"] )

		sendMessage(playerid, "Вы удачно зарегистрировались!", turquoise)

		print("[ACCOUNT REGISTER] "..playername.." [ip - "..ip..", serial - "..serial.."]")

	elseif result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

		if result[1]["reg_serial"] ~= serial then
			kickPlayer(playerid, "Вы не владелец аккаунта")
			return
		end

		load_inv(playername, "player", result[1]["inventory"])

		logged[playername] = 1
		arrest[playername] = result[1]["arrest"]
		crimes[playername] = result[1]["crimes"]
		alcohol[playername] = result[1]["alcohol"]
		satiety[playername] = result[1]["satiety"]
		hygiene[playername] = result[1]["hygiene"]
		sleep[playername] = result[1]["sleep"]
		drugs[playername] = result[1]["drugs"]

		spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"], 0, result[1]["skin"], 0, 0)

		setElementHealth( playerid, result[1]["heal"] )

		sendMessage(playerid, "Вы удачно зашли!", turquoise)
	end

	setPlayerNametagColor_fun( playerid )
	sqlite_load(playerid, "quest_table")
	sqlite_load(playerid, "auc")
	sqlite_load(playerid, "cow_farms_table1")
	sqlite_load(playerid, "cow_farms_table2")
	sqlite_load(playerid, "carparking_table")

	if getElementData(playerid, "admin_data") ~= 0 then
		sqlite_load(playerid, "account_db")
		sqlite_load(playerid, "house_db")
		sqlite_load(playerid, "business_db")
		sqlite_load(playerid, "car_db")
		sqlite_load(playerid, "cow_farms_db2")
	end

	setElementData(playerid, "player_id", { count_player, 0 })
	setElementData(playerid, "fuel_data", 0)
	setElementData(playerid, "probeg_data", 0)
	setElementData(playerid, "zakon_nalog_car_data", zakon_nalog_car)
	setElementData(playerid, "zakon_nalog_house_data", zakon_nalog_house)
	setElementData(playerid, "zakon_nalog_business_data", zakon_nalog_business)
	setElementData(playerid, "zakon_alcohol", zakon_alcohol)
	setElementData(playerid, "zakon_drugs", zakon_drugs)
	setElementData(playerid, "craft_table", craft_table)
	setElementData(playerid, "shop", shop)
	setElementData(playerid, "gas", gas)
	setElementData(playerid, "giuseppe", giuseppe)
	setElementData(playerid, "interior_business", interior_business)
	setElementData(playerid, "mayoralty_shop", mayoralty_shop)
	setElementData(playerid, "weapon_cops", weapon_cops)
	setElementData(playerid, "sub_cops", sub_cops)
	setElementData(playerid, "house_bussiness_radius", house_bussiness_radius)
	setElementData(playerid, "upgrades_car_table", upgrades_car_table)
	setElementData(playerid, "name_mafia", name_mafia)
	setElementData(playerid, "interior_job", interior_job)
	setElementData(playerid, "cash_car", cash_car)
	setElementData(playerid, "cash_boats", cash_boats)
	setElementData(playerid, "cash_helicopters", cash_helicopters)
	setElementData(playerid, "quest_select", "0:0")
end

------------------------------------взрыв авто-------------------------------------------
function fixVehicle_fun( vehicleid )
	fixVehicle(vehicleid)
	fixVehicle(vehicleid)
	setElementHealth(vehicleid, 300)
end

function explode_car()
	local vehicleid = source
	local plate = getVehiclePlateText ( vehicleid )

	setTimer(fixVehicle_fun, 5000, 1, vehicleid)

	for k,playerid in pairs(getElementsByType("player")) do
		if vehicleid == getPlayerVehicle(playerid) then
			removePedFromVehicle ( playerid )--антибаг
			setElementHealth(playerid, 0.0)
		end
	end

	if getElementModel(vehicleid) == 428 then
		for i=0,max_inv do
			local sic2p = search_inv_car_2_parameter(vehicleid, 65)
			inv_car_throw_earth(vehicleid, 65, sic2p)
		end

		for i=0,max_inv do
			local sic2p = search_inv_car_2_parameter(vehicleid, 66)
			inv_car_throw_earth(vehicleid, 66, sic2p)
		end
	end
end
addEventHandler("onVehicleExplode", getRootElement(), explode_car)

function freez_car()--заморозка авто
	for k,vehicleid in pairs(getElementsByType("vehicle")) do
		local x,y,z = getElementPosition( vehicleid )
		local plate = getVehiclePlateText ( vehicleid )

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
			for k,v in pairs(result) do
				if v["frozen"] == 1 then
					setElementFrozen(vehicleid, true)
				else
					setElementFrozen(vehicleid, false)
				end
			end
		end

		local table_no_damage_car = {528,432,601,428}
		for k,v in pairs(table_no_damage_car) do
			if getElementModel(vehicleid) == v then
				setVehicleDamageProof(vehicleid, true)
			end
		end

		--[[if getVehicleType (vehicleid) == "Plane" or getVehicleType (vehicleid) == "Helicopter" then
			if isInsideColShape(lv_airport, x,y,z) or isInsideColShape(sf_airport, x,y,z) or isInsideColShape(ls_airport, x,y,z) then
				for k,playerid in pairs(getElementsByType("player")) do
					triggerClientEvent( playerid, "event_setElementCollidableWith_fun", playerid, "vehicle", vehicleid, false )
				end
			else
				for k,playerid in pairs(getElementsByType("player")) do
					triggerClientEvent( playerid, "event_setElementCollidableWith_fun", playerid, "vehicle", vehicleid, true )
				end
			end
		end]]
	end
end

function detachTrailer(vehicleid)--прицепка прицепа
	local trailer = source
	local plate = getVehiclePlateText ( trailer )
	local playerid = getVehicleController ( vehicleid )

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
	if result[1]["COUNT()"] == 1 and getElementModel(vehicleid) == 525 and search_inv_player_2_parameter(playerid, 10) ~= 0 then
		local x,y,z = getElementPosition(trailer)
		local rx,ry,rz = getElementRotation(trailer)

		if isInsideColShape(car_shtraf_stoyanka, x,y,z) then
			sqlite( "UPDATE car_db SET frozen = '0', x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")
		end

		sqlite( "UPDATE car_db SET evacuate = '1' WHERE number = '"..plate.."'")
	end
end
addEventHandler("onTrailerAttach", getRootElement(), detachTrailer)

function reattachTrailer(vehicleid)--отцепка прицепа
	local trailer = source
	local plate = getVehiclePlateText ( trailer )

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
	if result[1]["COUNT()"] == 1 and getElementModel(vehicleid) == 525 and search_inv_player_2_parameter(playerid, 10) ~= 0 then
		local x,y,z = getElementPosition(trailer)
		local rx,ry,rz = getElementRotation(trailer)

		if isInsideColShape(car_shtraf_stoyanka, x,y,z) then
			sqlite( "UPDATE car_db SET frozen = '1', x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")
		end

		sqlite( "UPDATE car_db SET evacuate = '0' WHERE number = '"..plate.."'")
	end
end
addEventHandler("onTrailerDetach", getRootElement(), reattachTrailer)

function car_spawn(number)
	local plate = number
	local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )

	if result[1]["nalog"] ~= 0 then
		local vehicleid = createVehicle(result[1]["model"], result[1]["x"], result[1]["y"], result[1]["z"], 0, 0, result[1]["rot"], plate)

		setVehicleLocked ( vehicleid, true )

		fuel[plate] = result[1]["fuel"]
		probeg[plate] = result[1]["probeg"]

		local spl = split(result[1]["tune"], ",")
		for k,v in pairs(spl) do
			addVehicleUpgrade ( vehicleid, v )
		end

		local spl = split(result[1]["car_rgb"], ",")
		setVehicleColor( vehicleid, spl[1], spl[2], spl[3], spl[1], spl[2], spl[3], spl[1], spl[2], spl[3], spl[1], spl[2], spl[3] )

		local spl = split(result[1]["headlight_rgb"], ",")
		setVehicleHeadLightColor ( vehicleid, spl[1], spl[2], spl[3] )

		setVehiclePaintjob ( vehicleid, result[1]["paintjob"] )

		setVehicleHandling(vehicleid, "engineAcceleration", getOriginalHandling(getElementModel(vehicleid))["engineAcceleration"]*(result[1]["stage"]*car_stage_coef)+getOriginalHandling(getElementModel(vehicleid))["engineAcceleration"])
		setVehicleHandling(vehicleid, "maxVelocity", getOriginalHandling(getElementModel(vehicleid))["maxVelocity"]*(result[1]["stage"]*car_stage_coef)+getOriginalHandling(getElementModel(vehicleid))["maxVelocity"])
			
		array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

		load_inv(plate, "car", result[1]["inventory"])

		carnumber_number = carnumber_number+1
	end
end
addEvent("event_car_spawn", true)
addEventHandler("event_car_spawn", getRootElement(), car_spawn)

function spawn_carparking( playerid, plate )
	local playername = getPlayerName(playerid)
	local count = 0
	local result = sqlite( "SELECT COUNT() FROM car_db WHERE nalog = '0' AND number = '"..plate.."'" )

	for k,vehicleid in pairs(getElementsByType("vehicle")) do
		if getVehiclePlateText(vehicleid) == plate then
			count = 1
			break
		end
	end

	if count == 1 or result[1]["COUNT()"] == 0 then
		sendMessage(playerid, "[ERROR] Т/с в городе", red)
		return
	end

	if search_inv_player(playerid, 61, 7) ~= 0 then
		if inv_player_delet(playerid, 61, 7) then
			sqlite( "UPDATE car_db SET nalog = '7' WHERE number = '"..plate.."'")
			car_spawn(plate)

			sendMessage(playerid, "Вы забрали т/с с номером "..plate, yellow)
		end
	else
		sendMessage(playerid, "[ERROR] У вас нет "..info_png[61][1].." 7 "..info_png[61][2], red)
	end
end
addEvent( "event_spawn_carparking", true )
addEventHandler ( "event_spawn_carparking", getRootElement(), spawn_carparking )

--addCommandHandler ( "buycar",--покупка авто
function buycar ( playerid, id )
	local police_car = {596,597,598,599,427,601,490,525,523,528}
	local police_boats = {430}
	local police_helicopters = {497}

	local playername = getPlayerName ( playerid )
	local x1,y1,z1 = getElementPosition ( playerid )
	local x,y,z,rot = 0,0,0,0

	if logged[playername] == 0 then
		return
	end

	local id = tonumber(id)

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ид т/с]", red)
		return
	end

	if id >= 400 and id <= 611 then
		local result = sqlite( "SELECT COUNT() FROM car_db" )
		local number = result[1]["COUNT()"]+1
		local val1, val2 = 6, number

		if isPointInCircle3D(t_s_salon[1][1],t_s_salon[1][2],t_s_salon[1][3], x1,y1,z1, 5) then
			if cash_car[id] == nil then
				sendMessage(playerid, "[ERROR] Этот т/с недоступен", red)
				return
			end

			for k,v in pairs(police_car) do
				if v == id and (search_inv_player(playerid, 10, 6) == 0) then
					sendMessage(playerid, "[ERROR] Вы не Шеф полиции", red)
					return
				end
			end

			if cash_car[id][2] > array_player_2[playername][1] then
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				return
			end

			if inv_player_empty(playerid, val1, val2) then
			else
				sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				return
			end

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash_car[id][2], playername )

			sendMessage(playerid, "Вы купили транспортное средство за "..cash_car[id][2].."$", orange)

			x,y,z,rot = 2120.8515625,-1136.013671875,25.287223815918,0

		elseif isPointInCircle3D(t_s_salon[2][1],t_s_salon[2][2],t_s_salon[2][3], x1,y1,z1, 5) then
			if cash_helicopters[id] == nil then
				sendMessage(playerid, "[ERROR] Этот т/с недоступен", red)
				return
			end

			for k,v in pairs(police_helicopters) do
				if v == id and (search_inv_player(playerid, 10, 6) == 0) then
					sendMessage(playerid, "[ERROR] Вы не Шеф полиции", red)
					return
				end
			end

			if cash_helicopters[id][2] > array_player_2[playername][1] then
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				return
			end

			if inv_player_empty(playerid, val1, val2) then
			else
				sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				return
			end

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash_helicopters[id][2], playername )

			sendMessage(playerid, "Вы купили транспортное средство за "..cash_helicopters[id][2].."$", orange)

			x,y,z,rot = 1582.072265625,1197.61328125,12.73429775238,0

		elseif isPointInCircle3D(t_s_salon[3][1],t_s_salon[3][2],t_s_salon[3][3], x1,y1,z1, 5) then
			if cash_boats[id] == nil then
				sendMessage(playerid, "[ERROR] Этот т/с недоступен", red)
				return
			end

			for k,v in pairs(police_boats) do
				if v == id and (search_inv_player(playerid, 10, 6) == 0) then
					sendMessage(playerid, "[ERROR] Вы не Шеф полиции", red)
					return
				end
			end

			if cash_boats[id][2] > array_player_2[playername][1] then
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				return
			end

			if inv_player_empty(playerid, val1, val2) then
			else
				sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				return
			end

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash_boats[id][2], playername )

			sendMessage(playerid, "Вы купили транспортное средство за "..cash_boats[id][2].."$", orange)

			x,y,z,rot = -2244.6,2408.7,1.8,315
		else
			sendMessage(playerid, "[ERROR] Найдите место продажи т/с", red)
			return
		end


		local vehicleid = createVehicle(id, x, y, z, 0, 0, rot, val2)
		local plate = getVehiclePlateText ( vehicleid )

		local color = {getVehicleColor ( vehicleid, true )}
		local car_rgb_text = color[1]..","..color[2]..","..color[3]
		setVehicleColor( vehicleid, color[1], color[2], color[3], color[1], color[2], color[3], color[1], color[2], color[3], color[1], color[2], color[3] )

		local color = {getVehicleHeadLightColor ( vehicleid )}
		local headlight_rgb_text = color[1]..","..color[2]..","..color[3]

		local paintjob_text = getVehiclePaintjob ( vehicleid )

		local nalog_start = 5

		setVehicleLocked ( vehicleid, true )

		array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		fuel[plate] = max_fuel
		probeg[plate] = 0

		sendMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2, orange)

		sqlite( "INSERT INTO car_db (number, model, nalog, frozen, evacuate, x, y, z, rot, fuel, car_rgb, headlight_rgb, paintjob, tune, stage, probeg, inventory) VALUES ('"..val2.."', '"..id.."', '"..nalog_start.."', '0','0', '"..x.."', '"..y.."', '"..z.."', '"..rot.."', '"..max_fuel.."', '"..car_rgb_text.."', '"..headlight_rgb_text.."', '"..paintjob_text.."', '0', '0', '0', '0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,')" )
	else
		sendMessage(playerid, "[ERROR] от 400 до 611", red)
	end
end
addEvent( "event_buycar", true )
addEventHandler ( "event_buycar", getRootElement(), buycar )

--------------------------------------вход и выход в авто--------------------------------
function enter_car ( vehicleid, seat, jacked )--евент входа в авто
	local playerid = source
	if getElementType ( playerid ) == "player" then

		local playername = getPlayerName ( playerid )
		local plate = getVehiclePlateText ( vehicleid )

		if isVehicleLocked ( vehicleid ) then
			removePedFromVehicle ( playerid )
			return
		end

		if seat == 0 then
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["nalog"] <= 0 then
					sendMessage(playerid, "[ERROR] Т/с арестован за уклонение от уплаты налогов", red)
					setVehicleEngineState(vehicleid, false)
					return
				end
			end

			if search_inv_player(playerid, 6, tonumber(plate)) ~= 0 and search_inv_player(playerid, 2, 1) ~= 0 then
				if tonumber(plate) ~= 0 then
					triggerClientEvent( playerid, "event_tab_load", playerid, "car", plate )
				end

				if fuel[plate] <= 0 then
					sendMessage(playerid, "[ERROR] Бак пуст", red)
					setVehicleEngineState(vehicleid, false)
					return
				end
			else
				sendMessage(playerid, "[ERROR] Чтобы завести т/с надо иметь ключ от т/с и права (можно купить в Мэрии)", red)
				setVehicleEngineState(vehicleid, false)
			end
		end
	end
end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), enter_car )

function exit_car_fun( playerid )
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)

	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		if getVehicleOccupant ( vehicleid, 0 ) then
			setVehicleEngineState(vehicleid, false)

			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				local x,y,z = getElementPosition(vehicleid)
				local rx,ry,rz = getElementRotation(vehicleid)

				sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."', probeg = '"..probeg[plate].."' WHERE number = '"..plate.."'")
			end
		end
	end
end

function exit_car ( vehicleid, seat, jacked )--евент выхода из авто
	local playerid = source
	if getElementType ( playerid ) == "player" then

		local playername = getPlayerName ( playerid )
		local plate = getVehiclePlateText ( vehicleid )

		if seat == 0 then
			setVehicleEngineState(vehicleid, false)

			triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )

			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				local x,y,z = getElementPosition(vehicleid)
				local rx,ry,rz = getElementRotation(vehicleid)

				sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."', probeg = '"..probeg[plate].."' WHERE number = '"..plate.."'")
			end
		end
	end
end
addEventHandler ( "onPlayerVehicleExit", getRootElement(), exit_car )

function h_down (playerid, key, keyState)--вкл выкл сирены
local playername = getPlayerName ( playerid )
local vehicleid = getPlayerVehicle(playerid)

	if keyState == "down" then
		if vehicleid then
			if not getVehicleSirensOn ( vehicleid ) then
				setVehicleSirensOn ( vehicleid, true )
			else
				setVehicleSirensOn ( vehicleid, false )
			end
		end
	end
end
-----------------------------------------------------------------------------------------

function tab_down (playerid, key, keyState)--открытие инв-ря игрока
local playername = getPlayerName ( playerid )
local vehicleid = getPlayerVehicle(playerid)
local x,y,z = getElementPosition(playerid)

	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then
		if state_gui_window[playername] == 0 then--гуи окно
			if state_inv_player[playername] == 0 and arrest[playername] == 0 then--инв-рь игрока
				for i=0,max_inv do
					triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
				end

				if vehicleid then
					local plate = getVehiclePlateText ( vehicleid )

					if search_inv_player(playerid, 6, tonumber(plate)) ~= 0 and getVehicleOccupant ( vehicleid, 0 ) and tonumber(plate) ~= 0 then
						for i=0,max_inv do
							triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )
						end
					end
				end

				if enter_house[playername][1] == 1 then
					for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
						if getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_house[v["interior"]][1] then
							local count = 0
							for k,player in pairs(getElementsByType("player")) do
								local playername2 = getPlayerName(player)
								if enter_house[playername2][2] == v["number"] then
									count = 1
									break
								end
							end

							if count == 0 then
								for i=0,max_inv do
									triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, array_house_1[v["number"]][i+1], array_house_2[v["number"]][i+1] )
								end

								enter_house[playername][2] = v["number"]

								triggerClientEvent( playerid, "event_tab_load", playerid, "house", v["number"] )
							end
							break
						end
					end
				end

				triggerClientEvent( playerid, "event_inv_create", playerid )
				state_inv_player[playername] = 1
			elseif state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_inv_delet", playerid )
				state_inv_player[playername] = 0
				enter_house[playername][2] = 0
			end
		end
	end
end

function throw_earth_server (playerid, value, id3, id1, id2, tabpanel)--выброс предмета
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local vehicleid = getPlayerVehicle(playerid)

	if value == "player" then
		for k,v in pairs(down_player_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) and id1 == v[5] then--получение прибыли за предметы
				inv_player_delet( playerid, id1, id2 )
				inv_server_load( playerid, value, 0, 1, array_player_2[playername][1]+id2, tabpanel )
				quest_player(playerid, id1)

				sendMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow)

				return
			end
		end

		for k,v in pairs(anim_player_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) and id1 == v[5] and not vehicleid then--обработка предметов
				local randomize = random(1,v[7])

				inv_player_delet( playerid, id1, id2, true )
				inv_player_empty( playerid, v[6], randomize )

				sendMessage(playerid, "Вы получили "..info_png[v[6]][1].." "..randomize.." "..info_png[v[6]][2], svetlo_zolotoy)

				--предмет для работы
				if id1 == 30 then
					local obj = object_attach(playerid, 322, 12, 0,0.03,0.07, 180,0,-90, (v[12]*1000))
					setElementInterior(obj, v[10])
					setElementDimension(obj, v[11])
				elseif id1 == 67 then
					object_attach(playerid, 341, 12, 0,0,0, 0,-90,0, (v[12]*1000))
				elseif id1 == 70 then
					object_attach(playerid, 326, 12, 0,0,0, 0,-90,0, (v[12]*1000))
				end

				setPedAnimation(playerid, v[8], v[9], -1, true, false, false, false)

				setTimer(function ()
					if isElement(playerid) then
						setPedAnimation(playerid, nil, nil)
					end
				end, (v[12]*1000), 1)

				return
			end
		end
	end

	max_earth = max_earth+1
	earth[max_earth] = {x,y,z,id1,id2}

	--[[if enter_house[playername][2] == id2 and id1 == 25 then--когда выбрасываешь ключ в инв-ре исчезают картинки(выкл из-за фичи)
		triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
		enter_house[playername][2] = 0
	end]]

	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		if getVehicleOccupant ( vehicleid, 0 ) and id2 == tonumber(plate) and id1 == 6 then--когда выбрасываешь ключ в инв-ре исчезают картинки
			triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )
		end
	end

	inv_server_load( playerid, value, id3, 0, 0, tabpanel )

	me_chat(playerid, playername.." выбросил(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
	--sendMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow)
end
addEvent( "event_throw_earth_server", true )
addEventHandler ( "event_throw_earth_server", getRootElement(), throw_earth_server )

function e_down (playerid, key, keyState)--подбор предметов с земли
	local x,y,z = getElementPosition(playerid)
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	
	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then

		for k,v in pairs(down_car_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then
				if vehicleid then
					if getElementModel(vehicleid) ~= v[6] then
						sendMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( v[6] ).."("..v[6]..")", red)
						return
					end
				end

				delet_subject(playerid, v[5])
			end
		end

		for k,v in pairs(up_car_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then
				if vehicleid then
					if getElementModel(vehicleid) ~= v[6] then
						sendMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( v[6] ).."("..v[6]..")", red)
						return
					end
				end

				give_subject(playerid, "car", v[5], random(v[7]/2,v[7]), true)
			end
		end

		for k,v in pairs(up_player_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then
				if v[9] ~= 0 then
					if getElementModel(playerid) ~= v[9] then
						sendMessage(playerid, "[ERROR] Вы должны быть в одежде "..v[9], red)
						return
					end
				end

				give_subject(playerid, "player", v[5], random(1,v[6]), true)
			end
		end

		for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
			if isPointInCircle3D(x,y,z, v["x"],v["y"],v["z"], house_bussiness_radius) then
				if vehicleid then
					if getElementModel(vehicleid) ~= down_car_subject[1][6] then
						sendMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( down_car_subject[1][6] ).."("..down_car_subject[1][6]..")", red)
						return
					end
				end

				delet_subject(playerid, 24)
			end
		end


		for i,v in pairs(earth) do
			local area = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 10 )

			if area then
				local count = false
				for k,v1 in pairs(up_player_subject) do
					if v[4] == v1[5] then
						count = true
						break
					end
				end

				if count and search_inv_player(playerid, v[4], search_inv_player_2_parameter(playerid, v[4])) >= 1 then
					sendMessage(playerid, "[ERROR] Можно переносить только один предмет", red)
					return
				end

				if inv_player_empty(playerid, v[4], v[5]) then
					
					me_chat(playerid, playername.." поднял(а) "..info_png[ v[4] ][1].." "..v[5].." "..info_png[ v[4] ][2])
					--sendMessage(playerid, "Вы подняли "..info_png[ v[4] ][1].." "..v[5].." "..info_png[ v[4] ][2], svetlo_zolotoy)

					earth[i] = nil
				else
					sendMessage(playerid, "[ERROR] Инвентарь полон", red)
				end

				return
			end
		end
	end
end

function x_down (playerid, key, keyState)
local playername = getPlayerName ( playerid )
local x,y,z = getElementPosition(playerid)
local vehicleid = getPlayerVehicle(playerid)

	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then
		if state_inv_player[playername] == 0 then--инв-рь игрока
			if state_gui_window[playername] == 0 then

				for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do--бизнесы
					if getElementDimension(playerid) == v["world"] and v["type"] == interior_business[1][2] and enter_business[playername] == 1 then--оружие
						triggerClientEvent( playerid, "event_shop_menu", playerid, v["number"], 1 )
						state_gui_window[playername] = 1
						return

					elseif getElementDimension(playerid) == v["world"] and v["type"] == interior_business[2][2] and enter_business[playername] == 1 then--одежда
						triggerClientEvent( playerid, "event_shop_menu", playerid, v["number"], 2 )
						state_gui_window[playername] = 1
						return

					elseif getElementDimension(playerid) == v["world"] and v["type"] == interior_business[3][2] and enter_business[playername] == 1 then--24/7
						triggerClientEvent( playerid, "event_shop_menu", playerid, v["number"], 3 )
						state_gui_window[playername] = 1
						return

					elseif isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and v["type"] == interior_business[4][2] then--заправка

						if v["nalog"] <= 0 then
							sendMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red)
							return
						end

						triggerClientEvent( playerid, "event_shop_menu", playerid, v["number"], 4 )
						state_gui_window[playername] = 1
						return

					elseif isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and v["type"] == interior_business[5][2] then--тюнинг

						if v["nalog"] <= 0 then
							sendMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red)
							return
						elseif not vehicleid then
							sendMessage(playerid, "[ERROR] Вы не в т/с", red)
							return
						end

						triggerClientEvent( playerid, "event_tune_create", playerid, v["number"] )
						state_gui_window[playername] = 1
						return

					elseif isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius*2) and search_inv_player(playerid, 43, v["number"]) ~= 0 then
						for j,i in pairs(interior_business) do
							if v["type"] == interior_business[j][2] then
								triggerClientEvent( playerid, "event_business_menu", playerid, v["number"] )
								state_gui_window[playername] = 1
								return
							end
						end
					end
				end


				if enter_job[playername] == 1 then--здания
					local police_station = {2,3,4,15,16,17,18}
					for k,v in pairs(police_station) do
						if interior_job[v][1] == getElementInterior(playerid) and interior_job[v][10] == getElementDimension(playerid) then
							if search_inv_player_2_parameter(playerid, 10) == 0 then
								sendMessage(playerid, "[ERROR] Вы не полицейский", red)
								return
							end

							triggerClientEvent( playerid, "event_shop_menu", playerid, -1, "pd" )
							state_gui_window[playername] = 1
							return
						end
					end

					local mayoralty = {5,7,8}
					for k,v in pairs(mayoralty) do				
						if interior_job[v][1] == getElementInterior(playerid) and interior_job[v][10] == getElementDimension(playerid) then
							triggerClientEvent( playerid, "event_shop_menu", playerid, -1, "mer" )
							state_gui_window[playername] = 1
							return
						end
					end

					local black_auc = {22}
					for k,v in pairs(black_auc) do
						if interior_job[v][1] == getElementInterior(playerid) and interior_job[v][10] == getElementDimension(playerid) then
							if crimes[playername] < crimes_giuseppe then
								sendMessage(playerid, "[ERROR] Нужно иметь "..crimes_giuseppe.." преступлений", red)
								return
							end

							triggerClientEvent( playerid, "event_shop_menu", playerid, -1, "giuseppe" )
							state_gui_window[playername] = 1
							return
						end
					end
				end

				if isPointInCircle3D(t_s_salon[1][1],t_s_salon[1][2],t_s_salon[1][3], x,y,z, 5) then
					triggerClientEvent( playerid, "event_avto_bikes_menu", playerid )
					state_gui_window[playername] = 1
					return
				elseif isPointInCircle3D(t_s_salon[2][1],t_s_salon[2][2],t_s_salon[2][3], x,y,z, 5) then
					triggerClientEvent( playerid, "event_helicopters_menu", playerid )
					state_gui_window[playername] = 1
					return
				elseif isPointInCircle3D(t_s_salon[3][1],t_s_salon[3][2],t_s_salon[3][3], x,y,z, 5) then
					triggerClientEvent( playerid, "event_boats_menu", playerid )
					state_gui_window[playername] = 1
					return
				end

			else
				triggerClientEvent( playerid, "event_gui_delet", playerid )
				state_gui_window[playername] = 0
			end
		end
	end
end

function left_alt_down (playerid, key, keyState)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local vehicleid = getPlayerVehicle(playerid)

	if logged[playername] == 0 or getElementData(playerid, "is_chat_open") == 1 then
		return
	end

	if keyState == "down" then

		for id2,v in pairs(sqlite( "SELECT * FROM house_db" )) do--вход в дома
			if not vehicleid then
				local id = v["interior"]
				local house_door = v["door"]

				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					if house_door == 0 then
						sendMessage(playerid, "[ERROR] Дверь закрыта", red)
						return
					end

					if v["nalog"] <= 0 then
						sendMessage(playerid, "[ERROR] Дом арестован за уклонение от уплаты налогов", red)
						return
					end

					enter_house[playername][1] = 1
					setElementDimension(playerid, v["world"])
					setElementInterior(playerid, interior_house[id][1], interior_house[id][3], interior_house[id][4], interior_house[id][5])
					return

				elseif getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_house[id][1] and enter_house[playername][1] == 1 then
					if house_door == 0 then
						sendMessage(playerid, "[ERROR] Дверь закрыта", red)
						return
					end

					enter_house[playername][1] = 0
					setElementDimension(playerid, 0)
					setElementInterior(playerid, 0, v["x"],v["y"],v["z"])

					if search_inv_player(playerid, 25, v["number"]) ~= 0 then
						triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
					end
					return
				end
			end
		end


		for id2,v in pairs(sqlite( "SELECT * FROM business_db" )) do--вход в бизнесы
			if not vehicleid then
				local id = v["interior"]

				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					if id == 5 or id == 4 then
						return
					end

					if v["nalog"] <= 0 then
						sendMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red)
						return
					end
					
					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 1
					setElementDimension(playerid, v["world"])
					setElementInterior(playerid, interior_business[id][1], interior_business[id][3], interior_business[id][4], interior_business[id][5])
					return

				elseif getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_business[id][1] and enter_business[playername] == 1 then

					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 0
					setElementDimension(playerid, 0)
					setElementInterior(playerid, 0, v["x"],v["y"],v["z"])
					return
				end
			end
		end


		for id,v in pairs(interior_job) do--вход в здания
			if not vehicleid then
				if isPointInCircle3D(v[6],v[7],v[8], x,y,z, 5) then
					if id == 9 or id == 10 or id == 11 or id == 12 then
						if inv_player_empty(playerid, 6, 0) then
						else
							sendMessage(playerid, "[ERROR] Инвентарь полон", red)
							return
						end
					end

					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_job[playername] = 1
					setElementDimension(playerid, v[10])
					setElementInterior(playerid, interior_job[id][1], interior_job[id][3], interior_job[id][4], interior_job[id][5])
					return

				elseif getElementInterior(playerid) == interior_job[id][1] and getElementDimension(playerid) == v[10] and enter_job[playername] == 1 then
					if id == 9 or id == 10 or id == 11 or id == 12 then
						inv_player_delet(playerid, 6, 0, true)
					end

					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_job[playername] = 0
					setElementDimension(playerid, 0)
					setElementInterior(playerid, 0, v[6],v[7],v[8])
					return
				end
			end
		end

	end
end

function give_subject( playerid, value, id1, id2, load_value )--выдача предметов игроку или авто
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local vehicleid = getPlayerVehicle(playerid)
	local count2 = 0

	if value == "player" then

		if search_inv_player(playerid, id1, search_inv_player_2_parameter(playerid, id1)) >= 1 then
			sendMessage(playerid, "[ERROR] Можно переносить только один предмет", red)
			return
		end

		if inv_player_empty(playerid, id1, id2) then

			sendMessage(playerid, "Вы получили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], svetlo_zolotoy)

			random_sub (playerid, id1)
		else
			sendMessage(playerid, "[ERROR] Инвентарь полон", red)
		end

	elseif value == "car" then--для работ по перевозке ящиков

		if vehicleid then
			count2 = amount_inv_car_1_parameter(vehicleid, 0)

			if not getVehicleOccupant ( vehicleid, 0 ) then
				return

			elseif count2 == 0 then
				sendMessage(playerid, "[ERROR] Багажник заполнен", red)
				return

			elseif id1 == 65 then
				if search_inv_player(playerid, 64, 3) == 0 then
					sendMessage(playerid, "[ERROR] Вы не инкассатор", red)
					return
				end
			elseif id1 == 24 or id1 == 73 then
				if search_inv_player(playerid, 64, 7) == 0 then
					sendMessage(playerid, "[ERROR] Вы не дальнобойщик", red)
					return
				end
			elseif id1 == 66 then
				if search_inv_player(playerid, 64, 8) == 0 then
					sendMessage(playerid, "[ERROR] Вы не перевозчик оружия", red)
					return
				end
			elseif id1 == 75 then
				if search_inv_player(playerid, 64, 2) == 0 then
					sendMessage(playerid, "[ERROR] Вы не водитель мусоровоза", red)
					return
				end
			elseif id1 == 78 then
				if search_inv_player(playerid, 64, 4) == 0 then
					sendMessage(playerid, "[ERROR] Вы не рыболов", red)
					return
				end
			elseif id1 == 88 then
				if search_inv_player(playerid, 64, 7) == 0 then
					sendMessage(playerid, "[ERROR] Вы не дальнобойщик", red)
					return
				elseif search_inv_player(playerid, 87, search_inv_player_2_parameter(playerid, 87)) == 0 then
					sendMessage(playerid, "[ERROR] Вы не работаете на скотобойне", red)
					return
				elseif not cow_farms(playerid, "load", count2, 0) then
					return
				end
			elseif id1 == 89 then
				if search_inv_player(playerid, 64, 7) == 0 then
					sendMessage(playerid, "[ERROR] Вы не дальнобойщик", red)
					return
				elseif search_inv_player(playerid, 87, search_inv_player_2_parameter(playerid, 87)) == 0 then
					sendMessage(playerid, "[ERROR] Вы не работаете на скотобойне", red)
					return
				end
			end

			inv_car_empty(playerid, id1, id2, load_value)

			sendMessage(playerid, "Вы загрузили в т/с "..info_png[id1][1].." за "..id2.."$", svetlo_zolotoy)
				
			if id1 == 24 then
				sendMessage(playerid, "[TIPS] Езжайте в порт или в любой бизнес, чтобы разгрузиться", color_tips)
			elseif id1 == 73 then
				sendMessage(playerid, "[TIPS] Езжайте в порт, чтобы разгрузиться", color_tips)
			elseif id1 == 88 then
				sendMessage(playerid, "[TIPS] Езжайте на мясокомбинат, чтобы разгрузиться", color_tips)
			elseif id1 == 89 then
				sendMessage(playerid, "[TIPS] Езжайте на скотобойню, чтобы разгрузиться", color_tips)
			end
		else
			sendMessage(playerid, "[ERROR] Вы не в т/с", red)
		end
	end

end

function delet_subject(playerid, id)--удаление предметов из авто, для работ по перевозке ящиков
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local x,y,z = getElementPosition(playerid)
	local money = 0
		
	if vehicleid then
		if not getVehicleOccupant ( vehicleid, 0 ) then
			return
		end

		local sic2p = search_inv_car_2_parameter(vehicleid, id)
		local count = search_inv_car(vehicleid, id, sic2p)

		if count ~= 0 then

			for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then

					if id ~= 24 then
						sendMessage(playerid, "[ERROR] Нужен только "..info_png[24][1], red)
						return
					end

					--[[if v["buyprod"] == 0 then
						sendMessage(playerid, "[ERROR] Цена покупки не указана", red)
						return
					end]]

					if v["warehouse"] >= max_business then
						sendMessage(playerid, "[ERROR] Склад полон", red)
						return
					end

					money = count*sic2p

					if v["money"] < money then
						sendMessage(playerid, "[ERROR] Недостаточно средств на балансе бизнеса", red)
						return
					end

					inv_car_delet(playerid, id, sic2p, true, true)

					sqlite( "UPDATE business_db SET warehouse = warehouse + '"..count.."', money = money - '"..money.."' WHERE number = '"..v["number"].."'")

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

					sendMessage(playerid, "Вы разгрузили из т/с "..info_png[id][1].." "..count.." шт за "..money.."$", green)
					return
				end
			end

			for k,v in pairs(down_car_subject) do
				if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then--места разгрузки
					if not cow_farms(playerid, "unload", count, sic2p) and not cow_farms(playerid, "unload_prod", count, sic2p) then

						inv_car_delet(playerid, id, sic2p, true, true)

						money = count*sic2p

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

						sendMessage(playerid, "Вы разгрузили из т/с "..info_png[id][1].." "..count.." шт за "..money.."$", green)
					end
					return
				end
			end
		else
			sendMessage(playerid, "[ERROR] Багажник пуст", red)
		end
	else
		sendMessage(playerid, "[ERROR] Вы не в т/с", red)
	end
end

function inv_server_load (playerid, value, id3, id1, id2, tabpanel)--изменение(сохранение) инв-ря на сервере
	local playername = getPlayerName(playerid)
	local plate = tabpanel
	local h = tabpanel

	if value == "player" then
		array_player_1[playername][id3+1] = id1
		array_player_2[playername][id3+1] = id2

		if id3+1 ~= 25 then
			setPlayerNametagColor_fun( playerid )
			
			triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, array_player_1[playername][id3+1], array_player_2[playername][id3+1] )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, value, id3, array_player_1[playername][id3+1] )
			end
		end

		sqlite( "UPDATE account SET inventory = '"..save_inv(playername, "player").."' WHERE name = '"..playername.."'")

	elseif value == "car" then
		array_car_1[plate][id3+1] = id1
		array_car_2[plate][id3+1] = id2

		triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, array_car_1[plate][id3+1], array_car_2[plate][id3+1] )

		if state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, array_car_1[plate][id3+1] )
		end

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET inventory = '"..save_inv(plate, "car").."' WHERE number = '"..plate.."'")
		end
		
	elseif value == "house" then
		array_house_1[h][id3+1] = id1
		array_house_2[h][id3+1] = id2

		triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, array_house_1[h][id3+1], array_house_2[h][id3+1] )
		
		if state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, array_house_1[h][id3+1] )
		end

		sqlite( "UPDATE house_db SET inventory = '"..save_inv(h, "house").."' WHERE number = '"..h.."'")
	end
end
addEvent( "event_inv_server_load", true )
addEventHandler ( "event_inv_server_load", getRootElement(), inv_server_load )

function use_inv (playerid, value, id3, id_1, id_2 )--использование предметов
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local x,y,z = getElementPosition(playerid)
	local id1, id2 = id_1, id_2

	if value == "player" then

-----------------------------------------------------нужды-------------------------------------------------------------
		if id1 == 3 or id1 == 7 or id1 == 8 then--сигареты
			local satiety_plus = 5

			if getElementHealth(playerid) == max_heal then
				sendMessage(playerid, "[ERROR] У вас полное здоровье", red)
				return
			end

			id2 = id2 - 1

			if id1 == 3 then
				local hp = max_heal*0.05
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendMessage(playerid, "+"..hp.." хп", yellow)

			elseif id1 == 7 then
				local hp = max_heal*0.10
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendMessage(playerid, "+"..hp.." хп", yellow)

			elseif id1 == 8 then
				local hp = max_heal*0.15
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendMessage(playerid, "+"..hp.." хп", yellow)
			end

			if satiety[playername]+satiety_plus <= max_satiety then
				satiety[playername] = satiety[playername]+satiety_plus
				sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
			end

			object_attach(playerid, 1485, 12, -0.1,0,0.04, 0,0,10, 3500)

			if vehicleid then
				setPedAnimation(playerid, "ped", "smoke_in_car", -1, false, false, false, false)
			else
				setPedAnimation(playerid, "smoking", "m_smk_drag", -1, false, false, false, false)
			end

			me_chat(playerid, playername.." выкурил(а) сигарету")

		elseif id1 == 4 then--аптечка
			if getElementHealth(playerid) == max_heal then
				sendMessage(playerid, "[ERROR] У вас полное здоровье", red)
				return
			end

			id2 = id2 - 1

			setElementHealth(playerid, max_heal)
			sendMessage(playerid, "+"..max_heal.." хп", yellow)

			me_chat(playerid, playername.." использовал(а) аптечку")

		elseif id1 == 20 then--нарко
			local satiety_plus = 20
			local sleep_plus = 20
			local drugs_plus = 1

			if getElementHealth(playerid) == max_heal then
				sendMessage(playerid, "[ERROR] У вас полное здоровье", red)
				return
			elseif drugs[playername]+drugs_plus > max_drugs then
				sendMessage(playerid, "[ERROR] У вас сильная наркозависимость", red)
				return
			end

			id2 = id2 - 1

			local hp = max_heal*0.50
			setElementHealth(playerid, getElementHealth(playerid)+hp)
			sendMessage(playerid, "+"..hp.." хп", yellow)

			drugs[playername] = drugs[playername]+drugs_plus
			sendMessage(playerid, "+"..drugs_plus.." ед. наркозависимости", yellow)

			if satiety[playername]+satiety_plus <= max_satiety then
				satiety[playername] = satiety[playername]+satiety_plus
				sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
			end

			if sleep[playername]+sleep_plus <= max_sleep then
				sleep[playername] = sleep[playername]+sleep_plus
				sendMessage(playerid, "+"..sleep_plus.." ед. сна", yellow)
			end

			object_attach(playerid, 1485, 12, -0.1,0,0.04, 0,0,10, 3500)

			if vehicleid then
				setPedAnimation(playerid, "ped", "smoke_in_car", -1, false, false, false, false)
			else
				setPedAnimation(playerid, "smoking", "m_smk_drag", -1, false, false, false, false)
			end

			me_chat(playerid, playername.." употребил(а) наркотики")

		elseif id1 == 21 or id1 == 22 then--пиво
			local alcohol_plus = 10
			local hygiene_minys = 5

			if getElementHealth(playerid) == max_heal then
				sendMessage(playerid, "[ERROR] У вас полное здоровье", red)
				return
			elseif alcohol[playername]+alcohol_plus > max_alcohol then
				sendMessage(playerid, "[ERROR] Вы сильно пьяны", red)
				return
			end

			id2 = id2 - 1

			if id1 == 21 then
				local satiety_plus = 10
				local hp = max_heal*0.20
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendMessage(playerid, "+"..hp.." хп", yellow)

				if satiety[playername]+satiety_plus <= max_satiety then
					satiety[playername] = satiety[playername]+satiety_plus
					sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
				end

			elseif id1 == 22 then
				local satiety_plus = 5
				local hp = max_heal*0.25
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendMessage(playerid, "+"..hp.." хп", yellow)

				if satiety[playername]+satiety_plus <= max_satiety then
					satiety[playername] = satiety[playername]+satiety_plus
					sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
				end
			end

			alcohol[playername] = alcohol[playername]+alcohol_plus
			sendMessage(playerid, "+"..(alcohol_plus/100).." промилле", yellow)

			if hygiene[playername]-hygiene_minys >= 0 then
				hygiene[playername] = hygiene[playername]-hygiene_minys
				sendMessage(playerid, "-"..hygiene_minys.." ед. чистоплотности", yellow)
			end

			object_attach(playerid, 1484, 11, 0.1,-0.02,0.13, 0,130,0, 2000)
			setPedAnimation(playerid, "vending", "vend_drink2_p", -1, false, false, false, false)

			me_chat(playerid, playername.." выпил(а) "..info_png[id1][1])

		elseif id1 == 72 then--виски

			if id1 == 72 then
				local alcohol_plus = 100
				local hygiene_minys = 10

				if getElementHealth(playerid) == max_heal then
					sendMessage(playerid, "[ERROR] У вас полное здоровье", red)
					return
				elseif alcohol[playername]+alcohol_plus > max_alcohol then
					sendMessage(playerid, "[ERROR] Вы сильно пьяны", red)
					return
				end

				id2 = id2 - 1

				local satiety_plus = 10
				local hp = max_heal*0.50
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendMessage(playerid, "+"..hp.." хп", yellow)

				if satiety[playername]+satiety_plus <= max_satiety then
					satiety[playername] = satiety[playername]+satiety_plus
					sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
				end

				alcohol[playername] = alcohol[playername]+alcohol_plus
				sendMessage(playerid, "+"..(alcohol_plus/100).." промилле", yellow)

				if hygiene[playername]-hygiene_minys >= 0 then
					hygiene[playername] = hygiene[playername]-hygiene_minys
					sendMessage(playerid, "-"..hygiene_minys.." ед. чистоплотности", yellow)
				end

				object_attach(playerid, 1484, 11, 0.1,-0.02,0.13, 0,130,0, 2000)
				setPedAnimation(playerid, "vending", "vend_drink2_p", -1, false, false, false, false)

				me_chat(playerid, playername.." выпил(а) "..info_png[id1][1])
			end

		elseif id1 == 53 or id1 == 54 then--бургер, пицца
			id2 = id2 - 1

			if id1 == 53 then
				local satiety_plus = 50

				if satiety[playername]+satiety_plus > max_satiety then
					sendMessage(playerid, "[ERROR] Вы не голодны", red)
					return
				end

				satiety[playername] = satiety[playername]+satiety_plus
				sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
				me_chat(playerid, playername.." съел(а) "..info_png[id1][1])

				object_attach(playerid, 2703, 12, 0.02,0.05,0.04, 0,130,0, 5000)
				setPedAnimation(playerid, "food", "eat_burger", -1, false, false, false, false)

			elseif id1 == 54 then
				local satiety_plus = 25

				if satiety[playername]+satiety_plus > max_satiety then
					sendMessage(playerid, "[ERROR] Вы не голодны", red)
					return
				end

				satiety[playername] = satiety[playername]+satiety_plus
				sendMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow)
				me_chat(playerid, playername.." съел(а) "..info_png[id1][1])

				object_attach(playerid, 2702, 12, 0,0.1,0.05, 0,270,0, 5000)
				setPedAnimation(playerid, "food", "eat_pizza", -1, false, false, false, false)
			end

		elseif id1 == 55 or id1 == 56 then--мыло, пижама

			if id1 == 55 then
				local sleep_hygiene_plus = 50

				if hygiene[playername]+sleep_hygiene_plus > max_hygiene then
					sendMessage(playerid, "[ERROR] Вы чисты", red)
					return
				end

				if enter_house[playername][1] == 1 then
					hygiene[playername] = hygiene[playername]+sleep_hygiene_plus
					sendMessage(playerid, "+"..sleep_hygiene_plus.." ед. чистоплотности", yellow)
					me_chat(playerid, playername.." помылся(ась)")
					id2 = id2 - 1

					setPedAnimation(playerid, "int_house", "wash_up", -1, false, false, false, false)

				elseif (enter_job[playername] == 1 and (interior_job[19][1] == getElementInterior(playerid) and interior_job[19][10] == getElementDimension(playerid) or interior_job[20][1] == getElementInterior(playerid) and interior_job[20][10] == getElementDimension(playerid) or interior_job[21][1] == getElementInterior(playerid) and interior_job[21][10] == getElementDimension(playerid) or interior_job[24][1] == getElementInterior(playerid) and interior_job[24][10] == getElementDimension(playerid)) ) then
				
					if (player_hotel(playerid, 55)) then
					
						id2 = id2 - 1
					else
						return
					end
				
				else 
				
					sendMessage(playerid, "[ERROR] Вы не в доме и не в отеле", red)
					return
				end

			elseif id1 == 56 then
				local sleep_hygiene_plus = 50

				if sleep[playername]+sleep_hygiene_plus > max_sleep then
					sendMessage(playerid, "[ERROR] Вы бодры", red)
					return
				end

				if enter_house[playername][1] == 1 then
					sleep[playername] = sleep[playername]+sleep_hygiene_plus
					sendMessage(playerid, "+"..sleep_hygiene_plus.." ед. сна", yellow)
					me_chat(playerid, playername.." вздремнул(а)")
					id2 = id2 - 1

				elseif (enter_job[playername] == 1 and (interior_job[19][1] == getElementInterior(playerid) and interior_job[19][10] == getElementDimension(playerid) or interior_job[20][1] == getElementInterior(playerid) and interior_job[20][10] == getElementDimension(playerid) or interior_job[21][1] == getElementInterior(playerid) and interior_job[21][10] == getElementDimension(playerid) or interior_job[24][1] == getElementInterior(playerid) and interior_job[24][10] == getElementDimension(playerid)) ) then
				
					if (player_hotel(playerid, 56)) then
					
						id2 = id2 - 1
					else
						return
					end
				
				else 
				
					sendMessage(playerid, "[ERROR] Вы не в доме и не в отеле", red)
					return
				end
			end

		elseif id1 == 42 then--лекарство от наркозависимости
			id2 = id2 - 1

			local drugs_minys = 10

			if drugs[playername]-drugs_minys < 0 then
				sendMessage(playerid, "[ERROR] У вас нет наркозависимости", red)
				return
			end

			drugs[playername] = drugs[playername]-drugs_minys
			sendMessage(playerid, "-"..drugs_minys.." ед. наркозависимости", yellow)
			me_chat(playerid, playername.." выпил(а) "..info_png[id1][1])

		elseif id1 == 76 then--антипохмелин
			id2 = id2 - 1

			local alcohol_minys = 50

			if alcohol[playername]-alcohol_minys < 0 then
				sendMessage(playerid, "[ERROR] Вы не пьяны", red)
				return
			end

			alcohol[playername] = alcohol[playername]-alcohol_minys
			sendMessage(playerid, "-"..(alcohol_minys/100).." промилле", yellow)
			me_chat(playerid, playername.." выпил(а) "..info_png[id1][1])
-----------------------------------------------------------------------------------------------------------------------

		elseif id1 == 5 then--канистра
			if vehicleid then
				local plate = getVehiclePlateText ( vehicleid )

				if getSpeed(vehicleid) < 5 then
					if fuel[plate]+id2 <= max_fuel then

						fuel[plate] = fuel[plate]+id2
						me_chat(playerid, playername.." заправил(а) т/с из канистры")
						id2 = 0

						sqlite( "UPDATE car_db SET fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")

						local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
						if result[1]["COUNT()"] == 1 then
							local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
							if result[1]["nalog"] ~= 0 and search_inv_player(playerid, 6, tonumber(plate)) ~= 0 and search_inv_player(playerid, 2, 1) ~= 0 and getVehicleOccupant(vehicleid, 0) then
								setVehicleEngineState(vehicleid, true)
							end
						end

					else
						sendMessage(playerid, "[ERROR] Максимальная вместимость бака "..max_fuel.." литров", red)
						return
					end
				else
					sendMessage(playerid, "[ERROR] Остановите т/с", red)
					return
				end
			else
				sendMessage(playerid, "[ERROR] Вы не в т/с", red)
				return
			end

		elseif id1 == 6 then
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..id2.."'" )
			if result[1]["COUNT()"] == 1 then
				local result = sqlite( "SELECT * FROM car_db WHERE number = '"..id2.."'" )

				me_chat(playerid, playername.." показал(а) документы на т/с с номером "..id2)

				do_chat(playerid, "Налог т/с оплачен на "..result[1]["nalog"].." дней - "..playername)
				do_chat(playerid, "Установлен "..result[1]["stage"].." stage - "..playername)
			end
			return

		elseif id1 == 10 then--документы копа
			if search_inv_player(playerid, 10, 1) ~= 0 then
				me_chat(playerid, "Офицер "..playername.." показал(а) "..info_png[id1][1])
			elseif search_inv_player(playerid, 10, 2) ~= 0 then
				me_chat(playerid, "Детектив "..playername.." показал(а) "..info_png[id1][1])
			elseif search_inv_player(playerid, 10, 3) ~= 0 then
				me_chat(playerid, "Сержант "..playername.." показал(а) "..info_png[id1][1])
			elseif search_inv_player(playerid, 10, 4) ~= 0 then
				me_chat(playerid, "Лейтенант "..playername.." показал(а) "..info_png[id1][1])
			elseif search_inv_player(playerid, 10, 5) ~= 0 then
				me_chat(playerid, "Капитан "..playername.." показал(а) "..info_png[id1][1])
			elseif search_inv_player(playerid, 10, 6) ~= 0 then
				me_chat(playerid, "Шеф полиции "..playername.." показал(а) "..info_png[id1][1])
			end
			return

		elseif weapon[id1] ~= nil then--оружие
			giveWeapon(playerid, weapon[id1][2], id2)
			me_chat(playerid, playername.." взял(а) в руку "..weapon[id1][1])
			id2 = 0

		elseif id1 == 11 then--планшет
			me_chat(playerid, playername.." достал(а) "..info_png[id1][1])

			triggerClientEvent( playerid, "event_inv_delet", playerid )
			triggerClientEvent( playerid, "event_tablet_fun", playerid )
			state_inv_player[playername] = 0
			state_gui_window[playername] = 1

			return

		elseif id1 == 23 then--ремонтный набор
			if vehicleid then
				if getSpeed(vehicleid) > 5 then
					sendMessage(playerid, "[ERROR] Остановите т/с", red)
					return
				end

				if getElementHealth(vehicleid) == 1000 then
					sendMessage(playerid, "[ERROR] Т/с не нуждается в ремонте", red)
					return
				end

				id2 = id2 - 1

				fixVehicle ( vehicleid )

				me_chat(playerid, playername.." починил(а) т/с")
			else
				sendMessage(playerid, "[ERROR] Вы не в т/с", red)
				return
			end

		elseif id1 == 25 then--ключ от дома
			local h = id2
			local result = sqlite( "SELECT COUNT() FROM house_db WHERE number = '"..h.."'" )
			if result[1]["COUNT()"] == 1 then

				local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )
				if getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[result[1]["interior"]][1] or isPointInCircle3D(result[1]["x"],result[1]["y"],result[1]["z"], x,y,z, house_bussiness_radius) then
					local house_door = result[1]["door"]

					if house_door == 0 then
						house_door = 1
						me_chat(playerid, playername.." открыл(а) дверь дома")
					else
						house_door = 0
						me_chat(playerid, playername.." закрыл(а) дверь дома")
					end

					sqlite( "UPDATE house_db SET door = '"..house_door.."' WHERE number = '"..h.."'")

					return
				end
			end

			me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			return

		elseif id1 == 27 then--одежда
			local skin = getElementModel(playerid)

			setElementModel(playerid, id2)

			sqlite( "UPDATE account SET skin = '"..id2.."' WHERE name = '"..playername.."'")

			id2 = skin

			me_chat(playerid, playername.." переоделся(ась)")

		elseif id1 == 29 then--рожок

			if job[playername] == 15 then
				id2 = id2-1

				sendMessage(playerid, "Расстояние до оленя: "..split(getDistanceBetweenPoints2D(job_pos[playername][1],job_pos[playername][2], x,y), ".")[1].." метров", yellow)
			else
				sendMessage(playerid, "[ERROR] Вы не Охотник", red)
				return
			end

		elseif id1 == 33 then--сонар

			if job[playername] == 17 then
				id2 = id2-1

				sendMessage(playerid, "Расстояние до груза: "..split(getDistanceBetweenPoints2D(job_pos[playername][1],job_pos[playername][2], x,y), ".")[1].." метров", yellow)
			else
				sendMessage(playerid, "[ERROR] Вы не Уборщик морского дна", red)
				return
			end

		elseif id1 == 39 then--броник
			if getPedArmor(playerid) ~= 0 then
				sendMessage(playerid, "[ERROR] На вас надет бронежилет", red)
				return
			end

			armour[playername] = createObject (1242, x, y, z)
			setObjectScale(armour[playername], 1.7)
			attachElementToBone (armour[playername], playerid, 3, 0,0.04,0.06, 5,0,0)

			setPedArmor(playerid, 100)

			id2 = id2 - 1

			me_chat(playerid, playername.." надел(а) бронежилет")

		elseif id1 == 40 then--лом
			local count = 0
			local hour, minute = getTime()
			local x1,y1 = player_position( playerid )

			if vehicleid then
				sendMessage(playerid, "[ERROR] Вы в т/с", red)
				return
			end

			if hour >= 0 and hour <= 5 then
				for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
					if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and robbery_player[playername] == 0 then
						local time_rob = 1--время для ограбления

						id2 = id2 - 1

						count = count+1

						robbery_player[playername] = 1

						me_chat(playerid, playername.." взломал(а) дверь")

						sendMessage(playerid, "Вы начали взлом", yellow )
						sendMessage(playerid, "[TIPS] Не покидайте место ограбления "..time_rob.." мин", color_tips)

						police_chat(playerid, "[ДИСПЕТЧЕР] Ограбление "..v["number"].." дома, GPS координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

						robbery_timer[playername] = setTimer(robbery, (time_rob*10000), 1, playerid, zakon_robbery_crimes, 1000, v["x"],v["y"],v["z"], house_bussiness_radius, "house - "..v["number"])

						break
					end
				end

				for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
					if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and robbery_player[playername] == 0 then
						local time_rob = 1--время для ограбления

						id2 = id2 - 1

						count = count+1

						robbery_player[playername] = 1

						me_chat(playerid, playername.." взломал(а) дверь")

						sendMessage(playerid, "Вы начали взлом", yellow )
						sendMessage(playerid, "[TIPS] Не покидайте место ограбления "..time_rob.." мин", color_tips)

						police_chat(playerid, "[ДИСПЕТЧЕР] Ограбление "..v["number"].." бизнеса, GPS координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

						robbery_timer[playername] = setTimer(robbery, (time_rob*10000), 1, playerid, zakon_robbery_crimes, 1000, v["x"],v["y"],v["z"], house_bussiness_radius, "business - "..v["number"])

						break
					end
				end

				if isPointInCircle3D(2144.18359375,1635.2705078125,993.57611083984, x,y,z, 5) and robbery_player[playername] == 0 then
					local time_rob = 1--время для ограбления

					id2 = id2 - 1

					count = count+1

					robbery_player[playername] = 1

					me_chat(playerid, playername.." взломал(а) сейф")

					sendMessage(playerid, "Вы начали взлом", yellow )
					sendMessage(playerid, "[TIPS] Не покидайте место ограбления "..time_rob.." мин", color_tips)

					police_chat(playerid, "[ДИСПЕТЧЕР] Ограбление Казино Калигула, подозреваемый "..playername)

					robbery_timer[playername] = setTimer(robbery, (time_rob*10000), 1, playerid, zakon_robbery_crimes, 2000, 2144.18359375,1635.2705078125,993.57611083984, 5, "Casino Caligulas")
				end

				if count == 0 then
					sendMessage(playerid, "[ERROR] Нужно быть около дома, бизнеса или в хранилище казино калигула; Вы уже начали ограбление", red)
					return
				end
			else
				sendMessage(playerid, "[ERROR] Ограбление доступно с 0 до 6 часов игрового времени", red)
				return
			end

		elseif id1 == 46 then--радар
			if speed_car_device[playername] == 0 then
				speed_car_device[playername] = 1

				me_chat(playerid, playername.." включил(а) "..info_png[id1][1])
			else
				speed_car_device[playername] = 0

				me_chat(playerid, playername.." выключил(а) "..info_png[id1][1])
			end
			return

		elseif id1 == 51 then--джетпак
			if isPedWearingJetpack ( playerid ) then
				setPedWearingJetpack ( playerid, false )

				me_chat(playerid, playername.." снял(а) "..info_png[id1][1])
			else
				setPedWearingJetpack ( playerid, true )

				me_chat(playerid, playername.." надел(а) "..info_png[id1][1])
			end
			return

		elseif id1 == 52 then--кислородный балон
			if getElementData(playerid, "OxygenLevel") then
				sendMessage(playerid, "[ERROR] На вас надет кислородный балон", red)
				return
			end

			id2 = id2 - 1

			triggerClientEvent( playerid, "event_setPedOxygenLevel_fun", playerid )

			me_chat(playerid, playername.." надел(а) "..info_png[id1][1])

		elseif id1 == 57 then--алкостестер
			id2 = 0
			local alcohol_test = alcohol[playername]/100
			
			me_chat(playerid, playername.." подул(а) в "..info_png[id1][1])
			do_chat(playerid, info_png[id1][1].." показал "..alcohol_test.." промилле - "..playername)

			if alcohol_test >= zakon_alcohol then
				local crimes_plus = zakon_alcohol_crimes
				crimes[playername] = crimes[playername]+crimes_plus
				sendMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername], blue)
			end

		elseif id1 == 58 then--наркостестер
			id2 = 0
			local drugs_test = drugs[playername]
			
			me_chat(playerid, playername.." смочил(а) слюной палочку")
			do_chat(playerid, info_png[id1][1].." показал "..drugs_test.."% зависимости - "..playername)

			if drugs_test >= zakon_drugs then
				local crimes_plus = zakon_drugs_crimes
				crimes[playername] = crimes[playername]+crimes_plus
				sendMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername], blue)
			end

		elseif id1 == 59 then--налог дома
			local count = 0
			for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					sqlite( "UPDATE house_db SET nalog = nalog + '"..id2.."' WHERE number = '"..v["number"].."'")
					
					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2].." и оплатил(а) "..v["number"].." дом")

					id2 = 0
					count = 1
					break
				end
			end

			if count == 0 then
				sendMessage(playerid, "[ERROR] Вы должны быть около дома", red)
				return
			end

		elseif id1 == 60 then--налог бизнеса
			local count = 0
			for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					sqlite( "UPDATE business_db SET nalog = nalog + '"..id2.."' WHERE number = '"..v["number"].."'")
					
					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2].." и оплатил(а) "..v["number"].." бизнес")

					id2 = 0
					count = 1
					break
				end
			end

			if count == 0 then
				sendMessage(playerid, "[ERROR] Вы должны быть около бизнеса", red)
				return
			end
		
		elseif id1 == 61 then--налог авто
			if vehicleid then
				local plate = getVehiclePlateText(vehicleid)
				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET nalog = nalog + '"..id2.."' WHERE number = '"..plate.."'")

					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2].." и оплатил(а) "..plate.." т/с")

					id2 = 0
				else
					sendMessage(playerid, "[ERROR] Т/с не найдено", red)
					return
				end
			else
				sendMessage(playerid, "[ERROR] Вы не в т/с", red)
				return
			end

		elseif id1 == 63 then--gps навигатор
			if gps_device[playername] == 0 then
				gps_device[playername] = 1

				me_chat(playerid, playername.." включил(а) "..info_png[id1][1])
			else
				gps_device[playername] = 0

				me_chat(playerid, playername.." выключил(а) "..info_png[id1][1])
			end
			return

		elseif id1 == 64 then--лицензии
			if id2 == 1 then
				if job[playername] == 0 then
					job[playername] = 1

					me_chat(playerid, playername.." вышел(ла) на работу Таксист")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 2 then
				if job[playername] == 0 then
					job[playername] = 2

					me_chat(playerid, playername.." вышел(ла) на работу Мусоровозчик")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 3 then
				if crimes[playername] ~= 0 then
					sendMessage(playerid, "[ERROR] У вас плохая репутация", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 3

					me_chat(playerid, playername.." вышел(ла) на работу Инкассатор")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 4 then
				if job[playername] == 0 then
					job[playername] = 4

					me_chat(playerid, playername.." вышел(ла) на работу Рыболов")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 5 then
				if getElementModel(playerid) ~= 61 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 61", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 5

					me_chat(playerid, playername.." вышел(ла) на работу Пилот")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 6 then
				if (crimes[playername] < crimes_giuseppe) then
			
					sendMessage(playerid, "[ERROR] Нужно иметь "..crimes_giuseppe.." преступлений", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 6

					me_chat(playerid, playername.." вышел(ла) на работу Угонщик")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 8 then
				if crimes[playername] ~= 0 then
					sendMessage(playerid, "[ERROR] У вас плохая репутация", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 8

					me_chat(playerid, playername.." вышел(ла) на работу Перевозчик оружия")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 9 then
				if job[playername] == 0 then
					job[playername] = 9

					me_chat(playerid, playername.." вышел(ла) на работу Водитель автобуса")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 10 then
				if crimes[playername] ~= 0 then
					sendMessage(playerid, "[ERROR] У вас плохая репутация", red)
					return
				elseif getElementModel(playerid) ~= 274 and getElementModel(playerid) ~= 275 and getElementModel(playerid) ~= 276 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 274,275,276", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 10

					me_chat(playerid, playername.." вышел(ла) на работу Парамедик")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 11 then
				if job[playername] == 0 then
					job[playername] = 11

					me_chat(playerid, playername.." вышел(ла) на работу Уборщик улиц")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 12 then
				if crimes[playername] ~= 0 then
					sendMessage(playerid, "[ERROR] У вас плохая репутация", red)
					return
				elseif getElementModel(playerid) ~= 277 and getElementModel(playerid) ~= 278 and getElementModel(playerid) ~= 279 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 277,278,279", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 12

					me_chat(playerid, playername.." вышел(ла) на работу Пожарный")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 13 then
				if crimes[playername] ~= 0 then
					sendMessage(playerid, "[ERROR] У вас плохая репутация", red)
					return
				elseif getElementModel(playerid) ~= 285 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 285", red)
					return
				elseif search_inv_player_2_parameter(playerid, 10) == 0 then
					sendMessage(playerid, "[ERROR] Вы не полицейский", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 13

					me_chat(playerid, playername.." вышел(ла) на работу SWAT")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 14 then
				if getElementModel(playerid) ~= 158 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 158", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 14

					me_chat(playerid, playername.." вышел(ла) на работу Фермер")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 15 then
				if getElementModel(playerid) ~= 312 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 312", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 15

					me_chat(playerid, playername.." вышел(ла) на работу Охотник")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 16 then
				if getElementModel(playerid) ~= 155 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 155", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 16

					me_chat(playerid, playername.." вышел(ла) на работу Развозчик пиццы")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			elseif id2 == 17 then
				if getElementModel(playerid) ~= 311 then
					sendMessage(playerid, "[ERROR] Вы должны быть в одежде 311", red)
					return
				end

				if job[playername] == 0 then
					job[playername] = 17

					me_chat(playerid, playername.." вышел(ла) на работу Уборщик морского дна")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			end

			if job[playername] == 0 then
				job_0(playername)
				car_theft_fun(playername)
			end

			return

		elseif id1 == 65 then--инкассаторский сумка
			local randomize = id2

			id2 = 0

			me_chat(playerid, playername.." открыл(а) "..info_png[id1][1])

			sendMessage(playerid, "Вы получили "..randomize.."$", green)

			local crimes_plus = zakon_65_crimes
			crimes[playername] = crimes[playername]+crimes_plus
			sendMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername], blue)

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

		elseif id1 == 66 then--ящик с оружием
			local array_weapon = {9,12,13,14,15,17,18,19,26,34,41}

			local randomize = random(1,#array_weapon)

			me_chat(playerid, playername.." открыл(а) "..info_png[id1][1])

			inv_player_delet(playerid, id1, id2)
			inv_player_empty(playerid, array_weapon[randomize], 25)

			local crimes_plus = zakon_66_crimes
			crimes[playername] = crimes[playername]+crimes_plus
			sendMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername], blue)

			return

		elseif id1 == 77 then--жетон
			if vehicleid then
				sendMessage(playerid, "[ERROR] Вы в т/с", red)
				return
			end

			if isPointInCircle3D(x,y,z, station[1][1],station[1][2],station[1][3], station[1][4]) then
				setElementPosition(playerid, station[2][1],station[2][2],station[2][3])
				id2 = id2 - 1
			elseif isPointInCircle3D(x,y,z, station[2][1],station[2][2],station[2][3], station[2][4]) then
				setElementPosition(playerid, station[3][1],station[3][2],station[3][3])
				id2 = id2 - 1
			elseif isPointInCircle3D(x,y,z, station[3][1],station[3][2],station[3][3], station[3][4]) then
				setElementPosition(playerid, station[1][1],station[1][2],station[1][3])
				id2 = id2 - 1
			else 
				sendMessage(playerid, "[ERROR] Вы должны быть около вокзала", red)
				return
			end

		elseif id1 == 79 then--чек

			if (not isPointInCircle3D(x,y,z, 2308.81640625,-13.25,26.7421875, 5)) then
			
				sendMessage(playerid, "[ERROR] Вы не около банка", red)
				return
			end

			local randomize = id2

			id2 = 0

			me_chat(playerid, playername.." обналичил(а) "..info_png[id1][1].." "..randomize.." "..info_png[id1][2])

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

		elseif id1 == 81 then--динамит
			for k,vehicleid in pairs(getElementsByType("vehicle")) do
				local x1,y1,z1 = getElementPosition( vehicleid )
				if (isPointInCircle3D(x,y,z, x1,y1,z1, 10.0) and getElementModel(vehicleid) == 428) then
					blowVehicle(vehicleid)

					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1])
					id2 = 0
					break
				end
			end

			if (id2 ~= 0) then
			
				sendMessage(playerid, "[ERROR] Рядом нет инкассаторской машины", red)
				return
			end

		elseif id1 == 84 then--отмычка
			if(vehicleid) then
			
				if(job[playername] == 6) then
				
					if(job_vehicleid[playername][1] == vehicleid) then
					
						id2 = id2-1

						setVehicleEngineState(vehicleid, true)

						me_chat(playerid, playername.." использовал(а) "..info_png[id1][1])
					
					else
					
						sendMessage(playerid, "[ERROR] Это не тот т/с", red)
						return
					end
				
				else
				
					sendMessage(playerid, "[ERROR] Вы не Угонщик", red)
					return
				end
			
			else
				local count = 0
				for k,v in pairs(getElementsByType("vehicle")) do
					local pos = {getElementPosition(v)}

					if(job[playername] == 6) then
						if isPointInCircle3D(x,y,z, pos[1],pos[2],pos[3], 5) and job_vehicleid[playername][1] == v then
							setVehicleLocked(v, false)

							id2 = id2-1
							count = 1

							me_chat(playerid, playername.." использовал(а) "..info_png[id1][1])
							break
						end
					end
				end

				if count == 0 then
					sendMessage(playerid, "[ERROR] Рядом нет нужного т/с", red)
					return
				end
			end

		elseif(id1 == 85)then--повязка
			local count = 0
			local count2 = 0
			do_chat(playerid, "на шее "..info_png[id1][1].." "..name_mafia[id2][1].." - "..playername)

			sendMessage(playerid, "====[ ПОД КОНТРОЛЕМ "..name_mafia[id2][1].." ]====", yellow)

			for k,v in pairs(guns_zone) do
				if(v[2] == id2) then
				
					count = count+1

					for k1,v1 in pairs(sqlite( "SELECT * FROM business_db" )) do
					
						if(isInsideRadarArea(v[1], v1["x"],v1["y"])) then
						
							count2 = count2+1
						end
					end
				end
			end

			sendMessage(playerid, "Территорий: "..count..", Доход: "..(count*money_guns_zone).."$", yellow)
			sendMessage(playerid, "Бизнесов: "..count2..", Доход: "..(count2*money_guns_zone_business).."$", yellow)
			return

		elseif id1 == 87 then--лиц. забойщика
			if job[playername] == 0 then
				job[playername] = 7

				me_chat(playerid, playername.." вышел(ла) на работу Забойщик скота на "..id2.." скотобойне")
			else
				job[playername] = 0

				car_theft_fun(playername)

				me_chat(playerid, playername.." закончил(а) работу")
			end
			return

		elseif id1 == 91 then--ордер
			me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..info_png[id1][id2+2])
			return

		else
			if id1 == 1 then
				return
			end

			me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			return
		end

		--------------------------------------------------------------------------------------------------------------------------------
		if id2 == 0 then
			id1, id2 = 0, 0
		end

		inv_server_load( playerid, "player", id3, id1, id2, playername )
	end
end
addEvent( "event_use_inv", true )
addEventHandler ( "event_use_inv", getRootElement(), use_inv )

-------------------------------команды игроков----------------------------------------------------------
addCommandHandler ( "sms",--смс игроку
function (playerid, cmd, id, ...)
	local playername = getPlayerName ( playerid )
	local text = ""

	if logged[playername] == 0 then
		return
	end
	
	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	if not id or text == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока] [текст]", red)
		return
	end

	local id,player = getPlayerId(id)
		
	if id then
		sendMessage(playerid, "[SMS TO] "..id.." ["..getElementData(player, "player_id")[1].."]: "..text, yellow)
		sendMessage(player, "[SMS FROM] "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text, yellow)
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)


local Red = {1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36}
local Black = {2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35}
local to1 = {1,4,7,10,13,16,19,22,25,28,31,34}
local to2 = {2,5,8,11,14,17,20,23,26,29,32,35}
local to3 = {3,6,9,12,15,18,21,24,27,30,33,36}

function roulette(playerid, randomize)
	for k,v in pairs(Red) do
		if randomize == v then
			sendMessage(playerid, "====[ РУЛЕТКА ]====", yellow)
			sendMessage(playerid, "Выпало "..randomize.." красное", yellow)
			return
		end
	end

	for k,v in pairs(Black) do
		if randomize == v then
			sendMessage(playerid, "====[ РУЛЕТКА ]====", yellow)
			sendMessage(playerid, "Выпало "..randomize.." черное", yellow)
			return
		end
	end

	if randomize == 0 then
		sendMessage(playerid, "====[ РУЛЕТКА ]====", yellow)
		sendMessage(playerid, "Выпало ZERO", yellow)
		return
	end
end

function win_roulette( playerid, cash, ratio )
	local playername = getPlayerName ( playerid )
	local money = cash*ratio

	sendMessage(playerid, "Вы заработали "..money.."$ X"..ratio, green)

	inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )
end

addCommandHandler ( "roulette",--играть в рулетку
function (playerid, cmd, id, cash)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id = tostring(id)
	local cash = tonumber(cash)
	local randomize = random(0,36)
	local roulette_game = {"красное","черное","четное","нечетное","1-18","19-36","1-12","2-12","3-12","3-1","3-2","3-3"}

	if logged[playername] == 0 then
		return
	end

	if not id or not cash then
		local text = ""
		for k,v in pairs(roulette_game) do
			text = text..v..", "
		end

		sendMessage(playerid, "[ERROR] /"..cmd.." [режим игры ("..text..")] [сумма]", red)
		return
	end

	if cash < 1 then
		return
	end

	if cash > array_player_2[playername][1] then
		sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
		return
	end

	if interior_job[14][1] == getElementInterior(playerid) and interior_job[14][10] == getElementDimension(playerid) or interior_job[13][1] == getElementInterior(playerid) and interior_job[13][10] == getElementDimension(playerid) then
		for _,j in pairs(roulette_pos) do
			if isPointInCircle3D(x,y,z, j[1],j[2],j[3], 5) then
				for k,v in pairs(roulette_game) do
					if v == id then
						roulette(playerid, randomize)

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

						if id == "красное" then
							for k,v in pairs(Red) do
								if randomize == v then
									win_roulette(playerid, cash, 2)
									return
								end
							end

						elseif id == "черное" then
							for k,v in pairs(Black) do
								if randomize == v then
									win_roulette(playerid, cash, 2)
									return
								end
							end

						elseif id == "четное" and randomize%2 == 0 then
							win_roulette(playerid, cash, 2)
							return

						elseif id == "нечетное" and randomize%2 == 1 then
							win_roulette(playerid, cash, 2)
							return

						elseif id == "1-18" and randomize >= 1 and randomize <= 18 then
							win_roulette(playerid, cash, 2)
							return

						elseif id == "19-36" and randomize >= 19 and randomize <= 36 then
							win_roulette(playerid, cash, 2)
							return

						elseif id == "1-12" and randomize >= 1 and randomize <= 12 then
							win_roulette(playerid, cash, 3)
							return

						elseif id == "2-12" and randomize >= 13 and randomize <= 24 then
							win_roulette(playerid, cash, 3)
							return

						elseif id == "3-12" and randomize >= 25 and randomize <= 36 then
							win_roulette(playerid, cash, 3)
							return

						elseif id == "3-1" then
							for k,v in pairs(to1) do
								if randomize == v then
									win_roulette(playerid, cash, 3)
									return
								end
							end

						elseif id == "3-2" then
							for k,v in pairs(to2) do
								if randomize == v then
									win_roulette(playerid, cash, 3)
									return
								end
							end

						elseif id == "3-3" then
							for k,v in pairs(to3) do
								if randomize == v then
									win_roulette(playerid, cash, 3)
									return
								end
							end
						end
						return
					end
				end

				return
			end
		end

		sendMessage(playerid, "[ERROR] Вы не у стола", red)
	else
		sendMessage(playerid, "[ERROR] Вы не в казино", red)
	end
end)

addCommandHandler ( "slots",
function (playerid, cmd, cash)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local cash = tonumber(cash)
	local randomize1 = random(1,5)
	local randomize2 = random(1,5)
	local randomize3 = random(1,5)

	if logged[playername] == 0 then
		return
	end

	if not cash then
		sendMessage(playerid, "[ERROR] /"..cmd.." [сумма]", red)
		return
	end

	if cash < 1 then
		return
	end

	if cash > array_player_2[playername][1] then
		sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
		return
	end

	if interior_job[14][1] == getElementInterior(playerid) and interior_job[14][10] == getElementDimension(playerid) or interior_job[13][1] == getElementInterior(playerid) and interior_job[13][10] == getElementDimension(playerid) then

		sendMessage(playerid, "====[ ОДНОРУКИЙ БАНДИТ ]====", yellow)
		sendMessage(playerid, "Выпало "..randomize1.." - "..randomize2.." - "..randomize3, yellow)

		inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

		if(randomize1 == randomize2 and randomize1 == randomize3) then
			win_roulette( playerid, cash, 25 )
		end

	else
		sendMessage(playerid, "[ERROR] Вы не в казино", red)
	end
end)

addCommandHandler( "setchanel",--//сменить канал в рации
function( playerid, cmd, id )

	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if not id then
		sendMessage(playerid, "[ERROR] /"..cmd.." [канал]", red)
		return
	
	elseif (logged[playername] == 0 or id <= 0) then
	
		return
	
	elseif (amount_inv_player_1_parameter(playerid, 80) == 0) then
	
		sendMessage(playerid, "[ERROR] У вас нет рации", red)
		return
	end

	inv_player_delet(playerid, 80, search_inv_player_2_parameter(playerid, 80), true)

	inv_player_empty(playerid, 80, id)

	me_chat(playerid, playername.." сменил(а) канал в рации на "..id)
end)

--[[addCommandHandler ( "blackjack",
function (playerid, cmd, id, cash)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local cash = tonumber(cash)
	local randomize1 = random(1,5)
	local randomize2 = random(1,5)
	local randomize3 = random(1,5)

	if logged[playername] == 0 then
		return
	end

	if not cash then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока] [сумма]", red)
		return
	end

	if cash < 1 then
		return
	end

	if cash > array_player_2[playername][1] then
		sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
		return
	end

	local id,player = getPlayerId(id)
		
	if id then
		local x1,y1,z1 = getElementPosition(player)
		if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then

			if arrest[id] ~= 0 then
				sendMessage(playerid, "[ERROR] Игрок в тюрьме", red)
				return
			end

			
			
		else
			sendMessage(playerid, "[ERROR] Игрок далеко", red)
		end
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)]]

addCommandHandler ( "r",--рация
function (playerid, cmd, ...)
	local playername = getPlayerName ( playerid )
	local text = ""

	if logged[playername] == 0 then
		return
	elseif (amount_inv_player_1_parameter(playerid, 80) == 0) then
		sendMessage(playerid, "[ERROR] У вас нет рации", red)
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	if text == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [текст]", red)
		return
	end

	local radio_chanel = search_inv_player_2_parameter(playerid, 80)

	if(radio_chanel == police_chanel) then
		if search_inv_player(playerid, 10, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Офицер "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		elseif search_inv_player(playerid, 10, 2) ~= 0 then
			police_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Детектив "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		elseif search_inv_player(playerid, 10, 3) ~= 0 then
			police_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Сержант "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		elseif search_inv_player(playerid, 10, 4) ~= 0 then
			police_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Лейтенант "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		elseif search_inv_player(playerid, 10, 5) ~= 0 then
			police_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Капитан "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		elseif search_inv_player(playerid, 10, 6) ~= 0 then
			police_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Шеф полиции "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		end
	elseif(radio_chanel == admin_chanel) then
		if search_inv_player_2_parameter(playerid, 44) ~= 0 then
			admin_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] Админ "..search_inv_player_2_parameter(playerid, 44).." "..info_png[44][2].." "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text)
		end
	else
		radio_chat(playerid, "[РАЦИЯ "..radio_chanel.." K] "..playername.." ["..getElementData(playerid, "player_id")[1].."]: "..text, green_rc)
	end
end)

addCommandHandler("ec",--эвакуция авто
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id = tonumber(id)
	local cash = 500

	if logged[playername] == 0 then
		return
	end

	if arrest[playername] ~= 0 or enter_house[playername][1] == 1 or enter_job[playername] == 1 or enter_business[playername] == 1 then
		return
	end

	if not id then
		sendMessage(playerid, "[ERROR] /"..cmd.." [номер т/с]", red)
		return
	end

	if cash <= array_player_2[playername][1] then
		for k,vehicleid in pairs(getElementsByType("vehicle")) do

			local plate = getVehiclePlateText(vehicleid)
			if id == tonumber(plate) then

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then

					local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
					for k,v in pairs(result) do
						
						if v["frozen"] == 0 then
							if v["evacuate"] == 1 then
								sendMessage(playerid, "[ERROR] Т/с на эвакуаторе", red)
								return
							end

							if search_inv_player(playerid, 6, id) ~= 0 then
								if (player_in_car_theft(tostring(id)) ~= 0) then
								
									sendMessage(playerid, "[ERROR] Т/с угнали", red)
									return
								end

								for k,player in pairs(getElementsByType("player")) do
									local vehicle = getPlayerVehicle(player)
									if vehicle == vehicleid then
										removePedFromVehicle ( player )
									end
								end

								if getVehicleLandingGearDown(vehicleid) ~= nil then
									setVehicleLandingGearDown(vehicleid,true)
								end

								setElementPosition(vehicleid, x+2,y,z+1)
								setElementRotation(vehicleid, 0,0,0)
								setElementDimension(vehicleid, 0)

								sqlite( "UPDATE car_db SET x = '"..(x+2).."', y = '"..y.."', z = '"..(z+1).."', fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

								sendMessage(playerid, "Вы эвакуировали т/с за "..cash.."$", orange)

							else
								sendMessage(playerid, "[ERROR] У вас нет ключа от этого т/с", red)
							end
						else
							sendMessage(playerid, "[ERROR] Т/с на штрафстоянке", red)
						end
					end
				else
					sendMessage(playerid, "[ERROR] Т/с не найдено", red)
				end

				return
			end
		end

		sendMessage(playerid, "[ERROR] Т/с не найдено", red)
	else
		sendMessage(playerid, "[ERROR] Нужно иметь "..cash.."$", red)
	end
end)

addCommandHandler("wc",--выдача чека
function (playerid, cmd, cash)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local cash = tonumber(cash)

	if not cash then
		sendMessage(playerid, "[ERROR] /"..cmd.." [сумма]", red)
		return
	end

	if logged[playername] == 0 or cash < 1 or arrest[playername] ~= 0 then
		return
	end

	if cash > array_player_2[playername][1] then
		sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
		return
	end

	if(inv_player_empty(playerid, 79, cash)) then
	
		me_chat(playerid, playername.." выписал(а) "..info_png[79][1].." "..cash.." "..info_png[79][2])

		inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )
	
	else
	
		sendMessage(playerid, "[ERROR] Инвентарь полон", red)
	end
end)

addCommandHandler ( "prison",--команда для копов (посадить игрока в тюрьму)
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local cash = 100

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока]", red)
		return
	end

	if search_inv_player_2_parameter(playerid, 10) == 0 then
		sendMessage(playerid, "[ERROR] Вы не полицейский", red)
		return
	end

	local id,player = getPlayerId(id)
		
	if id then
		local x1,y1,z1 = getElementPosition(player)
		if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then

			if arrest[id] ~= 0 then
				sendMessage(playerid, "[ERROR] Игрок в тюрьме", red)
				return
			end

			if crimes[id] == 0 then
				sendMessage(playerid, "[ERROR] Гражданин чист перед законом", red)
				return
			end

			me_chat(playerid, playername.." посадил(а) "..id.." в камеру на "..(crimes[id]).." мин")

			arrest[id] = 1

			sendMessage(playerid, "Вы получили премию "..(cash*(crimes[id])).."$", green )

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+(cash*(crimes[id])), playername )
		else
			sendMessage(playerid, "[ERROR] Игрок далеко", red)
		end
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)

addCommandHandler ( "lawyer",--выйти из тюряги за деньги
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local cash = 1000

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока]", red)
		return
	end

	local id,player = getPlayerId(id)
		
	if id then
		local x1,y1,z1 = getElementPosition(player)
		if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then

			if arrest[id] == 0 or arrest[id] == 2 then
				sendMessage(playerid, "[ERROR] Игрок не в тюрьме", red)
				return
			elseif crimes[id] == 1 then
				sendMessage(playerid, "[ERROR] Маленький срок заключения", red)
				return
			end

			if cash*crimes[id] > array_player_2[playername][1] then
				sendMessage(playerid, "[ERROR] У вас недостаточно средств", red)
				return
			end

			me_chat(playerid, playername.." заплатил(а) залог за "..id.." в размере "..(cash*(crimes[id])).."$")

			sendMessage(player, "Ждите освобождения", yellow)

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*(crimes[id])), playername )

			crimes[id] = 1
		else
			sendMessage(playerid, "[ERROR] Игрок далеко", red)
		end
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)

addCommandHandler ( "search",--команда для копов (обыскать игрока)
function (playerid, cmd, value, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local wanted_sub = {20,81,83}

	if logged[playername] == 0 then
		return
	end

	if not id or not value then
		sendMessage(playerid, "[ERROR] /"..cmd.." [player | car | house] [ИД игрока | номер т/с | номер дома]", red)
		return
	end

	if search_inv_player_2_parameter(playerid, 10) == 0 then
		sendMessage(playerid, "[ERROR] Вы не полицейский", red)
		return
	end

	if value == "player" then
		local id,player = getPlayerId(id)
		
		if id then
			local x1,y1,z1 = getElementPosition(player)

			if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then
				me_chat(playerid, playername.." обыскал(а) "..id)

				search_inv_player_police( playerid, id )
			else
				sendMessage(playerid, "[ERROR] Игрок далеко", red)
			end
		else
			sendMessage(playerid, "[ERROR] Такого игрока нет", red)
		end

	elseif value == "car" then
		for i,vehicleid in pairs(getElementsByType("vehicle")) do
			local x1,y1,z1 = getElementPosition(vehicleid)
			local plate = getVehiclePlateText(vehicleid)

			if (plate == id) then

				if(search_inv_player(playerid, 91, 2) == 0) then
					sendMessage(playerid, "[ERROR] У вас нет "..info_png[91][1].." "..info_png[91][2+2], red)
					return
				end
			
				if (isPointInCircle3D(x,y,z, x1,y1,z1, 10.0)) then
				
					me_chat(playerid, playername.." обыскал(а) т/с с номером "..id)

					inv_player_delet(playerid, 91, 2, true)

					search_inv_car_police( playerid, id )
				else
				
					sendMessage(playerid, "[ERROR] Т/с далеко", red)
				end

				return
			end
		end

		sendMessage(playerid, "[ERROR] Т/с не найдено", red)

	elseif value == "house" then
		for i,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			local id = tonumber(id)

			if (v["number"] == id) then

				if(search_inv_player(playerid, 91, 3) == 0) then
					sendMessage(playerid, "[ERROR] У вас нет "..info_png[91][1].." "..info_png[91][3+2], red)
					return
				end
			
				if (isPointInCircle3D(x,y,z, v["x"],v["y"],v["z"], 10.0)) then
				
					me_chat(playerid, playername.." обыскал(а) дом с номером "..id)

					inv_player_delet(playerid, 91, 3, true)

					search_inv_house_police( playerid, id )
				else
				
					sendMessage(playerid, "[ERROR] Дом далеко", red)
				end

				return
			end
		end

		sendMessage(playerid, "[ERROR] Дом не найден", red)
	end
end)

addCommandHandler("takepolicetoken",--забрать пол-ий жетон
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока]", red)
		return
	end

	if search_inv_player(playerid, 10, 6) == 0 then
		sendMessage(playerid, "[ERROR] Вы не Шеф полиции", red)
		return
	end

	local id,player = getPlayerId(id)
		
	if id then
		if search_inv_player(player, 10, 6) == 1 then
			sendMessage(playerid, "[ERROR] "..id.." Шеф полиции", red)
			return
		end

		if inv_player_delet(player, 10, search_inv_player_2_parameter(player, 10), true) then
			sendMessage(playerid, "Вы забрали у "..id.." "..info_png[10][1], yellow)
			sendMessage(player, playername.." забрал(а) у вас "..info_png[10][1], yellow)
		else
			sendMessage(playerid, "[ERROR] У игрока нет жетона", red)
		end
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)

addCommandHandler ( "sellhouse",--команда для риэлторов
function (playerid)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local house_count = 0
	local business_count = 0
	local job_count = 0

	if logged[playername] == 0 then
		return
	end

	if search_inv_player(playerid, 45, 1) == 0 then
		sendMessage(playerid, "[ERROR] Вы не риэлтор", red)
		return
	end

	if(array_player_2[playername][1] < zakon_price_house) then
	
		sendMessage(playerid, "[ERROR] Стоимость домов составляет "..zakon_price_house.."$", red)
		return
	end

	local result = sqlite( "SELECT COUNT() FROM house_db" )
	local house_number = result[1]["COUNT()"]
	for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
		if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius*2) then
			house_count = house_count+1
		end
	end

	local result = sqlite( "SELECT COUNT() FROM business_db" )
	local business_number = result[1]["COUNT()"]
	for h,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
		if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius*2) then
			business_count = business_count+1
		end
	end

	local job_number = #interior_job
	for h,v in pairs(interior_job) do
		if not isPointInCircle3D(v[6],v[7],v[8], x,y,z, v[12]) then
			job_count = job_count+1
		end
	end

	if business_count == business_number and house_count == house_number and job_count == job_number then
		local dim = house_number+1

		if inv_player_empty(playerid, 25, dim) then
			array_house_1[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			local house_door = 0

			house_pos[dim] = {x, y, z, createBlip ( x, y, z, 32, 0, 0,0,0,0, 0, 500 ), createPickup ( x, y, z, 3, house_icon, 10000 )}

			sqlite( "INSERT INTO house_db (number, door, nalog, x, y, z, interior, world, inventory) VALUES ('"..dim.."', '"..house_door.."', '5', '"..x.."', '"..y.."', '"..z.."', '1', '"..dim.."', '0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,0:0,')" )

			sendMessage(playerid, "Вы получили "..info_png[25][1].." "..dim.." "..info_png[25][2], orange)

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-zakon_price_house, playername )
		else
			sendMessage(playerid, "[ERROR] Инвентарь полон", red)
		end
	else
		sendMessage(playerid, "[ERROR] Рядом есть бизнес, дом или гос. здание", red)
	end
end)

addCommandHandler ( "sellbusiness",--команда для риэлторов
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local business_count = 0
	local house_count = 0
	local job_count = 0
	local id = tonumber(id)

	if logged[playername] == 0 then
		return
	end

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [номер бизнеса от 1 до "..#interior_business.."]", red)
		return
	end

	if(array_player_2[playername][1] < zakon_price_business) then
	
		sendMessage(playerid, "[ERROR] Стоимость бизнеса составляет "..zakon_price_business.."$", red)
		return
	end

	if id >= 1 and id <= #interior_business then
		if search_inv_player(playerid, 45, 1) == 0 then
			sendMessage(playerid, "[ERROR] Вы не риэлтор", red)
			return
		end

		local result = sqlite( "SELECT COUNT() FROM business_db" )
		local business_number = result[1]["COUNT()"]
		for h,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
			if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius*2) then
				business_count = business_count+1
			end
		end

		local result = sqlite( "SELECT COUNT() FROM house_db" )
		local house_number = result[1]["COUNT()"]
		for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius*2) then
				house_count = house_count+1
			end
		end

		local job_number = #interior_job
		for h,v in pairs(interior_job) do
			if not isPointInCircle3D(v[6],v[7],v[8], x,y,z, v[12]) then
				job_count = job_count+1
			end
		end

		if business_count == business_number and house_count == house_number and job_count == job_number then
			local dim = business_number+1

			if inv_player_empty(playerid, 43, dim) then
				business_pos[dim] = {x, y, z, createBlip ( x, y, z, interior_business[id][6], 0, 0,0,0,0, 0, 500 ), createPickup ( x, y, z, 3, business_icon, 10000 )}

				sqlite( "INSERT INTO business_db (number, type, price, money, nalog, warehouse, x, y, z, interior, world) VALUES ('"..dim.."', '"..interior_business[id][2].."', '0', '0', '5', '0', '"..x.."', '"..y.."', '"..z.."', '"..id.."', '"..dim.."')" )

				sendMessage(playerid, "Вы получили "..info_png[43][1].." "..dim.." "..info_png[43][2], orange)

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-zakon_price_business, playername )
			else
				sendMessage(playerid, "[ERROR] Инвентарь полон", red)
			end
		else
			sendMessage(playerid, "[ERROR] Рядом есть бизнес, дом или гос. здание", red)
		end
	else
		sendMessage(playerid, "[ERROR] от 1 до "..#interior_business, red)
	end
end)

addCommandHandler ( "buyinthouse",--команда по смене интерьера дома
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id = tonumber(id)
	local cash = 1000
	local max_interior_house = #interior_house

	if logged[playername] == 0 then
		return
	end

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [номер интерьера от 1 до "..max_interior_house.."]", red)
		return
	end

	if id >= 1 and id <= max_interior_house then
		if (cash*id) <= array_player_2[playername][1] then
			for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and getElementDimension(playerid) == 0 and getElementInterior(playerid) == 0 then
					if search_inv_player(playerid, 25, v["number"]) ~= 0 then
						sqlite( "UPDATE house_db SET interior = '"..id.."' WHERE number = '"..v["number"].."'")

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*id), playername )

						sendMessage(playerid, "Вы изменили интерьер на "..id.." за "..(cash*id).."$", orange)
					else
						sendMessage(playerid, "[ERROR] У вас нет ключа от дома", red)
					end

					return
				end
			end

			sendMessage(playerid, "[ERROR] Нужно находиться около дома", red)
		else
			sendMessage(playerid, "[ERROR] Нужно иметь "..(cash*id).."$", red)
		end
	else
		sendMessage(playerid, "[ERROR] от 1 до "..max_interior_house, red)
	end

end)

addCommandHandler ( "do",
function (playerid, cmd, ...)
	local playername = getPlayerName ( playerid )
	local text = ""

	if logged[playername] == 0 then
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	if text == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [текст]", red)
		return
	end

	do_chat_player(playerid, text.."- "..playername)
end)

addCommandHandler ( "b",
function (playerid, cmd, ...)
	local playername = getPlayerName ( playerid )
	local text = ""

	if logged[playername] == 0 then
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	if text == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [текст]", red)
		return
	end

	b_chat_player(playerid, "(Ближний OOC) "..getPlayerName( playerid ).." ["..getElementData(playerid, "player_id")[1].."]: "..text)
end)

addCommandHandler ( "try",
function (playerid, cmd, ...)
	local playername = getPlayerName ( playerid )
	local text = ""

	if logged[playername] == 0 then
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	if text == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [текст]", red)
		return
	end

	try_chat_player(playerid, playername.." "..text)
end)

addCommandHandler("capture",--захват территории
function (playerid)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)

	if (logged[playername] == 0) then
	
		return
	
	elseif(search_inv_player_2_parameter(playerid, 85) == 0) then
	
		sendMessage(playerid, "[ERROR] Вы не состоите в банде", red)
		return
	
	elseif(point_guns_zone[1] == 1) then
	
		sendMessage(playerid, "[ERROR] Идет захват территории", red)
		return

	elseif(crimes[playername] < crimes_capture) then
	
		sendMessage(playerid, "[ERROR] Нужно иметь "..crimes_capture.." преступлений", red)
		return
	end

	for k,v in pairs(guns_zone) do
		if (isInsideRadarArea(v[1], x,y) and search_inv_player_2_parameter(playerid, 85) ~= v[2]) then
		
			point_guns_zone[1] = 1
			point_guns_zone[2] = k

			point_guns_zone[3] = search_inv_player_2_parameter(playerid, 85)
			point_guns_zone[4] = 0

			point_guns_zone[5] = v[2]
			point_guns_zone[6] = 0

			setRadarAreaFlashing ( v[1], true )

			sendMessage(getRootElement(), "[НОВОСТИ] "..playername.." из "..name_mafia[search_inv_player_2_parameter(playerid, 85)][1].." захватывает территорию - "..name_mafia[v[2]][1], green)
			return
		end
	end
end)

addCommandHandler("idpng",
function (playerid)

	local playername = getPlayerName ( playerid )
	if (logged[playername] == 0) then
		return
	end

	sendMessage(playerid, "====[ ПРЕДМЕТЫ ]====", white)

	for i=1,#info_png do
		sendMessage(playerid, "["..i.."] "..info_png[i][1].." 0 "..info_png[i][2], white)
	end
end)

addCommandHandler("cc",--clear chat
function (playerid)

	local playername = getPlayerName ( playerid )
	if (logged[playername] == 0) then
		return
	end

	clearChatBox(playerid)
end)

--------------------------------------------админские команды----------------------------
addCommandHandler ( "sub",--выдача предметов с числом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), tonumber(id2)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if not val1 or not val2  then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ид предмета] [количество]", red)
		return
	end

	if val1 > #info_png or val1 < 2 then
		sendMessage(playerid, "[ERROR] от 2 до "..#info_png, red)
		return
	end

	if inv_player_empty(playerid, val1, val2) then
		sendMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme)
	else
		sendMessage(playerid, "[ERROR] Инвентарь полон", red)
	end
end)

addCommandHandler ( "subcar",--выдача предметов с числом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), tonumber(id2)
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if not val1 or not val2  then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ид предмета] [количество]", red)
		return
	end

	if val1 > #info_png or val1 < 2 then
		sendMessage(playerid, "[ERROR] от 2 до "..#info_png, red)
		return
	end

	if not vehicleid then
		sendMessage(playerid, "[ERROR] Вы не в т/с", red)
		return
	end

	if inv_car_empty(playerid, val1, val2, true) then
		sendMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme)
	else
		sendMessage(playerid, "[ERROR] Инвентарь полон", red)
	end
end)

addCommandHandler ( "subearth",--выдача предметов с числом
function (playerid, cmd, id1, id2, count )
	local val1, val2, count = tonumber(id1), tonumber(id2), tonumber(count)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if not val1 or not val2  then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ид предмета] [количество] [количество на земле]", red)
		return
	end

	if val1 > #info_png or val1 < 2 then
		sendMessage(playerid, "[ERROR] от 2 до "..#info_png, red)
		return
	end

	for i=1,count do
		max_earth = max_earth+1
		earth[max_earth] = {x,y,z,val1,val2}
	end

	sendMessage(playerid, "Вы создали на земле "..info_png[val1][1].." "..val2.." "..info_png[val1][2].." "..count.." шт", lyme)
end)

addCommandHandler ( "go",
function ( playerid, cmd, x, y, z )
	local playername = getPlayerName ( playerid )
	local x,y,z = tonumber(x), tonumber(y), tonumber(z)
	local vehicleid = getPlayerVehicle(playerid)

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if x == nil or y == nil or z == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [и 3 координаты]", red)
		return
	end

	if not vehicleid then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		spawnPlayer(playerid, x, y, z, 0, result[1]["skin"], getElementInterior(playerid), getElementDimension(playerid))
	else
		spawnVehicle(vehicleid, x,y,z)
	end
end)

addCommandHandler ( "pos",
function ( playerid, cmd, ... )
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local text = ""

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	local result = sqlite( "INSERT INTO position (description, pos) VALUES ('"..text.."', '"..x..","..y..","..z.."')" )
	sendMessage(playerid, "save pos "..text, lyme)
end)

addCommandHandler ( "global",
function ( playerid, cmd, ... )
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local text = ""

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	if text == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [текст]", red)
		return
	end

	sendMessage(getRootElement(), "[ADMIN] "..playername..": "..text, lyme)
end)

addCommandHandler ( "stime",
function ( playerid, cmd, id1, id2 )
	local playername = getPlayerName ( playerid )
	local house = tonumber(id1)
	local min = tonumber(id2)

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if house == nil or min == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [часов] [минут]", red)
		return
	end

	if house >= 0 and house <= 23 and min >= 0 and min <= 59 then
		setTime (house, min)

		sendMessage(playerid, "stime "..house..":"..min, lyme)
	end
end)

addCommandHandler ( "inv",--чекнуть инв-рь игрока
function (playerid, cmd, value, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [player | car | house] [имя игрока | номер т/с | номер дома]", red)
		return
	end

	if value == "player" then
		local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
			local text = ""

			for k,v in pairs(split(result[1]["inventory"], ",")) do
				local spl = split(v, ":")
				text = text..info_png[tonumber(spl[1])][1].." "..spl[2].." "..info_png[tonumber(spl[1])][2].."\n"
			end
			
			triggerClientEvent(playerid, "event_invsave_fun", playerid, "save", id, text)

			triggerClientEvent(playerid, "event_invsave_fun", playerid, "load", 0, 0, 0, 0)
		else
			sendMessage(playerid, "[ERROR] Такого игрока нет", red)
		end

	elseif value == "car" then
		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..id.."'" )
		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM car_db WHERE number = '"..id.."'" )
			local text = ""

			for k,v in pairs(split(result[1]["inventory"], ",")) do
				local spl = split(v, ":")
				text = text..info_png[tonumber(spl[1])][1].." "..spl[2].." "..info_png[tonumber(spl[1])][2].."\n"
			end
			
			triggerClientEvent(playerid, "event_invsave_fun", playerid, "save", "car-"..id, text)

			triggerClientEvent(playerid, "event_invsave_fun", playerid, "load", 0, 0, 0, 0)
		else
			sendMessage(playerid, "[ERROR] Такого т/с нет", red)
		end

	elseif value == "house" then
		local result = sqlite( "SELECT COUNT() FROM house_db WHERE number = '"..id.."'" )
		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM house_db WHERE number = '"..id.."'" )
			local text = ""

			for k,v in pairs(split(result[1]["inventory"], ",")) do
				local spl = split(v, ":")
				text = text..info_png[tonumber(spl[1])][1].." "..spl[2].." "..info_png[tonumber(spl[1])][2].."\n"
			end

			triggerClientEvent(playerid, "event_invsave_fun", playerid, "save", "house-"..id, text)

			triggerClientEvent(playerid, "event_invsave_fun", playerid, "load", 0, 0, 0, 0)
		else
			sendMessage(playerid, "[ERROR] Такого дома нет", red)
		end
	end
end)

function prisonplayer (playerid, cmd, id, time, ...)--(посадить игрока в тюрьму)
	local playername = getPlayerName ( playerid )
	local reason = ""
	local time = tonumber(time)

	for k,v in ipairs(arg) do
		reason = reason..v.." "
	end

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if not id or reason == "" or not time then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока] [время] [причина]", red)
		return
	end

	if time < 1 then
		return
	end

	local id,player = getPlayerId(id)
		
	if id then
		sendMessage( getRootElement(), "Администратор "..playername.." посадил в тюрьму "..id.." на "..time.." мин. Причина: "..reason, lyme)

		arrest[id] = 2
		inv_server_load (playerid, "player", 24, 92, time, playername)
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end
addCommandHandler ( "prisonplayer", prisonplayer)
addEvent("event_prisonplayer", true)
addEventHandler("event_prisonplayer", getRootElement(), prisonplayer)

--[[addCommandHandler ( "banplayer",
function ( playerid, cmd, id, ... )
	local playername = getPlayerName ( playerid )
	local reason = ""

	for k,v in ipairs(arg) do
		reason = reason..v.." "
	end

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if id == nil or reason == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока] [причина]", red)
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then

		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		if result[1]["ban"] == "1" then
			sendMessage(playerid, "[ERROR] Игрок уже забанен", red)
			return
		end

		sqlite( "UPDATE account SET ban = '1', reason = '"..reason.."' WHERE name = '"..id.."'")

		sendMessage( getRootElement(), "Администратор "..playername.." забанил "..id..". Причина: "..reason, lyme)

		local id,player = getPlayerId ( id )
		if player then
			kickPlayer(player, "banplayer reason: "..reason)
		end
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)

addCommandHandler ( "unbanplayer",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока]", red)
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then

		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		if result[1]["ban"] == "0" then
			sendMessage(playerid, "[ERROR] Игрок не забанен", red)
			return
		end

		sqlite( "UPDATE account SET ban = '0', reason = '0' WHERE name = '"..id.."'")

		sendMessage( getRootElement(), "Администратор "..playername.." разбанил "..id, lyme)
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)

addCommandHandler ( "banserial",
function ( playerid, cmd, id, ... )
	local playername = getPlayerName ( playerid )
	local reason = ""

	for k,v in ipairs(arg) do
		reason = reason..v.." "
	end

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if id == nil or reason == "" then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ИД игрока] [причина]", red)
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then

		local result = sqlite( "SELECT COUNT() FROM banserial_list WHERE name = '"..id.."'" )
		if result[1]["COUNT()"] == 1 then
			sendMessage(playerid, "[ERROR] Серийник игрока уже забанен", red)
			return
		end

		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		local result = sqlite( "INSERT INTO banserial_list (name, serial, reason) VALUES ('"..id.."', '"..result[1]["reg_serial"].."', '"..reason.."')" )

		sendMessage( getRootElement(), "Администратор "..playername.." забанил "..id.." по серийнику. Причина: "..reason, lyme)

		local id,player = getPlayerId ( id )
		if player then
			kickPlayer(player, "banserial reason: "..reason)
		end
	else
		sendMessage(playerid, "[ERROR] Такого игрока нет", red)
	end
end)]]

local obj = 0 
addCommandHandler ( "int",
function ( playerid, cmd, id0,id1,id2,id3,id4 )
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id0,id1,id2,id3,id4 = tonumber(id0),tonumber(id1),tonumber(id2),tonumber(id3),tonumber(id4)
	
	if obj == 0 then
		obj = createObject(id0, x,y,z+id1, id2,id3,id4)
	else
		destroyElement(obj)
		obj = 0
	end
end)

addCommandHandler ( "dim",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [номер виртуального мира]", red)
		return
	end

	setElementDimension ( playerid, id )
	sendMessage(playerid, "setElementDimension "..id, lyme)
end)

addCommandHandler ( "v",--спавн авто для админов
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, 1) == 0 then
		return
	end

	local id = tonumber(id)

	if id == nil then
		sendMessage(playerid, "[ERROR] /"..cmd.." [ид т/с]", red)
		return
	end

	if id >= 400 and id <= 611 then
		local number = 0

		local val1, val2 = 6, number

		--if inv_player_empty(playerid, 6, val2) then
			local x,y,z = getElementPosition( playerid )
			local vehicleid = createVehicle(id, x+5, y, z+2, 0, 0, 0, val2)
			local plate = getVehiclePlateText ( vehicleid )

			setElementInterior(vehicleid, getElementInterior(playerid))
			setElementDimension(vehicleid, getElementDimension(playerid))

			array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			fuel[plate] = max_fuel
			probeg[plate] = 0

			--setVehicleDamageProof(vehicleid, true)

			--sendMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme)
		--[[else
			sendMessage(playerid, "[ERROR] Инвентарь полон", red)
		end]]
	else
		sendMessage(playerid, "[ERROR] от 400 до 611", red)
	end
end)
-----------------------------------------------------------------------------------------

function restartAllResources()
	-- we store a table of resources
	local allResources = getResources()
	-- for each one of them,
	for index, res in ipairs(allResources) do
		-- if it's running,
		if getResourceState(res) == "running" then
			-- then restart it
			restartResource(res)
		end
	end
end

function input_Console ( text )

	if text == "z" then
		--pay_nalog()
		--print(string.find("UPDATE", "UPDATE"))

		--[[timer = setTimer(function (  )
			for k,v in pairs(getElementsByType("player")) do
				local x,y,z = getElementPosition(v)
				local result = sqlite( "INSERT INTO position (description, pos) VALUES ('job_clear_street6', '"..x..","..y..","..z.."')" )
				sendMessage(getRootElement(), "save pos "..text, lyme)
			end
		end, 5000, 0)

		for i=1,24 do

			sqlite( "INSERT INTO guns_zone (number, x1, y1, x2, y2, mafia) VALUES ('"..(i+24).."', '"..(-3000+((i-1)*250)).."', '-3000', '250', '3500', '0')" )
		end

	elseif text == "c" then
		killTimer(timer)]]

	elseif text == "x" then
		for k,v in pairs(getElementsByType("player")) do
			kickPlayer(v, "restartAllResources")
		end

		restartAllResources()
	end
end
addEventHandler ( "onConsole", getRootElement(), input_Console )

local objPick = 0
function o_pos( thePlayer )
	local x, y, z = getElementPosition (thePlayer)
	objPick = createObject (322, x, y, z)
	setObjectScale(objPick, 1.7)

	attachElementToBone (objPick, thePlayer, 12, 0,0,0, 0,0,0)
end

addCommandHandler ("orot",
function (playerid, cmd, id1, id2, id3)
	if objPick ~= 0 then
		setElementBoneRotationOffset (objPick, tonumber(id1), tonumber(id2), tonumber(id3))
	end
end)

addCommandHandler ("opos",
function (playerid, cmd, id1, id2, id3)
	if objPick ~= 0 then
		setElementBonePositionOffset (objPick, tonumber(id1), tonumber(id2), tonumber(id3))
	end
end)

addEvent("event_server_attach", true)
addEventHandler ( "event_server_attach", getRootElement(),
function ( playerid, state )
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)

	if vehicleid then
		local x,y,z = getElementPosition(vehicleid)
		if getElementModel(vehicleid) == 548 then
			for k,vehicle in pairs(getElementsByType("vehicle")) do
				local x1,y1,z1 = getElementPosition(vehicle)
				if isPointInCircle3D(x1,y1,z1, x,y,z, 10) then

					if not isElementAttached ( vehicle ) and state == "true" then
						local car_attach = attachElements ( vehicle, vehicleid, 0, 0, -4 )
						if car_attach then
							sendMessage(playerid, "т/с прикреплен", yellow)
						end
					elseif isElementAttached ( vehicle ) and state == "false" then
						detachElements  ( vehicle, vehicleid )
						sendMessage(playerid, "т/с откреплен", yellow)
					end

					return
				end
			end
		end
	end
end)

addEvent("event_server_car_door", true)
addEventHandler("event_server_car_door", getRootElement(),
function ( playerid, state )
	local x,y,z = getElementPosition(playerid)
	local playername = getPlayerName ( playerid )

	for k,vehicle in pairs(getElementsByType("vehicle")) do
		local x1,y1,z1 = getElementPosition(vehicle)
		local plate = getVehiclePlateText ( vehicle )

		if isPointInCircle3D(x,y,z, x1,y1,z1, 10) and search_inv_player(playerid, 6, tonumber(plate)) ~= 0 then
			if state == "true" then
				setVehicleLocked ( vehicle, true )
				me_chat(playerid, playername.." закрыл(а) двери")
			else
				setVehicleLocked ( vehicle, false )
				me_chat(playerid, playername.." открыл(а) двери")
			end
			return
		end
	end
end)

addEvent("event_server_car_light", true)
addEventHandler("event_server_car_light", getRootElement(),
function ( playerid, state )
	local x,y,z = getElementPosition(playerid)
	local playername = getPlayerName ( playerid )

	for k,vehicle in pairs(getElementsByType("vehicle")) do
		local x1,y1,z1 = getElementPosition(vehicle)
		local plate = getVehiclePlateText ( vehicle )

		if isPointInCircle3D(x,y,z, x1,y1,z1, 10) and search_inv_player(playerid, 6, tonumber(plate)) ~= 0 then
			if state == "true" then
				setVehicleOverrideLights ( vehicle, 2 )
			else
				setVehicleOverrideLights ( vehicle, 1 )
			end
			return
		end
	end
end)

addEvent("event_server_car_engine", true)
addEventHandler ( "event_server_car_engine", getRootElement(),
function ( playerid, state )
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	
	for k,vehicleid in pairs(getElementsByType("vehicle")) do
		local x1,y1,z1 = getElementPosition(vehicleid)
		local plate = getVehiclePlateText ( vehicleid )
		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )

		if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then
			if result[1]["COUNT()"] == 1 then
				local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["nalog"] ~= 0 and search_inv_player(playerid, 6, tonumber(plate)) ~= 0 and search_inv_player(playerid, 2, 1) ~= 0 and fuel[plate] > 0 then
					if state == "true" then
						setVehicleEngineState(vehicleid, true)
						me_chat(playerid, playername.." завел(а) двигатель")
					else
						setVehicleEngineState(vehicleid, false)
						me_chat(playerid, playername.." заглушил(а) двигатель")
					end
				end
			end

			return
		end
	end
end)

addEvent("event_server_anim_player", true)
addEventHandler("event_server_anim_player", getRootElement(),
function ( playerid, state )
	local x,y,z = getElementPosition(playerid)
	local playername = getPlayerName ( playerid )
	local spl = split(state, ",")

	if spl[1] ~= "nil" then
		if spl[3] == "true" then
			setPedAnimation(playerid, tostring(spl[1]), tostring(spl[2]), -1, true, false, false, false)
		else
			setPedAnimation(playerid, tostring(spl[1]), tostring(spl[2]), -1, false, false, false, true)
		end
	else
		setPedAnimation(playerid, nil, nil)
	end
end)