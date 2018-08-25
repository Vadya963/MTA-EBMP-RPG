local database = dbConnect( "sqlite", "ebmp-ver-4.db" )

function sqlite(text)
	local result = dbQuery( database, text )
	local result = dbPoll( result, -1 )
	return result
end

local me_radius = 10--радиус отображения действий игрока в чате
local max_inv = 23--слоты инв-ря
local max_fuel = 50--объем бака авто
local car_spawn_value = 0--чтобы ресурсы не запускались два раза

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
function sendPlayerMessage(playerid, text, r, g, b)
	outputChatBox(text, playerid, r, g, b)
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

local earth = {}--слоты земли
local max_earth = 50

for i=1,max_earth do
	earth[i] = {0,0,0,0,0}
end

function timer_earth_clear()
	local time = getRealTime()

	if time["minute"] == 30 then
		for j=1,max_earth do
			earth[j][1] = 0
			earth[j][2] = 0
			earth[j][3] = 0
			earth[j][4] = 0
			earth[j][5] = 0
		end

		for k,playerid in pairs(getElementsByType("player")) do
			sendPlayerMessage(playerid, "["..time["hour"]..":"..time["minute"]..":"..time["second"].."] [НОВОСТИ] Улицы очищенны от мусора", green[1], green[2], green[3])
		end

		print("[timer_earth_clear] clear")
	end
end

local spawnX, spawnY, spawnZ = 1642, -2240, 13

local info_png = {
	[0] = {"", ""},
	[1] = {"деньги", "$"},
	[2] = {"права на имя", ""},
	[3] = {"сигареты Big Break Red", "шт в пачке"},
	[4] = {"аптечка", "шт"},
	[5] = {"канистра с", "лит."},
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
	[23] = {"ремонтный набор", "шт"},
	[24] = {"ящик, цена продажи", "$"},
	[25] = {"ключ от дома с номером", ""},
	[26] = {"silenced", "ID"},
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
	[40] = {"лом", "ID"},
	[41] = {"sniper", "ID"},
	[42] = {"лекарство, цена продажи", "$"},
	[43] = {"лицензия на бизнес, на имя", ""},
	[44] = {"админский жетон", ""},
	[45] = {"риэлторская лицензия на имя", ""},
}

