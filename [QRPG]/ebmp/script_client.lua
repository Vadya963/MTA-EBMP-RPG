local screenWidth, screenHeight = guiGetScreenSize ( )
local m2font = guiCreateFont( "gui/m2font.ttf", 9 )
local m2font_dx = dxCreateFont ( "gui/m2font.ttf", 9 )--default-bold
local m2font_dx1 = "default-bold"--dxCreateFont ( "gui/m2font.ttf", 10 )
setDevelopmentMode ( true )
local debuginfo = false
local hud = true
local timer = {false, 10, 10}
local info_png = {}
local image = {}--загрузка картинок для отображения на земле
local no_sell_auc = {}--нельзя продать

addEventHandler( "onClientResourceStart", resourceRoot,
function ( startedRes )
	bindKey ( "F1", "down", showcursor_b )
	bindKey ( "F2", "down", showdebuginfo_b )
	bindKey ( "F3", "down", menu_mafia_2 )
	bindKey ( "F11", "down", showdebuginfo_b )
	bindKey( "vehicle_fire", "down", toggleNOS )

	info_png = getElementData(resourceRoot, "info_png")
	setElementData(resourceRoot, "no_sell_auc", no_sell_auc)

	for i=0,#info_png do
		image[i] = dxCreateTexture("image_inventory/"..i..".png")
	end

	setTimer(function()
		triggerServerEvent("event_reg_or_login", resourceRoot, localPlayer)
	end, 1000, 1)
end)

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
local crimson = {220,20,60}--малиновый
local purple = {175,0,255}--фиолетовый
local gray = {150,150,150}--серый
local green_rc = {115,180,97}--темно зеленый

local max_speed = 80--максимальная скорость в городе
local time_game = 0--сколько минут играешь
local afk = 0--сколько минут в афк
local pos_timer = 0--задержка для евента

local no_use_subject = {-1,0}--нельзя использовать
local no_select_subject = {-1,0,1}--нельзя выделить
local no_change_subject = {-1,1}--нельзя заменить

--выделение картинки
local gui_2dtext = false
local gui_pos_x = 0 --положение картинки x
local gui_pos_y = 0 --положение картинки y
local info1_png = -1 --номер картинки
local info2_png = -1 --значение картинки

-----------эвенты------------------------------------------------------------------------
math.randomseed(getTickCount())
function random(min, max)
	return math.random(min, max)
end

function playerDamage_text ( attacker, weapon, bodypart, loss )--получение урона
	local ped = source

	for k,v in pairs(getElementData(localPlayer, "no_ped_damage")) do
		if v == ped then
			cancelEvent()
			break
		end
	end
end
addEventHandler ( "onClientPedDamage", root, playerDamage_text )

function outputLoss(loss, attacker)
	local object = source

	if getElementType(attacker) == "player" and getElementData(localPlayer, "job_player") == 15 and getElementModel(object) == 1851 then
		if getPedWeapon(localPlayer) == 33 then
			setElementData(localPlayer, "deer", true)
		end
	end
end
addEventHandler("onClientObjectDamage", root, outputLoss)

function setPedOxygenLevel_fun ()--кислородный балон
	local count = 0
	
	setTimer(function()
		setPedOxygenLevel ( localPlayer, 4000 )
		count = count+1

		if count == 300 then
			setElementData(localPlayer, "OxygenLevel", false)
		end
	end, 1000, 300)

	setElementData(localPlayer, "OxygenLevel", true)
end
addEvent( "event_setPedOxygenLevel_fun", true )
addEventHandler ( "event_setPedOxygenLevel_fun", root, setPedOxygenLevel_fun )

function createFire_fun (x,y,z, size, radius, count)--создание огня
	local r1,r2 = random(radius*-1,radius),random(radius*-1,radius)
	for i=1,count do
		createFire(x+r1, y+r2, z, size)
	end
end
addEvent( "event_createFire", true )
addEventHandler ( "event_createFire", root, createFire_fun )

function body_hit_sound ()--звук поподания в тело
	playSound("other/body_hit_sound.mp3")
end
addEvent( "event_body_hit_sound", true )
addEventHandler ( "event_body_hit_sound", root, body_hit_sound )

function setElementCollidableWith_fun (value1, element, value)--вкл/откл столкновения тс
	for index,vehicle in pairs(getElementsByType(value1)) do --LOOP through all Vehicles
		setElementCollidableWith(vehicle, element, value) -- Set the Collison off with the Other vehicles.
	end
end
addEvent( "event_setElementCollidableWith_fun", true )
addEventHandler ( "event_setElementCollidableWith_fun", root, setElementCollidableWith_fun )

addEvent( "event_extinguishFire", true )
addEventHandler ( "event_extinguishFire", root, extinguishFire )

addEvent( "event_setPedAimTarget", true )
addEventHandler ( "event_setPedAimTarget", root, setPedAimTarget )

addEvent( "event_setPedControlState", true )
addEventHandler ( "event_setPedControlState", root, setPedControlState )

addEvent( "event_givePedWeapon", true )
addEventHandler ( "event_givePedWeapon", root, givePedWeapon )

addEvent( "event_setPedCameraRotation", true )
addEventHandler ( "event_setPedCameraRotation", root, setPedCameraRotation )

addEvent( "event_setFarClipDistance", true )
addEventHandler ( "event_setFarClipDistance", root, setFarClipDistance )

addEventHandler( "onClientElementStreamIn", root,
function ( )
	if getElementType(source) == "vehicle" then
		--setVehicleComponentVisible(source, "bump_front_dummy", false)
		--setVehicleComponentVisible(source, "bump_rear_dummy", false)
	end
end)

function handleVehicleDamage(theAttacker, theWeapon, loss, damagePosX, damagePosY, damagePosZ, tireID)
	local vehicleid = source
	local table_no_damage_car = {528,432,601,428}
	for k,v in pairs(table_no_damage_car) do
		if getElementModel(vehicleid) == v then
			setElementHealth(vehicleid, 999)
			cancelEvent()
		end
	end

	--[[if getVehicleType (vehicleid) == "Plane" or getVehicleType (vehicleid) == "Helicopter" then
		if isInsideColShape(lv_airport, x,y,z) or isInsideColShape(sf_airport, x,y,z) or isInsideColShape(ls_airport, x,y,z) then
			for k,localPlayer in pairs(getElementsByType("player")) do
				triggerClientEvent( localPlayer, "event_setElementCollidableWith_fun", localPlayer, "vehicle", vehicleid, false )
			end
		else
			for k,localPlayer in pairs(getElementsByType("player")) do
				triggerClientEvent( localPlayer, "event_setElementCollidableWith_fun", localPlayer, "vehicle", vehicleid, true )
			end
		end
	end]]
end
addEventHandler("onClientVehicleDamage", root, handleVehicleDamage)


local name_player = 0
local logplayer = {}
function logsave_fun (value, name, i, id)--таблица логов
	if value == "save" then
		name_player = name
		logplayer[i] = id

	elseif value == "load" then
		save_logplayer()
	end
end
addEvent( "event_logsave_fun", true )
addEventHandler ( "event_logsave_fun", root, logsave_fun )

function save_logplayer()
	local newFile = fileCreate("log-"..name_player..".txt")
	if (newFile) then
		for i=1,#logplayer do
			fileWrite(newFile, logplayer[i].."\n")
		end

		sendMessage("лог "..name_player.." загружен и сохранен в папке с модом", lyme)
		fileClose(newFile)

		logplayer = {}
	end
end

local invplayer = ""
function invsave_fun (value, name, text)--таблица inv
	if value == "save" then
		name_player = name
		invplayer = text

	elseif value == "load" then
		save_invplayer()
	end
end
addEvent( "event_invsave_fun", true )
addEventHandler ( "event_invsave_fun", root, invsave_fun )

function save_invplayer()
	local newFile = fileCreate("inv-"..name_player..".txt")
	if (newFile) then
		fileWrite(newFile, invplayer.."\n")

		sendMessage("инв-рь "..name_player.." загружен и сохранен в папке с модом", lyme)
		fileClose(newFile)

		invplayer = {}
	end
end
-----------------------------------------------------------------------------------------

---------------------таймеры-------------------------------------------------------------
setTimer(function ()
	time_game = time_game+1
end, 60000, 0)

setTimer(function ()
	pos_timer = 1
end, 5000, 1)

setTimer(function ()
	if isChatBoxInputActive() or isConsoleActive() then
		setElementData(localPlayer, "is_chat_open", 1)
	elseif getElementData(localPlayer, "is_chat_open") == 1 then
		setElementData(localPlayer, "is_chat_open", 0)
	end
end, 500, 0)

setTimer(function ()
	if isMainMenuActive() then
		afk = afk+1
		setElementData(localPlayer, "afk", afk)
	elseif getElementData(localPlayer, "afk") and getElementData(localPlayer, "afk") > 0 then
		afk = 0
		setElementData(localPlayer, "afk", afk)
	end

	if timer[1] then
		timer[3] = timer[3]-1

		if timer[3] == -1 then
			timer[1] = false
		end
	end

	setElementData(localPlayer, "task", getPedSimplestTask(localPlayer))
end, 1000, 0)

setTimer(function ()
	local timeserver = getElementData(localPlayer, "timeserver")
	if timeserver then
		timeserver = split(getElementData(localPlayer, "timeserver"), ":")
		setTime(timeserver[1], timeserver[2])
	end
end, 60000, 0)
-----------------------------------------------------------------------------------------

local upgrades_car_table = {}
local uc_txt = fileOpen(":ebmp/other/upgrades_car.txt")
for k,v in pairs(split(fileRead ( uc_txt, fileGetSize( uc_txt ) ), "|")) do
	local spl = split(v, ",")
	upgrades_car_table[tonumber(spl[1])] = spl[3]
