local database = dbConnect( "sqlite", "ebmp-rpg.db" )
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

function player_position( playerid )
	local x,y,z = getElementPosition(playerid)
	local x_table = split(x, ".")
	local y_table = split(y, ".")

	return x_table[1],y_table[1]
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

function police_chat(playerid, text)
	for k,player in pairs(getElementsByType("player")) do
		local playername = getPlayerName(player)

		if search_inv_player(player, 10, playername) ~= 0 then
			sendPlayerMessage(player, text, blue[1], blue[2], blue[3])
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

	setTimer(function ()
		detachElementFromBone(objPick)
		destroyElement(objPick)
	end, time, 1)
end
-----------------------------------------------------------------------------------------

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
	[24] = {"ящик с товаром", "$ за штуку"},
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
	[40] = {"лом", "%"},
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
	[64] = {"лицензия таксиста на имя", ""},
	[65] = {"инкасаторская сумка", "$ в сумке"},
	[66] = {"лицензия инкассатора на имя", ""},
	[67] = {"бензопила", "шт"},
	[68] = {"дрова", "кг"},
	[69] = {"пустая коробка", "шт"},
	[70] = {"кирка", "шт"},
	[71] = {"руда", "кг"},
	[72] = {"лицензия дальнобойщика на имя", ""},
	[73] = {"бочка с нефтью", "$ за штуку"},
	[74] = {"лицензия водителя мусоровоза на имя", ""},
	[75] = {"мусор", "кг"},
	[76] = {"антипохмелин", "шт"},
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
	--[40] = {info_png[40][1], 15, 150, 1},
	[41] = {info_png[41][1], 34, 6000, 25},
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
	[40] = {info_png[40][1], 10, 500},
	[42] = {info_png[42][1], 1, 10000},
	[46] = {info_png[46][1], 1, 100},
	[52] = {info_png[52][1], 1, 1000},
	[53] = {info_png[53][1], 1, 100},
	[54] = {info_png[54][1], 1, 50},
	[55] = {info_png[55][1], 100, 50},
	[56] = {info_png[56][1], 100, 100},
	[57] = {info_png[57][1], 1, 100},
	[58] = {info_png[58][1], 1, 100},
	[63] = {info_png[63][1], 1, 100},
	[76] = {info_png[76][1], 1, 250},
}

local gas = {
	[5] = {info_png[5][1].." 20 "..info_png[5][2], 20, 250},
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
	[408] = {"TRASH", 50000},--мусоровоз
	[409] = {"STRETCH", 40000},--лимузин
	[410] = {"MANANA", 9000},
	[411] = {"INFERNUS", 95000},
	[412] = {"VOODOO", 30000},
	[413] = {"PONY", 20000},--грузовик с колонками
	--[414] = {"MULE", 22000},--грузовик развозчика
	[415] = {"CHEETAH", 105000},
	--[416] = {"AMBULAN", 10000},--скорая
	[418] = {"MOONBEAM", 16000},
	[419] = {"ESPERANT", 19000},
	[420] = {"TAXI", 20000},
	[421] = {"WASHING", 18000},
	[422] = {"BOBCAT", 26000},
	--[423] = {"MRWHOOP", 29000},--грузовик мороженого
	[424] = {"BFINJECT", 15000},
	[426] = {"PREMIER", 25000},
	[428] = {"SECURICA", 40000},--инкасаторский грузовик
	[429] = {"BANSHEE", 45000},
	--[431] = {"BUS", 15000},
	--[432] = {"RHINO", 110000},--танк
	--[433] = {"BARRACKS", 10000},--военный грузовик
	[434] = {"HOTKNIFE", 35000},
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
	{3, "Лас Вентурас ПД", 289.7703,171.7460,1007.1790, 2287.1005859375,2432.3642578125,10.8203125, 30, 4, ", Меню - X", 5},
	{3, "Мэрия ЛС", 374.6708,173.8050,1008.3893, 1481.0576171875,-1772.3115234375,18.795755386353, 19, 5, ", Меню - X", 5},
	{2, "Завод продуктов", 2570.33,-1302.31,1044.12, -86.208984375,-299.36328125,2.7646157741547, 51, 6, "", 5},
	{3, "Мэрия СФ", 374.6708,173.8050,1008.3893, -2766.55078125,375.60546875,6.3346824645996, 19, 7, ", Меню - X", 5},
	{3, "Мэрия ЛВ", 374.6708,173.8050,1008.3893, 2447.6826171875,2376.3037109375,12.163512229919, 19, 8, ", Меню - X", 5},
	{4, "Гонки на мотоциклах", -1435.8690,-662.2505,1052.4650, 2780.3994140625,-1812.2841796875,11.84375, 33, 9, "", 5},
	{7, "Гонки на автомобилях", -1417.8720,-276.4260,1051.1910, 2695.05078125,-1707.8583984375,11.84375, 33, 10, "", 5},
	{15, "Дерби арена", -1394.20,987.62,1023.96, 2794.310546875,-1723.8642578125,11.84375, 33, 11, "", 5},
	{16, "Последний выживший", -1400,1250,1040, 2685.4638671875,-1802.6201171875,11.84375, 33, 12, "", 5},
	{10, "Казино 4 Дракона", 2009.4140,1017.8990,994.4680, 2019.3134765625,1007.6728515625,10.8203125, 43, 13, "", 5},
	{1, "Казино Калигула", 2235.2524,1708.5146,1010.6129, 2196.9619140625,1677.1708984375,12.3671875, 44, 14, ", Разгрузить товар - E", 5},
	{5, "Эль Кебрадос ПД", 322.72,306.43,999.15, -1389.66015625,2644.005859375,55.984375, 30, 15, ", Меню - X", 5},
	{5, "Форт Карсон ПД", 322.72,306.43,999.15, -217.837890625,979.171875,19.504064559937, 30, 16, ", Меню - X", 5},
	{5, "Диллимор ПД", 322.72,306.43,999.15, 626.9697265625,-571.796875,17.920680999756, 30, 17, ", Меню - X", 5},
	{5, "Эйнджел Пайн ПД", 322.72,306.43,999.15, -2161.2099609375,-2384.9052734375,30.893091201782, 30, 18, ", Меню - X", 5},
}

local t_s_salon = {
	{2131.9775390625,-1151.322265625,24.062105178833, 55},--авто
	{-2236.951171875,2354.212890625,4.9799103736877, 5},--верт
	{-2187.46875,2416.5576171875,5.1651339530945, 9},--лодки
}

--места поднятия предметов
local up_car_subject = {--{x,y,z, радиус 4, ид пнг 5, ид тс 6, зп 7}
	{89.9423828125,-304.623046875,1.578125, 15, 24, 456, 1},--склад продуктов
	{2308.81640625,-13.25,26.7421875, 15, 65, 428, 1},--банк
	{260.4326171875,1409.2626953125,10.506074905396, 15, 73, 456, 1},--нефтезавод
}