local weapon = {
	[9] = {"граната", 16},
	[12] = {"colt-45", 22},
	[13] = {"deagle", 24},
	[14] = {"AK-47", 30},
	[15] = {"M4", 31},
	[16] = {"tec-9", 32},
	[17] = {"MP5", 29},
	[18] = {"uzi", 28},
	[19] = {"дымовая граната", 17},
	[26] = {"silenced", 23},
	[34] = {"shotgun", 25},
	[35] = {"парашют", 46},
	[36] = {"дубинка", 3},
	[37] = {"бита", 5},
	[38] = {"нож", 4},
	[40] = {"лом", 15},
	[41] = {"sniper", 34},
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
	{3, "Las Venturas Planning Dep.",	374.6708,	173.8050,	1008.3893},--мерия
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
	{6, "Ammu-Nation 4",	317.2380,	-168.0520,	999.5930},
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

local interior_house = {--27
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
	{5, "Burglary House 11",	140.5631,	1369.051,	1083.864},--дорогой дом
	{9, "Burglary House 12",	85.32596,	1323.585,	1083.859},
	{9, "Burglary House 13",	260.3189,	1239.663,	1084.258},
	{10, "Burglary House 14",	21.241,		1342.153,	1084.375},
	{6, "Burglary House 15",	234.319,	1066.455,	1084.208},--дорогой дом
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
}

--инв-рь игрока
local array_player_1 = {}
local array_player_2 = {}

--инв-рь авто
local array_car_1 = {}
local array_car_2 = {}
local fuel = {}--топливный бак

--инв-рь дома
local array_house_1 = {}
local array_house_2 = {}
local house_pos = {}--позиции домов для dxDrawText
local house_door = {}--состояние двери 0-закрыта, 1-открыта

local state_inv_player = {}--состояние инв-ря игрока 0-выкл, 1-вкл
local state_gui_window = {}--состояние гуи окна 0-выкл, 1-вкл
local logged = {}--0-не вошел, 1-вошел

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
		end
	end
end

function timer_earth()--передача слотов земли на клиент
	for k,playerid in pairs(getElementsByType("player")) do
		for i=1,max_earth do
			triggerClientEvent( playerid, "event_earth_load", playerid, i, earth[i][1], earth[i][2], earth[i][3], earth[i][4], earth[i][5] )
		end
 
		local playername = getPlayerName ( playerid )
		local vehicleid = getPlayerVehicle(playerid)

		if logged[playername] ~= 0 then
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", 0, array_player_1[playername][0+1], array_player_2[playername][0+1] )

			if vehicleid then
				local veh = getVehiclePlateText(vehicleid)
				triggerClientEvent( playerid, "event_fuel_load", playerid, fuel[veh] )
			end
		end
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
			inv_server_load( playerid, "player", i, id1, id2, playername )
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
				inv_server_load( playerid, "car", i, id1, id2, plate )
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

-------------------------------эвенты----------------------------------------------------
function addVehicleUpgrade_fun( vehicleid, value, value1 )
	addVehicleUpgrade ( vehicleid, value )

	if value1 == "save" then
		local plate = getVehiclePlateText ( vehicleid )
		local upgrades = getVehicleUpgrades(vehicleid)
		local text = ""
		for k,v in pairs(upgrades) do
			text = text..v..","
		end

		print("[addVehicleUpgrade_fun] plate["..plate.."] ["..value.."]")

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE carnumber = '"..plate.."'")
		end
	end
end
addEvent( "event_addVehicleUpgrade", true )
addEventHandler ( "event_addVehicleUpgrade", getRootElement(), addVehicleUpgrade_fun )

function removeVehicleUpgrade_fun( vehicleid, value, value1 )
	removeVehicleUpgrade ( vehicleid, value )

	if value1 == "save" then
		local plate = getVehiclePlateText ( vehicleid )
		local upgrades = getVehicleUpgrades(vehicleid)
		local text = ""
		for k,v in pairs(upgrades) do
			text = text..v..","
		end

		if text == "" then
			text = "0"
		end

		print("[removeVehicleUpgrade_fun] plate["..plate.."] ["..value.."]")

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE carnumber = '"..plate.."'")
		end
	end
end
addEvent( "event_removeVehicleUpgrade", true )
addEventHandler ( "event_removeVehicleUpgrade", getRootElement(), removeVehicleUpgrade_fun )

function setVehiclePaintjob_fun( vehicleid, value, value1  )
	setVehiclePaintjob ( vehicleid, value )

	if value1 == "save" then
		local plate = getVehiclePlateText ( vehicleid )
		local text = value

		print("[setVehiclePaintjob_fun] plate["..plate.."] ["..text.."]")

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET paintjob = '"..text.."' WHERE carnumber = '"..plate.."'")
		end
	end
end
addEvent( "event_setVehiclePaintjob", true )
addEventHandler ( "event_setVehiclePaintjob", getRootElement(), setVehiclePaintjob_fun )

function setVehicleColor_fun( vehicleid, r, g, b, value1 )
	setVehicleColor( vehicleid, r, g, b, r, g, b, r, g, b, r, g, b )

	if value1 == "save" then
		local plate = getVehiclePlateText ( vehicleid )
		local text = r..","..g..","..b

		print("[setVehicleColor_fun] plate["..plate.."] ["..text.."]")

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET car_rgb = '"..text.."' WHERE carnumber = '"..plate.."'")
		end
	end
end
addEvent( "event_setVehicleColor", true )
addEventHandler ( "event_setVehicleColor", getRootElement(), setVehicleColor_fun )

function setVehicleHeadLightColor_fun( vehicleid, r, g, b, value1 )
	setVehicleHeadLightColor ( vehicleid, r, g, b )

	if value1 == "save" then
		local plate = getVehiclePlateText ( vehicleid )
		local text = r..","..g..","..b

		print("[setVehicleHeadLightColor_fun] plate["..plate.."] ["..text.."]")

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET headlight_rgb = '"..text.."' WHERE carnumber = '"..plate.."'")
		end
	end
end
addEvent( "event_setVehicleHeadLightColor", true )
addEventHandler ( "event_setVehicleHeadLightColor", getRootElement(), setVehicleHeadLightColor_fun )

function reloadWeapon(playerid)
	reloadPedWeapon(playerid)
end
addEvent("relWep", true)
addEventHandler("relWep", resourceRoot, reloadWeapon)

function kickPlayer_fun(playerid)
	kickPlayer(playerid)
end
addEvent("event_kickPlayer", true)
addEventHandler("event_kickPlayer", getRootElement(), kickPlayer_fun)
-----------------------------------------------------------------------------------------

function displayLoadedRes ( res )--старт ресурсов
	if car_spawn_value == 0 then
		car_spawn_value = 1

		setTimer(timer_earth, 1000, 0)--передача слотов земли на клиент
		setTimer(timer_earth_clear, 60000, 0)--очистка земли от предметов
		setTimer(fuel_down, 500, 0)--система топлива

		local result = sqlite( "SELECT COUNT() FROM car_db" )--спавн машин
		local carnumber_number = result[1]["COUNT()"]
		for i=1,carnumber_number do
			local result = sqlite( "SELECT * FROM car_db" )
			car_spawn(result[i]["carnumber"])
		end

		print("[number_car_spawn] "..carnumber_number)

		local result = sqlite( "SELECT COUNT() FROM house_db" )
		local house_number = result[1]["COUNT()"]
		for h=1,house_number do
			local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )
			createBlip ( result[1]["x"], result[1]["y"], result[1]["z"], 32, 0, 0,0,0,0, 0, 500 )

			house_pos[h] = {result[1]["x"], result[1]["y"], result[1]["z"]}
			house_door[h] = 0

			array_house_1[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

			for i=0,max_inv do
				array_house_1[h][i+1] = result[1]["slot_"..i.."_1"]
				array_house_2[h][i+1] = result[1]["slot_"..i.."_2"]
			end
		end

		print("[house_number] "..house_number)
	end
end
addEventHandler ( "onResourceStart", getRootElement(), displayLoadedRes )

addEventHandler("onPlayerJoin", getRootElement(),--конект игрока на сервер
function()
	local playerid = source
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)

	local result = sqlite( "SELECT COUNT() FROM banserial_list WHERE serial = '"..serial.."'" )
	if result[1]["COUNT()"] == 1 then
		kickPlayer(playerid, "kick for banserial")
		return
	end

	array_player_1[playername] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_player_2[playername] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 0 then
		triggerClientEvent( playerid, "event_reg_log_okno", playerid, "reg" )
	else
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		if result[1]["ban"] ~= "0" then
			kickPlayer(playerid, result[1]["reason"])
			return
		end

		triggerClientEvent( playerid, "event_reg_log_okno", playerid, "log" )

		--[[local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		for i=0,max_inv do
			array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
			array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
		end]]
	end

	for h,v in pairs(house_pos) do
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, h, v[1], v[2], v[3], "house" )
	end

	state_inv_player[playername] = 0
	state_gui_window[playername] = 0
	logged[playername] = 0--ИЗМЕНИТЬ НА 0!!!

	----бинд клавиш----
	bindKey(playerid, "tab", "down", tab_down )
	bindKey(playerid, "e", "down", e_down )
	bindKey(playerid, "x", "down", x_down )
	bindKey(playerid, "2", "down", to_down )

	spawnPlayer(playerid, spawnX, spawnY, spawnZ)
	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)
	setElementFrozen( playerid, true )--ИЗМЕНИТЬ НА true!!!

	for _, stat in pairs({ 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
		setPedStat(playerid, stat, 1000)
	end

	setElementDimension(playerid, 1)
end)

function quitPlayer ( quitType )--дисконект игрока с сервера
	local playerid = source
	local playername = getPlayerName ( playerid )

	if logged[playername] == 1 then
		local heal = getElementHealth( playerid )
		sqlite( "UPDATE account SET heal = '"..heal.."' WHERE name = '"..playername.."'")
	else
		
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )


