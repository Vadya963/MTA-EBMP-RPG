local database = dbConnect( "sqlite", "ebmp-ver-4.db" )
function sqlite(text)
	local result = dbQuery( database, text )
	local result = dbPoll( result, -1 )
	return result
end

local database_save_player_action = dbConnect( "sqlite", "save_player_action.db" )
function sqlite_save_player_action(text)
	local result = dbQuery( database_save_player_action, text )
	local result = dbPoll( result, -1 )
	return result
end

local earth = {}--слоты земли
local max_earth = 0

local me_radius = 10--радиус отображения действий игрока в чате
local max_inv = 23--слоты инв-ря
local max_fuel = 50--объем бака авто
local car_spawn_value = 0--чтобы ресурсы не запускались два раза
local max_blip = 250--радиус блипов
local house_bussiness_radius = 5--радиус размещения бизнесов и домов
local tomorrow_weather = 0--погода
local spawnX, spawnY, spawnZ = 1642, -2240, 13--стартовая позиция
local max_heal = 200--макс здоровье игрока
local house_icon = 1273--пикап дома
local business_icon = 1274--пикап бизнеса
local job_icon = 1318--пикап работ
local time_nalog = 12--время когда будет взиматься налог

--зарплаты--
local zp_box = 10--зп за ящик
local zp_pig = 10--зп за тушку свиньи

----цвета----
local color_tips = {168,228,160}--бабушкины яблоки
local yellow = {255,255,0}--желтый
local red = {255,0,0}--красный
local blue = {0,150,255}--синий
local white = {255,255,255}--белый
local green = {0,255,0}--зеленый
local turquoise = {0,255,255}--бирюзовый
local orange = {255,100,0}--оранжевый
local orange_do = {255,150,0}--оранжевый do
local pink = {255,100,255}--розовый
local lyme = {130,255,0}--лайм админский цвет
local svetlo_zolotoy = {255,255,130}--светло-золотой

-------------------пользовательские функции----------------------------------------------
function sendPlayerMessage(playerid, text, r, g, b)
	local time = getRealTime()

	outputChatBox("[ "..time["hour"]..":"..time["minute"]..":"..time["second"].." ] "..text, playerid, r, g, b)
end

local car_shtraf_stoyanka = createColRectangle( 2054.1,2367.5, 62, 70 )
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

function do_chat(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendPlayerMessage(player, text, orange_do[1], orange_do[2], orange_do[3])
		end
	end
end

function ic_chat(playerid, text)
	local x,y,z = getElementPosition(playerid)

	for k,player in pairs(getElementsByType("player")) do
		local x1,y1,z1 = getElementPosition(player)

		if isPointInCircle3D(x,y,z, x1,y1,z1, me_radius ) then
			sendPlayerMessage(player, text, white[1], white[2], white[3])
		end
	end
end

function save_player_action( playerid, text )
	local playername = getPlayerName(playerid)
	local time = getRealTime()
	local client_time = "[Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"].."] "

	sqlite_save_player_action( "INSERT INTO "..playername.." (player_action) VALUES ('"..client_time..text.."')" )
end

function save_admin_action( playerid, text )
	local time = getRealTime()
	local client_time = "[Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"].."] "

	sqlite( "INSERT INTO save_admin_action (admin_action) VALUES ('"..client_time..text.."')" )
end

function save_realtor_action( playerid, text )
	local time = getRealTime()
	local client_time = "[Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"].."] "

	sqlite( "INSERT INTO save_realtor_action (realtor_action) VALUES ('"..client_time..text.."')" )
end

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

function set_weather()
	local hour, minute = getTime()

	if hour == 0 then
		math.randomseed(getTickCount())

		setWeatherBlended(tomorrow_weather)

		tomorrow_weather = math.random(22)
		print("[tomorrow_weather] "..tomorrow_weather)

		for k,playerid in pairs(getElementsByType("player")) do
			triggerClientEvent( playerid, "event_tomorrow_weather_fun", playerid, tomorrow_weather )
		end
	end
end

--[[Bone IDs:
1: head
2: neck
3: spine
4: pelvis
5: left clavicle
6: right clavicle
7: left shoulder
8: right shoulder
9: left elbow
10: right elbow
11: left hand
12: right hand
13: left hip
14: right hip
15: left knee
16: right knee
17: left ankle
18: right ankle
19: left foot
20: right foot]]
function object_attach( playerid, model, bone, x,y,z, rx,ry,rz, time )--прикрепление объектов к игроку
	local x1, y1, z1 = getElementPosition (playerid)
	local objPick = createObject (model, x1, y1, z1)

	attachElementToBone (objPick, playerid, bone, x,y,z, rx,ry,rz)

	setTimer(function ( playerid )
		detachElementFromBone(objPick)
		destroyElement(objPick)
	end, time, 1, playerid)
end
-----------------------------------------------------------------------------------------

function timer_earth_clear()
	local time = getRealTime()

	if time["minute"] == 0 or time["minute"] == 30 then
		print("[timer_earth_clear] max_earth "..max_earth)

		earth = {}
		max_earth = 0

		for k,playerid in pairs(getElementsByType("player")) do
			sendPlayerMessage(playerid, "[НОВОСТИ] Улицы очищенны от мусора", green[1], green[2], green[3])
			triggerClientEvent( playerid, "event_earth_load", playerid, "nil", 0, 0, 0, 0, 0, 0 )
		end
	end
end

local info_png = {
	[0] = {"", ""},
	[1] = {"деньги", "$"},
	[2] = {"права на имя", ""},
	[3] = {"сигареты Big Break Red", "сигарет в пачке"},
	[4] = {"аптечка", "шт"},
	[5] = {"канистра с", "лит."},
	[6] = {"ключ от автомобиля с номером", ""},
	[7] = {"сигареты Big Break Blue", "сигарет в пачке"},
	[8] = {"сигареты Big Break White", "сигарет в пачке"},
	[9] = {"граната", "боеприпасов"},
	[10] = {"полицейский жетон на имя", ""},
	[11] = {"планшет", "шт"},
	[12] = {"colt-45", "боеприпасов"},
	[13] = {"deagle", "боеприпасов"},
	[14] = {"AK-47", "боеприпасов"},
	[15] = {"M4", "боеприпасов"},
	[16] = {"tec-9", "боеприпасов"},
	[17] = {"MP5", "боеприпасов"},
	[18] = {"uzi", "боеприпасов"},
	[19] = {"слезоточивый газ", "боеприпасов"},
	[20] = {"наркотики", "гр"},
	[21] = {"пиво старый эмпайр", "шт"},
	[22] = {"пиво штольц", "шт"},
	[23] = {"ремонтный набор", "шт"},
	[24] = {"ящик", "$ за штуку"},
	[25] = {"ключ от дома с номером", ""},
	[26] = {"silenced", "боеприпасов"},
	[27] = {"одежда", ""},
	[28] = {"шеврон Офицера", "шт"},
	[29] = {"шеврон Детектива", "шт"},
	[30] = {"шеврон Сержанта", "шт"},
	[31] = {"шеврон Лейтенанта", "шт"},
	[32] = {"шеврон Капитан", "шт"},
	[33] = {"шеврон Шефа полиции", "шт"},
	[34] = {"shotgun", "боеприпасов"},
	[35] = {"парашют", "шт"},
	[36] = {"дубинка", "шт"},
	[37] = {"бита", "шт"},
	[38] = {"нож", "шт"},
	[39] = {"бронежилет", "шт"},
	[40] = {"лом", "шт"},
	[41] = {"sniper", "боеприпасов"},
	[42] = {"таблетки от наркозависимости", "шт"},
	[43] = {"документы на", "бизнес"},
	[44] = {"админский жетон на имя", ""},
	[45] = {"риэлторская лицензия на имя", ""},
	[46] = {"радар", "шт"},
	[47] = {"перцовый балончик", "боеприпасов"},
	[48] = {"тушка свиньи", "$ за штуку"},
	[49] = {"лопата", "шт"},
	[50] = {"лицензия на оружие на имя", ""},
	[51] = {"jetpack", "шт"},
	[52] = {"кислородный балон на 5 мин", "шт"},
	[53] = {"бургер", "шт"},
	[54] = {"хот-дог", "шт"},
	[55] = {"мыло", "шт"},
	[56] = {"пижама", "%"},
	[57] = {"алкотестер", "шт"},
	[58] = {"наркотестер", "шт"},
	[59] = {"жетон для оплаты дома на", "дней"},
	[60] = {"жетон для оплаты бизнеса на", "дней"},
	[61] = {"жетон для оплаты т/с на", "дней"},
}

local weapon = {
	[9] = {info_png[9][1], 16, 360, 5},
	[12] = {info_png[12][1], 22, 240, 25},
	[13] = {info_png[13][1], 24, 1440, 25},
	[14] = {info_png[14][1], 30, 4200, 25},
	[15] = {info_png[15][1], 31, 5400, 25},
	[16] = {info_png[16][1], 32, 360, 25},
	[17] = {info_png[17][1], 29, 2400, 25},
	[18] = {info_png[18][1], 28, 600, 25},
	[19] = {info_png[19][1], 17, 360, 5},
	[26] = {info_png[26][1], 23, 720, 25},
	[34] = {info_png[34][1], 25, 720, 25},
	[35] = {info_png[35][1], 46, 200, 1},
	[36] = {info_png[36][1], 3, 150, 1},
	[37] = {info_png[37][1], 5, 150, 1},
	[38] = {info_png[38][1], 4, 150, 1},
	[40] = {info_png[40][1], 15, 150, 1},
	[41] = {info_png[41][1], 34, 6000, 25},
	[47] = {info_png[47][1], 41, 50, 25},
	[49] = {info_png[49][1], 6, 50, 1},
}

local shop = {
	[3] = {info_png[3][1], 20, 5},
	[4] = {info_png[4][1], 1, 250},
	[5] = {info_png[5][1].." 20 "..info_png[5][2], 20, 250},
	[7] = {info_png[7][1], 20, 10},
	[8] = {info_png[8][1], 20, 15},
	[11] = {info_png[11][1], 1, 100},
	[23] = {info_png[23][1], 1, 100},
	[28] = {info_png[28][1], 1, 100},
	[29] = {info_png[29][1], 1, 100},
	[30] = {info_png[30][1], 1, 100},
	[31] = {info_png[31][1], 1, 100},
	[32] = {info_png[32][1], 1, 100},
	[33] = {info_png[33][1], 1, 100},
	[42] = {info_png[42][1], 1, 10000},
	[46] = {info_png[46][1], 1, 100},
	[52] = {info_png[52][1], 1, 1000},
	[53] = {info_png[53][1], 1, 100},
	[54] = {info_png[54][1], 1, 50},
	[55] = {info_png[55][1], 1, 50},
	[56] = {info_png[56][1], 100, 100},
	[57] = {info_png[57][1], 1, 100},
	[58] = {info_png[58][1], 1, 100},
}

local bar = {
	[21] = {info_png[21][1], 1, 45},
	[22] = {info_png[22][1], 1, 60},
}