local up_player_subject = {--{x,y,z, радиус 4, ид пнг 5, зп 6, интерьер 7, мир 8, скин 9}
	{955.9677734375,2143.6513671875,1011.0258789063, 5, 48, 1, 1, 1, 0},--мясокомбинат
	
	{2559.1171875,-1287.2275390625,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2551.1318359375,-1287.2294921875,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2543.0859375,-1287.2216796875,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2543.166015625,-1300.0927734375,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2551.09375,-1300.09375,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов
	{2559.0185546875,-1300.0927734375,1044.125, 2, 69, 1, 2, 6, 16},--завод продуктов

	{-491.4609375,-194.43359375,78.394332885742, 5, 67, 1, 0, 0, 27},--лесоповал

	{576.8212890625,846.5732421875,-42.264389038086, 5, 70, 1, 0, 0, 260},--рудник лв
}

--места сброса предметов
local down_car_subject = {--{x,y,z, радиус 4, ид пнг 5, ид тс 6}
	{2787.8974609375,-2455.974609375,13.633636474609, 15, 24, 456},--порт лс
	{2196.9619140625,1677.1708984375,12.3671875, 15, 65, 428},--калигула
	{-1990.5732421875,-2384.921875,30.625, 15, 68, 455},--лесопилка
	{2787.8974609375,-2455.974609375,13.633636474609, 15, 73, 456},--порт лс
	{-1813.2890625,-1654.3330078125,22.398532867432, 15, 75, 408},--свалка
}

local down_player_subject = {--{x,y,z, радиус 4, ид пнг 5, интерьер 6, мир 7}
	{942.4775390625,2117.900390625,1011.0302734375, 5, 48, 1, 1},--мясокомбинат
	{2564.779296875,-1293.0673828125,1044.125, 2, 62, 2, 6},--завод продуктов
	{681.7744140625,823.8447265625,-26.840600967407, 5, 71, 0, 0},--рудник лв
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
	{630.7001953125,865.71032714844,-42.660102844238, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{619.72265625,873.4443359375,-42.9609375, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{607.9052734375,864.9892578125,-42.809223175049, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{610.1083984375,845.86267089844,-42.524024963379, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{627.5458984375,844.70349121094,-42.33695602417, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{579.53356933594,874.83459472656,-43.100883483887, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{574.99548339844,889.15100097656,-42.958339691162, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{559.23962402344,892.81115722656,-42.695762634277, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{552.41442871094,878.68420410156,-42.364948272705, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
	{563.02087402344,863.94885253906,-42.350147247314, 1, 70, 71, 1, "baseball", "bat_4", 0, 0, 5},
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
local robbery_player = {}--ограбление, 0-нет, 1-да
local gps_device = {}--отображение координат игрока, 0-выкл, 1-вкл
local timer_robbery = {}--таймер ограбления
local job = {}--работа, 0-нет, 1-таксист, 2-вод мусоровоза
local job_call = {}--(таксист - есть ли вызов, 0-нет, 1-да, 2-сдаем вызов)
local job_ped = {}--создан ли нпс, 0-нет
local job_blip = {}--создан ли блип, 0-нет
local job_marker = {}--создан ли маркер, 0-нет
local job_pos = {}--позиция места назначения
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

-------------------пользовательские функции 2----------------------------------------------
function debuginfo ()
	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)

		--элементдата
		setElementData(playerid, "0", "max_earth "..max_earth)
		setElementData(playerid, "1", "state_inv_player[playername] "..state_inv_player[playername])
		setElementData(playerid, "2", "state_gui_window[playername] "..state_gui_window[playername])
		setElementData(playerid, "3", "logged[playername] "..logged[playername])
		setElementData(playerid, "4", "enter_house[playername] "..enter_house[playername])
		setElementData(playerid, "5", "enter_business[playername] "..enter_business[playername])
		setElementData(playerid, "6", "enter_job[playername] "..enter_job[playername])
		setElementData(playerid, "7", "speed_car_device[playername] "..speed_car_device[playername])
		setElementData(playerid, "8", "arrest[playername] "..arrest[playername])
		setElementData(playerid, "9", "crimes[playername] "..crimes[playername])
		setElementData(playerid, "10", "robbery_player[playername] "..robbery_player[playername])
		setElementData(playerid, "11", "gps_device[playername] "..gps_device[playername])
		setElementData(playerid, "12", "timer_robbery[playername] "..tostring(timer_robbery[playername]))
		setElementData(playerid, "13", "job[playername] "..job[playername])
		setElementData(playerid, "14", "job_call[playername] "..job_call[playername])
		setElementData(playerid, "15", "job_ped[playername] "..tostring(job_ped[playername]))
		setElementData(playerid, "16", "job_blip[playername] "..tostring(job_blip[playername]))

		if job_pos[playername] ~= 0 then
			setElementData(playerid, "17", "job_pos[playername] "..tostring(job_pos[playername][1])..", "..tostring(job_pos[playername][2])..", "..tostring(job_pos[playername][3]))
		else
			setElementData(playerid, "17", "job_pos[playername] "..job_pos[playername])
		end

		setElementData(playerid, "18", "job_marker[playername] "..tostring(job_marker[playername]))

		setElementData(playerid, "crimes_data", crimes[playername])
		setElementData(playerid, "alcohol_data", alcohol[playername])
		setElementData(playerid, "satiety_data", satiety[playername])
		setElementData(playerid, "hygiene_data", hygiene[playername])
		setElementData(playerid, "sleep_data", sleep[playername])
		setElementData(playerid, "drugs_data", drugs[playername])
		setElementData(playerid, "tomorrow_weather_data", tomorrow_weather)

		local vehicleid = getPlayerVehicle(playerid)
		if (vehicleid) then
			local plate = getVehiclePlateText(vehicleid)
			setElementData ( playerid, "fuel_data", fuel[plate] )
		end
	end
end

function job_timer ()
	--места для таксистов
	local taxi_pos = {
		{2308.81640625,-13.25,26.7421875},--банк
	}

	--загрузка позиций для работы таксист
	local count = #taxi_pos
	for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
		count = count+1
		taxi_pos[count] = {v["x"],v["y"],v["z"]}
	end

	for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
		count = count+1
		taxi_pos[count] = {v["x"],v["y"],v["z"]}
	end

	for k,v in pairs(interior_job) do
		count = count+1
		taxi_pos[count] = {v[6],v[7],v[8]}
	end

	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName(playerid)
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		math.randomseed(getTickCount())

		if logged[playername] == 1 then
			if job[playername] == 1 then--работа таксиста
				if vehicleid then
					if getElementModel(vehicleid) == 420 then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then--нету вызова
								local randomize = math.random(1,#taxi_pos)

								sendPlayerMessage(playerid, "Езжайте на вызов", yellow[1], yellow[2], yellow[3])

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1, 0, 4, yellow[1], yellow[2], yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1, "checkpoint", 40.0, yellow[1], yellow[2], yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then--есть вызов
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = math.random(1,#taxi_pos)
									local randomize_skin = 1

									for k,v in pairs(getValidPedModels()) do
										local random = math.random(2,312)
										if v == random then
											randomize_skin = random
											break
										end
									end

									sendPlayerMessage(playerid, "Отвезите клиента", yellow[1], yellow[2], yellow[3])

									job_call[playername] = 2
									job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
									job_ped[playername] = createPed ( randomize_skin, taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1, 0.0, true )

									setElementPosition(job_blip[playername], taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1)
									setElementPosition(job_marker[playername], taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1)
								
									if not getVehicleOccupant ( vehicleid, 1 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 1 )
									elseif not getVehicleOccupant ( vehicleid, 2 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 2 )
									elseif not getVehicleOccupant ( vehicleid, 3 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 3 )
									end
								end

							elseif job_call[playername] == 2 then--сдаем вызов
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = math.random(1,zp_player_taxi)

									inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

									sendPlayerMessage(playerid, "Вы получили "..randomize.."$", green[1], green[2], green[3])

									save_player_action(playerid, "[taxi_job_timer] "..playername.." [+"..randomize.."$, "..array_player_2[playername][1].."$]")

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
					if getElementModel(vehicleid) == 408 then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then--старт работы
								local randomize = math.random(1,#taxi_pos)

								sendPlayerMessage(playerid, "Езжайте на место погрузки", yellow[1], yellow[2], yellow[3])

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1, 0, 4, yellow[1], yellow[2], yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1, "checkpoint", 40.0, yellow[1], yellow[2], yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = math.random(1,#taxi_pos)
									local randomize_zp = math.random(1,zp_car_75)

									give_subject( playerid, "car", 75, randomize_zp )

									job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1)
									setElementPosition(job_marker[playername], taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1)
								end
							end

						end
					end
				end

			elseif job[playername] == 0 then--нету вызова
				job_0( playername )
			end
		end
	end
end

function job_0( playername )
	if job_ped[playername] ~= 0 then
		destroyElement(job_ped[playername])
	end

	if job_blip[playername] ~= 0 then
		destroyElement(job_blip[playername])
	end

	if job_marker[playername] ~= 0 then
		destroyElement(job_marker[playername])
	end

	job[playername] = 0
	job_ped[playername] = 0
	job_blip[playername] = 0
	job_marker[playername] = 0
	job_pos[playername] = 0
	job_call[playername] = 0
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

				setPedAnimation(playerid, "food", "eat_vomit_p", -1, false, false, false, false)
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
		local plate = getVehiclePlateText(vehicle)
		local engine = getVehicleEngineState ( vehicle )
		local fuel_down_number = 0.0002

		if engine then
			if fuel[plate] <= 0 then
				setVehicleEngineState ( vehicle, false )
			else
				if getSpeed(vehicle) == 0 then
					fuel[plate] = fuel[plate] - fuel_down_number
				else
					fuel[plate] = fuel[plate] - (fuel_down_number*getSpeed(vehicle))
				end
			end
		end
	end
end

function timer_earth()--передача слотов земли на клиент
	for k,playerid in pairs(getElementsByType("player")) do
		local playername = getPlayerName ( playerid )
		local x,y,z = getElementPosition(playerid)

		for i,v in pairs(earth) do
			if isPointInCircle3D(x,y,z, v[1], v[2], v[3], 20) then
				triggerClientEvent( playerid, "event_earth_load", playerid, "", i, v[1], v[2], v[3], v[4], v[5] )
			end
		end
	end
end

function timer_earth_clear()--очистка земли

	print("[timer_earth_clear] max_earth "..max_earth)

	earth = {}
	max_earth = 0

	for k,playerid in pairs(getElementsByType("player")) do
		sendPlayerMessage(playerid, "[НОВОСТИ] Улицы очищенны от мусора", green[1], green[2], green[3])
		triggerClientEvent( playerid, "event_earth_load", playerid, "nil", 0, 0, 0, 0, 0, 0 )
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

addEventHandler("onPlayerCommand",getRootElement(),
function(command)
	local playerid = source
	local playername = getPlayerName(playerid)

	if command == "msg" then
		cancelEvent()
	end
end)

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
			inv_server_load( playerid, "player", i, id1, id2, playername )

			return true
		end
	end

	return false
end

function inv_player_delet(playerid, id1, id2)--удаления предмета игрока
	local playername = getPlayerName ( playerid )

	for i=0,max_inv do
		if array_player_1[playername][i+1] == id1 and array_player_2[playername][i+1] == id2 then
			inv_server_load( playerid, "player", i, 0, 0, playername )

			return true
		end
	end

	return false
end

function robbery(playerid, zakon, money, x1,y1,z1, radius, text)
	math.randomseed(getTickCount())

	if isElement ( playerid ) then
		local x,y,z = getElementPosition(playerid)
		local playername = getPlayerName ( playerid )
		local crimes_plus = zakon
		local cash = math.random(1,money)

		if isPointInCircle3D(x1,y1,z1, x,y,z, radius) then
			crimes[playername] = crimes[playername]+crimes_plus
			sendPlayerMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername]+1, yellow[1], yellow[2], yellow[3])

			sendPlayerMessage(playerid, "Вы унесли "..cash.."$", green[1], green[2], green[3] )

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+cash, playername )

			save_player_action(playerid, "[robbery] "..playername.." ["..text.."], [+"..cash.."$, "..array_player_2[playername][1].."$]")
		else
			sendPlayerMessage(playerid, "[ERROR] Вы покинули место ограбления", red[1], red[2], red[3] )
		end

		robbery_player[playername] = 0
		timer_robbery[playername] = 0
	end
end

function select_sqlite(id1, id2)--выводит имя владельца любого предмета
	for i=0,max_inv do
		local result = sqlite( "SELECT COUNT() FROM account WHERE slot_"..i.."_1 = '"..id1.."' AND slot_"..i.."_2 = '"..id2.."'" )
		if result[1]["COUNT()"] == 1 then
			local result = sqlite( "SELECT * FROM account WHERE slot_"..i.."_1 = '"..id1.."' AND slot_"..i.."_2 = '"..id2.."'" )
			return {result[1]["name"], i}
		end
	end

	return {false, 0}
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

function search_inv_car_2_parameter(vehicleid, id1)--вывод 2 параметра предмета в авто
	local plate = getVehiclePlateText ( vehicleid )

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 then
			return array_car_2[plate][i+1]
		end
	end
end

function inv_car_empty(playerid, id1, id2)--выдача предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local plate = getVehiclePlateText ( vehicleid )

	for i=0,max_inv do
		if array_car_1[plate][i+1] == 0 then
			inv_server_load( playerid, "car", i, id1, id2, plate )

			return true
		end
	end

	return false
end

function inv_car_delet(playerid, id1, id2)--удаления предмета в авто
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	local plate = getVehiclePlateText ( vehicleid )

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
			inv_server_load( playerid, "car", i, 0, 0, plate )

			return true
		end
	end

	return false
end

function inv_car_throw_earth(vehicleid, id1, id2)--выброс предмета из авто на землю
	local plate = getVehiclePlateText ( vehicleid )
	local x,y,z = getElementPosition(vehicleid)

	for i=0,max_inv do
		if array_car_1[plate][i+1] == id1 and array_car_2[plate][i+1] == id2 then
			inv_server_load( playerid, "car", i, 0, 0, plate )

			max_earth = max_earth+1
			local j = max_earth
			earth[j] = {x,y,z,id1,id2}
		end
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
		for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
			if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
				sendPlayerMessage(playerid, " ", yellow[1], yellow[2], yellow[3])

				local s_sql = select_sqlite(43, v["number"])
				if s_sql[1] then
					sendPlayerMessage(playerid, "Владелец бизнеса "..s_sql[1], yellow[1], yellow[2], yellow[3])
				else
					sendPlayerMessage(playerid, "Владелец бизнеса нету", yellow[1], yellow[2], yellow[3])
				end

				sendPlayerMessage(playerid, "Тип "..v["type"], yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(playerid, "Товаров на складе "..v["warehouse"].." шт", yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(playerid, "Стоимость товара (надбавка в N раз) "..v["price"].."$", green[1], green[2], green[3])
				sendPlayerMessage(playerid, "Цена закупки товара "..v["buyprod"].."$", green[1], green[2], green[3])

				if search_inv_player(playerid, 43, v["number"]) ~= 0 then
					sendPlayerMessage(playerid, "Состояние кассы "..v["money"].."$", green[1], green[2], green[3])
					sendPlayerMessage(playerid, "Налог бизнеса оплачен на "..v["nalog"].." дней", yellow[1], yellow[2], yellow[3])
				end
				return
			end
		end

	elseif getElementModel(pickup) == house_icon then
		for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
				sendPlayerMessage(playerid, " ", yellow[1], yellow[2], yellow[3])

				local s_sql = select_sqlite(25, v["number"])
				if s_sql[1] then
					sendPlayerMessage(playerid, "Владелец дома "..s_sql[1], yellow[1], yellow[2], yellow[3])
				else
					sendPlayerMessage(playerid, "Владелец дома нету", yellow[1], yellow[2], yellow[3])
				end

				if search_inv_player(playerid, 25, v["number"]) ~= 0 then
					sendPlayerMessage(playerid, "Налог дома оплачен на "..v["nalog"].." дней", yellow[1], yellow[2], yellow[3])
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
	for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, v["number"], v["x"], v["y"], v["z"], "house", house_bussiness_radius )
	end

	for h,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, v["number"], v["x"], v["y"], v["z"], "biz", house_bussiness_radius )
	end

	for h,v in pairs(interior_job) do 
		triggerClientEvent( playerid, "event_bussines_house_fun", playerid, h, v[6], v[7], v[8], "job", house_bussiness_radius, v[11], v[12] )
	end
end

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

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-result[1]["money"], playername )

					for i,playerid in pairs(getElementsByType("player")) do
						local playername_sell = getPlayerName(playerid)
						if playername_sell == result[1]["name_sell"] then
							inv_server_load( playerid, "player", 0, 1, array_player_2[playername_sell][1]+result[1]["money"], playername_sell )
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

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[addVehicleUpgrade_fun] [plate - "..plate..", upgrades - "..value.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE number = '"..plate.."'")
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

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[removeVehicleUpgrade_fun] [plate - "..plate..", upgrades - "..value.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET tune = '"..text.."' WHERE number = '"..plate.."'")
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

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[setVehiclePaintjob_fun] [plate - "..plate..", paintjob - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET paintjob = '"..text.."' WHERE number = '"..plate.."'")
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

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[setVehicleColor_fun] [plate - "..plate..", color - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET car_rgb = '"..text.."' WHERE number = '"..plate.."'")
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

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				save_player_action(playerid, "[setVehicleHeadLightColor_fun] [plate - "..plate..", color - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))

				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET headlight_rgb = '"..text.."' WHERE number = '"..plate.."'")
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

	if value == "pd" then
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

				save_player_action(playerid, "[cops_weapon_fun] "..playername.." [weapon - "..text.."]")
			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
			end
			return
		end

		for k,v in pairs(weapon_cops) do
			if v[1] == text then
				if inv_player_empty(playerid, k, v[4]) then
					sendPlayerMessage(playerid, "Вы получили "..text, orange[1], orange[2], orange[3])

					save_player_action(playerid, "[cops_weapon_fun] "..playername.." [weapon - "..text.."]")
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end
			end
		end

		return

	elseif value == "mer" then
		local day_nalog = 7

		local mayoralty_shop = {
			[2] = {"права", 0, 1000},
			[50] = {"лицензия на оружие", 0, 10000},
			[64] = {"лицензия таксиста", 0, 5000},
			[66] = {"лицензия инкасатора", 0, 10000},
			[72] = {"лицензия дальнобойщика", 0, 15000},
			[74] = {"лицензия водителя мусоровоза", 0, 20000},
		}

		local mayoralty_nalog = {
			[59] = {"квитанция для оплаты дома на "..day_nalog.." дней", day_nalog, (zakon_nalog_house*day_nalog)},
			[60] = {"квитанция для оплаты бизнеса на "..day_nalog.." дней", day_nalog, (zakon_nalog_business*day_nalog)},
			[61] = {"квитанция для оплаты т/с на "..day_nalog.." дней", day_nalog, (zakon_nalog_car*day_nalog)},
		}

		for k,v in pairs(mayoralty_shop) do
			if v[1] == text then
				if v[3] <= array_player_2[playername][1] then
					if inv_player_empty(playerid, k, playername) then
						sendPlayerMessage(playerid, "Вы купили "..text.." за "..v[3].."$", orange[1], orange[2], orange[3])

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(v[3]), playername )

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

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(v[3]), playername )

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
		
		return
	end

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

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )

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

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

					save_player_action(playerid, "[buy_subject_fun] [skin - "..text.."], "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
				else
					sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				end

			elseif value == 3 then
				for k,v in pairs(shop) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[2]) then
								sendPlayerMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange[1], orange[2], orange[3])

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )

								save_player_action(playerid, "[buy_subject_fun] [24/7 - "..text.."], "..playername.." [-"..cash*v[3].."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
							else
								sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
							end
						else
							sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
						end
					end
				end

			elseif value == 4 then
				for k,v in pairs(gas) do
					if v[1] == text then
						if cash*v[3] <= array_player_2[playername][1] then
							if inv_player_empty(playerid, k, v[2]) then
								sendPlayerMessage(playerid, "Вы купили "..text.." за "..cash*v[3].."$", orange[1], orange[2], orange[3])

								sqlite( "UPDATE business_db SET warehouse = warehouse - '"..prod.."', money = money + '"..cash*v[3].."' WHERE number = '"..number.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*v[3]), playername )

								save_player_action(playerid, "[buy_subject_fun] [gas - "..text.."], "..playername.." [-"..cash*v[3].."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
							else
								sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
							end
						else
							sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
						end
					end
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


--------------------------эвент по кассе для бизнесов-------------------------------------------------------
function till_fun( playerid, number, money, value )
	local playername = getPlayerName(playerid)

	if value == "withdraw" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		if money <= result[1]["money"] then
			sqlite( "UPDATE business_db SET money = money - '"..money.."' WHERE number = '"..number.."'")

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

			sendPlayerMessage(playerid, "Вы забрали из кассы "..money.."$", green[1], green[2], green[3])

			save_player_action(playerid, "[till_fun_withdraw] "..playername.." [+"..money.."$, "..array_player_2[playername][1].."$], "..info_bisiness(number))
		else
			sendPlayerMessage(playerid, "[ERROR] В кассе недостаточно средств", red[1], red[2], red[3])
		end

	elseif value == "deposit" then
		local result = sqlite( "SELECT * FROM business_db WHERE number = '"..number.."'" )
		if money <= array_player_2[playername][1] then
			sqlite( "UPDATE business_db SET money = money + '"..money.."' WHERE number = '"..number.."'")

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-money, playername )

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


----------------------------------крафт предметов -----------------------------------------------------------
function craft_fun( playerid, text )--мэрия
	local playername = getPlayerName(playerid)

	local craft_table = {--[предмет 1, рецепт 2, предметы для крафта 3, кол-во предметов для крафта 4, предмет который скрафтится 5]
		{info_png[20][1], info_png[3][1].."(1 шт) + "..info_png[4][1].."(1 шт)", "3,4", "1,1", "20,1"},
	}

	if enter_house[playername] == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не в доме", red[1], red[2], red[3] )
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
						if search_inv_player(playerid, tonumber(split_sub[i]), search_inv_player_2_parameter(playerid, tonumber(split_sub[i]) )) >= tonumber(split_res[i]) then
							count = count + 1
						end
					end
					
					if count == len then
						if inv_player_empty(playerid, tonumber(split_sub_create[1]), tonumber(split_sub_create[2])) then

							for i=1,len do
								if inv_player_delet(playerid, tonumber(split_sub[i]), search_inv_player_2_parameter(playerid, tonumber(split_sub[i]) )) then
								end
							end

							sendPlayerMessage(playerid, "Вы создали "..v[1].." "..tonumber(split_sub_create[2]).." шт", orange[1], orange[2], orange[3])

							save_player_action(playerid, "[craft_fun] "..playername.." craft ["..v[1].."]")
						else
							sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
						end
					else
						sendPlayerMessage(playerid, "[ERROR] Недостаточно ресурсов", red[1], red[2], red[3])
					end
				end
			end

			return
		end
	end

	sendPlayerMessage(playerid, "[ERROR] У вас нет ключей от дома", red[1], red[2], red[3])
end
addEvent( "event_craft_fun", true )
addEventHandler ( "event_craft_fun", getRootElement(), craft_fun )
-------------------------------------------------------------------------------------------------------------

function displayLoadedRes ( res )--старт ресурсов
	if car_spawn_value == 0 then
		car_spawn_value = 1

		setTime(0,0)

		setTimer(debuginfo, 1000, 0)--дебагинфа
		setTimer(freez_car, 1000, 0)--заморозка авто
		setTimer(need, 60000, 0)--уменьшение потребностей
		setTimer(need_1, 1000, 0)--смена скина на бомжа
		setTimer(timer_earth, 500, 0)--передача слотов земли на клиент
		setTimer(timer_earth_clear, (24*60000), 0)--очистка земли от предметов
		setTimer(fuel_down, 1000, 0)--система топлива
		setTimer(set_weather, 60000, 0)--погода сервера
		setTimer(prison, 60000, 0)--таймер заключения в тюрьме
		setTimer(prison_timer, 1000, 0)--античит если не в тюрьме
		setTimer(pay_nalog, (60*60000), 0)--списание налогов
		setTimer(job_timer, 1000, 0)--работы в цикле

		setWeather(tomorrow_weather)
		setGlitchEnabled ( "quickreload", true )


		zakon_alcohol = 1
		zakon_alcohol_crimes = 1
		zakon_drugs = 1
		zakon_drugs_crimes = 1
		zakon_kill_crimes = 1
		zakon_robbery_crimes = 1
		zakon_65_crimes = 1

		zakon_nalog_car = 500
		zakon_nalog_house = 1000
		zakon_nalog_business = 2000

		up_car_subject[1][7] = 50
		up_player_subject[1][6] = 20
		zp_player_taxi = 250
		up_car_subject[2][7] = 100
		up_car_subject[3][7] = 150
		zp_car_75 = 200

		for k=1,10 do
			anim_player_subject[k][7] = 40
		end

		for k=11,26 do
			anim_player_subject[k][7] = 60
		end

		for k=27,36 do
			anim_player_subject[k][7] = 80
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


		local carnumber_number = 0
		for k,v in pairs(sqlite( "SELECT * FROM car_db" )) do
			car_spawn(v["number"])
			carnumber_number = carnumber_number+1
		end
		print("[number_car_spawn] "..carnumber_number)


		local house_number = 0
		for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			local h = v["number"]
			createBlip ( v["x"], v["y"], v["z"], 32, 0, 0,0,0,0, 0, max_blip )
			createPickup (  v["x"], v["y"], v["z"], 3, house_icon, 10000 )

			array_house_1[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[h] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

			for i=0,max_inv do
				array_house_1[h][i+1] = v["slot_"..i.."_1"]
				array_house_2[h][i+1] = v["slot_"..i.."_2"]
			end

			house_number = house_number+1
		end
		print("[house_number] "..house_number)


		local business_number = 0
		for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
			local h = v["number"]
			createBlip ( v["x"], v["y"], v["z"], interior_business[v["interior"]][6], 0, 0,0,0,0, 0, max_blip )
			createPickup ( v["x"], v["y"], v["z"], 3, business_icon, 10000 )

			business_number = business_number+1
		end
		print("[business_number] "..business_number)
		print("")


		--создание блипов
		for k,v in pairs(interior_job) do 
			createBlip ( v[6], v[7], v[8], v[9], 0, 0,0,0,0, 0, max_blip )
			createPickup ( v[6], v[7], v[8], 3, job_icon, 10000 )
		end

		createBlip ( 2308.81640625, -13.25, 26.7421875, 51, 0, 0,0,0,0, 0, max_blip )--банк
		createBlip ( 89.9423828125,-304.623046875,1.578125, 51, 0, 0,0,0,0, 0, max_blip )--склад продуктов
		createBlip ( 2788.23046875,-2455.99609375,13.340852737427, 52, 0, 0,0,0,0, 0, max_blip )--порт
		createBlip ( -491.4609375,-194.43359375,78.394332885742, 51, 0, 0,0,0,0, 0, max_blip )--лесоповал
		createBlip ( -1990.513671875,-2384.9560546875,31.061803817749, 52, 0, 0,0,0,0, 0, max_blip )--лесопилка
		createBlip ( 576.8212890625,846.5732421875,-42.264389038086, 51, 0, 0,0,0,0, 0, max_blip )--рудник лв
		createBlip ( 260.4326171875,1409.2626953125,10.506074905396, 51, 0, 0,0,0,0, 0, max_blip )--нефтезавод
		createBlip ( -1813.2890625,-1654.3330078125,22.398532867432, 52, 0, 0,0,0,0, 0, max_blip )--свалка

		for k,v in pairs(t_s_salon) do
			createBlip ( v[1], v[2], v[3], v[4], 0, 0,0,0,0, 0, max_blip )--салоны продажи
		end


		--создание маркеров
		for k,v in pairs(up_car_subject) do 
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1], yellow[2], yellow[3] )
		end

		for k,v in pairs(down_car_subject) do 
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1], yellow[2], yellow[3] )
		end

		for k,v in pairs(up_player_subject) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1], yellow[2], yellow[3] )
			setElementInterior(marker, v[7])
			setElementDimension(marker, v[8])
		end

		for k,v in pairs(down_player_subject) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1], yellow[2], yellow[3] )
			setElementInterior(marker, v[6])
			setElementDimension(marker, v[7])
		end

		for k,v in pairs(anim_player_subject) do
			local marker = createMarker ( v[1], v[2], v[3]-1, "cylinder", 1.0, yellow[1], yellow[2], yellow[3] )
			setElementInterior(marker, v[10])
			setElementDimension(marker, v[11])
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
	robbery_player[playername] = 0
	gps_device[playername] = 0
	timer_robbery[playername] = 0
	job[playername] = 0
	job_call[playername] = 0
	job_ped[playername] = 0
	job_blip[playername] = 0
	job_marker[playername] = 0
	job_pos[playername] = 0
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
	bindKey(playerid, "lalt", "down", left_alt_down )
	bindKey(playerid, "h", "down", h_down )

	fadeCamera(playerid, true)
	setCameraTarget(playerid, playerid)
	setPlayerNametagColor ( playerid, white[1], white[2], white[3] )
	setPlayerHudComponentVisible ( playerid, "money", false )
	setPlayerHudComponentVisible ( playerid, "health", false )

	--элементдата2
	setElementData(playerid, "zakon_nalog_car_data", zakon_nalog_car)
	setElementData(playerid, "zakon_nalog_house_data", zakon_nalog_house)
	setElementData(playerid, "zakon_nalog_business_data", zakon_nalog_business)
	setElementData(playerid, "speed_car_device_data", 0)
	setElementData(playerid, "gps_device_data", 0)

	for _, stat in pairs({ 22, 24, 225, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79 }) do
		setPedStat(playerid, stat, 1000)
	end

	reg_or_login(playerid)
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
		job_0( playername )

		if robbery_player[playername] == 1 then
			killTimer ( timer_robbery[playername] )
			robbery_player[playername] = 0
			timer_robbery[playername] = 0
		end

		state_inv_player[playername] = 0
		state_gui_window[playername] = 0
		logged[playername] = 0
		enter_house[playername] = 0
		enter_business[playername] = 0
		enter_job[playername] = 0
		speed_car_device[playername] = 0
		arrest[playername] = 0
		crimes[playername] = -1
		robbery_player[playername] = 0
		gps_device[playername] = 0
		timer_robbery[playername] = 0
		job[playername] = 0
		job_call[playername] = 0
		job_ped[playername] = 0
		job_blip[playername] = 0
		job_marker[playername] = 0
		job_pos[playername] = 0
		--нужды
		alcohol[playername] = 0
		satiety[playername] = 0
		hygiene[playername] = 0
		sleep[playername] = 0
		drugs[playername] = 0
	else
		
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), quitPlayer )