function player_Spawn (playerid)--спавн игрока
	local playername = getPlayerName ( playerid )

	spawnPlayer(playerid, spawnX, spawnY, spawnZ)

	local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
	setElementModel( playerid, result[1]["skin"] )

	sqlite( "UPDATE account SET heal = '5' WHERE name = '"..playername.."'")
	setElementHealth( playerid, 5 )
end


addEventHandler( "onPlayerWasted", getRootElement(),--смерть игрока
function(ammo, attacker, weapon, bodypart)
	setTimer( player_Spawn, 5000, 1, source )
end)

function nickChangeHandler(oldNick, newNick)
	local playerid = source
	local playername = getPlayerName ( playerid )

	kickPlayer( playerid, "kick for ChangeNick" )
end
addEventHandler("onPlayerChangeNick", getRootElement(), nickChangeHandler)

----------------------------------Регистрация--------------------------------------------
function reg_fun(playerid, cmd)
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP(playerid)

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 0 then
		
		local result = sqlite( "INSERT INTO account (name, ban, reason, password, x, y, z, reg_ip, reg_serial, heal, skin, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..playername.."', '0', '0', '"..md5(cmd).."', '"..spawnX.."', '"..spawnY.."', '"..spawnZ.."', '"..ip.."', '"..serial.."', '100', '26', '1', '500', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		for i=0,max_inv do
			array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
			array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
		end

		logged[playername] = 1

		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"])
		setElementHealth( playerid, result[1]["heal"] )
		setElementModel( playerid, result[1]["skin"] )
		setElementFrozen( playerid, false )

		sendPlayerMessage(playerid, "Вы удачно зашли!", turquoise[1], turquoise[2], turquoise[3])

		print("[ACCOUNT REGISTER] "..playername)

		triggerClientEvent( playerid, "event_delet_okno", playerid )

		setElementDimension(playerid, 0)
	end
end
addEvent( "event_reg", true )
addEventHandler("event_reg", getRootElement(), reg_fun)

----------------------------------Авторизация--------------------------------------------
function log_fun(playerid, cmd)
	local playername = getPlayerName ( playerid )

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

		if md5(cmd) == result[1]["password"] then
			local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
			for i=0,max_inv do
				array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
				array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
			end

			logged[playername] = 1

			local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
			spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"])
			setElementHealth( playerid, result[1]["heal"] )
			setElementFrozen( playerid, false )

			for h,v in pairs(house_pos) do
				local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )

				if search_inv_player(playerid, 25, h) ~= 0 then
					spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"])
					break
				end
			end

			sendPlayerMessage(playerid, "Вы удачно зашли!", turquoise[1], turquoise[2], turquoise[3])

			triggerClientEvent( playerid, "event_delet_okno", playerid )

			setElementDimension(playerid, 0)

			local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
			setElementModel( playerid, result[1]["skin"] )
		else
			sendPlayerMessage(playerid, "[ERROR] Неверный пароль!", red[1], red[2], red[3])
		end
	end
end
addEvent( "event_log", true )
addEventHandler("event_log", getRootElement(), log_fun)

------------------------------------взрыв авто-------------------------------------------
function fixVehicle_fun( vehicleid )
	fixVehicle(vehicleid)
	fixVehicle(vehicleid)
end

function explode_car()
	local vehicleid = source
	local plate = getVehiclePlateText ( vehicleid )

	setTimer(fixVehicle_fun, 5000, 1, vehicleid)
	
	print("[explode_car] ["..plate.."]")
end
addEventHandler("onVehicleExplode", getRootElement(), explode_car)

function car_spawn(number)

		local plate = number
		local result = sqlite( "SELECT * FROM car_db WHERE carnumber = '"..plate.."'" )
		local vehicleid = createVehicle(result[1]["carmodel"], result[1]["x"], result[1]["y"], result[1]["z"], 0, 0, result[1]["rot"], plate)

		setVehicleLocked ( vehicleid, true )

		fuel[plate] = result[1]["fuel"]

		local spl = split(result[1]["tune"], ",")
		for k,v in pairs(spl) do
			addVehicleUpgrade_fun(vehicleid, v, "")
		end

		local spl = split(result[1]["car_rgb"], ",")
		setVehicleColor_fun(vehicleid, spl[1], spl[2], spl[3], "")

		local spl = split(result[1]["headlight_rgb"], ",")
		setVehicleHeadLightColor_fun(vehicleid, spl[1], spl[2], spl[3], "")

		setVehiclePaintjob_fun(vehicleid, result[1]["paintjob"], "")

		array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

		for i=0,max_inv do
			array_car_1[plate][i+1] = result[1]["slot_"..i.."_1"]
			array_car_2[plate][i+1] = result[1]["slot_"..i.."_2"]
		end

		print("[car_spawn] "..plate)

