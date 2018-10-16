local screenWidth, screenHeight = guiGetScreenSize ( )
local m2font = guiCreateFont( "gui/m2font.ttf", 9 )
local m2font_dx = dxCreateFont ( "gui/m2font.ttf", 9 )

local width = 220.0
local height = 80.0+16+10

--собственное гуи------------------------------------------------------------------------
function m2gui_label( x,y, width, height, text, bool_r, parent )
	local text = guiCreateLabel ( x, y, width, height, text, bool_r, parent )
	guiSetFont( text, m2font )
	return text
end

function m2gui_window( x,y, width, height, text, bool_r )
	local m2gui_win = guiCreateStaticImage( x, y, width, height, "gui/gui1.png", bool_r )
	local gui_text = guiCreateStaticImage( 0, 0, width, 15, "gui/gui2.png", bool_r, m2gui_win )
	local text = guiCreateLabel ( 0, 0, width, 15, text, bool_r, m2gui_win )
	guiSetFont( text, m2font )
	guiLabelSetHorizontalAlign ( text, "center" )
	return m2gui_win
end

function m2gui_button( x,y, text, bool_r, parent )
	local sym = 16+5+5
	local dimensions = dxGetTextWidth ( text, 1, m2font_dx )
	local dimensions_h = dxGetFontHeight ( 1, m2font_dx )
	local m2gui_fon = guiCreateStaticImage( x, y, dimensions+sym, 16, "comp/low_fon.png", bool_r, parent )
	local m2gui_but = guiCreateStaticImage( 0, 0, 16, 16, "gui/gui7.png", bool_r, m2gui_fon )
	local text = m2gui_label ( 16+5, 0, dimensions+5, dimensions_h, text, bool_r, m2gui_fon )

	function outputEditBox ( absoluteX, absoluteY, gui )--наведение на текст кнопки
		guiLabelSetColor ( text, 178, 16, 49 )
	end
	addEventHandler( "onClientMouseEnter", text, outputEditBox, false )

	function outputEditBox ( absoluteX, absoluteY, gui )--покидание на текст кнопки
		guiLabelSetColor ( text, 255, 255, 255 )
	end
	addEventHandler( "onClientMouseLeave", text, outputEditBox, false )

	return text
end
-----------------------------------------------------------------------------------------

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