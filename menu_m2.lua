local screenWidth, screenHeight = guiGetScreenSize ( )

local menu_m2_table_text = {
	--button text
	["т/с"] = {"фары", "двигатель", "вертолет", "двери"},
	["двигатель"] = {"назад к т/с", "завести", "", "заглушить"},
	["двери"] = {"назад к т/с", "открыть", "", "закрыть"},
	["фары"] = {"назад к т/с", "включить", "", "выключить"},
	["вертолет"] = {"назад к т/с", "прицепить", "", "отцепить"},
	["назад к т/с"] = {"фары", "двигатель", "вертолет", "двери"},

	--triggerEvent
	["завести"] = "event_client_car_engine_true",
	["заглушить"] = "event_client_car_engine_false",

	["открыть"] = "event_client_car_door_false",
	["закрыть"] = "event_client_car_door_true",

	["включить"] = "event_client_car_light_true",
	["выключить"] = "event_client_car_light_false",

	["прицепить"] = "event_client_attach_true",
	["отцепить"] = "event_client_attach_false",
}

--triggerEvent---------------------------------------------------------------------------
--attach
function outputEditBox()
	triggerServerEvent( "event_server_attach", getRootElement(), localPlayer, true )
end
addEvent( "event_client_attach_true", true )
addEventHandler ( "event_client_attach_true", getRootElement(), outputEditBox )

function outputEditBox()
	triggerServerEvent( "event_server_attach", getRootElement(), localPlayer, false )
end
addEvent( "event_client_attach_false", true )
addEventHandler ( "event_client_attach_false", getRootElement(), outputEditBox )

--engine
function outputEditBox()
	triggerServerEvent( "event_server_car_engine", getRootElement(), localPlayer, true )
end
addEvent( "event_client_car_engine_true", true )
addEventHandler ( "event_client_car_engine_true", getRootElement(), outputEditBox )

function outputEditBox()
	triggerServerEvent( "event_server_car_engine", getRootElement(), localPlayer, false )
end
addEvent( "event_client_car_engine_false", true )
addEventHandler ( "event_client_car_engine_false", getRootElement(), outputEditBox )

--door
function outputEditBox()
	triggerServerEvent( "event_server_car_door", getRootElement(), localPlayer, false )
end
addEvent( "event_client_car_door_false", true )
addEventHandler ( "event_client_car_door_false", getRootElement(), outputEditBox )

function outputEditBox()
	triggerServerEvent( "event_server_car_door", getRootElement(), localPlayer, true )
end
addEvent( "event_client_car_door_true", true )
addEventHandler ( "event_client_car_door_true", getRootElement(), outputEditBox )

--light
function outputEditBox()
	triggerServerEvent( "event_server_car_light", getRootElement(), localPlayer, false )
end
addEvent( "event_client_car_light_false", true )
addEventHandler ( "event_client_car_light_false", getRootElement(), outputEditBox )

function outputEditBox()
	triggerServerEvent( "event_server_car_light", getRootElement(), localPlayer, true )
end
addEvent( "event_client_car_light_true", true )
addEventHandler ( "event_client_car_light_true", getRootElement(), outputEditBox )
-----------------------------------------------------------------------------------------

--menu from mafia 2
local menu_m2 = guiCreateStaticImage( screenWidth/2-30, screenHeight-100, 57, 58, "gui/window-m2.png", false )
local sx,sy = guiGetSize(menu_m2, false)
local px,py = guiGetPosition(menu_m2, false)
local arrow_m2 = {
	[1] = {guiCreateStaticImage( (sx/2)-(13/2), sy-16, 13, 8, "gui/window-arrow-off-down.png", false, menu_m2 ), m2gui_label( px+(sx/2)-(25/2), py+sy+3, 25, 15, "test", false ), "down"},
	[2] = {guiCreateStaticImage( 8, (sy/2)-(13/2), 8, 13, "gui/window-arrow-off-left.png", false, menu_m2 ), m2gui_label( px-25-5, py+(sy/2)-(15/2), 25, 15, "test", false ), "left"},
	[3] = {guiCreateStaticImage( (sx/2)-(13/2), 8, 13, 8, "gui/window-arrow-off-up.png", false, menu_m2 ), m2gui_label( px+(sx/2)-(25/2), py-15-5, 25, 15, "test", false ), "up"},
	[4] = {guiCreateStaticImage( sx-16, (sy/2)-(13/2), 8, 13, "gui/window-arrow-off-right.png", false, menu_m2 ), m2gui_label( px+sx+5, py+(sy/2)-(15/2), 25, 15, "test", false ), "right"},
}
guiSetVisible ( menu_m2, false )
for i=1,4 do
	guiSetVisible ( arrow_m2[i][2], false )