function player_Spawn (playerid)--спавн игрока
	if isElement ( playerid ) then
		local playername = getPlayerName ( playerid )

		if logged[playername] == 1 then
			local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

			spawnPlayer(playerid, spawnX, spawnY, spawnZ, 0, result[1]["skin"])

			setElementHealth( playerid, 100 )
		end
	end
end

addEventHandler( "onPlayerWasted", getRootElement(),--смерть игрока
function(ammo, attacker, weapon, bodypart)
	local playerid = source
	local playername = getPlayerName ( playerid )
	local playername_a = nil
	local reason = weapon
	local cash = 100

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
			else
				if crimes[playername] ~= -1 then
					arrest[playername] = 1

					sendPlayerMessage(playerid, "Вы получили премию "..(cash*(crimes[playername]+1)).."$", green[1], green[2], green[3] )

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername_a][1]+(cash*(crimes[playername]+1)), playername_a )

					save_player_action(playerid, "[police_prison_kill] "..playername_a.." prison "..playername.." time "..(crimes[playername]+1))
				end
			end

		elseif getElementType ( attacker ) == "vehicle" then
			for i,player_id in pairs(getElementsByType("player")) do
				local vehicleid = getPlayerVehicle(player_id)

				if attacker == vehicleid then
					playername_a = getPlayerName ( player_id )

					if search_inv_player(player_id, 10, playername_a) == 0 then
						local crimes_plus = zakon_kill_crimes
						crimes[playername_a] = crimes[playername_a]+crimes_plus
						sendPlayerMessage(player_id, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername_a]+1, yellow[1], yellow[2], yellow[3])
					else
						if crimes[playername] ~= -1 then
							arrest[playername] = 1

							sendPlayerMessage(playerid, "Вы получили премию "..(cash*(crimes[playername]+1)).."$", green[1], green[2], green[3] )

							inv_server_load( playerid, "player", 0, 1, array_player_2[playername_a][1]+(cash*(crimes[playername]+1)), playername_a )

							save_player_action(playerid, "[police_prison_kill] "..playername_a.." prison "..playername.." time "..(crimes[playername]+1))
						end
					end

					break
				end
			end
		end
	end

	if robbery_player[playername] == 1 then
		killTimer ( timer_robbery[playername] )
		robbery_player[playername] = 0
		timer_robbery[playername] = 0
	end
	
	setTimer( player_Spawn, 5000, 1, playerid )

	if not playername_a then
		sendPlayerMessage(getRootElement(), "[НОВОСТИ] "..playername.." умер Причина: "..tostring(reason).." Часть тела: "..tostring(getBodyPartName ( bodypart )), green[1], green[2], green[3] )
	else
		sendPlayerMessage(getRootElement(), "[НОВОСТИ] "..playername_a.." убил "..playername.." Причина: "..tostring(reason).." Часть тела: "..tostring(getBodyPartName ( bodypart )), green[1], green[2], green[3] )
	end

	save_player_action(playerid, "[onPlayerWasted] "..playername.." [ammo - "..tostring(ammo)..", attacker - "..tostring(playername_a)..", reason - "..tostring(reason)..", bodypart - "..tostring(getBodyPartName ( bodypart )).."]")