local deathReasons = {
	[19] = "Ракета",
	[37] = "Обжигать",
	[49] = "Утрамбованный",
	[50] = "Наезд / лопасти вертолета",
	[51] = "Взрыв",
	[52] = "Стрелять из авто",
	[53] = "Утопленный",
	[54] = "Упасть",
	[55] = "Неизвестный",
	[56] = "Свалка",
	[57] = "Оружие",
	[59] = "Танковая Граната",
	[63] = "Взорванный"
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

local cash_car = {
	[400] = {"LANDSTAL", 25000},
	[401] = {"BRAVURA", 9000},
	[402] = {"BUFFALO", 35000},
	[403] = {"LINERUN", 35000},
	[404] = {"PEREN", 10000},
	[405] = {"SENTINEL", 35000},
	--[406] = {"DUMPER", 50000},--самосвал
	--[407] = {"FIRETRUK", 15000},
	--[408] = {"TRASH", 50000},--мусоровоз
	[409] = {"STRETCH", 40000},--лимузин
	[410] = {"MANANA", 9000},
	[411] = {"INFERNUS", 95000},
	[412] = {"VOODOO", 30000},
	[413] = {"PONY", 20000},--грузовик с колонками
	[414] = {"MULE", 22000},--грузовик развозчика
	[415] = {"CHEETAH", 105000},
	--[416] = {"AMBULAN", 10000},--скорая
	[418] = {"MOONBEAM", 16000},
	[419] = {"ESPERANT", 19000},
	--[420] = {"TAXI", 20000},
	[421] = {"WASHING", 18000},
	[422] = {"BOBCAT", 26000},
	--[423] = {"MRWHOOP", 29000},--грузовик мороженого
	[424] = {"BFINJECT", 15000},
	[426] = {"PREMIER", 25000},
	--[428] = {"SECURICA", 40000},--инкасаторский грузовик
	[429] = {"BANSHEE", 45000},
	--[431] = {"BUS", 15000},
	--[432] = {"RHINO", 110000},--танк
	--[433] = {"BARRACKS", 10000},--военный грузовик
	[434] = {"HOTKNIFE", 35000},
	--[435] = {"Trailer 1", 35000},--продуктовый
	[436] = {"PREVION", 9000},
	--[437] = {"COACH", 20000},--автобус
	--[438] = {"CABBIE", 10000},--такси
	[439] = {"STALLION", 19000},
	[440] = {"RUMPO", 26000},--грузовик развозчика в сампрп
	--[442] = {"ROMERO", 10000},--гробовозка
	--[443] = {"PACKER", 20000},--фура с траплином
	[444] = {"MONSTER", 40000},
	[445] = {"ADMIRAL", 35000},
	[451] = {"TURISMO", 95000},
	--[455] = {"FLATBED", 10000},--пустой грузовик
	--[456] = {"YANKEE", 22000},--грузовик
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
	--[528] = {"FBITRUCK", 40000},
	[529] = {"WILLARD", 19000},
	--[530] = {"FORKLIFT", 9000},--вилочный погр-ик
	--[531] = {"TRACTOR", 9000},
	--[532] = {"COMBINE", 10000},
	[533] = {"FELTZER", 35000},
	[534] = {"REMINGTN", 30000},
	[535] = {"SLAMVAN", 19000},
	[536] = {"BLADE", 19000},
	[539] = {"VORTEX", 26000},--возд-ая подушка
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
	--[574] = {"SWEEPER", 15000},--очистка улиц
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
}

local cash_helicopters = {
	--[[[548] = {"CARGOBOB", 25000},
	[425] = {"HUNTER", 99000},--верт военный с ракетами
	[417] = {"LEVIATHN", 25000},--верт военный
	[487] = {"MAVERICK", 45000},--верт
	[488] = {"News Chopper", 45000},--верт новостей
	[563] = {"RAINDANC", 99000},--верт спасателей
	[469] = {"SPARROW", 25000},--верт без пушки
	[447] = {"SEASPAR", 28000},--верт с пуляметом]]
	[497] = {"Police Maverick", 45000},
}

local cash_airplanes = {
	[592] = {"ANDROM", 45000},--андромада
	[593] = {"DODO", 45000},
	[577] = {"AT400", 45000},
	[511] = {"BEAGLE", 45000},--самолет
	[512] = {"CROPDUST", 45000},--кукурузник
	[513] = {"STUNT", 45000},--спорт самолет
	[519] = {"SHAMAL", 45000},
	[520] = {"HYDRA", 45000},
	[553] = {"NEVADA", 45000},--самолет
	[476] = {"RUSTLER", 45000},--самолет с пушками
	[460] = {"Skimmer", 30000},--самолет садится на воду
}

local interior_business = {
	{1, "Магазин оружия", 285.7870,-41.7190,1001.5160, 6},
	{5, "Магазин одежды", 225.3310,-8.6169,1002.1977, 45},
	{6, "Магазин 24/7", -26.7180,-55.9860,1003.5470, 50},--буду юзать это инт
	{17, "Клуб", 493.4687,-23.0080,1000.6796, 48},
	{0, "Автомастерская", 0,0,0, 27},
}

local interior_house = {
	{1, "Burglary House 1",	224.6351,	1289.012,	1082.141},
	{5, "The Crack Den",	322.1117,	1119.3270,	1083.8830},--наркопритон
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
local interior_job = {
	{1, "Мясокомбинат", 963.6078,2108.3970,1011.0300, 966.2333984375,2160.5166015625,10.8203125, 51, 1, ", Разгрузить товар - E", 15},
	{6, "ЛСПД", 246.4510,65.5860,1003.6410, 1555.494140625,-1675.5419921875,16.1953125, 30, 2, ", Меню - X", 5},
	{10, "СФПД", 246.4410,112.1640,1003.2190, -1605.7109375,710.28515625,13.8671875, 30, 3, ", Меню - X", 5},
	{3, "ЛВПД", 289.7703,171.7460,1007.1790, 2287.1005859375,2432.3642578125,10.8203125, 30, 4, ", Меню - X", 5},
	{3, "Мэрия ЛС", 374.6708,173.8050,1008.3893, 1481.0576171875,-1772.3115234375,18.795755386353, 19, 5, ", Меню - X", 5},
	{2, "Завод продуктов", 2570.33,-1302.31,1044.12, -86.208984375,-299.36328125,2.7646157741547, 51, 6, ", Разгрузить товар - E", 15},
	{3, "Мэрия СФ", 374.6708,173.8050,1008.3893, -2766.55078125,375.60546875,6.3346824645996, 19, 7, ", Меню - X", 5},
	{3, "Мэрия ЛВ", 374.6708,173.8050,1008.3893, 2447.6826171875,2376.3037109375,12.163512229919, 19, 8, ", Меню - X", 5},
}

local t_s_salon = {
	{2131.9775390625,-1151.322265625,24.062105178833, 55},--авто
	{-2236.951171875,2354.212890625,4.9799103736877, 5},--верт
	{-2187.46875,2416.5576171875,5.1651339530945, 9},--лодки
}

--предметы за которые можно получить деньги, место выброски
local image_3d = {
	{942.4775390625,2117.900390625,1011.0302734375, 5, 48},
}

--камеры полиции
local prison_cell = {
	{interior_job[2][1], interior_job[2][10], "кпз_лс",		263.84765625,	77.6044921875,	1001.0390625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф1",	227.5947265625,	110.0537109375,	999.015625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф2",	223.373046875,	110.0986328125,	999.015625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф3",	219.337890625,	110.4619140625,	999.015625},
	{interior_job[3][1], interior_job[3][10], "кпз_сф4",	215.59375,	109.8916015625,	999.015625},
	{interior_job[4][1], interior_job[4][10], "кпз_лв",		198.283203125,	162.1220703125,	1003.0299682617},
	{interior_job[4][1], interior_job[4][10], "кпз_лв2",	198.0390625,	174.78125,	1003.0234375},
	{interior_job[4][1], interior_job[4][10], "кпз_лв3",	193.6708984375,	176.7255859375,	1003.0234375},
}

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
local arrest = {}--арест игрока, 0-нет, 1-да
local crimes = {}--преступления
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

--инв-рь дома
local array_house_1 = {}
local array_house_2 = {}
local house_pos = {}--позиции домов для dxdrawtext
local house_door = {}--состояние двери 0-закрыта, 1-открыта

--бизнесы
local business_pos = {}--позиции бизнесов для dxdrawtext

-------------------пользовательские функции 2----------------------------------------------
function debuginfo ()
	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)
		triggerClientEvent( playerid, "event_debuginfo_fun", playerid, "state_inv_player[playername] "..state_inv_player[playername], "state_gui_window[playername] "..state_gui_window[playername], "logged[playername] "..logged[playername], "enter_house[playername] "..enter_house[playername], "enter_business[playername] "..enter_business[playername], "enter_job[playername] "..enter_job[playername], "speed_car_device[playername] "..speed_car_device[playername], "arrest[playername] "..arrest[playername], "crimes[playername] "..crimes[playername], "max_earth "..max_earth )
			
		if logged[playername] == 1 then
			--нужды
			triggerClientEvent( playerid, "event_need_fun", playerid, alcohol[playername], satiety[playername], hygiene[playername], sleep[playername], drugs[playername] )
			triggerClientEvent( playerid, "event_nalog_fun", playerid, zakon_nalog_car, zakon_nalog_house, zakon_nalog_business )
		end
	end
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

				sendPlayerMessage(playerid, "-100 хп", yellow[1], yellow[2], yellow[3])

				if hygiene[playername]-hygiene_minys >= 0 then
					hygiene[playername] = hygiene[playername]-hygiene_minys
					sendPlayerMessage(playerid, "-"..hygiene_minys.." ед. чистоплотности", yellow[1], yellow[2], yellow[3])
				end

				me_chat(playerid, playername.." стошнило")

				setPedAnimation(playerid, "food", "eat_vomit_p", -1, false, true, true, false)
			end


			if drugs[playername] == 100 then
				setElementHealth( playerid, getElementHealth(playerid)-100 )
				sendPlayerMessage(playerid, "-100 хп", yellow[1], yellow[2], yellow[3])
			end


			if alcohol[playername] ~= 0 then
				alcohol[playername] = alcohol[playername]-10
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
	for k,vehicle in pairs(getElementsByType("vehicle")) do
		local veh = getVehiclePlateText(vehicle)
		local engine = getVehicleEngineState ( vehicle )
		local fuel_down_number = 0.0002

		if engine then
			if fuel[veh] <= 0 then
				setVehicleEngineState ( vehicle, false )
			else
				if getSpeed(vehicle) == 0 then
					fuel[veh] = fuel[veh] - fuel_down_number
				else
					fuel[veh] = fuel[veh] - (fuel_down_number*getSpeed(vehicle))
				end
			end
		end
	end

	for k,playerid in pairs(getElementsByType("player")) do
		local vehicleid = getPlayerVehicle(playerid)
		if vehicleid then
			local veh = getVehiclePlateText(vehicleid)
			triggerClientEvent( playerid, "event_fuel_load", playerid, fuel[veh] )
		end
	end
end

function timer_earth()--передача слотов земли на клиент
	for k,playerid in pairs(getElementsByType("player")) do

		for i,v in pairs(earth) do
			triggerClientEvent( playerid, "event_earth_load", playerid, "", i, v[1], v[2], v[3], v[4], v[5] )
		end
 
		local playername = getPlayerName ( playerid )

		if logged[playername] == 1 then
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", 0, array_player_1[playername][0+1], array_player_2[playername][0+1] )
		end
	end
end

function prison_timer()--античит если не в тюрьме
	for i,playerid in pairs(getElementsByType("player")) do
		local count = 0
		local playername = getPlayerName(playerid)
		local x,y,z = getElementPosition(playerid)

		if arrest[playername] == 1 then
			for k,v in pairs(prison_cell) do
				if not isPointInCircle3D(x,y,z, v[4],v[5],v[6], 5) then
					count = count+1
				end
			end

			if count == #prison_cell then
				local randomize = math.random(1,#prison_cell)

				triggerClientEvent( playerid, "event_inv_delet", playerid )
				state_inv_player[playername] = 0

				triggerClientEvent( playerid, "event_gui_delet", playerid )
				state_gui_window[playername] = 0

				enter_house[playername] = 0
				enter_business[playername] = 0
				enter_job[playername] = 0

				takeAllWeapons ( playerid )

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
			if crimes[playername] == 0 then
				arrest[playername] = 0
				crimes[playername] = -1

				local randomize = math.random(2,4)

				setElementDimension(playerid, 0)
				setElementInterior(playerid, 0, interior_job[randomize][6], interior_job[randomize][7], interior_job[randomize][8])

				sendPlayerMessage(playerid, "Вы свободны, больше не нарушайте", yellow[1], yellow[2], yellow[3])

			elseif crimes[playername] > 0 then
				crimes[playername] = crimes[playername]-1

				sendPlayerMessage(playerid, "Вам сидеть ещё "..(crimes[playername]+1).." мин", yellow[1], yellow[2], yellow[3])
			end
		end
	end
end

function pay_nalog()
	local time = getRealTime()

	if time["hour"] == time["hour"] then
		local result = sqlite( "SELECT * FROM car_db" )
		for k,v in pairs(result) do
			if v["nalog"] > 0 then
				sqlite( "UPDATE car_db SET nalog = nalog - '1' WHERE carnumber = '"..v["carnumber"].."'")
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

		print("[pay_nalog]")
	end
end

function onChat(message, messageType)
	local playerid = source
	local playername = getPlayerName(playerid)

	if logged[playername] == 1 then
		ic_chat(playerid, playername..": "..message)
	end

	cancelEvent()
end
addEventHandler("onPlayerChat", getRootElement(), onChat)

---------------------------------------игрок------------------------------------------------------------
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

function search_inv_player_2_parameter(playerid, id1)--вывод 2 параметра предмета в инв-ре игрока
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == id1 then
			return array_player_2[playername][i+1]
		end
	end
end

function inv_player_empty(playerid, id1, id2)--выдача предмета игроку
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == 0 then
			inv_server_load( "player", i, id1, id2, playername )
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, id1, id2 )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, id1 )
			end

			return true
		end
	end

	return false
end

function inv_player_delet(playerid, id1, id2)--удаления предмета игрока
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == id1 and array_player_2[playername][i+1] == id2 then
			inv_server_load( "player", i, 0, 0, playername )
			triggerClientEvent( playerid, "event_inv_load", playerid, "player", i, 0, 0 )

			if state_inv_player[playername] == 1 then
				triggerClientEvent( playerid, "event_change_image", playerid, "player", i, 0 )
			end

			return true
		end
	end

	return false
end
--------------------------------------------------------------------------------------------------------

---------------------------------------авто-------------------------------------------------------------
function search_inv_car( playerid, value1, value2 )--цикл по поиску предмета в инв-ре авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local val = 0

	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		for i=0,max_inv do
			if array_car_1[plate][i+1] == value1 and array_car_2[plate][i+1] == value2 then
				val = val + 1
			end
		end

		return val
	end
end

function search_inv_car_2_parameter(playerid, id1)--вывод 2 параметра предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	
	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		for i=0,max_inv do
			if array_car_1[plate][i+1] == id1 then
				return array_car_2[plate][i+1]
			end
		end
	end
end

function inv_car_empty(playerid, id1, id2)--выдача предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	
	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		for i=0,max_inv do
			if array_car_1[plate][i+1] == 0 then
				inv_server_load( "car", i, id1, id2, plate )
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

function inv_car_delet(playerid, id1, id2)--удаления предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	
	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		for i=0,max_inv do
			if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
				inv_server_load( "car", i, 0, 0, plate )
				triggerClientEvent( playerid, "event_inv_load", playerid, "car", i, 0, 0 )

				if state_inv_player[playername] == 1 then
					triggerClientEvent( playerid, "event_change_image", playerid, "car", i, 0 )
				end

				return true
			end
		end

		return false
	end
end
--------------------------------------------------------------------------------------------------------

function info_bisiness( number )
	local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
	return "[business "..number..", type "..result[1]["type"]..", price "..result[1]["price"]..", buyprod "..result[1]["buyprod"]..", money "..result[1]["money"]..", warehouse "..result[1]["warehouse"].."]"
end

function pickupUse( playerid )
	local pickup = source
	local x,y,z = getElementPosition(playerid)

	if getElementModel(pickup) == business_icon then
		for k,v in pairs(business_pos) do 
			if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
				sendPlayerMessage(playerid, " ", yellow[1], yellow[2], yellow[3])

				for i=0,max_inv do
					local result = sqlite( "SELECT COUNT() FROM account WHERE slot_"..i.."_1 = '43' AND slot_"..i.."_2 = '"..k.."'" )
					if result[1]["COUNT()"] == 1 then
						local result = sqlite( "SELECT * FROM account WHERE slot_"..i.."_1 = '43' AND slot_"..i.."_2 = '"..k.."'" )
						sendPlayerMessage(playerid, "Владелец бизнеса "..result[1]["name"], yellow[1], yellow[2], yellow[3])
						break
					end
				end

				local result = sqlite( "SELECT * FROM business_db WHERE number = '"..k.."'" )
				sendPlayerMessage(playerid, "Тип "..result[1]["type"], yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(playerid, "Товаров на складе "..result[1]["warehouse"].." шт", yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(playerid, "Стоимость товара (надбавка в N раз) "..result[1]["price"].."$", green[1], green[2], green[3])
				sendPlayerMessage(playerid, "Цена закупки товара "..result[1]["buyprod"].."$", green[1], green[2], green[3])

				if search_inv_player(playerid, 43, k) ~= 0 then
					sendPlayerMessage(playerid, "Состояние кассы "..result[1]["money"].."$", green[1], green[2], green[3])
					sendPlayerMessage(playerid, "Налог бизнеса оплачен на "..result[1]["nalog"].." дней", yellow[1], yellow[2], yellow[3])
				end
				return
			end
		end

	elseif getElementModel(pickup) == house_icon then
		for k,v in pairs(house_pos) do
			if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
				sendPlayerMessage(playerid, " ", yellow[1], yellow[2], yellow[3])

				for i=0,max_inv do
					local result = sqlite( "SELECT COUNT() FROM account WHERE slot_"..i.."_1 = '25' AND slot_"..i.."_2 = '"..k.."'" )
					if result[1]["COUNT()"] == 1 then
						local result = sqlite( "SELECT * FROM account WHERE slot_"..i.."_1 = '25' AND slot_"..i.."_2 = '"..k.."'" )
						sendPlayerMessage(playerid, "Владелец дома "..result[1]["name"], yellow[1], yellow[2], yellow[3])
						break
					end
				end

				if search_inv_player(playerid, 25, k) ~= 0 then
					local result = sqlite( "SELECT * FROM house_db WHERE number = '"..k.."'" )
					sendPlayerMessage(playerid, "Налог дома оплачен на "..result[1]["nalog"].." дней", yellow[1], yellow[2], yellow[3])
				end
				return
			end
		end

	elseif getElementModel(pickup) == job_icon then
		for k,v in pairs(interior_job) do 
			if isPointInCircle3D(v[6],v[7],v[8], x,y,z, 5) then
				sendPlayerMessage(playerid, " ", yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(playerid, v[2], yellow[1], yellow[2], yellow[3])
				return
			end
		end
	end
end
addEventHandler( "onPickupUse", getRootElement(), pickupUse )

function house_bussiness_job_pos_load( playerid )
	for h,v in pairs(house_pos) do
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, h, v[1], v[2], v[3], "house", house_bussiness_radius )
	end

	for h,v in pairs(business_pos) do 
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, h, v[1], v[2], v[3], "biz", house_bussiness_radius )
	end

	for h,v in pairs(interior_job) do 
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, h, v[6], v[7], v[8], "job", house_bussiness_radius, v[11], v[12] )
	end
end

function reg_or_log_fun(playerid, text)
	local playername = getPlayerName ( playerid )
	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 0 then
		reg_fun(playerid, text)
	else
		log_fun(playerid, text)
	end
end
addEvent( "event_reg_or_log_fun", true )
addEventHandler ( "event_reg_or_log_fun", getRootElement(), reg_or_log_fun )

function auction(playerid)--загрузка аука
	local result = sqlite( "SELECT * FROM auction" )

	triggerClientEvent( playerid, "event_auction_fun", playerid, "clear" )

	for k,v in pairs(result) do
		triggerClientEvent( playerid, "event_auction_fun", playerid, "0", v["i"], v["name_sell"], v["id1"], v["id2"], v["money"] )
	end
end
addEvent( "event_auction", true )
addEventHandler ( "event_auction", getRootElement(), auction )

function auction_buy_sell(playerid, value, i, id1, id2, money)--продажа покупка вещей
	math.randomseed(getTickCount())
	local playername = getPlayerName ( playerid )
	local randomize = math.random(0,9999)
	local count = 0

	if value == "sell" then
		if inv_player_delet(playerid, id1, id2) then
			while (true) do
				local result = sqlite( "SELECT COUNT() FROM auction WHERE i = '"..randomize.."'" )
				if result[1]["COUNT()"] == 0 then
					break
				else
					randomize = math.random(0,99999)
				end
			end

			sendPlayerMessage(playerid, "Вы выставили на аукцион "..info_png[id1][1].." "..id2.." "..info_png[id1][2].." за "..money.."$", green[1], green[2], green[3])

			sqlite( "INSERT INTO auction (i, name_sell, id1, id2, money) VALUES ('"..randomize.."', '"..playername.."', '"..id1.."', '"..id2.."', '"..money.."')" )

			save_player_action(playerid, "[auction_sell] "..playername.." [i - "..randomize..", "..info_png[id1][1]..", "..id2..", "..money.."$]")
		else
			sendPlayerMessage(playerid, "[ERROR] У вас нет такого предмета", red[1], red[2], red[3])
		end

	elseif value == "buy" then
		local result = sqlite( "SELECT COUNT() FROM auction WHERE i = '"..i.."'" )

		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM auction WHERE i = '"..i.."'" )

			if array_player_2[playername][1] >= result[1]["money"] then

				if inv_player_empty(playerid, result[1]["id1"], result[1]["id2"]) then
					sendPlayerMessage(playerid, "Вы купили у "..result[1]["name_sell"].." "..info_png[result[1]["id1"]][1].." "..result[1]["id2"].." "..info_png[result[1]["id1"]][2].." за "..result[1]["money"].."$", orange[1], orange[2], orange[3])

					inv_server_load( "player", 0, 1, array_player_2[playername][1]-result[1]["money"], playername )

					for i,playerid in pairs(getElementsByType("player")) do
						local playername_sell = getPlayerName(playerid)
						if playername_sell == result[1]["name_sell"] then
							inv_server_load( "player", 0, 1, array_player_2[playername_sell][1]+result[1]["money"], playername_sell )
							count = count+1
							break
						end
					end

					if count == 0 then
						sqlite( "UPDATE account SET slot_0_2 = slot_0_2 + '"..result[1]["money"].."' WHERE name = '"..result[1]["name_sell"].."'")
					end

					save_player_action(playerid, "[auction_buy] "..playername.." [i - "..i..", name - "..result[1]["name_sell"]..", "..info_png[result[1]["id1"]][1]..", "..result[1]["id2"].."], [-"..result[1]["money"].."$, "..array_player_2[playername][1].."$]")

					sqlite( "DELETE FROM auction WHERE i = '"..i.."'" )
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Лот не найден", red[1], red[2], red[3])
		end

	elseif value == "return" then
		local result = sqlite( "SELECT COUNT() FROM auction WHERE i = '"..i.."'" )

		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM auction WHERE i = '"..i.."'" )

			if playername == result[1]["name_sell"] then

				if inv_player_empty(playerid, result[1]["id1"], result[1]["id2"]) then
					sendPlayerMessage(playerid, "Вы забрали "..info_png[result[1]["id1"]][1].." "..result[1]["id2"].." "..info_png[result[1]["id1"]][2], orange[1], orange[2], orange[3])

					save_player_action(playerid, "[auction_return] "..playername.." [i - "..i..", name - "..result[1]["name_sell"]..", "..info_png[result[1]["id1"]][1]..", "..result[1]["id2"].."]")

					sqlite( "DELETE FROM auction WHERE i = '"..i.."'" )
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Имена не совпадают", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Лот не найден", red[1], red[2], red[3])
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
				sendPlayerMessage(playerid, "[ERROR] Не установлена стоимость товара", red[1], red[2], red[3])
				return
			end

			if cash <= array_player_2[playername][1] then

				addVehicleUpgrade ( vehicleid, value )

				for k,v in pairs(getVehicleUpgrades(vehicleid)) do
					text = text..v..","
				end

				sendPlayerMessage(playerid, "Вы установили апгрейд за "..cash.."$", orange[1], orange[2], orange[3])

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[addVehicleUpgrade_fun] [plate - "..plate..", upgrades - "..value.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE carnumber = '"..plate.."'")
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] На складе недостаточно товаров", red[1], red[2], red[3])
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
				sendPlayerMessage(playerid, "[ERROR] Не установлена стоимость товара", red[1], red[2], red[3])
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

				sendPlayerMessage(playerid, "Вы удалили апгрейд за "..cash.."$", orange[1], orange[2], orange[3])

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[removeVehicleUpgrade_fun] [plate - "..plate..", upgrades - "..value.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE carnumber = '"..plate.."'")
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] На складе недостаточно товаров", red[1], red[2], red[3])
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
				sendPlayerMessage(playerid, "[ERROR] Не установлена стоимость товара", red[1], red[2], red[3])
				return
			end

			if cash <= array_player_2[playername][1] then

				setVehiclePaintjob ( vehicleid, value )

				sendPlayerMessage(playerid, "Вы установили покрасочную работу за "..cash.."$", orange[1], orange[2], orange[3])

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[setVehiclePaintjob_fun] [plate - "..plate..", paintjob - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET paintjob = '"..text.."' WHERE carnumber = '"..plate.."'")
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] На складе недостаточно товаров", red[1], red[2], red[3])
		end
	end
