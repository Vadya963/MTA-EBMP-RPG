local screenWidth, screenHeight = guiGetScreenSize ( )
local m2font = guiCreateFont( "gui/m2font.ttf", 9 )
local m2font_dx = dxCreateFont ( "gui/m2font.ttf", 9 )--default-bold
local m2font_dx1 = "default-bold"--dxCreateFont ( "gui/m2font.ttf", 10 )
setDevelopmentMode ( true )
local debuginfo = false
local car_spawn_value = 0
local hud = true
local playerid = 0

addEventHandler( "onClientResourceStart", getRootElement( ),
function ( startedRes )
	if car_spawn_value == 0 then
		car_spawn_value = 1

		bindKey ( "F1", "down", showcursor_b )
		bindKey ( "F2", "down", showdebuginfo_b )
		bindKey ( "F3", "down", menu_mafia_2 )
		bindKey ( "F11", "down", showdebuginfo_b )
	end
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
	[32] = {"шеврон Капитан", "шт"},
	[33] = {"шеврон Шефа полиции", "шт"},
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
	[44] = {"админский жетон", "шт"},
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
}
local info1_png = -1 --номер картинки
local info2_png = -1 --значение картинки

-----------эвенты------------------------------------------------------------------------
function random(min, max)
	--math.randomseed(getTickCount())
	return math.random(min, max)
end

function playerDamage_text ( attacker, weapon, bodypart, loss )--получение урона
	local ped = source

	for k,v in pairs(getElementData(playerid, "no_ped_damage")[2]) do
		if v == ped then
			cancelEvent()
			break
		end
	end
end
addEventHandler ( "onClientPedDamage", getRootElement(), playerDamage_text )

function setPedOxygenLevel_fun ()--кислородный балон
	setTimer(function()
		setPedOxygenLevel ( playerid, 4000 )
		sendMessage("Кислород пополнился", yellow )
	end, 38000, 8)
end
addEvent( "event_setPedOxygenLevel_fun", true )
addEventHandler ( "event_setPedOxygenLevel_fun", getRootElement(), setPedOxygenLevel_fun )

function setPedAimTarget_fun (ped, x,y,z)--аим педа
	setPedAimTarget ( ped, x, y, z )
end
addEvent( "event_setPedAimTarget_fun", true )
addEventHandler ( "event_setPedAimTarget_fun", getRootElement(), setPedAimTarget_fun )

function setPedControlState_fun (ped, control, state)--контроль педа
	setPedControlState ( ped, control, state )
end
addEvent( "event_setPedControlState_fun", true )
addEventHandler ( "event_setPedControlState_fun", getRootElement(), setPedControlState_fun )

function givePedWeapon_fun (ped, weapon, ammo, setAsCurrent)--выдать оружие педу
	givePedWeapon ( ped, weapon, ammo, setAsCurrent )
end
addEvent( "event_givePedWeapon_fun", true )
addEventHandler ( "event_givePedWeapon_fun", getRootElement(), givePedWeapon_fun )

function createFire_fun (x,y,z, size, radius, count)--создание огня
	local r1,r2 = random(radius*-1,radius),random(radius*-1,radius)
	for i=1,count do
		createFire(x+r1, y+r2, z, size)
	end
end
addEvent( "event_createFire", true )
addEventHandler ( "event_createFire", getRootElement(), createFire_fun )

function extinguishFire_fun (x,y,z, r)--тушение огня
	extinguishFire(x,y,z, r)
end
addEvent( "event_extinguishFire", true )
addEventHandler ( "event_extinguishFire", getRootElement(), extinguishFire_fun )

function body_hit_sound ()--звук поподания в тело
	playSound("parachute/body_hit_sound.mp3")
end
addEvent( "event_body_hit_sound", true )
addEventHandler ( "event_body_hit_sound", getRootElement(), body_hit_sound )

function setElementCollidableWith_fun (value1, element, value)--вкл/откл столкновения тс
	for index,vehicle in pairs(getElementsByType(value1)) do --LOOP through all Vehicles
		setElementCollidableWith(vehicle, element, value) -- Set the Collison off with the Other vehicles.
	end
end
addEvent( "event_setElementCollidableWith_fun", true )
addEventHandler ( "event_setElementCollidableWith_fun", getRootElement(), setElementCollidableWith_fun )


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
addEventHandler ( "event_logsave_fun", getRootElement(), logsave_fun )

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
addEventHandler ( "event_invsave_fun", getRootElement(), invsave_fun )

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
	else
		setElementData(localPlayer, "is_chat_open", 0)
	end
end, 500, 0)

setTimer(function ()
	if isMainMenuActive() then
		afk = afk+1
		setElementData(localPlayer, "afk", afk)
	else
		afk = 0
		setElementData(localPlayer, "afk", afk)
	end
end, 1000, 0)

setTimer(function ()
	local timeserver = split(getElementData(playerid, "timeserver"), ":")
	setTime(timeserver[1], timeserver[2])
end, 60000, 0)
-----------------------------------------------------------------------------------------

local image = {}--загрузка картинок для отображения на земле
for i=0,#info_png do
	image[i] = dxCreateTexture("image_inventory/"..i..".png")
end

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

--окно тюнинга
local gui_window = nil

local plate = ""
local house = ""

local max_inv = 23
local inv_slot_player = {} -- инв-рь игрока
local inv_slot_car = {} -- инв-рь авто
local inv_slot_house = {} -- инв-рь дома

for i=0,max_inv do
	inv_slot_player[i] = {0,0,0}
	inv_slot_car[i] = {0,0,0}
	inv_slot_house[i] = {0,0,0}
end

function sendMessage(text, color)
	local time = getRealTime()

	outputChatBox("[ "..time["hour"]..":"..time["minute"]..":"..time["second"].." ] "..text, color[1], color[2], color[3])
end

function getPlayerVehicle( playerid )
	local vehicle = getPedOccupiedVehicle ( playerid )
	return vehicle
end

function isPointInCircle3D(x, y, z, x1, y1, z1, radius)
	if getDistanceBetweenPoints3D(x, y, z, x1, y1, z1) <= radius then
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

------------------------------собственное гуи--------------------------------------------
function m2gui_label( x,y, width, height, text, bool_r, parent )
	local text = guiCreateLabel ( x, y, width, height, text, bool_r, parent )
	guiSetFont( text, m2font )
	return text
end

function m2gui_radiobutton( x,y, width, height, text, bool_r, parent )
	local text = guiCreateRadioButton ( x, y, width, height, text, bool_r, parent )
	guiSetFont( text, m2font )
	return text
end

function m2gui_window( x,y, width, height, text, bool_r, movable )
	local m2gui_win = guiCreateWindow( x, y, width, height, text, bool_r )
	guiWindowSetMovable ( m2gui_win, false )
	guiWindowSetSizable ( m2gui_win, false )

	if movable then
		guiWindowSetMovable ( m2gui_win, true )
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

	function outputEditBox ( absoluteX, absoluteY, gui )--наведение на текст кнопки
		guiLabelSetColor ( text, crimson[1], crimson[2], crimson[3] )
	end
	addEventHandler( "onClientMouseEnter", text, outputEditBox, false )

	function outputEditBox ( absoluteX, absoluteY, gui )--покидание на текст кнопки
		guiLabelSetColor ( text, white[1], white[2], white[3] )
	end
	addEventHandler( "onClientMouseLeave", text, outputEditBox, false )

	return text,dimensions+sym+x
