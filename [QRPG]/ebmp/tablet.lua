local screenWidth, screenHeight = guiGetScreenSize ( )
local roulette_number = {false, {0,0,0}, {}}
local info_png = {}
local no_sell_auc = {}--нельзя продать
local gui_window = nil
local update_db_rang = 0

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
	"/searchcar [номер т/с] - написать заявление о пропаже т/с",
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
	"/sub [ИД игрока] [ид предмета] [количество] - выдать предмет",
	"/subdel [ИД игрока] [ид предмета] [количество] - удалить предмет",
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
	"/delv - удалить тс созданные через /v",
	"/rc [ИД игрока] - следить за игроком",
}

----цвета----
local color_mes = {
	color_tips = {168,228,160},--бабушкины яблоки
	yellow = {255,255,0},--желтый
	red = {255,0,0},--красный
	red_try = {200,0,0},--красный
	blue = {0,150,255},--синий
	white = {255,255,255},--белый
	green = {0,255,0},--зеленый
	green_try = {0,200,0},--зеленый
	turquoise = {0,255,255},--бирюзовый
	orange = {255,100,0},--оранжевый
	orange_do = {255,150,0},--оранжевый do
	pink = {255,100,255},--розовый
	lyme = {130,255,0},--лайм админский цвет
	svetlo_zolotoy = {255,255,130},--светло-золотой
	crimson = {220,20,60},--малиновый
	purple = {175,0,255},--фиолетовый
	gray = {150,150,150},--серый
	green_rc = {115,180,97},--темно зеленый
}

addEventHandler( "onClientResourceStart", resourceRoot,
function ( startedRes )
	info_png = getElementData(resourceRoot, "info_png")
	no_sell_auc = getElementData(resourceRoot, "no_sell_auc")
	update_db_rang = getElementData(resourceRoot, "update_db_rang")
end)

function roulette_number_Text ()
	if roulette_number[1] then--рисование цифр рулетки
		local dimensions = dxGetTextWidth ( tostring(roulette_number[1]), 6, "pricedown" )
		dxDrawText ( tostring(roulette_number[1]), roulette_number[3][1]+roulette_number[3][3]+(tablet_width/2)-(dimensions/2), roulette_number[3][2]+roulette_number[3][4]-34, 0.0, 0.0, tocolor ( roulette_number[2][1], roulette_number[2][2], roulette_number[2][3], 255 ), 6, "pricedown", "left", "top", false, false, true )
	end
