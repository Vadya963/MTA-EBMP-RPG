local screenWidth, screenHeight = guiGetScreenSize ( )
local m2font = guiCreateFont( "gui/m2font.ttf", 9 )
local m2font_dx = dxCreateFont ( "gui/m2font.ttf", 9 )--default-bold
local m2font_dx1 = "default-bold"--dxCreateFont ( "gui/m2font.ttf", 10 )
setDevelopmentMode ( true )
local debuginfo = false
local car_spawn_value = 0
local hud = true
local playerid = 0
local update_db_rang = 1
local roulette_number = {false, {0,0,0}, {}}
local timer = {false, 10, 10}

addEventHandler( "onClientResourceStart", resourceRoot,
function ( startedRes )
	if car_spawn_value == 0 then
		car_spawn_value = 1

		bindKey ( "F1", "down", showcursor_b )
		bindKey ( "F2", "down", showdebuginfo_b )
		bindKey ( "F3", "down", menu_mafia_2 )
		bindKey ( "F11", "down", showdebuginfo_b )
		bindKey( "vehicle_fire", "down", toggleNOS )

		setTimer(function()
			triggerServerEvent("event_reg_or_login", root, playerid)
		end, 5000, 1)
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
	[93] = {"колода карт", "шт"},
	[94] = {"квадрокоптер", "шт"},
	[95] = {"двигатель", "stage"},
	[96] = {"колесо", "марка"},
	[97] = {"банка краски", "цвет"},
	[98] = {"фара", "цвет"},
	[99] = {"винилы", "вариант"},
	[100] = {"гидравлика", "шт"},
	[101] = {"краска для колес", "цвет"},
	[102] = {"уголовное дело", "преступлений"},
}
local info1_png = -1 --номер картинки
local info2_png = -1 --значение картинки

local commands = {
	"/sms [ИД игрока] [текст] - отправить смс игроку",
	"/blackjack [invite | take | open] - сыграть в блэкджек",
	"/r [текст] - рация",
	"/setchanel [канал] - сменить канал в рации",
	"/ec [номер т/с] - эвакуция т/с",
	"/wc [сумма] - выписать чек",
	"/prison [ИД игрока] - посадить игрока в тюрьму (для полицейских)",
	"/lawyer [ИД игрока] - заплатить залог за игрока",
	"/search [player | car | house] [ИД игрока | номер т/с | номер дома] - обыскать игрока, т/с или дом (для полицейских)",
	"/takepolicetoken [ИД игрока] - забрать полицейский жетон (для полицейских)",
	"/sellhouse - создать дом (для риэлторов)",
	"/sellbusiness [номер бизнеса от 1 до 5] - создать бизнес (для риэлторов)",
	"/buyinthouse [номер интерьера от 1 до 29] - сменить интерьер дома",
	"/capture - захват территории (для банд)",
	"/me [текст] - описание действия от 1 лица",
	"/do [текст] - описание от 3 лица",
	"/try [текст] - попытка действия",
	"/b [текст] - ближний OOC чат",
	"/сс - очистить чат",
	"/marker [x координата] [y координата] - поставить маркер",
}

local commandsadm = {
	"/sub [ид предмета] [количество] - выдать себе предмет",
	"/subcar [ид предмета] [количество] - выдать предмет в тс",
	"/subearth [ид предмета] [количество] [количество на земле] - выдать предмет на землю",
	"/go [и 3 координаты] - тп на заданные координаты",
	"/pos [текст] - сохранить позицию в бд",
	"/global [текст] - глобальный чат",
	"/stime [часов] [минут] - установить время",
	"/inv [player | car | house] [имя игрока | номер т/с | номер дома] - чекнуть инв-рь",
	"/prisonplayer [ИД игрока] [время] [причина] - посадить игрока в тюрьму",
	"/dim [номер виртуального мира] - установить себе виртуальный мир",
	"/v [ид т/с] - создать тс",
	"/sellbusiness [номер бизнеса от 1 до 5] - создать бизнес (для риэлторов)",
	"/delv - удалить тс созданные через /v",
	"/rc [ИД игрока] - следить за игроком",
}

-----------эвенты------------------------------------------------------------------------
math.randomseed(getTickCount())
function random(min, max)
	return math.random(min, max)
end

function playerDamage_text ( attacker, weapon, bodypart, loss )--получение урона
	local ped = source

	for k,v in pairs(getElementData(playerid, "no_ped_damage")) do
		if v == ped then
			cancelEvent()
			break
		end
	end

	if getElementData(playerid, "job_player") == 15 and getElementModel(ped) == 264 then
		if weapon == 33 then
		else
			cancelEvent()
		end
	end
end
addEventHandler ( "onClientPedDamage", root, playerDamage_text )

function setPedOxygenLevel_fun ()--кислородный балон
	local count = 0
	
	setTimer(function()
		setPedOxygenLevel ( playerid, 4000 )
		count = count+1

		if count == 300 then
			setElementData(playerid, "OxygenLevel", false)
		end
	end, 1000, 300)

	setElementData(playerid, "OxygenLevel", true)
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
	playSound("parachute/body_hit_sound.mp3")
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

addEventHandler( "onClientElementStreamIn", root,
function ( )
	if getElementType(source) == "vehicle" then
		--setVehicleComponentVisible(source, "bump_front_dummy", false)
		--setVehicleComponentVisible(source, "bump_rear_dummy", false)
	end
end)


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

	if timer[1] then
		timer[3] = timer[3]-1

		if timer[3] == -1 then
			timer[1] = false
		end
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

local upgrades_car_table = {}
local uc_txt = fileOpen(":ebmp/upgrade/upgrades_car.txt")
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

