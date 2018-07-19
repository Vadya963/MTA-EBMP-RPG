local screenWidth, screenHeight = guiGetScreenSize ( )

local info_tab = nil
local info1 = -1; --номер картинки
local info2 = -1; --значение картинки
local info3 = -1; --слот картинки

--гуи окно
local stats_window = nil
local tabPanel = nil
local tab_player = nil
local tab_car = nil
local tab_house = nil

--кнопки инв-ря
local use_button = nil
local throw_button = nil

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

function getSpeed(vehicle)
	if vehicle then
		local x, y, z = getElementVelocity(vehicle)
		return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))*111.847*1.61--узнает скорость авто в км/ч
	end
end

local gui_2dtext = false
local gui_pos_x = 0 --положение картинки x
local gui_pos_y = 0 --положение картинки y
local info_png = {
	[0] = {"", ""},
	[1] = {"Деньги", "$"},
	[2] = {"Права на имя", ""},
	[3] = {"Сигареты Big Break Red", "шт в пачке"},
	[4] = {"error", ""},
	[5] = {"В канистре", "галл."},
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
local info1_png = -1 --номер картинки
local info2_png = -1 --значение картинки

local gui_selection = false
local gui_selection_pos_x = 0 --положение картинки x
local gui_selection_pos_y = 0 --положение картинки y
local info3_selection = -1 --слот картинки
local info1_selection = -1 --номер картинки
local info2_selection = -1 --значение картинки

function createText ()
	local playerid = getLocalPlayer()
	local time = getRealTime()
	local client_time = " Date: "..time["monthday"].."."..time["month"]+'1'.."."..time["year"]+'1900'.." Time: "..time["hour"]..":"..time["minute"]..":"..time["second"]
	local text = "Ping: "..getPlayerPing(playerid).." | ".."Players online: "..#getElementsByType("player").." | "..client_time

	dxDrawText ( text, 2.0+1, 0.0+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
	dxDrawText ( text, 2.0, 0.0, 0.0, 0.0, tocolor ( 255, 255, 255, 255 ), 1, "default-bold" )

	local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
	if vehicle then
		local speed_table = split(getSpeed(vehicle), '.')
		local speed_vehicle = "vehicle speed "..speed_table[1].." km/h"
		dxDrawText ( speed_vehicle, 300.0+1, 20.0+1, 0.0, 0.0, tocolor ( 0, 0, 0, 255 ), 1, "default-bold" )
		dxDrawText ( speed_vehicle, 300.0, 20.0, 0.0, 0.0, tocolor ( 255, 255, 255, 255 ), 1, "default-bold" )
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
			dxDrawText ( info_png[info1_png][1].." "..info2_png.." "..info_png[info1_png][2], ((width+gui_pos_x+x)+25)-(dimensions/2), height+gui_pos_y+y, 0.0, 0.0, tocolor ( 255, 255, 255, 255 ), 1, "default-bold", "left", "top", false, false, true )
		end
	end

	if gui_selection and info_tab == guiGetSelectedTab(tabPanel) then--выделение картинки
		local width,height = guiGetPosition ( stats_window, false )
		local x = 9
		local y = 20+24
		dxDrawRectangle( width+gui_selection_pos_x+x, height+gui_selection_pos_y+y, 50.0, 50.0, tocolor ( 255, 255, 130, 100 ), true )
	end
end
addEventHandler ( "onClientRender", getRootElement(), createText )


function inv_create ()--создание инв-ря
	local width = 400.0+100+10
	local height = 215.0+(25.0*2)+10.0+30

	local text_width = 50.0
	local text_height = 50.0

	stats_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "", false )
	tabPanel = guiCreateTabPanel ( 0.0, 20.0, 310.0+10+text_width, 215.0+10+text_height, false, stats_window )
	tab_player = guiCreateTab( "Инвентарь", tabPanel )
	tab_car = guiCreateTab( "Авто", tabPanel )
	tab_house = guiCreateTab( "Дом", tabPanel )

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

			if info1 == 0 or info1 == -1 or info1 == 1 then
				return
			end

			if not gui_selection then
				gui_selection = true
			end

			info_tab = tab_player
			gui_selection_pos_x = x
			gui_selection_pos_y = y
			info3_selection = info3
			info1_selection = info1
			info2_selection = info2

			sendPlayerMessage(info3.." "..info1.." "..info2)
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

			if info1 == 0 or info1 == -1 or info1 == 1 then
				return
			end

			if not gui_selection then
				gui_selection = true
			end

			info_tab = tab_car
			gui_selection_pos_x = x
			gui_selection_pos_y = y
			info3_selection = info3
			info1_selection = info1
			info2_selection = info2

			sendPlayerMessage(info3.." "..info1.." "..info2)
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

			if info1 == 0 or info1 == -1 or info1 == 1 then
				return
			end

			if not gui_selection then
				gui_selection = true
			end

			info_tab = tab_house
			gui_selection_pos_x = x
			gui_selection_pos_y = y
			info3_selection = info3
			info1_selection = info1
			info2_selection = info2

			sendPlayerMessage(info3.." "..info1.." "..info2)
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

	use_button = guiCreateButton( 400.0, 43.0, 100.0, 25.0, "Использовать", false, stats_window )
	throw_button = guiCreateButton( 400.0, 73.0, 100.0, 25.0, "Выкинуть", false, stats_window )

end
addEvent( "event_inv_create", true )
addEventHandler ( "event_inv_create", getRootElement(), inv_create )

function inv_delet ()--удаление инв-ря
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

	info1 = -1;
	info2 = -1;
	info3 = -1;

	destroyElement(stats_window)
end
addEvent( "event_inv_delet", true )
addEventHandler ( "event_inv_delet", getRootElement(), inv_delet )

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