end
addEvent( "event_setVehiclePaintjob", true )
addEventHandler ( "event_setVehiclePaintjob", getRootElement(), setVehiclePaintjob_fun )

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
				sendPlayerMessage(playerid, "[ERROR] Не установлена стоимость товара", red[1], red[2], red[3])
				return
			end

			if cash <= array_player_2[playername][1] then

				setVehicleColor( vehicleid, r, g, b, r, g, b, r, g, b, r, g, b )

				sendPlayerMessage(playerid, "Вы перекрасили т/с за "..cash.."$", orange[1], orange[2], orange[3])

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[setVehicleColor_fun] [plate - "..plate..", color - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET car_rgb = '"..text.."' WHERE carnumber = '"..plate.."'")
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] На складе недостаточно товаров", red[1], red[2], red[3])
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
				sendPlayerMessage(playerid, "[ERROR] Не установлена стоимость товара", red[1], red[2], red[3])
				return
			end

			if cash <= array_player_2[playername][1] then

				setVehicleHeadLightColor ( vehicleid, r, g, b )

				sendPlayerMessage(playerid, "Вы поменяли цвет фар т/с за "..cash.."$", orange[1], orange[2], orange[3])

				sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

				inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[setVehicleHeadLightColor_fun] [plate - "..plate..", color - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET headlight_rgb = '"..text.."' WHERE carnumber = '"..plate.."'")
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] На складе недостаточно товаров", red[1], red[2], red[3])
		end
	end
end
addEvent( "event_setVehicleHeadLightColor", true )
addEventHandler ( "event_setVehicleHeadLightColor", getRootElement(), setVehicleHeadLightColor_fun )
------------------------------------------------------------------------------------------------------------


---------------------------------------магазины-------------------------------------------------------------
function buy_subject_fun( playerid, text, number, value )
	local playername = getPlayerName(playerid)
	local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
	local prod = 1
	local cash = result[1]["price"]

	if prod <= result[1]["warehouse"] then
		if cash == 0 then
			sendPlayerMessage(playerid, "[ERROR] Не установлена стоимость товара (надбавка в N раз)", red[1], red[2], red[3])
			return
		end

		if cash <= array_player_2[playername][1] then

			if value == 1 then
				if search_inv_player(playerid, 50, playername) == 0 then
					sendPlayerMessage(playerid, "[ERROR] У вас нет лицензии на оружие, приобрести её можно в магазине 24/7", red[1], red[2], red[3])
					return
				end

				for k,v in pairs(weapon) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[4]) then
								sendPlayerMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange[1], orange[2], orange[3])

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )

								save_player_action(playerid, "[buy_subject_fun] [weapon - "..text.."], "..playername.." [-"..cash*v[3].."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
							else
								sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
							end
						else
							sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
						end
					end
				end

			elseif value == 2 then
				if text == "мужская одежда" or text == "женская одежда" then
					return
				end

				if inv_player_empty(playerid, 27, text) then
					sendPlayerMessage(playerid, "Вы купили "..text.." скин за "..cash.."$", orange[1], orange[2], orange[3])

					sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

					inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

					save_player_action(playerid, "[buy_subject_fun] [skin - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end

			elseif value == 3 then
				for k,v in pairs(shop) do
					if v[1] == text then
						--if text ~= "права" and text ~= "лицензия на оружие" then
							if cash*v[3] <= array_player_2[playername][1] then
								if inv_player_empty(playerid, k, v[2]) then
									sendPlayerMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange[1], orange[2], orange[3])

									sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

									inv_server_load( "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )

									save_player_action(playerid, "[buy_subject_fun] [24/7 - "..text.."], "..playername.." [-"..cash*v[3].."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
								else
									sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
								end
							else
								sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
							end
						--end
					end
				end

			elseif value == 4 then
				for k,v in pairs(bar) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[2]) then
								sendPlayerMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange[1], orange[2], orange[3])

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )

								save_player_action(playerid, "[buy_subject_fun] [bar - "..text.."], "..playername.." [-"..cash*v[3].."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
							else
								sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
							end
						else
							sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
						end
					end
				end

			elseif value == 5 then
				if inv_player_empty(playerid, 5, 20) then
					sendPlayerMessage(playerid, "Вы купили "..info_png[5][1].." 20 "..info_png[5][2].." за "..cash.."$", orange[1], orange[2], orange[3])

					sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash.."' WHERE number = '"..number.."'")

					inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

					save_player_action(playerid, "[buy_subject_fun] [fuel - "..info_png[5][1].." 20 "..info_png[5][2].."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end

			end
		else
			sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] На складе недостаточно товаров", red[1], red[2], red[3])
	end	
end
addEvent( "event_buy_subject_fun", true )
addEventHandler ( "event_buy_subject_fun", getRootElement(), buy_subject_fun )
------------------------------------------------------------------------------------------------------------


function cops_weapon_fun( playerid, text )--склад копов
	local playername = getPlayerName(playerid)

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

	if text == weapon_cops[39][1] then
		if inv_player_empty(playerid, 39, 1) then
			sendPlayerMessage(playerid, "Вы получили "..text, orange[1], orange[2], orange[3])

			save_player_action(playerid, "[cops_weapon_fun] [weapon - "..text.."], "..playername)
		else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end
		return
	end

	for k,v in pairs(weapon_cops) do
		if v[1] == text then
			if inv_player_empty(playerid, k, v[4]) then
				sendPlayerMessage(playerid, "Вы получили "..text, orange[1], orange[2], orange[3])

				save_player_action(playerid, "[cops_weapon_fun] [weapon - "..text.."], "..playername)
			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
			end
		end
	end
end
addEvent( "event_cops_weapon_fun", true )
addEventHandler ( "event_cops_weapon_fun", getRootElement(), cops_weapon_fun )


function mayoralty_menu_fun( playerid, text )--мэрия
	local playername = getPlayerName(playerid)
	local day_nalog = 7

	local mayoralty_shop = {
		[2] = {"права", 0, 1000},
		[50] = {"лицензия на оружие", 0, 10000},
	}

	local mayoralty_nalog = {
		[59] = {"жетон для оплаты дома на "..day_nalog.." дней", day_nalog, (zakon_nalog_house*day_nalog)},
		[60] = {"жетон для оплаты бизнеса на "..day_nalog.." дней", day_nalog, (zakon_nalog_business*day_nalog)},
		[61] = {"жетон для оплаты т/с на "..day_nalog.." дней", day_nalog, (zakon_nalog_car*day_nalog)},
	}

	for k,v in pairs(mayoralty_shop) do
		if v[1] == text then
			if v[3] <= array_player_2[playername][1] then
				if inv_player_empty(playerid, k, playername) then
					sendPlayerMessage(playerid, "Вы купили "..text.." за "..v[3].."$", orange[1], orange[2], orange[3])

					inv_server_load( "player", 0, 1, array_player_2[playername][1]-(v[3]), playername )

					save_player_action(playerid, "[mayoralty_menu_fun] [mayoralty_shop - "..text.."], "..playername.." [-"..v[3].."$, "..array_player_2[playername][1].."$]")
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end

			return
		end
	end

	for k,v in pairs(mayoralty_nalog) do
		if v[1] == text then
			if v[3] <= array_player_2[playername][1] then
				if inv_player_empty(playerid, k, v[2]) then
					sendPlayerMessage(playerid, "Вы купили "..text.." за "..v[3].."$", orange[1], orange[2], orange[3])

					inv_server_load( "player", 0, 1, array_player_2[playername][1]-(v[3]), playername )

					save_player_action(playerid, "[mayoralty_menu_fun] [mayoralty_nalog - "..text.."], "..playername.." [-"..v[3].."$, "..array_player_2[playername][1].."$]")
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end
			else
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
			end

			return
		end
	end
end
addEvent( "event_mayoralty_menu_fun", true )
addEventHandler ( "event_mayoralty_menu_fun", getRootElement(), mayoralty_menu_fun )


--------------------------эвент по кассе для бизнесов-------------------------------------------------------
function till_fun( playerid, number, money, value )
	local playername = getPlayerName(playerid)

	if value == "withdraw" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		if money <= result[1]["money"] then
			sqlite( "UPDATE business_db SET money = money - '"..money.."' WHERE number = '"..number.."'")

			inv_server_load( "player", 0, 1, array_player_2[playername][1]+money, playername )

			sendPlayerMessage(playerid, "Вы забрали из кассы "..money.."$", green[1], green[2], green[3])

			save_player_action(playerid, "[till_fun_withdraw] "..playername.." [+"..money.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
		else
			sendPlayerMessage(playerid, "[ERROR] В кассе недостаточно средств", red[1], red[2], red[3])
		end

	elseif value == "deposit" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		if money <= array_player_2[playername][1] then
			sqlite( "UPDATE business_db SET money = money + '"..money.."' WHERE number = '"..number.."'")

			inv_server_load( "player", 0, 1, array_player_2[playername][1]-money, playername )

			sendPlayerMessage(playerid, "Вы положили в кассу "..money.."$", orange[1], orange[2], orange[3])

			save_player_action(playerid, "[till_fun_deposit] "..playername.." [-"..money.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
		else
			sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
		end

	elseif value == "price" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )

		sqlite( "UPDATE business_db SET price = '"..money.."' WHERE number = '"..number.."'")

		sendPlayerMessage(playerid, "Вы установили стоимость товара "..money.."$", yellow[1], yellow[2], yellow[3])

		save_player_action(playerid, "[till_fun_price] "..playername.." "..info_bisiness(number))

	elseif value == "buyprod" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )

		sqlite( "UPDATE business_db SET buyprod = '"..money.."' WHERE number = '"..number.."'")

		sendPlayerMessage(playerid, "Вы установили цену закупки товара "..money.."$", yellow[1], yellow[2], yellow[3])

		save_player_action(playerid, "[till_fun_buyprod] "..playername.." "..info_bisiness(number))
	end
end
addEvent( "event_till_fun", true )
addEventHandler ( "event_till_fun", getRootElement(), till_fun )
-------------------------------------------------------------------------------------------------------------