end

addCommandHandler ( "v",--покупка авто
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 then
		return
	end

	local id = tonumber(id)

	if id == nil then
		return
	end

	if id >= 400 and id <= 611 then
		local number = randomize_number()

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..number.."'" )
		if result[1]["COUNT()"] == 1 then
			sendPlayerMessage(playerid, "[ERROR] Этот номер числится в базе автомобилей, пожалуйста повторите попытку снова", red[1], red[2], red[3] )
			return
		end

		local val1, val2 = 6, number

		if inv_player_empty(playerid, 6, val2) then
			local x,y,z = getElementPosition( playerid )
			local vehicleid = createVehicle(id, x+5, y, z+2, 0, 0, 0, val2)
			local plate = getVehiclePlateText ( vehicleid )

			local color = {getVehicleColor ( vehicleid, true )}
			local car_rgb_text = color[1]..","..color[2]..","..color[3]

			local color = {getVehicleHeadLightColor ( vehicleid )}
			local headlight_rgb_text = color[1]..","..color[2]..","..color[3]

			local paintjob_text = getVehiclePaintjob ( vehicleid )

			setVehicleLocked ( vehicleid, true )

			array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			fuel[plate] = max_fuel

			sendPlayerMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])
			sendPlayerMessage(playerid, "spawn vehicle "..id.." ["..plate.."] "..getVehicleNameFromModel ( id ), lyme[1], lyme[2], lyme[3])

			local result = sqlite( "INSERT INTO car_db (carnumber, carmodel, x, y, z, rot, fuel, day_engine_on, car_rgb, headlight_rgb, paintjob, tune, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..val2.."', '"..id.."', '"..x.."', '"..y.."', '"..z.."', '0', '"..max_fuel.."', '0', '"..car_rgb_text.."', '"..headlight_rgb_text.."', '"..paintjob_text.."', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

			print("[buy_vehicle] "..playername.." plate["..plate.."]")
		else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] от 400 до 611", red[1], red[2], red[3])
	end
end)

--------------------------------------вход и выход в авто--------------------------------
function enter_car ( vehicleid, seat, jacked )--евент входа в авто
	local playerid = source
	local playername = getPlayerName ( playerid )
	local plate = getVehiclePlateText ( vehicleid )

	setVehicleEngineState(vehicleid, false)

	if seat == 0 then
		sendPlayerMessage( playerid, "Чтобы завести (заглушить) двигатель используйте клавишу 2", yellow[1], yellow[2], yellow[3] )
	end

	print("[Entered_Vehicle] "..playername.." seat = "..seat..", plate = "..plate)
end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), enter_car )

function exit_car ( vehicleid, seat, jacked )--евент выхода из авто
	local playerid = source
	local playername = getPlayerName ( playerid )
	local plate = getVehiclePlateText ( vehicleid )

	setVehicleEngineState(vehicleid, false)

	if seat == 0 then
		for i=0,max_inv do
			triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, 0, 0 )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "car", i, 0)
			end
		end
		triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			local x,y,z = getElementPosition(vehicleid)
			local rx,ry,rz = getElementRotation(vehicleid)

			sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE carnumber = '"..plate.."'")
		end
	end

	print("[Vehicle_Exit] "..playername.." seat = "..seat..", plate = "..plate)
end
addEventHandler ( "onPlayerVehicleExit", getRootElement(), exit_car )

function to_down (playerid, key, keyState)--вкл выкл двигатель авто
local playername = getPlayerName ( playerid )
local vehicleid = getPlayerVehicle(playerid)

	if keyState == "down" then
		if vehicleid then
			local plate = getVehiclePlateText ( vehicleid )

			if getSpeed(vehicleid) > 5 then
				sendPlayerMessage(playerid, "[ERROR] Остановите машину", red[1], red[2], red[3])
				return
			end

			if search_inv_player(playerid, 6, plate) ~= 0 and getVehicleOccupant ( vehicleid, 0 ) and search_inv_player(playerid, 2, playername) ~= 0 then
				if getVehicleEngineState(vehicleid) then
					setVehicleEngineState(vehicleid, false)
					me_chat(playerid, playername.." заглушил двигатель")
				else
					setVehicleEngineState(vehicleid, true)
					me_chat(playerid, playername.." завел двигатель")

					local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
					if result[1]["COUNT()"] == 1 then
						local time = getRealTime()
						local client_time = "Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"]

						sqlite( "UPDATE car_db SET day_engine_on = '"..client_time.."' WHERE carnumber = '"..plate.."'")
					end
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Чтобы завести авто надо выполнить 3 пункта:", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 1) нужно иметь ключ от авто", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 2) сидить на водительском месте", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 3) иметь права на свое имя", red[1], red[2], red[3])
			end
		end
	end
