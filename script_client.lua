local screenWidth, screenHeight = guiGetScreenSize ( )

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

local max_subject = 46--кол-во предметов

--выделение картинки
local gui_2dtext = false
local gui_pos_x = 0 --положение картинки x
local gui_pos_y = 0 --положение картинки y
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
	[11] = {"планшет", "шт"},
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
	[24] = {"ящик", "$ за штуку"},
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
	[42] = {"лекарство", "$ за штуку"},
	[43] = {"документы на", "бизнес"},
	[44] = {"админский жетон на имя", ""},
	[45] = {"риэлторская лицензия на имя", ""},
	[46] = {"радар", "шт"},
}
local info1_png = -1 --номер картинки
local info2_png = -1 --значение картинки

local earth = {}--слоты земли
local max_earth = 100

for i=1,max_earth do
	earth[i] = {0,0,0,0,0}
end

-----------эвенты------------------------------------------------------------------------
function earth_load (i, x, y, z, id1, id2)--изменения слотов земли
	earth[i][1] = x
	earth[i][2] = y
	earth[i][3] = z
	earth[i][4] = id1
	earth[i][5] = id2
end
addEvent( "event_earth_load", true )
addEventHandler ( "event_earth_load", getRootElement(), earth_load )

local fuel = 0--топливо авто для dxdrawimage
function fuel_load_fun (i)
	fuel = i
end
addEvent( "event_fuel_load", true )
addEventHandler ( "event_fuel_load", getRootElement(), fuel_load_fun )

local speed_car_device = 0--отображение скорости авто, 0-выкл, 1-вкл
function speed_car_device_fun (i)
	speed_car_device = i
end
addEvent( "event_speed_car_device_fun", true )
addEventHandler ( "event_speed_car_device_fun", getRootElement(), speed_car_device_fun )
-----------------------------------------------------------------------------------------

local image = {}--загрузка картинок для отображения на земле
for i=0,max_subject do
	image[i] = dxCreateTexture(i..".png")
end

local info_tab = nil
local info1 = -1 --номер картинки
local info2 = -1 --значение картинки
local info3 = -1 --слот картинки

--гуи окно
local stats_window = nil
local tabPanel = nil
local tab_player = nil
local tab_car = nil
local tab_house = nil

--кнопки инв-ря
local use_button = nil
local throw_button = nil

--окно тюнинга
local gui_window = nil

local plate = ""
local house = ""

local max_inv = 23
local inv_slot = {} -- инв-рь игрока
local inv_slot_car = {} -- инв-рь авто
local inv_slot_house = {} -- инв-рь дома

for i=0,max_inv do
	inv_slot[i] = {0,0,0}
	inv_slot_car[i] = {0,0,0}
	inv_slot_house[i] = {0,0,0}
end

function sendPlayerMessage(text, r, g, b)
	outputChatBox(text, r, g, b)
end

function getPlayerVehicle( playerid )
	local vehicle = getPedOccupiedVehicle ( playerid )
	return vehicle
end

function isPointInCircle3D(x, y, z, x1, y1, z1, radius)
	local hash = createColSphere ( x, y, z, radius )
	local area = isInsideColShape( hash, x1, y1, z1 )
	destroyElement(hash)
	return area
end

function getSpeed(vehicle)
	if vehicle then
		local x, y, z = getElementVelocity(vehicle)
		return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))*111.847*1.61--узнает скорость авто в км/ч
	end
end

local table_import_car = {
[445] = "car/admiral(smith-custom-iz-mafia-2)",
[429] = "car/banshee(isw-508-from-mafia-2)",
[434] = "car/hotknife(smith-34-hot-rod-mafia-2)",
[409] = "car/stretch(lassiter-series-75-hollywood-iz-mafia-2)",
[475] = "car/sabre(smith-thunderbolt-from-mafia-2)",
[433] = "car/barracks(millitary-truck-from-mafia-2)",
[405] = "car/sentinel(houstan-wasp-mafia-2)",
[474] = "car/hermes(hudson_hornet_1952)",
[527] = "car/cadrona(ford_thunderbird_1957)",
}

function car_import_fun(model)
	for k,v in pairs(table_import_car) do
		if k == model then
			local txd = engineLoadTXD ( v..".txd" )
			engineImportTXD ( txd, k )
			local dff = engineLoadDFF ( v..".dff" )
			engineReplaceModel ( dff, k )
			return
		end
	end
end
addEvent( "event_car_import_fun", true )
addEventHandler("event_car_import_fun",getRootElement(), car_import_fun)

local script_client = 0
addEventHandler( "onClientResourceStart", getRootElement( ),
function ( startedRes )
	if script_client == 0 then
		script_client = 1

		for k,v in pairs(table_import_car) do
			car_import_fun(k)
		end
	end
end)

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
	[9] = {"граната", 16},
	[12] = {"colt-45", 22},
	[13] = {"deagle", 24},
	[14] = {"AK-47", 30},
	[15] = {"M4", 31},
	[16] = {"tec-9", 32},
	[17] = {"MP5", 29},
	[18] = {"uzi", 28},
	[19] = {"слезоточивый газ", 17},
	[26] = {"silenced", 23},
	[34] = {"shotgun", 25},
	[35] = {"парашют", 46},
	[36] = {"дубинка", 3},
	[37] = {"бита", 5},
	[38] = {"нож", 4},
	[40] = {"лом", 15},
	[41] = {"sniper", 34},
}

local house_bussiness_radius = 5--радиус размещения бизнесов и домов
local house_pos = {}
local business_pos = {}
local job_pos = {}
function bussines_house_fun (i, x,y,z, value)
	if value == "biz" then
		business_pos[i] = {x,y,z}
	elseif value == "house" then
		house_pos[i] = {x,y,z}
	elseif value == "job" then
		job_pos[i] = {x,y,z}
	end