end)

function frozen_false_fun( playerid )
	if isElement ( playerid ) then
		if isElementFrozen(playerid) then
			setElementFrozen( playerid, false )
			sendPlayerMessage(playerid, "Вы можете двигаться", yellow[1], yellow[2], yellow[3])
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
addEventHandler ( "onPlayerDamage", getRootElement(), playerDamage_text )

function nickChangeHandler(oldNick, newNick)
	local playerid = source
	local playername = getPlayerName ( playerid )

	--kickPlayer( playerid, "kick for Change Nick" )
	cancelEvent()
end
addEventHandler("onPlayerChangeNick", getRootElement(), nickChangeHandler)

----------------------------------Регистрация-Авторизация--------------------------------------------
function reg_or_login(playerid)
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP(playerid)

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..playername.."'" )
	if result[1]["COUNT()"] == 0 then

		local result = sqlite( "SELECT COUNT() FROM account WHERE reg_serial = '"..serial.."'" )
		if result[1]["COUNT()"] == 1 then
			kickPlayer(playerid, "Регистрация твинков запрещена")
			return
		end
		
		local result = sqlite( "INSERT INTO account (name, ban, reason, x, y, z, reg_ip, reg_serial, heal, alcohol, satiety, hygiene, sleep, drugs, skin, arrest, crimes, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..playername.."', '0', '0', '"..spawnX.."', '"..spawnY.."', '"..spawnZ.."', '"..ip.."', '"..serial.."', '"..max_heal.."', '0', '100', '100', '100', '0', '26', '0', '-1', '1', '500', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

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

		sendPlayerMessage(playerid, "Вы удачно зарегистрировались!", turquoise[1], turquoise[2], turquoise[3])

		sqlite_save_player_action( "CREATE TABLE "..playername.." (player_action TEXT)" )

		save_player_action(playerid, "[ACCOUNT REGISTER] "..playername.." [ip - "..ip..", serial - "..serial.."]")

		house_bussiness_job_pos_load( playerid )

	elseif result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..playername.."'" )

		if result[1]["reg_serial"] ~= serial then
			kickPlayer(playerid, "Вы не владелец аккаунта")
			return
		end

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

		--[[if arrest[playername] == 1 then--не удалять
			local randomize = math.random(1,#prison_cell)
			spawnPlayer(playerid, prison_cell[randomize][4], prison_cell[randomize][5], prison_cell[randomize][6], 0, result[1]["skin"], prison_cell[randomize][1], prison_cell[randomize][2])
		else]]
			spawnPlayer(playerid, result[1]["x"], result[1]["y"], result[1]["z"], 0, result[1]["skin"], 0, 0)
		--end

		setElementHealth( playerid, result[1]["heal"] )

		sendPlayerMessage(playerid, "Вы удачно зашли!", turquoise[1], turquoise[2], turquoise[3])

		save_player_action(playerid, "[log_fun] "..playername.." [ip - "..ip..", serial - "..serial.."]")

		house_bussiness_job_pos_load( playerid )
	end
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
			removePedFromVehicle ( playerid )
		end
	end

	if getElementModel(vehicleid) == 428 then
		for i=0,max_inv do
			local sic2p = search_inv_car_2_parameter(vehicleid, 65)
			inv_car_throw_earth(vehicleid, 65, sic2p)
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
	end
end

function detachTrailer(vehicleid)--прицепка прицепа
	local trailer = source
	local plate = getVehiclePlateText ( trailer )

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
	if result[1]["COUNT()"] == 1 then
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
	if result[1]["COUNT()"] == 1 then
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
		local vehicleid = createVehicle(result[1]["model"], result[1]["x"], result[1]["y"], result[1]["z"], 0, 0, result[1]["rot"], plate)

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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ид т/с]", red[1], red[2], red[3])
		return
	end

	if id >= 400 and id <= 611 then
		local result = sqlite( "SELECT COUNT() FROM car_db" )
		local number = result[1]["COUNT()"]+1
		local val1, val2 = 6, number

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

			if inv_player_empty(playerid, val1, val2) then

			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				return
			end

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash_car[id][2], playername )

			sendPlayerMessage(playerid, "Вы купили транспортное средство за "..cash_car[id][2].."$", orange[1], orange[2], orange[3])

			x,y,z,rot = 2120.8515625,-1136.013671875,25.287223815918,0

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

			if inv_player_empty(playerid, val1, val2) then

			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				return
			end

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash_helicopters[id][2], playername )

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

			if inv_player_empty(playerid, val1, val2) then

			else
				sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
				return
			end

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash_boats[id][2], playername )

			sendPlayerMessage(playerid, "Вы купили транспортное средство за "..cash_boats[id][2].."$", orange[1], orange[2], orange[3])

			x,y,z,rot = -2244.6,2408.7,1.8,315
		else
			sendPlayerMessage(playerid, "[ERROR] Найдите место продажи т/с", red[1], red[2], red[3])
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

		sendPlayerMessage(playerid, "Вы получили "..info_png[val1][1].." "..val2, orange[1], orange[2], orange[3])

		sqlite( "INSERT INTO car_db (number, model, nalog, frozen, evacuate, x, y, z, rot, fuel, car_rgb, headlight_rgb, paintjob, tune, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..val2.."', '"..id.."', '"..nalog_start.."', '0',' 0', '"..x.."', '"..y.."', '"..z.."', '"..rot.."', '"..max_fuel.."', '"..car_rgb_text.."', '"..headlight_rgb_text.."', '"..paintjob_text.."', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

		save_player_action(playerid, "[buy_vehicle] "..playername.." [plate - "..plate.."]")
	else
		sendPlayerMessage(playerid, "[ERROR] от 400 до 611", red[1], red[2], red[3])
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
					sendPlayerMessage(playerid, "[ERROR] Т/с арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
					setVehicleEngineState(vehicleid, false)
					removePedFromVehicle ( playerid )--для мотиков, не удалять
					return
				end
			end

			if fuel[plate] <= 0 then
				sendPlayerMessage(playerid, "[ERROR] Бак пуст", red[1], red[2], red[3])
				setVehicleEngineState(vehicleid, false)
				return
			end

			if search_inv_player(playerid, 6, tonumber(plate)) ~= 0 and search_inv_player(playerid, 2, playername) ~= 0 then
				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
					sendPlayerMessage(playerid, "Налог т/с оплачен на "..result[1]["nalog"].." дней", yellow[1], yellow[2], yellow[3])
				end

				if tonumber(plate) ~= 0 then
					triggerClientEvent( playerid, "event_tab_load", playerid, "car", plate )
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Чтобы завести т/с надо выполнить 2 пункта:", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 1) нужно иметь ключ от т/с", red[1], red[2], red[3])
				sendPlayerMessage(playerid, "[ERROR] 2) иметь права на свое имя", red[1], red[2], red[3])
				setVehicleEngineState(vehicleid, false)
				removePedFromVehicle ( playerid )
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

				sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")
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

				sqlite( "UPDATE car_db SET x = '"..x.."', y = '"..y.."', z = '"..z.."', rot = '"..rz.."', fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")
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

				for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
					if getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_house[v["interior"]][1] and search_inv_player(playerid, 25, v["number"]) ~= 0 and enter_house[playername] == 1 then
						for i=0,max_inv do
							triggerClientEvent( playerid, "event_inv_load", playerid, "house", i, array_house_1[v["number"]][i+1], array_house_2[v["number"]][i+1] )
						end

						triggerClientEvent( playerid, "event_tab_load", playerid, "house", v["number"] )
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
	math.randomseed(getTickCount())

	if value == "player" then
		for k,v in pairs(down_player_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) and id1 == v[5] then--получение прибыли за предметы
				inv_server_load( playerid, value, id3, 0, 0, tabpanel )
				inv_server_load( playerid, value, 0, 1, array_player_2[playername][1]+id2, tabpanel )

				sendPlayerMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])

				save_player_action(playerid, "[throw_earth_job] "..playername.." [+"..id2.."$, "..array_player_2[playername][1].."$] ["..info_png[id1][1]..", "..id2.."]")

				return
			end
		end

		for k,v in pairs(anim_player_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) and id1 == v[5] and not vehicleid then--обработка предметов
				local randomize = math.random(1,v[7])

				inv_server_load( playerid, value, id3, 0, 0, tabpanel )

				inv_server_load( playerid, value, id3, v[6], randomize, tabpanel )

				sendPlayerMessage(playerid, "Вы получили "..info_png[v[6]][1].." "..randomize.." "..info_png[v[6]][2], svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])

				if id1 == 67 then--предмет для работы
					object_attach(playerid, 341, 12, 0,0,0, 0,-90,0, (v[12]*1000))
				elseif id1 == 70 then
					object_attach(playerid, 337, 12, 0,0,0, 0,-90,0, (v[12]*1000))
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
	local j = max_earth
	earth[j] = {x,y,z,id1,id2}

	if search_inv_player(playerid, 25, id2) ~= 0 and id1 == 25 then--когда выбрасываешь ключ в инв-ре исчезают картинки
		triggerClientEvent( playerid, "event_tab_load", playerid, "house", "" )
	end

	if vehicleid then
		local plate = getVehiclePlateText ( vehicleid )

		if getVehicleOccupant ( vehicleid, 0 ) and id2 == tonumber(plate) and id1 == 6 then--когда выбрасываешь ключ в инв-ре исчезают картинки
			triggerClientEvent( playerid, "event_tab_load", playerid, "car", "" )
		end
	end

	inv_server_load( playerid, value, id3, 0, 0, tabpanel )

	sendPlayerMessage(playerid, "Вы выбросили "..info_png[id1][1].." "..id2.." "..info_png[id1][2], yellow[1], yellow[2], yellow[3])

	save_player_action(playerid, "[throw_earth] "..playername.." [value - "..value..", x - "..x..", y - "..y..", z - "..z.."] ["..info_png[ id1 ][1]..", "..id2.."]")