end

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
			if state_inv_player[playername] == 0 then--инв-рь игрока
				for i=0,max_inv do
					triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, array_player_1[playername][i+1], array_player_2[playername][i+1] )
				end

				if vehicleid then
					local plate = getVehiclePlateText ( vehicleid )

					if search_inv_player(playerid, 6, plate) ~= 0 and getVehicleOccupant ( vehicleid, 0 ) then
						for i=0,max_inv do
							triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, array_car_1[plate][i+1], array_car_2[plate][i+1] )
						end
						triggerClientEvent( playerid, "event_tab_load", playerid, "car", plate )
					end
				end

				for h,v in pairs(house_pos) do
					local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )

					if getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[result[1]["interior"]][1] and search_inv_player(playerid, 25, h) ~= 0 then
						for i=0,max_inv do
							triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, array_house_1[h][i+1], array_house_2[h][i+1] )
						end

						triggerClientEvent( playerid, "event_tab_load", playerid, "house", h )
						break
					end
				end

				triggerClientEvent( playerid, "event_inv_create", playerid )
				state_inv_player[playername] = 1
			elseif state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_inv_delet", playerid )
				state_inv_player[playername] = 0
			end
		end
	end
end

function throw_earth_server (playerid, value, id3, id1, id2, tabpanel)--выброс предмета
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local vehicleid = getPlayerVehicle(playerid)

	for j=1,max_earth do
		if earth[j][4] == 0 then

			earth[j][1] = x
			earth[j][2] = y
			earth[j][3] = z
			earth[j][4] = id1
			earth[j][5] = id2

			if search_inv_player(playerid, 25, id2) ~= 0 then--когда выбрасываешь ключ в инв-ре исчезают картинки
				for i=0,max_inv do
					triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, 0, 0 )

					if state_inv_player[playername] == 1 then
						triggerClientEvent( playerid, "event_change_image", playerid, "house", i, 0)
					end
				end
				triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
			end

			if vehicleid then
				local plate = getVehiclePlateText ( vehicleid )

				if getVehicleOccupant ( vehicleid, 0 ) and id2 == plate then--когда выбрасываешь ключ в инв-ре исчезают картинки
					for i=0,max_inv do
						triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, 0, 0 )

						if state_inv_player[playername] == 1 then
							triggerClientEvent( playerid, "event_change_image", playerid, "car", i, 0)
						end
					end
					triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )
				end
			end

			inv_server_load(playerid, value, id3, 0, 0, tabpanel)

			triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, 0, 0 )
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, 0 )

			sendPlayerMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])
			print("[throw_earth] "..playername.." [x - "..earth[j][1]..", y - "..earth[j][2]..", z - "..earth[j][3].."] ["..earth[j][4]..", "..earth[j][5].."]")

			return
		end
	end
end
addEvent( "event_throw_earth_server", true )
addEventHandler ( "event_throw_earth_server", getRootElement(), throw_earth_server )

function e_down (playerid, key, keyState)--подбор предметов с земли
local x,y,z = getElementPosition(playerid)
local playername = getPlayerName ( playerid )
	
	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then

			--[[if state_inv_player[playername] == 0 then--инв-рь игрока
				if state_gui_window[playername] == 0 then
					triggerClientEvent( playerid, "event_tune_create", playerid )
					state_gui_window[playername] = 1
				else
					triggerClientEvent( playerid, "event_tune_delet", playerid )
					state_gui_window[playername] = 0
				end
			end]]

			house_enter(playerid)

		for j=1,max_earth do
			local area = isPointInCircle3D( x, y, z, earth[j][1], earth[j][2], earth[j][3], 20 )

			if area and earth[j][4] ~= 0 then
				for i=0,max_inv do
					if array_player_1[playername][i+1] == 0 then
						inv_server_load( playerid, "player", i, earth[j][4], earth[j][5], playername )
						triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, earth[j][4], earth[j][5] )

						if state_inv_player[playername] == 1 then
							triggerClientEvent( playerid, "event_change_image", playerid, "player", i, earth[j][4])
						end

						sendPlayerMessage(playerid, "Вы подняли "..info_png[earth[j][4]][1].." "..earth[j][5].." "..info_png[earth[j][4]][2], svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])
						print("[e_down] "..playername.." [x - "..earth[j][1]..", y - "..earth[j][2]..", z - "..earth[j][3].."] ["..earth[j][4]..", "..earth[j][5].."]")

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
	end
end

function x_down (playerid, key, keyState)
local playername = getPlayerName ( playerid )

	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then
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

function house_enter(playerid)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local vehicleid = getPlayerVehicle(playerid)

	for id2,v in pairs(house_pos) do
		if not vehicleid then
			local result = sqlite( "SELECT * FROM house_db WHERE number = '"..id2.."'" )
			local id = result[1]["interior"]

			if isPointInCircle3D(result[1]["x"],result[1]["y"],result[1]["z"], x,y,z, 5) then

				if house_door[id2] == 0 then
					sendPlayerMessage(playerid, "[ERROR] Дверь закрыта", red[1], red[2], red[3] )
					return
				end

				setElementDimension(playerid, result[1]["world"])
				setElementInterior(playerid, interior_house[id][1], interior_house[id][3], interior_house[id][4], interior_house[id][5])

				if state_inv_player[playername] == 1 and search_inv_player(playerid, 25, id2) ~= 0 then
					for i=0,max_inv do
						triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, array_house_1[id2][i+1], array_house_2[id2][i+1] )
						triggerClientEvent( playerid, "event_change_image", playerid, "house", i, array_house_1[id2][i+1])
					end
					triggerClientEvent( playerid, "event_tab_load", playerid, "house", id2 )
				end
			elseif getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[id][1] then
				setElementDimension(playerid, 0)
				setElementInterior(playerid, 0, result[1]["x"],result[1]["y"],result[1]["z"])

				if state_inv_player[playername] == 1 and search_inv_player(playerid, 25, id2) ~= 0 then
					for i=0,max_inv do
						triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, 0, 0 )
						triggerClientEvent( playerid, "event_change_image", playerid, "house", i, 0)
					end
					triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
				end
			end

			return
		end
	end
