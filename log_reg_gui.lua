local screenWidth, screenHeight = guiGetScreenSize ( )

local width = 220.0
local height = 80.0+25+10

showCursor( true )
local rl_window = guiCreateWindow( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Регистрация - Авторизация", false )

local dimensions = dxGetTextWidth ( "Введите пароль", 1, "default-bold" )
local text = guiCreateLabel ( (width/2)-(dimensions/2), 25, dimensions, 20, "Введите пароль", false, rl_window )
local edit = guiCreateEdit ( 0, 50, width-20, 25, "", false, rl_window )
local button = guiCreateButton( 0, 80, width-20, 25, "Войти", false, rl_window )

function outputEditBox ( button, state, absoluteX, absoluteY )
	local text = guiGetText ( edit )

	triggerServerEvent( "event_reg_or_log_fun", getRootElement(), getLocalPlayer(), text )
end
addEventHandler ( "onClientGUIClick", button, outputEditBox, false )

function delet_okno ()
	showCursor( false )
	destroyElement(rl_window)
end
addEvent( "event_delet_okno", true )
addEventHandler ( "event_delet_okno", getRootElement(), delet_okno )