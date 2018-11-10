local screenWidth, screenHeight = guiGetScreenSize ( )

local width = 220.0
local height = 80.0+16+10

showCursor( true )
local rl_window = m2gui_window( (screenWidth/2)-(width/2), (screenHeight/2)-(height/2), width, height, "Регистрация - Авторизация", false )
local text = m2gui_label ( 0, 25, width, 20, "Введите пароль", false, rl_window )
guiLabelSetHorizontalAlign ( text, "center" )
local edit = guiCreateEdit ( 10, 50, width-20, 25, "", false, rl_window )
local button = m2gui_button( 10, 80, "Войти", false, rl_window )
local fon = guiCreateStaticImage( 0, 0, screenWidth, screenHeight, "gui/gui4.png", false )
guiSetEnabled( fon, false )

function outputEditBox ( button, state, absoluteX, absoluteY )
	local text = guiGetText ( edit )

	triggerServerEvent( "event_reg_or_log_fun", getRootElement(), getLocalPlayer(), text )
end
addEventHandler ( "onClientGUIClick", button, outputEditBox, false )

function delet_okno ()
	showCursor( false )
	destroyElement(rl_window)
	destroyElement(fon)
end
addEvent( "event_delet_okno", true )
addEventHandler ( "event_delet_okno", getRootElement(), delet_okno )