end

function inv_server_load (playerid, value, id3, id1, id2, tabpanel )--изменение инв-ря на сервере
	local playername = tabpanel
	local plate = tabpanel
	local h = tabpanel
	local x,y,z = getElementPosition(playerid)

	if value == "player" then
		array_player_1[playername][id3+1] = id1
		array_player_2[playername][id3+1] = id2
		sqlite( "UPDATE account SET slot_"..id3.."_1 = '"..array_player_1[playername][id3+1].."', slot_"..id3.."_2 = '"..array_player_2[playername][id3+1].."' WHERE name = '"..playername.."'")
	elseif value == "car" then

			array_car_1[plate][id3+1] = id1
			array_car_2[plate][id3+1] = id2

			local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				sqlite( "UPDATE car_db SET slot_"..id3.."_1 = '"..array_car_1[plate][id3+1].."', slot_"..id3.."_2 = '"..array_car_2[plate][id3+1].."' WHERE carnumber = '"..plate.."'")
			end
		
	elseif value == "house" then

			local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )

			if search_inv_player(playerid, 25, h) ~= 0 then
				array_house_1[h][id3+1] = id1
				array_house_2[h][id3+1] = id2

				sqlite( "UPDATE house_db SET slot_"..id3.."_1 = '"..array_house_1[h][id3+1].."', slot_"..id3.."_2 = '"..array_house_2[h][id3+1].."' WHERE number = '"..h.."'")
			end
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

		if id1 == 6 then--ключ авто
			for k,vehicleid in pairs(getElementsByType("vehicle")) do
				local x1,y1,z1 = getElementPosition(vehicleid)
				local plate = getVehiclePlateText ( vehicleid )

				if isPointInCircle3D(x,y,z, x1,y1,z1, 5) and plate == id2 then
					if isVehicleLocked ( vehicleid ) then
						setVehicleLocked ( vehicleid, false )
						me_chat(playerid, playername.." открыл двери авто")
					else
						setVehicleLocked ( vehicleid, true )
						me_chat(playerid, playername.." закрыл двери авто")
					end
					return
				end
			end

			me_chat(playerid, playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			return

		elseif id1 == 2 or id1 == 43 or id1 == 44 or id1 == 45 then--права, лиц на бизнес, АЖ, РЛ,
			me_chat(playerid, playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			return

		elseif id1 == 3 or id1 == 7 or id1 == 8 then--сигареты
			if getElementHealth(playerid) == 100 then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1
			print("[heal_playerid - DO] "..getElementHealth(playerid))

			if id1 == 3 then
				local hp = 100*0.05
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])
			elseif id1 == 7 then
				local hp = 100*0.10
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])
			elseif id1 == 8 then
				local hp = 100*0.15
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])
			end

			me_chat(playerid, playername.." выкурил сигарету")
			print("[heal_playerid - POSLE] "..getElementHealth(playerid))

		elseif id1 == 4 then--аптечка
			if getElementHealth(playerid) == 100 then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1
			print("[heal_playerid - DO] "..getElementHealth(playerid))

			setElementHealth(playerid, 100)
			sendPlayerMessage(playerid, "+100 хп", yellow[1], yellow[2], yellow[3])

			me_chat(playerid, playername.." использовал аптечку")
			print("[heal_playerid - POSLE] "..getElementHealth(playerid))

		elseif id1 == 5 then--канистра
			if vehicleid then
				local plate = getVehiclePlateText ( vehicleid )

				if not getVehicleEngineState(vehicleid) then
					if fuel[plate]+id2 <= max_fuel then
						print("[fuel - DO] "..fuel[plate])

						fuel[plate] = fuel[plate]+id2
						me_chat(playerid, playername.." заправил машину из канистры")
						id2 = 0

						print("[fuel - POSLE] "..fuel[plate])
					else
						sendPlayerMessage(playerid, "[ERROR] Максимальная вместимость бака "..max_fuel.." литров", red[1], red[2], red[3])
						return
					end
				else
					sendPlayerMessage(playerid, "[ERROR] Заглушите двигатель", red[1], red[2], red[3])
					return
				end
			else
				return
			end

		elseif id1 == 10 then--документы копа
			if search_inv_player(playerid, 28, 1) ~= 0 then
				me_chat(playerid, "Офицер "..playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			elseif search_inv_player(playerid, 29, 1) ~= 0 then
				me_chat(playerid, "Детектив "..playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			elseif search_inv_player(playerid, 30, 1) ~= 0 then
				me_chat(playerid, "Сержант "..playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			elseif search_inv_player(playerid, 31, 1) ~= 0 then
				me_chat(playerid, "Лейтенант "..playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			elseif search_inv_player(playerid, 32, 1) ~= 0 then
				me_chat(playerid, "Капитан "..playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			elseif search_inv_player(playerid, 33, 1) ~= 0 then
				me_chat(playerid, "Шеф полиции "..playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			end
			return

		elseif weapon[id1] ~= nil then--оружие
			giveWeapon(playerid, weapon[id1][2], 25)
			me_chat(playerid, playername.." взял в руку "..weapon[id1][1])
			id2 = 0

		elseif id1 == 11 then--боеприпасы
			if getPedWeapon(playerid) == weapon[id2][2] then
				giveWeapon(playerid, weapon[id2][2], 25)
				me_chat(playerid, playername.." распаковал коробку боеприпасов")
				id2 = 0
			else
				sendPlayerMessage(playerid, "[ERROR] В руках нет оружия", red[1], red[2], red[3] )
				return
			end

		elseif id1 >= 28 and id1 <= 33 then--шевроны
			return

		elseif id1 == 20 then--нарко
			if getElementHealth(playerid) == 100 then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1

			print("[heal_playerid - DO] "..getElementHealth(playerid))

			local hp = 100*0.50
			setElementHealth(playerid, getElementHealth(playerid)+hp)
			sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])

			me_chat(playerid, playername.." употребил наркотики")
			print("[heal_playerid - POSLE] "..getElementHealth(playerid))

		elseif id1 == 21 or id1 == 22 then--пиво
			if getElementHealth(playerid) == 100 then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1

			print("[heal_playerid - DO] "..getElementHealth(playerid))

			if id1 == 21 then
				local hp = 100*0.20
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])
			elseif id1 == 22 then
				local hp = 100*0.25
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])
			end

			me_chat(playerid, playername.." выпил пиво")
			print("[heal_playerid - POSLE] "..getElementHealth(playerid))

		elseif id1 == 23 then--ремонтный набор
			if vehicleid then
				if getVehicleEngineState(vehicleid) then
					sendPlayerMessage(playerid, "[ERROR] Заглушите двигатель", red[1], red[2], red[3])
					return
				end

				if getElementHealth(vehicleid) == 1000 then
					sendPlayerMessage(playerid, "[ERROR] Авто не нуждается в ремонте", red[1], red[2], red[3] )
					return
				end

				id2 = id2 - 1
				print("[heal_vehicleid - DO] "..getElementHealth(vehicleid))

				fixVehicle ( vehicleid )

				me_chat(playerid, playername.." починил авто")
				print("[heal_vehicleid - POSLE] "..getElementHealth(vehicleid))
			else
				return
			end

		elseif id1 == 24 then--ящик
			return

		elseif id1 == 25 then--ключ от дома
				local h = id2
				local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )

				if getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[result[1]["interior"]][1] or isPointInCircle3D(result[1]["x"],result[1]["y"],result[1]["z"], x,y,z, 5) then
					if house_door[h] == 0 then
						house_door[h] = 1
						me_chat(playerid, playername.." открыл дверь дома")
					else
						house_door[h] = 0
						me_chat(playerid, playername.." закрыл дверь дома")
					end

					return
				end

			me_chat(playerid, playername.." показал "..info_png[id1][1].." "..id2.." "..info_png[id1][2])

			return

		elseif id1 == 27 then--одежда
			local skin = getElementModel(playerid)

			setElementModel(playerid, id2)

			sqlite( "UPDATE account SET skin = '"..id2.."' WHERE name = '"..playername.."'")

			id2 = skin

			me_chat(playerid, playername.." переоделся")

		elseif id1 == 39 then--броник
			if getPedArmor(playerid) ~= 0 then
				sendPlayerMessage(playerid, "[ERROR] На вас надет бронежилет", red[1], red[2], red[3] )
				return
			end

			setPedArmor(playerid, 100)

			id2 = id2 - 1

			me_chat(playerid, playername.." надел бронежилет")
		end

		-----------------------------------------------------------------------------------------------------------------------
		print("[use_inv] "..playername.." [value - "..value.."] ["..id1..", "..id2.."("..id_2..")]")

		if id2 == 0 then
			id1, id2 = 0, 0
		end

		if id2 == 0 then
			triggerClientEvent( playerid, "event_change_image", playerid, "player", id3, id1)
		end

		inv_server_load(playerid, "player", id3, id1, id2, playername)
		triggerClientEvent( playerid, "event_inv_load", playerid, "player", id3, id1, id2 )
	end