end
fileClose(uc_txt)

local info_tab = nil --положение картинки в табе
local info1 = -1 --номер картинки
local info2 = -1 --значение картинки
local info3 = -1 --слот картинки

--гуи окно
local stats_window = nil
local tabPanel = nil
local tab_player = nil
local tab_car = nil
local tab_house = nil
local tab_box = nil

--окно тюнинга
local gui_window = nil

local plate = ""
local house = ""
local box = ""

local max_inv = 23
local inv_slot_player = {} -- инв-рь игрока
local inv_slot_car = {} -- инв-рь авто
local inv_slot_house = {} -- инв-рь дома
local inv_slot_box = {} -- инв-рь ящика

for i=0,max_inv do
	inv_slot_player[i] = {0,0,0}
	inv_slot_car[i] = {0,0,0}
	inv_slot_house[i] = {0,0,0}
	inv_slot_box[i] = {0,0,0}
end

function sendMessage(text, color)
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

	outputChatBox("["..hour..":"..minute..":"..second.."] "..text, color[1], color[2], color[3])
end

function timerm2(time)
	timer[1] = true
	timer[2] = time
	timer[3] = time
end
addEvent("createHudTimer", true)
addEventHandler("createHudTimer", root, timerm2)

function timerm2off()
	timer[1] = false
end
addEvent("destroyHudTimer", true)
addEventHandler("destroyHudTimer", root, timerm2off)

function getPlayerVehicle( localPlayer )
	local vehicle = getPedOccupiedVehicle ( localPlayer )
	return vehicle
end

function isPointInCircle3D(x, y, z, x1, y1, z1, radius)
	local check = getDistanceBetweenPoints3D(x, y, z, x1, y1, z1)
	if check <= radius then
		return true
	else
		return false
	end
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

function getPlayerId( id )--узнать имя игрока из ид
	for k,player in pairs(getElementsByType("player")) do
		if getElementData(player, "player_id")[1] == tonumber(id) then
			return getPlayerName(player), player
		end
	end

	return false
end

function getPedMaxHealth(ped)
	-- Output an error and stop executing the function if the argument is not valid
	assert(isElement(ped) and (getElementType(ped) == "ped" or getElementType(ped) == "player"), "Bad argument @ 'getPedMaxHealth' [Expected ped/player at argument 1, got " .. tostring(ped) .. "]")

	-- Grab his player health stat.
	local stat = getPedStat(ped, 24)

	-- Do a linear interpolation to get how many health a ped can have.
	-- Assumes: 100 health = 569 stat, 200 health = 1000 stat.
	local maxhealth = 100 + (stat - 569) / 4.31

	-- Return the max health. Make sure it can't be below 1
	return math.max(1, maxhealth)
end

function getPlayer_Id (localPlayer)
	local id = getElementData(localPlayer, "player_id")
	if id and id[1] then
		return id[1]
	else
		return 0
	end
end

------------------------------собственное гуи--------------------------------------------
function m2gui_label( x,y, width, height, text, bool_r, parent )
	local text = guiCreateLabel ( x, y, width, height, text, bool_r, parent )
	guiSetFont( text, m2font )
	return text
end

function m2gui_radiobutton( x,y, width, height, text, bool_r, parent )
	local text = guiCreateRadioButton ( x, y, width, height, text, bool_r, parent )
	guiSetFont( text, m2font )
	local x1,y1 = guiGetSize(text, false)
	local x2,y2 = guiGetPosition(text, false)
	return text,x1+x+5,y1+y2
end

function m2gui_window( x,y, width, height, text, bool_r, movable, sizable )
	local m2gui_win = guiCreateWindow( x, y, width, height, text, bool_r )

	if movable then
		guiWindowSetMovable ( m2gui_win, true )
	else
		guiWindowSetMovable ( m2gui_win, false )
	end

	if sizable then
		guiWindowSetSizable ( m2gui_win, true )
	else
		guiWindowSetSizable ( m2gui_win, false )
	end

	return m2gui_win
end

function m2gui_button( x,y, text, bool_r, parent)
	local sym = 16+5+20
	local dimensions = dxGetTextWidth ( text, 1, m2font_dx )
	local dimensions_h = dxGetFontHeight ( 1, m2font_dx )
	local m2gui_fon = guiCreateStaticImage( x, y, dimensions+sym, 16, "comp/low_fon.png", bool_r, parent )
	local m2gui_but = guiCreateStaticImage( 0, 0, 16, 16, "gui/gui7.png", bool_r, m2gui_fon )
	local text = m2gui_label ( 16+5, 0, dimensions+20, dimensions_h, text, bool_r, m2gui_fon )
	local x1,y1 = guiGetPosition(m2gui_fon, false)

	function outputEditBox ( absoluteX, absoluteY, gui )--наведение на текст кнопки
		guiLabelSetColor ( text, crimson[1], crimson[2], crimson[3] )
	end
	addEventHandler( "onClientMouseEnter", text, outputEditBox, false )

	function outputEditBox ( absoluteX, absoluteY, gui )--покидание на текст кнопки
		guiLabelSetColor ( text, white[1], white[2], white[3] )
	end
	addEventHandler( "onClientMouseLeave", text, outputEditBox, false )

	return text,dimensions+sym+x,20+y1
end
-----------------------------------------------------------------------------------------

local skin = {"мужская одежда", 1, 2, 7, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 153, 154, 155, 156, 158, 159, 160, 161, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 265, 266, 267, 268, 269, 270, 271, 272, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 305, 306, 307, 308, 309, 310, 312, "женская одежда", 9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 304}

local text1 = "Нажмите E, чтобы взять пустую коробку"
local text2 = "Выбросите пустую коробку, чтобы получить коробку с продуктами"
local text3 = "Выбросите бензопилу, чтобы получить бревна"
local text4 = "Выбросите кирку, чтобы получить железную руду"
local text5 = "Выбросите кирку, чтобы получить уголь"

local text_3d = {--3d text

	--up_player_subject
	{-491.4609375,-194.43359375,78.394332885742, 5, "Нажмите E, чтобы взять бензопилу"},
	{576.8212890625,846.5732421875,-42.264389038086, 5, "Нажмите E, чтобы взять кирку"},
	{1743.0302734375,-1864.4560546875,13.573830604553, 5, "Нажмите E, чтобы взять маршрутный лист"},--автобусник
	{964.064453125,2117.3544921875,1011.0302734375, 1, "Нажмите E, чтобы взять нож мясника"},--мясокомбинат
	
	--down_player_subject
	{942.4775390625,2117.900390625,1011.0302734375, 5, "Выбросите мясо, чтобы получить прибыль"},
	{2564.779296875,-1293.0673828125,1044.125, 2, "Выбросите продукты, чтобы получить прибыль"},
	{681.7744140625,823.8447265625,-26.840600967407, 5, "Выбросите руду, чтобы получить прибыль"},
	{-488.2119140625,-176.8603515625,78.2109375, 5, "Выбросите дрова, чтобы получить прибыль"},--склад бревен
	{-1633.845703125,-2239.08984375,31.4765625, 5, "Выбросите тушку оленя, чтобы получить прибыль"},--охотничий дом
	{2435.361328125,-2705.46484375,3, 5, "Выбросите потерянный груз, чтобы получить прибыль"},--доки лc

	--up_car_subject
	{89.9423828125,-304.623046875,1.578125, 15, "Склад продуктов (Загрузить ящики - E)"},
	{260.4326171875,1409.2626953125,10.506074905396, 15, "Нефтезавод (Загрузить бочки - E)"},
	{-1061.6103515625,-1195.5166015625,129.828125, 15, "Скотобойня (Загрузить тушки коров - E)"},
	{1461.939453125,974.8876953125,10.30264377594, 15, "Склад корма (Загрузить корм - E)"},--склад корма для коров
	{2492.3974609375,2773.46484375,10.803514480591, 15, "KACC (Загрузить ящики - E)"},--kacc
	{2122.8994140625,-1790.56640625,13.5546875, 15, "Пиццерия (Загрузить пиццу - E)"},--pizza

	--down_car_subject
	{2787.8974609375,-2455.974609375,13.633636474609, 15, "Порт ЛС (Разгрузить товар - E)"},
	{2315.595703125,6.263671875,26.484375, 15, "Банк"},
	{-1813.2890625,-1654.3330078125,22.398532867432, 15, "Свалка"},
	{2463.7587890625,-2716.375,1.1451852619648, 15, "Доки Лос Сантоса"},
	{966.951171875,2132.8623046875,10.8203125, 15, "Мясокомбинат (Разгрузить тушки коров - E)"},
	{-1079.947265625,-1195.580078125,129.79998779297, 15, "Склад скотобойни (Разгрузить корм - E)"},--скотобойня корм

	--interior_job
	{2131.9775390625,-1151.322265625,24.062105178833, 5, "Покупка т/с (Меню - X)"},
	{1590.1689453125,1170.60546875,14.224066734314, 5, "Покупка вертолетов и самолетов (Меню - X)"},
	{-2187.46875,2416.5576171875,5.1651339530945, 5, "Покупка лодок (Меню - X)"},
	{2308.81640625,-13.25,26.7421875, 5, "Банк"},

	{1743.119140625,-1943.5732421875,13.569796562195, 10, "Используйте жетон, чтобы отправиться на Вокзал СФ"},
	{-1973.22265625,116.78515625,27.6875, 10, "Используйте жетон, чтобы отправиться на Вокзал ЛВ"},
	{2848.4521484375,1291.462890625,11.390625, 10, "Используйте жетон, чтобы отправиться на Вокзал ЛС"},

	{365.4150390625,2537.072265625,16.664493560791, 5, "Отстойник"},

	--anim_player_subject
	--завод продуктов
	{2559.1171875,-1287.2275390625,1044.125, 2, text1},
	{2551.1318359375,-1287.2294921875,1044.125, 2, text1},
	{2543.0859375,-1287.2216796875,1044.125, 2, text1},
	{2543.166015625,-1300.0927734375,1044.125, 2, text1},
	{2551.09375,-1300.09375,1044.125, 2, text1},
	{2559.0185546875,-1300.0927734375,1044.125, 2, text1},
	{2558.6474609375,-1291.0029296875,1044.125, 1, text2},
	{2556.080078125,-1290.9970703125,1044.125, 1, text2},
	{2553.841796875,-1291.0048828125,1044.125, 1, text2},
	{2544.4326171875,-1291.00390625,1044.125, 1, text2},
	{2541.9169921875,-1290.9951171875,1044.125, 1, text2},
	{2541.9091796875,-1295.8505859375,1044.125, 1, text2},
	{2544.427734375,-1295.8505859375,1044.125, 1, text2},
	{2553.7578125,-1295.8505859375,1044.125, 1, text2},
	{2556.2578125,-1295.8544921875,1044.125, 1, text2},
	{2558.5478515625,-1295.8505859375,1044.125, 1, text2},

	--лесоповал
	{-511.3896484375,-193.8212890625,78.391899108887, 1, text3},
	{-515.8330078125,-194.17578125,78.40625, 1, text3},
	{-521.138671875,-194.4169921875,78.40625, 1, text3},
	{-525.8740234375,-194.6396484375,78.40625, 1, text3},
	{-530.169921875,-194.83984375,78.40625, 1, text3},
	{-535.298828125,-195.0869140625,78.40625, 1, text3},
	{-547.07421875,-158.0869140625,77.827285766602, 1, text3},
	{-542.3623046875,-157.970703125,77.814529418945, 1, text3},
	{-536.755859375,-158.0146484375,77.819396972656, 1, text3},
	{-531.126953125,-157.77734375,77.626838684082, 1, text3},
	{-525.6103515625,-157.7939453125,77.082763671875, 1, text3},
	{-494.0009765625,-154.6943359375,76.312866210938, 1, text3},
	{-487.8037109375,-154.35546875,76.055053710938, 1, text3},
	{-482.490234375,-154.0693359375,75.835266113281, 1, text3},
	{-477.3134765625,-153.7890625,75.568603515625, 1, text3},
	{-471.2958984375,-153.5048828125,75.246078491211, 1, text3},

	--рудник лв
	{630.7001953125,865.71032714844,-42.660102844238, 1, text5},
	{619.72265625,873.4443359375,-42.9609375, 1, text5},
	{607.9052734375,864.9892578125,-42.809223175049, 1, text5},
	{610.1083984375,845.86267089844,-42.524024963379, 1, text5},
	{627.5458984375,844.70349121094,-42.33695602417, 1, text5},
	{579.53356933594,874.83459472656,-43.100883483887, 1, text4},
	{574.99548339844,889.15100097656,-42.958339691162, 1, text4},
	{559.23962402344,892.81115722656,-42.695762634277, 1, text4},
	{552.41442871094,878.68420410156,-42.364948272705, 1, text4},
	{563.02087402344,863.94885253906,-42.350147247314, 1, text4},
}