end
-----------------------------------------------------------------------------------------

local paint={
	[483]={"VehiclePaintjob_Camper_0"},-- camper
	[534]={"VehiclePaintjob_Remington_0","VehiclePaintjob_Remington_1","VehiclePaintjob_Remington_2"},-- remington
	[535]={"VehiclePaintjob_Slamvan_0","VehiclePaintjob_Slamvan_1","VehiclePaintjob_Slamvan_2"},-- slamvan
	[536]={"VehiclePaintjob_Blade_0","VehiclePaintjob_Blade_1","VehiclePaintjob_Blade_2"},-- blade
	[558]={"VehiclePaintjob_Uranus_0","VehiclePaintjob_Uranus_1","VehiclePaintjob_Uranus_2"},-- uranus
	[559]={"VehiclePaintjob_Jester_0","VehiclePaintjob_Jester_1","VehiclePaintjob_Jester_2"},-- jester
	[560]={"VehiclePaintjob_Sultan_0","VehiclePaintjob_Sultan_1","VehiclePaintjob_Sultan_2"},-- sultan
	[561]={"VehiclePaintjob_Stratum_0","VehiclePaintjob_Stratum_1","VehiclePaintjob_Stratum_2"},-- stratum
	[562]={"VehiclePaintjob_Elegy_0","VehiclePaintjob_Elegy_1","VehiclePaintjob_Elegy_2"},-- elegy
	[565]={"VehiclePaintjob_Flash_0","VehiclePaintjob_Flash_1","VehiclePaintjob_Flash_2"},-- flash
	[567]={"VehiclePaintjob_Savanna_0","VehiclePaintjob_Savanna_1","VehiclePaintjob_Savanna_2"},-- savanna
	[575]={"VehiclePaintjob_Broadway_0","VehiclePaintjob_Broadway_1"},-- broadway
	[576]={"VehiclePaintjob_Tornado_0","VehiclePaintjob_Tornado_1","VehiclePaintjob_Tornado_2"},-- tornado
}

local weapon = {
	--[9] = {info_png[9][1], 16, 360, 5},
	[12] = {info_png[12][1], 22, 240, 25},
	[13] = {info_png[13][1], 24, 1440, 25},
	[14] = {info_png[14][1], 30, 4200, 25},
	[15] = {info_png[15][1], 31, 5400, 25},
	[17] = {info_png[17][1], 29, 2400, 25},
	[18] = {info_png[18][1], 28, 600, 25},
	--[19] = {info_png[19][1], 17, 360, 5},
	[26] = {info_png[26][1], 23, 720, 25},
	[34] = {info_png[34][1], 25, 720, 25},
	[35] = {info_png[35][1], 46, 200, 1},
	--[36] = {info_png[36][1], 3, 150, 1},
	[37] = {info_png[37][1], 5, 150, 1},
	[38] = {info_png[38][1], 4, 150, 1},
	[41] = {info_png[41][1], 34, 6000, 25},
	--[47] = {info_png[47][1], 41, 50, 25},
	[49] = {info_png[49][1], 6, 50, 1},
}

local skin = {"мужская одежда", 1, 2, 7, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 265, 266, 267, 268, 269, 270, 271, 272, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 305, 306, 307, 308, 309, 310, 311, 312, "женская одежда", 9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 304}

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
	{2564.779296875,-1293.0673828125,1044.125, 2, "Выбросите коробку с продуктами, чтобы получить прибыль"},
	{681.7744140625,823.8447265625,-26.840600967407, 5, "Выбросите руду, чтобы получить прибыль"},
	{-488.2119140625,-176.8603515625,78.2109375, 5, "Выбросите дрова, чтобы получить прибыль"},--склад бревен
	{-1633.845703125,-2239.08984375,31.4765625, 5, "Выбросите тушку оленя, чтобы получить прибыль"},--охотничий дом

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

	{-1106.65234375,-1620.943359375,76.3671875, 5, "Отстойник"},

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

local weather_list = {
	[0] = {"SUNNY", 101,60},
	[1] = {"SUNNY", 101,60},
	[2] = {"SUNNY", 101,60},
	[3] = {"CLOUDY", 107,60},
	[4] = {"CLOUDY", 107,60},
	[5] = {"SUNNY", 101,60},
	[6] = {"SUNNY", 101,60},
	[7] = {"CLOUDY", 107,60},
	[8] = {"RAINY", 68,60},
	[9] = {"FOGGY", 111,60},
	[10] = {"SUNNY", 101,60},
	[11] = {"SUNNY", 101,60},
	[12] = {"CLOUDY", 107,60},
	[13] = {"SUNNY", 101,60},
	[14] = {"SUNNY", 101,60},
	[15] = {"CLOUDY", 107,60},
	[16] = {"RAINY", 68,60},
	[17] = {"SUNNY", 101,60},
	[18] = {"SUNNY", 101,60},
	[19] = {"SANDSTORM", 71,60},
	[20] = {"CLOUDY", 107,60},
	[21] = {"CLOUDY", 107,60},
	[22] = {"CLOUDY", 107,60},
}

--перемещение картинки
local lmb = 0--лкм
local gui_selection = false
local gui_selection_pos_x = 0 --положение картинки x
local gui_selection_pos_y = 0 --положение картинки y
local info3_selection_1 = -1 --слот картинки
local info1_selection_1 = -1 --номер картинки
local info2_selection_1 = -1 --значение картинки

--выбор цвета для окна тюнинга
local tune_color_2d = false
local tune_color_r = 255
local tune_color_g = 0
local tune_color_b = 0

function dxdrawtext(text, x, y, width, height, color, scale, font)
	dxDrawText ( text, x+1, y+1, width, height, tocolor ( 0, 0, 0, 255 ), scale, font )

	dxDrawText ( text, x, y, width, height, color, scale, font )
end