end
addEvent( "event_use_inv", true )
addEventHandler ( "event_use_inv", getRootElement(), use_inv )

function give_subject( playerid, id3, id1, id2 )

end
addEvent( "event_give_subject", true )
addEventHandler ( "event_give_subject", getRootElement(), give_subject )

addCommandHandler ( "sellhouse",--команда для риэлторов
function (playerid)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local house_count = 0

	if logged[playername] == 0 then
		return
	end

	if search_inv_player(playerid, 45, playername) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не риэлтор", red[1], red[2], red[3] )
		return
	end

	local result = sqlite( "SELECT COUNT() FROM house_db" )
	local house_number = result[1]["COUNT()"]
	for i=1,house_number do

		local result = sqlite( "SELECT * FROM house_db WHERE number = '"..i.."'" )
		if not isPointInCircle3D(result[1]["x"],result[1]["y"],result[1]["z"], x,y,z, 5) then
			house_count = house_count+1
		end
	end

	if house_count == house_number then
		local dim = house_number+1

		if inv_player_empty(playerid, 25, dim) then
			house_pos[dim] = {x,y,z}
			array_house_1[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			house_door[dim] = 0

			createBlip ( house_pos[dim][1], house_pos[dim][2], house_pos[dim][3], 32, 0, 0,0,0,0, 0, 500 )

			sqlite( "INSERT INTO house_db (number, x, y, z, interior, world, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..dim.."', '"..x.."', '"..y.."', '"..z.."', '"..interior_house[1][1].."', '"..dim.."', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )
			sendPlayerMessage(playerid, "Вы получили "..info_png[25][1].." "..dim.." "..info_png[25][2], orange[1], orange[2], orange[3])
			
			triggerClientEvent( playerid, "event_bussines_house_fun", playerid, dim, house_pos[dim][1], house_pos[dim][2], house_pos[dim][3], "house" )
		else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Рядом есть дом", red[1], red[2], red[3] )
	end
end)

addCommandHandler ( "interiorhouse",--команда по смене интерьера дома
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 then
		return
	end

	if id == nil then
		return
	end

	if id >= 1 and id <= 27 then
		for h,v in pairs(house_pos) do
			if search_inv_player(playerid, 25, h) ~= 0 and getElementDimension(playerid) == 0 and getElementInterior(playerid) == 0 then
				sqlite( "UPDATE house_db SET interior = '"..id.."' WHERE number = '"..h.."'")

				sendPlayerMessage(playerid, "Вы изменили интерьер на "..id, orange[1], orange[2], orange[3])
				return
			end
		end

		sendPlayerMessage(playerid, "[ERROR] У вас нет дома или вы в доме", red[1], red[2], red[3] )
	else
		sendPlayerMessage(playerid, "[ERROR] от 1 до 27", red[1], red[2], red[3] )
	end

end)

--------------------------------------------админские команды----------------------------
addCommandHandler ( "sub",--выдача предметов с числом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), tonumber(id2)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if val1 == nil or val2 == nil then
		return
	end

	if inv_player_empty(playerid, val1, val2) then
		sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
	end
end)

local sub_text = {2,6,10,43,44,45}
addCommandHandler ( "subt",--выдача предметов с текстом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), id2
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if val1 == nil or val2 == nil then
		return
	end

	for k,v in pairs(sub_text) do
		if val1 == v then
			if inv_player_empty(playerid, val1, val2) then
				sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])
			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
			end
		end
	end
