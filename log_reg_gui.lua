local screenWidth, screenHeight = guiGetScreenSize ( )

local width = 220.0
local height = 80.0+25+10

local rl_window = nil

function kik_player()
	if rl_window == nil then
		triggerServerEvent( "event_kickPlayer", getRootElement(), getLocalPlayer() )
	end
end

--setTimer(kik_player, 5000, 1)--кик если не видно окно входа

function reg_log_okno (state)--создание окна регистрации или авторизации
	showCursor( true )

	local value = state

	if value == "reg" then
		rl_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Регистрация", false )
	elseif value == "log" then
		rl_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Авторизация", false )
	end

	local dimensions = dxGetTextWidth ( "Введите пароль", 1, "default-bold" )
	local text = guiCreateLabel ( (width/2)-(dimensions/2), 25, dimensions, 20, "Введите пароль", false, rl_window )
	local edit = guiCreateEdit ( 0, 50, width-20, 25, "", false, rl_window )
	local button = guiCreateButton( 0, 80, width-20, 25, "Войти", false, rl_window )

	function outputEditBox ( button, state, absoluteX, absoluteY )
		local text = guiGetText ( edit )

		if value == "reg" then
			triggerServerEvent( "event_reg", getRootElement(), getLocalPlayer(), text )
		elseif value == "log" then
			triggerServerEvent( "event_log", getRootElement(), getLocalPlayer(), text )
		end
	end
	addEventHandler ( "onClientGUIClick", button, outputEditBox, false )
end
addEvent( "event_reg_log_okno", true )
addEventHandler ( "event_reg_log_okno", getRootElement(), reg_log_okno )

function delet_okno ()
	showCursor( false )
	destroyElement(rl_window)
end
addEvent( "event_delet_okno", true )
addEventHandler ( "event_delet_okno", getRootElement(), delet_okno )