for j=0,1 do
	for i=0,4 do
		text_3d[#text_3d+1] = {956.0166015625+(j*6.5),2142.6650390625-(3*i),1011.0181274414, 1, "Выбросите нож мясника, чтобы получить мясо"}
	end
end

--перемещение картинки
local lmb = 0--лкм
local gui_selection = false
local gui_selection_pos_x = 0 --положение картинки x
local gui_selection_pos_y = 0 --положение картинки y
local info3_selection_1 = -1 --слот картинки
local info1_selection_1 = -1 --номер картинки
local info2_selection_1 = -1 --значение картинки


function dxdrawtext(text, x, y, width, height, color, scale, font)
	dxDrawText ( text, x+1, y+1, width, height, tocolor ( 0, 0, 0, 255 ), scale, font )

	dxDrawText ( text, x, y, width, height, color, scale, font )
end

local lastTick, framesRendered, FPS = getTickCount(), 0, 0
function createText ()

	local currentTick = getTickCount()
	local elapsedTime = currentTick - lastTick

	if elapsedTime >= 1000 then
		FPS = framesRendered
		lastTick = currentTick
		framesRendered = 0
	else
		framesRendered = framesRendered + 1
	end

	local time = getRealTime()

	local alcohol = getElementData ( localPlayer, "alcohol_data" ) or 0--макс 500
	local satiety = getElementData ( localPlayer, "satiety_data" ) or 0--макс 100
	local hygiene = getElementData ( localPlayer, "hygiene_data" ) or 0--макс 100
	local sleep = getElementData ( localPlayer, "sleep_data" ) or 0--макс 100
	local drugs = getElementData ( localPlayer, "drugs_data" ) or 0--макс 100
	local width_need = (screenWidth/5.04)--ширина нужд 271
	local height_need = (screenHeight/5.68)--высота нужд 135

	if hud then
		local client_time = "Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"]
		local text = "FPS: "..FPS.." | Ping: "..getPlayerPing(localPlayer).." | ID: "..getPlayer_Id(localPlayer).." | Players online: "..#getElementsByType("player").." | Minute in game: "..time_game.." | "..client_time
		dxdrawtext ( text, 2.0, 0.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

		--нужды
		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*0, 30, 30, "hud/alcohol.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*0, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*0, (width_need/500)*alcohol, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*1, 30, 30, "hud/drugs.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*1, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*1, (width_need/100)*drugs, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*2, 30, 30, "hud/satiety.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*2, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*2, (width_need/100)*satiety, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*3, 30, 30, "hud/hygiene.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*3, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*3, (width_need/100)*hygiene, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*4, 30, 30, "hud/sleep.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*4, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*4, (width_need/100)*sleep, 15, tocolor ( 90, 151, 107, 255 ) )

		local vehicle = getPlayerVehicle ( localPlayer )
		if vehicle then--отображение скорости авто
			local speed_table = split(getSpeed(vehicle), ".")
			local heal_vehicle = split(getElementHealth(vehicle), ".")
			local fuel = getElementData ( localPlayer, "fuel_data" )
			local fuel_table = split(fuel, ".")
			local speed_car = 0

			if getSpeed(vehicle) >= 240 then
				speed_car = 240*1.125+43
			else
				speed_car = getSpeed(vehicle)*1.125+43
			end

			local speed_vehicle = "plate "..plate.." | heal vehicle "..heal_vehicle[1].." | kilometrage "..split(getElementData ( localPlayer, "probeg_data" ), ".")[1]

			dxdrawtext ( speed_vehicle, 5, screenHeight-16, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

			dxDrawImage ( screenWidth-250, screenHeight-250, 210, 210, "speedometer/speed_v.png" )
			dxDrawImage ( screenWidth-250, screenHeight-250, 210, 210, "speedometer/arrow_speed_v.png", speed_car )
			dxDrawImage ( (screenWidth-250), screenHeight-250, 210, 210, "speedometer/fuel_v.png", 35.0-(fuel*1.4) )
		end

		local spl_gz = getElementData(localPlayer, "guns_zone2")
		local name_mafia = getElementData(resourceRoot, "name_mafia")
		if spl_gz and spl_gz[1][1] == 1 then
			dxDrawRectangle( 0.0, screenHeight-16.0*6-124, 250.0, 16.0*3, tocolor( 0, 0, 0, 150 ) )
			dxdrawtext ( "Время: "..spl_gz[2].." сек", 2.0, screenHeight-16*6-124, 0.0, 0.0, tocolor( white[1], white[2], white[3] ), 1, m2font_dx1 )
			dxdrawtext ( "Атака "..getTeamName(name_mafia[spl_gz[1][3]][1])..": "..spl_gz[1][4].." очков", 2.0, screenHeight-16*5-124, 0.0, 0.0, tocolor( 255,0,50 ), 1, m2font_dx1 )
			dxdrawtext ( "Защита "..getTeamName(name_mafia[spl_gz[1][5]][1])..": "..spl_gz[1][6].." очков", 2.0, screenHeight-16*4-124, 0.0, 0.0, tocolor( 0,50,255 ), 1, m2font_dx1 )
		end

		if timer[1] then
			dxDrawImage ( (screenWidth-85), 238, 85, 85, "gui/timer.png" )
			dxDrawCircle ( (screenWidth-85)+(85/2), 238+(85/2), 30, -90.0, (360.0/timer[2])*timer[3]-90, tocolor( 255,50,50,200 ), tocolor( 255,50,50,200 ) )
			dxDrawImage ( (screenWidth-85), 238, 85, 85, "gui/timer_arrow.png", (360.0/timer[2])*timer[3] )
		end
	end

	local x,y,z = getElementPosition(localPlayer)
	local rx,ry,rz = getElementRotation(localPlayer)
	local heal_player = split(getElementHealth(localPlayer), ".")


	if isCursorShowing() then
		dxdrawtext ( x.." "..y.." "..z, 300.0, 40.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( rx.." "..ry.." "..rz, 300.0, 55.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( "skin "..getElementModel(localPlayer)..", interior "..getElementInterior(localPlayer)..", dimension "..getElementDimension(localPlayer), 300.0, 70.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

		if isCursorShowing() then
			local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
			dxdrawtext ( screenx*screenWidth..", "..screeny*screenHeight, screenx*screenWidth, screeny*screenHeight+15, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		end

		dxdrawtext ( (alcohol/100), screenWidth-width_need-30-30, height_need+(20+7.5)*0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( drugs, screenWidth-width_need-30-30, height_need+(20+7.5)*1, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( satiety, screenWidth-width_need-30-30, height_need+(20+7.5)*2, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( hygiene, screenWidth-width_need-30-30, height_need+(20+7.5)*3, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( sleep, screenWidth-width_need-30-30, height_need+(20+7.5)*4, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
	end


	for k,vehicle in pairs(getElementsByType("vehicle")) do--отображение скорости авто над машиной
		local xv,yv,zv = getElementPosition(vehicle)
		
		if isPointInCircle3D(x,y,z, xv,yv,zv, 20) then
			local coords = { getScreenFromWorldPosition( xv,yv,zv+1, 0, false ) }
			local plate = getVehiclePlateText(vehicle)

			if coords[1] and coords[2] then
				if getElementData(localPlayer, "speed_car_device_data") == 1 then
					local coords = { getScreenFromWorldPosition( xv,yv,zv+1.5, 0, false ) }
					local speed_table = split(getSpeed(vehicle), ".")
					local dimensions = dxGetTextWidth ( speed_table[1].." km/h", 1, m2font_dx1 )

					if coords[1] and coords[2] then
						if tonumber(speed_table[1]) >= max_speed then
							dxdrawtext ( speed_table[1].." km/h", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( red[1], red[2], red[3], 255 ), 1, m2font_dx1 )
						elseif tonumber(speed_table[1]) < max_speed then
							dxdrawtext ( speed_table[1].." km/h", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
						end
					end
				end

				local dimensions = dxGetTextWidth ( plate, 1, m2font_dx1 )
				if getElementDimension(vehicle) == 0 then
					dxdrawtext ( plate, coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			end
		end
	end

	if getElementData(localPlayer, "gps_device_data") == 1 then
		local coords = { getScreenFromWorldPosition( x,y,z, 0, false ) }
		local x_table = split(x, ".")
		local y_table = split(y, ".")
		local dimensions = dxGetTextWidth ( "[X  "..x_table[1]..", Y  "..y_table[1].."]", 1, m2font_dx1 )

		if coords[1] and coords[2] then
			dxdrawtext ( "[X  "..x_table[1]..", Y  "..y_table[1].."]", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
		end
	end
	

	if pos_timer == 1 then
		setCameraShakeLevel ( (alcohol/2) )

		for k,v in pairs(getElementData(resourceRoot, "house_pos")) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], getElementData(resourceRoot, "house_bussiness_radius")) then
				local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]+0.2, 0, false ) }
				if coords[1] and coords[2] then
					local dimensions = dxGetTextWidth ( "Дом #"..k.."", 1, m2font_dx1 )
					dxdrawtext ( "Дом #"..k.."", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )

					local dimensions = dxGetTextWidth ( "(Войти - ALT)", 1, m2font_dx1 )
					dxdrawtext ( "(Войти - ALT)", coords[1]-(dimensions/2), coords[2]+15, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			end
		end


		for k,v in pairs(getElementData(resourceRoot, "business_pos")) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], getElementData(resourceRoot, "house_bussiness_radius")) then	
				local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]+0.2, 0, false ) }
				if coords[1] and coords[2] then
					local dimensions = dxGetTextWidth ( "Бизнес #"..k.."", 1, m2font_dx1 )
					dxdrawtext ( "Бизнес #"..k.."", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )

					local dimensions = dxGetTextWidth ( "(Войти - ALT, Разгрузить товар - E, Меню - X)", 1, m2font_dx1 )
					dxdrawtext ( "(Войти - ALT, Разгрузить товар - E, Меню - X)", coords[1]-(dimensions/2), coords[2]+15, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			end
		end


		for k,v in pairs(getElementData(resourceRoot, "interior_job")) do
			if isPointInCircle3D(x,y,z, v[6],v[7],v[8], v[12]) then				
				local coords = { getScreenFromWorldPosition( v[6],v[7],v[8]+0.2, 0, false ) }
				if coords[1] and coords[2] then
					local dimensions = dxGetTextWidth ( "Здание", 1, m2font_dx1 )
					dxdrawtext ( "Здание", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )

					local dimensions = dxGetTextWidth ( "(Войти - ALT"..v[11]..")", 1, m2font_dx1 )
					dxdrawtext ( "(Войти - ALT"..v[11]..")", coords[1]-(dimensions/2), coords[2]+15, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			end
		end
	end


	for k,v in pairs(text_3d) do--отображение 3д надписей
		local area = isPointInCircle3D( x, y, z, v[1], v[2], v[3], v[4] )

		if area then
			local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]+0.2, 0, false ) }
			if coords[1] and coords[2] then
				local dimensions = dxGetTextWidth ( v[5], 1, m2font_dx1 )
				dxdrawtext ( v[5], coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
			end
		end
	end


	if gui_2dtext then--отображение инфы
		local width,height = guiGetPosition ( stats_window, false )
		local x,y = guiGetPosition ( tabPanel, false )
		y = y+24
		if info1_png ~= 0 then

			if info1_png == 6 and info2_png ~= 0 and getVehicleNameFromPlate( info2_png ) then
				local dimensions = dxGetTextWidth ( info_png[info1_png][1].." "..info2_png.." ("..getVehicleNameFromPlate( info2_png )..") "..info_png[info1_png][2], 1, m2font_dx1 )
				dxDrawText ( info_png[info1_png][1].." "..info2_png.." ("..getVehicleNameFromPlate( info2_png )..") "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2)+1, height+gui_pos_y+y+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, m2font_dx1, "left", "top", false, false, true )
				dxDrawText ( info_png[info1_png][1].." "..info2_png.." ("..getVehicleNameFromPlate( info2_png )..") "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1, "left", "top", false, false, true )
			else
				local dimensions = dxGetTextWidth ( info_png[info1_png][1].." "..split(info2_png,".")[1].." "..info_png[info1_png][2], 1, m2font_dx1 )
				dxDrawText ( info_png[info1_png][1].." "..split(info2_png,".")[1].." "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2)+1, height+gui_pos_y+y+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, m2font_dx1, "left", "top", false, false, true )
				dxDrawText ( info_png[info1_png][1].." "..split(info2_png,".")[1].." "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1, "left", "top", false, false, true )
			end
			
			if debuginfo then
				local dimensions = dxGetTextWidth ( "ID предмета "..info1_png, 1, m2font_dx1 )

				dxDrawText ( "ID предмета "..info1_png, ((width+gui_pos_x+x)+25)-(dimensions/2)+1, height+gui_pos_y+y+1+30, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, m2font_dx1, "left", "top", false, false, true )
				dxDrawText ( "ID предмета "..info1_png, ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y+30, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1, "left", "top", false, false, true )
			end
			
			if tab_player == guiGetSelectedTab(tabPanel) then
				local dimensions = dxGetTextWidth ( "(использовать ПКМ)", 1, m2font_dx1 )

				dxDrawText ( "(использовать ПКМ)", ((width+gui_pos_x+x)+25)-(dimensions/2)+1, height+gui_pos_y+y+1+15, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, m2font_dx1, "left", "top", false, false, true )
				dxDrawText ( "(использовать ПКМ)", ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y+15, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1, "left", "top", false, false, true )
			end
		end
	end


	if gui_selection and info_tab == guiGetSelectedTab(tabPanel) then--выделение картинки
		local width,height = guiGetPosition ( stats_window, false )
		local x,y = guiGetPosition ( tabPanel, false )
		y = y+24
		dxDrawRectangle( width+gui_selection_pos_x+x, height+gui_selection_pos_y+y, 50.0, 50.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 100 ), true )
	end


	for i,v in pairs(getElementData(resourceRoot, "harvest")) do--отображение растений на земле
		local area2 = isPointInCircle3D( v[1][1], v[1][2], v[1][3], x, y, z, 2 )
		if area2 then
			local coords = { getScreenFromWorldPosition( v[1][1], v[1][2], v[1][3]-1, 0, false ) }
			if coords[1] and coords[2] then
				local dimensions = dxGetTextWidth ( info_png[v[9]][1], 1, m2font_dx1 )
				dxdrawtext ( info_png[v[9]][1], coords[1]-(dimensions/2), coords[2]-15*3, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )

				if v[8] then
					local dimensions = dxGetTextWidth ( "полито", 1, m2font_dx1 )
					dxdrawtext ( "полито", coords[1]-(dimensions/2), coords[2]-15*2, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				else
					local dimensions = dxGetTextWidth ( "не полито", 1, m2font_dx1 )
					dxdrawtext ( "не полито", coords[1]-(dimensions/2), coords[2]-15*2, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end

				if v[2] > 0 then
					local dimensions = dxGetTextWidth ( "созреет через "..v[2].." мин", 1, m2font_dx1 )
					dxdrawtext ( "созреет через "..v[2].." мин", coords[1]-(dimensions/2), coords[2]-15*1, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				elseif v[2] == 0 then
					local dimensions = dxGetTextWidth ( "исчезнет через "..v[3].." мин", 1, m2font_dx1 )
					dxdrawtext ( "исчезнет через "..v[3].." мин", coords[1]-(dimensions/2), coords[2]-15*1, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			
				local dimensions = dxGetTextWidth ( v[5], 1, m2font_dx1 )
				dxdrawtext ( v[5], coords[1]-(dimensions/2), coords[2]-15*0, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
			end
		end
	end


	for i,v in pairs(getElementData(resourceRoot, "earth_data")) do--отображение предметов на земле
		local area = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 20 )
		local area2 = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 10 )
		local dist = getDistanceBetweenPoints3D(v[1], v[2], v[3]-1, x,y,z)

		if area then
			local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]-1, 0, false ) }
			if coords[1] and coords[2] then
				dxDrawImage ( coords[1]-((57-dist*2.85)/2), coords[2], 57-dist*2.85, 57-dist*2.85, image[ v[4] ], 0, 0,0, tocolor(255,255,255,255-dist*12.75) )
			end
		end

		if area2 then
			local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]-1+0.2, 0, false ) }
			if coords[1] and coords[2] then
				local dimensions = dxGetTextWidth ( "Нажмите E", 1-dist*0.05, m2font_dx1 )
				dxdrawtext ( "Нажмите E", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1-dist*0.05, m2font_dx1 )
			end
		end
	end


	if pos_timer == 1 then
		for k,player in pairs(getElementsByType("player")) do
			local x1,y1,z1 = getElementPosition(player)
			local coords = { getScreenFromWorldPosition( x1,y1,z1+1.0, 0, false ) }

			if player ~= localPlayer and coords[1] and coords[2] and isLineOfSightClear(x, y, z, x1,y1,z1) then
				if isPointInCircle3D( x, y, z, x1,y1,z1, 10 ) and getElementData(player, "drugs_data") >= getElementData(resourceRoot, "zakon_drugs") then
					local dimensions = dxGetTextWidth ( "*эффект наркотиков*", 1, m2font_dx1 )
					dxdrawtext ( "*эффект наркотиков*", coords[1]-(dimensions/2), coords[2]-15*4, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end

				if isPointInCircle3D( x, y, z, x1,y1,z1, 10 ) and (getElementData(player, "alcohol_data")/100) >= getElementData(resourceRoot, "zakon_alcohol") then
					local dimensions = dxGetTextWidth ( "*эффект алкоголя*", 1, m2font_dx1 )
					dxdrawtext ( "*эффект алкоголя*", coords[1]-(dimensions/2), coords[2]-15*3, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end

				if isPointInCircle3D( x, y, z, x1,y1,z1, 10 ) and getElementData(player, "is_chat_open") == 1 then
					local dimensions = dxGetTextWidth ( "печатает...", 1, m2font_dx1 )
					dxdrawtext ( "печатает...", coords[1]-(dimensions/2), coords[2]-15*2, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end

				if isPointInCircle3D( x, y, z, x1,y1,z1, 10 ) and getElementData(player, "afk") ~= 0 and getElementData(player, "afk") then
					local dimensions = dxGetTextWidth ( "[AFK] "..getElementData(player, "afk").." секунд", 1, m2font_dx1 )
					dxdrawtext ( "[AFK] "..getElementData(player, "afk").." секунд", coords[1]-(dimensions/2), coords[2]-15*2, 0.0, 0.0, tocolor ( purple[1], purple[2], purple[3], 255 ), 1, m2font_dx1 )
				end

				if isPointInCircle3D( x, y, z, x1,y1,z1, 35 ) and getElementData(player, "crimes_data") ~= 0 then
					local dimensions = dxGetTextWidth ( "WANTED", 1, m2font_dx1 )
					dxdrawtext ( "WANTED", coords[1]-(dimensions/2), coords[2]-15*1, 0.0, 0.0, tocolor ( red[1], red[2], red[3], 255 ), 1, m2font_dx1 )
				end

				if isPointInCircle3D( x, y, z, x1,y1,z1, 35 ) then
					local dimensions = dxGetTextWidth ( getPlayerName(player).."("..getElementData(player, "player_id")[1]..")", 1, m2font_dx1 )
					local r,g,b = getPlayerNametagColor ( player )
					dxdrawtext ( getPlayerName(player).."("..getElementData(player, "player_id")[1]..")", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( r,g,b, 255 ), 1, m2font_dx1 )
				end
			end
		end
	end
end
addEventHandler ( "onClientRender", root, createText )

local number_business = 0
local tune_business = false
local int_upgrades = 0
function tune_window_create (number)--создание окна тюнинга
	number_business = number
	local vehicleid = getPlayerVehicle(localPlayer)

	local width = 355+70
	local height = 225.0+(16.0*1)+10
	tune_business = true
	gui_window = m2gui_window( (screenWidth/2)-(width/2), 20, width, height, number_business.." бизнес, Автомастерская", false, false )
	local tabPanel = guiCreateTabPanel ( 10.0, 20.0, width, height, false, gui_window )
	local tab_shop = guiCreateTab( "Детали", tabPanel )

	local shoplist = guiCreateGridList(0, 0, 405, 170, false, tab_shop)
	local column_width1 = 0.7
	local column_width2 = 0.2

	guiGridListAddColumn(shoplist, "Товары", column_width1)
	guiGridListAddColumn(shoplist, "Цена", column_width2)
	for k,v in pairs(getElementData ( resourceRoot, "repair_shop" )) do
		guiGridListAddRow(shoplist, v[1], (v[3]*100).."%")
	end

	local buy_subject = m2gui_button( 10, 175, "Купить", false, tab_shop )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

		triggerServerEvent( "event_buy_subject_fun", resourceRoot, localPlayer, text, number_business, 5 )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

	if vehicleid then
		local tab_tune = guiCreateTab( "Тюнинг", tabPanel )
		local upgrades_table = guiCreateComboBox ( 10, 10, 386, 140, "Апгрейды", false, tab_tune )
		for i=1000, 1193 do
			if i ~= 1086 and i ~= 1087 then
				guiComboBoxAddItem( upgrades_table, upgrades_car_table[i].."#"..i )
			end
		end

		local tune_text = m2gui_label ( 66, 40, 10, 20, "X", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local tune_x_edit = guiCreateEdit ( 10, 60, 122, 20, "0", false, tab_tune )

		local tune_text = m2gui_label ( 196, 40, 10, 20, "Y", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local tune_y_edit = guiCreateEdit ( 142, 60, 122, 20, "0", false, tab_tune )

		local tune_text = m2gui_label ( 330, 40, 10, 20, "Z", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local tune_z_edit = guiCreateEdit ( 274, 60, 122, 20, "0", false, tab_tune )


		local tune_text = m2gui_label ( 61, 80, 20, 20, "RX", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local tune_rx_edit = guiCreateEdit ( 10, 100, 122, 20, "0", false, tab_tune )

		local tune_text = m2gui_label ( 191, 80, 20, 20, "RY", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local tune_ry_edit = guiCreateEdit ( 142, 100, 122, 20, "0", false, tab_tune )

		local tune_text = m2gui_label ( 325, 80, 20, 20, "RZ", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local tune_rz_edit = guiCreateEdit ( 274, 100, 122, 20, "0", false, tab_tune )


		local tune_text = m2gui_label ( 183, 120, 50, 20, "SCALE", false, tab_tune )
		guiSetFont( tune_text, m2font )
		local scale = guiCreateEdit ( 10, 140, 386, 20, "1", false, tab_tune )


		local tune_install_button,m2gui_width = m2gui_button( 10, 170, "Установить", false, tab_tune )
		local tune_delete_button,m2gui_width = m2gui_button( m2gui_width, 170, "Удалить всё", false, tab_tune )

		addEventHandler ( "onClientGUIComboBoxAccepted", upgrades_table,
		function ( comboBox )
			local item = guiComboBoxGetItemText(upgrades_table, guiComboBoxGetSelected(upgrades_table))
			for k,v in pairs(upgrades_car_table) do
				if item == v.."#"..k then
					if int_upgrades == 0 then
						int_upgrades = {k,createObject(k, 0,0,0, 0,0,0)}
						attachElements(int_upgrades[2], vehicleid, 0,0,0, 0,0,0)
					else
						int_upgrades[1] = k
						setElementModel(int_upgrades[2], k)
					end
					break
				end
			end
		end)

		addEventHandler("onClientGUIChanged", tune_x_edit, function(editBox) 
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local x = tonumber(guiGetText(editBox)) or 0
				setElementAttachedOffsets ( int_upgrades[2], x,y,z, rx,ry,rz)
			end
		end)

		addEventHandler("onClientGUIChanged", tune_y_edit, function(editBox) 
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local y = tonumber(guiGetText(editBox)) or 0
				setElementAttachedOffsets ( int_upgrades[2], x,y,z, rx,ry,rz)
			end
		end)

		addEventHandler("onClientGUIChanged", tune_z_edit, function(editBox) 
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local z = tonumber(guiGetText(editBox)) or 0
				setElementAttachedOffsets ( int_upgrades[2], x,y,z, rx,ry,rz)
			end
		end)

		addEventHandler("onClientGUIChanged", tune_rx_edit, function(editBox) 
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local rx = tonumber(guiGetText(editBox)) or 0
				setElementAttachedOffsets ( int_upgrades[2], x,y,z, rx,ry,rz)
			end
		end)

		addEventHandler("onClientGUIChanged", tune_ry_edit, function(editBox) 
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local ry = tonumber(guiGetText(editBox)) or 0
				setElementAttachedOffsets ( int_upgrades[2], x,y,z, rx,ry,rz)
			end
		end)

		addEventHandler("onClientGUIChanged", tune_rz_edit, function(editBox) 
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local rz = tonumber(guiGetText(editBox)) or 0
				setElementAttachedOffsets ( int_upgrades[2], x,y,z, rx,ry,rz)
			end
		end)

		addEventHandler("onClientGUIChanged", scale, function(editBox) 
			if int_upgrades ~= 0 then
				local sc = tonumber(guiGetText(editBox)) or 1
				setObjectScale(int_upgrades[2], sc)
			end
		end)

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			if int_upgrades ~= 0 then
				local x,y,z, rx,ry,rz = getElementAttachedOffsets ( int_upgrades[2] )
				local sc = tonumber(guiGetText(scale)) or 1
				triggerServerEvent( "event_addVehicleUpgrade", resourceRoot, vehicleid, {int_upgrades[1], x,y,z, rx,ry,rz, sc}, localPlayer, number_business )
			end
		end
		addEventHandler ( "onClientGUIClick", tune_install_button, complete, false )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			triggerServerEvent( "event_removeVehicleUpgrade", resourceRoot, vehicleid, localPlayer, number_business )
		end
		addEventHandler ( "onClientGUIClick", tune_delete_button, complete, false )
	end

	showCursor( true )

end
addEvent( "event_tune_create", true )
addEventHandler ( "event_tune_create", root, tune_window_create )


function shop_menu(number, value)--создание окна магазина
	number_business = number

	showCursor( true )

	if value == "pd" then
		local width = 400+10
		local height = 320.0+(16.0*1)+10
		gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Склад полиции", false )

		local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

		guiGridListAddColumn(shoplist, "Товары", 0.9)
		for k,v in pairs(getElementData ( resourceRoot, "weapon_cops" )) do
			guiGridListAddRow(shoplist, v[1])
		end

		for k,v in pairs(getElementData ( resourceRoot, "sub_cops" )) do
			guiGridListAddRow(shoplist, v[1])
		end

		local buy_subject = m2gui_button( 5, 320, "Взять", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", resourceRoot, localPlayer, text, number_business, value )
		end
		addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

		return
		
	elseif value == "mer" then
		local column_width1 = 0.7
		local column_width2 = 0.2

		local width = 400+10
		local height = 320.0+(16.0*1)+10
		gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Мэрия", false )

		local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

		guiGridListAddColumn(shoplist, "Услуги", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( resourceRoot, "mayoralty_shop" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

		local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", resourceRoot, localPlayer, text, number_business, value )
		end
		addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

		return

	elseif value == "giuseppe" then
		local column_width1 = 0.7
		local column_width2 = 0.2
		local width = 400+10
		local height = 320.0+(16.0*1)+10
		gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Черный рынок", false )

		local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( resourceRoot, "giuseppe" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

		local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", resourceRoot, localPlayer, text, number_business, value )
		end
		addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

		return
	end

	local width = 400+10
	local height = 320.0+(16.0*1)+10
	gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, number_business.." бизнес, "..getElementData(resourceRoot, "interior_business")[value][2], false )

	local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)
	local column_width1 = 0.7
	local column_width2 = 0.2

	local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

		triggerServerEvent( "event_buy_subject_fun", resourceRoot, localPlayer, text, number_business, value )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

	if value == 1 then
		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( resourceRoot, "weapon_shop" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

	elseif value == 2 then
		guiGridListAddColumn(shoplist, "Товары", 0.9)
		for k,v in pairs(skin) do
			guiGridListAddRow(shoplist, v)
		end

	elseif value == 3 then
		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( resourceRoot, "shop" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

	elseif value == 4 then
		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( resourceRoot, "gas" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end
	end
end
addEvent( "event_shop_menu", true )
addEventHandler ( "event_shop_menu", root, shop_menu )


function avto_bikes_menu()--создание окна машин

	showCursor( true )

	local vehicleIds = getElementData(resourceRoot, "cash_car")

	local width = 400+10
	local height = 320.0+(16.0*1)+10
	gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Автомобили и мотоциклы", false )

	local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

	guiGridListAddColumn(shoplist, "Название тс", 0.5)
	guiGridListAddColumn(shoplist, "Цена", 0.4)
	for k,v in pairs(vehicleIds) do
		guiGridListAddRow(shoplist, getVehicleNameFromModel(k), v[2])
	end

	local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
		
		if text == "" then
			sendMessage("[ERROR] Вы не выбрали т/с", red)
			return
		end

		triggerServerEvent( "event_buycar", resourceRoot, localPlayer, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_avto_bikes_menu", true )
addEventHandler ( "event_avto_bikes_menu", root, avto_bikes_menu )


function boats_menu()--создание окна машин

	showCursor( true )

	local vehicleIds = getElementData(resourceRoot, "cash_boats")

	local width = 400+10
	local height = 320.0+(16.0*1)+10
	gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Лодки", false )

	local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

	guiGridListAddColumn(shoplist, "Название тс", 0.5)
	guiGridListAddColumn(shoplist, "Цена", 0.4)
	for k,v in pairs(vehicleIds) do
		guiGridListAddRow(shoplist, getVehicleNameFromModel(k), v[2])
	end

	local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
		
		if text == "" then
			sendMessage("[ERROR] Вы не выбрали т/с", red)
			return
		end

		triggerServerEvent( "event_buycar", resourceRoot, localPlayer, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_boats_menu", true )
addEventHandler ( "event_boats_menu", root, boats_menu )


function helicopters_menu()--создание окна машин

	showCursor( true )

	local vehicleIds = getElementData(resourceRoot, "cash_helicopters")

	local width = 400+10
	local height = 320.0+(16.0*1)+10
	gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Вертолеты", false )

	local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

	guiGridListAddColumn(shoplist, "Название тс", 0.5)
	guiGridListAddColumn(shoplist, "Цена", 0.4)
	for k,v in pairs(vehicleIds) do
		guiGridListAddRow(shoplist, getVehicleNameFromModel(k), v[2])
	end

	local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
		
		if text == "" then
			sendMessage("[ERROR] Вы не выбрали т/с", red)
			return
		end

		triggerServerEvent( "event_buycar", resourceRoot, localPlayer, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_helicopters_menu", true )
addEventHandler ( "event_helicopters_menu", root, helicopters_menu )


function zamena_img()
--------------------------------------------------------------замена куда нажал 1 раз----------------------------------------------------------------------------
	if info_tab == tab_player then
		triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "player", info3_selection_1, info1, info2, getPlayerName(localPlayer) )

	elseif info_tab == tab_car then
		triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "car", info3_selection_1, info1, info2, plate )

	elseif info_tab == tab_house then
		triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "house", info3_selection_1, info1, info2, house )

	elseif info_tab == tab_box then
		triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "box", info3_selection_1, info1, info2, box )
	end
end

function inv_create ()--создание инв-ря
	local text_width = 50.0
	local text_height = 50.0

	local width = 380.0+10
	local height = 215.0+(25.0*2)+10.0+30

	stats_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "", false )

	tabPanel = guiCreateTabPanel ( 10.0, 20.0, 310.0+10+text_width, 215.0+10+text_height, false, stats_window )
	tab_player = guiCreateTab( "Инвентарь", tabPanel )

	showCursor( true )

	inv_slot_player[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_player[0][2]..".png", false, tab_player )
	inv_slot_player[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_player[1][2]..".png", false, tab_player )
	inv_slot_player[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_player[2][2]..".png", false, tab_player )
	inv_slot_player[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_player[3][2]..".png", false, tab_player )
	inv_slot_player[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_player[4][2]..".png", false, tab_player )
	inv_slot_player[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_player[5][2]..".png", false, tab_player )

	inv_slot_player[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_player[6][2]..".png", false, tab_player )
	inv_slot_player[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_player[7][2]..".png", false, tab_player )
	inv_slot_player[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_player[8][2]..".png", false, tab_player )
	inv_slot_player[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_player[9][2]..".png", false, tab_player )
	inv_slot_player[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_player[10][2]..".png", false, tab_player )
	inv_slot_player[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_player[11][2]..".png", false, tab_player )

	inv_slot_player[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_player[12][2]..".png", false, tab_player )
	inv_slot_player[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_player[13][2]..".png", false, tab_player )
	inv_slot_player[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_player[14][2]..".png", false, tab_player )
	inv_slot_player[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_player[15][2]..".png", false, tab_player )
	inv_slot_player[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_player[16][2]..".png", false, tab_player )
	inv_slot_player[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_player[17][2]..".png", false, tab_player )

	inv_slot_player[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_player[18][2]..".png", false, tab_player )
	inv_slot_player[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_player[19][2]..".png", false, tab_player )
	inv_slot_player[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_player[20][2]..".png", false, tab_player )
	inv_slot_player[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_player[21][2]..".png", false, tab_player )
	inv_slot_player[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_player[22][2]..".png", false, tab_player )
	inv_slot_player[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_player[23][2]..".png", false, tab_player )

	for i=0,max_inv do
		function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
			local x,y = guiGetPosition ( inv_slot_player[i][1], false )

			info3 = i
			info1 = inv_slot_player[i][2]
			info2 = inv_slot_player[i][3]

			if lmb == 0 then
				for k,v in pairs(no_select_subject) do 
					if v == info1 then
						return
					end
				end

				gui_selection = true
				info_tab = tab_player
				gui_selection_pos_x = x
				gui_selection_pos_y = y
				info3_selection_1 = info3
				info1_selection_1 = info1
				info2_selection_1 = info2
				lmb = 1
			else
				--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
				--if inv_slot_player[info3][2] ~= 0 then

					
					for k,v in pairs(no_change_subject) do
						if v == info1 then
							return
						end
					end

					--[[info_tab = tab_player
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection_1 = info3
					info1_selection_1 = info1
					info2_selection_1 = info2
					return
				end]]

				triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "player", info3, info1_selection_1, info2_selection_1, getPlayerName(localPlayer) )

				zamena_img()

				gui_selection = false
				info_tab = nil
				lmb = 0
			end

			--sendMessage(info3.." "..info1.." "..info2)
		end
		addEventHandler ( "onClientGUIClick", inv_slot_player[i][1], outputEditBox, false )
	end

	for i=0,max_inv do
		function outputEditBox ( absoluteX, absoluteY, gui )--наведение на картинки в инв-ре
			gui_2dtext = true
			local x,y = guiGetPosition ( inv_slot_player[i][1], false )
			gui_pos_x = x
			gui_pos_y = y
			info1_png = inv_slot_player[i][2]
			info2_png = inv_slot_player[i][3]
		end
		addEventHandler( "onClientMouseEnter", inv_slot_player[i][1], outputEditBox, false )
	end

	if plate ~= "" then
		tab_car = guiCreateTab( "Т/С "..plate, tabPanel )
		inv_slot_car[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_car[0][2]..".png", false, tab_car )
		inv_slot_car[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_car[1][2]..".png", false, tab_car )
		inv_slot_car[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_car[2][2]..".png", false, tab_car )
		inv_slot_car[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_car[3][2]..".png", false, tab_car )
		inv_slot_car[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_car[4][2]..".png", false, tab_car )
		inv_slot_car[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_car[5][2]..".png", false, tab_car )

		inv_slot_car[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_car[6][2]..".png", false, tab_car )
		inv_slot_car[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_car[7][2]..".png", false, tab_car )
		inv_slot_car[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_car[8][2]..".png", false, tab_car )
		inv_slot_car[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_car[9][2]..".png", false, tab_car )
		inv_slot_car[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_car[10][2]..".png", false, tab_car )
		inv_slot_car[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_car[11][2]..".png", false, tab_car )

		inv_slot_car[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_car[12][2]..".png", false, tab_car )
		inv_slot_car[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_car[13][2]..".png", false, tab_car )
		inv_slot_car[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_car[14][2]..".png", false, tab_car )
		inv_slot_car[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_car[15][2]..".png", false, tab_car )
		inv_slot_car[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_car[16][2]..".png", false, tab_car )
		inv_slot_car[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_car[17][2]..".png", false, tab_car )

		inv_slot_car[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_car[18][2]..".png", false, tab_car )
		inv_slot_car[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_car[19][2]..".png", false, tab_car )
		inv_slot_car[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_car[20][2]..".png", false, tab_car )
		inv_slot_car[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_car[21][2]..".png", false, tab_car )
		inv_slot_car[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_car[22][2]..".png", false, tab_car )
		inv_slot_car[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_car[23][2]..".png", false, tab_car )

		function car_trunk( tab )
			if tab == tab_car then
				triggerServerEvent("event_setVehicleDoorOpenRatio_fun", resourceRoot, localPlayer, 1)
			end
		end
		addEventHandler( "onClientGUITabSwitched", tab_car, car_trunk, false )

		for i=0,max_inv do
			function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
				local x,y = guiGetPosition ( inv_slot_car[i][1], false )

				info3 = i
				info1 = inv_slot_car[i][2]
				info2 = inv_slot_car[i][3]

				if lmb == 0 then
					for k,v in pairs(no_select_subject) do 
						if v == info1 then
							return
						end
					end

					gui_selection = true
					info_tab = tab_car
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection_1 = info3
					info1_selection_1 = info1
					info2_selection_1 = info2
					lmb = 1
				else
					--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
					--if inv_slot_car[info3][2] ~= 0 then
						
						
						for k,v in pairs(no_change_subject) do 
							if v == info1 then
								return
							end
						end
						
						--[[info_tab = tab_car
						gui_selection_pos_x = x
						gui_selection_pos_y = y
						info3_selection_1 = info3
						info1_selection_1 = info1
						info2_selection_1 = info2
						return
					end]]

					triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "car", info3, info1_selection_1, info2_selection_1, plate )

					zamena_img()

					gui_selection = false
					info_tab = nil
					lmb = 0
				end

				--sendMessage(info3.." "..info1.." "..info2)
			end
			addEventHandler ( "onClientGUIClick", inv_slot_car[i][1], outputEditBox, false )
		end

		for i=0,max_inv do
			function outputEditBox ( absoluteX, absoluteY, gui )--наведение на картинки в инв-ре
				gui_2dtext = true
				local x,y = guiGetPosition ( inv_slot_car[i][1], false )
				gui_pos_x = x
				gui_pos_y = y
				info1_png = inv_slot_car[i][2]
				info2_png = inv_slot_car[i][3]
			end
			addEventHandler( "onClientMouseEnter", inv_slot_car[i][1], outputEditBox, false )
		end
	end

	if house ~= "" then
		tab_house = guiCreateTab( "Дом "..house, tabPanel )
		inv_slot_house[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_house[0][2]..".png", false, tab_house )
		inv_slot_house[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_house[1][2]..".png", false, tab_house )
		inv_slot_house[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_house[2][2]..".png", false, tab_house )
		inv_slot_house[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_house[3][2]..".png", false, tab_house )
		inv_slot_house[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_house[4][2]..".png", false, tab_house )
		inv_slot_house[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_house[5][2]..".png", false, tab_house )

		inv_slot_house[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_house[6][2]..".png", false, tab_house )
		inv_slot_house[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_house[7][2]..".png", false, tab_house )
		inv_slot_house[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_house[8][2]..".png", false, tab_house )
		inv_slot_house[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_house[9][2]..".png", false, tab_house )
		inv_slot_house[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_house[10][2]..".png", false, tab_house )
		inv_slot_house[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_house[11][2]..".png", false, tab_house )

		inv_slot_house[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_house[12][2]..".png", false, tab_house )
		inv_slot_house[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_house[13][2]..".png", false, tab_house )
		inv_slot_house[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_house[14][2]..".png", false, tab_house )
		inv_slot_house[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_house[15][2]..".png", false, tab_house )
		inv_slot_house[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_house[16][2]..".png", false, tab_house )
		inv_slot_house[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_house[17][2]..".png", false, tab_house )

		inv_slot_house[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_house[18][2]..".png", false, tab_house )
		inv_slot_house[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_house[19][2]..".png", false, tab_house )
		inv_slot_house[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_house[20][2]..".png", false, tab_house )
		inv_slot_house[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_house[21][2]..".png", false, tab_house )
		inv_slot_house[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_house[22][2]..".png", false, tab_house )
		inv_slot_house[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_house[23][2]..".png", false, tab_house )

		for i=0,max_inv do
			function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
				local x,y = guiGetPosition ( inv_slot_house[i][1], false )

				info3 = i
				info1 = inv_slot_house[i][2]
				info2 = inv_slot_house[i][3]

				if lmb == 0 then
					for k,v in pairs(no_select_subject) do 
						if v == info1 then
							return
						end
					end

					gui_selection = true
					info_tab = tab_house
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection_1 = info3
					info1_selection_1 = info1
					info2_selection_1 = info2
					lmb = 1
				else
					--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
					--if inv_slot_house[info3][2] ~= 0 then
						
						
						for k,v in pairs(no_change_subject) do 
							if v == info1 then
								return
							end
						end
						
						--[[info_tab = tab_house
						gui_selection_pos_x = x
						gui_selection_pos_y = y
						info3_selection_1 = info3
						info1_selection_1 = info1
						info2_selection_1 = info2
						return
					end]]

					triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "house", info3, info1_selection_1, info2_selection_1, house )

					zamena_img()

					gui_selection = false
					info_tab = nil
					lmb = 0
				end

				--sendMessage(info3.." "..info1.." "..info2)
			end
			addEventHandler ( "onClientGUIClick", inv_slot_house[i][1], outputEditBox, false )
		end

		for i=0,max_inv do
			function outputEditBox ( absoluteX, absoluteY, gui )--наведение на картинки в инв-ре
				gui_2dtext = true
				local x,y = guiGetPosition ( inv_slot_house[i][1], false )
				gui_pos_x = x
				gui_pos_y = y
				info1_png = inv_slot_house[i][2]
				info2_png = inv_slot_house[i][3]
			end
			addEventHandler( "onClientMouseEnter", inv_slot_house[i][1], outputEditBox, false )
		end
	end

	if box ~= "" then
		tab_box = guiCreateTab( "Ящик "..box, tabPanel )
		inv_slot_box[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_box[0][2]..".png", false, tab_box )
		inv_slot_box[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_box[1][2]..".png", false, tab_box )
		inv_slot_box[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_box[2][2]..".png", false, tab_box )
		inv_slot_box[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_box[3][2]..".png", false, tab_box )
		inv_slot_box[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_box[4][2]..".png", false, tab_box )
		inv_slot_box[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, "image_inventory/"..inv_slot_box[5][2]..".png", false, tab_box )

		inv_slot_box[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_box[6][2]..".png", false, tab_box )
		inv_slot_box[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_box[7][2]..".png", false, tab_box )
		inv_slot_box[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_box[8][2]..".png", false, tab_box )
		inv_slot_box[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_box[9][2]..".png", false, tab_box )
		inv_slot_box[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_box[10][2]..".png", false, tab_box )
		inv_slot_box[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, "image_inventory/"..inv_slot_box[11][2]..".png", false, tab_box )

		inv_slot_box[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_box[12][2]..".png", false, tab_box )
		inv_slot_box[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_box[13][2]..".png", false, tab_box )
		inv_slot_box[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_box[14][2]..".png", false, tab_box )
		inv_slot_box[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_box[15][2]..".png", false, tab_box )
		inv_slot_box[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_box[16][2]..".png", false, tab_box )
		inv_slot_box[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, "image_inventory/"..inv_slot_box[17][2]..".png", false, tab_box )

		inv_slot_box[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_box[18][2]..".png", false, tab_box )
		inv_slot_box[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_box[19][2]..".png", false, tab_box )
		inv_slot_box[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_box[20][2]..".png", false, tab_box )
		inv_slot_box[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_box[21][2]..".png", false, tab_box )
		inv_slot_box[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_box[22][2]..".png", false, tab_box )
		inv_slot_box[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, "image_inventory/"..inv_slot_box[23][2]..".png", false, tab_box )

		for i=0,max_inv do
			function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
				local x,y = guiGetPosition ( inv_slot_box[i][1], false )

				info3 = i
				info1 = inv_slot_box[i][2]
				info2 = inv_slot_box[i][3]

				if lmb == 0 then
					for k,v in pairs(no_select_subject) do 
						if v == info1 then
							return
						end
					end

					gui_selection = true
					info_tab = tab_box
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection_1 = info3
					info1_selection_1 = info1
					info2_selection_1 = info2
					lmb = 1
				else
					--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
					--if inv_slot_box[info3][2] ~= 0 then
						
						
						for k,v in pairs(no_change_subject) do 
							if v == info1 then
								return
							end
						end
						
						--[[info_tab = tab_box
						gui_selection_pos_x = x
						gui_selection_pos_y = y
						info3_selection_1 = info3
						info1_selection_1 = info1
						info2_selection_1 = info2
						return
					end]]

					triggerServerEvent( "event_inv_server_load", resourceRoot, localPlayer, "box", info3, info1_selection_1, info2_selection_1, box )

					zamena_img()

					gui_selection = false
					info_tab = nil
					lmb = 0
				end

				--sendMessage(info3.." "..info1.." "..info2)
			end
			addEventHandler ( "onClientGUIClick", inv_slot_box[i][1], outputEditBox, false )
		end

		for i=0,max_inv do
			function outputEditBox ( absoluteX, absoluteY, gui )--наведение на картинки в инв-ре
				gui_2dtext = true
				local x,y = guiGetPosition ( inv_slot_box[i][1], false )
				gui_pos_x = x
				gui_pos_y = y
				info1_png = inv_slot_box[i][2]
				info2_png = inv_slot_box[i][3]
			end
			addEventHandler( "onClientMouseEnter", inv_slot_box[i][1], outputEditBox, false )
		end
	end

	---------------------кнопки--------------------------------------------------
	for i=0,max_inv do
		function use_subject ( button, state, absoluteX, absoluteY )--использование предмета
			if button == "right" then

				for k,v in pairs(no_use_subject) do 
					if v == info1 then
						return
					end
				end

				if tab_player == guiGetSelectedTab(tabPanel) then
					triggerServerEvent( "event_use_inv", resourceRoot, localPlayer, "player", info3, info1, info2 )
				end

				gui_selection = false
				info_tab = nil
				info1 = -1
				info2 = -1
				info3 = -1
				lmb = 0
			end
		end
		addEventHandler( "onClientGUIClick", inv_slot_player[i][1], use_subject, false )
	end

	function throw_earth ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )--выброс предмета
		if lmb == 1 then
			local x,y = guiGetPosition ( stats_window, false )

			if absoluteX < x or absoluteX > (x+width) or absoluteY < y or absoluteY > (y+height) then
				if tab_player == info_tab then
					triggerServerEvent( "event_throw_earth_server", resourceRoot, localPlayer, "player", info3, info1, info2, getPlayerName ( localPlayer ) )

				elseif tab_car == info_tab then
					local vehicleid = getPlayerVehicle(localPlayer)

					if vehicleid then
						triggerServerEvent( "event_throw_earth_server", resourceRoot, localPlayer, "car", info3, info1, info2, plate )
					end

				elseif tab_house == info_tab then
					triggerServerEvent( "event_throw_earth_server", resourceRoot, localPlayer, "house", info3, info1, info2, house )

				elseif tab_box == info_tab then
					triggerServerEvent( "event_throw_earth_server", resourceRoot, localPlayer, "box", info3, info1, info2, box )
				end

				gui_selection = false
				info_tab = nil
				info1 = -1
				info2 = -1
				info3 = -1
				lmb = 0
			end
		end
	end
	addEventHandler ( "onClientClick", root, throw_earth )

end
addEvent( "event_inv_create", true )
addEventHandler ( "event_inv_create", root, inv_create )

function inv_delet ()--удаление инв-ря
	if stats_window then
		showCursor( false )

		for i=0,max_inv do
			inv_slot_player[i] = {0,0,0}
			inv_slot_car[i] = {0,0,0}
			inv_slot_house[i] = {0,0,0}
			inv_slot_box[i] = {0,0,0}
		end

		house = ""
		box = ""

		gui_2dtext = false
		gui_pos_x = 0
		gui_pos_y = 0
		info1_png = -1
		info2_png = -1

		gui_selection = false
		gui_selection_pos_x = 0
		gui_selection_pos_y = 0
		info3_selection_1 = -1
		info1_selection_1 = -1
		info2_selection_1 = -1

		info1 = -1
		info2 = -1
		info3 = -1

		info_tab = nil
		tab_car = nil
		tab_house = nil
		lmb = 0

		destroyElement(stats_window)

		triggerServerEvent("event_setVehicleDoorOpenRatio_fun", resourceRoot, localPlayer, 0)

		stats_window = nil
	end
end
addEvent( "event_inv_delet", true )
addEventHandler ( "event_inv_delet", root, inv_delet )

function tune_close ( button, state, absoluteX, absoluteY )--закрытие окна
local vehicleid = getPlayerVehicle(localPlayer)

	if gui_window then
		destroyElement(gui_window)

		gui_window = nil
		showCursor( false )

		if tune_business then
			if int_upgrades ~= 0 then
				destroyElement(int_upgrades[2])
			end

			int_upgrades = 0
			tune_business = false
		end
	end

	triggerEvent("event_close_tablet", resourceRoot)
end
addEvent( "event_gui_delet", true )
addEventHandler ( "event_gui_delet", root, tune_close )

function inv_load (value, id3, id1, id2)--загрузка инв-ря
	if value == "player" then
		inv_slot_player[id3][2] = id1
		inv_slot_player[id3][3] = id2
	elseif value == "car" then
		inv_slot_car[id3][2] = id1
		inv_slot_car[id3][3] = id2
	elseif value == "house" then
		inv_slot_house[id3][2] = id1
		inv_slot_house[id3][3] = id2
	elseif value == "box" then
		inv_slot_box[id3][2] = id1
		inv_slot_box[id3][3] = id2
	end
end
addEvent( "event_inv_load", true )
addEventHandler ( "event_inv_load", root, inv_load )

function tab_load (value, text)--загрузка надписей в табе
	if value == "car" then

		if text == "" and tab_car then
			destroyElement(tab_car)
		end

		plate = text
		gui_selection = false
		info_tab = nil
		info1 = -1
		info2 = -1
		info3 = -1
		tab_car = nil
		lmb = 0
	elseif value == "house" then

		if text == "" and tab_house then
			destroyElement(tab_house)
		end

		house = text
		gui_selection = false
		info_tab = nil
		info1 = -1
		info2 = -1
		info3 = -1
		tab_house = nil
		lmb = 0
	elseif value == "box" then

		if text == "" and tab_box then
			destroyElement(tab_box)
		end

		box = text
		gui_selection = false
		info_tab = nil
		info1 = -1
		info2 = -1
		info3 = -1
		tab_box = nil
		lmb = 0
	end
end
addEvent( "event_tab_load", true )
addEventHandler ( "event_tab_load", root, tab_load )

function change_image (value, id3, filename)--замена картинок в инв-ре
	if value == "player" then
		guiStaticImageLoadImage ( inv_slot_player[id3][1], "image_inventory/"..filename..".png" )
	elseif value == "car" then
		guiStaticImageLoadImage ( inv_slot_car[id3][1], "image_inventory/"..filename..".png" )
	elseif value == "house" then
		guiStaticImageLoadImage ( inv_slot_house[id3][1], "image_inventory/"..filename..".png" )
	elseif value == "box" then
		guiStaticImageLoadImage ( inv_slot_box[id3][1], "image_inventory/"..filename..".png" )
	end
end
addEvent( "event_change_image", true )
addEventHandler ( "event_change_image", root, change_image )

addEventHandler("onClientMouseLeave", root,--покидание картинок в инв-ре
function(absoluteX, absoluteY, gui)
	gui_2dtext = false
	gui_pos_x = 0
	gui_pos_y = 0
	info1_png = -1
	info2_png = -1
end)

function showcursor_b (key, keyState)
	if keyState == "down" then
		showCursor( not isCursorShowing () )
	end
end

function toggleNOS( key, state )
	local vehicleid = getPlayerVehicle(localPlayer)

	if vehicleid then
		if getElementData(vehicleid, "tune_car") ~= "0" and getElementData(vehicleid, "tune_car") then
			for k,v in pairs(split(getElementData(vehicleid, "tune_car"), ",")) do
				local upgrade = split(v, ":")
				upgrade = tonumber(upgrade[1])
				if (upgrade == 1008 or upgrade == 1009 or upgrade == 1010) then
					addVehicleUpgrade( vehicleid, upgrade )
					break
				end
			end
		end
	end
end

function showdebuginfo_b (key, keyState)
	if keyState == "down" then
		--debuginfo = not debuginfo
		hud = not hud
		setPlayerHudComponentVisible ( "ammo", hud )
		setPlayerHudComponentVisible ( "clock", hud )
		setPlayerHudComponentVisible ( "weapon", hud )
		setElementData(localPlayer, "radar_visible", hud)
		showChat(hud)
	end
end

local addCommandHandler_marker = 0
addCommandHandler ( "marker",
function ( cmd, x,y )
	local playername = getPlayerName ( localPlayer )
	local x,y = tonumber(x),tonumber(y)

	if not x or not y then
		sendMessage("[ERROR] /"..cmd.." [x координата] [y координата]", red)
		return
	end

	if addCommandHandler_marker == 0 then
		addCommandHandler_marker = createBlip ( x,y,0, 41, 4, blue[1], blue[2], blue[3], 255, 0, 16383.0 )
	else
		destroyElement(addCommandHandler_marker)
		addCommandHandler_marker = 0
	end
end)