function displayLoadedRes ( res )--старт ресурсов
	if car_spawn_value == 0 then
		car_spawn_value = 1

		setTimer(debuginfo, 1000, 0)--дебагинфа
		setTimer(freez_car, 1000, 0)--дебагинфа
		setTimer(need, 60000, 0)--уменьшение потребностей
		setTimer(need_1, 1000, 0)--нужды
		setTimer(timer_earth, 500, 0)--передача слотов земли на клиент
		setTimer(timer_earth_clear, 60000, 0)--очистка земли от предметов
		setTimer(fuel_down, 1000, 0)--система топлива
		setTimer(set_weather, 60000, 0)--погода сервера
		setTimer(prison, 60000, 0)--таймер заключения в тюрьме
		setTimer(prison_timer, 1000, 0)--античит если не в тюрьме
		setTimer(pay_nalog, (60*60000), 0)--списание налогов

		setWeather(tomorrow_weather)


		local result = sqlite( "SELECT * FROM zakon_mayoralty" )
		zakon_alcohol = result[1]["zakon_alcohol"]
		zakon_alcohol_crimes = result[1]["zakon_alcohol_crimes"]
		zakon_drugs = result[1]["zakon_drugs"]
		zakon_drugs_crimes = result[1]["zakon_drugs_crimes"]
		zakon_kill_crimes = result[1]["zakon_kill_crimes"]

		zakon_nalog_car = result[1]["zakon_nalog_car"]
		zakon_nalog_house = result[1]["zakon_nalog_house"]
		zakon_nalog_business = result[1]["zakon_nalog_business"]

		print("[zakon] zakon_alcohol "..zakon_alcohol..", zakon_alcohol_crimes "..zakon_alcohol_crimes)
		print("[zakon] zakon_drugs "..zakon_drugs..", zakon_drugs_crimes "..zakon_drugs_crimes)
		print("[zakon] zakon_kill_crimes "..zakon_kill_crimes)
		print("[zakon] zakon_nalog_car "..zakon_nalog_car)
		print("[zakon] zakon_nalog_house "..zakon_nalog_house)
		print("[zakon] zakon_nalog_business "..zakon_nalog_business)


		local result = sqlite( "SELECT * FROM car_db" )
		local carnumber_number = 0
		for k,v in pairs(result) do
			car_spawn(v["carnumber"])
			carnumber_number = carnumber_number+1
		end
		print("[number_car_spawn] "..carnumber_number)


		local result = sqlite( "SELECT * FROM house_db" )
		local house_number = 0
		for k,v in pairs(result) do
			local h = v["number"]
			createBlip ( v["x"], v["y"], v["z"], 32, 0, 0,0,0,0, 0, max_blip )
			createPickup (  v["x"], v["y"], v["z"], 3, house_icon, 10000 )

			house_pos[h] = {v["x"], v["y"], v["z"]}
			house_door[h] = v["door"]

			array_house_1[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

			for i=0,max_inv do
				array_house_1[h][i+1] = v["slot_"..i.."_1"]
				array_house_2[h][i+1] = v["slot_"..i.."_2"]
			end

			house_number = house_number+1
		end
		print("[house_number] "..house_number)


		local result = sqlite( "SELECT * FROM business_db" )
		local business_number = 0
		for k,v in pairs(result) do
			local h = v["number"]
			createBlip ( v["x"], v["y"], v["z"], interior_business[v["interior"]][6], 0, 0,0,0,0, 0, max_blip )
			createPickup ( v["x"], v["y"], v["z"], 3, business_icon, 10000 )

			business_pos[h] = {v["x"], v["y"], v["z"], v["type"], v["world"]}

			business_number = business_number+1
		end
		print("[business_number] "..business_number)


		for k,v in pairs(interior_job) do 
			createBlip ( v[6], v[7], v[8], v[9], 0, 0,0,0,0, 0, max_blip )
			createPickup ( v[6], v[7], v[8], 3, job_icon, 10000 )
		end

		createBlip ( 2308.81640625, -13.25, 26.7421875, 52, 0, 0,0,0,0, 0, max_blip )--банк
		createBlip ( 2788.23046875,-2455.99609375,13.340852737427, 51, 0, 0,0,0,0, 0, max_blip )--порт

		for k,v in pairs(t_s_salon) do
			createBlip ( v[1], v[2], v[3], v[4], 0, 0,0,0,0, 0, max_blip )--салоны продажи
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

	array_player_1[playername] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	array_player_2[playername] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	state_inv_player[playername] = 0
	state_gui_window[playername] = 0
	logged[playername] = 0
	enter_house[playername] = 0
	enter_business[playername] = 0
	enter_job[playername] = 0
	speed_car_device[playername] = 0
	arrest[playername] = 0
	crimes[playername] = -1
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

	----бинд клавиш----
	bindKey(playerid, "tab", "down", tab_down )
	bindKey(playerid, "e", "down", e_down )
	bindKey(playerid, "x", "down", x_down )
	bindKey(playerid, "2", "down", to_down )
	bindKey(playerid, "lalt", "down", left_alt_down )

	spawnPlayer(playerid, spawnX, spawnY, spawnZ, 0, 0, 0, 1)
	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)
	setElementFrozen( playerid, true )
	setPlayerNametagColor ( playerid, white[1], white[2], white[3] )
	setPlayerHudComponentVisible ( playerid, "money", false )
	setPlayerHudComponentVisible ( playerid, "health", false )

	for _, stat in pairs({ 22, 24, 225, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79 }) do
		setPedStat(playerid, stat, 1000)
	end
end)

function quitPlayer ( quitType )--дисконект игрока с сервера
	local playerid = source
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)

	if logged[playername] == 1 then
		local heal = getElementHealth( playerid )
		sqlite( "UPDATE account SET heal = '"..heal.."', x = '"..x.."', y = '"..y.."', z = '"..z.."', arrest = '"..arrest[playername].."', crimes = '"..crimes[playername].."', alcohol = '"..alcohol[playername].."', satiety = '"..satiety[playername].."', hygiene = '"..hygiene[playername].."', sleep = '"..sleep[playername].."', drugs = '"..drugs[playername].."' WHERE name = '"..playername.."'")

		save_player_action(playerid, "[quitPlayer] "..playername.." [heal - "..heal.."]")

		exit_car_fun(playerid)
	else
		
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )

function player_Spawn (playerid)--спавн игрока
	local playername = getPlayerName ( playerid )

	if logged[playername] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

		spawnPlayer(playerid, spawnX, spawnY, spawnZ, 0, result[1]["skin"])

		setElementHealth( playerid, 100 )
	end
end

addEventHandler( "onPlayerWasted", getRootElement(),--смерть игрока
function(ammo, attacker, weapon, bodypart)
	local playerid = source
	local playername = getPlayerName ( playerid )
	local playername_a = nil
	local reason = weapon

	for k,v in pairs(deathReasons) do
		if k == reason then
			reason = v
		end
	end

	if attacker then
		if getElementType ( attacker ) == "player" then
			playername_a = getPlayerName ( attacker )

			if search_inv_player(attacker, 10, playername_a) == 0 then
				local crimes_plus = zakon_kill_crimes
				crimes[playername_a] = crimes[playername_a]+crimes_plus
				sendPlayerMessage(attacker, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername_a]+1, yellow[1], yellow[2], yellow[3])
			end

			sendPlayerMessage(attacker, "Вы убили "..playername, yellow[1], yellow[2], yellow[3])
			sendPlayerMessage(playerid, "Вас убил "..playername_a, yellow[1], yellow[2], yellow[3])

		elseif getElementType ( attacker ) == "vehicle" then
			for i,player_id in pairs(getElementsByType("player")) do
				local vehicleid = getPlayerVehicle(player_id)

				if attacker == vehicleid then
					playername_a = getPlayerName ( player_id )

					if search_inv_player(player_id, 10, playername_a) == 0 then
						local crimes_plus = zakon_kill_crimes
						crimes[playername_a] = crimes[playername_a]+crimes_plus
						sendPlayerMessage(player_id, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername_a]+1, yellow[1], yellow[2], yellow[3])
					end

					sendPlayerMessage(player_id, "Вы убили "..playername, yellow[1], yellow[2], yellow[3])
					sendPlayerMessage(playerid, "Вас убил "..playername_a, yellow[1], yellow[2], yellow[3])

					break
				end
			end
		end
	end
	
	setTimer( player_Spawn, 5000, 1, playerid )

	save_player_action(playerid, "[onPlayerWasted] "..playername.." [ammo - "..tostring(ammo)..", attacker - "..tostring(playername_a)..", reason - "..tostring(reason)..", bodypart - "..tostring(getBodyPartName ( bodypart )).."]")
end)

function frozen_false_fun( playerid )
	if isElementFrozen(playerid) then
		setElementFrozen( playerid, false )
		sendPlayerMessage(playerid, "Вы можете двигаться", yellow[1], yellow[2], yellow[3])
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

	for k,v in pairs(deathReasons) do
		if k == reason then
			reason = v
		end
	end

	if (reason == 16 or reason == 3) and not isElementFrozen(playerid) then--удар дубинкой оглушает игрока на 15 сек
		local playername_attacker = getPlayerName ( attacker )
		setElementFrozen( playerid, true )
		setTimer(frozen_false_fun, 15000, 1, playerid)--разморозка
		me_chat(playerid, playername_attacker.." оглушил(а) "..playername)
	end
end
addEventHandler ( "onPlayerDamage", getRootElement (), playerDamage_text )

function nickChangeHandler(oldNick, newNick)
	local playerid = source
	local playername = getPlayerName ( playerid )

	kickPlayer( playerid, "kick for Change Nick" )
end
addEventHandler("onPlayerChangeNick", getRootElement(), nickChangeHandler)