end
addEvent( "event_throw_earth_server", true )
addEventHandler ( "event_throw_earth_server", getRootElement(), throw_earth_server )

function e_down (playerid, key, keyState)--подбор предметов с земли
	local x,y,z = getElementPosition(playerid)
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle(playerid)
	math.randomseed(getTickCount())
	
	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then

		for k,v in pairs(up_car_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then
				if vehicleid then
					if getElementModel(vehicleid) ~= v[6] then
						sendPlayerMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( v[6] ).."("..v[6]..")", red[1], red[2], red[3] )
						return
					end
				end

				give_subject(playerid, "car", v[5], math.random(1,v[7]))
			end
		end

		for k,v in pairs(up_player_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then
				if v[9] ~= 0 then
					if getElementModel(playerid) ~= v[9] then
						sendPlayerMessage(playerid, "[ERROR] Вы должны быть в одежде "..v[9], red[1], red[2], red[3] )
						return
					end
				end

				give_subject(playerid, "player", v[5], math.random(1,v[6]))
			end
		end

		for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
			if isPointInCircle3D(x,y,z, v["x"],v["y"],v["z"], house_bussiness_radius) then
				if vehicleid then
					if getElementModel(vehicleid) ~= down_car_subject[1][6] then
						sendPlayerMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( down_car_subject[1][6] ).."("..down_car_subject[1][6]..")", red[1], red[2], red[3] )
						return
					end
				end

				delet_subject(playerid, 24)
			end
		end

		for k,v in pairs(down_car_subject) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then
				if vehicleid then
					if getElementModel(vehicleid) ~= v[6] then
						sendPlayerMessage(playerid, "[ERROR] Вы должны быть в "..getVehicleNameFromModel ( v[6] ).."("..v[6]..")", red[1], red[2], red[3] )
						return
					end
				end

				delet_subject(playerid, v[5])
			end
		end


		for i,v in pairs(earth) do
			local area = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 20 )

			if area then
				if (v[4] == 48 or v[4] == 24 or v[4] == 62 or v[4] == 67 or v[4] == 68 or v[4] == 69 or v[4] == 70 or v[4] == 71) and search_inv_player(playerid, v[4], search_inv_player_2_parameter(playerid, v[4])) >= 1 then
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
				return

			elseif id1 == 65 then
				if search_inv_player(playerid, 66, playername) == 0 then
					sendPlayerMessage(playerid, "[ERROR] Вы не инкасатор", red[1], red[2], red[3] )
					return
				end
			elseif id1 == 24 then
				if search_inv_player(playerid, 72, playername) == 0 then
					sendPlayerMessage(playerid, "[ERROR] Вы не дальнобойщик", red[1], red[2], red[3] )
					return
				end
			elseif id1 == 75 then
				if search_inv_player(playerid, 74, playername) == 0 then
					sendPlayerMessage(playerid, "[ERROR] Вы не водитель мусоровоза", red[1], red[2], red[3] )
					return
				end
			end

			for i=0,max_inv do
				if inv_car_empty(playerid, id1, id2) then
					count2 = count2 + 1
				end
			end

			if count2 ~= 0 then
				local count = search_inv_car(vehicleid, id1, id2)

				sendPlayerMessage(playerid, "Вы загрузили в т/с "..info_png[id1][1].." "..count.." шт за "..id2.."$", svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3])
				
				if id1 == 24 then
					sendPlayerMessage(playerid, "[TIPS] Езжайте в порт или в любой бизнес, чтобы разгрузиться", color_tips[1], color_tips[2], color_tips[3])
				elseif id1 == 65 then
					sendPlayerMessage(playerid, "[TIPS] Езжайте в казино Калигула, чтобы разгрузиться", color_tips[1], color_tips[2], color_tips[3])
				elseif id1 == 73 then
					sendPlayerMessage(playerid, "[TIPS] Езжайте в порт, чтобы разгрузиться", color_tips[1], color_tips[2], color_tips[3])
				elseif id1 == 75 then
					sendPlayerMessage(playerid, "[TIPS] Езжайте на свалку, чтобы разгрузиться", color_tips[1], color_tips[2], color_tips[3])
				end

				save_player_action(playerid, "[give_subject] "..playername.." [value - "..value..", count - "..count.."] ["..info_png[id1][1]..", "..id2.."]")
			else
				sendPlayerMessage(playerid, "[ERROR] Багажник заполнен", red[1], red[2], red[3] )
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
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
						sendPlayerMessage(playerid, "[ERROR] Нужен только "..info_png[24][1], red[1], red[2], red[3] )
						return
					end

					if v["buyprod"] == 0 then
						sendPlayerMessage(playerid, "[ERROR] Цена покупки не указана", red[1], red[2], red[3] )
						return
					end

					money = count*v["buyprod"]

					if v["money"] < money then
						sendPlayerMessage(playerid, "[ERROR] Недостаточно средств на балансе бизнеса", red[1], red[2], red[3] )
						return
					end

					for i=0,max_inv do
						if inv_car_delet(playerid, id, sic2p) then
						end
					end

					sqlite( "UPDATE business_db SET warehouse = warehouse + '"..count.."', money = money - '"..money.."' WHERE number = '"..v["number"].."'")

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

					sendPlayerMessage(playerid, "Вы разгрузили из т/с "..info_png[id][1].." "..count.." шт ("..v["buyprod"].."$ за 1 шт) за "..money.."$", green[1], green[2], green[3])

					save_player_action(playerid, "[delet_subject_business] "..playername.." [count - "..count.."], [+"..money.."$, "..array_player_2[playername][1].."$], "..info_bisiness(v["number"]))
					return
				end
			end

			for k,v in pairs(down_car_subject) do
				if isPointInCircle3D(x,y,z, v[1],v[2],v[3], v[4]) then--места разгрузки
					for i=0,max_inv do
						if inv_car_delet(playerid, id, sic2p) then
						end
					end

					money = count*sic2p

					inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

					sendPlayerMessage(playerid, "Вы разгрузили из т/с "..info_png[id][1].." "..count.." шт ("..sic2p.."$ за 1 шт) за "..money.."$", green[1], green[2], green[3])

					save_player_action(playerid, "[delet_subject_job] "..playername.." [count - "..count..", price - "..sic2p.."], [+"..money.."$, "..array_player_2[playername][1].."$]")
					return
				end
			end
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
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
							sendPlayerMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
							return
						end

						triggerClientEvent( playerid, "event_shop_menu", playerid, v["number"], 4 )
						state_gui_window[playername] = 1
						return

					elseif isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and v["type"] == interior_business[5][2] then--тюнинг

						if v["nalog"] <= 0 then
							sendPlayerMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
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
							if search_inv_player(playerid, 10, playername) == 0 then
								sendPlayerMessage(playerid, "[ERROR] Вы не полицейский", red[1], red[2], red[3] )
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

	if logged[playername] == 0 then
		return
	end

	if keyState == "down" then

		for id2,v in pairs(sqlite( "SELECT * FROM house_db" )) do--вход в дома
			if not vehicleid then
				local id = v["interior"]
				local house_door = v["door"]

				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					if house_door == 0 then
						sendPlayerMessage(playerid, "[ERROR] Дверь закрыта", red[1], red[2], red[3] )
						return
					end

					if v["nalog"] <= 0 then
						sendPlayerMessage(playerid, "[ERROR] Дом арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
						return
					end

					enter_house[playername] = 1
					setElementDimension(playerid, v["world"])
					setElementInterior(playerid, interior_house[id][1], interior_house[id][3], interior_house[id][4], interior_house[id][5])
					return

				elseif getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_house[id][1] and enter_house[playername] == 1 then
					if house_door == 0 then
						sendPlayerMessage(playerid, "[ERROR] Дверь закрыта", red[1], red[2], red[3] )
						return
					end

					enter_house[playername] = 0
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
						sendPlayerMessage(playerid, "[ERROR] Бизнес арестован за уклонение от уплаты налогов", red[1], red[2], red[3])
						return
					end
					
					triggerClientEvent( playerid, "event_gui_delet", playerid )

					state_gui_window[playername] = 0
					enter_business[playername] = 1
					setElementDimension(playerid, v["world"])
					setElementInterior(playerid, interior_business[id][1], interior_business[id][3], interior_business[id][4], interior_business[id][5])
					return

				elseif getElementDimension(playerid) == v["world"] and getElementInterior(playerid) == interior_business[id][1] and enter_business[playername] == 1 and id ~= 5 then

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
							sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
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
						inv_player_delet(playerid, 6, 0)
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

function inv_server_load (playerid, value, id3, id1, id2, tabpanel)--изменение(сохранение) инв-ря на сервере
	local playername = getPlayerName(playerid)
	local plate = tabpanel
	local h = tabpanel

	if value == "player" then
		array_player_1[playername][id3+1] = id1
		array_player_2[playername][id3+1] = id2

		sqlite( "UPDATE account SET slot_"..id3.."_1 = '"..array_player_1[playername][id3+1].."', slot_"..id3.."_2 = '"..array_player_2[playername][id3+1].."' WHERE name = '"..playername.."'")

		triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, array_player_1[playername][id3+1], array_player_2[playername][id3+1] )

		if state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, array_player_1[playername][id3+1] )
		end

	elseif value == "car" then
		array_car_1[plate][id3+1] = id1
		array_car_2[plate][id3+1] = id2

		local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
		if result[1]["COUNT()"] == 1 then
			sqlite( "UPDATE car_db SET slot_"..id3.."_1 = '"..array_car_1[plate][id3+1].."', slot_"..id3.."_2 = '"..array_car_2[plate][id3+1].."' WHERE number = '"..plate.."'")
		end

		triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, array_car_1[plate][id3+1], array_car_2[plate][id3+1] )

		if state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, array_car_1[plate][id3+1] )
		end
		
	elseif value == "house" then
		array_house_1[h][id3+1] = id1
		array_house_2[h][id3+1] = id2

		sqlite( "UPDATE house_db SET slot_"..id3.."_1 = '"..array_house_1[h][id3+1].."', slot_"..id3.."_2 = '"..array_house_2[h][id3+1].."' WHERE number = '"..h.."'")

		triggerClientEvent( playerid, "event_inv_load", playerid, value, id3, array_house_1[h][id3+1], array_house_2[h][id3+1] )
		
		if state_inv_player[playername] == 1 then
			triggerClientEvent( playerid, "event_change_image", playerid, value, id3, array_house_1[h][id3+1] )
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
	math.randomseed(getTickCount())

	if value == "player" then

		if id1 == 6 then--ключ авто
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..id2.."'" )
			if result[1]["COUNT()"] == 1 then

				for k,vehicle in pairs(getElementsByType("vehicle")) do
					local x1,y1,z1 = getElementPosition(vehicle)
					local plate = getVehiclePlateText ( vehicle )

					if isPointInCircle3D(x,y,z, x1,y1,z1, 10) and tonumber(plate) == id2 then
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

		elseif id1 == 2 or id1 == 44 or id1 == 45 or id1 == 50 or id1 == 66 or id1 == 72 then--права, АЖ, РЛ, лиц на оружие, инка-ая лиц, лиц водилы
			me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			return

		elseif id1 == 1 then--показать бумажник
			me_chat(playerid, playername.." показал(а) свой бумажник в котором находится "..id2.."$")
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

			object_attach(playerid, 1485, 12, -0.1,0,0.04, 0,0,10, 3500)

			if vehicleid then
				setPedAnimation(playerid, "ped", "smoke_in_car", -1, false, false, false, false)
			else
				setPedAnimation(playerid, "smoking", "m_smk_drag", -1, false, false, false, false)
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

			object_attach(playerid, 1484, 11, 0.1,-0.02,0.13, 0,130,0, 2000)
			setPedAnimation(playerid, "vending", "vend_drink2_p", -1, false, false, false, false)

			me_chat(playerid, playername.." выпил(а) пиво")

		elseif id1 == 53 or id1 == 54 then--бургер, пицца
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

				object_attach(playerid, 2703, 12, 0.02,0.05,0.04, 0,130,0, 5000)
				setPedAnimation(playerid, "food", "eat_burger", -1, false, false, false, false)

			elseif id1 == 54 then
				local satiety_plus = 25

				if satiety[playername]+satiety_plus > max_satiety then
					sendPlayerMessage(playerid, "[ERROR] Вы не голодны", red[1], red[2], red[3] )
					return
				end

				satiety[playername] = satiety[playername]+satiety_plus
				sendPlayerMessage(playerid, "+"..satiety_plus.." ед. сытости", yellow[1], yellow[2], yellow[3])
				me_chat(playerid, playername.." съел(а) "..info_png[id1][1])

				object_attach(playerid, 2702, 12, 0,0.1,0.05, 0,270,0, 5000)
				setPedAnimation(playerid, "food", "eat_pizza", -1, false, false, false, false)
			end

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

				setPedAnimation(playerid, "int_house", "wash_up", -1, false, false, false, false)

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

		elseif id1 == 76 then--антипохмелин
			id2 = id2 - 1

			local alcohol_minys = 50

			if alcohol[playername]-alcohol_minys < 0 then
				sendPlayerMessage(playerid, "[ERROR] Вы не пьяны", red[1], red[2], red[3] )
				return
			end

			alcohol[playername] = alcohol[playername]-alcohol_minys
			sendPlayerMessage(playerid, "-"..(alcohol_minys/100).." промилле", yellow[1], yellow[2], yellow[3])
			me_chat(playerid, playername.." выпил(а) "..info_png[id1][1])