end
addEventHandler ( "onClientRender", root, roulette_number_Text )

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
	local services = guiCreateStaticImage( 494, 80, 60, 60, "comp/services.png", false, fon )

	for value,weather in pairs(weather_list) do
		if getElementData(resourceRoot, "tomorrow_weather_data") == value then
			local set_weather = guiCreateStaticImage( width_fon-weather[2], height_fon-weather[3], weather[2], weather[3], "comp/"..weather[1]..".png", false, fon )
			break
		end
	end

	function outputEditBox ( button, state, absoluteX, absoluteY )--настройки
		local low_fon = guiCreateStaticImage( 0, 0, width_fon, height_fon, "comp/low_fon1.png", false, fon )
		local home,m2gui_width = m2gui_button( 0, height_fon-16, "Рабочий стол", false, low_fon )
		local save,m2gui_width = m2gui_button( m2gui_width, height_fon-16, "Сохранить", false, low_fon )

		local text = m2gui_label ( 0, 5, 200, 15, "Дальность прорисовки", false, low_fon )
		local dist = guiCreateEdit ( 200, 0, width_fon, 25, getElementData(localPlayer, "settings"), false, low_fon )

		function outputEditBox ( button, state, absoluteX, absoluteY )--вернуться в меню аука
			destroyElement(low_fon)
		end
		addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--сохранить настройки
			local text1 = guiGetText(dist)
				
			if text1 == "" then
				sendMessage("[ERROR] Вы ничего не написали", color_mes.red)
				return
			elseif not tonumber(text1) then
				sendMessage("[ERROR] Укажите число", color_mes.red)
				return
			end

			sendMessage("Настройки сохранены", color_mes.yellow)

			setFarClipDistance(tonumber(text1))

			setElementData(localPlayer, "settings", text1)

			triggerServerEvent("event_sqlite", resourceRoot, "UPDATE account SET settings = '"..getElementData(localPlayer, "settings").."' WHERE name = '"..getPlayerName(localPlayer).."'")
		end
		addEventHandler ( "onClientGUIClick", save, outputEditBox, false )
	end
	addEventHandler ( "onClientGUIClick", services, outputEditBox, false )

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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "auc")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "auc")) do
						guiGridListAddRow(shoplist, v["i"], v["name_sell"], info_png[v["id1"]][1].." "..v["id2"].." "..info_png[v["id1"]][2], v["money"], v["name_buy"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--купить предмет
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

				if text == "" then
					sendMessage("[ERROR] Вы не выбрали предмет", color_mes.red)
					return
				end
				
				triggerServerEvent("event_auction_buy_sell", resourceRoot, localPlayer, "buy", text, 0, 0, 0 )
			end
			addEventHandler ( "onClientGUIClick", buy_subject, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--вернуть предмет
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

				if text == "" then
					sendMessage("[ERROR] Вы не выбрали предмет", color_mes.red)
					return
				end

				triggerServerEvent("event_auction_buy_sell", resourceRoot, localPlayer, "return", text, 0, 0, 0 )
			end
			addEventHandler ( "onClientGUIClick", return_subject, outputEditBox, false )

			if getElementData(localPlayer, "auc") then
				guiGridListAddColumn(shoplist, "№", 0.1)
				guiGridListAddColumn(shoplist, "Продавец", 0.20)
				guiGridListAddColumn(shoplist, "Товар", 0.30)
				guiGridListAddColumn(shoplist, "Стоимость", 0.15)
				guiGridListAddColumn(shoplist, "Покупатель", 0.2)
				for k,v in pairs(getElementData(localPlayer, "auc")) do
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
				local count = false
				for k,v in pairs(no_sell_auc) do 
					if v == i then
						count = true
					end
				end

				if count then
				else
					guiComboBoxAddItem( edit_id1, info_png[i][1] )
				end
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

				for k,v in ipairs(info_png) do
					if v[1] == guiComboBoxGetItemText(edit_id1, guiComboBoxGetSelected(edit_id1)) then
						id1 = k
						break
					end
				end

				if id1 >= 2 and id1 <= #info_png and id2 and money > 0 then
					triggerServerEvent("event_auction_buy_sell", resourceRoot, localPlayer, "sell", 0, id1, id2, money, name_buy)
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
						sendMessage("[ERROR] URL пуст", color_mes.red)
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
			local color = guiCreateStaticImage( 0, 0, 642, 223, "other/color_car.png", false, low_fon )

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

		guiGridListAddColumn(shoplist, "Предмет", 0.4)
		guiGridListAddColumn(shoplist, "Ресурсы", 1.0)

		for k,v in pairs(getElementData(resourceRoot, "craft_table")) do
			guiGridListAddRow(shoplist, v[1], v[2])
		end

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			if text == "" then
				sendMessage("[ERROR] Вы не выбрали предмет", color_mes.red)
				return
			end

			triggerServerEvent("event_craft_fun", resourceRoot, localPlayer, text )
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
			triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "carparking_table")
			guiGridListClear(shoplist)

			setTimer(function()
				for k,v in pairs(getElementData(localPlayer, "carparking_table")) do
					guiGridListAddRow(shoplist, v)
				end
			end, 1000, 1)
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )--вернуть тс
			local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )

			if text == "" then
				sendMessage("[ERROR] Вы не выбрали т/с", color_mes.red)
				return
			end

			triggerServerEvent("event_spawn_carparking", resourceRoot, localPlayer, text )
		end
		addEventHandler ( "onClientGUIClick", return_car, outputEditBox, false )

		if getElementData(localPlayer, "carparking_table") then
			guiGridListAddColumn(shoplist, "Номер т/с", 0.95)
			for k,v in pairs(getElementData(localPlayer, "carparking_table")) do
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
			triggerServerEvent("event_cow_farms", resourceRoot, localPlayer, "buy", 0,0 )
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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "cow_farms_table1")
				guiGridListClear(shoplist)

				setTimer(function()
					if getElementData(localPlayer, "cow_farms_table1") then
						if isElement(shoplist) then
							for k,v in pairs(getElementData(localPlayer, "cow_farms_table1")) do
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
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				if not text2 then
					sendMessage("[ERROR] Введите число в белое поле", color_mes.red)
					return
				end

				triggerServerEvent( "event_cow_farms", resourceRoot, localPlayer, "menu", text, text2 )
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			if getElementData(localPlayer, "cow_farms_table1") then
				guiGridListAddColumn(shoplist, "Ферма "..getElementData(localPlayer, "cow_farms_table1")[1][1], 0.5)
				guiGridListAddColumn(shoplist, "", 0.4)
				for k,v in pairs(getElementData(localPlayer, "cow_farms_table1")) do
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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "cow_farms_table2")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "cow_farms_table2")) do
						guiGridListAddRow(shoplist, v["number"], v["price"].."$", v["coef"].." процентов")
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				triggerServerEvent( "event_cow_farms", resourceRoot, localPlayer, "job", tonumber(text), 0 )
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			if getElementData(localPlayer, "cow_farms_table2") then
				guiGridListAddColumn(shoplist, "Скотобойни", 0.15)
				guiGridListAddColumn(shoplist, "Зарплата", 0.4)
				guiGridListAddColumn(shoplist, "Доход от продаж", 0.4)
				for k,v in pairs(getElementData(localPlayer, "cow_farms_table2")) do
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
				local row = guiGridListAddRow(shoplist, getElementData(v, "player_id"), getPlayerName(v), getElementData(v, "crimes_data"))
				local r,g,b = getPlayerNametagColor(localPlayer)
				guiGridListSetItemColor ( shoplist, row,2, r,g,b)
			end
		end
		addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

		guiGridListAddColumn(shoplist, "ИД", 0.15)
		guiGridListAddColumn(shoplist, "Ник", 0.7)
		guiGridListAddColumn(shoplist, "ОП", 0.1)
		for k,v in pairs(getElementsByType("player")) do
			local row = guiGridListAddRow(shoplist, getElementData(v, "player_id"), getPlayerName(v), getElementData(v, "crimes_data"))
			local r,g,b = getPlayerNametagColor(localPlayer)
			guiGridListSetItemColor ( shoplist, row,2, r,g,b)
		end
	end
	addEventHandler ( "onClientGUIClick", handbook, outputEditBox, false )


	function outputEditBox( button, state, absoluteX, absoluteY )--админ панель
		if getElementData(localPlayer, "admin_data") ~= 1 then
			sendMessage("[ERROR] Вы не админ", color_mes.red)
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
			triggerServerEvent("event_earth_true", resourceRoot, localPlayer)
		end
		addEventHandler ( "onClientGUIClick", timer_earth_clear, outputEditBox, false )

		function outputEditBox ( button, state, absoluteX, absoluteY )
			local res_t = 2

			triggerServerEvent("event_restartResource", resourceRoot)
			triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] начал скачивание лога")

			setTimer(function()
				triggerEvent("event_download", root)
			end, res_t*1000, 1)

			function onDownloadFinish ( file, success )
				if file == "save_sqlite.sql" then
					triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] скачал лог сервера")
				end
			end
			addEventHandler ( "onClientFileDownloadComplete", root, onDownloadFinish )
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
				setCameraTarget(localPlayer)
			end
			addEventHandler ( "onClientGUIClick", home, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				guiGridListClear(shoplist)
				for k,v in pairs(getElementsByType("player")) do
					local row = guiGridListAddRow(shoplist, getElementData(v, "player_id"), getPlayerName(v), getElementData(v, "crimes_data"))
					local r,g,b = getPlayerNametagColor(localPlayer)
					guiGridListSetItemColor (shoplist, row,2, r,g,b)
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				local id,player = getPlayerId(text)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				elseif not id then
					sendMessage("[ERROR] Такого игрока нет", color_mes.red)
					return
				end

				local x,y,z = getElementPosition(player)
				setElementPosition(localPlayer, x,y,z)
				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] телепортировался к "..id.." ["..getElementData(player, "player_id").."]")
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--prison
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				local id,player = getPlayerId(text)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				elseif not id then
					sendMessage("[ERROR] Такого игрока нет", color_mes.red)
					return
				end

				triggerServerEvent("event_prisonplayer", resourceRoot, localPlayer, "", text, 60, "Нарушение правил сервера")
			end
			addEventHandler ( "onClientGUIClick", prison, complete, false )

			guiGridListAddColumn(shoplist, "ИД", 0.15)
			guiGridListAddColumn(shoplist, "Ник", 0.7)
			guiGridListAddColumn(shoplist, "ОП", 0.1)
			for k,v in pairs(getElementsByType("player")) do
				local row = guiGridListAddRow(shoplist, getElementData(v, "player_id"), getPlayerName(v), getElementData(v, "crimes_data"))
				local r,g,b = getPlayerNametagColor(localPlayer)
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
				for k,v in pairs(getElementData(resourceRoot, "interior_job")) do
					guiGridListAddRow(shoplist, k, v[2])
				end
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				local name,x,y,z = getElementData(resourceRoot, "interior_job")[tonumber(text)][2],getElementData(resourceRoot, "interior_job")[tonumber(text)][6],getElementData(resourceRoot, "interior_job")[tonumber(text)][7],getElementData(resourceRoot, "interior_job")[tonumber(text)][8]
				setElementPosition(localPlayer, x,y,z)
				sendMessage("Вы телепортировались к "..name, color_mes.lyme)
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			guiGridListAddColumn(shoplist, "Номер", 0.15)
			guiGridListAddColumn(shoplist, "Название", 0.8)
			for k,v in pairs(getElementData(resourceRoot, "interior_job")) do
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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "house_db")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "house_db")) do
						guiGridListAddRow(shoplist, v["number"], v["door"], v["taxation"], v["x"], v["y"], v["z"], v["interior"], v["world"], v["inventory"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(localPlayer, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", color_mes.red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", color_mes.red)
					return
				end

				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", resourceRoot, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				local x,y,z = getElementData(localPlayer, "house_db")[tonumber(text)]["x"],getElementData(localPlayer, "house_db")[tonumber(text)]["y"],getElementData(localPlayer, "house_db")[tonumber(text)]["z"]
				setElementPosition(localPlayer, x,y,z)
				sendMessage("Вы телепортировались к "..text.." дому", color_mes.lyme)
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "door", 0.1)
			guiGridListAddColumn(shoplist, "taxation", 0.1)
			guiGridListAddColumn(shoplist, "x", 0.2)
			guiGridListAddColumn(shoplist, "y", 0.2)
			guiGridListAddColumn(shoplist, "z", 0.2)
			guiGridListAddColumn(shoplist, "interior", 0.1)
			guiGridListAddColumn(shoplist, "world", 0.1)
			guiGridListAddColumn(shoplist, "inventory", 4.0)
			for k,v in pairs(getElementData(localPlayer, "house_db")) do
				guiGridListAddRow(shoplist, v["number"], v["door"], v["taxation"], v["x"], v["y"], v["z"], v["interior"], v["world"], v["inventory"])
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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "business_db")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "business_db")) do
						guiGridListAddRow(shoplist, v["number"], v["type"], v["price"], v["money"], v["taxation"], v["warehouse"], v["x"], v["y"], v["z"], v["interior"], v["world"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(localPlayer, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", color_mes.red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", color_mes.red)
					return
				end

				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", resourceRoot, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--выполнение операции
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				local x,y,z = getElementData(localPlayer, "business_db")[tonumber(text)]["x"],getElementData(localPlayer, "business_db")[tonumber(text)]["y"],getElementData(localPlayer, "business_db")[tonumber(text)]["z"]
				setElementPosition(localPlayer, x,y,z)
				sendMessage("Вы телепортировались к "..text.." бизнесу", color_mes.lyme)
			end
			addEventHandler ( "onClientGUIClick", complete_button, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "type", 0.2)
			guiGridListAddColumn(shoplist, "price", 0.1)
			guiGridListAddColumn(shoplist, "money", 0.1)
			guiGridListAddColumn(shoplist, "taxation", 0.1)
			guiGridListAddColumn(shoplist, "warehouse", 0.1)
			guiGridListAddColumn(shoplist, "x", 0.2)
			guiGridListAddColumn(shoplist, "y", 0.2)
			guiGridListAddColumn(shoplist, "z", 0.2)
			guiGridListAddColumn(shoplist, "interior", 0.1)
			guiGridListAddColumn(shoplist, "world", 0.1)
			for k,v in pairs(getElementData(localPlayer, "business_db")) do
				guiGridListAddRow(shoplist, v["number"], v["type"], v["price"], v["money"], v["taxation"], v["warehouse"], v["x"], v["y"], v["z"], v["interior"], v["world"])
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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "account_db")
				guiGridListClear(shoplist)

				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "account_db")) do
						guiGridListAddRow(shoplist, v["name"], v["ban"], v["reason"], v["x"], v["y"], v["z"], v["reg_ip"], v["reg_serial"], v["heal"], v["alcohol"], v["satiety"], v["hygiene"], v["sleep"], v["drugs"], v["skin"], v["arrest"], v["crimes"], v["inventory"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(localPlayer, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", color_mes.red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", color_mes.red)
					return
				end

				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", resourceRoot, text)
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
			for k,v in pairs(getElementData(localPlayer, "account_db")) do
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
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				local vehicleid = getVehicleidFromPlate( text )
				for k,v in pairs(getVehicleOccupants(vehicleid)) do
					triggerServerEvent("event_removePedFromVehicle", resourceRoot, v)
				end

				triggerServerEvent("event_destroyElement", resourceRoot, vehicleid)
				triggerServerEvent("event_car_spawn", resourceRoot, text)
				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] пересоздал т/с под номером "..text)
			end
			addEventHandler ( "onClientGUIClick", refresh_car, outputEditBox, false )

			function outputEditBox ( button, state, absoluteX, absoluteY )--обновить
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "car_db")
				guiGridListClear(shoplist)
				
				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "car_db")) do
						guiGridListAddRow(shoplist, v["number"], v["model"], v["taxation"], v["frozen"], v["evacuate"], v["x"], v["y"], v["z"], v["rot"], v["fuel"], v["car_rgb"], v["headlight_rgb"], v["paintjob"], v["tune"], v["stage"], v["kilometrage"], v["wheel"], v["hydraulics"], v["wheel_rgb"], v["theft"], v["inventory"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(localPlayer, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", color_mes.red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", color_mes.red)
					return
				end

				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", resourceRoot, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			function complete ( button, state, absoluteX, absoluteY )--dim_0
				local text = guiGridListGetItemText ( shoplist, guiGridListGetSelectedItem ( shoplist ) )
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
					return
				end

				local vehicleid = getVehicleidFromPlate( text )

				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] убрал т/с под номером "..text)

				triggerServerEvent("event_setElementDimension", resourceRoot, vehicleid, 1)
			end
			addEventHandler ( "onClientGUIClick", dim_0, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.15)
			guiGridListAddColumn(shoplist, "model", 0.1)
			guiGridListAddColumn(shoplist, "taxation", 0.1)
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
			guiGridListAddColumn(shoplist, "kilometrage", 0.2)
			guiGridListAddColumn(shoplist, "wheel", 0.1)
			guiGridListAddColumn(shoplist, "hydraulics", 0.1)
			guiGridListAddColumn(shoplist, "wheel_rgb", 0.2)
			guiGridListAddColumn(shoplist, "theft", 0.1)
			guiGridListAddColumn(shoplist, "inventory", 4.0)
			for k,v in pairs(getElementData(localPlayer, "car_db")) do
				guiGridListAddRow(shoplist, v["number"], v["model"], v["taxation"], v["frozen"], v["evacuate"], v["x"], v["y"], v["z"], v["rot"], v["fuel"], v["car_rgb"], v["headlight_rgb"], v["paintjob"], v["tune"], v["stage"], v["kilometrage"], v["wheel"], v["hydraulics"], v["wheel_rgb"], v["theft"], v["inventory"])
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
				triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "cow_farms_table2")
				guiGridListClear(shoplist)
				
				setTimer(function()
					for k,v in pairs(getElementData(localPlayer, "cow_farms_table2")) do
						guiGridListAddRow(shoplist, v["number"], v["price"], v["coef"], v["money"], v["taxation"], v["warehouse"], v["prod"])
					end
				end, 1000, 1)
			end
			addEventHandler ( "onClientGUIClick", refresh, outputEditBox, false )

			function complete ( button, state, absoluteX, absoluteY )--update_db
				if getElementData(localPlayer, "admin_data") ~= update_db_rang then
					sendMessage("[ERROR] Вы не админ", color_mes.red)
					return
				end

				local text = guiGetText(edit)
				
				if text == "" then
					sendMessage("[ERROR] Вы ничего не написали", color_mes.red)
					return
				end

				triggerServerEvent("event_admin_chat", resourceRoot, localPlayer, getPlayerName(localPlayer).." ["..getElementData(localPlayer, "player_id").."] выполнил запрос "..text)

				triggerServerEvent("event_sqlite", resourceRoot, text)
			end
			addEventHandler ( "onClientGUIClick", update_db, complete, false )

			guiGridListAddColumn(shoplist, "number", 0.1)
			guiGridListAddColumn(shoplist, "price", 0.1)
			guiGridListAddColumn(shoplist, "coef", 0.1)
			guiGridListAddColumn(shoplist, "money", 0.2)
			guiGridListAddColumn(shoplist, "taxation", 0.1)
			guiGridListAddColumn(shoplist, "warehouse", 0.1)
			guiGridListAddColumn(shoplist, "prod", 0.1)
			for k,v in pairs(getElementData(localPlayer, "cow_farms_table2")) do
				guiGridListAddRow(shoplist, v["number"], v["price"], v["coef"], v["money"], v["taxation"], v["warehouse"], v["prod"])
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
			triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "quest_table")
			guiGridListClear(shoplist)
				
			setTimer(function()
				for k,v in pairs(getElementData(localPlayer, "quest_table")) do
					local count = 0
					for k,v in pairs(v[8]) do
						if v ~= getPlayerName(localPlayer) then
							count = count+1
						end
					end

					if count == #v[8] then
						if tonumber(split(getElementData(localPlayer, "quest_select"), ":")[1]) == k then
							local r = guiGridListAddRow(shoplist, k, v[1], v[2]..v[3]..v[4], split(getElementData(localPlayer, "quest_select"), ":")[2].."/"..v[3], v[6], info_png[ v[7][1] ][1].." "..v[7][2].." "..info_png[ v[7][1] ][2])
						
							for i=1,guiGridListGetColumnCount (shoplist) do
								guiGridListSetItemColor ( shoplist, r,i, color_mes.green[1], color_mes.green[2], color_mes.green[3])
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
				sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
				return
			end

			for k,v in pairs(getElementData(localPlayer, "quest_table")[tonumber(text)][8]) do
				if v == getPlayerName(localPlayer) then
					sendMessage("[ERROR] Вы выполнили этот квест", color_mes.red)
					return
				end
			end

			for i=0,guiGridListGetRowCount (shoplist) do
				for j=1,guiGridListGetColumnCount (shoplist) do
					guiGridListSetItemColor ( shoplist, i,j, color_mes.white[1], color_mes.white[2], color_mes.white[3])
				end
			end

			local r,c = guiGridListGetSelectedItem ( shoplist )
			for i=1,guiGridListGetColumnCount (shoplist) do
				guiGridListSetItemColor ( shoplist, r,i, color_mes.green[1], color_mes.green[2], color_mes.green[3])
			end

			sendMessage("Вы взяли квест "..getElementData(localPlayer, "quest_table")[tonumber(text)][1], color_mes.yellow)

			setElementData(localPlayer, "quest_select", text..":0")
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )

		guiGridListAddColumn(shoplist, "Номер", 0.1)
		guiGridListAddColumn(shoplist, "Название", 0.2)
		guiGridListAddColumn(shoplist, "Описание", 0.5)
		guiGridListAddColumn(shoplist, "Прогресс", 0.1)
		guiGridListAddColumn(shoplist, "Награда $", 0.1)
		guiGridListAddColumn(shoplist, "Награда предметом", 0.3)
		for k,v in pairs(getElementData(localPlayer, "quest_table")) do
			local count = 0
			for k,v in pairs(v[8]) do
				if v ~= getPlayerName(localPlayer) then
					count = count+1
				end
			end

			if count == #v[8] then
				if tonumber(split(getElementData(localPlayer, "quest_select"), ":")[1]) == k then
					local r = guiGridListAddRow(shoplist, k, v[1], v[2]..v[3]..v[4], split(getElementData(localPlayer, "quest_select"), ":")[2].."/"..v[3], v[6], info_png[ v[7][1] ][1].." "..v[7][2].." "..info_png[ v[7][1] ][2])
					
					for i=1,guiGridListGetColumnCount (shoplist) do
						guiGridListSetItemColor ( shoplist, r,i, color_mes.green[1], color_mes.green[2], color_mes.green[3])
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
				sendMessage("[ERROR] Укажите ставку", color_mes.red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", color_mes.red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", color_mes.red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", color_mes.red)
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
					triggerServerEvent("event_slots", resourceRoot, localPlayer, cash, randomize1, randomize2, randomize3)
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
			guiLabelSetColor(radiobutton_table[1][i], color_mes.gray[1], color_mes.gray[2], color_mes.gray[3])
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
							guiLabelSetColor(radiobutton_table[1][i], color_mes.green[1], color_mes.green[2], color_mes.green[3])
						else
							radiobutton_table[2][k] = true
							guiLabelSetColor(radiobutton_table[1][i], color_mes.red[1], color_mes.red[2], color_mes.red[3])
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
				sendMessage("[ERROR] Укажите ставку", color_mes.red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", color_mes.red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", color_mes.red)
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
					sendMessage("[ERROR] Вы не выбрали коэффициент", color_mes.red)
					return
				end

				count,token,money = 2,tonumber(guiGetText(edit))/tonumber(coef),tonumber(guiGetText(edit))

				for i=1,count_card do
					guiLabelSetColor(radiobutton_table[1][i], color_mes.green[1], color_mes.green[2], color_mes.green[3])
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
				
				triggerServerEvent("event_poker_win", resourceRoot, localPlayer, text, money, coef, token)

				count = 1
				radiobutton_table[2][1],radiobutton_table[3][1] = false, "0"
				radiobutton_table[2][2],radiobutton_table[3][2] = false, "0"
				radiobutton_table[2][3],radiobutton_table[3][3] = false, "0"
				radiobutton_table[2][4],radiobutton_table[3][4] = false, "0"
				radiobutton_table[2][5],radiobutton_table[3][5] = false, "0"

				for i=1,count_card do
					guiLabelSetColor(radiobutton_table[1][i], color_mes.gray[1], color_mes.gray[2], color_mes.gray[3])
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
					sendMessage("[ERROR] Вы играете", color_mes.red)
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
				sendMessage("[ERROR] Укажите ставку", color_mes.red)
				return
			elseif id == "" then
				sendMessage("[ERROR] Вы не сделали ставку", color_mes.red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", color_mes.red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", color_mes.red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", color_mes.red)
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
					triggerServerEvent("event_roulette_fun", resourceRoot, localPlayer, id, cash, randomize)
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
				sendMessage("[ERROR] Вы не выбрали лошадь", color_mes.red)
				return	
			elseif text == "" then
				sendMessage("[ERROR] Укажите ставку", color_mes.red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", color_mes.red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", color_mes.red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", color_mes.red)
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
						triggerServerEvent( "event_insider_track", resourceRoot, localPlayer, cash, v[3], k, horse_player )

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
					sendMessage("[ERROR] Вы играете", color_mes.red)
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
				sendMessage("[ERROR] Укажите ставку", color_mes.red)
				return
			elseif id == 0 then
				sendMessage("[ERROR] Вы не сделали ставку", color_mes.red)
				return
			elseif not cash then
				sendMessage("[ERROR] Укажите число", color_mes.red)
				return
			elseif cash < 1 then
				sendMessage("[ERROR] Число меньше 1", color_mes.red)
				return
			elseif start then
				sendMessage("[ERROR] Вы играете", color_mes.red)
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
					triggerServerEvent("event_fortune_fun", resourceRoot, localPlayer, cash, id, wheel_fortune[count2])
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
			triggerServerEvent("event_sqlite_load", resourceRoot, localPlayer, "business_table")
			guiGridListClear(shoplist)

			setTimer(function()
				if getElementData(localPlayer, "business_table") then
					if isElement(shoplist) then
						for k,v in pairs(getElementData(localPlayer, "business_table")) do
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
				sendMessage("[ERROR] Вы ничего не выбрали", color_mes.red)
				return
			elseif not text2 then
				sendMessage("[ERROR] Введите число в белое поле", color_mes.red)
				return
			end

			triggerServerEvent( "event_till_fun", resourceRoot, localPlayer, text, text2 )
		end
		addEventHandler ( "onClientGUIClick", complete_button, complete, false )

		if getElementData(localPlayer, "business_table") then
			guiGridListAddColumn(shoplist, "Бизнес "..getElementData(localPlayer, "business_table")[1][1], 0.5)
			guiGridListAddColumn(shoplist, "", 0.4)
			for k,v in pairs(getElementData(localPlayer, "business_table")) do
				guiGridListAddRow(shoplist, v[2], v[3])
			end
		end
	end
	addEventHandler ( "onClientGUIClick", menu_business, outputEditBox, false )
end
addEvent( "event_tablet_fun", true )
addEventHandler ( "event_tablet_fun", root, tablet_fun )

function close_tablet()
	if gui_window then
		showCursor( false )
		destroyElement(gui_window)

		gui_window = nil
		roulette_number[1] = false
	end
end
addEvent( "event_close_tablet", true )
addEventHandler ( "event_close_tablet", root, close_tablet )