----------------------------------Регистрация--------------------------------------------
function reg_fun(playerid, cmd)
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP(playerid)

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 0 then
		
		local result = sqlite( "INSERT INTO account (name, ban, reason, password, x, y, z, reg_ip, reg_serial, heal, alcohol, satiety, hygiene, sleep, drugs, skin, arrest, crimes, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..playername.."', '0', '0', '"..md5(cmd).."', '"..spawnX.."', '"..spawnY.."', '"..spawnZ.."', '"..ip.."', '"..serial.."', '"..max_heal.."', '0', '100', '100', '100', '0', '26', '0', '-1', '1', '500', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
		for i=0,max_inv do
			array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
			array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
		end

		logged[playername] = 1
		alcohol[playername] = result[1]["alcohol"]
		satiety[playername] = result[1]["satiety"]
		hygiene[playername] = result[1]["hygiene"]
		sleep[playername] = result[1]["sleep"]
		drugs[playername] = result[1]["drugs"]

		spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"], 0, result[1]["skin"], 0, 0)
		setElementHealth( playerid, result[1]["heal"] )
		setElementFrozen( playerid, false )

		sendPlayerMessage(playerid, "Вы удачно зашли!", turquoise[1], turquoise[2], turquoise[3])

		triggerClientEvent( playerid, "event_delet_okno", playerid )

		sqlite_save_player_action( "CREATE TABLE "..playername.." (player_action TEXT)" )

		save_player_action(playerid, "[ACCOUNT REGISTER] "..playername.." [ip - "..ip..", serial - "..serial.."]")

		house_bussiness_job_pos_load( playerid )
	end
end
addEvent( "event_reg", true )
addEventHandler("event_reg", getRootElement(), reg_fun)

----------------------------------Авторизация--------------------------------------------
function log_fun(playerid, cmd)
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP(playerid)

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

		if md5(cmd) == result[1]["password"] then
			for i=0,max_inv do
				array_player_1[playername][i+1] = result[1]["slot_"..i.."_1"]
				array_player_2[playername][i+1] = result[1]["slot_"..i.."_2"]
			end

			logged[playername] = 1
			arrest[playername] = result[1]["arrest"]
			crimes[playername] = result[1]["crimes"]
			alcohol[playername] = result[1]["alcohol"]
			satiety[playername] = result[1]["satiety"]
			hygiene[playername] = result[1]["hygiene"]
			sleep[playername] = result[1]["sleep"]
			drugs[playername] = result[1]["drugs"]

			--[[for h,v in pairs(house_pos) do
				if search_inv_player(playerid, 25, h) ~= 0 then
					spawnPlayer(playerid, v[1], v[2], v[3], 0, result[1]["skin"], 0, 0)
					break
				end
			end]]

			if arrest[playername] == 1 then
				local randomize = math.random(1,#prison_cell)
				spawnPlayer(playerid, prison_cell[randomize][4], prison_cell[randomize][5], prison_cell[randomize][6], 0, result[1]["skin"], prison_cell[randomize][1], prison_cell[randomize][2])
			else
				spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"], 0, result[1]["skin"], 0, 0)
			end

			setElementHealth( playerid, result[1]["heal"] )
			setElementFrozen( playerid, false )

			sendPlayerMessage(playerid, "Вы удачно зашли!", turquoise[1], turquoise[2], turquoise[3])

			triggerClientEvent( playerid, "event_delet_okno", playerid )

			save_player_action(playerid, "[log_fun] "..playername.." [ip - "..ip..", serial - "..serial.."]")

			house_bussiness_job_pos_load( playerid )
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
	setElementHealth(vehicleid, 250)
end

function explode_car()
	local vehicleid = source
	local plate = getVehiclePlateText ( vehicleid )

	setTimer(fixVehicle_fun, 5000, 1, vehicleid)
end
addEventHandler("onVehicleExplode", getRootElement(), explode_car)

function freez_car()--заморозка авто
	for k,vehicleid in pairs(getElementsByType("vehicle")) do
		local x,y,z = getElementPosition( vehicleid )
		local plate = getVehiclePlateText ( vehicleid )

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM car_db WHERE carnumber = '"..plate.."'" )
			for k,v in pairs(result) do
				if v["frozen"] == 1 then
					setElementFrozen(vehicleid, true)
				else
					setElementFrozen(vehicleid, false)
				end
			end
		end
	end
end

function reattachTrailer(vehicleid)--отцепка прицепа
	local trailer = source
	local plate = getVehiclePlateText ( trailer )

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
	if result[1]["COUNT()"] == 1 then
		local x,y,z = getElementPosition(trailer)
		local rx,ry,rz = getElementRotation(trailer)

		if isInsideColShape(car_shtraf_stoyanka, x,y,z) then
			sqlite( "UPDATE car_db SET frozen = '1', x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE carnumber = '"..plate.."'")
		end

		sqlite( "UPDATE car_db SET evacuate = '0' WHERE carnumber = '"..plate.."'")
	end
end
addEventHandler("onTrailerDetach", getRootElement(), reattachTrailer)

function detachTrailer(vehicleid)--прицепка прицепа
	local trailer = source
	local plate = getVehiclePlateText ( trailer )

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
	if result[1]["COUNT()"] == 1 then
		local x,y,z = getElementPosition(trailer)
		local rx,ry,rz = getElementRotation(trailer)

		if isInsideColShape(car_shtraf_stoyanka, x,y,z) then
			sqlite( "UPDATE car_db SET frozen = '0', x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE carnumber = '"..plate.."'")
		end

		sqlite( "UPDATE car_db SET evacuate = '1' WHERE carnumber = '"..plate.."'")
	end
end
addEventHandler("onTrailerAttach", getRootElement(), detachTrailer)

function car_spawn(number)

		local plate = number
		local result = sqlite( "SELECT * FROM car_db WHERE carnumber = '"..plate.."'" )
		local vehicleid = createVehicle(result[1]["carmodel"], result[1]["x"], result[1]["y"], result[1]["z"], 0, 0, result[1]["rot"], plate)

		setVehicleLocked ( vehicleid, true )

		fuel[plate] = result[1]["fuel"]

		local spl = split(result[1]["tune"], ",")
		for k,v in pairs(spl) do
			addVehicleUpgrade ( vehicleid, v )
		end

		local spl = split(result[1]["car_rgb"], ",")
		setVehicleColor( vehicleid, spl[1], spl[2], spl[3], spl[1], spl[2], spl[3], spl[1], spl[2], spl[3], spl[1], spl[2], spl[3] )

		local spl = split(result[1]["headlight_rgb"], ",")
		setVehicleHeadLightColor ( vehicleid, spl[1], spl[2], spl[3] )

		setVehiclePaintjob ( vehicleid, result[1]["paintjob"] )

		array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

		for i=0,max_inv do
			array_car_1[plate][i+1] = result[1]["slot_"..i.."_1"]
			array_car_2[plate][i+1] = result[1]["slot_"..i.."_2"]
		end
end

addCommandHandler ( "buycar",--покупка авто
function ( playerid, cmd, id )
	local police_car = {596,597,598,599,427,601,490,525,523}
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
		sendPlayerMessage(playerid, "[ERROR] /buycar [ид т/с]", red[1], red[2], red[3])
		return
	end

	if id >= 400 and id <= 611 then
		local number = randomize_number()

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..number.."'" )
		if result[1]["COUNT()"] == 1 then
			sendPlayerMessage(playerid, "[ERROR] Этот номер числится в базе т/с, пожалуйста повторите попытку снова", red[1], red[2], red[3])
			return
		end


		if isPointInCircle3D(t_s_salon[1][1],t_s_salon[1][2],t_s_salon[1][3], x1,y1,z1, 5) then
			if cash_car[id] == nil then
				sendPlayerMessage(playerid, "[ERROR] Этот т/с недоступен", red[1], red[2], red[3])
				return
			end

			for k,v in pairs(police_car) do
				if v == id and (search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0) then
					sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3])
					return
				end
			end

			if cash_car[id][2] > array_player_2[playername][1] then
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств, необходимо "..cash_car[id][2].."$", red[1], red[2], red[3])
				return
			end

			inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash_car[id][2], playername )

			sendPlayerMessage(playerid, "Вы купили транспортное средство за "..cash_car[id][2].."$", orange[1], orange[2], orange[3])

			x,y,z,rot = 2134.5244140625,-1133.404296875,25.779407501221,52

		elseif isPointInCircle3D(t_s_salon[2][1],t_s_salon[2][2],t_s_salon[2][3], x1,y1,z1, 5) then
			if cash_helicopters[id] == nil then
				sendPlayerMessage(playerid, "[ERROR] Этот т/с недоступен", red[1], red[2], red[3])
				return
			end

			for k,v in pairs(police_helicopters) do
				if v == id and (search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0) then
					sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3])
					return
				end
			end

			if cash_helicopters[id][2] > array_player_2[playername][1] then
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств, необходимо "..cash_helicopters[id][2].."$", red[1], red[2], red[3])
				return
			end

			inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash_helicopters[id][2], playername )

			sendPlayerMessage(playerid, "Вы купили транспортное средство за "..cash_helicopters[id][2].."$", orange[1], orange[2], orange[3])

			x,y,z,rot = -2225.8125,2326.9091796875,7.6982507705688,90

		elseif isPointInCircle3D(t_s_salon[3][1],t_s_salon[3][2],t_s_salon[3][3], x1,y1,z1, 5) then
			if cash_boats[id] == nil then
				sendPlayerMessage(playerid, "[ERROR] Этот т/с недоступен", red[1], red[2], red[3])
				return
			end

			for k,v in pairs(police_boats) do
				if v == id and (search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0) then
					sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3])
					return
				end
			end

			if cash_boats[id][2] > array_player_2[playername][1] then
				sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств, необходимо "..cash_boats[id][2].."$", red[1], red[2], red[3])
				return
			end

			inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash_boats[id][2], playername )

			sendPlayerMessage(playerid, "Вы купили транспортное средство за "..cash_boats[id][2].."$", orange[1], orange[2], orange[3])

			x,y,z,rot = -2244.6,2408.7,1.8,315
		else
			sendPlayerMessage(playerid, "[ERROR] Найдите место продажи т/с", red[1], red[2], red[3])
			return
		end


		local val1, val2 = 6, number

		if inv_player_empty(playerid, 6, val2) then
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

			sendPlayerMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2, orange[1], orange[2], orange[3])

			sqlite( "INSERT INTO car_db (carnumber, carmodel, nalog, frozen, evacuate, x, y, z, rot, fuel, day_engine_on, car_rgb, headlight_rgb, paintjob, tune, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..val2.."', '"..id.."', '"..nalog_start.."', '0',' 0', '"..x.."', '"..y.."', '"..z.."', '"..rot.."', '"..max_fuel.."', '0', '"..car_rgb_text.."', '"..headlight_rgb_text.."', '"..paintjob_text.."', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

			save_player_action(playerid, "[buy_vehicle] "..playername.." [plate - "..plate.."]")
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

	if isVehicleLocked ( vehicleid ) then
		removePedFromVehicle ( playerid )
	end

	setVehicleEngineState(vehicleid, false)

	if seat == 0 then
		sendPlayerMessage( playerid, "Чтобы завести (заглушить) двигатель используйте клавишу 2", yellow[1], yellow[2], yellow[3] )

		if search_inv_player(playerid, 6, tonumber(plate)) ~= 0 then
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				local result = sqlite( "SELECT * FROM car_db WHERE carnumber = '"..plate.."'" )
				sendPlayerMessage(playerid, "Налог т/с оплачен на "..result[1]["nalog"].." дней", yellow[1], yellow[2], yellow[3])
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

		setVehicleEngineState(vehicleid, false)

		if getVehicleOccupant ( vehicleid, 0 ) then

			local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				local x,y,z = getElementPosition(vehicleid)
				local rx,ry,rz = getElementRotation(vehicleid)

				sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE carnumber = '"..plate.."'")
			end
		end
	end
end

function exit_car ( vehicleid, seat, jacked )--евент выхода из авто
	local playerid = source
	local playername = getPlayerName ( playerid )
	local plate = getVehiclePlateText ( vehicleid )

	setVehicleEngineState(vehicleid, false)

	if seat == 0 then
		triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			local x,y,z = getElementPosition(vehicleid)
			local rx,ry,rz = getElementRotation(vehicleid)

			sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE carnumber = '"..plate.."'")
		end
	end
end
addEventHandler ( "onPlayerVehicleExit", getRootElement(), exit_car )

function to_down (playerid, key, keyState)--вкл выкл двигатель авто
local playername = getPlayerName ( playerid )
local vehicleid = getPlayerVehicle(playerid)

	if keyState == "down" then
		if vehicleid then
			local plate = getVehiclePlateText ( vehicleid )

			if fuel[plate] <= 0 then
				sendPlayerMessage(playerid, "[ERROR] Бак пуст", red[1], red[2], red[3])
				return
			end

			local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
			if result[1]["COUNT()"] == 1 then
				local result = sqlite( "SELECT * FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["nalog"] <= 0 then
					sendPlayerMessage(playerid, "[ERROR] Т/с арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
					return
				end
			end

			if getSpeed(vehicleid) > 5 then
				sendPlayerMessage(playerid, "[ERROR] Остановите машину", red[1], red[2], red[3])
				return
			end

			if search_inv_player(playerid, 6, tonumber(plate)) ~= 0 and getVehicleOccupant ( vehicleid, 0 ) and search_inv_player(playerid, 2, playername) ~= 0 then
				if getVehicleEngineState(vehicleid) then
					setVehicleEngineState(vehicleid, false)
					me_chat(playerid, playername.." заглушил(а) двигатель")
				else
					setVehicleEngineState(vehicleid, true)
					me_chat(playerid, playername.." завел(а) двигатель")

					local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
					if result[1]["COUNT()"] == 1 then
						local time = getRealTime()
						local client_time = "Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"]

						sqlite( "UPDATE car_db SET day_engine_on = '"..client_time.."' WHERE carnumber = '"..plate.."'")
					end
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Чтобы завести т/с надо выполнить 3 пункта:", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 1) нужно иметь ключ от т/с", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 2) сидеть на водительском месте", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 3) иметь права на свое имя", red[1], red[2], red[3])
			end
		end
	end
end

function randomize_number()--генератор номеров для авто
	math.randomseed(getTickCount())

	local randomize = math.random(1,999999)
	return randomize
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
						triggerClientEvent( playerid, "event_tab_load", playerid, "car", plate )
					end
				end

				for h,v in pairs(house_pos) do
					local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )

					if getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[result[1]["interior"]][1] and search_inv_player(playerid, 25, h) ~= 0 and enter_house[playername] == 1 then
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

	if value == "player" then
		for k,v in pairs(image_3d) do
			if (isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) and id1 == v[5]) then--получение прибыли за предметы
				inv_server_load( value, id3, 0, 0, tabpanel )
				inv_server_load( value, 0, 1, array_player_2[playername][1]+id2, tabpanel )

				triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, 0, 0 )
				triggerClientEvent( playerid, "event_change_image", playerid, value, id3, 0 )

				sendPlayerMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])

				save_player_action(playerid, "[throw_earth_job] "..playername.." [+"..id2.."$, "..array_player_2[playername][1].."$]] ["..info_png[id1][1]..", "..id2.."]")

				return
			end
		end
	end

	max_earth = max_earth+1
	local j = max_earth
	earth[j] = {x,y,z,id1,id2}

	if search_inv_player(playerid, 25, id2) ~= 0 and id1 == 25 then--когда выбрасываешь ключ в инв-ре исчезают картинки
		triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
	end

	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		if getVehicleOccupant ( vehicleid, 0 ) and id2 == plate and id1 == 6 then--когда выбрасываешь ключ в инв-ре исчезают картинки
			triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )
		end
	end

	inv_server_load( value, id3, 0, 0, tabpanel )

	triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, 0, 0 )
	triggerClientEvent( playerid, "event_change_image", playerid, value, id3, 0 )

	sendPlayerMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])

	save_player_action(playerid, "[throw_earth] "..playername.." [value - "..value..", x - "..earth[j][1]..", y - "..earth[j][2]..", z - "..earth[j][3].."] ["..info_png[ earth[j][4] ][1]..", "..earth[j][5].."]")
end
addEvent( "event_throw_earth_server", true )
addEventHandler ( "event_throw_earth_server", getRootElement(), throw_earth_server )

function e_down (playerid, key, keyState)--подбор предметов с земли
	local x,y,z = getElementPosition(playerid)
	local playername = getPlayerName ( playerid )
	math.randomseed(getTickCount())
	
	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then

		if isPointInCircle3D(x,y,z, -86.208984375,-299.36328125,2.7646157741547, 15) then--место_погрузки_ящиков
			give_subject(playerid, "car", 24, math.random(1,zp_box))

		elseif isPointInCircle3D(x,y,z, 955.9677734375,2143.6513671875,1011.0258789063, 5) then--взять тушку свиньи
			give_subject(playerid, "player", 48, math.random(1,zp_pig))
		else
			delet_subject(playerid, 24)
		end


		for i,v in pairs(earth) do
			local area = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 20 )

			if area then
				if v[4] == 48 and search_inv_player(playerid, v[4], search_inv_player_2_parameter(playerid, v[4])) >= 1 then
					sendPlayerMessage(playerid, "[ERROR] Можно переносить только один предмет", red[1], red[2], red[3])
					return
				end

				if inv_player_empty(playerid, v[4], v[5]) then
						
					sendPlayerMessage(playerid, "Вы подняли "..info_png[ v[4] ][1].." "..v[5].." "..info_png[ v[4] ][2], svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])

					save_player_action(playerid, "[e_down] "..playername.." [x - "..v[1]..", y - "..v[2]..", z - "..v[3].."] ["..info_png[ v[4] ][1]..", "..v[5].."]")

					earth[i] = nil

					for i,playerid in pairs(getElementsByType("player")) do
						triggerClientEvent( playerid, "event_earth_load", playerid, "nil", 0, 0, 0, 0, 0, 0 )
					end
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end

				return
			end
		end
	end
end

function x_down (playerid, key, keyState)
local playername = getPlayerName ( playerid )
local x,y,z = getElementPosition(playerid)

	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then
		if state_inv_player[playername] == 0 then--инв-рь игрока
			if state_gui_window[playername] == 0 then

				for k,v in pairs(business_pos) do--бизнесы
					if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) and v[4] == interior_business[5][2] then

						local result = sqlite( "SELECT * FROM business_db WHERE number = '"..k.."'" )
						if result[1]["nalog"] <= 0 then
							sendPlayerMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
							return
						end

						triggerClientEvent( playerid, "event_tune_create", playerid, k )
						state_gui_window[playername] = 1
						return

					elseif getElementDimension(playerid) == v[5] and v[4] == interior_business[1][2] and enter_business[playername] == 1 then
						triggerClientEvent( playerid, "event_shop_menu", playerid, k, 1 )
						state_gui_window[playername] = 1
						return

					elseif getElementDimension(playerid) == v[5] and v[4] == interior_business[2][2] and enter_business[playername] == 1 then
						triggerClientEvent( playerid, "event_shop_menu", playerid, k, 2 )
						state_gui_window[playername] = 1
						return

					elseif getElementDimension(playerid) == v[5] and v[4] == interior_business[3][2] and enter_business[playername] == 1 then
						triggerClientEvent( playerid, "event_shop_menu", playerid, k, 3 )
						state_gui_window[playername] = 1
						return

					elseif getElementDimension(playerid) == v[5] and v[4] == interior_business[4][2] and enter_business[playername] == 1 then
						triggerClientEvent( playerid, "event_shop_menu", playerid, k, 4 )
						state_gui_window[playername] = 1
						return

					elseif isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius*2) and search_inv_player(playerid, 43, k) ~= 0 then
						for j,i in pairs(interior_business) do
							if v[4] == interior_business[j][2] then
								triggerClientEvent( playerid, "event_business_menu", playerid, k )
								state_gui_window[playername] = 1
								return
							end
						end
					end
				end


				if enter_job[playername] == 1 then--здания
					if interior_job[2][1] == getElementInterior(playerid) and interior_job[2][10] == getElementDimension(playerid) or interior_job[3][1] == getElementInterior(playerid) and interior_job[3][10] == getElementDimension(playerid) or interior_job[4][1] == getElementInterior(playerid) and interior_job[4][10] == getElementDimension(playerid) then
						if search_inv_player(playerid, 10, playername) == 0 then
							sendPlayerMessage(playerid, "[ERROR] Вы не полицейский", red[1], red[2], red[3] )
							return
						end

						triggerClientEvent( playerid, "event_cops_menu", playerid )
						state_gui_window[playername] = 1

					elseif interior_job[5][1] == getElementInterior(playerid) and interior_job[5][10] == getElementDimension(playerid) or interior_job[7][1] == getElementInterior(playerid) and interior_job[7][10] == getElementDimension(playerid) or interior_job[8][1] == getElementInterior(playerid) and interior_job[8][10] == getElementDimension(playerid) then
						triggerClientEvent( playerid, "event_mayoralty_menu", playerid )
						state_gui_window[playername] = 1
					end

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

	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then

		for id2,v in pairs(house_pos) do--вход в дома
			if not vehicleid then
				local result = sqlite( "SELECT * FROM house_db WHERE number = '"..id2.."'" )
				local id = result[1]["interior"]

				if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
					if house_door[id2] == 0 then
						sendPlayerMessage(playerid, "[ERROR] Дверь закрыта", red[1], red[2], red[3] )
						return
					end

					if result[1]["nalog"] <= 0 then
						sendPlayerMessage(playerid, "[ERROR] Дом арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
						return
					end

					enter_house[playername] = 1
					setElementDimension(playerid, result[1]["world"])
					setElementInterior(playerid, interior_house[id][1], interior_house[id][3], interior_house[id][4], interior_house[id][5])
					return

				elseif getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[id][1] and enter_house[playername] == 1 then
					if house_door[id2] == 0 then
						sendPlayerMessage(playerid, "[ERROR] Дверь закрыта", red[1], red[2], red[3] )
						return
					end

					enter_house[playername] = 0
					setElementDimension(playerid, 0)
					setElementInterior(playerid, 0, result[1]["x"],result[1]["y"],result[1]["z"])

					if search_inv_player(playerid, 25, id2) ~= 0 then
						triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
					end
					return
				end
			end
		end


		for id2,v in pairs(business_pos) do--вход в бизнесы
			if not vehicleid then
				local result = sqlite( "SELECT * FROM business_db WHERE number = '"..id2.."'" )
				local id = result[1]["interior"]

				if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
					if id == 5 then
						return
					end

					if result[1]["nalog"] <= 0 then
						sendPlayerMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
						return
					end
					
					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 1
					setElementDimension(playerid, result[1]["world"])
					setElementInterior(playerid, interior_business[id][1], interior_business[id][3], interior_business[id][4], interior_business[id][5])
					return

				elseif getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_business[id][1] and enter_business[playername] == 1 and id ~= 5 then

					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 0
					setElementDimension(playerid, 0)
					setElementInterior(playerid, 0, result[1]["x"],result[1]["y"],result[1]["z"])
					return
				end
			--[[else--убрал из-за бага, игрок при тп падает с мотика
				local result = sqlite( "SELECT * FROM business_db WHERE number = '"..id2.."'" )
				local id = result[1]["interior"]

				if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) and id == 5 then

					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 1

					setElementRotation(vehicleid, 0, 0, 90)

					setElementDimension(vehicleid, result[1]["world"])
					setElementInterior(vehicleid, interior_business[id][1], interior_business[id][3], interior_business[id][4], interior_business[id][5])

					setElementDimension(playerid, result[1]["world"])
					setElementInterior(playerid, interior_business[id][1], interior_business[id][3], interior_business[id][4], interior_business[id][5])

					setElementFrozen(vehicleid, true)
					setElementFrozen(playerid, true)
					return

				elseif getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_business[id][1] and enter_business[playername] == 1 and id == 5 then
					
					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 0

					setElementDimension(vehicleid, 0)
					setElementInterior(vehicleid, 0, result[1]["x"],result[1]["y"],result[1]["z"])

					setElementDimension(playerid, 0)
					setElementInterior(playerid, 0, result[1]["x"],result[1]["y"],result[1]["z"])

					setElementFrozen(vehicleid, false)
					setElementFrozen(playerid, false)
					return
				end]]
			end
		end


		for id,v in pairs(interior_job) do--вход в здания
			if not vehicleid then
				if isPointInCircle3D(v[6],v[7],v[8], x,y,z, 5) then

					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_job[playername] = 1
					setElementDimension(playerid, v[10])
					setElementInterior(playerid, interior_job[id][1], interior_job[id][3], interior_job[id][4], interior_job[id][5])
					return

				elseif getElementInterior(playerid) == interior_job[id][1] and getElementDimension(playerid) == v[10] and enter_job[playername] == 1 then

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