-----------------------------------------------------------------------------------------------------------------------

		elseif id1 == 5 then--канистра
			if vehicleid then
				local plate = getVehiclePlateText ( vehicleid )

				if getSpeed(vehicleid) < 5 then
					if fuel[plate]+id2 <= max_fuel then

						fuel[plate] = fuel[plate]+id2
						me_chat(playerid, playername.." заправил(а) машину из канистры")
						id2 = 0

					else
						sendPlayerMessage(playerid, "[ERROR] Максимальная вместимость бака "..max_fuel.." литров", red[1], red[2], red[3])
						return
					end
				else
					sendPlayerMessage(playerid, "[ERROR] Остановите т/с", red[1], red[2], red[3])
					return
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3] )
				return
			end

		elseif id1 == 10 then--документы копа
			if id2 == playername then
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

		elseif id1 == 23 then--ремонтный набор
			if vehicleid then
				if getSpeed(vehicleid) > 5 then
					sendPlayerMessage(playerid, "[ERROR] Остановите т/с", red[1], red[2], red[3])
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

		elseif id1 == 40 then--лом
			local count = 0
			local hour, minute = getTime()
			local x1,y1 = player_position( playerid )

			if hour >= 0 and hour <= 7 then
				for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
					if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and robbery_player[playername] == 0 then
						local time_rob = 1--время для ограбления

						id2 = id2 - 1

						count = count+1

						robbery_player[playername] = 1

						me_chat(playerid, playername.." взломал(а) дверь")

						sendPlayerMessage(playerid, "Вы начали взлом", yellow[1], yellow[2], yellow[3] )
						sendPlayerMessage(playerid, "[TIPS] Не покидайте место ограбления "..time_rob.." мин", color_tips[1], color_tips[2], color_tips[3])

						police_chat(playerid, "[ДИСПЕТЧЕР] Ограбление "..v["number"].." дома, GPS координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

						timer_robbery[playername] = setTimer(robbery, (time_rob*10000), 1, playerid, zakon_robbery_crimes, 500, v[1],v[2],v[3], house_bussiness_radius, "house - "..v["number"])

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

						sendPlayerMessage(playerid, "Вы начали взлом", yellow[1], yellow[2], yellow[3] )
						sendPlayerMessage(playerid, "[TIPS] Не покидайте место ограбления "..time_rob.." мин", color_tips[1], color_tips[2], color_tips[3])

						police_chat(playerid, "[ДИСПЕТЧЕР] Ограбление "..v["number"].." бизнеса, GPS координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

						timer_robbery[playername] = setTimer(robbery, (time_rob*10000), 1, playerid, zakon_robbery_crimes, 1000, v["x"],v["y"],v["z"], house_bussiness_radius, "business - "..v["number"])

						break
					end
				end

				if isPointInCircle3D(2144.18359375,1635.2705078125,993.57611083984, x,y,z, 5) and robbery_player[playername] == 0 then
					local time_rob = 1--время для ограбления

					id2 = id2 - 1

					count = count+1

					robbery_player[playername] = 1

					me_chat(playerid, playername.." взломал(а) сейф")

					sendPlayerMessage(playerid, "Вы начали взлом", yellow[1], yellow[2], yellow[3] )
					sendPlayerMessage(playerid, "[TIPS] Не покидайте место ограбления "..time_rob.." мин", color_tips[1], color_tips[2], color_tips[3])

					police_chat(playerid, "[ДИСПЕТЧЕР] Ограбление Казино Калигула, подозреваемый "..playername)

					timer_robbery[playername] = setTimer(robbery, (time_rob*10000), 1, playerid, zakon_robbery_crimes, 2000, 2144.18359375,1635.2705078125,993.57611083984, 5, "Casino Caligulas")
				end

				if count == 0 then
					sendPlayerMessage(playerid, "[ERROR] Нужно быть около дома, бизнеса или в хранилище казино калигула; Вы уже начали ограбление", red[1], red[2], red[3] )
					return
				end
			else
				sendPlayerMessage(playerid, "[ERROR] Ограбление доступно с 0 до 7 часов игрового времени", red[1], red[2], red[3] )
				return
			end

		elseif id1 == 43 then--документы на бизнес
			local result = sqlite( "SELECT COUNT() FROM business_db WHERE number = '"..id2.."'" )
			if result[1]["COUNT()"] == 1 then
				me_chat(playerid, playername.." показал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])
			end
			return

		elseif id1 == 46 then--радар
			if speed_car_device[playername] == 0 then
				speed_car_device[playername] = 1
				setElementData(playerid, "speed_car_device_data", speed_car_device[playername])

				me_chat(playerid, playername.." включил(а) "..info_png[id1][1])
			else
				speed_car_device[playername] = 0
				setElementData(playerid, "speed_car_device_data", speed_car_device[playername])

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

			triggerClientEvent( playerid, "event_setPedOxygenLevel_fun", playerid )

			me_chat(playerid, playername.." надел(а) "..info_png[id1][1])

		elseif id1 == 57 then--алкостестер
			local alcohol_test = alcohol[playername]/100
			
			me_chat(playerid, playername.." подул(а) в "..info_png[id1][1])
			do_chat(playerid, info_png[id1][1].." показал "..alcohol_test.." промилле")

			if alcohol_test >= zakon_alcohol then
				local crimes_plus = zakon_alcohol_crimes
				crimes[playername] = crimes[playername]+crimes_plus
				sendPlayerMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername]+1, yellow[1], yellow[2], yellow[3])
			end

		elseif id1 == 58 then--наркостестер
			local drugs_test = drugs[playername]
			
			me_chat(playerid, playername.." подул(а) в "..info_png[id1][1])
			do_chat(playerid, info_png[id1][1].." показал "..drugs_test.."% зависимости")

			if drugs_test >= zakon_drugs then
				local crimes_plus = zakon_drugs_crimes
				crimes[playername] = crimes[playername]+crimes_plus
				sendPlayerMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername]+1, yellow[1], yellow[2], yellow[3])
			end

		elseif id1 == 59 then--налог дома
			local count = 0
			for k,v in pairs(sqlite( "SELECT * FROM house_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					sqlite( "UPDATE house_db SET nalog = nalog + '"..id2.."' WHERE number = '"..v["number"].."'")
					
					me_chat(playerid, playername.." использовал(а) "..info_png[id1][1].." "..id2.." "..info_png[id1][2])

					id2 = 0
					count = 1
					break
				end
			end

			if count == 0 then
				sendPlayerMessage(playerid, "[ERROR] Вы должны быть около дома", red[1], red[2], red[3] )
				return
			end

		elseif id1 == 60 then--налог бизнеса
			local count = 0
			for k,v in pairs(sqlite( "SELECT * FROM business_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
					sqlite( "UPDATE business_db SET nalog = nalog + '"..id2.."' WHERE number = '"..v["number"].."'")
					
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
				local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
				if result[1]["COUNT()"] == 1 then
					sqlite( "UPDATE car_db SET nalog = nalog + '"..id2.."' WHERE number = '"..plate.."'")

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

		elseif id1 == 63 then--gps навигатор
			if gps_device[playername] == 0 then
				gps_device[playername] = 1
				setElementData(playerid, "gps_device_data", gps_device[playername])

				me_chat(playerid, playername.." включил(а) "..info_png[id1][1])
			else
				gps_device[playername] = 0
				setElementData(playerid, "gps_device_data", gps_device[playername])

				me_chat(playerid, playername.." выключил(а) "..info_png[id1][1])
			end
			return

		elseif id1 == 64 then--лиц. таксиста
			if id2 == playername then
				if job[playername] == 0 then
					job[playername] = 1

					me_chat(playerid, playername.." вышел(ла) на работу")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			end
			return

		elseif id1 == 65 then--инкасаторский сумка
			local randomize = id2

			id2 = 0

			me_chat(playerid, playername.." открыл(а) "..info_png[id1][1])

			sendPlayerMessage(playerid, "Вы получили "..randomize.."$", green[1], green[2], green[3])

			local crimes_plus = zakon_65_crimes
			crimes[playername] = crimes[playername]+crimes_plus
			sendPlayerMessage(playerid, "+"..crimes_plus.." преступление, всего преступлений "..crimes[playername]+1, yellow[1], yellow[2], yellow[3])

			inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+randomize, playername )

		elseif id1 == 74 then--лиц. вод мусоровоза
			if id2 == playername then
				if job[playername] == 0 then
					job[playername] = 2

					me_chat(playerid, playername.." вышел(ла) на работу")
				else
					job[playername] = 0

					me_chat(playerid, playername.." закончил(а) работу")
				end
			end
			return

		else
			return
		end

		--------------------------------------------------------------------------------------------------------------------------------
		save_player_action(playerid, "[use_inv] "..playername.." [value - "..value.."] ["..info_png[id1][1]..", "..id2.."("..id_2..")]")

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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр] [текст]", red[1], red[2], red[3])
		return
	end

	local player = getPlayerFromName ( id )
	if player then
		local player_name = getPlayerName ( player )

		if id == player_name then
			if logged[id] == 0 then
				sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
				return
			end

			sendPlayerMessage(playerid, "[SMS TO] "..id..": "..text, yellow[1], yellow[2], yellow[3])
			sendPlayerMessage(player, "[SMS FROM] "..playername..": "..text, yellow[1], yellow[2], yellow[3])
		else
			sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
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
			sendPlayerMessage(playerid, "====[ Рулетка ]====", yellow[1], yellow[2], yellow[3])
			sendPlayerMessage(playerid, "Выпало "..randomize.." красное", yellow[1], yellow[2], yellow[3])
			return
		end
	end

	for k,v in pairs(Black) do
		if randomize == v then
			sendPlayerMessage(playerid, "====[ Рулетка ]====", yellow[1], yellow[2], yellow[3])
			sendPlayerMessage(playerid, "Выпало "..randomize.." черное", yellow[1], yellow[2], yellow[3])
			return
		end
	end

	if randomize == 0 then
		sendPlayerMessage(playerid, "====[ Рулетка ]====", yellow[1], yellow[2], yellow[3])
		sendPlayerMessage(playerid, "Выпало ZERO", yellow[1], yellow[2], yellow[3])
		return
	end
end

function win_roulette( playerid, cash, ratio )
	local playername = getPlayerName ( playerid )
	local money = cash*ratio

	sendPlayerMessage(playerid, "Вы заработали "..money.."$ X"..ratio, green[1], green[2], green[3])

	inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+money, playername )

	save_player_action(playerid, "[win_roulette] "..playername.." [+"..money.."$, "..array_player_2[playername][1].."$]")
end

addCommandHandler ( "roulette",--играть в рулетку
function (playerid, cmd, id, cash)
	local playername = getPlayerName ( playerid )
	local x,y,z = getElementPosition(playerid)
	local id = tostring(id)
	local cash = tonumber(cash)
	math.randomseed(getTickCount())
	local randomize = math.random(0,36)
	local roulette_game = {"красное","черное","четное","нечетное","1-18","19-36","1-12","2-12","3-12","3-1","3-2","3-3"}

	if logged[playername] == 0 then
		return
	end

	if not id or not cash then
		local text = ""
		for k,v in pairs(roulette_game) do
			text = text..v..", "
		end

		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [режим игры ("..text..")] [сумма]", red[1], red[2], red[3])
		return
	end

	if cash < 1 then
		return
	end

	if cash > array_player_2[playername][1] then
		sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3])
		return
	end

	if interior_job[14][1] == getElementInterior(playerid) and interior_job[14][10] == getElementDimension(playerid) or interior_job[13][1] == getElementInterior(playerid) and interior_job[13][10] == getElementDimension(playerid) then
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

				save_player_action(playerid, "[los_roulette] "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$]")
				return
			end
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Вы не в казино", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "pr",--пол-ая волна
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [текст]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) ~= 0 then
		if search_inv_player(playerid, 28, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ] Офицер "..playername..": "..text)
		elseif search_inv_player(playerid, 29, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ] Детектив "..playername..": "..text)
		elseif search_inv_player(playerid, 30, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ] Сержант "..playername..": "..text)
		elseif search_inv_player(playerid, 31, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ] Лейтенант "..playername..": "..text)
		elseif search_inv_player(playerid, 32, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ] Капитан "..playername..": "..text)
		elseif search_inv_player(playerid, 33, 1) ~= 0 then
			police_chat(playerid, "[РАЦИЯ] Шеф полиции "..playername..": "..text)
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Вы не полицейский", red[1], red[2], red[3])
	end