end

for i=1,4 do
	function select_button_menu ( absoluteX, absoluteY, gui )--наведение на меню
		guiLabelSetColor ( arrow_m2[i][2], 255, 210, 75 )
		guiStaticImageLoadImage(arrow_m2[i][1], "gui/window-arrow-on-"..arrow_m2[i][3]..".png")
	end
	addEventHandler( "onClientMouseEnter", arrow_m2[i][2], select_button_menu, false )
end
for i=1,4 do
	function select_button_menu2 ( absoluteX, absoluteY, gui )--наведение на меню
		guiLabelSetColor ( arrow_m2[i][2], 255, 255, 255 )
		guiStaticImageLoadImage(arrow_m2[i][1], "gui/window-arrow-off-"..arrow_m2[i][3]..".png")
	end
	addEventHandler( "onClientMouseLeave", arrow_m2[i][2], select_button_menu2, false )
end

function menu_mafia_2( key, keyState )
	if keyState == "down" then
		if not guiGetVisible(menu_m2) then
			local menu_m2_table = {
				[1] = "",
				[2] = "т/с",
				[3] = "",
				[4] = "анимации",
			}

			for k,v in pairs(menu_m2_table) do
				local dimensions = dxGetTextWidth ( v, 1, "default-bold" )
				dimensions = dimensions+5
				guiSetText(arrow_m2[k][2], v)

				local px1,py1 = guiGetPosition(arrow_m2[k][2], false)
				guiSetSize(arrow_m2[k][2], dimensions, 15, false)
				if k == 1 then
					guiSetPosition(arrow_m2[k][2], px+(sx/2)-(dimensions/2), py1, false)
				elseif k == 2 then
					guiSetPosition(arrow_m2[k][2], px-dimensions-5, py1, false)
				elseif k == 3 then
					guiSetPosition(arrow_m2[k][2], px+(sx/2)-(dimensions/2), py1, false)
				end
			end

			guiSetVisible ( menu_m2, true )
			for i=1,4 do
				guiSetVisible ( arrow_m2[i][2], true )
			end
			showCursor( true )
		else
			guiSetVisible ( menu_m2, false )
			for i=1,4 do
				guiSetVisible ( arrow_m2[i][2], false )
			end
			showCursor( false )
		end
	end
end

function outputEditBox ( button, state, absoluteX, absoluteY )
	local gui = source

	for k,v in pairs(arrow_m2) do
		if gui == v[2] then
			local text = guiGetText(gui)

			for k1,v1 in pairs(menu_m2_table_text) do
				if text == k1 then
					if v1[1] then
						for k2,v2 in pairs(menu_m2_table_text[k1]) do
							local dimensions = dxGetTextWidth ( v2, 1, "default-bold" )
							dimensions = dimensions+10
							guiSetText(arrow_m2[k2][2], v2)

							local px1,py1 = guiGetPosition(arrow_m2[k2][2], false)
							guiSetSize(arrow_m2[k2][2], dimensions, 15, false)
							if k2 == 1 then
								guiSetPosition(arrow_m2[k2][2], px+(sx/2)-(dimensions/2), py1, false)
							elseif k2 == 2 then
								guiSetPosition(arrow_m2[k2][2], px-dimensions-5, py1, false)
							elseif k2 == 3 then
								guiSetPosition(arrow_m2[k2][2], px+(sx/2)-(dimensions/2), py1, false)
							end
						end
					else
						triggerEvent ( v1, getRootElement() )
					end
				end
			end
		end
	end
end
addEventHandler( "onClientGUIClick", resourceRoot, outputEditBox )