function inv_server_load (value, id3, id1, id2, tabpanel)--изменение(сохранение) инв-ря на сервере
	local playername = tabpanel
	local plate = tabpanel
	local h = tabpanel

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
		array_house_1[h][id3+1] = id1
		array_house_2[h][id3+1] = id2

		local result = sqlite( "SELECT COUNT() FROM house_db WHERE number = '"..h.."'" )
		if result[1]["COUNT()"] == 1 then
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
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..id2.."'" )
			if result[1]["COUNT()"] == 1 then

				for k,vehicle in pairs(getElementsByType("vehicle")) do
					local x1,y1,z1 = getElementPosition(vehicle)
					local plate = getVehiclePlateText ( vehicle )

					if isPointInCircle3D(x,y,z, x1,y1,z1, 5) and tonumber(plate) == id2 then
						if isVehicleLocked ( vehicle ) then
							setVehicleLocked ( vehicle, false )
							me_chat(playerid, playername.." открыл(а) двери т/с")
						else
							setVehicleLocked ( vehicle, true )
							me_chat(playerid, playername.." закрыл(а) двери т/с")
						end
						return
					end
				end

				me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			end
			return

		elseif id1 == 2 or id1 == 44 or id1 == 45 or id1 == 50 then--права, АЖ, РЛ, лиц на оружие
			me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			return

		elseif id1 == 1 then--показать бумажник
			me_chat(playerid, playername.." показал(а) свой бумажник в котором находится "..id2.."$")
			return

		elseif id1 == 24 or id1 == 48 then--ящик, тушка свиньи
			return

-----------------------------------------------------нужды-------------------------------------------------------------
		elseif id1 == 3 or id1 == 7 or id1 == 8 then--сигареты
			local satiety_minys = 5

			if getElementHealth(playerid) == max_heal then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1

			if id1 == 3 then
				local hp = max_heal*0.05
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])

			elseif id1 == 7 then
				local hp = max_heal*0.10
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])

			elseif id1 == 8 then
				local hp = max_heal*0.15
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])
			end

			if satiety[playername]-satiety_minys >= 0 then
				satiety[playername] = satiety[playername]-satiety_minys
				sendPlayerMessage(playerid, "-"..satiety_minys.." ед. сытости", yellow[1], yellow[2], yellow[3])
			end

			--object_attach(playerid, 1485, 12, -0.1,0,0.04, 0,0,10, 3500)

			if vehicleid then
				setPedAnimation(playerid, "ped", "smoke_in_car", -1, false, true, true, false)
			else
				setPedAnimation(playerid, "smoking", "m_smk_drag", -1, false, true, true, false)
			end

			me_chat(playerid, playername.." выкурил(а) сигарету")

		elseif id1 == 4 then--аптечка
			if getElementHealth(playerid) == max_heal then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1

			setElementHealth(playerid, max_heal)
			sendPlayerMessage(playerid, "+"..max_heal.." хп", yellow[1], yellow[2], yellow[3])

			me_chat(playerid, playername.." использовал(а) аптечку")

		elseif id1 == 20 then--нарко
			local satiety_minys = 10
			local drugs_plus = 1

			if getElementHealth(playerid) == max_heal then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			elseif drugs[playername]+drugs_plus > max_drugs then
				sendPlayerMessage(playerid, "[ERROR] У вас сильная наркозависимость", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1

			local hp = max_heal*0.50
			setElementHealth(playerid, getElementHealth(playerid)+hp)
			sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])

			drugs[playername] = drugs[playername]+drugs_plus
			sendPlayerMessage(playerid, "+"..drugs_plus.." ед. наркозависимости", yellow[1], yellow[2], yellow[3])

			if satiety[playername]-satiety_minys >= 0 then
				satiety[playername] = satiety[playername]-satiety_minys
				sendPlayerMessage(playerid, "-"..satiety_minys.." ед. сытости", yellow[1], yellow[2], yellow[3])
			end

			me_chat(playerid, playername.." употребил(а) наркотики")

		elseif id1 == 21 or id1 == 22 then--пиво
			local alcohol_plus = 10
			local hygiene_minys = 5

			if getElementHealth(playerid) == max_heal then
				sendPlayerMessage(playerid, "[ERROR] У вас полное здоровье", red[1], red[2], red[3] )
				return
			elseif alcohol[playername]+alcohol_plus > max_alcohol then
				sendPlayerMessage(playerid, "[ERROR] Вы сильно пьяны", red[1], red[2], red[3] )
				return
			end

			id2 = id2 - 1

			if id1 == 21 then
				local satiety_plus = 10
				local hp = max_heal*0.20
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])

				if satiety[playername]+satiety_plus <= max_satiety then
					satiety[playername] = satiety[playername]+satiety_plus
					sendPlayerMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow[1], yellow[2], yellow[3])
				end

			elseif id1 == 22 then
				local satiety_plus = 5
				local hp = max_heal*0.25
				setElementHealth(playerid, getElementHealth(playerid)+hp)
				sendPlayerMessage(playerid, "+"..hp.." хп", yellow[1], yellow[2], yellow[3])

				if satiety[playername]+satiety_plus <= max_satiety then
					satiety[playername] = satiety[playername]+satiety_plus
					sendPlayerMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow[1], yellow[2], yellow[3])
				end
			end

			alcohol[playername] = alcohol[playername]+alcohol_plus
			sendPlayerMessage(playerid, "+"..(alcohol_plus/100).." промилле", yellow[1], yellow[2], yellow[3])

			if hygiene[playername]-hygiene_minys >= 0 then
				hygiene[playername] = hygiene[playername]-hygiene_minys
				sendPlayerMessage(playerid, "-"..hygiene_minys.." ед. чистоплотности", yellow[1], yellow[2], yellow[3])
			end

			--object_attach(playerid, 1484, 11, 0.1,-0.02,0.13, 0,130,0, 2000)
			setPedAnimation(playerid, "vending", "vend_drink2_p", -1, false, true, true, false)

			me_chat(playerid, playername.." выпил(а) пиво")

		elseif id1 == 53 or id1 == 54 then--бургер, хот-дог
			id2 = id2 - 1

			if id1 == 53 then
				local satiety_plus = 50

				if satiety[playername]+satiety_plus > max_satiety then
					sendPlayerMessage(playerid, "[ERROR] Вы не голодны", red[1], red[2], red[3] )
					return
				end

				satiety[playername] = satiety[playername]+satiety_plus
				sendPlayerMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow[1], yellow[2], yellow[3])
				me_chat(playerid, playername.." съел(а) "..info_png[id1][1])

			elseif id1 == 54 then
				local satiety_plus = 25

				if satiety[playername]+satiety_plus > max_satiety then
					sendPlayerMessage(playerid, "[ERROR] Вы не голодны", red[1], red[2], red[3] )
					return
				end

				satiety[playername] = satiety[playername]+satiety_plus
				sendPlayerMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow[1], yellow[2], yellow[3])
				me_chat(playerid, playername.." съел(а) "..info_png[id1][1])
			end

			--object_attach(playerid, 1484, 11, 0.1,-0.02,0.13, 0,130,0, 2000)
			setPedAnimation(playerid, "food", "eat_burger", -1, false, true, true, false)

		elseif id1 == 55 or id1 == 56 then--мыло, пижама
			id2 = id2 - 1

			if id1 == 55 then
				local sleep_hygiene_plus = 100

				if hygiene[playername]+sleep_hygiene_plus > max_hygiene then
					sendPlayerMessage(playerid, "[ERROR] Вы чисты", red[1], red[2], red[3] )
					return
				elseif enter_house[playername] == 0 then
					sendPlayerMessage(playerid, "[ERROR] Вы не в доме", red[1], red[2], red[3] )
					return
				end

				hygiene[playername] = hygiene[playername]+sleep_hygiene_plus
				sendPlayerMessage(playerid, "+"..sleep_hygiene_plus.." ед. чистоплотности", yellow[1], yellow[2], yellow[3])
				me_chat(playerid, playername.." помылся(ась)")

				setPedAnimation(playerid, "int_house", "wash_up", -1, false, true, true, false)

			elseif id1 == 56 then
				local sleep_hygiene_plus = 100

				if sleep[playername]+sleep_hygiene_plus > max_sleep then
					sendPlayerMessage(playerid, "[ERROR] Вы бодры", red[1], red[2], red[3] )
					return
				elseif enter_house[playername] == 0 then
					sendPlayerMessage(playerid, "[ERROR] Вы не в доме", red[1], red[2], red[3] )
					return
				end

				sleep[playername] = sleep[playername]+sleep_hygiene_plus
				sendPlayerMessage(playerid, "+"..sleep_hygiene_plus.." ед. сна", yellow[1], yellow[2], yellow[3])
				me_chat(playerid, playername.." вздремнул(а)")
			end

		elseif id1 == 42 then--лекарство от наркозависимости
			id2 = id2 - 1

			local drugs_minys = 10

			if drugs[playername]-drugs_minys < 0 then
				sendPlayerMessage(playerid, "[ERROR] У вас нет наркозависимости", red[1], red[2], red[3] )
				return
			end

			drugs[playername] = drugs[playername]-drugs_minys
			sendPlayerMessage(playerid, "-"..drugs_minys.." ед. наркозависимости", yellow[1], yellow[2], yellow[3])
			me_chat(playerid, playername.." выпил(а) "..info_png[id1][1])

-----------------------------------------------------------------------------------------------------------------------

		elseif id1 == 5 then--канистра
			if vehicleid then
				local plate = getVehiclePlateText ( vehicleid )

				if not getVehicleEngineState(vehicleid) then
					if fuel[plate]+id2 <= max_fuel then

						fuel[plate] = fuel[plate]+id2
						me_chat(playerid, playername.." заправил(а) машину из канистры")
						id2 = 0

					else
						sendPlayerMessage(playerid, "[ERROR] Максимальная вместимость бака "..max_fuel.." литров", red[1], red[2], red[3])
						return
					end
				else
					sendPlayerMessage(playerid, "[ERROR] Заглушите двигатель", red[1], red[2], red[3])
					return
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
				return
			end

		elseif id1 == 10 then--документы копа
			if search_inv_player(playerid, 10, playername) ~= 0 then
				if search_inv_player(playerid, 28, 1) ~= 0 then
					me_chat(playerid, "Офицер "..playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
				elseif search_inv_player(playerid, 29, 1) ~= 0 then
					me_chat(playerid, "Детектив "..playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
				elseif search_inv_player(playerid, 30, 1) ~= 0 then
					me_chat(playerid, "Сержант "..playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
				elseif search_inv_player(playerid, 31, 1) ~= 0 then
					me_chat(playerid, "Лейтенант "..playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
				elseif search_inv_player(playerid, 32, 1) ~= 0 then
					me_chat(playerid, "Капитан "..playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
				elseif search_inv_player(playerid, 33, 1) ~= 0 then
					me_chat(playerid, "Шеф полиции "..playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Вы не полицейский", red[1], red[2], red[3])
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

		elseif id1 >= 28 and id1 <= 33 then--шевроны
			return

		elseif id1 == 23 then--ремонтный набор
			if vehicleid then
				if getVehicleEngineState(vehicleid) then
					sendPlayerMessage(playerid, "[ERROR] Заглушите двигатель", red[1], red[2], red[3])
					return
				end

				if getElementHealth(vehicleid) == 1000 then
					sendPlayerMessage(playerid, "[ERROR] Т/с не нуждается в ремонте", red[1], red[2], red[3] )
					return
				end

				id2 = id2 - 1

				fixVehicle ( vehicleid )

				me_chat(playerid, playername.." починил(а) т/с")
			else
				sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
				return
			end

		elseif id1 == 25 then--ключ от дома
			local h = id2
			local result = sqlite( "SELECT COUNT() FROM house_db WHERE number = '"..h.."'" )
			if result[1]["COUNT()"] == 1 then

				local result = sqlite( "SELECT * FROM house_db WHERE number = '"..h.."'" )
				if getElementDimension(playerid) == result[1]["world"] and getElementInterior(playerid) == interior_house[result[1]["interior"]][1] or isPointInCircle3D(result[1]["x"],result[1]["y"],result[1]["z"], x,y,z, house_bussiness_radius) then
					if house_door[h] == 0 then
						house_door[h] = 1
						me_chat(playerid, playername.." открыл(а) дверь дома")
					else
						house_door[h] = 0
						me_chat(playerid, playername.." закрыл(а) дверь дома")
					end

					sqlite( "UPDATE house_db SET door = '"..house_door[h].."' WHERE number = '"..h.."'")

					return
				end

				me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			end
			return

		elseif id1 == 27 then--одежда
			local skin = getElementModel(playerid)

			setElementModel(playerid, id2)

			sqlite( "UPDATE account SET skin = '"..id2.."' WHERE name = '"..playername.."'")

			id2 = skin

			me_chat(playerid, playername.." переоделся(ась)")

		elseif id1 == 39 then--броник
			if getPedArmor(playerid) ~= 0 then
				sendPlayerMessage(playerid, "[ERROR] На вас надет бронежилет", red[1], red[2], red[3] )
				return
			end

			setPedArmor(playerid, 100)

			id2 = id2 - 1

			me_chat(playerid, playername.." надел(а) бронежилет")

		elseif id1 == 43 then--документы на бизнес
			local result = sqlite( "SELECT COUNT() FROM business_db WHERE number = '"..id2.."'" )
			if result[1]["COUNT()"] == 1 then
				me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			end
			return

		elseif id1 == 46 then--радар
			if speed_car_device[playername] == 0 then
				speed_car_device[playername] = 1
				triggerClientEvent( playerid, "event_speed_car_device_fun", playerid, speed_car_device[playername])

				me_chat(playerid, playername.." включил(а) "..info_png[id1][1])
			else
				speed_car_device[playername] = 0
				triggerClientEvent( playerid, "event_speed_car_device_fun", playerid, speed_car_device[playername])

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
			id2 = id2 - 1

			setTimer(function( playerid )
				triggerClientEvent( playerid, "event_setPedOxygenLevel_fun", playerid )
				sendPlayerMessage(playerid, "Кислород пополнился", yellow[1], yellow[2], yellow[3] )
			end, 38000, 8, playerid)

			me_chat(playerid, playername.." надел(а) "..info_png[id1][1])

		elseif id1 == 57 then--алкостестер
			local alcohol_test = alcohol[playername]/100
			
			me_chat(playerid, playername.." подул(а) в "..info_png[id1][1])
			do_chat(playerid, info_png[id1][1].." показал "..alcohol_test.." промилле")

			if alcohol_test >= zakon_alcohol then
				local crimes_plus = zakon_alcohol_crimes
				crimes[playername] = crimes[playername]+crimes_plus
				sendPlayerMessage(playerid, "+"..crimes_plus.." преступлений, всего преступлений "..crimes[playername]+1, yellow[1], yellow[2], yellow[3])
			end

		elseif id1 == 58 then--наркостестер
			local drugs_test = drugs[playername]
			
			me_chat(playerid, playername.." подул(а) в "..info_png[id1][1])
			do_chat(playerid, info_png[id1][1].." показал "..drugs_test.."% зависимости")

			if drugs_test >= zakon_drugs then
				local crimes_plus = zakon_drugs_crimes
				crimes[playername] = crimes[playername]+crimes_plus
				sendPlayerMessage(playerid, "+"..crimes_plus.." преступлений, всего преступлений "..crimes[playername]+1, yellow[1], yellow[2], yellow[3])
			end

		elseif id1 == 59 then--налог дома
			if enter_house[playername] == 1 then
				sqlite( "UPDATE house_db SET nalog = nalog + '"..id2.."' WHERE number = '"..getElementDimension(playerid).."'")

				me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])

				id2 = 0
			else
				sendPlayerMessage(playerid, "[ERROR] Вы не в доме", red[1], red[2], red[3] )
				return
			end

		elseif id1 == 60 then--налог бизнеса
			local count = 0
			for k,v in pairs(business_pos) do
				if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
					sqlite( "UPDATE business_db SET nalog = nalog + '"..id2.."' WHERE number = '"..k.."'")
					
					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])

					id2 = 0
					count = 1
					break
				end
			end

			if count == 0 then
				sendPlayerMessage(playerid, "[ERROR] Вы должны быть около бизнеса", red[1], red[2], red[3] )
				return
			end
		
		elseif id1 == 61 then--налог авто
			if vehicleid then
				local plate = getVehiclePlateText(vehicleid)
				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET nalog = nalog + '"..id2.."' WHERE carnumber = '"..plate.."'")

					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])

					id2 = 0
				else
					sendPlayerMessage(playerid, "[ERROR] Т/с не найдено", red[1], red[2], red[3] )
					return
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
				return
			end
		end

		-----------------------------------------------------------------------------------------------------------------------
		save_player_action(playerid, "[use_inv] "..playername.." [value - "..value.."] ["..info_png[id1][1]..", "..id2.."("..id_2..")]")

		if id2 == 0 then
			id1, id2 = 0, 0
			triggerClientEvent( playerid, "event_change_image", playerid, "player", id3, id1)
		end

		inv_server_load( "player", id3, id1, id2, playername )
		triggerClientEvent( playerid, "event_inv_load", playerid, "player", id3, id1, id2 )
	end