end)

addCommandHandler ( "go",
function ( playerid, cmd, x, y, z )
	local playername = getPlayerName ( playerid )
	local x,y,z = tonumber(x), tonumber(y), tonumber(z)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if x == nil or y == nil or z == nil then
		return
	end

	spawnPlayer(playerid, x, y, z)

	local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
	setElementModel( playerid, result[1]["skin"] )
end)

--[[Muting commands
addCommandHandler ( "mutevoice",
	function (playerid, cmd, playerName )
		if not playerName then
			sendPlayerMessage (playerid, "[ERROR] Syntax: muteplayer <playerName>", red[1], red[2], red[3] )
			return
		end

		local player = getPlayerFromName ( playerName )
		if not player then
			sendPlayerMessage (playerid, "[ERROR] mutevoice: не в сети '"..playerName.."'", red[1], red[2], red[3] )
			return
		end

		if isPlayerMuted ( player ) then
			sendPlayerMessage (playerid, "[ERROR] mutevoice: '"..playerName.."' уже приглушен", red[1], red[2], red[3] )
			return
		end

		if player == playerid then
			sendPlayerMessage (playerid, "[ERROR] mutevoice: Самого себя нельзя приглушить", red[1], red[2], red[3] )
			return
		end

		setPlayerMuted ( player, true )
		sendPlayerMessage (playerid, "mutevoice: '"..playerName.."' игрок приглушен", lyme[1], lyme[2], lyme[3] )
		print("[admin_mute] "..getPlayerName(playerid).." mute "..playerName)
	end
)

addCommandHandler ( "unmutevoice",
	function (playerid, cmd, playerName )
		if not playerName then
			sendPlayerMessage (playerid, "[ERROR] Syntax: unmuteplayer <playerName>", red[1], red[2], red[3] )
			return
		end

		local player = getPlayerFromName ( playerName )
		if not player then
			sendPlayerMessage (playerid, "[ERROR] unmutevoice: не в сети '"..playerName.."'", red[1], red[2], red[3] )
			return
		end

		if not isPlayerMuted ( player ) then
			sendPlayerMessage (playerid, "[ERROR] unmutevoice: '"..playerName.."' не был приглушен", red[1], red[2], red[3] )
			return
		end

		setPlayerMuted ( player, false )
		sendPlayerMessage (playerid, "unmutevoice: '"..playerName.."' игрок снова может говорить", lyme[1], lyme[2], lyme[3] )
		print("[admin_unmute] "..getPlayerName(playerid).." unmute "..playerName)
	end
)]]

addCommandHandler ( "int",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		return
	end

	if interior_house[id] ~= nil then
		setElementInterior(playerid, 0)
		setElementInterior(playerid, interior_house[id][1], interior_house[id][3], interior_house[id][4], interior_house[id][5])
		sendPlayerMessage(playerid, "interior "..interior_house[id][2])
	else
		setElementInterior(playerid, 0, spawnX, spawnY, spawnZ)
	end
end)

addCommandHandler ( "dim",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		return
	end

	setElementDimension ( playerid, id )
	sendPlayerMessage(playerid, "setElementDimension "..id)
end)
-----------------------------------------------------------------------------------------

function input_Console ( text )

	if text == "z" then
		--[[local hFile = fileOpen("businesses.txt")

		local spl = split(fileRead(hFile, fileGetSize ( hFile )), ",")
		for i=1,108 do
			--print(spl[i*6-5]..","..spl[i*6-4]..","..spl[i*6-3])
			createBlip ( spl[i*6-5], spl[i*6-4], spl[i*6-3], 0, 2, 255,255,0 )
		end]]

		

	elseif text == "x" then
		local allResources = getResources()
		for index, res in ipairs(allResources) do
			if getResourceState(res) == "running" then
				restartResource(res)
			end
		end
	end
end
addEventHandler ( "onConsole", getRootElement(), input_Console )