local lastTick, framesRendered, FPS = getTickCount(), 0, 0
function createText ()
	playerid = localPlayer
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

	local alcohol = getElementData ( playerid, "alcohol_data" )--макс 500
	local satiety = getElementData ( playerid, "satiety_data" )--макс 100
	local hygiene = getElementData ( playerid, "hygiene_data" )--макс 100
	local sleep = getElementData ( playerid, "sleep_data" )--макс 100
	local drugs = getElementData ( playerid, "drugs_data" )--макс 100
	local width_need = (screenWidth/5.04)--ширина нужд 271
	local height_need = (screenHeight/5.68)--высота нужд 135

	if hud then
		local client_time = "Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"]
		local text = "FPS: "..FPS.." | Ping: "..getPlayerPing(playerid).." | Players online: "..#getElementsByType("player").." | Minute in game: "..time_game.." | "..client_time
		dxdrawtext ( text, 2.0, 0.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

		dxDrawImage ( screenWidth-30, height_need-7.5, 30, 30, "hud/health.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need, (width_need/200)*getElementHealth(playerid), 15, tocolor ( 90, 151, 107, 255 ) )

		--нужды
		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*1, 30, 30, "hud/alcohol.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*1, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*1, (width_need/500)*alcohol, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*2, 30, 30, "hud/drugs.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*2, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*2, (width_need/100)*drugs, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*3, 30, 30, "hud/satiety.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*3, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*3, (width_need/100)*satiety, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*4, 30, 30, "hud/hygiene.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*4, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*4, (width_need/100)*hygiene, 15, tocolor ( 90, 151, 107, 255 ) )

		dxDrawImage ( screenWidth-30, height_need-7.5+(20+7.5)*5, 30, 30, "hud/sleep.png" )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*5, width_need, 15, tocolor ( 0, 0, 0, 200 ) )
		dxDrawRectangle( screenWidth-width_need-30, height_need+(20+7.5)*5, (width_need/100)*sleep, 15, tocolor ( 90, 151, 107, 255 ) )

		local spl_gz = getElementData(playerid, "guns_zone2")
		local name_mafia = getElementData(playerid, "name_mafia")
		if spl_gz and spl_gz[1][1] == 1 then
			dxDrawRectangle( 0.0, screenHeight-16.0*6, 250.0, 16.0*3, tocolor( 0, 0, 0, 150 ) )
			dxdrawtext ( "Время: "..spl_gz[2].." сек", 2.0, screenHeight-16*6, 0.0, 0.0, tocolor( white[1], white[2], white[3] ), 1, m2font_dx1 )
			dxdrawtext ( "Атака "..name_mafia[spl_gz[1][3]][1]..": "..spl_gz[1][4].." очки", 2.0, screenHeight-16*5, 0.0, 0.0, tocolor( 255,0,50 ), 1, m2font_dx1 )
			dxdrawtext ( "Защита "..name_mafia[spl_gz[1][5]][1]..": "..spl_gz[1][6].." очки", 2.0, screenHeight-16*4, 0.0, 0.0, tocolor( 0,50,255 ), 1, m2font_dx1 )
		end
	end

	local x,y,z = getElementPosition(playerid)
	local rx,ry,rz = getElementRotation(playerid)
	local heal_player = split(getElementHealth(playerid), ".")


	if debuginfo then
		dxdrawtext ( x.." "..y.." "..z, 300.0, 40.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( rx.." "..ry.." "..rz, 300.0, 55.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( "skin "..getElementModel(playerid)..", interior "..getElementInterior(playerid)..", dimension "..getElementDimension(playerid), 300.0, 70.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

		if isCursorShowing() then
			local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
			dxdrawtext ( screenx*screenWidth..", "..screeny*screenHeight, screenx*screenWidth, screeny*screenHeight+15, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		end

		--[[for i=0,20 do--setdata
			dxdrawtext ( getElementData(playerid, tostring(i)), 10.0, 175.0+(15*i), 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		end]]

		dxdrawtext ( heal_player[1], screenWidth-width_need-30-30, height_need, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( (alcohol/100), screenWidth-width_need-30-30, height_need+(20+7.5)*1, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( drugs, screenWidth-width_need-30-30, height_need+(20+7.5)*2, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( satiety, screenWidth-width_need-30-30, height_need+(20+7.5)*3, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( hygiene, screenWidth-width_need-30-30, height_need+(20+7.5)*4, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( sleep, screenWidth-width_need-30-30, height_need+(20+7.5)*5, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
	end


	if hud then
		local vehicle = getPlayerVehicle ( playerid )
		if vehicle then--отображение скорости авто
			local speed_table = split(getSpeed(vehicle), ".")
			local heal_vehicle = split(getElementHealth(vehicle), ".")
			local fuel = getElementData ( playerid, "fuel_data" )
			local fuel_table = split(fuel, ".")
			local speed_car = 0

			if getSpeed(vehicle) >= 240 then
				speed_car = 240*1.125+43
			else
				speed_car = getSpeed(vehicle)*1.125+43
			end

			local speed_vehicle = "plate "..plate.." | heal vehicle "..heal_vehicle[1].." | kilometrage "..split(getElementData ( playerid, "probeg_data" ), ".")[1]

			dxdrawtext ( speed_vehicle, 5, screenHeight-16, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

			dxDrawImage ( screenWidth-250, screenHeight-250, 210, 210, "speedometer/speed_v.png" )
			dxDrawImage ( screenWidth-250, screenHeight-250, 210, 210, "speedometer/arrow_speed_v.png", speed_car )
			dxDrawImage ( (screenWidth-250), screenHeight-250, 210, 210, "speedometer/fuel_v.png", 35.0-(fuel*1.4) )
		end
	end


	for k,vehicle in pairs(getElementsByType("vehicle")) do--отображение скорости авто над машиной
		local xv,yv,zv = getElementPosition(vehicle)
		
		if isPointInCircle3D(x,y,z, xv,yv,zv, 20) then
			local coords = { getScreenFromWorldPosition( xv,yv,zv+1, 0, false ) }
			local plate = getVehiclePlateText(vehicle)

			if coords[1] and coords[2] then
				if getElementData(playerid, "speed_car_device_data") == 1 then
					local coords = { getScreenFromWorldPosition( xv,yv,zv+1.5, 0, false ) }
					local speed_table = split(getSpeed(vehicle), ".")
					local dimensions = dxGetTextWidth ( speed_table[1].." km/h", 1, m2font_dx1 )

					if coords[1] and coords[2] then
						if tonumber(speed_table[1]) >= max_speed then
							dxdrawtext ( speed_table[1].." km/h", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( red, 255 ), 1, m2font_dx1 )
						elseif tonumber(speed_table[1]) < max_speed then
							dxdrawtext ( speed_table[1].." km/h", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
						end
					end
				end

				local dimensions = dxGetTextWidth ( plate, 1, m2font_dx1 )
				dxdrawtext ( plate, coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
			end
		end
	end

	if getElementData(playerid, "gps_device_data") == 1 then
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

		for k,v in pairs(getElementData(playerid, "house_pos")) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], getElementData(playerid, "house_bussiness_radius")) then
				local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]+0.2, 0, false ) }
				if coords[1] and coords[2] then
					local dimensions = dxGetTextWidth ( "Дом #"..k.."", 1, m2font_dx1 )
					dxdrawtext ( "Дом #"..k.."", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )

					local dimensions = dxGetTextWidth ( "(Войти - ALT)", 1, m2font_dx1 )
					dxdrawtext ( "(Войти - ALT)", coords[1]-(dimensions/2), coords[2]+15, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			end
		end


		for k,v in pairs(getElementData(playerid, "business_pos")) do
			if isPointInCircle3D(x,y,z, v[1],v[2],v[3], getElementData(playerid, "house_bussiness_radius")) then	
				local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]+0.2, 0, false ) }
				if coords[1] and coords[2] then
					local dimensions = dxGetTextWidth ( "Бизнес #"..k.."", 1, m2font_dx1 )
					dxdrawtext ( "Бизнес #"..k.."", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )

					local dimensions = dxGetTextWidth ( "(Войти - ALT, Разгрузить товар - E, Меню - X)", 1, m2font_dx1 )
					dxdrawtext ( "(Войти - ALT, Разгрузить товар - E, Меню - X)", coords[1]-(dimensions/2), coords[2]+15, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end
			end
		end


		for k,v in pairs(getElementData(playerid, "interior_job")) do
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
		local offset = dxGetFontHeight(1,m2font_dx1)
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


	for i,v in pairs(getElementData(playerid, "earth")) do--отображение предметов на земле
		local area = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 20 )
		local area2 = isPointInCircle3D( x, y, z, v[1], v[2], v[3], 10 )

		if area then
			local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]-1, 0, false ) }
			if coords[1] and coords[2] then
				dxDrawImage ( coords[1]-(57/2), coords[2], 57, 57, image[ v[4] ] )
			end
		end

		if area2 then
			local coords = { getScreenFromWorldPosition( v[1], v[2], v[3]-1+0.2, 0, false ) }
			if coords[1] and coords[2] then
				local dimensions = dxGetTextWidth ( "Нажмите E", 1, m2font_dx1 )
				dxdrawtext ( "Нажмите E", coords[1]-(dimensions/2), coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
			end
		end
	end


	if tune_color_2d then--выбор цвета для окна тюнинга
		local width,height = guiGetPosition ( gui_window, false )
		dxDrawRectangle( width+10, height+25, 160, 160, tocolor ( tune_color_r, tune_color_g, tune_color_b, 255 ), true )
	end


	if pos_timer == 1 then
		for k,player in pairs(getElementsByType("player")) do
			local x1,y1,z1 = getElementPosition(player)
			local coords = { getScreenFromWorldPosition( x1,y1,z1+1.0, 0, false ) }

			if player ~= playerid and coords[1] and coords[2] and isLineOfSightClear(x, y, z, x1,y1,z1) then
				if isPointInCircle3D( x, y, z, x1,y1,z1, 10 ) and getElementData(player, "drugs_data") >= getElementData(player, "zakon_drugs") then
					local dimensions = dxGetTextWidth ( "*эффект наркотиков*", 1, m2font_dx1 )
					dxdrawtext ( "*эффект наркотиков*", coords[1]-(dimensions/2), coords[2]-15*4, 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, m2font_dx1 )
				end

				if isPointInCircle3D( x, y, z, x1,y1,z1, 10 ) and (getElementData(player, "alcohol_data")/100) >= getElementData(player, "zakon_alcohol") then
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
					dxdrawtext ( "WANTED", coords[1]-(dimensions/2), coords[2]-15*1, 0.0, 0.0, tocolor ( red, 255 ), 1, m2font_dx1 )
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
addEventHandler ( "onClientRender", getRootElement(), createText )

local number_business = 0
local tune_business = false
local int_upgrades = 0
local int_paint = -1
local int_stage = 0
function tune_window_create (number)--создание окна тюнинга
	number_business = number
	local vehicleid = getPlayerVehicle(playerid)

	if not vehicleid then
		return
	end

	setElementData(playerid, "car_upgrades_save", getVehicleUpgrades(vehicleid))
	setElementData(playerid, "car_paint_save", getVehiclePaintjob ( vehicleid ))

	local dimensions1 = dxGetTextWidth ( "Введите цвет в RGB", 1, m2font_dx )
	local width = 355+50
	local height = 235.0+(16.0*1)+10
	tune_business = true
	gui_window = m2gui_window( (screenWidth/2)-(width/2), 20, width, height, number_business.." бизнес, Автомастерская", false, false )

	local upgrades_table = guiCreateComboBox ( 180, 25, 215, 200, "Апгрейды", false, gui_window )
	for k,v in pairs(getVehicleCompatibleUpgrades ( vehicleid )) do
		guiComboBoxAddItem( upgrades_table, getElementData(playerid, "upgrades_car_table")[v].."#"..v )
	end

	local paint_job = guiCreateComboBox ( 180, 55, 215, 200, "Покраска", false, gui_window )
	for i=1,4 do
		guiComboBoxAddItem( paint_job, i)
	end

	local car_stage = guiCreateComboBox ( 180, 85, 215, 200, "Stage", false, gui_window )
	for i=1,3 do
		guiComboBoxAddItem( car_stage, i)
	end

	local tune_text = m2gui_label ( 180, 115, dimensions1+15, 20, "Введите цвет в RGB", false, gui_window )
	guiSetFont( tune_text, m2font )
	local tune_r_edit = guiCreateEdit ( 180, 145, 65, 20, "", false, gui_window )
	local tune_g_edit = guiCreateEdit ( 255, 145, 65, 20, "", false, gui_window )
	local tune_b_edit = guiCreateEdit ( 330, 145, 65, 20, "", false, gui_window )
	local tune_radio_button1 = m2gui_radiobutton ( 180, 175, 60, 15, "Авто", false, gui_window )
	local tune_radio_button2 = m2gui_radiobutton ( 240, 175, 60, 15, "Фары", false, gui_window )
	local tune_search_button = m2gui_button( 180, 205, "Посмотреть цвет", false, gui_window )
	local tune_install_button = m2gui_button( 180, 235, "Установить", false, gui_window )
	local tune_img = guiCreateStaticImage( 10, 25, 160, 160, "upgrade/999_w_s.png", false, gui_window )

	showCursor( true )

	addEventHandler ( "onClientGUIComboBoxAccepted", upgrades_table,
	function ( comboBox )
		local item = guiComboBoxGetItemText(upgrades_table, guiComboBoxGetSelected(upgrades_table))
		for k,v in pairs(getElementData(playerid, "upgrades_car_table")) do
			if item == v.."#"..k then
				int_upgrades = k
				addVehicleUpgrade ( vehicleid, int_upgrades )
				guiSetText ( tune_r_edit, "" )
				guiSetText ( tune_g_edit, "" )
				guiSetText ( tune_b_edit, "" )
				int_paint = -1
				int_stage = 0
				break
			end
		end
	end)

	addEventHandler ( "onClientGUIComboBoxAccepted", paint_job,
	function ( comboBox )
		local item = guiComboBoxGetItemText(paint_job, guiComboBoxGetSelected(paint_job))
		int_paint = tonumber(item)-1
		setVehiclePaintjob ( vehicleid, int_paint )
		guiSetText ( tune_r_edit, "" )
		guiSetText ( tune_g_edit, "" )
		guiSetText ( tune_b_edit, "" )
		int_upgrades = 0
		int_stage = 0
	end)

	addEventHandler ( "onClientGUIComboBoxAccepted", car_stage,
	function ( comboBox )
		local item = guiComboBoxGetItemText(car_stage, guiComboBoxGetSelected(car_stage))
		int_stage = tonumber(item)
		guiSetText ( tune_r_edit, "" )
		guiSetText ( tune_g_edit, "" )
		guiSetText ( tune_b_edit, "" )
		int_upgrades = 0
		int_paint = -1
	end)

	function tune_img_load ( button, state, absoluteX, absoluteY )--поиск тюнинга
		local r1,g1,b1 = guiGetText ( tune_r_edit ), guiGetText ( tune_g_edit ), guiGetText ( tune_b_edit )
		local r,g,b = tonumber(r1), tonumber(g1), tonumber(b1)

		if r1 ~= "" and g1 ~= "" and b1 ~= "" and r and g and b then
			if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
				tune_color_2d = true
				tune_color_r = r
				tune_color_g = g
				tune_color_b = b
			end
		end
	end
	addEventHandler ( "onClientGUIClick", tune_search_button, tune_img_load, false )

	function tune_upgrade ( button, state, absoluteX, absoluteY )--установка тюнинга
		local r1,g1,b1 = guiGetText ( tune_r_edit ), guiGetText ( tune_g_edit ), guiGetText ( tune_b_edit )
		local r,g,b = tonumber(r1), tonumber(g1), tonumber(b1)

		if int_upgrades ~= 0 then
			if tonumber(int_upgrades) >= 1000 and tonumber(int_upgrades) <= 1193 then
				local upgrades = getVehicleCompatibleUpgrades ( vehicleid )

				for v, upgrade in pairs ( upgrades ) do
					if upgrade == tonumber(int_upgrades) then

						for k,v in pairs(getVehicleUpgrades(vehicleid)) do
							removeVehicleUpgrade(vehicleid, v)
						end

						for k,v in pairs(getElementData(playerid, "car_upgrades_save")) do
							addVehicleUpgrade(vehicleid, v)
						end

						triggerServerEvent( "event_addVehicleUpgrade", getRootElement(), vehicleid, tonumber(int_upgrades), "save", playerid, number_business )

						int_upgrades = 0
						return
					end
				end

				sendMessage("[ERROR] Эту деталь нельзя установить", red)
			end

		elseif int_paint ~= -1 then
			local model = getElementModel ( vehicleid )
			if paint[model] ~= nil then
				triggerServerEvent( "event_setVehiclePaintjob", getRootElement(), vehicleid, int_paint, "save", playerid, number_business )
			end

			int_paint = -1

		elseif int_stage ~= 0 then
			triggerServerEvent( "event_setVehicleStage_fun", getRootElement(), vehicleid, int_stage, "save", playerid, number_business )
			int_stage = 0
		end

		if r1 ~= "" and g1 ~= "" and b1 ~= "" and vehicleid and r and g and b then
			if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
				if guiRadioButtonGetSelected( tune_radio_button1 ) == true then
					triggerServerEvent( "event_setVehicleColor", getRootElement(), vehicleid, r, g, b, "save", playerid, number_business )

				elseif guiRadioButtonGetSelected( tune_radio_button2 ) == true then
					triggerServerEvent( "event_setVehicleHeadLightColor", getRootElement(), vehicleid, r, g, b, "save", playerid, number_business )
				end
			end
		end
	end
	addEventHandler ( "onClientGUIClick", tune_install_button, tune_upgrade, false )

	function tune_r_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_r_edit, "" )
		int_upgrades = 0
		int_paint = -1
		int_stage = 0
	end
	addEventHandler ( "onClientGUIClick", tune_r_edit, tune_r_edit_fun, false )

	function tune_g_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_g_edit, "" )
		int_upgrades = 0
		int_paint = -1
		int_stage = 0
	end
	addEventHandler ( "onClientGUIClick", tune_g_edit, tune_g_edit_fun, false )

	function tune_b_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_b_edit, "" )
		int_upgrades = 0
		int_paint = -1
		int_stage = 0
	end
	addEventHandler ( "onClientGUIClick", tune_b_edit, tune_b_edit_fun, false )

end
addEvent( "event_tune_create", true )
addEventHandler ( "event_tune_create", getRootElement(), tune_window_create )


function business_menu(number)--создание окна бизнеса
	number_business = number

	showCursor( true )

	local width = 340+10
	local height = 140.0+(16.0*1)+10
	gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, number_business.." бизнес, Касса", false )
	local tune_text = m2gui_label ( 0, 20, width, 20, "Укажите сумму", false, gui_window )
	guiLabelSetHorizontalAlign ( tune_text, "center" )
	guiSetFont( tune_text, m2font )
	local tune_text_edit = guiCreateEdit ( 5, 40, (width-10), 20, "", false, gui_window )
	local tune_radio_button1 = m2gui_radiobutton ( 5, 65, 220, 15, "Забрать деньги из кассы", false, gui_window )
	local tune_radio_button2 = m2gui_radiobutton ( 5, 90, 220, 15, "Положить деньги в кассу", false, gui_window )
	local tune_radio_button3 = m2gui_radiobutton ( 5, 115, 330, 15, "Установить стоимость товара (надбавку в N раз)", false, gui_window )
	local complete_button = m2gui_button( 5, 140, "Выполнить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGetText ( tune_text_edit )

		if tonumber(text) ~= nil and tonumber(text) >= 1 then
			if guiRadioButtonGetSelected( tune_radio_button1 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), playerid, number_business, tonumber(text), "withdraw" )

			elseif guiRadioButtonGetSelected( tune_radio_button2 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), playerid, number_business, tonumber(text), "deposit" )

			elseif guiRadioButtonGetSelected( tune_radio_button3 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), playerid, number_business, tonumber(text), "price" )
			end
		end
	end
	addEventHandler ( "onClientGUIClick", complete_button, complete, false )