end
addEvent( "event_bussines_house_fun", true )
addEventHandler ( "event_bussines_house_fun", getRootElement(), bussines_house_fun )

--перемещение картинки
local lmb = 0--лкм
local gui_selection = false
local gui_selection_pos_x = 0 --положение картинки x
local gui_selection_pos_y = 0 --положение картинки y
local info3_selection = -1 --слот картинки
local info1_selection = -1 --номер картинки
local info2_selection = -1 --значение картинки

local info3_selection_1 = -1 --слот картинки
local info1_selection_1 = -1 --номер картинки
local info2_selection_1 = -1 --значение картинки

--выбор цвета для окна тюнинга
local tune_color_2d = false
local tune_color_r = 255
local tune_color_g = 0
local tune_color_b = 0

function createText ()
	--setTime( 0, 0 )

	local time = getRealTime()
	local playerid = getLocalPlayer()
	local client_time = " Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"]
	local text = "Ping: "..getPlayerPing(playerid).." | ".."Players online: "..#getElementsByType("player").." | "..client_time

	dxDrawText ( text, 2.0+1, 0.0+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
	dxDrawText ( text, 2.0, 0.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, "default-bold" )

	local x,y,z = getElementPosition(playerid)
	local rx,ry,rz = getElementRotation(playerid)
	dxDrawText ( x.." "..y.." "..z, 300.0+1, 40.0+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
	dxDrawText ( x.." "..y.." "..z, 300.0, 40.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, "default-bold" )
	dxDrawText ( rx.." "..ry.." "..rz, 300.0+1, 55.0+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
	dxDrawText ( rx.." "..ry.." "..rz, 300.0, 55.0, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, "default-bold" )

	local vehicle = getPlayerVehicle ( playerid )
	if vehicle then--отображение скорости авто
		local speed_table = split(getSpeed(vehicle), ".")
		local heal_table = split(getElementHealth(vehicle), ".")
		local fuel_table = split(fuel, ".")
		local speed_car = 0

		if getSpeed(vehicle) >= 240 then
			speed_car = 240*1.125+43
		else
			speed_car = getSpeed(vehicle)*1.125+43
		end

		local speed_vehicle = "vehicle speed "..speed_table[1].." km/h | heal "..heal_table[1].." | fuel "..fuel.." | gear "..getVehicleCurrentGear(vehicle)
		dxDrawText ( speed_vehicle, 5+1, screenHeight-16+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
		dxDrawText ( speed_vehicle, 5, screenHeight-16, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, "default-bold" )

		dxDrawImage ( screenWidth-250, screenHeight-250, 210, 210, "speedometer/speed_v.png" )
		dxDrawImage ( screenWidth-250, screenHeight-250, 210, 210, "speedometer/arrow_speed_v.png", speed_car )
		dxDrawImage ( (screenWidth-250)+(fuel*1.6+63), screenHeight-250+166, 6, 13, "speedometer/fuel_v.png" )
	end

	for k,vehicle in pairs(getElementsByType("vehicle")) do
		local xv,yv,zv = getElementPosition(vehicle)
		
		if isPointInCircle3D(x,y,z, xv,yv,zv, 20) then
			local coords = { getScreenFromWorldPosition( xv,yv,zv+1, 0, false ) }
			local plate = getVehiclePlateText(vehicle)

			if coords[1] and coords[2] then
				if speed_car_device == 1 then
					local coords = { getScreenFromWorldPosition( xv,yv,zv+1.5, 0, false ) }
					local speed_table = split(getSpeed(vehicle), ".")

					if coords[1] and coords[2] then
						dxDrawText ( speed_table[1].." km/h", coords[1]+1, coords[2]+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
						dxDrawText ( speed_table[1].." km/h", coords[1], coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, "default-bold" )
					end
				end

				dxDrawText ( plate, coords[1]+1, coords[2]+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
				dxDrawText ( plate, coords[1], coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, "default-bold" )
			end
		end
	end


	if house_pos ~= nil then
		for k,v in pairs(house_pos) do
			if isPointInCircle3D(x,y,z, house_pos[k][1],house_pos[k][2],house_pos[k][3], house_bussiness_radius) then
				dxDrawText ( "Дом #"..k.." (Нажмите ALT)", 5+1, screenHeight-31+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
				dxDrawText ( "Дом #"..k.." (Нажмите ALT)", 5, screenHeight-31, 0.0, 0.0, tocolor ( green[1], green[2], green[3], 255 ), 1, "default-bold" )
				break
			end
		end
	end

	if business_pos ~= nil then
		for k,v in pairs(business_pos) do
			if isPointInCircle3D(x,y,z, business_pos[k][1],business_pos[k][2],business_pos[k][3], house_bussiness_radius) then
				dxDrawText ( "Бизнес #"..k.." (Нажмите ALT)", 5+1, screenHeight-31+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
				dxDrawText ( "Бизнес #"..k.." (Нажмите ALT)", 5, screenHeight-31, 0.0, 0.0, tocolor ( green[1], green[2], green[3], 255 ), 1, "default-bold" )
				break
			end
		end
	end

	if job_pos ~= nil then
		for k,v in pairs(job_pos) do
			if isPointInCircle3D(x,y,z, job_pos[k][1],job_pos[k][2],job_pos[k][3], 5) then
				dxDrawText ( "Здание (Нажмите ALT)", 5+1, screenHeight-31+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
				dxDrawText ( "Здание (Нажмите ALT)", 5, screenHeight-31, 0.0, 0.0, tocolor ( green[1], green[2], green[3], 255 ), 1, "default-bold" )
				break
			end
		end
	end


	if gui_2dtext then--отображение инфы
		local width,height = guiGetPosition ( stats_window, false )
		local x = 9
		local y = 20+24
		local offset = dxGetFontHeight(1,"default-bold")
		if info1_png ~= 0 then
			local dimensions = dxGetTextWidth ( info_png[info1_png][1].." "..info2_png.." "..info_png[info1_png][2], 1, "default-bold" )
			--dxDrawRectangle( ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y, dimensions, offset, tocolor ( 0, 0, 0, 255 ), true )
			dxDrawText ( info_png[info1_png][1].." "..info2_png.." "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2)+1, height+gui_pos_y+y+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold", "left", "top", false, false, true )
			dxDrawText ( info_png[info1_png][1].." "..info2_png.." "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y, 0.0, 0.0, tocolor ( white[1], white[2], white[3], 255 ), 1, "default-bold", "left", "top", false, false, true )
		end
	end


	if gui_selection and info_tab == guiGetSelectedTab(tabPanel) then--выделение картинки
		local width,height = guiGetPosition ( stats_window, false )
		local x = 9
		local y = 20+24
		dxDrawRectangle( width+gui_selection_pos_x+x, height+gui_selection_pos_y+y, 50.0, 50.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 100 ), true )
	end


	for i=1,max_earth do--отображение предметов на земле
		local x,y,z = getElementPosition(playerid)
		local area = isPointInCircle3D( x, y, z, earth[i][1], earth[i][2], earth[i][3], 20 )

		if area and earth[i][4] ~= 0 then
			local coords = { getScreenFromWorldPosition( earth[i][1], earth[i][2], earth[i][3]-1, 0, false ) }
			if coords[1] and coords[2] then
				dxDrawImage ( coords[1], coords[2], 57, 57, image[ earth[i][4] ] )
			end

			local coords = { getScreenFromWorldPosition( earth[i][1], earth[i][2], earth[i][3]-1+0.2, 0, false ) }
			if coords[1] and coords[2] then
				dxDrawText ( "Нажмите E", coords[1]+1, coords[2]+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
				dxDrawText ( "Нажмите E", coords[1], coords[2], 0.0, 0.0, tocolor ( svetlo_zolotoy[1], svetlo_zolotoy[2], svetlo_zolotoy[3], 255 ), 1, "default-bold" )
			end
		end
	end


	if tune_color_2d then--выбор цвета для окна тюнинга
		local width,height = guiGetPosition ( gui_window, false )
		dxDrawRectangle( width+10, height+25, 160, 160, tocolor ( tune_color_r, tune_color_g, tune_color_b, 255 ), true )
	end
end
addEventHandler ( "onClientRender", getRootElement(), createText )

local number_business = 0
function tune_window_create (number)--создание окна тюнинга
	number_business = number

	local dimensions = dxGetTextWidth ( "Введите ИД", 1, "default-bold" )
	local dimensions1 = dxGetTextWidth ( "Введите цвет в RGB", 1, "default-bold" )
	local width = 300+50+10
	local height = 210.0+(25.0*1)+10
	gui_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, number_business.." бизнес, Автомастерская", false )
	local tune_text = guiCreateLabel ( 180, 25, dimensions, 20, "Введите ИД детали", false, gui_window )
	local tune_text_edit = guiCreateEdit ( 180, 50, 170, 20, "", false, gui_window )
	local tune_text = guiCreateLabel ( 180, 75, dimensions1, 20, "Введите цвет в RGB", false, gui_window )
	local tune_r_edit = guiCreateEdit ( 180, 100, 50, 20, "", false, gui_window )
	local tune_g_edit = guiCreateEdit ( 240, 100, 50, 20, "", false, gui_window )
	local tune_b_edit = guiCreateEdit ( 300, 100, 50, 20, "", false, gui_window )
	local tune_radio_button1 = guiCreateRadioButton ( 180, 125, 50, 15, "Авто", false, gui_window )
	local tune_radio_button2 = guiCreateRadioButton ( 240, 125, 50, 15, "Фары", false, gui_window )
	local tune_search_button = guiCreateButton( 180, 150, 170, 25, "Найти", false, gui_window )
	local tune_install_button = guiCreateButton( 180, 180, 170, 25, "Установить", false, gui_window )
	local tune_delet_button = guiCreateButton( 180, 210, 170, 25, "Удалить", false, gui_window )
	local tune_img = guiCreateStaticImage( 10, 25, 160, 160, "upgrade/999_w_s.png", false, gui_window )

	showCursor( true )

	function tune_img_load ( button, state, absoluteX, absoluteY )--поиск тюнинга
		local text = guiGetText ( tune_text_edit )
		local r1,g1,b1 = guiGetText ( tune_r_edit ), guiGetText ( tune_g_edit ), guiGetText ( tune_b_edit )
		local r,g,b = tonumber(r1), tonumber(g1), tonumber(b1)

		if text ~= "" then
			if tonumber(text) >= 1000 and tonumber(text) <= 1193 then
				tune_color_2d = false
				guiStaticImageLoadImage ( tune_img, "upgrade/"..text.."_w_s.jpg" )
			elseif tonumber(text) >= 0 and tonumber(text) <= 2 then
				local vehicleid = getPlayerVehicle(getLocalPlayer())

				if vehicleid then
					local model = getElementModel ( vehicleid )

					if paint[model] ~= nil and paint[model][tonumber(text)+1] ~= nil then
						tune_color_2d = false
						guiStaticImageLoadImage ( tune_img, "paintjob/"..paint[model][tonumber(text)+1]..".png" )
					end
				end
			end
		end

		if r1 ~= "" and g1 ~= "" and b1 ~= "" then
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
		local text = guiGetText ( tune_text_edit )
		local vehicleid = getPlayerVehicle(getLocalPlayer())
		local r1,g1,b1 = guiGetText ( tune_r_edit ), guiGetText ( tune_g_edit ), guiGetText ( tune_b_edit )
		local r,g,b = tonumber(r1), tonumber(g1), tonumber(b1)

		if text ~= "" and vehicleid then
			if tonumber(text) >= 1000 and tonumber(text) <= 1193 then
				local upgrades = getVehicleCompatibleUpgrades ( vehicleid )

				for v, upgrade in pairs ( upgrades ) do
					if upgrade == tonumber(text) then
						triggerServerEvent( "event_addVehicleUpgrade", getRootElement(), vehicleid, tonumber(text), "save", getLocalPlayer(), number_business )
						break
					end
				end
			elseif tonumber(text) >= 0 and tonumber(text) <= 2 then
				local model = getElementModel ( vehicleid )

				if paint[model] ~= nil and paint[model][tonumber(text)+1] ~= nil then
					triggerServerEvent( "event_setVehiclePaintjob", getRootElement(), vehicleid, tonumber(text), "save", getLocalPlayer(), number_business )
				end
			end
		end

		if r1 ~= "" and g1 ~= "" and b1 ~= "" and vehicleid then
			if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
				if guiRadioButtonGetSelected( tune_radio_button1 ) == true then
					triggerServerEvent( "event_setVehicleColor", getRootElement(), vehicleid, r, g, b, "save", getLocalPlayer(), number_business )

				elseif guiRadioButtonGetSelected( tune_radio_button2 ) == true then
					triggerServerEvent( "event_setVehicleHeadLightColor", getRootElement(), vehicleid, r, g, b, "save", getLocalPlayer(), number_business )
				end
			end
		end
	end
	addEventHandler ( "onClientGUIClick", tune_install_button, tune_upgrade, false )

	function tune_delet ( button, state, absoluteX, absoluteY )--удаление тюнинга
		local text = guiGetText ( tune_text_edit )
		local vehicleid = getPlayerVehicle(getLocalPlayer())

		if text ~= "" and vehicleid then
			if tonumber(text) >= 1000 and tonumber(text) <= 1193 then
				local upgrades = getVehicleUpgrades ( vehicleid )

				for v, upgrade in pairs ( upgrades ) do
					if upgrade == tonumber(text) then
						triggerServerEvent( "event_removeVehicleUpgrade", getRootElement(), vehicleid, tonumber(text), "save", getLocalPlayer(), number_business )
						break
					end
				end
			end
		end
	end
	addEventHandler ( "onClientGUIClick", tune_delet_button, tune_delet, false )

	function tune_text_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_text_edit, "" )
		guiSetText ( tune_r_edit, "" )
		guiSetText ( tune_g_edit, "" )
		guiSetText ( tune_b_edit, "" )
	end
	addEventHandler ( "onClientGUIClick", tune_text_edit, tune_text_edit_fun, false )

	function tune_r_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_r_edit, "" )
		guiSetText ( tune_text_edit, "" )
	end
	addEventHandler ( "onClientGUIClick", tune_r_edit, tune_r_edit_fun, false )

	function tune_g_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_g_edit, "" )
		guiSetText ( tune_text_edit, "" )
	end
	addEventHandler ( "onClientGUIClick", tune_g_edit, tune_g_edit_fun, false )

	function tune_b_edit_fun ( button, state, absoluteX, absoluteY )--удаление текста в гуи edit
		guiSetText ( tune_b_edit, "" )
		guiSetText ( tune_text_edit, "" )
	end
	addEventHandler ( "onClientGUIClick", tune_b_edit, tune_b_edit_fun, false )

end
addEvent( "event_tune_create", true )
addEventHandler ( "event_tune_create", getRootElement(), tune_window_create )


function business_menu(number)--создание окна бизнеса
	number_business = number

	showCursor( true )

	local dimensions = dxGetTextWidth ( "Укажите сумму", 1, "default-bold" )
	local width = 220+10
	local height = 165.0+(25.0*1)+10
	gui_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, number_business.." бизнес, Касса", false )
	local tune_text = guiCreateLabel ( (width/2)-(dimensions/2), 20, dimensions, 20, "Укажите сумму", false, gui_window )
	local tune_text_edit = guiCreateEdit ( 0, 40, 220, 20, "", false, gui_window )
	local tune_radio_button1 = guiCreateRadioButton ( 0, 65, 220, 15, "Забрать деньги из кассы", false, gui_window )
	local tune_radio_button2 = guiCreateRadioButton ( 0, 90, 220, 15, "Положить деньги в кассу", false, gui_window )
	local tune_radio_button3 = guiCreateRadioButton ( 0, 115, 220, 15, "Установить стоимость товара", false, gui_window )
	local tune_radio_button4 = guiCreateRadioButton ( 0, 140, 220, 15, "Установить цену закупки товара", false, gui_window )
	local complete_button = guiCreateButton( 0, 165, 220, 25, "Выполнить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGetText ( tune_text_edit )

		if tonumber(text) ~= nil and tonumber(text) >= 1 then
			if guiRadioButtonGetSelected( tune_radio_button1 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), getLocalPlayer(), number_business, tonumber(text), "withdraw" )

			elseif guiRadioButtonGetSelected( tune_radio_button2 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), getLocalPlayer(), number_business, tonumber(text), "deposit" )

			elseif guiRadioButtonGetSelected( tune_radio_button3 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), getLocalPlayer(), number_business, tonumber(text), "price" )

			elseif guiRadioButtonGetSelected( tune_radio_button4 ) == true then
				triggerServerEvent( "event_till_fun", getRootElement(), getLocalPlayer(), number_business, tonumber(text), "buyprod" )
			end
		end
	end
	addEventHandler ( "onClientGUIClick", complete_button, complete, false )

end
addEvent( "event_business_menu", true )
addEventHandler ( "event_business_menu", getRootElement(), business_menu )


function weapon_menu(number)--создание окна аммунации
	number_business = number

	showCursor( true )

	local width = 200+10
	local height = 320.0+(25.0*1)+10
	local text_width = 50.0
	local text_height = 50.0
	gui_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, number_business.." бизнес, Магазин оружия", false )

	local weaponlist = guiCreateGridList(0, 20, 200, 320-30, false, gui_window)
	guiGridListAddColumn(weaponlist, "Оружие", 1)

	for k,v in pairs(weapon) do
		guiGridListAddRow(weaponlist, v[1])
	end

	local buy_weapon = guiCreateButton( 0, 320, 200, 25, "Купить", false, gui_window )

	function complete ( button, state, absoluteX, absoluteY )--выполнение операции
		local text = guiGridListGetItemText ( weaponlist, guiGridListGetSelectedItem ( weaponlist ) )

		triggerServerEvent( "event_weaponbuy_fun", getRootElement(), getLocalPlayer(), text, number_business )
	end
	addEventHandler ( "onClientGUIClick", buy_weapon, complete, false )

end
addEvent( "event_weapon_menu", true )
addEventHandler ( "event_weapon_menu", getRootElement(), weapon_menu )


function tablet_fun()--создание окна бизнеса

	showCursor( true )

	local width = 720
	local height = 430

	local width_fon = 642
	local height_fon = 360

	local width_fon_pos = 40
	local height_fon_pos = 29

	gui_window = guiCreateStaticImage( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "comp/tablet-display.png", false )
	local fon = guiCreateStaticImage( width_fon_pos, height_fon_pos, width_fon, height_fon, "comp/fon.png", false, gui_window )

	local loadURL = guiCreateButton ( 0, 0, 40, 25, "HOME", false, fon )
	local NavigateBack = guiCreateButton ( 40, 0, 20, 25, "<", false, fon )
	local NavigateForward = guiCreateButton ( 60, 0, 20, 25, ">", false, fon )
	local reloadPage = guiCreateButton ( 80, 0, 20, 25, "F5", false, fon )
	local home = guiCreateButton ( 100, 0, 40, 25, "LOAD", false, fon )
	local addressBar = guiCreateEdit ( 140, 0, width_fon-140, 25, "", false, fon )

	local auction = guiCreateStaticImage( 10, 30, 60, 60, "comp/auction.png", false, fon )

	function outputEditBox ( button, state, absoluteX, absoluteY )--список бизнесов

	end
	addEventHandler ( "onClientGUIClick", auction, outputEditBox, false )

	--[[local browser = guiCreateBrowser( width_fon_pos, height_fon_pos+25, width_fon, height_fon-25, false, false, false, fon )
	local theBrowser = guiGetBrowser( browser )

	addEventHandler("onClientBrowserCreated", theBrowser, 
	function()
		loadBrowserURL(theBrowser, "https://www.youtube.com/")
	end)

	addEventHandler( "onClientBrowserDocumentReady", theBrowser, function( )
		guiSetText( addressBar, getBrowserURL( theBrowser ) )
	end )

	addEventHandler( "onClientGUIClick", resourceRoot, 
	function()
		if source == NavigateBack then
			navigateBrowserBack(theBrowser)
		elseif source == NavigateForward then
			navigateBrowserForward(theBrowser)
		elseif source == reloadPage then
			reloadBrowserPage(theBrowser)
		end
	end)]]

end
addEvent( "event_tablet_fun", true )
addEventHandler ( "event_tablet_fun", getRootElement(), tablet_fun )


function zamena_img()
--------------------------------------------------------------замена куда нажал 1 раз----------------------------------------------------------------------------
	if info_tab == tab_player then
		inv_slot[info3_selection][2] = info1_selection_1
		inv_slot[info3_selection][3] = info2_selection_1

		triggerServerEvent( "event_inv_server_load", getRootElement(), getLocalPlayer(), "player", info3_selection, info1_selection_1, info2_selection_1, getPlayerName(getLocalPlayer()) )
		
		change_image ( "player", info3_selection, info1_selection_1 )


	elseif info_tab == tab_car then
		inv_slot_car[info3_selection][2] = info1_selection_1
		inv_slot_car[info3_selection][3] = info2_selection_1

		triggerServerEvent( "event_inv_server_load", getRootElement(), getLocalPlayer(), "car", info3_selection, info1_selection_1, info2_selection_1, plate )
		
		change_image ( "car", info3_selection, info1_selection_1 )

	elseif info_tab == tab_house then
		inv_slot_house[info3_selection][2] = info1_selection_1
		inv_slot_house[info3_selection][3] = info2_selection_1

		triggerServerEvent( "event_inv_server_load", getRootElement(), getLocalPlayer(), "house", info3_selection, info1_selection_1, info2_selection_1, house )
		
		change_image ( "house", info3_selection, info1_selection_1 )
	end
end

function inv_create ()--создание инв-ря

	local width = 400.0+100+10
	local height = 215.0+(25.0*2)+10.0+30

	local text_width = 50.0
	local text_height = 50.0

	stats_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "", false )
	tabPanel = guiCreateTabPanel ( 0.0, 20.0, 310.0+10+text_width, 215.0+10+text_height, false, stats_window )
	tab_player = guiCreateTab( "Инвентарь "..getPlayerName ( getLocalPlayer() ), tabPanel )

	showCursor( true )

	inv_slot[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, inv_slot[0][2]..".png", false, tab_player )
	inv_slot[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, inv_slot[1][2]..".png", false, tab_player )
	inv_slot[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, inv_slot[2][2]..".png", false, tab_player )
	inv_slot[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, inv_slot[3][2]..".png", false, tab_player )
	inv_slot[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, inv_slot[4][2]..".png", false, tab_player )
	inv_slot[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, inv_slot[5][2]..".png", false, tab_player )

	inv_slot[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, inv_slot[6][2]..".png", false, tab_player )
	inv_slot[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, inv_slot[7][2]..".png", false, tab_player )
	inv_slot[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, inv_slot[8][2]..".png", false, tab_player )
	inv_slot[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, inv_slot[9][2]..".png", false, tab_player )
	inv_slot[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, inv_slot[10][2]..".png", false, tab_player )
	inv_slot[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, inv_slot[11][2]..".png", false, tab_player )

	inv_slot[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, inv_slot[12][2]..".png", false, tab_player )
	inv_slot[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, inv_slot[13][2]..".png", false, tab_player )
	inv_slot[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, inv_slot[14][2]..".png", false, tab_player )
	inv_slot[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, inv_slot[15][2]..".png", false, tab_player )
	inv_slot[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, inv_slot[16][2]..".png", false, tab_player )
	inv_slot[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, inv_slot[17][2]..".png", false, tab_player )

	inv_slot[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, inv_slot[18][2]..".png", false, tab_player )
	inv_slot[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, inv_slot[19][2]..".png", false, tab_player )
	inv_slot[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, inv_slot[20][2]..".png", false, tab_player )
	inv_slot[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, inv_slot[21][2]..".png", false, tab_player )
	inv_slot[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, inv_slot[22][2]..".png", false, tab_player )
	inv_slot[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, inv_slot[23][2]..".png", false, tab_player )

	for i=0,max_inv do
		function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
			local x,y = guiGetPosition ( inv_slot[i][1], false )

			info3 = i
			info1 = inv_slot[i][2]
			info2 = inv_slot[i][3]

			if lmb == 0 then
				if info1 == 1 or info1 == 0 then
					return
				end

				gui_selection = true
				info_tab = tab_player
				gui_selection_pos_x = x
				gui_selection_pos_y = y
				info3_selection = info3
				info1_selection = info1
				info2_selection = info2
				lmb = 1
			else
				info3_selection_1 = info3
				info1_selection_1 = info1
				info2_selection_1 = info2

				--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
				if inv_slot[info3_selection_1][2] ~= 0 then
					if info1 == 1 or info1 == 0 then
						return
					end

					info_tab = tab_player
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection = info3
					info1_selection = info1
					info2_selection = info2
					return
				end

				inv_slot[info3_selection_1][2] = info1_selection
				inv_slot[info3_selection_1][3] = info2_selection

				triggerServerEvent( "event_inv_server_load", getRootElement(), getLocalPlayer(), "player", info3_selection_1, info1_selection, info2_selection, getPlayerName(getLocalPlayer()) )

				change_image ( "player", info3_selection_1, info1_selection )

				zamena_img()

				gui_selection = false
				info_tab = nil
				lmb = 0
			end

			--sendPlayerMessage(info3.." "..info1.." "..info2)
		end
		addEventHandler ( "onClientGUIClick", inv_slot[i][1], outputEditBox, false )
	end

	for i=0,max_inv do
		function outputEditBox ( absoluteX, absoluteY, gui )--наведение на картинки в инв-ре
			gui_2dtext = true
			local x,y = guiGetPosition ( inv_slot[i][1], false )
			gui_pos_x = x
			gui_pos_y = y
			info1_png = inv_slot[i][2]
			info2_png = inv_slot[i][3]
		end
		addEventHandler( "onClientMouseEnter", inv_slot[i][1], outputEditBox, false )
	end

	if plate ~= "" then
		tab_car = guiCreateTab( "Авто "..plate, tabPanel )
		inv_slot_car[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, inv_slot_car[0][2]..".png", false, tab_car )
		inv_slot_car[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, inv_slot_car[1][2]..".png", false, tab_car )
		inv_slot_car[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, inv_slot_car[2][2]..".png", false, tab_car )
		inv_slot_car[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, inv_slot_car[3][2]..".png", false, tab_car )
		inv_slot_car[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, inv_slot_car[4][2]..".png", false, tab_car )
		inv_slot_car[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, inv_slot_car[5][2]..".png", false, tab_car )

		inv_slot_car[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, inv_slot_car[6][2]..".png", false, tab_car )
		inv_slot_car[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, inv_slot_car[7][2]..".png", false, tab_car )
		inv_slot_car[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, inv_slot_car[8][2]..".png", false, tab_car )
		inv_slot_car[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, inv_slot_car[9][2]..".png", false, tab_car )
		inv_slot_car[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, inv_slot_car[10][2]..".png", false, tab_car )
		inv_slot_car[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, inv_slot_car[11][2]..".png", false, tab_car )

		inv_slot_car[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, inv_slot_car[12][2]..".png", false, tab_car )
		inv_slot_car[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, inv_slot_car[13][2]..".png", false, tab_car )
		inv_slot_car[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, inv_slot_car[14][2]..".png", false, tab_car )
		inv_slot_car[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, inv_slot_car[15][2]..".png", false, tab_car )
		inv_slot_car[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, inv_slot_car[16][2]..".png", false, tab_car )
		inv_slot_car[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, inv_slot_car[17][2]..".png", false, tab_car )

		inv_slot_car[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, inv_slot_car[18][2]..".png", false, tab_car )
		inv_slot_car[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, inv_slot_car[19][2]..".png", false, tab_car )
		inv_slot_car[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, inv_slot_car[20][2]..".png", false, tab_car )
		inv_slot_car[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, inv_slot_car[21][2]..".png", false, tab_car )
		inv_slot_car[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, inv_slot_car[22][2]..".png", false, tab_car )
		inv_slot_car[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, inv_slot_car[23][2]..".png", false, tab_car )

		for i=0,max_inv do
			function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
				local x,y = guiGetPosition ( inv_slot_car[i][1], false )

				info3 = i
				info1 = inv_slot_car[i][2]
				info2 = inv_slot_car[i][3]

				if lmb == 0 then
					if info1 == 1 or info1 == 0 then
						return
					end

					gui_selection = true
					info_tab = tab_car
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection = info3
					info1_selection = info1
					info2_selection = info2
					lmb = 1
				else
					info3_selection_1 = info3
					info1_selection_1 = info1
					info2_selection_1 = info2

					--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
					if inv_slot_car[info3_selection_1][2] ~= 0 then
						if info1 == 1 or info1 == 0 then
							return
						end
						
						info_tab = tab_car
						gui_selection_pos_x = x
						gui_selection_pos_y = y
						info3_selection = info3
						info1_selection = info1
						info2_selection = info2
						return
					end

					inv_slot_car[info3_selection_1][2] = info1_selection
					inv_slot_car[info3_selection_1][3] = info2_selection

					triggerServerEvent( "event_inv_server_load", getRootElement(), getLocalPlayer(), "car", info3_selection_1, info1_selection, info2_selection, plate )

					change_image ( "car", info3_selection_1, info1_selection )

					zamena_img()

					gui_selection = false
					info_tab = nil
					lmb = 0
				end

				--sendPlayerMessage(info3.." "..info1.." "..info2)
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
		inv_slot_house[0][1] = guiCreateStaticImage( 10.0, 10.0, text_width, text_height, inv_slot_house[0][2]..".png", false, tab_house )
		inv_slot_house[1][1] = guiCreateStaticImage( 70.0, 10.0, text_width, text_height, inv_slot_house[1][2]..".png", false, tab_house )
		inv_slot_house[2][1] = guiCreateStaticImage( 130.0, 10.0, text_width, text_height, inv_slot_house[2][2]..".png", false, tab_house )
		inv_slot_house[3][1] = guiCreateStaticImage( 190.0, 10.0, text_width, text_height, inv_slot_house[3][2]..".png", false, tab_house )
		inv_slot_house[4][1] = guiCreateStaticImage( 250.0, 10.0, text_width, text_height, inv_slot_house[4][2]..".png", false, tab_house )
		inv_slot_house[5][1] = guiCreateStaticImage( 310.0, 10.0, text_width, text_height, inv_slot_house[5][2]..".png", false, tab_house )

		inv_slot_house[6][1] = guiCreateStaticImage( 10.0, 70.0, text_width, text_height, inv_slot_house[6][2]..".png", false, tab_house )
		inv_slot_house[7][1] = guiCreateStaticImage( 70.0, 70.0, text_width, text_height, inv_slot_house[7][2]..".png", false, tab_house )
		inv_slot_house[8][1] = guiCreateStaticImage( 130.0, 70.0, text_width, text_height, inv_slot_house[8][2]..".png", false, tab_house )
		inv_slot_house[9][1] = guiCreateStaticImage( 190.0, 70.0, text_width, text_height, inv_slot_house[9][2]..".png", false, tab_house )
		inv_slot_house[10][1] = guiCreateStaticImage( 250.0, 70.0, text_width, text_height, inv_slot_house[10][2]..".png", false, tab_house )
		inv_slot_house[11][1] = guiCreateStaticImage( 310.0, 70.0, text_width, text_height, inv_slot_house[11][2]..".png", false, tab_house )

		inv_slot_house[12][1] = guiCreateStaticImage( 10.0, 130.0, text_width, text_height, inv_slot_house[12][2]..".png", false, tab_house )
		inv_slot_house[13][1] = guiCreateStaticImage( 70.0, 130.0, text_width, text_height, inv_slot_house[13][2]..".png", false, tab_house )
		inv_slot_house[14][1] = guiCreateStaticImage( 130.0, 130.0, text_width, text_height, inv_slot_house[14][2]..".png", false, tab_house )
		inv_slot_house[15][1] = guiCreateStaticImage( 190.0, 130.0, text_width, text_height, inv_slot_house[15][2]..".png", false, tab_house )
		inv_slot_house[16][1] = guiCreateStaticImage( 250.0, 130.0, text_width, text_height, inv_slot_house[16][2]..".png", false, tab_house )
		inv_slot_house[17][1] = guiCreateStaticImage( 310.0, 130.0, text_width, text_height, inv_slot_house[17][2]..".png", false, tab_house )

		inv_slot_house[18][1] = guiCreateStaticImage( 10.0, 190.0, text_width, text_height, inv_slot_house[18][2]..".png", false, tab_house )
		inv_slot_house[19][1] = guiCreateStaticImage( 70.0, 190.0, text_width, text_height, inv_slot_house[19][2]..".png", false, tab_house )
		inv_slot_house[20][1] = guiCreateStaticImage( 130.0, 190.0, text_width, text_height, inv_slot_house[20][2]..".png", false, tab_house )
		inv_slot_house[21][1] = guiCreateStaticImage( 190.0, 190.0, text_width, text_height, inv_slot_house[21][2]..".png", false, tab_house )
		inv_slot_house[22][1] = guiCreateStaticImage( 250.0, 190.0, text_width, text_height, inv_slot_house[22][2]..".png", false, tab_house )
		inv_slot_house[23][1] = guiCreateStaticImage( 310.0, 190.0, text_width, text_height, inv_slot_house[23][2]..".png", false, tab_house )

		for i=0,max_inv do
			function outputEditBox ( button, state, absoluteX, absoluteY )--выделение картинки в инв-ре
				local x,y = guiGetPosition ( inv_slot_house[i][1], false )

				info3 = i
				info1 = inv_slot_house[i][2]
				info2 = inv_slot_house[i][3]

				if lmb == 0 then
					if info1 == 1 or info1 == 0 then
						return
					end

					gui_selection = true
					info_tab = tab_house
					gui_selection_pos_x = x
					gui_selection_pos_y = y
					info3_selection = info3
					info1_selection = info1
					info2_selection = info2
					lmb = 1
				else
					info3_selection_1 = info3
					info1_selection_1 = info1
					info2_selection_1 = info2

					--------------------------------------------------------------замена куда нажал 2 раз----------------------------------------------------------------------------
					if inv_slot_house[info3_selection_1][2] ~= 0 then
						if info1 == 1 or info1 == 0 then
							return
						end
						
						info_tab = tab_house
						gui_selection_pos_x = x
						gui_selection_pos_y = y
						info3_selection = info3
						info1_selection = info1
						info2_selection = info2
						return
					end

					inv_slot_house[info3_selection_1][2] = info1_selection
					inv_slot_house[info3_selection_1][3] = info2_selection

					triggerServerEvent( "event_inv_server_load", getRootElement(), getLocalPlayer(), "house", info3_selection_1, info1_selection, info2_selection, house )

					change_image ( "house", info3_selection_1, info1_selection )

					zamena_img()

					gui_selection = false
					info_tab = nil
					lmb = 0
				end

				--sendPlayerMessage(info3.." "..info1.." "..info2)
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

	use_button = guiCreateButton( 400.0, 44.0, 100.0, 25.0, "Использовать", false, stats_window )
	throw_button = guiCreateButton( 400.0, 74.0, 100.0, 25.0, "Выбросить", false, stats_window )

	---------------------кнопки--------------------------------------------------
	function use_subject ( button, state, absoluteX, absoluteY )--использование предмета
		if info1 == 1 or info1 == 0 or info1 == -1 then
			return
		end

		if tab_player == guiGetSelectedTab(tabPanel) then
			triggerServerEvent( "event_use_inv", getRootElement(), getLocalPlayer(), "player", info3, info1, info2 )
		end

		gui_selection = false
		info_tab = nil
		info1 = -1
		info2 = -1
		info3 = -1
		lmb = 0
	end
	addEventHandler ( "onClientGUIClick", use_button, use_subject, false )

	function throw_earth ( button, state, absoluteX, absoluteY )--выброс предмета
		if info1 == 1 or info1 == 0 or info1 == -1 then
			return
		end

		if tab_player == guiGetSelectedTab(tabPanel) then
			triggerServerEvent( "event_throw_earth_server", getRootElement(), getLocalPlayer(), "player", info3, info1, info2, getPlayerName ( getLocalPlayer() ) )
		--[[elseif tab_car == guiGetSelectedTab(tabPanel) then--возникает проблема с предметами
			local vehicleid = getPlayerVehicle(getLocalPlayer())

			if vehicleid then
				triggerServerEvent( "event_throw_earth_server", getRootElement(), getLocalPlayer(), "car", info3, info1, info2, plate )
			end
		elseif tab_house == guiGetSelectedTab(tabPanel) then
			triggerServerEvent( "event_throw_earth_server", getRootElement(), getLocalPlayer(), "house", info3, info1, info2, house )]]
		end

		gui_selection = false
		info_tab = nil
		info1 = -1
		info2 = -1
		info3 = -1
		lmb = 0
	end
	addEventHandler ( "onClientGUIClick", throw_button, throw_earth, false )