end)

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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [номер т/с]", red[1], red[2], red[3])
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
								sendPlayerMessage(playerid, "[ERROR] Т/с на эвакуаторе", red[1], red[2], red[3])
								return
							end

							if search_inv_player(playerid, 6, id) ~= 0 then
								for k,player in pairs(getElementsByType("player")) do
									local vehicle = getPlayerVehicle(player)
									if vehicle == vehicleid then
										removePedFromVehicle ( player )
									end
								end

								setElementPosition(vehicleid, x+5,y,z+1)
								setElementRotation(vehicleid, 0,0,0)

								sqlite( "UPDATE car_db SET x = '"..(x+5).."', y = '"..y.."', z = '"..(z+1).."', fuel = '"..fuel[plate].."' WHERE number = '"..plate.."'")

								inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

								sendPlayerMessage(playerid, "Вы эвакуировали т/с за "..cash.."$", orange[1], orange[2], orange[3])

								save_player_action(playerid, "[evacuationcar] "..playername.." [-"..cash.."$, "..array_player_2[playername][1].."$]")
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
		sendPlayerMessage(playerid, "[ERROR] Нужно иметь "..cash.."$", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр] [сумма]", red[1], red[2], red[3])
		return
	end

	if cash < 1 then
		return
	end

	if cash > array_player_2[playername][1] then
		sendPlayerMessage(playerid, "[ERROR] У вас недостаточно средств", red[1], red[2], red[3] )
		return
	end

	local player = getPlayerFromName ( id )
	if player then
		local player_name = getPlayerName ( player )

		if id == player_name then
			if logged[id] == 0 then
				sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
				return
			end

			local x1,y1,z1 = getElementPosition(player)
			if isPointInCircle3D(x,y,z, x1,y1,z1, 10) then
				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-cash, playername )

				inv_server_load( playerid, "player", 0, 1, array_player_2[id][1]+cash, id )

				me_chat(playerid, playername.." передал(а) "..id.." "..cash.."$")

				save_player_action(playerid, "[pay] "..playername.." give money "..id.." [-"..cash.."$, "..array_player_2[playername][1].."$]")
				save_player_action(player, "[pay] "..playername.." give money "..id.." [+"..cash.."$, "..array_player_2[id][1].."$]")
			else
				sendPlayerMessage(playerid, "[ERROR] Игрок далеко", red[1], red[2], red[3] )
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не полицейский", red[1], red[2], red[3] )
		return
	end

	local player = getPlayerFromName ( id )
	if player then
		local player_name = getPlayerName ( player )

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

				inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]+(cash*(crimes[id]+1)), playername )

				save_player_action(playerid, "[police_prison] "..playername.." prison "..id.." time "..(crimes[id]+1))
			else
				sendPlayerMessage(playerid, "[ERROR] Игрок далеко", red[1], red[2], red[3] )
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
	end
end)

addCommandHandler("givepolicetoken",--выдать пол-ий жетон
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3] )
		return
	end

	if inv_player_empty(playerid, 10, id) then
		sendPlayerMessage(playerid, "Вы получили "..info_png[10][1].." "..id, yellow[1], yellow[2], yellow[3])

		save_player_action(playerid, "[police_sub] "..playername.." ["..info_png[10][1]..", "..id.."]")
	else
		sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
	end
end)

addCommandHandler("takepolicetoken",--забрать пол-ий жетон
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3] )
		return
	end

	local player = getPlayerFromName ( id )
	if player then
		local player_name = getPlayerName ( player )

		if id == player_name then
			if inv_player_delet(player, 10, id) then
				sendPlayerMessage(playerid, "Вы забрали у "..id.." "..info_png[10][1].." "..id, yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(player, playername.." забрал(а) у вас "..info_png[10][1].." "..id, yellow[1], yellow[2], yellow[3])

				save_player_action(playerid, "[police_take_sub] "..playername.." ["..info_png[10][1]..", "..id.."]")
			else
				sendPlayerMessage(playerid, "[ERROR] У игрока нет жетона", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
		end
	else
		local s_sql = select_sqlite(10, id)
		if id == s_sql[1] then
			sendPlayerMessage(playerid, "Вы забрали у "..id.." "..info_png[10][1].." "..id, yellow[1], yellow[2], yellow[3])

			sqlite( "UPDATE account SET slot_"..s_sql[2].."_1 = '0', slot_"..s_sql[2].."_2 = '0' WHERE name = '"..s_sql[1].."'")

			save_player_action(playerid, "[police_take_sub] "..playername.." ["..info_png[10][1]..", "..id.."]")
		else
			sendPlayerMessage(playerid, "[ERROR] У игрока нет жетона", red[1], red[2], red[3])
		end
	end
end)

addCommandHandler("givepolicerank",--выдать шеврон
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 then
		return
	end

	if not id then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [от 28 до 32]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3] )
		return
	end

	if id >= 28 and id <= 32 then
		if inv_player_empty(playerid, id, 1) then
			sendPlayerMessage(playerid, "Вы получили "..info_png[id][1], yellow[1], yellow[2], yellow[3])

			save_player_action(playerid, "[police_sub] "..playername.." ["..info_png[id][1]..", 1]")
		else
			sendPlayerMessage(playerid, "[ERROR] Инвентарь полон", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] от 28 до 32", red[1], red[2], red[3])
	end
end)