end
addEvent( "event_business_menu", true )
addEventHandler ( "event_business_menu", getRootElement(), business_menu )


function shop_menu(number, value)--создание окна магазина
	number_business = number

	showCursor( true )

	if value == "pd" then
		local width = 400+10
		local height = 320.0+(16.0*1)+10
		gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Склад полиции", false )

		local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

		guiGridListAddColumn(shoplist, "Товары", 0.9)
		for k,v in pairs(getElementData ( playerid, "weapon_cops" )) do
			guiGridListAddRow(shoplist, v[1])
		end

		for k,v in pairs(getElementData ( playerid, "sub_cops" )) do
			guiGridListAddRow(shoplist, v[1])
		end

		local buy_subject = m2gui_button( 5, 320, "Взять", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", getRootElement(), playerid, text, number_business, value )
		end
		addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

		return
		
	elseif value == "mer" then
		local column_width1 = 0.7
		local column_width2 = 0.2

		local zakon_nalog_car = getElementData ( playerid, "zakon_nalog_car_data" )
		local zakon_nalog_house = getElementData ( playerid, "zakon_nalog_house_data" )
		local zakon_nalog_business = getElementData ( playerid, "zakon_nalog_business_data" )

		local width = 400+10
		local height = 320.0+(16.0*1)+10
		gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Мэрия", false )

		local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)

		guiGridListAddColumn(shoplist, "Услуги", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( playerid, "mayoralty_shop" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

		local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", getRootElement(), playerid, text, number_business, value )
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
		for k,v in pairs(getElementData ( playerid, "giuseppe" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

		local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", getRootElement(), playerid, text, number_business, value )
		end
		addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

		return
	end

	local width = 400+10
	local height = 320.0+(16.0*1)+10
	gui_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, number_business.." бизнес, "..getElementData(playerid, "interior_business")[value][2], false )

	local shoplist = guiCreateGridList(5, 20, width-10, 320-30, false, gui_window)
	local column_width1 = 0.7
	local column_width2 = 0.2

	local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

		triggerServerEvent( "event_buy_subject_fun", getRootElement(), playerid, text, number_business, value )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

	if value == 1 then
		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(weapon) do
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
		for k,v in pairs(getElementData ( playerid, "shop" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

	elseif value == 4 then
		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( playerid, "gas" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end
	end
end
addEvent( "event_shop_menu", true )
addEventHandler ( "event_shop_menu", getRootElement(), shop_menu )


function avto_bikes_menu()--создание окна машин

	showCursor( true )

	local vehicleIds = getElementData(playerid, "cash_car")

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

		triggerServerEvent( "event_buycar", getRootElement(), playerid, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_avto_bikes_menu", true )
addEventHandler ( "event_avto_bikes_menu", getRootElement(), avto_bikes_menu )


function boats_menu()--создание окна машин

	showCursor( true )

	local vehicleIds = getElementData(playerid, "cash_boats")

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

		triggerServerEvent( "event_buycar", getRootElement(), playerid, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_boats_menu", true )
addEventHandler ( "event_boats_menu", getRootElement(), boats_menu )


function helicopters_menu()--создание окна машин

	showCursor( true )

	local vehicleIds = getElementData(playerid, "cash_helicopters")

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

		triggerServerEvent( "event_buycar", getRootElement(), playerid, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_helicopters_menu", true )
addEventHandler ( "event_helicopters_menu", getRootElement(), helicopters_menu )


function tablet_fun()--создание планшета

	showCursor( true )

	local width = 720
	local height = 430

	local pos_x = screenWidth-width
	local pos_Y = screenHeight-height

	local width_fon = width/1.121--642
	local height_fon = height/1.194--360

	local width_fon_pos = width_fon/16.05--40
	local height_fon_pos = height_fon/12.41--29

	local browser = nil

	gui_window = guiCreateStaticImage( pos_x, pos_Y, width, height, "comp/tablet-display.png", false )
	local fon = guiCreateStaticImage( width_fon_pos, height_fon_pos, width_fon, height_fon, "comp/low_fon.png", false, gui_window )

	local auction_menu = guiCreateStaticImage( 10, 10, 80, 60, "comp/auction.png", false, fon )
	local youtube = guiCreateStaticImage( 100, 10, 85, 60, "comp/youtube.png", false, fon )
	local wiki = guiCreateStaticImage( 195, 10, 66, 60, "comp/wiki.png", false, fon )
	local craft = guiCreateStaticImage( 270, 10, 55, 60, "comp/bookcraft.png", false, fon )
	local carparking = guiCreateStaticImage( 340, 10, 60, 60, "comp/carparking.png", false, fon )
	local shop = guiCreateStaticImage( 410, 10, 60, 60, "comp/shop.png", false, fon )
	local handbook = guiCreateStaticImage( 480, 10, 60, 60, "comp/handbook.png", false, fon )

	for value,weather in pairs(weather_list) do
		if getElementData(playerid, "tomorrow_weather_data") == value then
			local set_weather = guiCreateStaticImage( width_fon-weather[2], height_fon-weather[3], weather[2], weather[3], "comp/"..weather[1]..".png", false, fon )
			break
		end
	end

	function outputEditBox ( button, state, absoluteX, absoluteY )--аук предметов меню
		local auc_menu = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local buy_sub = m2gui_button( 0, 0, "Купить предметы", false, auc_menu )
		local sell_sub = m2gui_button( 0, 20, "Продать предметы", false, auc_menu )
		local work_table = m2gui_button( 0, 20*2, "Рабочий стол", false, auc_menu )

		function outputEditBox ( button, state, absoluteX, absoluteY )--вернуться на раб стол
			destroyElement(auc_menu)
		end
		addEventHandler ( "onClientGUIClick", work_table, outputEditBox, false )


		function outputEditBox ( button, state, absoluteX, absoluteY )--аук предметов
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local buy_subject,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Купить", false, low_fon )
			local return_subject,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Вернуть", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )--вернуться в меню аука
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить меню аука
				guiGridListClear(shoplist)
				for k,v in pairs(getElementData(playerid, "auc")) do
					guiGridListAddRow(shoplist, v["i"], v["name_sell"], info_png[v["id1"]][1].." "..v["id2"].." "..info_png[v["id1"]][2], v["money"], v["name_buy"])
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--купить предмет
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

				if text == "" then
					sendMessage("[ERROR] Вы не выбрали предмет", red)
					return
				end
				
				triggerServerEvent("event_auction_buy_sell", getRootElement(), playerid, "buy", text, 0, 0, 0 )
			end
			addEventHandler ( "onClientGUIClick", buy_subject, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--вернуть предмет
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

				if text == "" then
					sendMessage("[ERROR] Вы не выбрали предмет", red)
					return
				end

				triggerServerEvent("event_auction_buy_sell", getRootElement(), playerid, "return", text, 0, 0, 0 )
			end
			addEventHandler ( "onClientGUIClick", return_subject, outputEditBox, false )

			if getElementData(playerid, "auc") then
				guiGridListAddColumn(shoplist, "№", 0.1)
				guiGridListAddColumn(shoplist, "Продавец", 0.20)
				guiGridListAddColumn(shoplist, "Товар", 0.30)
				guiGridListAddColumn(shoplist, "Стоимость", 0.15)
				guiGridListAddColumn(shoplist, "Покупатель", 0.2)
				for k,v in pairs(getElementData(playerid, "auc")) do
					guiGridListAddRow(shoplist, v["i"], v["name_sell"], info_png[v["id1"]][1].." "..v["id2"].." "..info_png[v["id1"]][2], v["money"], v["name_buy"])
				end
			end
		end
		addEventHandler ( "onClientGUIClick", buy_sub, outputEditBox, false )


		function outputEditBox ( button, state, absoluteX, absoluteY )--продать предмет
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )

			local text_id1 = m2gui_label ( 0, 0, 200, 15, "Выберите предмет", false, low_fon )
			local edit_id1 = guiCreateComboBox ( 0, 20, 200, 300, "", false, low_fon )

			for i=2,#info_png do
				guiComboBoxAddItem( edit_id1, info_png[i][1] )
			end

			local text_id2 = m2gui_label ( 0, 50, 200, 15, "Введите количество предмета", false, low_fon )
			local text_id3 = m2gui_label ( 0, 65, 200, 15, "или его стоимость", false, low_fon )
			local edit_id2 = guiCreateEdit ( 0, 85, 200, 25, "", false, low_fon )
			local text_money = m2gui_label ( 0, 115, 200, 15, "Введите стоимость предмета", false, low_fon )
			local edit_money = guiCreateEdit ( 0, 135, 200, 25, "", false, low_fon )
			local text_id4 = m2gui_label ( 0, 165, 200, 15, "Имя покупателя, если есть", false, low_fon )
			local edit_text_id4 = guiCreateEdit ( 0, 185, 200, 25, "all", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local sell_subject,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Продать", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )--вернуться в меню аука
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--продать предмет
				local id1, id2, money, name_buy = 0, tonumber(guiGetText ( edit_id2 )), tonumber(guiGetText ( edit_money )), guiGetText ( edit_text_id4 )

				for k,v in pairs(info_png) do
					if v[1] == guiComboBoxGetItemText(edit_id1, guiComboBoxGetSelected(edit_id1)) then
						id1 = k
						break
					end
				end

				if id1 >= 2 and id1 <= #info_png and id2 and money > 0 then
					triggerServerEvent("event_auction_buy_sell", getRootElement(), playerid, "sell", 0, id1, id2, money, name_buy)
				end
			end
			addEventHandler ( "onClientGUIClick", sell_subject, outputEditBox, false )
		end
		addEventHandler ( "onClientGUIClick", sell_sub, outputEditBox, false )
	end
	addEventHandler ( "onClientGUIClick", auction_menu, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--интернет
		if not browser then
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )

			local home = guiCreateStaticImage ( 0, 0, 25, 25, "comp/homebut.png", false, low_fon )
			local NavigateBack = guiCreateStaticImage ( 25, 0, 25, 25, "comp/backbut.png", false, low_fon )
			local NavigateForward = guiCreateStaticImage ( 50, 0, 25, 25, "comp/forbut.png", false, low_fon )
			local reloadPage = guiCreateStaticImage ( 75, 0, 25, 25, "comp/update.png", false, low_fon )
			local loadURL = guiCreateStaticImage ( 100, 0, 25, 25, "comp/connect.png", false, low_fon )
			local addressBar = guiCreateEdit ( 125, 0, width_fon-125, 25, "", false, low_fon )

			browser = guiCreateBrowser( 0, 25, width_fon, height_fon-25, false, false, false, low_fon )
			local theBrowser = guiGetBrowser( browser )

			addEventHandler("onClientBrowserCreated", theBrowser,
			function ()
				loadBrowserURL(theBrowser, "https://www.youtube.com")
			end, false)

			addEventHandler( "onClientBrowserDocumentReady", theBrowser, function( )
				guiSetText( addressBar, getBrowserURL( theBrowser ) )
			end)

			addEventHandler( "onClientGUIClick", resourceRoot,
			function()
				if source == NavigateBack then
					navigateBrowserBack(theBrowser)

				elseif source == NavigateForward then
					navigateBrowserForward(theBrowser)

				elseif source == reloadPage then
					reloadBrowserPage(theBrowser)

				elseif source == loadURL then
					local text = guiGetText ( addressBar )
					if text ~= "" then
						loadBrowserURL(theBrowser, text)
					else
						sendMessage("[ERROR] URL пуст", red)
					end

				elseif source == home then
					destroyElement(low_fon)

					browser = nil
				end
			end)
		end
	end
	addEventHandler ( "onClientGUIClick", youtube, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--вики
		if not browser then
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )

			local home = guiCreateStaticImage ( 0, 0, 25, 25, "comp/homebut.png", false, low_fon )
			local NavigateBack = guiCreateStaticImage ( 25, 0, 25, 25, "comp/backbut.png", false, low_fon )
			local NavigateForward = guiCreateStaticImage ( 50, 0, 25, 25, "comp/forbut.png", false, low_fon )
			local reloadPage = guiCreateStaticImage ( 75, 0, 25, 25, "comp/update.png", false, low_fon )
			local loadURL = guiCreateStaticImage ( 100, 0, 25, 25, "comp/connect.png", false, low_fon )
			local addressBar = guiCreateEdit ( 125, 0, width_fon-125, 25, "", false, low_fon )

			browser = guiCreateBrowser( 0, 25, width_fon, height_fon-25, true, false, false, low_fon )
			local theBrowser = guiGetBrowser( browser )

			addEventHandler("onClientBrowserCreated", theBrowser,
			function ()
				loadBrowserURL(theBrowser, "http://mta/local/wiki/index.html")
			end, false)

			addEventHandler( "onClientBrowserDocumentReady", theBrowser, function( )
				guiSetText( addressBar, getBrowserURL( theBrowser ) )
			end)

			addEventHandler( "onClientGUIClick", resourceRoot,
			function()
				if source == NavigateBack then
					navigateBrowserBack(theBrowser)

				elseif source == NavigateForward then
					navigateBrowserForward(theBrowser)

				elseif source == reloadPage then
					reloadBrowserPage(theBrowser)

				elseif source == loadURL then
					local text = guiGetText ( addressBar )
					if text ~= "" then
						loadBrowserURL(theBrowser, text)
					else
						sendMessage("[ERROR] URL пуст", red)
					end

				elseif source == home then
					destroyElement(low_fon)

					browser = nil
				end
			end)
		end
	end
	addEventHandler ( "onClientGUIClick", wiki, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--крафт предметов
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

		local home,m2gui_width = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local create,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Создать", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		guiGridListAddColumn(shoplist, "Предмет", 0.2)
		guiGridListAddColumn(shoplist, "Ресурсы", 1.0)

		for k,v in pairs(getElementData(playerid, "craft_table")) do
			guiGridListAddRow(shoplist, v[1], v[2])
		end

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			if text == "" then
				sendMessage("[ERROR] Вы не выбрали предмет", red)
				return
			end

			triggerServerEvent("event_craft_fun", getRootElement(), playerid, text )
		end
		addEventHandler ( "onClientGUIClick", create, outputEditBox, false )
	end
	addEventHandler ( "onClientGUIClick", craft, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--штрафстоянка неоплаченного тс
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

		local home,m2gui_width = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local return_car,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Забрать т/с", false, low_fon )
		local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
			guiGridListClear(shoplist)
			for k,v in pairs(getElementData(playerid, "carparking_table")) do
				guiGridListAddRow(shoplist, v)
			end
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--вернуть тс
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			if text == "" then
				sendMessage("[ERROR] Вы не выбрали т/с", red)
				return
			end

			triggerServerEvent("event_spawn_carparking", getRootElement(), playerid, text )
		end
		addEventHandler ( "onClientGUIClick", return_car, outputEditBox, false )

		if getElementData(playerid, "carparking_table") then
			guiGridListAddColumn(shoplist, "Номер т/с", 0.95)
			for k,v in pairs(getElementData(playerid, "carparking_table")) do
				guiGridListAddRow(shoplist, v)
			end
		end
	end
	addEventHandler ( "onClientGUIClick", carparking, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--скотобойня
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local buy_ferm = m2gui_button( 0, 0, "Купить скотобойню", false, low_fon )
		local menu_ferm = m2gui_button( 0, 20, "Меню скотобойни", false, low_fon )
		local job_ferm = m2gui_button( 0, 20*2, "Устроиться на скотобойню", false, low_fon )
		local work_table = m2gui_button( 0, 20*3, "Рабочий стол", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", work_table, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			triggerServerEvent("event_cow_farms", getRootElement(), playerid, "buy", 0,0 )
		end
		addEventHandler ( "onClientGUIClick", buy_ferm, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
			local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "0", false, low_fon )
			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Выполнить", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				guiGridListClear(shoplist)
				if getElementData(playerid, "cow_farms_table1") then
					for k,v in pairs(getElementData(playerid, "cow_farms_table1")) do
						guiGridListAddRow(shoplist, v[2], v[3])
					end
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				local text2 = tonumber(guiGetText ( edit ))
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				if not text2 then
					sendMessage("[ERROR] Введите число в белое поле", red)
					return
				end

				triggerServerEvent( "event_cow_farms", getRootElement(), playerid, "menu", text, text2 )
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			if getElementData(playerid, "cow_farms_table1") then
				guiGridListAddColumn(shoplist, "Ферма "..getElementData(playerid, "cow_farms_table1")[1][1], 0.5)
				guiGridListAddColumn(shoplist, "", 0.4)
				for k,v in pairs(getElementData(playerid, "cow_farms_table1")) do
					guiGridListAddRow(shoplist, v[2], v[3])
				end
			end
		end
		addEventHandler ( "onClientGUIClick", menu_ferm, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)
			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Устроиться", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				guiGridListClear(shoplist)
				for k,v in pairs(getElementData(playerid, "cow_farms_table2")) do
					guiGridListAddRow(shoplist, v["number"], v["price"].."$", v["coef"].." процентов")
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				triggerServerEvent( "event_cow_farms", getRootElement(), playerid, "job", tonumber(text), 0 )
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			if getElementData(playerid, "cow_farms_table2") then
				guiGridListAddColumn(shoplist, "Скотобойни", 0.15)
				guiGridListAddColumn(shoplist, "Зарплата", 0.4)
				guiGridListAddColumn(shoplist, "Доход от продаж", 0.4)
				for k,v in pairs(getElementData(playerid, "cow_farms_table2")) do
					guiGridListAddRow(shoplist, v["number"], v["price"].."$", v["coef"].." процентов")
				end
			end
		end
		addEventHandler ( "onClientGUIClick", job_ferm, outputEditBox, false )
	end
	addEventHandler ( "onClientGUIClick", shop, outputEditBox, false )


	function outputEditBox( button, state, absoluteX, absoluteY )--список игроков
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

		local home,m2gui_width = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
			guiGridListClear(shoplist)
			for k,v in pairs(getElementsByType("player")) do
				guiGridListAddRow(shoplist, getElementData(v, "player_id")[1], getPlayerName(v), getElementData(v, "crimes_data"))
			end
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		guiGridListAddColumn(shoplist, "ИД", 0.15)
		guiGridListAddColumn(shoplist, "Ник", 0.7)
		guiGridListAddColumn(shoplist, "ОП", 0.1)
		for k,v in pairs(getElementsByType("player")) do
			guiGridListAddRow(shoplist, getElementData(v, "player_id")[1], getPlayerName(v), getElementData(v, "crimes_data"))
		end
	end
	addEventHandler ( "onClientGUIClick", handbook, outputEditBox, false )
end
addEvent( "event_tablet_fun", true )
addEventHandler ( "event_tablet_fun", getRootElement(), tablet_fun )


function zamena_img()
--------------------------------------------------------------замена куда нажал 1 раз----------------------------------------------------------------------------
	if info_tab == tab_player then
		triggerServerEvent( "event_inv_server_load", getRootElement(), playerid, "player", info3_selection_1, info1, info2, getPlayerName(playerid) )

	elseif info_tab == tab_car then
		triggerServerEvent( "event_inv_server_load", getRootElement(), playerid, "car", info3_selection_1, info1, info2, plate )

	elseif info_tab == tab_house then
		triggerServerEvent( "event_inv_server_load", getRootElement(), playerid, "house", info3_selection_1, info1, info2, house )
	end
end

function inv_create ()--создание инв-ря
	local text_width = 50.0
	local text_height = 50.0

	local width = 380.0+10
	local height = 215.0+(25.0*2)+10.0+30

	stats_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "", false )

	tabPanel = guiCreateTabPanel ( 10.0, 20.0, 310.0+10+text_width, 215.0+10+text_height, false, stats_window )
	tab_player = guiCreateTab( "Инвентарь "..getPlayerName ( playerid ), tabPanel )

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

				triggerServerEvent( "event_inv_server_load", getRootElement(), playerid, "player", info3, info1_selection_1, info2_selection_1, getPlayerName(playerid) )

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
				triggerServerEvent("event_setVehicleDoorOpenRatio_fun", getRootElement(), playerid, 1)
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

					triggerServerEvent( "event_inv_server_load", getRootElement(), playerid, "car", info3, info1_selection_1, info2_selection_1, plate )

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

					triggerServerEvent( "event_inv_server_load", getRootElement(), playerid, "house", info3, info1_selection_1, info2_selection_1, house )

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
					triggerServerEvent( "event_use_inv", getRootElement(), playerid, "player", info3, info1, info2 )
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
					triggerServerEvent( "event_throw_earth_server", getRootElement(), playerid, "player", info3, info1, info2, getPlayerName ( playerid ) )

				elseif tab_car == info_tab then
					local vehicleid = getPlayerVehicle(playerid)

					if vehicleid then
						triggerServerEvent( "event_throw_earth_server", getRootElement(), playerid, "car", info3, info1, info2, plate )
					end

				elseif tab_house == info_tab then
					triggerServerEvent( "event_throw_earth_server", getRootElement(), playerid, "house", info3, info1, info2, house )
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
	addEventHandler ( "onClientClick", getRootElement(), throw_earth )

end
addEvent( "event_inv_create", true )
addEventHandler ( "event_inv_create", getRootElement(), inv_create )

function inv_delet ()--удаление инв-ря
	if stats_window then
		showCursor( false )

		for i=0,max_inv do
			inv_slot_player[i] = {0,0,0}
			inv_slot_car[i] = {0,0,0}
			inv_slot_house[i] = {0,0,0}
		end

		house = ""

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

		triggerServerEvent("event_setVehicleDoorOpenRatio_fun", getRootElement(), playerid, 0)

		stats_window = nil
	end
end
addEvent( "event_inv_delet", true )
addEventHandler ( "event_inv_delet", getRootElement(), inv_delet )

function tune_close ( button, state, absoluteX, absoluteY )--закрытие окна
local vehicleid = getPlayerVehicle(playerid)

	if gui_window then
		destroyElement(gui_window)

		tune_color_2d = false
		gui_window = nil
		showCursor( false )

		if vehicleid and tune_business then
			for k,v in pairs(getVehicleUpgrades(vehicleid)) do
				removeVehicleUpgrade(vehicleid, v)
			end

			for k,v in pairs(getElementData(playerid, "car_upgrades_save")) do
				addVehicleUpgrade(vehicleid, v)
			end

			setVehiclePaintjob ( vehicleid, getElementData(playerid, "car_paint_save") )

			int_upgrades = 0
			int_paint = -1
			int_stage = 0
			tune_business = false
		end
	end
end
addEvent( "event_gui_delet", true )
addEventHandler ( "event_gui_delet", getRootElement(), tune_close )

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
	end
end
addEvent( "event_inv_load", true )
addEventHandler ( "event_inv_load", getRootElement(), inv_load )

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
	end
end
addEvent( "event_tab_load", true )
addEventHandler ( "event_tab_load", getRootElement(), tab_load )

function change_image (value, id3, filename)--замена картинок в инв-ре
	if value == "player" then
		guiStaticImageLoadImage ( inv_slot_player[id3][1], "image_inventory/"..filename..".png" )
	elseif value == "car" then
		guiStaticImageLoadImage ( inv_slot_car[id3][1], "image_inventory/"..filename..".png" )
	elseif value == "house" then
		guiStaticImageLoadImage ( inv_slot_house[id3][1], "image_inventory/"..filename..".png" )
	end
end
addEvent( "event_change_image", true )
addEventHandler ( "event_change_image", getRootElement(), change_image )

addEventHandler("onClientMouseLeave", getRootElement(),--покидание картинок в инв-ре
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

function showdebuginfo_b (key, keyState)
	if keyState == "down" then
		--debuginfo = not debuginfo
		hud = not hud
		setPlayerHudComponentVisible ( "ammo", hud )
		setPlayerHudComponentVisible ( "armour", hud )
		setPlayerHudComponentVisible ( "breath", hud )
		setPlayerHudComponentVisible ( "clock", hud )
		setPlayerHudComponentVisible ( "radar", hud )
		setPlayerHudComponentVisible ( "weapon", hud )
		showChat(hud)
	end
end

local addCommandHandler_marker = 0
addCommandHandler ( "marker",
function ( cmd, x,y )
	local playername = getPlayerName ( playerid )
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