end
addEvent( "event_inv_create", true )
addEventHandler ( "event_inv_create", getRootElement(), inv_create )

function inv_delet ()--удаление инв-ря

	showCursor( false )

	for i=0,max_inv do
		inv_slot[i] = {0,0,0}
		inv_slot_car[i] = {0,0,0}
		inv_slot_house[i] = {0,0,0}
	end

	plate = ""
	house = ""

	gui_2dtext = false
	gui_pos_x = 0
	gui_pos_y = 0
	info1_png = -1
	info2_png = -1

	gui_selection = false
	gui_selection_pos_x = 0
	gui_selection_pos_y = 0
	info3_selection = -1
	info1_selection = -1
	info2_selection = -1

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

	stats_window = nil
end
addEvent( "event_inv_delet", true )
addEventHandler ( "event_inv_delet", getRootElement(), inv_delet )

function tune_close ( button, state, absoluteX, absoluteY )--закрытие окна
	destroyElement(gui_window)

	tune_color_2d = false
	gui_window = nil
	showCursor( false )
end
addEvent( "event_gui_delet", true )
addEventHandler ( "event_gui_delet", getRootElement(), tune_close )

function inv_load (value, id3, id1, id2)--загрузка инв-ря
	if value == "player" then
		inv_slot[id3][2] = id1
		inv_slot[id3][3] = id2
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

		if text == "" and tab_car ~= nil then
			destroyElement(tab_car)
		end

		plate = text
		gui_selection = false
		info_tab = nil
		tab_car = nil
		lmb = 0
	elseif value == "house" then

		if text == "" and tab_house ~= nil then
			destroyElement(tab_house)
		end

		house = text
		gui_selection = false
		info_tab = nil
		tab_house = nil
		lmb = 0
	end
end
addEvent( "event_tab_load", true )
addEventHandler ( "event_tab_load", getRootElement(), tab_load )

function change_image (value, id3, filename)--замена картинок в инв-ре
	if value == "player" then
		guiStaticImageLoadImage ( inv_slot[id3][1], filename..".png" )
	elseif value == "car" then
		guiStaticImageLoadImage ( inv_slot_car[id3][1], filename..".png" )
	elseif value == "house" then
		guiStaticImageLoadImage ( inv_slot_house[id3][1], filename..".png" )
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