function getPlayerVehicle( playerid )
	local vehicle = getPedOccupiedVehicle ( playerid )
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
	{2564.779296875,-1293.0673828125,1044.125, 2, "Выбросите коробку с продуктами, чтобы получить прибыль"},
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
		local text = "FPS: "..FPS.." | Ping: "..getPlayerPing(playerid).." | ID: "..getElementData(playerid, "player_id")[1].." | Players online: "..#getElementsByType("player").." | Minute in game: "..time_game.." | "..client_time
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

		local spl_gz = getElementData(playerid, "guns_zone2")
		local name_mafia = getElementData(playerid, "name_mafia")
		if spl_gz and spl_gz[1][1] == 1 then
			dxDrawRectangle( 0.0, screenHeight-16.0*6-124, 250.0, 16.0*3, tocolor( 0, 0, 0, 150 ) )
			dxdrawtext ( "Время: "..spl_gz[2].." сек", 2.0, screenHeight-16*6-124, 0.0, 0.0, tocolor( white[1], white[2], white[3] ), 1, m2font_dx1 )
			dxdrawtext ( "Атака "..name_mafia[spl_gz[1][3]][1]..": "..spl_gz[1][4].." очков", 2.0, screenHeight-16*5-124, 0.0, 0.0, tocolor( 255,0,50 ), 1, m2font_dx1 )
			dxdrawtext ( "Защита "..name_mafia[spl_gz[1][5]][1]..": "..spl_gz[1][6].." очков", 2.0, screenHeight-16*4-124, 0.0, 0.0, tocolor( 0,50,255 ), 1, m2font_dx1 )
		end

		if timer[1] then
			dxDrawImage ( (screenWidth-85), 238, 85, 85, "gui/timer.png" )
			dxDrawCircle ( (screenWidth-85)+(85/2), 238+(85/2), 30, -90.0, (360.0/timer[2])*timer[3]-90, tocolor( 255,50,50,200 ), tocolor( 255,50,50,200 ) )
			dxDrawImage ( (screenWidth-85), 238, 85, 85, "gui/timer_arrow.png", (360.0/timer[2])*timer[3] )
		end
	end

	local x,y,z = getElementPosition(playerid)
	local rx,ry,rz = getElementRotation(playerid)
	local heal_player = split(getElementHealth(playerid), ".")


	if isCursorShowing() then
		dxdrawtext ( x.." "..y.." "..z, 300.0, 40.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( rx.." "..ry.." "..rz, 300.0, 55.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )
		dxdrawtext ( "skin "..getElementModel(playerid)..", interior "..getElementInterior(playerid)..", dimension "..getElementDimension(playerid), 300.0, 70.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, m2font_dx1 )

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


	if roulette_number[1] then--рисование цифр рулетки
		local dimensions = dxGetTextWidth ( tostring(roulette_number[1]), 6, "pricedown" )
		dxDrawText ( tostring(roulette_number[1]), roulette_number[3][1]+roulette_number[3][3]+(tablet_width/2)-(dimensions/2), roulette_number[3][2]+roulette_number[3][4]-34, 0.0, 0.0, tocolor ( roulette_number[2][1], roulette_number[2][2], roulette_number[2][3], 255 ), 6, "pricedown", "left", "top", false, false, true )
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
	local vehicleid = getPlayerVehicle(playerid)

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
	for k,v in pairs(getElementData ( playerid, "repair_shop" )) do
		guiGridListAddRow(shoplist, v[1], v[3])
	end

	local buy_subject = m2gui_button( 10, 175, "Купить", false, tab_shop )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

		triggerServerEvent( "event_buy_subject_fun", root, playerid, text, number_business, 5 )
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
				triggerServerEvent( "event_addVehicleUpgrade", root, vehicleid, {int_upgrades[1], x,y,z, rx,ry,rz, sc}, playerid, number_business )
			end
		end
		addEventHandler ( "onClientGUIClick", tune_install_button, complete, false )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			triggerServerEvent( "event_removeVehicleUpgrade", root, vehicleid, playerid, number_business )
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
		for k,v in pairs(getElementData ( playerid, "weapon_cops" )) do
			guiGridListAddRow(shoplist, v[1])
		end

		for k,v in pairs(getElementData ( playerid, "sub_cops" )) do
			guiGridListAddRow(shoplist, v[1])
		end

		local buy_subject = m2gui_button( 5, 320, "Взять", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", root, playerid, text, number_business, value )
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
		for k,v in pairs(getElementData ( playerid, "mayoralty_shop" )) do
			guiGridListAddRow(shoplist, v[1], v[3])
		end

		local buy_subject = m2gui_button( 5, 320, "Купить", false, gui_window )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			triggerServerEvent( "event_buy_subject_fun", root, playerid, text, number_business, value )
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

			triggerServerEvent( "event_buy_subject_fun", root, playerid, text, number_business, value )
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

		triggerServerEvent( "event_buy_subject_fun", root, playerid, text, number_business, value )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

	if value == 1 then
		guiGridListAddColumn(shoplist, "Товары", column_width1)
		guiGridListAddColumn(shoplist, "Цена", column_width2)
		for k,v in pairs(getElementData ( playerid, "weapon_shop" )) do
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
addEventHandler ( "event_shop_menu", root, shop_menu )


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

		triggerServerEvent( "event_buycar", root, playerid, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_avto_bikes_menu", true )
addEventHandler ( "event_avto_bikes_menu", root, avto_bikes_menu )


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

		triggerServerEvent( "event_buycar", root, playerid, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_boats_menu", true )
addEventHandler ( "event_boats_menu", root, boats_menu )


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

		triggerServerEvent( "event_buycar", root, playerid, getVehicleModelFromName (text) )
	end
	addEventHandler ( "onClientGUIClick", buy_subject, complete, false )

end
addEvent( "event_helicopters_menu", true )
addEventHandler ( "event_helicopters_menu", root, helicopters_menu )


function tablet_fun()--создание планшета

	showCursor( true )

	local width = 720
	local height = 430

	local pos_x = screenWidth-width
	local pos_Y = screenHeight-height

	local width_fon = width/1.121--642
	local height_fon = height/1.194--360
	tablet_width = width_fon

	local width_fon_pos = width_fon/16.05--40
	local height_fon_pos = height_fon/12.41--29

	local browser = nil

	roulette_number[3] = {pos_x,pos_Y, width_fon_pos,height_fon_pos}

	gui_window = guiCreateStaticImage( pos_x, pos_Y, width, height, "comp/tablet-display.png", false )
	local fon = guiCreateStaticImage( width_fon_pos, height_fon_pos, width_fon, height_fon, "comp/low_fon.png", false, gui_window )

	local auction_menu = guiCreateStaticImage( 10, 10, 80, 60, "comp/auction.png", false, fon )
	local youtube = guiCreateStaticImage( 100, 10, 85, 60, "comp/youtube.png", false, fon )
	local wiki = guiCreateStaticImage( 195, 10, 66, 60, "comp/wiki.png", false, fon )
	local craft = guiCreateStaticImage( 270, 10, 55, 60, "comp/bookcraft.png", false, fon )
	local carparking = guiCreateStaticImage( 335, 10, 60, 60, "comp/carparking.png", false, fon )
	local shop = guiCreateStaticImage( 405, 10, 60, 60, "comp/shop.png", false, fon )
	local handbook = guiCreateStaticImage( 475, 10, 60, 60, "comp/handbook.png", false, fon )
	local admin = guiCreateStaticImage( 545, 10, 52, 60, "comp/admin.png", false, fon )
	local quest = guiCreateStaticImage( 10, 80, 60, 60, "comp/quest.png", false, fon )
	local slot = guiCreateStaticImage( 80, 80, 63, 60, "comp/slot.png", false, fon )
	local poker = guiCreateStaticImage( 150, 80, 60, 60, "comp/poker.png", false, fon )
	local roulette = guiCreateStaticImage( 220, 80, 70, 60, "comp/roulette.png", false, fon )
	local horse = guiCreateStaticImage( 300, 80, 60, 60, "comp/it.png", false, fon )
	local fortune = guiCreateStaticImage( 370, 80, 54, 60, "comp/fortune.png", false, fon )
	local menu_business = guiCreateStaticImage( 434, 80, 60, 60, "comp/shopb.png", false, fon )

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
				triggerServerEvent("event_sqlite_load", root, playerid, "auc")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(playerid, "auc")) do
						guiGridListAddRow(shoplist, v["i"], v["name_sell"], info_png[v["id1"]][1].." "..v["id2"].." "..info_png[v["id1"]][2], v["money"], v["name_buy"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--купить предмет
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

				if text == "" then
					sendMessage("[ERROR] Вы не выбрали предмет", red)
					return
				end
				
				triggerServerEvent("event_auction_buy_sell", root, playerid, "buy", text, 0, 0, 0 )
			end
			addEventHandler ( "onClientGUIClick", buy_subject, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--вернуть предмет
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

				if text == "" then
					sendMessage("[ERROR] Вы не выбрали предмет", red)
					return
				end

				triggerServerEvent("event_auction_buy_sell", root, playerid, "return", text, 0, 0, 0 )
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
					triggerServerEvent("event_auction_buy_sell", root, playerid, "sell", 0, id1, id2, money, name_buy)
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
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local cmd = m2gui_button( 0, 0, "Команды сервера", false, low_fon )
		local color_car = m2gui_button( 0, 20, "Цвета т/с", false, low_fon )
		local idpng = m2gui_button( 0, 20*2, "Предметы", false, low_fon )
		local work_table = m2gui_button( 0, 20*3, "Рабочий стол", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )--вернуться на раб стол
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", work_table, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local color = guiCreateStaticImage( 0, 0, 642, 223, "upgrade/color_car.png", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )
		end
		addEventHandler ( "onClientGUIClick", color_car, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			guiGridListAddColumn(shoplist, "Команды сервера", 1.5)

			for k,v in pairs(commands) do
				guiGridListAddRow(shoplist, v)
			end
		end
		addEventHandler ( "onClientGUIClick", cmd, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			guiGridListAddColumn(shoplist, "Ид", 0.1)
			guiGridListAddColumn(shoplist, "Предметы", 1.5)

			for k,v in ipairs(info_png) do
				if k ~= 0 then
					guiGridListAddRow(shoplist, k, v[1].." 0 "..v[2])
				end
			end
		end
		addEventHandler ( "onClientGUIClick", idpng, outputEditBox, false )
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

			triggerServerEvent("event_craft_fun", root, playerid, text )
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
			triggerServerEvent("event_sqlite_load", root, playerid, "carparking_table")
			guiGridListClear(shoplist)

			setTimer(function()
				for k,v in pairs(getElementData(playerid, "carparking_table")) do
					guiGridListAddRow(shoplist, v)
				end
			end, 1000, 1)
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--вернуть тс
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			if text == "" then
				sendMessage("[ERROR] Вы не выбрали т/с", red)
				return
			end

			triggerServerEvent("event_spawn_carparking", root, playerid, text )
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
			triggerServerEvent("event_cow_farms", root, playerid, "buy", 0,0 )
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
				triggerServerEvent("event_sqlite_load", root, playerid, "cow_farms_table1")
				guiGridListClear(shoplist)

				setTimer(function()
					if getElementData(playerid, "cow_farms_table1") then
						if isElement(shoplist) then
							for k,v in pairs(getElementData(playerid, "cow_farms_table1")) do
								guiGridListAddRow(shoplist, v[2], v[3])
							end
						end
					end
				end, 1000, 1)
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

				triggerServerEvent( "event_cow_farms", root, playerid, "menu", text, text2 )
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
				triggerServerEvent("event_sqlite_load", root, playerid, "cow_farms_table2")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(playerid, "cow_farms_table2")) do
						guiGridListAddRow(shoplist, v["number"], v["price"].."$", v["coef"].." процентов")
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				triggerServerEvent( "event_cow_farms", root, playerid, "job", tonumber(text), 0 )
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
				local row = guiGridListAddRow(shoplist, getElementData(v, "player_id")[1], getPlayerName(v), getElementData(v, "crimes_data"))
				local r,g,b = getPlayerNametagColor(playerid)
				guiGridListSetItemColor ( shoplist, row,2, r,g,b)
			end
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		guiGridListAddColumn(shoplist, "ИД", 0.15)
		guiGridListAddColumn(shoplist, "Ник", 0.7)
		guiGridListAddColumn(shoplist, "ОП", 0.1)
		for k,v in pairs(getElementsByType("player")) do
			local row = guiGridListAddRow(shoplist, getElementData(v, "player_id")[1], getPlayerName(v), getElementData(v, "crimes_data"))
			local r,g,b = getPlayerNametagColor(playerid)
			guiGridListSetItemColor ( shoplist, row,2, r,g,b)
		end
	end
	addEventHandler ( "onClientGUIClick", handbook, outputEditBox, false )


	function outputEditBox( button, state, absoluteX, absoluteY )--админ панель
		if getElementData(playerid, "admin_data") ~= 1 then
			sendMessage("[ERROR] Вы не админ", red)
			return
		end

		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local tp_player,m2gui_width,m2gui_height = m2gui_button( 0, 0, "Игроки", false, low_fon )
		local tp_interior_job,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "Здания", false, low_fon )
		local cmdadm,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "Команды админа", false, low_fon )
		local tp_player_db,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "account", false, low_fon )
		local tp_car,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "car_db", false, low_fon )
		local tp_house,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "house_db", false, low_fon )
		local tp_business,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "business_db", false, low_fon )
		local tp_cow_farms,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "cow_farms_db", false, low_fon )
		local timer_earth_clear,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "timer_earth_clear", false, low_fon )
		local log,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "скачать лог", false, low_fon )
		local work_table,m2gui_width,m2gui_height = m2gui_button( 0, m2gui_height, "Рабочий стол", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", work_table, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			triggerServerEvent("event_earth_true", root, playerid)
		end
		addEventHandler ( "onClientGUIClick", timer_earth_clear, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local res_t = 2

			triggerServerEvent("event_restartResource", root)
			sendMessage("лог скачается через "..res_t.." сек", lyme)

			setTimer(function()
				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] скачал лог сервера")
				triggerEvent("event_download", root)
			end, res_t*1000, 1)
		end
		addEventHandler ( "onClientGUIClick", log, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_player
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Телепорт", false, low_fon )
			local prison,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Посадить", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
				setCameraTarget(playerid)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				guiGridListClear(shoplist)
				for k,v in pairs(getElementsByType("player")) do
					local row = guiGridListAddRow(shoplist, getElementData(v, "player_id")[1], getPlayerName(v), getElementData(v, "crimes_data"))
					local r,g,b = getPlayerNametagColor(playerid)
					guiGridListSetItemColor (shoplist, row,2, r,g,b)
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				local id,player = getPlayerId(text)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				elseif not id then
					sendMessage("[ERROR] Такого игрока нет", red)
					return
				end

				local x,y,z = getElementPosition(player)
				setElementPosition(playerid, x,y,z)
				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] телепортировался к "..id.." ["..getElementData(player, "player_id")[1].."]")
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--prison
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				local id,player = getPlayerId(text)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				elseif not id then
					sendMessage("[ERROR] Такого игрока нет", red)
					return
				end

				triggerServerEvent("event_prisonplayer", root, playerid, "", text, 60, "Нарушение правил сервера")
			end
			addEventHandler ( "onClientGUIClick", prison, complete, false )

			guiGridListAddColumn(shoplist, "ИД", 0.15)
			guiGridListAddColumn(shoplist, "Ник", 0.7)
			guiGridListAddColumn(shoplist, "ОП", 0.1)
			for k,v in pairs(getElementsByType("player")) do
				local row = guiGridListAddRow(shoplist, getElementData(v, "player_id")[1], getPlayerName(v), getElementData(v, "crimes_data"))
				local r,g,b = getPlayerNametagColor(playerid)
				guiGridListSetItemColor (shoplist, row,2, r,g,b)
			end
		end
		addEventHandler ( "onClientGUIClick", tp_player, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_interior_job
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Телепорт", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				guiGridListClear(shoplist)
				for k,v in pairs(getElementData(playerid, "interior_job")) do
					guiGridListAddRow(shoplist, k, v[2])
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				local name,x,y,z = getElementData(playerid, "interior_job")[tonumber(text)][2],getElementData(playerid, "interior_job")[tonumber(text)][6],getElementData(playerid, "interior_job")[tonumber(text)][7],getElementData(playerid, "interior_job")[tonumber(text)][8]
				setElementPosition(playerid, x,y,z)
				sendMessage("Вы телепортировались к "..name, lyme)
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			guiGridListAddColumn(shoplist, "Номер", 0.15)
			guiGridListAddColumn(shoplist, "Название", 0.8)
			for k,v in pairs(getElementData(playerid, "interior_job")) do
				guiGridListAddRow(shoplist, k, v[2])
			end
		end
		addEventHandler ( "onClientGUIClick", tp_interior_job, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--cmdadm
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			guiGridListAddColumn(shoplist, "Команды админа", 1.5)

			for k,v in pairs(commandsadm) do
				guiGridListAddRow(shoplist, v)
			end
		end
		addEventHandler ( "onClientGUIClick", cmdadm, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_house
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
			local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local update_db,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Update DB", false, low_fon )
			local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Телепорт", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				triggerServerEvent("event_sqlite_load", root, playerid, "house_db")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(playerid, "house_db")) do
						guiGridListAddRow(shoplist, v["number"], v["door"], v["nalog"], v["x"], v["y"], v["z"], v["interior"], v["world"], v["inventory"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(playerid, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", red)
					return
				end

				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", root, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				local x,y,z = getElementData(playerid, "house_db")[tonumber(text)]["x"],getElementData(playerid, "house_db")[tonumber(text)]["y"],getElementData(playerid, "house_db")[tonumber(text)]["z"]
				setElementPosition(playerid, x,y,z)
				sendMessage("Вы телепортировались к "..text.." дому", lyme)
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "door", 0.1)
			guiGridListAddColumn(shoplist, "nalog", 0.1)
			guiGridListAddColumn(shoplist, "x", 0.2)
			guiGridListAddColumn(shoplist, "y", 0.2)
			guiGridListAddColumn(shoplist, "z", 0.2)
			guiGridListAddColumn(shoplist, "interior", 0.1)
			guiGridListAddColumn(shoplist, "world", 0.1)
			guiGridListAddColumn(shoplist, "inventory", 4.0)
			for k,v in pairs(getElementData(playerid, "house_db")) do
				guiGridListAddRow(shoplist, v["number"], v["door"], v["nalog"], v["x"], v["y"], v["z"], v["interior"], v["world"], v["inventory"])
			end
		end
		addEventHandler ( "onClientGUIClick", tp_house, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_business
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
			local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local update_db,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Update DB", false, low_fon )
			local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Телепорт", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				triggerServerEvent("event_sqlite_load", root, playerid, "business_db")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(playerid, "business_db")) do
						guiGridListAddRow(shoplist, v["number"], v["type"], v["price"], v["money"], v["nalog"], v["warehouse"], v["x"], v["y"], v["z"], v["interior"], v["world"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(playerid, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", red)
					return
				end

				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", root, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				local x,y,z = getElementData(playerid, "business_db")[tonumber(text)]["x"],getElementData(playerid, "business_db")[tonumber(text)]["y"],getElementData(playerid, "business_db")[tonumber(text)]["z"]
				setElementPosition(playerid, x,y,z)
				sendMessage("Вы телепортировались к "..text.." бизнесу", lyme)
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "type", 0.2)
			guiGridListAddColumn(shoplist, "price", 0.1)
			guiGridListAddColumn(shoplist, "money", 0.1)
			guiGridListAddColumn(shoplist, "nalog", 0.1)
			guiGridListAddColumn(shoplist, "warehouse", 0.1)
			guiGridListAddColumn(shoplist, "x", 0.2)
			guiGridListAddColumn(shoplist, "y", 0.2)
			guiGridListAddColumn(shoplist, "z", 0.2)
			guiGridListAddColumn(shoplist, "interior", 0.1)
			guiGridListAddColumn(shoplist, "world", 0.1)
			for k,v in pairs(getElementData(playerid, "business_db")) do
				guiGridListAddRow(shoplist, v["number"], v["type"], v["price"], v["money"], v["nalog"], v["warehouse"], v["x"], v["y"], v["z"], v["interior"], v["world"])
			end
		end
		addEventHandler ( "onClientGUIClick", tp_business, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_player_db
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
			local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local update_db,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Update DB", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				triggerServerEvent("event_sqlite_load", root, playerid, "account_db")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(playerid, "account_db")) do
						guiGridListAddRow(shoplist, v["name"], v["ban"], v["reason"], v["x"], v["y"], v["z"], v["reg_ip"], v["reg_serial"], v["heal"], v["alcohol"], v["satiety"], v["hygiene"], v["sleep"], v["drugs"], v["skin"], v["arrest"], v["crimes"], v["inventory"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(playerid, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", red)
					return
				end

				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", root, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			guiGridListAddColumn(shoplist, "name", 0.2)
			guiGridListAddColumn(shoplist, "ban", 0.1)
			guiGridListAddColumn(shoplist, "reason", 0.1)
			guiGridListAddColumn(shoplist, "x", 0.2)
			guiGridListAddColumn(shoplist, "y", 0.2)
			guiGridListAddColumn(shoplist, "z", 0.2)
			guiGridListAddColumn(shoplist, "reg_ip", 0.2)
			guiGridListAddColumn(shoplist, "reg_serial", 0.4)
			guiGridListAddColumn(shoplist, "heal", 0.1)
			guiGridListAddColumn(shoplist, "alcohol", 0.1)
			guiGridListAddColumn(shoplist, "satiety", 0.1)
			guiGridListAddColumn(shoplist, "hygiene", 0.1)
			guiGridListAddColumn(shoplist, "sleep", 0.1)
			guiGridListAddColumn(shoplist, "drugs", 0.1)
			guiGridListAddColumn(shoplist, "skin", 0.1)
			guiGridListAddColumn(shoplist, "arrest", 0.1)
			guiGridListAddColumn(shoplist, "crimes", 0.1)
			guiGridListAddColumn(shoplist, "inventory", 4.0)
			for k,v in pairs(getElementData(playerid, "account_db")) do
				guiGridListAddRow(shoplist, v["name"], v["ban"], v["reason"], v["x"], v["y"], v["z"], v["reg_ip"], v["reg_serial"], v["heal"], v["alcohol"], v["satiety"], v["hygiene"], v["sleep"], v["drugs"], v["skin"], v["arrest"], v["crimes"], v["inventory"])
			end
		end
		addEventHandler ( "onClientGUIClick", tp_player_db, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_car
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
			local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local update_db,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Update DB", false, low_fon )
			local refresh_car,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Пересоздать", false, low_fon )
			local dim_0,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Убрать", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				local vehicleid = getVehicleidFromPlate( text )
				for k,v in pairs(getVehicleOccupants(vehicleid)) do
					triggerServerEvent("event_removePedFromVehicle", root, v)
				end

				triggerServerEvent("event_destroyElement", root, vehicleid)
				triggerServerEvent("event_car_spawn", root, text)
				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] пересоздал т/с с номером "..text)
			end
			addEventHandler ( "onClientGUIClick", refresh_car, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				triggerServerEvent("event_sqlite_load", root, playerid, "car_db")
				guiGridListClear(shoplist)
				
				setTimer(function()
					for k,v in pairs(getElementData(playerid, "car_db")) do
						guiGridListAddRow(shoplist, v["number"], v["model"], v["nalog"], v["frozen"], v["evacuate"], v["x"], v["y"], v["z"], v["rot"], v["fuel"], v["car_rgb"], v["headlight_rgb"], v["paintjob"], v["tune"], v["stage"], v["probeg"], v["wheel"], v["hydraulics"], v["wheel_rgb"], v["theft"], v["inventory"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(playerid, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", red)
					return
				end

				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", root, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--dim_0
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", red)
					return
				end

				local vehicleid = getVehicleidFromPlate( text )

				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] убрал т/с с номером "..text)

				triggerServerEvent("event_setElementDimension", root, vehicleid, 1)
			end
			addEventHandler ( "onClientGUIClick", dim_0, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "model", 0.1)
			guiGridListAddColumn(shoplist, "nalog", 0.1)
			guiGridListAddColumn(shoplist, "frozen", 0.1)
			guiGridListAddColumn(shoplist, "evacuate", 0.1)
			guiGridListAddColumn(shoplist, "x", 0.2)
			guiGridListAddColumn(shoplist, "y", 0.2)
			guiGridListAddColumn(shoplist, "z", 0.2)
			guiGridListAddColumn(shoplist, "rot", 0.2)
			guiGridListAddColumn(shoplist, "fuel", 0.2)
			guiGridListAddColumn(shoplist, "car_rgb", 0.2)
			guiGridListAddColumn(shoplist, "headlight_rgb", 0.2)
			guiGridListAddColumn(shoplist, "paintjob", 0.1)
			guiGridListAddColumn(shoplist, "tune", 0.5)
			guiGridListAddColumn(shoplist, "stage", 0.1)
			guiGridListAddColumn(shoplist, "probeg", 0.2)
			guiGridListAddColumn(shoplist, "wheel", 0.1)
			guiGridListAddColumn(shoplist, "hydraulics", 0.1)
			guiGridListAddColumn(shoplist, "wheel_rgb", 0.2)
			guiGridListAddColumn(shoplist, "theft", 0.1)
			guiGridListAddColumn(shoplist, "inventory", 4.0)
			for k,v in pairs(getElementData(playerid, "car_db")) do
				guiGridListAddRow(shoplist, v["number"], v["model"], v["nalog"], v["frozen"], v["evacuate"], v["x"], v["y"], v["z"], v["rot"], v["fuel"], v["car_rgb"], v["headlight_rgb"], v["paintjob"], v["tune"], v["stage"], v["probeg"], v["wheel"], v["hydraulics"], v["wheel_rgb"], v["theft"], v["inventory"])
			end
		end
		addEventHandler ( "onClientGUIClick", tp_car, outputEditBox, false )

		function outputEditBox( button, state, absoluteX, absoluteY )--tp_cow_farms
			local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
			local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
			local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "", false, low_fon )

			local home,m2gui_width = m2gui_button( 0, height_fon-16, "Главная", false, low_fon )
			local update_db,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Update DB", false, low_fon )
			local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

			function outputEditBox ( button, state, absoluteX, absoluteY )
				destroyElement(low_fon)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				triggerServerEvent("event_sqlite_load", root, playerid, "cow_farms_table2")
				guiGridListClear(shoplist)
				
				setTimer(function()
					for k,v in pairs(getElementData(playerid, "cow_farms_table2")) do
						guiGridListAddRow(shoplist, v["number"], v["price"], v["coef"], v["money"], v["nalog"], v["warehouse"], v["prod"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(playerid, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", red)
					return
				end

				triggerServerEvent("event_admin_chat", root, playerid, getPlayerName(playerid).." ["..getElementData(playerid, "player_id")[1].."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", root, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "price", 0.1)
			guiGridListAddColumn(shoplist, "coef", 0.1)
			guiGridListAddColumn(shoplist, "money", 0.2)
			guiGridListAddColumn(shoplist, "nalog", 0.1)
			guiGridListAddColumn(shoplist, "warehouse", 0.1)
			guiGridListAddColumn(shoplist, "prod", 0.1)
			for k,v in pairs(getElementData(playerid, "cow_farms_table2")) do
				guiGridListAddRow(shoplist, v["number"], v["price"], v["coef"], v["money"], v["nalog"], v["warehouse"], v["prod"])
			end
		end
		addEventHandler ( "onClientGUIClick", tp_cow_farms, outputEditBox, false )
	end
	addEventHandler ( "onClientGUIClick", admin, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--квесты
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16, false, low_fon)

		local home,m2gui_width = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Выбрать", false, low_fon )
		local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
			triggerServerEvent("event_sqlite_load", root, playerid, "quest_table")
			guiGridListClear(shoplist)
				
			setTimer(function()
				for k,v in pairs(getElementData(playerid, "quest_table")) do
					local count = 0
					for k,v in pairs(v[8]) do
						if v ~= getPlayerName(playerid) then
							count = count+1
						end
					end

					if count == #v[8] then
						if tonumber(split(getElementData(playerid, "quest_select"), ":")[1]) == k then
							local r = guiGridListAddRow(shoplist, k, v[1], v[2]..v[3]..v[4], split(getElementData(playerid, "quest_select"), ":")[2].."/"..v[3], v[6], info_png[ v[7][1] ][1].." "..v[7][2].." "..info_png[ v[7][1] ][2])
						
							for i=1,guiGridListGetColumnCount (shoplist) do
								guiGridListSetItemColor ( shoplist, r,i, green[1], green[2], green[3])
							end
						else
							guiGridListAddRow(shoplist, k, v[1], v[2]..v[3]..v[4], "0/"..v[3], v[6], info_png[ v[7][1] ][1].." "..v[7][2].." "..info_png[ v[7][1] ][2])
						end
					end
				end
			end, 1000, 1)
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
			if text == "" then
				sendMessage("[ERROR] Вы ничего не выбрали", red)
				return
			end

			for k,v in pairs(getElementData(playerid, "quest_table")[tonumber(text)][8]) do
				if v == getPlayerName(playerid) then
					sendMessage("[ERROR] Вы выполнили этот квест", red)
					return
				end
			end

			for i=0,guiGridListGetRowCount (shoplist) do
				for j=1,guiGridListGetColumnCount (shoplist) do
					guiGridListSetItemColor ( shoplist, i,j, white[1], white[2], white[3])
				end
			end

			local r,c = guiGridListGetSelectedItem ( shoplist )
			for i=1,guiGridListGetColumnCount (shoplist) do
				guiGridListSetItemColor ( shoplist, r,i, green[1], green[2], green[3])
			end

			sendMessage("Вы взяли квест "..getElementData(playerid, "quest_table")[tonumber(text)][1], yellow)

			setElementData(playerid, "quest_select", text..":0")
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )

		guiGridListAddColumn(shoplist, "Номер", 0.1)
		guiGridListAddColumn(shoplist, "Название", 0.1)
		guiGridListAddColumn(shoplist, "Описание", 0.5)
		guiGridListAddColumn(shoplist, "Прогресс", 0.1)
		guiGridListAddColumn(shoplist, "Награда $", 0.1)
		guiGridListAddColumn(shoplist, "Награда предметом", 0.3)
		for k,v in pairs(getElementData(playerid, "quest_table")) do
			local count = 0
			for k,v in pairs(v[8]) do
				if v ~= getPlayerName(playerid) then
					count = count+1
				end
			end

			if count == #v[8] then
				if tonumber(split(getElementData(playerid, "quest_select"), ":")[1]) == k then
					local r = guiGridListAddRow(shoplist, k, v[1], v[2]..v[3]..v[4], split(getElementData(playerid, "quest_select"), ":")[2].."/"..v[3], v[6], info_png[ v[7][1] ][1].." "..v[7][2].." "..info_png[ v[7][1] ][2])
					
					for i=1,guiGridListGetColumnCount (shoplist) do
						guiGridListSetItemColor ( shoplist, r,i, green[1], green[2], green[3])
					end
				else
					guiGridListAddRow(shoplist, k, v[1], v[2]..v[3]..v[4], "0/"..v[3], v[6], info_png[ v[7][1] ][1].." "..v[7][2].." "..info_png[ v[7][1] ][2])
				end
			end
		end
	end
	addEventHandler ( "onClientGUIClick", quest, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--слоты
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local slots = guiCreateStaticImage( 0, 0, width_fon, height_fon-25, "comp/slot_0.png", false, low_fon )
		local slots_1 = guiCreateStaticImage( 102+59-30, 40+81-22, 60, 43, "comp/slot_1.png", false, slots )
		local slots_2 = guiCreateStaticImage( 248+59-30, 40+81-22, 60, 43, "comp/slot_1.png", false, slots )
		local slots_3 = guiCreateStaticImage( 394+59-30, 40+81-22, 60, 43, "comp/slot_1.png", false, slots )

		local home,m2gui_width1 = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width2 = m2gui_button( m2gui_width1, height_fon-16, "Крутить", false, low_fon )
		local edit = guiCreateEdit( m2gui_width2, height_fon-25, width_fon-m2gui_width1+m2gui_width2, 25, "укажите ставку", false, low_fon )
		local start, count, time_slot = false, 0, 20
		local randomize1 = 0
		local randomize2 = 0
		local randomize3 = 0

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			guiSetText(edit, "")
		end
		addEventHandler ( "onClientGUIClick", edit, outputEditBox, false )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGetText(edit)
			local cash = tonumber(text)
				
			if text == "" then
				sendMessage("[ERROR] Укажите ставку", red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", red)
				return
			end

			start = true

			setTimer(function()
				if not isElement(low_fon) then
					killTimer(sourceTimer)
					return
				end

				count = count+1

				randomize1 = random(1,6)
				randomize2 = random(1,6)
				randomize3 = random(1,6)

				guiStaticImageLoadImage ( slots_1, "comp/slot_"..randomize1..".png" )
				guiStaticImageLoadImage ( slots_2, "comp/slot_"..randomize2..".png" )
				guiStaticImageLoadImage ( slots_3, "comp/slot_"..randomize3..".png" )

				if count == time_slot then
					triggerServerEvent("event_slots", root, playerid, cash, randomize1, randomize2, randomize3)
					start,count = false,0
				end
			end, 500, time_slot)
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )
	end
	addEventHandler ( "onClientGUIClick", slot, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--poker
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local rb = {}
		rb[1] = m2gui_radiobutton ( 140, 0, 50, 15, "1", false, low_fon )
		rb[2] = m2gui_radiobutton ( 193, 0, 50, 15, "2", false, low_fon )
		rb[3] = m2gui_radiobutton ( 245, 0, 50, 15, "3", false, low_fon )
		rb[4] = m2gui_radiobutton ( 297, 0, 50, 15, "4", false, low_fon )
		rb[5] = m2gui_radiobutton ( 349, 0, 50, 15, "5", false, low_fon )
		local slots = guiCreateStaticImage( 0, 20, 433, 188, "comp/card/cards.png", false, low_fon )
		local count_card,count,coef,money,token = 5,1,0,0,0
		local radiobutton_table = {
			[1] = {0,0,0,0,0},
			[2] = {0,0,0,0,0},
			[3] = {0,0,0,0,0},
			[4] = {0,0,0,0,0}
		}
		radiobutton_table[1][1],radiobutton_table[2][1],radiobutton_table[3][1],radiobutton_table[4][1] = m2gui_label ( 14, 213, 100, 15, "себе", false, low_fon ), false, "0", guiCreateStaticImage( 14, 233, 100, 100, "comp/card/cd1c.png", false, low_fon )
		radiobutton_table[1][2],radiobutton_table[2][2],radiobutton_table[3][2],radiobutton_table[4][2] = m2gui_label ( 142, 213, 100, 15, "себе", false, low_fon ), false, "0", guiCreateStaticImage( 142, 233, 100, 100, "comp/card/cd1c.png", false, low_fon )
		radiobutton_table[1][3],radiobutton_table[2][3],radiobutton_table[3][3],radiobutton_table[4][3] = m2gui_label ( 270, 213, 100, 15, "себе", false, low_fon ), false, "0", guiCreateStaticImage( 270, 233, 100, 100, "comp/card/cd1c.png", false, low_fon )
		radiobutton_table[1][4],radiobutton_table[2][4],radiobutton_table[3][4],radiobutton_table[4][4] = m2gui_label ( 398, 213, 100, 15, "себе", false, low_fon ), false, "0", guiCreateStaticImage( 398, 233, 100, 100, "comp/card/cd1c.png", false, low_fon )
		radiobutton_table[1][5],radiobutton_table[2][5],radiobutton_table[3][5],radiobutton_table[4][5] = m2gui_label ( 526, 213, 100, 15, "себе", false, low_fon ), false, "0", guiCreateStaticImage( 526, 233, 100, 100, "comp/card/cd1c.png", false, low_fon )

		for i=1,count_card do
			guiLabelSetColor(radiobutton_table[1][i], gray[1], gray[2], gray[3])
			guiSetEnabled ( radiobutton_table[4][i], false )
		end

		local home,m2gui_width1 = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width2 = m2gui_button( m2gui_width1, height_fon-16, "Играть", false, low_fon )
		local edit = guiCreateEdit( m2gui_width2, height_fon-25, width_fon-m2gui_width1+m2gui_width2, 25, "укажите ставку", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			guiSetText(edit, "")
		end
		addEventHandler ( "onClientGUIClick", edit, outputEditBox, false )

		for i=1,count_card do
			function outputEditBox ( button, state, absoluteX, absoluteY )
				for k,v in pairs(radiobutton_table[4]) do
					if v == source then
						if radiobutton_table[2][k] then
							radiobutton_table[2][k] = false
							guiLabelSetColor(radiobutton_table[1][i], green[1], green[2], green[3])
						else
							radiobutton_table[2][k] = true
							guiLabelSetColor(radiobutton_table[1][i], red[1], red[2], red[3])
						end
					end
				end
			end
			addEventHandler ( "onClientGUIClick", radiobutton_table[4][i], outputEditBox, false )
		end

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGetText(edit)
			local cash = tonumber(text)
				
			if text == "" then
				sendMessage("[ERROR] Укажите ставку", red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", red)
				return
			end

			if count == 1 then
				coef = ""
				for k,v in pairs(getElementsByType("gui-radiobutton")) do
					if guiRadioButtonGetSelected(v) then
						coef = guiGetText(v)
					end
				end

				if coef == "" then
					sendMessage("[ERROR] Вы не выбрали коэффициент", red)
					return
				end

				count,token,money = 2,tonumber(guiGetText(edit))/tonumber(coef),tonumber(guiGetText(edit))

				for i=1,count_card do
					guiLabelSetColor(radiobutton_table[1][i], green[1], green[2], green[3])
					guiSetEnabled ( radiobutton_table[4][i], true )
				end

				local card = {"c","d","h","s"}
				local text = random(1,11)..card[random(1,#card)]

				for j=1,count_card do
					while true do
						local count = 0
						for i=1,count_card do
							if text ~= radiobutton_table[3][i] then
								count = count+1
							end
						end

						if count == count_card then
							break
						else
							text = random(1,11)..card[random(1,#card)]
						end
					end

					radiobutton_table[3][j] = text
					guiStaticImageLoadImage ( radiobutton_table[4][j], "comp/card/cd"..radiobutton_table[3][j]..".png" )
				end
			elseif count == 2 then
				local card = {"c","d","h","s"}
				local text = random(1,11)..card[random(1,#card)]

				for j=1,count_card do
					while true do
						local count = 0
						for i=1,count_card do
							if text ~= radiobutton_table[3][i] then
								count = count+1
							end
						end

						if count == count_card then
							break
						else
							text = random(1,11)..card[random(1,#card)]
						end
					end

					if not radiobutton_table[2][j] then
						radiobutton_table[3][j] = text
						guiStaticImageLoadImage ( radiobutton_table[4][j], "comp/card/cd"..radiobutton_table[3][j]..".png" )
					end
				end

				local text = ""
				for i=1,count_card do
					text = text..radiobutton_table[3][i]..","
				end
				
				triggerServerEvent("event_poker_win", root, playerid, text, money, coef, token)

				count = 1
				radiobutton_table[2][1],radiobutton_table[3][1] = false, "0"
				radiobutton_table[2][2],radiobutton_table[3][2] = false, "0"
				radiobutton_table[2][3],radiobutton_table[3][3] = false, "0"
				radiobutton_table[2][4],radiobutton_table[3][4] = false, "0"
				radiobutton_table[2][5],radiobutton_table[3][5] = false, "0"

				for i=1,count_card do
					guiLabelSetColor(radiobutton_table[1][i], gray[1], gray[2], gray[3])
					guiSetEnabled ( radiobutton_table[4][i], false )
				end
			end
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )
	end
	addEventHandler ( "onClientGUIClick", poker, outputEditBox, false )


	function roulette_fun( button, state, absoluteX, absoluteY )--рулетка
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon2.png", false, fon )
		local home,m2gui_width1 = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width2 = m2gui_button( m2gui_width1, height_fon-16, "Играть", false, low_fon )
		local edit = guiCreateEdit( m2gui_width2, height_fon-25, width_fon-m2gui_width1+m2gui_width2, 25, "укажите ставку", false, low_fon )

		local start, count, time_slot, id = false, 0, 100, ""
		local roulette_game = {}
		local Red = {1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36}
		local Black = {2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35}
		local to1 = {1,4,7,10,13,16,19,22,25,28,31,34}
		local to2 = {2,5,8,11,14,17,20,23,26,29,32,35}
		local to3 = {3,6,9,12,15,18,21,24,27,30,33,36}

		for i,v in ipairs(to3) do
			table.insert(roulette_game, guiCreateButton ( 6+(i*45), height_fon-25-45*5, 45, 45, tostring(v), false, low_fon ))
		end
		for i,v in ipairs(to2) do
			table.insert(roulette_game, guiCreateButton ( 6+(i*45), height_fon-25-45*4, 45, 45, tostring(v), false, low_fon ))
		end
		for i,v in ipairs(to1) do
			table.insert(roulette_game, guiCreateButton ( 6+(i*45), height_fon-25-45*3, 45, 45, tostring(v), false, low_fon ))
		end
		table.insert(roulette_game, guiCreateButton ( 0+(0*45), height_fon-25-45*5, 51, 45*5, "0", false, low_fon ))

		table.insert(roulette_game, guiCreateButton ( 6+(13*45), height_fon-25-45*5, 45+6, 45, "3-3", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(13*45), height_fon-25-45*4, 45+6, 45, "3-2", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(13*45), height_fon-25-45*3, 45+6, 45, "3-1", false, low_fon ))
		local roulette_button =		guiCreateButton ( 6+(13*45), height_fon-25-45*2, 45+6, 45*2, "", false, low_fon )

		table.insert(roulette_game, guiCreateButton ( 6+(1*45), height_fon-25-45*2, 45*4, 45, "1-12", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(5*45), height_fon-25-45*2, 45*4, 45, "13-24", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(9*45), height_fon-25-45*2, 45*4, 45, "25-36", false, low_fon ))

		table.insert(roulette_game, guiCreateButton ( 6+(1*45), height_fon-25-45, 45*2, 45, "1-18", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(3*45), height_fon-25-45, 45*2, 45, "EVEN", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(5*45), height_fon-25-45, 45*2, 45, "RED", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(7*45), height_fon-25-45, 45*2, 45, "BLACK", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(9*45), height_fon-25-45, 45*2, 45, "ODD", false, low_fon ))
		table.insert(roulette_game, guiCreateButton ( 6+(11*45), height_fon-25-45, 45*2, 45, "19-36", false, low_fon ))

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)

			roulette_number[1] = false
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			guiSetText(edit, "")
		end
		addEventHandler ( "onClientGUIClick", edit, outputEditBox, false )

		for k,v in pairs(roulette_game) do
			function outputEditBox ( button, state, absoluteX, absoluteY )
				if start then
					sendMessage("[ERROR] Вы играете", red)
					return
				end
				
				id = guiGetText(source)
				guiSetText(roulette_button, id)
			end
			addEventHandler ( "onClientGUIClick", v, outputEditBox, false )
		end

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGetText(edit)
			local cash = tonumber(text)
				
			if text == "" then
				sendMessage("[ERROR] Укажите ставку", red)
				return
			elseif id == "" then
				sendMessage("[ERROR] Вы не сделали ставку", red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", red)
				return
			end

			start = true

			setTimer(function()
				if not isElement(low_fon) then
					killTimer(sourceTimer)
					return
				end

				count = count+1

				local randomize = random(0,36)
				roulette_number[1] = randomize

				for k,v in pairs(Red) do
					if v == randomize then
						roulette_number[2] = {255,0,0}
					end
				end

				for k,v in pairs(Black) do
					if v == randomize then
						roulette_number[2] = {0,0,0}
					end
				end

				if randomize == 0 then
					roulette_number[2] = {255,255,255}
				end

				if count == time_slot then
					triggerServerEvent("event_roulette_fun", root, playerid, id, cash, randomize)
					start,count = false,0
				end
			end, 100, time_slot)
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )
	end
	addEventHandler ( "onClientGUIClick", roulette, roulette_fun, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--скачки
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local fon_it = guiCreateStaticImage( 0, 0, width_fon, height_fon-25, "comp/it/fon_it.png", false, low_fon )
		local horse_t = {
			[1] = {0,0,random(1,2),"b"},
			[2] = {0,0,random(3,4),"r"},
			[3] = {0,0,random(5,6),"y"},
			[4] = {0,0,random(7,8),"p"},
			[5] = {0,0,random(9,10),"g"},
		}

		horse_t[1][1] = guiCreateStaticImage( 0, 89, 128, 128, "comp/it/hrs1.png", false, fon_it )
		horse_t[1][2] = guiCreateStaticImage( 41, 9, 64, 32, "comp/it/bride1.png", false, horse_t[1][1] )
		
		horse_t[2][1] = guiCreateStaticImage( 0, 89+30*1, 128, 128, "comp/it/hrs1.png", false, fon_it )
		horse_t[2][2] = guiCreateStaticImage( 41, 9, 64, 32, "comp/it/rride1.png", false, horse_t[2][1] )

		horse_t[3][1] = guiCreateStaticImage( 0, 89+30*2, 128, 128, "comp/it/hrs1.png", false, fon_it )
		horse_t[3][2] = guiCreateStaticImage( 41, 9, 64, 32, "comp/it/yride1.png", false, horse_t[3][1] )

		horse_t[4][1] = guiCreateStaticImage( 0, 89+30*3, 128, 128, "comp/it/hrs1.png", false, fon_it )
		horse_t[4][2] = guiCreateStaticImage( 41, 9, 64, 32, "comp/it/pride1.png", false, horse_t[4][1] )

		horse_t[5][1] = guiCreateStaticImage( 0, 89+30*4, 128, 128, "comp/it/hrs1.png", false, fon_it )
		horse_t[5][2] = guiCreateStaticImage( 41, 9, 64, 32, "comp/it/gride1.png", false, horse_t[5][1] )

		for i=1,5 do
			guiSetEnabled ( horse_t[i][1], false )
		end

		local home,m2gui_width1 = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width2 = m2gui_button( m2gui_width1, height_fon-16, "Играть", false, low_fon )
		local start = false

		local rb, width_rb = m2gui_radiobutton ( m2gui_width2, height_fon-16, 60, 15, "1("..horse_t[1][3].."/1)", false, low_fon )
		local rb, width_rb = m2gui_radiobutton ( width_rb, height_fon-16, 60, 15, "2("..horse_t[2][3].."/1)", false, low_fon )
		local rb, width_rb = m2gui_radiobutton ( width_rb, height_fon-16, 60, 15, "3("..horse_t[3][3].."/1)", false, low_fon )
		local rb, width_rb = m2gui_radiobutton ( width_rb, height_fon-16, 60, 15, "4("..horse_t[4][3].."/1)", false, low_fon )
		local rb, width_rb = m2gui_radiobutton ( width_rb, height_fon-16, 70, 15, "5("..horse_t[5][3].."/1)", false, low_fon )

		local edit = guiCreateEdit( width_rb, height_fon-25, width_fon-m2gui_width1-m2gui_width2, 25, "укажите ставку", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			guiSetText(edit, "")
		end
		addEventHandler ( "onClientGUIClick", edit, outputEditBox, false )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGetText(edit)
			local cash = tonumber(text)
			local horse_player = 0

			for k,v in pairs(getElementsByType("gui-radiobutton")) do
				if guiRadioButtonGetSelected(v) then
					horse_player = tonumber(split(guiGetText(v), "(")[1])
				end
			end

			if horse_player == 0 then
				sendMessage("[ERROR] Вы не выбрали лошадь", red)
				return	
			elseif text == "" then
				sendMessage("[ERROR] Укажите ставку", red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", red)
				return
			end

			for k,v in pairs(horse_t) do
				guiStaticImageLoadImage ( v[1], "comp/it/hrs1.png" )
				guiStaticImageLoadImage ( v[2], "comp/it/"..v[4].."ride1.png" )
				local x,y = guiGetPosition(v[1], false)
				guiSetPosition(v[1], 0, y, false)
			end

			start = true

			setTimer(function()
				if not isElement(low_fon) or not start then
					killTimer(sourceTimer)
					return
				end

				for k,v in pairs(horse_t) do
					local x,y = guiGetPosition(v[1], false)
					guiSetPosition(v[1], x+random(1,10), y, false)

					local x,y = guiGetPosition(v[1], false)
					if x >= 525 then
						triggerServerEvent( "event_insider_track", root, playerid, cash, v[3], k, horse_player )

						start = false
						break
					end
				end
			end, 500, 0)

			local count = 0
			setTimer(function()
				if not isElement(low_fon) or not start then
					count = 0
					killTimer(sourceTimer)
					return
				end

				count = count+1

				for k,v in pairs(horse_t) do
					guiStaticImageLoadImage ( v[1], "comp/it/hrs"..count..".png" )
					guiStaticImageLoadImage ( v[2], "comp/it/"..v[4].."ride"..count..".png" )
				end

				if count == 8 then
					count = 0
				end
			end, 100, 0)
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )
	end
	addEventHandler ( "onClientGUIClick", horse, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--колесо удачи
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local home,m2gui_width1 = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width2 = m2gui_button( m2gui_width1, height_fon-16, "Играть", false, low_fon )
		local edit = guiCreateEdit( m2gui_width2, height_fon-25, width_fon, 25, "укажите ставку", false, low_fon )
		local start, count, time_slot, id, count2, fishka = false, 0, 0, 0, 0, false
		local fortune_game = {}
		local wheel_fortune = {40,1,2,1,5,1,2,1,5,1,2,1,10,1,20,1,5,1,2,1,5,2,1,2,1,2,40,1,2,1,5,1,2,1,10,5,2,1,20,1,2,5,1,2,1,10,2,1,5,1,2,1,10,2}

		table.insert(fortune_game, guiCreateButton ( 0+(214*0), height_fon-25-40*2, 214, 40, "1", false, low_fon ))
		table.insert(fortune_game, guiCreateButton ( 0+(214*1), height_fon-25-40*2, 214, 40, "2", false, low_fon ))
		table.insert(fortune_game, guiCreateButton ( 0+(214*2), height_fon-25-40*2, 214, 40, "5", false, low_fon ))

		table.insert(fortune_game, guiCreateButton ( 0+(214*0), height_fon-25-40*1, 214, 40, "10", false, low_fon ))
		table.insert(fortune_game, guiCreateButton ( 0+(214*1), height_fon-25-40*1, 214, 40, "20", false, low_fon ))
		table.insert(fortune_game, guiCreateButton ( 0+(214*2), height_fon-25-40*1, 214, 40, "40", false, low_fon ))

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
			roulette_number[1] = false
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			guiSetText(edit, "")
		end
		addEventHandler ( "onClientGUIClick", edit, outputEditBox, false )

		for k,v in pairs(fortune_game) do
			function outputEditBox ( button, state, absoluteX, absoluteY )
				if start then
					sendMessage("[ERROR] Вы играете", red)
					return
				end
				
				id = tonumber(guiGetText(source))

				if fishka then
					destroyElement(fishka)
				end

				fishka = guiCreateStaticImage( (214/2)-(36/2), 2, 36, 36, "comp/fishka.png", false, v )
			end
			addEventHandler ( "onClientGUIClick", v, outputEditBox, false )
		end

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGetText(edit)
			local cash = tonumber(text)
				
			if text == "" then
				sendMessage("[ERROR] Укажите ставку", red)
				return
			elseif id == 0 then
				sendMessage("[ERROR] Вы не сделали ставку", red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", red)
				return
			end

			start, time_slot = true, random(100,150)
			roulette_number[2] = {255,255,255}

			setTimer(function()
				if not isElement(low_fon) then
					killTimer(sourceTimer)
					return
				end

				count = count+1

				count2 = count2+1

				roulette_number[1] = wheel_fortune[count2]

				if count == time_slot then
					triggerServerEvent("event_fortune_fun", root, playerid, cash, id, wheel_fortune[count2])
					start,count = false,0
				end

				if count2 == 54 then
					count2 = 0
				end
			end, 100, time_slot)
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )

	end
	addEventHandler ( "onClientGUIClick", fortune, outputEditBox, false )


	function outputEditBox ( button, state, absoluteX, absoluteY )--меню бизнеса
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local shoplist = guiCreateGridList(0, 0, width_fon, height_fon-16-25, false, low_fon)
		local edit = guiCreateEdit ( 0, height_fon-16-25, width_fon, 25, "0", false, low_fon )
		local home,m2gui_width = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local complete_button,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Выполнить", false, low_fon )
		local refresh,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Обновить", false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
			triggerServerEvent("event_sqlite_load", root, playerid, "business_table")
			guiGridListClear(shoplist)

			setTimer(function()
				if getElementData(playerid, "business_table") then
					if isElement(shoplist) then
						for k,v in pairs(getElementData(playerid, "business_table")) do
							guiGridListAddRow(shoplist, v[2], v[3])
						end
					end
				end
			end, 1000, 1)
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		function complete ( button, state, absoluteX, absoluteY )--выполнение операции
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
			local text2 = tonumber(guiGetText ( edit ))
				
			if text == "" then
				sendMessage("[ERROR] Вы ничего не выбрали", red)
				return
			elseif not text2 then
				sendMessage("[ERROR] Введите число в белое поле", red)
				return
			end

			triggerServerEvent( "event_till_fun", root, playerid, text, text2 )
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )

		if getElementData(playerid, "business_table") then
			guiGridListAddColumn(shoplist, "Бизнес "..getElementData(playerid, "business_table")[1][1], 0.5)
			guiGridListAddColumn(shoplist, "", 0.4)
			for k,v in pairs(getElementData(playerid, "business_table")) do
				guiGridListAddRow(shoplist, v[2], v[3])
			end
		end
	end
	addEventHandler ( "onClientGUIClick", menu_business, outputEditBox, false )
end
addEvent( "event_tablet_fun", true )
addEventHandler ( "event_tablet_fun", root, tablet_fun )


function zamena_img()
--------------------------------------------------------------замена куда нажал 1 раз----------------------------------------------------------------------------
	if info_tab == tab_player then
		triggerServerEvent( "event_inv_server_load", root, playerid, "player", info3_selection_1, info1, info2, getPlayerName(playerid) )

	elseif info_tab == tab_car then
		triggerServerEvent( "event_inv_server_load", root, playerid, "car", info3_selection_1, info1, info2, plate )

	elseif info_tab == tab_house then
		triggerServerEvent( "event_inv_server_load", root, playerid, "house", info3_selection_1, info1, info2, house )
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

				triggerServerEvent( "event_inv_server_load", root, playerid, "player", info3, info1_selection_1, info2_selection_1, getPlayerName(playerid) )

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
				triggerServerEvent("event_setVehicleDoorOpenRatio_fun", root, playerid, 1)
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

					triggerServerEvent( "event_inv_server_load", root, playerid, "car", info3, info1_selection_1, info2_selection_1, plate )

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

					triggerServerEvent( "event_inv_server_load", root, playerid, "house", info3, info1_selection_1, info2_selection_1, house )

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
					triggerServerEvent( "event_use_inv", root, playerid, "player", info3, info1, info2 )
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
					triggerServerEvent( "event_throw_earth_server", root, playerid, "player", info3, info1, info2, getPlayerName ( playerid ) )

				elseif tab_car == info_tab then
					local vehicleid = getPlayerVehicle(playerid)

					if vehicleid then
						triggerServerEvent( "event_throw_earth_server", root, playerid, "car", info3, info1, info2, plate )
					end

				elseif tab_house == info_tab then
					triggerServerEvent( "event_throw_earth_server", root, playerid, "house", info3, info1, info2, house )
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

		triggerServerEvent("event_setVehicleDoorOpenRatio_fun", root, playerid, 0)

		stats_window = nil
	end
end
addEvent( "event_inv_delet", true )
addEventHandler ( "event_inv_delet", root, inv_delet )

function tune_close ( button, state, absoluteX, absoluteY )--закрытие окна
local vehicleid = getPlayerVehicle(playerid)

	if gui_window then
		destroyElement(gui_window)

		gui_window = nil
		showCursor( false )

		roulette_number[1] = false

		if tune_business then
			if int_upgrades ~= 0 then
				destroyElement(int_upgrades[2])
			end

			int_upgrades = 0
			tune_business = false
		end
	end
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
	local vehicleid = getPlayerVehicle(playerid)

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
		setElementData(playerid, "radar_visible", hud)
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