end
addEvent( "event_use_inv", true )
addEventHandler ( "event_use_inv", getRootElement(), use_inv )

function give_subject( playerid, value, id1, id2 )--выдача предметов игроку или авто
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local vehicleid = getPlayerVehicle(playerid)
	local count2 = 0

	if value == "player" then

		if search_inv_player(playerid, id1, search_inv_player_2_parameter(playerid, id1)) >= 1 then
			sendPlayerMessage(playerid, "[ERROR] Можно переносить только один предмет", red[1], red[2], red[3])
			return
		end

		if inv_player_empty(playerid, id1, id2) then

			sendPlayerMessage(playerid, "Вы получили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])

			save_player_action(playerid, "[give_subject] "..playername.." [value - "..value.."] ["..info_png[id1][1]..", "..id2.."]")
		else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end

	elseif value == "car" then--для работ по перевозке ящиков

		if vehicleid then
			if not getVehicleOccupant ( vehicleid, 0 ) then
				sendPlayerMessage(playerid, "[ERROR] Вы не водитель", red[1], red[2], red[3] )
				return
			end

			if getElementModel(vehicleid) ~= 414 then
				sendPlayerMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( 414 ), red[1], red[2], red[3] )
				return
			end

			for i=0,max_inv do
				if inv_car_empty(playerid, id1, id2) then
					count2 = count2 + 1
				end
			end

			if count2 ~= 0 then
				local count = search_inv_car(playerid, id1, id2)

				sendPlayerMessage(playerid, "Вы загрузили в т/с "..info_png[id1][1].." "..count.." шт за "..id2.."$", svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])
				sendPlayerMessage(playerid, "Езжайте на место разгрузки в порт или в любой бизнес", color_tips[1], color_tips[2], color_tips[3])

				save_player_action(playerid, "[give_subject] "..playername.." [value - "..value..", count - "..count.."] ["..info_png[id1][1]..", "..id2.."]")
			else
				sendPlayerMessage(playerid, "[ERROR] Багажник заполнен", red[1], red[2], red[3] )
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
		end
	end

end
addEvent( "event_give_subject", true )
addEventHandler ( "event_give_subject", getRootElement(), give_subject )

function delet_subject(playerid, id)--удаление предметов из авто, для работ по перевозке ящиков
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local x,y,z = getElementPosition(playerid)
	local money = 0
		
	if vehicleid then
		if not getVehicleOccupant ( vehicleid, 0 ) then
			sendPlayerMessage(playerid, "[ERROR] Вы не водитель", red[1], red[2], red[3] )
			return
		end

		local sic2p = search_inv_car_2_parameter(playerid, id)
		local count = search_inv_car(playerid, id, sic2p)

		if count ~= 0 then

			for k,v in pairs(business_pos) do
				if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then

					if id ~= 24 then
						sendPlayerMessage(playerid, "[ERROR] Нужны только ящики", red[1], red[2], red[3] )
						return
					end

					local result = sqlite( "SELECT * FROM business_db WHERE number = '"..k.."'" )

					if result[1]["buyprod"] == 0 then
						sendPlayerMessage(playerid, "[ERROR] Цена покупки не указана", red[1], red[2], red[3] )
						return
					end

					money = count*result[1]["buyprod"]

					if result[1]["money"] < money then
						sendPlayerMessage(playerid, "[ERROR] Недостаточно средств на балансе бизнеса", red[1], red[2], red[3] )
						return
					end

					for i=0,max_inv do
						if inv_car_delet(playerid, id, sic2p) then
						end
					end

					sqlite( "UPDATE business_db SET warehouse = warehouse + '"..count.."', money = money - '"..money.."' WHERE number = '"..k.."'")

					inv_server_load( "player", 0, 1, array_player_2[playername][1]+money, playername )

					sendPlayerMessage(playerid, "Вы разгрузили из т/с "..info_png[id][1].." "..count.." шт ("..result[1]["buyprod"].."$ за 1 шт) за "..money.."$", green[1], green[2], green[3])

					save_player_action(playerid, "[delet_subject_business] "..playername.." [count - "..count.."], [+"..money.."$, "..array_player_2[playername][1].."$], "..info_bisiness(k))
					return
				end
			end

			if isPointInCircle3D(x,y,z, 2788.23046875,-2455.99609375,13.340852737427, 15) then--место разгрузки ящиков 
				for i=0,max_inv do
					if inv_car_delet(playerid, id, sic2p) then
					end
				end

				money = count*sic2p

				inv_server_load( "player", 0, 1, array_player_2[playername][1]+money, playername )

				sendPlayerMessage(playerid, "Вы разгрузили из т/с "..info_png[id][1].." "..count.." шт ("..sic2p.."$ за 1 шт) за "..money.."$", green[1], green[2], green[3])

				save_player_action(playerid, "[delet_subject_job] "..playername.." [count - "..count..", price - "..sic2p.."], [+"..money.."$, "..array_player_2[playername][1].."$]")
				return
			end

		end
	else
		--sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
	end
end

-------------------------------команды игроков----------------------------------------------------------
addCommandHandler("evacuationcar",--эвакуция авто
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id = tonumber(id)
	local cash = 500

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendPlayerMessage(playerid, "[ERROR] /evacuationcar [номер т/с]", red[1], red[2], red[3])
		return
	end

	if cash <= array_player_2[playername][1] then
		for k,vehicleid in pairs(getElementsByType("vehicle")) do
			local plate = getVehiclePlateText(vehicleid)
			if id == tonumber(plate) then
				local result = sqlite( "SELECT COUNT() FROM car_db WHERE carnumber = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					local result = sqlite( "SELECT * FROM car_db WHERE carnumber = '"..plate.."'" )
					for k,v in pairs(result) do
						if v["frozen"] == 0 then
							if v["evacuate"] == 1 then
								sendPlayerMessage(playerid, "[ERROR] Т/с на эвакуаторе", red[1], red[2], red[3])
								return
							end

							if search_inv_player(playerid, 6, id) ~= 0 then
								setElementPosition(vehicleid, x+5,y,z+1)

								sqlite( "UPDATE car_db SET x = '"..(x+5).."', y = '"..y.."', z = '"..(z+1).."', fuel = '"..fuel[plate].."' WHERE carnumber = '"..plate.."'")

								inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

								sendPlayerMessage(playerid, "Вы эвакуировали т/с за "..cash.."$", orange[1], orange[2], orange[3])
							else
								sendPlayerMessage(playerid, "[ERROR] У вас нет ключей от этого т/с", red[1], red[2], red[3])
							end
						else
							sendPlayerMessage(playerid, "[ERROR] Т/с на штрафстоянке", red[1], red[2], red[3])
						end
					end
				else
					sendPlayerMessage(playerid, "[ERROR] Т/с не найдено", red[1], red[2], red[3])
				end

				return
			end
		end

		sendPlayerMessage(playerid, "[ERROR] Т/с не найдено", red[1], red[2], red[3])
	else
		sendPlayerMessage(playerid, "[ERROR] Нужно иметь "..cash.."$", red[1], red[2], red[3] )
	end
end)

addCommandHandler("pay",--передача денег
function (playerid, cmd, id, cash)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local cash = tonumber(cash)

	if logged[playername] == 0 then
		return
	end

	if not cash then
		sendPlayerMessage(playerid, "[ERROR] /pay [ник соблюдая регистр] [сумма]", red[1], red[2], red[3])
		return
	end

	if cash > array_player_2[playername][1] then
		sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3] )
		return
	end

	for k,v in pairs(getElementsByType("player")) do
		local player = getPlayerFromName ( id )
		local player_name = getPlayerName ( v )

		if id == player_name then
			if logged[id] == 0 then
				sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
				return
			end

			local x1,y1,z1 = getElementPosition(player)
			if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then
				inv_server_load( "player", 0, 1, array_player_2[playername][1]-cash, playername )

				inv_server_load( "player", 0, 1, array_player_2[id][1]+cash, id )

				me_chat(playerid, playername.." передал(а) "..id.." "..cash.."$")
			else
				sendPlayerMessage(playerid, "[ERROR] Игрок далеко", red[1], red[2], red[3] )
			end

			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /prison [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не полицейский", red[1], red[2], red[3] )
		return
	end

	for k,v in pairs(getElementsByType("player")) do
		local player = getPlayerFromName ( id )
		local player_name = getPlayerName ( v )

		if id == player_name then
			local x1,y1,z1 = getElementPosition(player)

			if logged[id] == 0 then
				sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
				return
			end

			if crimes[id] == -1 then
				sendPlayerMessage(playerid, "[ERROR] Гражданин чист перед законом", red[1], red[2], red[3] )
				return
			end

			if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then
				me_chat(playerid, playername.." посадил(а) "..id.." в камеру на "..(crimes[id]+1).." мин")

				arrest[id] = 1

				sendPlayerMessage(playerid, "Вы получили премию "..(cash*(crimes[id]+1)).."$", green[1], green[2], green[3] )

				inv_server_load( "player", 0, 1, array_player_2[playername][1]+(cash*(crimes[id]+1)), playername )
			else
				sendPlayerMessage(playerid, "[ERROR] Игрок далеко", red[1], red[2], red[3] )
			end

			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
end)