addCommandHandler("takepolicerank",--забрать шеврон
function (playerid, cmd, id, rang)
	local playername = getPlayerName ( playerid )
	local rang = tonumber(rang)

	if logged[playername] == 0 then
		return
	end

	if not id or not rang then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр] [от 28 до 32]", red[1], red[2], red[3])
		return
	end

	if search_inv_player(playerid, 10, playername) == 0 or search_inv_player(playerid, 33, 1) == 0 then
		sendPlayerMessage(playerid, "[ERROR] Вы не Шеф полиции", red[1], red[2], red[3] )
		return
	end

	local player = getPlayerFromName ( id )
	if player then
		local player_name = getPlayerName ( player )

		if id == player_name then
			if inv_player_delet(player, rang, 1) then
				sendPlayerMessage(playerid, "Вы забрали у "..id.." "..info_png[rang][1], yellow[1], yellow[2], yellow[3])
				sendPlayerMessage(player, playername.." забрал(а) у вас "..info_png[rang][1], yellow[1], yellow[2], yellow[3])

				save_player_action(playerid, "[police_take_sub] "..playername.." ["..info_png[rang][1]..", "..id.."]")
			else
				sendPlayerMessage(playerid, "[ERROR] У игрока нет шеврона", red[1], red[2], red[3])
			end
		else
			sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
		end
	else
		local s_sql = select_sqlite(rang, 1)
		if id == s_sql[1] then
			sendPlayerMessage(playerid, "Вы забрали у "..id.." "..info_png[rang][1], yellow[1], yellow[2], yellow[3])

			sqlite( "UPDATE account SET slot_"..s_sql[2].."_1 = '0', slot_"..s_sql[2].."_2 = '0' WHERE name = '"..s_sql[1].."'")

			save_player_action(playerid, "[police_take_sub] "..playername.." ["..info_png[rang][1]..", "..id.."]")
		else
			sendPlayerMessage(playerid, "[ERROR] У игрока нет шеврона", red[1], red[2], red[3])
		end
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
	for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
		if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
			house_count = house_count+1
		end
	end

	local result = sqlite( "SELECT COUNT() FROM business_db" )
	local business_number = result[1]["COUNT()"]
	for h,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
		if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
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
			array_house_1[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			array_house_2[dim] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
			local house_door = 0

			createBlip ( x, y, z, 32, 0, 0,0,0,0, 0, 500 )
			createPickup ( x, y, z, 3, house_icon, 10000 )

			sqlite( "INSERT INTO house_db (number, door, nalog, x, y, z, interior, world, slot_0_1, slot_0_2, slot_1_1, slot_1_2, slot_2_1, slot_2_2, slot_3_1, slot_3_2, slot_4_1, slot_4_2, slot_5_1, slot_5_2, slot_6_1, slot_6_2, slot_7_1, slot_7_2, slot_8_1, slot_8_2, slot_9_1, slot_9_2, slot_10_1, slot_10_2, slot_11_1, slot_11_2, slot_12_1, slot_12_2, slot_13_1, slot_13_2, slot_14_1, slot_14_2, slot_15_1, slot_15_2, slot_16_1, slot_16_2, slot_17_1, slot_17_2, slot_18_1, slot_18_2, slot_19_1, slot_19_2, slot_20_1, slot_20_2, slot_21_1, slot_21_2, slot_22_1, slot_22_2, slot_23_1, slot_23_2) VALUES ('"..dim.."', '"..house_door.."', '5', '"..x.."', '"..y.."', '"..z.."', '1', '"..dim.."', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')" )

			sendPlayerMessage(playerid, "Вы получили "..info_png[25][1].." "..dim.." "..info_png[25][2], orange[1], orange[2], orange[3])
			
			triggerClientEvent( playerid, "event_bussines_house_fun", playerid, dim, x, y, z, "house", house_bussiness_radius )

			save_realtor_action(playerid, "[sellhouse] "..playername.." [house - "..dim..", x - "..x..", y - "..y..", z - "..z.."]")
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [номер бизнеса от 1 до "..#interior_business.."]", red[1], red[2], red[3])
		return
	end

	if id >= 1 and id <= #interior_business then
		if search_inv_player(playerid, 45, playername) == 0 then
			sendPlayerMessage(playerid, "[ERROR] Вы не риэлтор", red[1], red[2], red[3] )
			return
		end

		local result = sqlite( "SELECT COUNT() FROM business_db" )
		local business_number = result[1]["COUNT()"]
		for h,v in pairs(sqlite( "SELECT * FROM business_db" )) do 
			if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
				business_count = business_count+1
			end
		end

		local result = sqlite( "SELECT COUNT() FROM house_db" )
		local house_number = result[1]["COUNT()"]
		for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
			if not isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) then
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
				createBlip ( x, y, z, interior_business[id][6], 0, 0,0,0,0, 0, 500 )
				createPickup ( x, y, z, 3, business_icon, 10000 )

				sqlite( "INSERT INTO business_db (number, type, price, buyprod, money, nalog, warehouse, x, y, z, interior, world) VALUES ('"..dim.."', '"..interior_business[id][2].."', '0', '0', '0', '5', '0', '"..x.."', '"..y.."', '"..z.."', '"..id.."', '"..dim.."')" )

				sendPlayerMessage(playerid, "Вы получили "..info_png[43][1].." "..dim.." "..info_png[43][2], orange[1], orange[2], orange[3])
				
				triggerClientEvent( playerid, "event_bussines_house_fun", playerid, dim, x, y, z, "biz", house_bussiness_radius )

				save_realtor_action(playerid, "[sellbusiness] "..playername.." [business - "..dim..", x - "..x..", y - "..y..", z - "..z.."]")
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [номер интерьера от 1 до "..#interior_house.."]", red[1], red[2], red[3])
		return
	end

	if id >= 1 and id <= #interior_house then
		if (cash*id) <= array_player_2[playername][1] then
			for h,v in pairs(sqlite( "SELECT * FROM house_db" )) do
				if isPointInCircle3D(v["x"],v["y"],v["z"], x,y,z, house_bussiness_radius) and getElementDimension(playerid) == 0 and getElementInterior(playerid) == 0 then
					if search_inv_player(playerid, 25, v["number"]) ~= 0 then
						sqlite( "UPDATE house_db SET interior = '"..id.."' WHERE number = '"..v["number"].."'")

						inv_server_load( playerid, "player", 0, 1, array_player_2[playername][1]-(cash*id), playername )

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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ид предмета] [количество]", red[1], red[2], red[3])
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

local sub_text = {2,10,44,45,50,64,66,72,74}
addCommandHandler ( "subt",--выдача предметов с текстом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), id2
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if val1 == nil or val2 == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ид предмета] [текст]", red[1], red[2], red[3])
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

addCommandHandler ( "subcar",--выдача предметов с числом
function (playerid, cmd, id1, id2 )
	local val1, val2 = tonumber(id1), tonumber(id2)
	local playername = getPlayerName ( playerid )
	local vehicleid = getPlayerVehicle ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if not val1 or not val2  then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ид предмета] [количество]", red[1], red[2], red[3])
		return
	end

	if val1 > #info_png or val1 < 2 then
		sendPlayerMessage(playerid, "[ERROR] от 2 до "..#info_png, red[1], red[2], red[3])
		return
	end

	if not vehicleid then
		sendPlayerMessage(playerid, "[ERROR] Вы не в т/с", red[1], red[2], red[3])
		return
	end

	give_subject(playerid, "car", val1, val2)

	sendPlayerMessage(playerid, "Вы создали "..info_png[val1][1].." "..val2.." "..info_png[val1][2], lyme[1], lyme[2], lyme[3])

	save_admin_action(playerid, "[admin_subcar] "..playername.." ["..val1..", "..val2.."]")
end)

addCommandHandler ( "go",
function ( playerid, cmd, x, y, z )
	local playername = getPlayerName ( playerid )
	local x,y,z = tonumber(x), tonumber(y), tonumber(z)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if x == nil or y == nil or z == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [и 3 координаты]", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [указать топливо от 0 до 50]", red[1], red[2], red[3])
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

	local result = sqlite( "INSERT INTO position (description, pos) VALUES ('"..text.."', '"..x..","..y..","..z.."')" )
	sendPlayerMessage(playerid, "save pos "..text, lyme[1], lyme[2], lyme[3])
end)

addCommandHandler ( "global",
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

	if text == "" then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [текст]", red[1], red[2], red[3])
		return
	end

	sendPlayerMessage(getRootElement(), "[ADMIN] "..playername..": "..text, lyme[1], lyme[2], lyme[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [час] [минуты]", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
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

addCommandHandler ( "invplayer",--чекнуть инв-рь игрока
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM account WHERE name = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM account WHERE name = '"..id.."'" )
		for i=0,max_inv do
			triggerClientEvent(playerid, "event_invsave_fun", playerid, "save", id, i, result[1]["slot_"..i.."_1"], result[1]["slot_"..i.."_2"])
		end

		triggerClientEvent(playerid, "event_invsave_fun", playerid, "load", 0, 0, 0, 0)
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "invcar",--чекнуть инв-рь тс
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM car_db WHERE number = '"..id.."'" )
		for i=0,max_inv do
			triggerClientEvent(playerid, "event_invsave_fun", playerid, "save", id, i, result[1]["slot_"..i.."_1"], result[1]["slot_"..i.."_2"])
		end

		triggerClientEvent(playerid, "event_invsave_fun", playerid, "load", 0, 0, 0, 0)
	else
		sendPlayerMessage(playerid, "[ERROR] Такого т/с нет", red[1], red[2], red[3])
	end
end)

addCommandHandler ( "invhouse",--чекнуть инв-рь дома
function (playerid, cmd, id)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
		return
	end

	local result = sqlite( "SELECT COUNT() FROM house_db WHERE number = '"..id.."'" )
	if result[1]["COUNT()"] == 1 then
		local result = sqlite( "SELECT * FROM house_db WHERE number = '"..id.."'" )
		for i=0,max_inv do
			triggerClientEvent(playerid, "event_invsave_fun", playerid, "save", id, i, result[1]["slot_"..i.."_1"], result[1]["slot_"..i.."_2"])
		end

		triggerClientEvent(playerid, "event_invsave_fun", playerid, "load", 0, 0, 0, 0)
	else
		sendPlayerMessage(playerid, "[ERROR] Такого дома нет", red[1], red[2], red[3])
	end
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

addCommandHandler ( "logrealtor",--чекнуть логи риэлторов
function (playerid)
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	local result = sqlite( "SELECT * FROM save_realtor_action" )
	for k,v in pairs(result) do
		triggerClientEvent(playerid, "event_logsave_fun", playerid, "save", "logrealtor", k, v["realtor_action"])
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

	if not id or reason == "" or not time then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр] [время] [причина]", red[1], red[2], red[3])
		return
	end

	local player = getPlayerFromName ( id )
	if player then
		local player_name = getPlayerName ( player )

		if id == player_name then
			if logged[id] == 0 then
				sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
				return
			end

			sendPlayerMessage( getRootElement(), "Администратор "..playername.." посадил в тюрьму "..id.." на "..time.." мин. Причина: "..reason, lyme[1], lyme[2], lyme[3])

			arrest[id] = 1
			crimes[id] = time-1

			save_admin_action(playerid, "[admin_prisonplayer] "..playername.." prisonplayer "..id.." time "..time.." reason "..reason)
		else
			sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
		end
	else
		sendPlayerMessage(playerid, "[ERROR] Такого игрока нет", red[1], red[2], red[3])
	end
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр] [причина]", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр]", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ник соблюдая регистр] [причина]", red[1], red[2], red[3])
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

addCommandHandler ( "int",
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )
	local id = tonumber(id)

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [номер интерьера]", red[1], red[2], red[3])
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
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [номер виртуального мира]", red[1], red[2], red[3])
		return
	end

	setElementDimension ( playerid, id )
	sendPlayerMessage(playerid, "setElementDimension "..id, lyme[1], lyme[2], lyme[3])
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
							sendPlayerMessage(playerid, "т/с прикреплен", lyme[1], lyme[2], lyme[3])
						end
					else
						detachElements  ( vehicle, vehicleid )
						sendPlayerMessage(playerid, "т/с откреплен", lyme[1], lyme[2], lyme[3])
					end

					return
				end
			end
		end
	end
end)

addCommandHandler ( "v",--спавн авто для админов
function ( playerid, cmd, id )
	local playername = getPlayerName ( playerid )

	if logged[playername] == 0 or search_inv_player(playerid, 44, playername) == 0 then
		return
	end

	local id = tonumber(id)

	if id == nil then
		sendPlayerMessage(playerid, "[ERROR] /"..cmd.." [ид т/с]", red[1], red[2], red[3])
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

			--setVehicleDamageProof(vehicleid, true)

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

	elseif text == "x" then
		restartAllResources()
	end
end
addEventHandler ( "onConsole", getRootElement(), input_Console )

local objPick = 0
function o_pos( thePlayer )
	local x, y, z = getElementPosition (thePlayer)
	objPick = createObject (2702, x, y, z)

	attachElementToBone (objPick, thePlayer, 12, 0,0,0, 0,0,0)
end

addCommandHandler ("orot",
function (playerid, cmd, id1, id2, id3)
	setElementBoneRotationOffset (objPick, tonumber(id1), tonumber(id2), tonumber(id3))
end)

addCommandHandler ("opos",
function (playerid, cmd, id1, id2, id3)
	setElementBonePositionOffset (objPick, tonumber(id1), tonumber(id2), tonumber(id3))
end)