addCommandHandler("policecertificate",--выдать удостоверение
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendPlayerMessage(playerid, "[ERROR] /policecertificate [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3] )
		return
	end

	if inv_player_empty(playerid, 10, id) then
		sendPlayerMessage(playerid, "Вы получили "..info_png[10][1].." "..id, yellow[1], yellow[2], yellow[3])

		save_player_action(playerid, "[police_sub] "..playername.." [10, "..id.."]")
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
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

	if search_inv_player(playerid, 45, playername) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не риэлтор", red[1], red[2], red[3] )
		return
	end

	local result = sqlite( "SELECT COUNT() FROM house_db" )
	local house_number = result[1]["COUNT()"]
	for h,v in pairs(house_pos) do
		if not isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
			house_count = house_count+1
		end
	end

	local result = sqlite( "SELECT COUNT() FROM business_db" )
	local business_number = result[1]["COUNT()"]
	for h,v in pairs(business_pos) do 
		if not isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
			business_count = business_count+1
		end
	end

	local job_number = #interior_job
	for h,v in pairs(interior_job) do
		if not isPointInCircle3D(v[6],v[7],v[8], x,y,z, 5) then
			job_count = job_count+1
		end
	end

	if business_count == business_number and house_count == house_number and job_count == job_number then
		local dim = house_number+1

		if inv_player_empty(playerid, 25, dim) then
			house_pos[dim] = {x,y,z}
			array_house_1[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			house_door[dim] = 0

			createBlip ( house_pos[dim][1], house_pos[dim][2], house_pos[dim][3], 32, 0, 0,0,0,0, 0, 500 )
			createPickup ( house_pos[dim][1], house_pos[dim][2], house_pos[dim][3], 3, house_icon, 10000 )

			sqlite( "INSERT INTO house_db (number, door, nalog, x, y, z, interior, world, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..dim.."', '"..house_door[dim].."', '5', '"..x.."', '"..y.."', '"..z.."', '1', '"..dim.."', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

			sendPlayerMessage(playerid, "Вы получили "..info_png[25][1].." "..dim.." "..info_png[25][2], orange[1], orange[2], orange[3])
			
			triggerClientEvent( playerid, "event_bussines_house_fun", playerid, dim, house_pos[dim][1], house_pos[dim][2], house_pos[dim][3], "house", house_bussiness_radius )

			save_realtor_action(playerid, "[sellhouse] "..playername.." [house - "..dim..", x - "..house_pos[dim][1]..", y - "..house_pos[dim][2]..", z - "..house_pos[dim][3].."]")
		else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Рядом есть бизнес, дом или гос. здание", red[1], red[2], red[3] )
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
		sendPlayerMessage(playerid, "[ERROR] /sellbusiness [номер бизнеса от 1 до "..#interior_business.."]", red[1], red[2], red[3])
		return
	end

	if id >= 1 and id <= #interior_business then
		if search_inv_player(playerid, 45, playername) == 0 then
			sendPlayerMessage(playerid, "[ERROR] Вы не риэлтор", red[1], red[2], red[3] )
			return
		end

		local result = sqlite( "SELECT COUNT() FROM business_db" )
		local business_number = result[1]["COUNT()"]
		for h,v in pairs(business_pos) do 
			if not isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
				business_count = business_count+1
			end
		end

		local result = sqlite( "SELECT COUNT() FROM house_db" )
		local house_number = result[1]["COUNT()"]
		for h,v in pairs(house_pos) do
			if not isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) then
				house_count = house_count+1
			end
		end

		local job_number = #interior_job
		for h,v in pairs(interior_job) do
			if not isPointInCircle3D(v[6],v[7],v[8], x,y,z, 5) then
				job_count = job_count+1
			end
		end

		if business_count == business_number and house_count == house_number and job_count == job_number then
			local dim = business_number+1

			if inv_player_empty(playerid, 43, dim) then
				business_pos[dim] = {x,y,z, interior_business[id][2], dim}

				createBlip ( business_pos[dim][1], business_pos[dim][2], business_pos[dim][3], interior_business[id][6], 0, 0,0,0,0, 0, 500 )
				createPickup ( business_pos[dim][1], business_pos[dim][2], business_pos[dim][3], 3, business_icon, 10000 )

				sqlite( "INSERT INTO business_db (number, type, price, buyprod, money, nalog, warehouse, x, y, z, interior, world) VALUES ('"..dim.."', '"..interior_business[id][2].."', '0', '0', '0', '5', '0', '"..x.."', '"..y.."', '"..z.."', '"..id.."', '"..dim.."')" )

				sendPlayerMessage(playerid, "Вы получили "..info_png[43][1].." "..dim.." "..info_png[43][2], orange[1], orange[2], orange[3])
				
				triggerClientEvent( playerid, "event_bussines_house_fun", playerid, dim, business_pos[dim][1], business_pos[dim][2], business_pos[dim][3], "biz", house_bussiness_radius )

				save_realtor_action(playerid, "[sellbusiness] "..playername.." [business - "..dim..", x - "..business_pos[dim][1]..", y - "..business_pos[dim][2]..", z - "..business_pos[dim][3].."]")
			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Рядом есть бизнес, дом или гос. здание", red[1], red[2], red[3] )
		end
	else
		sendPlayerMessage(playerid, "[ERROR] от 1 до "..#interior_business, red[1], red[2], red[3] )
	end
end)

addCommandHandler ( "buyinthouse",--команда по смене интерьера дома
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id = tonumber(id)
	local cash = 1000

	if logged[playername] == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /buyinthouse [номер интерьера от 1 до "..#interior_house.."]", red[1], red[2], red[3])
		return
	end

	if id >= 1 and id <= #interior_house then
		if (cash*id) <= array_player_2[playername][1] then
			for h,v in pairs(house_pos) do
				if isPointInCircle3D(v[1],v[2],v[3], x,y,z, house_bussiness_radius) and getElementDimension(playerid) == 0 and getElementInterior(playerid) == 0 then
					if search_inv_player(playerid, 25, h) ~= 0 then
						sqlite( "UPDATE house_db SET interior = '"..id.."' WHERE number = '"..h.."'")

						inv_server_load( "player", 0, 1, array_player_2[playername][1]-(cash*id), playername )

						sendPlayerMessage(playerid, "Вы изменили интерьер на "..id.." за "..(cash*id).."$", orange[1], orange[2], orange[3])

						save_player_action(playerid, "[buyinthouse] "..playername.." [id - "..id.."], [-"..(cash*id).."$, "..array_player_2[playername][1].."$]")
					else
						sendPlayerMessage(playerid, "[ERROR] У вас нет ключей от дома", red[1], red[2], red[3] )
					end

					return
				end
			end

			sendPlayerMessage(playerid, "[ERROR] Нужно находиться около дома", red[1], red[2], red[3] )
		else
			sendPlayerMessage(playerid, "[ERROR] Нужно иметь "..(cash*id).."$", red[1], red[2], red[3] )
		end
	else
		sendPlayerMessage(playerid, "[ERROR] от 1 до "..#interior_house, red[1], red[2], red[3] )
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

	if not val1 or not val2  then
		sendPlayerMessage(playerid, "[ERROR] /sub [ид предмета] [количество]", red[1], red[2], red[3])
		return
	end

	if val1 > #info_png or val1 < 2 then
		sendPlayerMessage(playerid, "[ERROR] от 2 до "..#info_png, red[1], red[2], red[3])
		return
	end

	if inv_player_empty(playerid, val1, val2) then
		sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])

		save_admin_action(playerid, "[admin_sub] "..playername.." ["..val1..", "..val2.."]")
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
	end
end)

local sub_text = {2,10,44,45,50}
addCommandHandler ( "subt",--выдача предметов с текстом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), id2
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if val1 == nil or val2 == nil then
		sendPlayerMessage(playerid, "[ERROR] /subt [ид предмета] [текст]", red[1], red[2], red[3])
		return
	end

	if val1 > #info_png or val1 < 2 then
		sendPlayerMessage(playerid, "[ERROR] от 2 до "..#info_png, red[1], red[2], red[3])
		return
	end

	for k,v in pairs(sub_text) do
		if val1 == v then
			if inv_player_empty(playerid, val1, val2) then
				sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])

				save_admin_action(playerid, "[admin_subt] "..playername.." ["..val1..", "..val2.."]")
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
		sendPlayerMessage(playerid, "[ERROR] /go [и 3 координаты]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )
	spawnPlayer(playerid, x, y, z, 0, result[1]["skin"], getElementInterior(playerid), getElementDimension(playerid))
end)

addCommandHandler ( "fuel",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local id = tonumber(id)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /fuel [указать топливо от 0 до 50]", red[1], red[2], red[3])
		return
	end

	if vehicleid and id >= 0 and id <= 50 then
		local plate = getVehiclePlateText(vehicleid)
		fuel[plate] = id
		sendPlayerMessage(playerid, "fuel car "..id, lyme[1], lyme[2], lyme[3])
	end
end)

addCommandHandler ( "pos",
function ( playerid, cmd, ... )
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local text = ""

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	for k,v in ipairs(arg) do
		text = text..v.." "
	end

	local result = sqlite( "INSERT INTO position (description, x, y, z) VALUES ('"..text.."', '"..x.."', '"..y.."', '"..z.."')" )
	sendPlayerMessage(playerid, "save pos "..text, lyme[1], lyme[2], lyme[3])
end)

addCommandHandler ( "stime",
function ( playerid, cmd, id1, id2 )
	local playername = getPlayerName ( playerid )
	local house = tonumber(id1)
	local min = tonumber(id2)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if house == nil or min == nil then
		sendPlayerMessage(playerid, "[ERROR] /stime [час] [минуты]", red[1], red[2], red[3])
		return
	end

	if house >= 0 and house <= 23 and min >= 0 and min <= 59 then
		setTime (house, min)
	end
end)

addCommandHandler ( "logplayer",--чекнуть логи игрока
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /logplayer [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT * FROM account" )
	for k,v in pairs(result) do
		if v["name"] == id then
			local result = sqlite_save_player_action( "SELECT * FROM "..id.."" )
			for k,v in pairs(result) do
				triggerClientEvent(playerid, "event_logsave_fun", playerid, "save", id, k, v["player_action"])
			end

			triggerClientEvent(playerid, "event_logsave_fun", playerid, "load", 0, 0, 0)

			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
end)

addCommandHandler ( "logadmin",--чекнуть логи админов
function (playerid)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	local result = sqlite( "SELECT * FROM save_admin_action" )
	for k,v in pairs(result) do
		triggerClientEvent(playerid, "event_logsave_fun", playerid, "save", "logadmin", k, v["admin_action"])
	end

	triggerClientEvent(playerid, "event_logsave_fun", playerid, "load", 0, 0, 0)
end)

addCommandHandler ( "prisonplayer",--(посадить игрока в тюрьму)
function (playerid, cmd, id, time, ...)
	local playername = getPlayerName ( playerid )
	local reason = ""
	local time = tonumber(time)

	for k,v in ipairs(arg) do
		reason = reason..v.." "
	end

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil or reason == "" or not time then
		sendPlayerMessage(playerid, "[ERROR] /prisonplayer [ник соблюдая регистр] [время] [причина]", red[1], red[2], red[3])
		return
	end

	for k,v in pairs(getElementsByType("player")) do
		local player = getPlayerFromName ( id )
		local player_name = getPlayerName ( v )

		if id == player_name then
			if logged[id] == 0 then
				sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
				return
			end

			sendPlayerMessage( getRootElement(), "Администратор "..playername.." посадил в тюрьму "..id.." на "..time.." мин. Причина: "..reason, lyme[1], lyme[2], lyme[3])

			arrest[id] = 1
			crimes[id] = time-1

			save_admin_action(playerid, "[admin_prisonplayer] "..playername.." prisonplayer "..id.." time "..time.." reason "..reason)
			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
end)

addCommandHandler ( "banplayer",
function ( playerid, cmd, id, ... )
	local playername = getPlayerName ( playerid )
	local reason = ""

	for k,v in ipairs(arg) do
		reason = reason..v.." "
	end

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil or reason == "" then
		sendPlayerMessage(playerid, "[ERROR] /banplayer [ник соблюдая регистр] [причина]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then

		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		if result[1]["ban"] == "1" then
			sendPlayerMessage(playerid, "[ERROR] Игрок уже забанен", red[1], red[2], red[3])
			return
		end

		sqlite( "UPDATE account SET ban = '1', reason = '"..reason.."' WHERE name = '"..id.."'")

		sendPlayerMessage( getRootElement(), "Администратор "..playername.." забанил "..id..". Причина: "..reason, lyme[1], lyme[2], lyme[3])

		local player = getPlayerFromName ( id )
		if player then
			kickPlayer(player, "banplayer reason: "..reason)
		end

		save_admin_action(playerid, "[admin_ban] "..playername.." ban "..id.." reason "..reason)
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "unbanplayer",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /unbanplayer [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then

		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		if result[1]["ban"] == "0" then
			sendPlayerMessage(playerid, "[ERROR] Игрок не забанен", red[1], red[2], red[3])
			return
		end

		sqlite( "UPDATE account SET ban = '0', reason = '0' WHERE name = '"..id.."'")

		sendPlayerMessage( getRootElement(), "Администратор "..playername.." разбанил "..id, lyme[1], lyme[2], lyme[3])

		save_admin_action(playerid, "[admin_unban] "..playername.." unban "..id)
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "banserial",
function ( playerid, cmd, id, ... )
	local playername = getPlayerName ( playerid )
	local reason = ""

	for k,v in ipairs(arg) do
		reason = reason..v.." "
	end

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil or reason == "" then
		sendPlayerMessage(playerid, "[ERROR] /banserial [ник соблюдая регистр] [причина]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then

		local result = sqlite( "SELECT COUNT() FROM banserial_list WHERE name = '"..id.."'" )
		if result[1]["COUNT()"] == 1 then
			sendPlayerMessage(playerid, "[ERROR] Серийник игрока уже забанен", red[1], red[2], red[3])
			return
		end

		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		local result = sqlite( "INSERT INTO banserial_list (name, serial, reason) VALUES ('"..id.."', '"..result[1]["reg_serial"].."', '"..reason.."')" )

		sendPlayerMessage( getRootElement(), "Администратор "..playername.." забанил "..id.." по серийнику. Причина: "..reason, lyme[1], lyme[2], lyme[3])

		local player = getPlayerFromName ( id )
		if player then
			kickPlayer(player, "banserial reason: "..reason)
		end

		save_admin_action(playerid, "[admin_banserial] "..playername.." banserial "..id.." reason "..reason)
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "setzakon",
function ( playerid, cmd, i1, i2, i3, i4, i5, i6, i7, i8 )
	local playername = getPlayerName ( playerid )
	local i1, i2, i3, i4, i5, i6, i7, i8 = tonumber(i1),tonumber(i2),tonumber(i3),tonumber(i4),tonumber(i5),tonumber(i6),tonumber(i7),tonumber(i8)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if not i1 or not i2 or not i3 or not i4 or not i5 or not i6 or not i7 or not i8 then
		sendPlayerMessage(playerid, "[ERROR] /setzakon [zakon_alcohol] [zakon_alcohol_crimes] [zakon_drugs] [zakon_drugs_crimes] [zakon_kill_crimes] [zakon_nalog_car] [zakon_nalog_house] [zakon_nalog_business]", red[1], red[2], red[3])
		return
	end

	sqlite( "UPDATE zakon_mayoralty SET zakon_alcohol = '"..i1.."', zakon_alcohol_crimes = '"..i2.."', zakon_drugs = '"..i3.."', zakon_drugs_crimes = '"..i4.."', zakon_kill_crimes = '"..i5.."', zakon_nalog_car = '"..i6.."', zakon_nalog_house = '"..i7.."', zakon_nalog_business = '"..i8.."'")

	sendPlayerMessage(playerid, "[zakon_alcohol = "..i1.."] [zakon_alcohol_crimes = "..i2.."] [zakon_drugs = "..i3.."] [zakon_drugs_crimes = "..i4.."] [zakon_kill_crimes = "..i5.."] [zakon_nalog_car = "..i6.."] [zakon_nalog_house = "..i7.."] [zakon_nalog_business = "..i8.."]", lyme[1], lyme[2], lyme[3])
end)

addCommandHandler ( "attach",
function ( playerid )
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if vehicleid then
		local x,y,z = getElementPosition(vehicleid)
		if getElementModel(vehicleid) == 548 then
			for k,vehicle in pairs(getElementsByType("vehicle")) do
				local x1,y1,z1 = getElementPosition(vehicle)
				if isPointInCircle3D(x1,y1,z1, x,y,z, 10) then

					if not isElementAttached ( vehicle ) then
						local car_attach = attachElements ( vehicle, vehicleid, 0, 0, -4 )
						if car_attach then
							sendPlayerMessage(playerid, "т/с прикреплен")
						end
					else
						detachElements  ( vehicle, vehicleid )
						sendPlayerMessage(playerid, "т/с откреплен")
					end

					return
				end
			end
		end
	end
end)

addCommandHandler ( "int",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /int [номер интерьера]", red[1], red[2], red[3])
		return
	end

	if interior[id] ~= nil then
		setElementInterior(playerid, 0)
		setElementInterior(playerid, interior[id][1], interior[id][3], interior[id][4], interior[id][5])
		sendPlayerMessage(playerid, "setElementInterior "..interior[id][2], lyme[1], lyme[2], lyme[3])
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
		sendPlayerMessage(playerid, "[ERROR] /dim [номер виртуального мира]", red[1], red[2], red[3])
		return
	end

	setElementDimension ( playerid, id )
	sendPlayerMessage(playerid, "setElementDimension "..id, lyme[1], lyme[2], lyme[3])
end)

addCommandHandler ( "v",--спавн авто для админов
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	local id = tonumber(id)

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /v [ид т/с]", red[1], red[2], red[3])
		return
	end

	if id >= 400 and id <= 611 then
		local number = 00000000

		local val1, val2 = 6, number

		--if inv_player_empty(playerid, 6, val2) then
			local x,y,z = getElementPosition( playerid )
			local vehicleid = createVehicle(id, x+5, y, z+2, 0, 0, 0, val2)
			local plate = getVehiclePlateText ( vehicleid )

			array_car_1[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_car_2[plate] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			fuel[plate] = max_fuel

			setVehicleDamageProof(vehicleid, true)

			--sendPlayerMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])

			save_admin_action(playerid, "[admin_car] "..playername.." model "..id.." plate ["..plate.."]")
		--[[else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end]]
	else
		sendPlayerMessage(playerid, "[ERROR] от 400 до 611", red[1], red[2], red[3])
	end
end)
-----------------------------------------------------------------------------------------

function input_Console ( text )

	if text == "z" then
		pay_nalog()

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

--[[local objPick = 0
function o_pos( thePlayer )
	local x, y, z = getElementPosition (thePlayer)
	objPick = createObject (1485, x, y, z)

	attachElementToBone (objPick, thePlayer, 12, 0, 0, 0, 0, 0, 0)
end

addCommandHandler ("orot",
function (playerid, cmd, id1, id2, id3)
	setElementBoneRotationOffset (objPick, tonumber(id1), tonumber(id2), tonumber(id3))
end)

addCommandHandler ("opos",
function (playerid, cmd, id1, id2, id3)
	setElementBonePositionOffset (objPick, tonumber(id1), tonumber(id2), tonumber(id3))
end)]]
