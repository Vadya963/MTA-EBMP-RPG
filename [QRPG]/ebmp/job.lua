local clear_street_pos = {
	["Los Santos"] = { [1] = {}, [2] = {} },
	["San Fierro"] = { [1] = {}, [2] = {} },
	["Las Venturas"] = { [1] = {}, [2] = {} },
}
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Los Santos"][1][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street2'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Los Santos"][2][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street3'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["San Fierro"][1][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street4'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["San Fierro"][2][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street5'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Las Venturas"][1][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end
for k,v in pairs(sqlite( "SELECT * FROM position WHERE description = 'job_clear_street6'" )) do
	local spl = split(v["pos"], ",")
	clear_street_pos["Las Venturas"][2][k] = {tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3])}
end

local vehicle_pos = {}
local uc_txt = fileOpen(":ebmp/other/vehicles_pos.txt")
for k,v in pairs(split(fileRead ( uc_txt, fileGetSize( uc_txt ) ), ";")) do
	local spl = split(v, ",")
	table.insert(vehicle_pos, {spl[1], spl[2],spl[3],spl[4], spl[5]})
end
fileClose(uc_txt)

local plane_job = {
	{1532.904296875,1449.3662109375,11.769500732422, "Лас Вентурас"},
	{-1339.0771484375,-225.6962890625,15.069016456604, "Сан Фиерро"},
	{1940.416015625,-2326.716796875,14.466937065125, "Лос Сантос"},
}

local sell_car_theft = {
	{365.4150390625,2537.072265625,16.664493560791},
}

local original_business_pos = {
	{1315.389648, -898.885803, 39.578125},
	{1199.693847, -919.824829, 43.107589},
	{1087.605468, -922.871948, 43.390625},
	{927.423706, -1352.795166, 13.376624},
	{953.874816, -1336.391479, 13.538938},
	{2421.620361, -1509.163085, 23.992208},
	{2309.676757, -1644.051757, 14.827047},
	{2421.507324, -1219.351928, 25.554723},
	{1835.677490, -1682.488403, 13.379734},
	{-2026.599121, -101.420875, 35.164062},
	{-2243.077392, -88.254119, 35.320312},
	{2020.498535, 1007.743408, 10.820312},
	{2195.840087, 1677.150512, 12.367187},
	{2083.363037, 2223.861572, 11.023437},
	{1872.878784, 2071.857666, 11.062500},
	{2507.153076, 2121.128173, 10.840013},
	{2637.511718, 1671.698120, 11.023437},
	{2546.290283, 1971.762695, 10.820312},
	{-2672.043945, 258.937194, 4.632812},
	{-2356.885498, 1008.085449, 50.898437},
	{-1911.886352, 828.324584, 35.190605},
	{-1808.028808, 945.119873, 24.890625},
	{-1816.763427, 617.589660, 35.171875},
	{-1721.932250, 1359.860717, 7.185316},
	{-2154.623535, -2460.848876, 30.851562},
	{203.338851, -203.111373, 1.578125},
	{-2336.397460, -166.919891, 35.554687},
	{172.669723, 1176.409179, 14.764543},
	{-2624.398925, 1411.984985, 7.093750},
	{ 2332.967041, 75.052017, 26.620975},
	{ 1367.071044, 248.593109, 19.566932},
	{ 810.959289, -1616.228393, 13.546875},
	{ 2366.433105, 2071.120605, 10.820312},
	{ 2472.081542, 2034.191772, 11.062500},
	{ 2393.012207, 2043.314697, 10.820312},
	{ 2846.259521, 2414.882568, 11.068956},
	{ 2756.376708, 2476.747314, 11.062500},
	{ 2885.277587, 2453.478271, 11.068956},
	{ -2242.484130, 128.449966, 35.320312},
	{ -2442.768310, 754.327941, 35.171875},
	{ 1631.911132, -1172.027099, 24.078125},
	{ 1289.185424, 270.880920, 19.554687},
	{ 1038.215576, -1339.617309, 13.726562},
	{ 2094.657714, 2122.192871, 10.820312},
	{ 2085.687255, 2074.024902, 11.054687},
	{ 693.628173, 1966.920166, 5.539062},
	{ 1158.547973, 2072.261474, 11.062500},
	{ 2170.229003, 2795.691894, 10.820312},
	{ 2330.606201, 2532.529785, 10.820312},
	{2825.737060, 2407.213623, 11.062500},
	{ 2802.501220, 2430.280273, 11.062500},
	{ 2779.359375, 2453.658691, 11.062500},
	{ 2102.554687, 2228.759033, 11.023437},
	{ 2102.572265, 2257.474365, 11.023437},
	{ 2097.767578, 2223.978515, 11.023437},
	{ 2090.559570, 2224.423828, 11.023437},
	{ 2194.563720, 1991.017944, 12.296875},
	{ 2452.393310, 2064.608154, 10.820312},
	{ 2441.232421, 2064.397949, 10.820312},
	{ 2080.458740, 2121.975341, 10.812517},
	{ -2571.014892, 246.275955, 10.185619},
	{ -2492.447998, -38.669422, 25.765625},
	{ -2492.282470, -29.028230, 25.765625},
	{ -1883.063476, 865.582031, 35.172843},
	{ -1693.950805, 950.370056, 24.890625},
	{ -2374.904052, 910.287475, 45.445312},
	{ 2069.536621, -1779.876708, 13.559158},
	{ 2071.437255, -1793.805786, 13.553277},
	{ 2104.495605, -1806.595214, 13.554687},
	{ 453.227142, -1478.244018, 30.812078},
	{ 1368.388671, -1279.795898, 13.546875},
	{ 2397.941406, -1898.133666, 13.546875},
	{ -1561.987426, -2733.466552, 48.743457},
	{ -2093.248046, -2464.454589, 30.625000},
	{ 1975.763061, -2036.651611, 13.546875},
	{ 1941.082763, -2116.011474, 13.695312},
	{ 1832.444946, -1842.604736, 13.578125},
	{ 2158.767333, 943.083129, 10.820312},
	{ 2638.084228, 1849.809326, 11.023437},
	{ -143.945327, 1224.217529, 19.899219},
	{ 1969.270507, 2294.182617, 16.455863},
	{ 1937.173583, 2307.304931, 10.820312},
	{ -1508.861572, 2609.611572, 55.835937},
	{ 2247.947509, 2397.572998, 10.820312},
	{ 2722.694335, -2026.645629, 13.547199},
	{ 2538.900878, 2084.042968, 10.820312},
	{ 823.392944, -1588.984252, 13.554450},
	{ -2767.562500, 788.794433, 52.781250},
	{ -2551.652832, 193.638565, 6.190325},
	{ 1070.058349, -1221.396118, 16.890625},
	{ 811.207946, -1060.040649, 24.946811},
	{ 499.961059, -1359.307128, 16.257724},
	{ 460.946624, -1500.953002, 31.058170},
	{ 681.296936, -474.303710, 16.536296},
	{ 2244.590820, -1664.513061, 15.476562},
	{ 674.178527, -497.001251, 16.335937},
	{ 661.015319, -573.572692, 16.335937},
	{ 2354.133056, -1512.185668, 24.000000},
	{ -2626.432128, 209.431488, 4.601754},
	{ 2400.531738, -1980.582885, 13.546875},
	{ 778.146789, 1871.564575, 4.907619},
	{ -314.774688, 829.901977, 14.242187},
	{ 241.099655, -178.363815, 1.578125},
	{ 2334.055664, 61.541301, 26.484687},
}

local gans_pos = {
	{-2626.432128, 209.431488, 4.601754},
	{2400.531738, -1980.582885, 13.546875},
	{778.146789, 1871.564575, 4.907619},
	{-314.774688, 829.901977, 14.242187},
	{241.099655, -178.363815, 1.578125},
	{2334.055664, 61.541301, 26.484687},
	{2538.900878, 2084.042968, 10.820312},
	{-1508.861572, 2609.611572, 55.835937},
	{2158.767333, 943.083129, 10.820312},
	{-2093.248046, -2464.454589, 30.625000},
	{1368.388671, -1279.795898, 13.546875},
}

local busdriver_pos = {
	{1776.921875,-1897.3623046875,13.520164489746},
	{2832.11328125,1291.9189453125,10.908647537231},
	{-1993.9208984375,144.396484375,27.685970306396},
	{1743.0302734375,-1864.4560546875,13.573830604553},
}

local color_mes = {}
local korovi_pos = {}
local grass_pos = {}
local taxi_pos = {}
local fire_pos = {}

local job_call = {}--переменная для работ
local job_ped = {}--создан ли нпс, 0-нет
local job_blip = {}--создан ли блип, 0-нет
local job_marker = {}--создан ли маркер, 0-нет
local job_pos = {}--позиция места назначения
local job_vehicleid = {}--позиция авто
local job_timer = {}--таймер угона
local timer_job = {}--таймер работ
local job_object = {}--создан ли объект, 0-нет
local job_vehicle = {}--позиция авто

function displayLoadedRes ( res )--старт ресурсов
	--[[for i=1,50 do
		local x,y,z = math.random(-1189,-1007), math.random(-1061,-916), 129.51875
		local obj = createObject(16442, x,y,z, 0,0,math.random(0,360))
		setObjectScale (obj, 0.7)
		korovi_pos[i] = {x,y,z}
	end]]

	color_mes = getElementData(resourceRoot, "color_mes")
end
addEventHandler ( "onResourceStart", resourceRoot, displayLoadedRes )

addEventHandler("onPlayerJoin", root,--конект игрока на сервер
function()
	local playerid = source
	local playername = getPlayerName ( playerid )
	local serial = getPlayerSerial(playerid)
	local ip = getPlayerIP ( playerid )

	job_call[playername] = 0
	job_ped[playername] = 0
	job_blip[playername] = 0
	job_marker[playername] = 0
	job_pos[playername] = 0
	job_vehicleid[playername] = 0
	job_timer[playername] = 0
	timer_job[playername] = 0
	job_object[playername] = 0
	job_vehicle[playername] = 0
end)

function update_taxi_pos()
	taxi_pos = {}

	for k,v in pairs(getElementData(resourceRoot, "interior_job")) do
		if k ~= 23 then
			table.insert(taxi_pos, {v[6],v[7],v[8]})
		end
	end

	for k,v in pairs(getElementData(resourceRoot, "house_pos")) do
		table.insert(taxi_pos, {v[1],v[2],v[3]})
	end
end

function update_fire_pos()
	fire_pos = {}

	for k,v in pairs(original_business_pos) do
		table.insert(fire_pos, {v[1],v[2],v[3]})
	end

	for k,v in pairs(getElementData(resourceRoot, "house_pos")) do
		table.insert(fire_pos, {v[1],v[2],v[3]})
	end
end

local table_job = {
	[1] = function(playerid,playername)--работа таксиста
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
			if getElementModel(vehicleid) == 420 then
				if getSpeed(vehicleid) < 1 then

					if job_call[playername] == 0 then
						update_taxi_pos()

						local randomize = random(1,#taxi_pos)

						sendMessage(playerid, "Езжайте на вызов", color_mes.yellow)

						job_call[playername] = 1
						job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
						job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
						job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

					elseif job_call[playername] == 1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							update_taxi_pos()

							local randomize = random(1,#taxi_pos)
							local randomize_skin = 1

							while true do
								local skin_table = getValidPedModels()
								local random1 = random(1,312)
								if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 and skin_table[random1] ~= 162 then
									randomize_skin = skin_table[random1]
									break
								else
									random1 = random(1,#skin_table)
								end
							end

							sendMessage(playerid, "Отвезите клиента", color_mes.yellow)

							job_call[playername] = 2
							job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
							job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0.0, true )

							setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								
							if not getVehicleOccupant ( vehicleid, 1 ) then
								warpPedIntoVehicle ( job_ped[playername], vehicleid, 1 )
							elseif not getVehicleOccupant ( vehicleid, 2 ) then
								warpPedIntoVehicle ( job_ped[playername], vehicleid, 2 )
							elseif not getVehicleOccupant ( vehicleid, 3 ) then
								warpPedIntoVehicle ( job_ped[playername], vehicleid, 3 )
							end
						end

					elseif job_call[playername] == 2 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							local randomize = random(get("zp_player_taxi")/2,get("zp_player_taxi"))

							inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

							sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

							destroyElement(job_ped[playername])
							destroyElement(job_blip[playername])
							destroyElement(job_marker[playername])

							job_ped[playername] = 0
							job_blip[playername] = 0
							job_marker[playername] = 0
							job_pos[playername] = 0
							job_call[playername] = 0
						end
					end
				end
			end
		end
	end,

	[2] = function(playerid,playername)--работа водителя мусоровоза
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
					if getElementModel(vehicleid) == getElementData(resourceRoot, "down_car_subject_pos")[1][6] then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								update_taxi_pos()

								local randomize = random(1,#taxi_pos)

								sendMessage(playerid, "Соберите мусор, потом доставьте его на свалку", color_mes.yellow)

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									update_taxi_pos()

									local randomize_zp = random(getElementData(resourceRoot, "down_car_subject_pos")[1][7]/2,getElementData(resourceRoot, "down_car_subject_pos")[1][7])
									local randomize = random(1,#taxi_pos)

									give_subject( playerid, "car", getElementData(resourceRoot, "down_car_subject_pos")[1][5], randomize_zp, false )

									job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

							if isPointInCircle3D(x,y,z, getElementData(resourceRoot, "down_car_subject_pos")[1][1],getElementData(resourceRoot, "down_car_subject_pos")[1][2],getElementData(resourceRoot, "down_car_subject_pos")[1][3], getElementData(resourceRoot, "down_car_subject_pos")[1][4]) and amount_inv_car_1_parameter(vehicleid, getElementData(resourceRoot, "down_car_subject_pos")[1][5]) ~= 0 then
								local randomize = amount_inv_car_2_parameter(vehicleid, getElementData(resourceRoot, "down_car_subject_pos")[1][5])

								inv_car_delet_1_parameter(playerid, getElementData(resourceRoot, "down_car_subject_pos")[1][5], true)

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_marker[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
							end

						end
					end
				end
	end,

	[3] = function(playerid,playername)--работа инкассатора
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid and getElementData(playerid, "crimes_data") == 0 then
					if getElementModel(vehicleid) == getElementData(resourceRoot, "down_car_subject_pos")[2][6] then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#original_business_pos)

								sendMessage(playerid, "Соберите деньги, потом доставьте их в банк (BS на карте)", color_mes.yellow)

								job_call[playername] = 1
								job_pos[playername] = {original_business_pos[randomize][1],original_business_pos[randomize][2],original_business_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize_zp = random(getElementData(resourceRoot, "down_car_subject_pos")[2][7]/2,getElementData(resourceRoot, "down_car_subject_pos")[2][7])
									local randomize = random(1,#original_business_pos)

									give_subject( playerid, "car", getElementData(resourceRoot, "down_car_subject_pos")[2][5], randomize_zp, false )

									job_pos[playername] = {original_business_pos[randomize][1],original_business_pos[randomize][2],original_business_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

							if isPointInCircle3D(x,y,z, getElementData(resourceRoot, "down_car_subject_pos")[2][1],getElementData(resourceRoot, "down_car_subject_pos")[2][2],getElementData(resourceRoot, "down_car_subject_pos")[2][3], getElementData(resourceRoot, "down_car_subject_pos")[2][4]) and amount_inv_car_1_parameter(vehicleid, getElementData(resourceRoot, "down_car_subject_pos")[2][5]) ~= 0 then
								local randomize = amount_inv_car_2_parameter(vehicleid, getElementData(resourceRoot, "down_car_subject_pos")[2][5])

								inv_car_delet_1_parameter(playerid, getElementData(resourceRoot, "down_car_subject_pos")[2][5], true)

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_marker[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
							end

						end
					end
				end
	end,

	[4] = function(playerid,playername)--работа рыболова
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
					if getElementModel(vehicleid) == getElementData(resourceRoot, "down_car_subject_pos")[3][6] then
						if getSpeed(vehicleid) <= 5 then

							if job_call[playername] == 0 then
								local fish_pos = {random(3000,4000), random(-3000,500), 0}

								sendMessage(playerid, "Соберите рыбу, потом доставьте её в доки Лос Сантоса", color_mes.yellow)

								job_call[playername] = 1
								job_pos[playername] = {fish_pos[1],fish_pos[2],fish_pos[3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize_zp = random(getElementData(resourceRoot, "down_car_subject_pos")[3][7]/2,getElementData(resourceRoot, "down_car_subject_pos")[3][7])
									local fish_pos = {random(3000,4000), random(-3000,500), 0}

									give_subject( playerid, "car", getElementData(resourceRoot, "down_car_subject_pos")[3][5], randomize_zp, false )

									job_pos[playername] = {fish_pos[1],fish_pos[2],fish_pos[3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

							if isPointInCircle3D(x,y,z, getElementData(resourceRoot, "down_car_subject_pos")[3][1],getElementData(resourceRoot, "down_car_subject_pos")[3][2],getElementData(resourceRoot, "down_car_subject_pos")[3][3], getElementData(resourceRoot, "down_car_subject_pos")[3][4]) and amount_inv_car_1_parameter(vehicleid, getElementData(resourceRoot, "down_car_subject_pos")[3][5]) ~= 0 then
								local randomize = amount_inv_car_2_parameter(vehicleid, getElementData(resourceRoot, "down_car_subject_pos")[3][5])

								inv_car_delet_1_parameter(playerid, getElementData(resourceRoot, "down_car_subject_pos")[3][5], true)

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_marker[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
							end

						end
					end
				end
	end,

	[5] = function(playerid,playername)--работа пилота
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
					if (getElementModel(vehicleid) == 593 or getElementModel(vehicleid) == 519) and getElementModel(playerid) == 61 then
						if getSpeed(vehicleid) <= 5 then

							if job_call[playername] == 0 then
								job_call[playername] = 1
								local randomize = job_call[playername]

								sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], color_mes.yellow)

								job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then--лв
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									local randomize = random(get("zp_player_plane")/2,get("zp_player_plane"))

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

									job_call[playername] = 2
									local randomize = job_call[playername]

									sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], color_mes.yellow)

									job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername] == 2 then--сф
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									local randomize = random(get("zp_player_plane")/2,get("zp_player_plane"))

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

									job_call[playername] = 3
									local randomize = job_call[playername]

									sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], color_mes.yellow)

									job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername] == 3 then--лс
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									local randomize = random(get("zp_player_plane")/2,get("zp_player_plane"))

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

									job_call[playername] = 1
									local randomize = job_call[playername]

									sendMessage(playerid, "Летите в аэропорт "..plane_job[randomize][4], color_mes.yellow)

									job_pos[playername] = {plane_job[randomize][1],plane_job[randomize][2],plane_job[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end
							end

						end
					end
				end
	end,

	[6] = function(playerid,playername)--работа Угонщик
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if getElementData(playerid, "crimes_data") >= get("crimes_giuseppe") then
					if (job_call[playername] == 0) then 
						local vehicleid = player_car_theft()

						if vehicleid then
							local pos = {getElementPosition(vehicleid)}
							local rot = {getElementRotation(vehicleid)}

							job_call[playername] = 1
							job_pos[playername] = {pos[1],pos[2],pos[3]}

							job_vehicleid[playername] = {vehicleid,pos[1],pos[2],pos[3],rot[3]}
							job_timer[playername] = setTimer(car_theft_fun, (get("car_theft_time")*60000), 1, playername)

							setElementData(playerid, "job_vehicleid", job_vehicleid[playername])

							sendMessage(playerid, "Угоните т/с гос.номер "..getVehiclePlateText(job_vehicleid[playername][1])..", у вас есть "..get("car_theft_time").." мин", color_mes.yellow)

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )
						
							triggerClientEvent( playerid, "createHudTimer", playerid, (get("car_theft_time")*60))
						end

					elseif (job_call[playername] == 1) then
						
						if (job_vehicleid[playername][1] == vehicleid) then
							
							local x1,y1 = player_position( playerid )

							job_call[playername] = 2

							local randomize = random(1,#sell_car_theft)

							addcrimes(playerid, get("zakon_car_theft_crimes"))

							sendMessage(playerid, "Езжайте в отстойник", color_mes.yellow)

							police_chat(playerid, "[ДИСПЕТЧЕР] Угон "..getVehicleNameFromModel(getElementModel(vehicleid)).." гос.номер "..getVehiclePlateText(vehicleid)..", координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

							job_pos[playername] = {sell_car_theft[randomize][1],sell_car_theft[randomize][2],sell_car_theft[randomize][3]}

							setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
						end
					
					elseif (job_call[playername] == 2) then
						
						if (isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5.0) and job_vehicleid[playername][1] == vehicleid) then
							
							if (getSpeed(vehicleid) < 1) then
								
								local randomize = 0

								if getVehicleType(vehicleid) == "Plane" or getVehicleType(vehicleid) == "Helicopter" then
									randomize = cash_helicopters[getElementModel(vehicleid)][2]*0.05
								else
									randomize = cash_car[getElementModel(vehicleid)][2]*0.05
								end

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								job_pos[playername] = 0
								job_call[playername] = 3

								car_theft_fun(playername, true)

								job_blip[playername] = 0
								job_marker[playername] = 0
							end
						end
					end
				end
	end,

	[7] = function(playerid,playername)--забойщик скота
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if job_call[playername] == 0 then
					job_call[playername] = 1
					local randomize = random(1,#korovi_pos)

					sendMessage(playerid, "Убейте корову", color_mes.yellow)

					job_pos[playername] = {korovi_pos[randomize][1],korovi_pos[randomize][2],korovi_pos[randomize][3]-1}
					job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
					job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

				elseif job_call[playername] == 1 then
					local result = sqlite( "SELECT * FROM cow_farms_db WHERE number = '"..search_inv_player_2_parameter(playerid, 87).."'" )

					if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) and result[1] and getPedWeapon(playerid) == getElementData(resourceRoot, "weapon")[38][2] then
						if result[1]["warehouse"] < get("max_cf") and result[1]["money"] >= result[1]["price"] and result[1]["nalog"] ~= 0 and result[1]["prod"] ~= 0 then
							local randomize = result[1]["price"]

							job_call[playername] = 2

							setPedAnimation(playerid, "knife", "knife_3", -1, true, false, false, false)

							setTimer(function ()
								if isElement(playerid) then
									setPedAnimation(playerid, nil, nil)
								end
							end, (10*1000), 1)

							sqlite( "UPDATE cow_farms_db SET warehouse = warehouse + '1', prod = prod - '1', money = money - '"..randomize.."' WHERE number = '"..search_inv_player_2_parameter(playerid, 87).."'" )

							inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

							sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)
						end
					end

				elseif job_call[playername] == 2 then
					destroyElement(job_blip[playername])
					destroyElement(job_marker[playername])

					job_blip[playername] = 0
					job_marker[playername] = 0
					job_pos[playername] = 0
					job_call[playername] = 0
				end
	end,

	[8] = function(playerid,playername)--работа перевозчика оружия
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid and getElementData(playerid, "crimes_data") == 0 then
					if getElementModel(vehicleid) == getElementData(resourceRoot, "up_car_subject")[5][6] then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#gans_pos)

								sendMessage(playerid, "Езжайте на завод KACC чтобы загрузить ящики с оружием, а потом развезите их по аммунациям", color_mes.yellow)

								job_call[playername] = 1
								job_pos[playername] = {gans_pos[randomize][1],gans_pos[randomize][2],gans_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) and amount_inv_car_1_parameter(vehicleid, getElementData(resourceRoot, "up_car_subject")[5][5]) ~= 0 then
									local randomize = random(1,#gans_pos)
									local sic2p = search_inv_car_2_parameter(vehicleid, getElementData(resourceRoot, "up_car_subject")[5][5])

									job_pos[playername] = {gans_pos[randomize][1],gans_pos[randomize][2],gans_pos[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])

									inv_car_delet(playerid, getElementData(resourceRoot, "up_car_subject")[5][5], sic2p, true, false)

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+sic2p, playername )

									sendMessage(playerid, "Вы получили "..sic2p.."$", color_mes.green)
								end
							end

						end
					end
				end
	end,

	[9] = function(playerid,playername)--работа автобусник
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
					if getElementModel(vehicleid) == 437 and getElementModel(playerid) == 253 then
						if getSpeed(vehicleid) < 1 and search_inv_player_2_parameter(playerid, getElementData(resourceRoot, "up_player_subject")[9][5]) ~= 0 then

							if job_call[playername] == 0 then

								sendMessage(playerid, "Езжайте по маршруту", color_mes.yellow)

								job_call[playername] = search_inv_player_2_parameter(playerid, getElementData(resourceRoot, "up_player_subject")[9][5])
								job_pos[playername] = {busdriver_pos[ job_call[playername] ][1],busdriver_pos[ job_call[playername] ][2],busdriver_pos[ job_call[playername] ][3]-1}

								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 15.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] >= 1 and job_call[playername] <= 3 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 15) then

									inv_player_delet(playerid, getElementData(resourceRoot, "up_player_subject")[9][5], job_call[playername], true)

									job_call[playername] = job_call[playername]+1

									inv_player_empty(playerid, getElementData(resourceRoot, "up_player_subject")[9][5], job_call[playername])

									job_pos[playername] = {busdriver_pos[ job_call[playername] ][1],busdriver_pos[ job_call[playername] ][2],busdriver_pos[ job_call[playername] ][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername] == 4 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 15) then
									local randomize = random(get("zp_player_busdriver")/2,get("zp_player_busdriver"))

									inv_player_delet(playerid, getElementData(resourceRoot, "up_player_subject")[9][5], job_call[playername], true)

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									sendMessage(playerid, "Вы получили за маршрут "..randomize.."$", color_mes.green)

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end

						end
					end
				end
	end,

	[10] = function(playerid,playername)--работа парамедик
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid and getElementData(playerid, "crimes_data") == 0 then
					if getElementModel(vehicleid) == 416 and (getElementModel(playerid) == 274 or getElementModel(playerid) == 275 or getElementModel(playerid) == 276 or getElementModel(playerid) == 145) then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								update_taxi_pos()

								local randomize = random(1,#taxi_pos)

								sendMessage(playerid, "Езжайте на вызов", color_mes.yellow)

								job_call[playername] = 1
								job_pos[playername] = {taxi_pos[randomize][1],taxi_pos[randomize][2],taxi_pos[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize_skin = 1

									while true do
										local skin_table = getValidPedModels()
										local random1 = random(1,312)
										if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 and skin_table[random1] ~= 162 then
											randomize_skin = skin_table[random1]
											break
										else
											random1 = random(1,#skin_table)
										end
									end

									sendMessage(playerid, "Отвезите пациента в ближайшую больницу", color_mes.yellow)

									job_call[playername] = 2
									job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0.0, true )

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])
									job_blip[playername] = 0
									job_marker[playername] = 0
								
									if not getVehicleOccupant ( vehicleid, 2 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 2 )
									elseif not getVehicleOccupant ( vehicleid, 3 ) then
										warpPedIntoVehicle ( job_ped[playername], vehicleid, 3 )
									end
								end

							elseif job_call[playername] == 2 then
								for k,v in pairs(getElementData(resourceRoot, "hospital_spawn")) do
									if isPointInCircle3D(x,y,z, v[1],v[2],v[3], 40) then
										local randomize = random(get("zp_player_medic")/2,get("zp_player_medic"))

										inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

										sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

										destroyElement(job_ped[playername])

										job_ped[playername] = 0
										job_pos[playername] = 0
										job_call[playername] = 0
									end
								end
							end

						end
					end
				end
	end,

	[11] = function(playerid,playername)--работа sas
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
					if getElementModel(vehicleid) == 574 then
						if getSpeed(vehicleid) < 61 then

							if job_call[playername] == 0 then

								sendMessage(playerid, "Езжайте по маршруту", color_mes.yellow)

								job_call[playername] = {getElementZoneName ( playerid, true ), random(1,2), 1}
								job_pos[playername] = {clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][1],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][2],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][3]-1}

								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername][3] >= 1 and job_call[playername][3] <= #clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ]-1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then

									job_call[playername][3] = job_call[playername][3]+1

									job_pos[playername] = {clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][1],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][2],clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ][ job_call[playername][3] ][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								end

							elseif job_call[playername][3] == #clear_street_pos[ job_call[playername][1] ][ job_call[playername][2] ] then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then
									local randomize = random(get("zp_player_sas")*job_call[playername][3]/2,get("zp_player_sas")*job_call[playername][3])

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									sendMessage(playerid, "Вы получили за маршрут "..randomize.."$", color_mes.green)

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end

						end
					end
				end
	end,

	[12] = function(playerid,playername)--работа пожарный
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid and getElementData(playerid, "crimes_data") == 0 then
					if getElementModel(vehicleid) == 407 and (getElementModel(playerid) == 277 or getElementModel(playerid) == 278 or getElementModel(playerid) == 279) then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								update_fire_pos()

								local randomize = random(1,#fire_pos)

								sendMessage(playerid, "Езжайте на вызов", color_mes.yellow)

								job_call[playername] = {1,random(1,2)}--2-ts
								job_pos[playername] = {fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3]-1}

								if job_call[playername][2] == 2 then
									local randomize = random(1,#vehicle_pos)
									job_pos[playername] = {vehicle_pos[randomize][2],vehicle_pos[randomize][3],vehicle_pos[randomize][4]-1}

									local vehicleid = createVehicle(vehicle_pos[randomize][1], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3]+1, 0, 0, vehicle_pos[randomize][5], "0")
									local plate = getVehiclePlateText ( vehicleid )

									job_vehicle[playername] = vehicleid

									setElementFrozen(vehicleid, true)
									sendMessage(playerid, "Возгорание т/с", color_mes.yellow)
								else
									sendMessage(playerid, "Возгорание здания", color_mes.yellow)
								end

								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 40.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername][1] >= 1 and job_call[playername][1] <= 59 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

									if getControlState ( playerid, "vehicle_fire" ) then
										job_call[playername][1] = job_call[playername][1]+1
									end

									triggerClientEvent( playerid, "event_createFire", playerid, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40, 5, 1)
								end

							elseif job_call[playername][1] == 60 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
									local randomize = random(get("zp_player_fire")/2,get("zp_player_fire"))

									triggerClientEvent( playerid, "event_extinguishFire", playerid, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40)

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									sendMessage(playerid, "Вы получили за вызов "..randomize.."$", color_mes.green)

									destroyElement(job_blip[playername])
									destroyElement(job_marker[playername])

									if job_call[playername][2] == 2 then
										destroyElement(job_vehicle[playername])
									end

									job_blip[playername] = 0
									job_marker[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
									job_vehicle[playername] = 0
								end
							end

						end
					end
				end
	end,

	[13] = function(playerid,playername)--работа swat
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if (getElementModel(playerid) == 285 or getElementModel(playerid) == 75) and search_inv_player_2_parameter(playerid, 10) == getElementData(playerid, "player_id") and getElementData(playerid, "crimes_data") == 0 then
					if job_call[playername] == 0 then
						update_fire_pos()

						local randomize = random(1,#fire_pos)

						--[[while true do
							if getZoneName ( fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3], true ) == "Los Santos" and "Los Santos" == getZoneName ( x,y,z, true ) then
								break
							elseif getZoneName ( fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3], true ) == "San Fierro" and "San Fierro" == getZoneName ( x,y,z, true ) then
								break
							elseif getZoneName ( fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3], true ) == "Las Venturas" and "Las Venturas" == getZoneName ( x,y,z, true ) then
								break
							else
								randomize = random(1,#fire_pos)
							end
						end]]

						sendMessage(playerid, "Езжайте на вызов", color_mes.yellow)

						job_call[playername] = {1,0,random(5,30)--[[n секунд чтобы преступник подумал]]}
						job_pos[playername] = {fire_pos[randomize][1],fire_pos[randomize][2],fire_pos[randomize][3]-1}

						job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )

					elseif job_call[playername][1] >= 1 and job_call[playername][1] <= job_call[playername][3] then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

							if job_call[playername][1] == 1 then
								local randomize_skin = 1

								while true do
									local skin_table = getValidPedModels()
									local random1 = random(1,312)
									if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 and skin_table[random1] ~= 162 then
										randomize_skin = skin_table[random1]
										break
									else
										random1 = random(1,#skin_table)
									end
								end

								job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3]+1, 0.0, true )

								function died()
									job_call[playername][1] = job_call[playername][3]+3
								end
								addEventHandler("onPedWasted", job_ped[playername], died)

								add_ped_in_no_ped_damage(job_ped[playername])

								me_chat(playerid, playername.." взял(а) мегафон в руку")
								do_chat(playerid, "говорит в мегафон - "..playername)
								ic_chat(playerid, "Это полиция, положите оружие на землю и поднимите руки вверх")
							end

							job_call[playername][1] = job_call[playername][1]+1
						end

					elseif job_call[playername][1] == job_call[playername][3]+1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							local randomize = random(1,2)

							triggerClientEvent(playerid, "event_givePedWeapon", playerid, job_ped[playername], getElementData(resourceRoot, "weapon")[18][2], 10000, true)

							if randomize == 1 then
								sendMessage(playerid, "Преступник сдается", color_mes.yellow)

								--setPedAnimation(job_ped[playername], "rob_bank", "shp_handsup_scr", -1, false, false, false, true)

								job_call[playername][1] = job_call[playername][3]+3
								job_call[playername][2] = randomize
							else
								sendMessage(playerid, "Устраните преступника", color_mes.yellow)

								delet_ped_in_no_ped_damage(job_ped[playername])

								--setPedAnimation(job_ped[playername], "ped", "gang_gunstand", -1, false, false, false, true)

								triggerClientEvent(playerid, "event_setPedControlState", playerid, job_ped[playername], "fire", true)

								job_call[playername][1] = job_call[playername][3]+2
								job_call[playername][2] = randomize
							end
						end

					elseif job_call[playername][1] == job_call[playername][3]+2 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							triggerClientEvent(playerid, "event_setPedAimTarget", playerid, job_ped[playername], x, y, z)

							local angle = math.deg(math.atan2(x-job_pos[playername][1],y-job_pos[playername][2]))*-1
							setElementRotation(job_ped[playername], 0,0,angle)
						end

					elseif job_call[playername][1] == job_call[playername][3]+3 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
							local randomize = random(get("zp_player_police")/2,get("zp_player_police"))

							inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

							sendMessage(playerid, "Вы получили за вызов "..randomize.."$", color_mes.green)

							delet_ped_in_no_ped_damage(job_ped[playername])

							destroyElement(job_blip[playername])
							destroyElement(job_ped[playername])

							job_blip[playername] = 0
							job_pos[playername] = 0
							job_call[playername] = 0
							job_ped[playername] = 0
						end
					end
				end
	end,

	--[[[14] = function(playerid,playername)--работа фермер
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if getElementModel(playerid) == 158 or getElementModel(playerid) == 198 then
					if ferm_etap == 1 then
						if job_call[playername] == 0 then

							job_call[playername] = 1
							job_pos[playername] = {-108.6884765625,-3.3505859375,3.1171875-1}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 1.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

						elseif job_call[playername] == 1 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(1,#grass_pos)

								job_call[playername] = 2

								job_pos[playername] = {grass_pos[randomize][2],grass_pos[randomize][3],grass_pos[randomize][4]+1.5}

								setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							end

						elseif job_call[playername] == 2 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(get("zp_player_ferm")/2,get("zp_player_ferm"))

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								setPedAnimation(playerid, "BOMBER", "BOM_Plant", -1, true, false, false, false)

								setTimer(function ()
									if isElement(playerid) then
										setPedAnimation(playerid, nil, nil)
									end
								end, (10*1000), 1)

								grass_pos_count = grass_pos_count+ferm_etap_count

								if grass_pos_count == #grass_pos then
									ferm_etap = 2
									grass_pos_count = 0

									for k,v in pairs(grass_pos) do
										setElementPosition(v[1], v[2],v[3],v[4]+0.2)
									end

									for _,i in pairs(getElementsByType("player")) do
										if job[getPlayerName(i)] == 14 then
											job_call[getPlayerName(i)] = 0

											local randomize = get("zp_player_ferm_etap")

											inv_server_load( i, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

											sendMessage(i, "Вы получили премию "..randomize.."$", color_mes.green)
										end
									end
								end

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
								job_marker[playername] = 0
							end
						end

					elseif ferm_etap == 2 then
						if job_call[playername] == 0 then

							job_call[playername] = 1
							job_pos[playername] = {-108.6884765625,-3.3505859375,3.1171875-1}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 1.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

						elseif job_call[playername] == 1 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(1,#grass_pos)

								job_call[playername] = 2

								job_pos[playername] = {grass_pos[randomize][2],grass_pos[randomize][3],grass_pos[randomize][4]+1.3}

								setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							end

						elseif job_call[playername] == 2 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(get("zp_player_ferm")/2,get("zp_player_ferm"))

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								object_attach(playerid, 321, 12, 0.15,0,0.3, 0,-90,0, (5*1000))

								setPedAnimation(playerid, "camera", "camstnd_idleloop", -1, true, false, false, false)

								setTimer(function ()
									if isElement(playerid) then
										setPedAnimation(playerid, nil, nil)
									end
								end, (5*1000), 1)

								grass_pos_count = grass_pos_count+ferm_etap_count

								if grass_pos_count == #grass_pos then
									ferm_etap = 3
									grass_pos_count = 0

									for k,v in pairs(grass_pos) do
										setElementPosition(v[1], v[2],v[3],v[4]+0.6)
									end

									for _,i in pairs(getElementsByType("player")) do
										if job[getPlayerName(i)] == 14 then
											job_call[getPlayerName(i)] = 0

											local randomize = get("zp_player_ferm_etap")

											inv_server_load( i, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

											sendMessage(i, "Вы получили премию "..randomize.."$", color_mes.green)
										end
									end
								end

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
								job_marker[playername] = 0
							end
						end

					elseif ferm_etap == 3 then
						if job_call[playername] == 0 then
							local randomize = random(1,#grass_pos)

							job_call[playername] = {1,randomize}
							job_pos[playername] = {grass_pos[randomize][2],grass_pos[randomize][3],grass_pos[randomize][4]}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 1.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

						elseif job_call[playername][1] == 1 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(1,#grass_pos)

								setPedAnimation(playerid, "rob_bank", "cat_safe_rob", -1, true, false, false, false)

								setTimer(function ()
									if isElement(playerid) then
										setPedAnimation(playerid, nil, nil)
									end
								end, (10*1000), 1)

								job_call[playername][1] = 2

								job_pos[playername] = {-108.6884765625,-3.3505859375,3.1171875-1}

								setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
								setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
							end

						elseif job_call[playername][1] == 2 then
							if isPointInCircle2D(x,y, job_pos[playername][1],job_pos[playername][2], 1) then
								local randomize = random(get("zp_player_ferm")/2,get("zp_player_ferm"))

								inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

								sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

								grass_pos_count = grass_pos_count+ferm_etap_count

								if grass_pos_count == #grass_pos then
									ferm_etap = 1
									grass_pos_count = 0

									for k,v in pairs(grass_pos) do
										setElementPosition(v[1], v[2],v[3],v[4]-1.5)
									end

									for _,i in pairs(getElementsByType("player")) do
										if job[getPlayerName(i)] == 14 then
											job_call[getPlayerName(i)] = 0

											local randomize = get("zp_player_ferm_etap")

											inv_server_load( i, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

											sendMessage(i, "Вы получили премию "..randomize.."$", color_mes.green)
										end
									end
								end

								destroyElement(job_blip[playername])
								destroyElement(job_marker[playername])

								job_blip[playername] = 0
								job_pos[playername] = 0
								job_call[playername] = 0
								job_marker[playername] = 0
							end
						end
					end
				end
	end,]]

	[15] = function(playerid,playername)--работа охотник
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if (getElementModel(playerid) == 312) then
					if job_call[playername] == 0 then
						local bamby_pos = getElementData(resourceRoot, "BambyPosition")
						local randomize = random(1,#bamby_pos.X)

						sendMessage(playerid, "Найдите оленя", color_mes.yellow)

						job_call[playername] = 1
						job_pos[playername] = {bamby_pos.X[randomize],bamby_pos.Y[randomize],bamby_pos.Z[randomize]-1}

						job_object[playername] = createObject ( 1851, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 90,0,0 )
						setElementFrozen(job_object[playername], true)
						setElementData(playerid, "deer", false)
						setElementData(playerid, "job_pos_15", job_pos[playername])

					elseif job_call[playername] == 1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 100) then
							sendMessage(playerid, "Убейте оленя", color_mes.yellow)

							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "cylinder", 1.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							job_call[playername] = 2
						end

					elseif job_call[playername] == 2 and getElementData(playerid, "deer") then
						sendMessage(playerid, "Заберите тушку оленя", color_mes.yellow)

						setElementPosition(job_object[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3]+0.5)
						setElementRotation(job_object[playername], 0, 90, 0)

						job_call[playername] = 3

					elseif job_call[playername] == 3 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then
							local randomize = random(get("zp_player_bamby")/2,get("zp_player_bamby"))

							give_subject(playerid, "player", getElementData(resourceRoot, "down_player_subject")[5][5], randomize)

							destroyElement(job_object[playername])
							destroyElement(job_marker[playername])

							job_object[playername] = 0
							job_pos[playername] = 0
							job_call[playername] = 0
							job_marker[playername] = 0
						end
					end
				end
	end,

	[16] = function(playerid,playername)--работа развозчик пиццы
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid then
					if getElementModel(vehicleid) == getElementData(resourceRoot, "up_car_subject")[6][6] and getElementModel(playerid) == 155 then
						if getSpeed(vehicleid) < 1 then

							if job_call[playername] == 0 then
								local randomize = random(1,#getElementData(resourceRoot, "house_pos"))

								sendMessage(playerid, "Езжайте к пиццерии в гетто чтобы загрузить пиццу, а потом развезите их по домам", color_mes.yellow)

								job_call[playername] = 1
								job_pos[playername] = {getElementData(resourceRoot, "house_pos")[randomize][1],getElementData(resourceRoot, "house_pos")[randomize][2],getElementData(resourceRoot, "house_pos")[randomize][3]-1}
								job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
								job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )

							elseif job_call[playername] == 1 then
								if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) and amount_inv_car_1_parameter(vehicleid, getElementData(resourceRoot, "up_car_subject")[6][5]) ~= 0 then
									local randomize = random(1,#getElementData(resourceRoot, "house_pos"))
									local sic2p = search_inv_car_2_parameter(vehicleid, getElementData(resourceRoot, "up_car_subject")[6][5])

									job_pos[playername] = {getElementData(resourceRoot, "house_pos")[randomize][1],getElementData(resourceRoot, "house_pos")[randomize][2],getElementData(resourceRoot, "house_pos")[randomize][3]-1}

									setElementPosition(job_blip[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
									setElementPosition(job_marker[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])

									inv_car_delet(playerid, getElementData(resourceRoot, "up_car_subject")[6][5], sic2p, true, false)

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+sic2p, playername )

									sendMessage(playerid, "Вы получили "..sic2p.."$", color_mes.green)
								end
							end

						end
					end
				end
	end,

	[17] = function(playerid,playername)--работа умд
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if (getElementModel(playerid) == 311) then
					if job_call[playername] == 0 then
						local box_pos = {random(-3000,3000), random(-4000,-3000), -68}

						sendMessage(playerid, "Соберите потерянный груз, потом доставьте его к NPC в доки Лос Сантоса", color_mes.yellow)

						job_call[playername] = 1
						job_pos[playername] = {box_pos[1],box_pos[2],box_pos[3]-1}

						setElementData(playerid, "job_pos_17", job_pos[playername])

						job_object[playername] = createObject(3798, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0,0,0)
						
					elseif job_call[playername] == 1 then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then
							local randomize = random(get("zp_player_box")/2,get("zp_player_box"))
							local box_pos = {random(-3000,3000), random(-4000,-3000), -68}

							job_pos[playername] = {box_pos[1],box_pos[2],box_pos[3]-1}

							give_subject(playerid, "player", getElementData(resourceRoot, "down_player_subject")[7][5], randomize)

							setElementPosition(job_object[playername], job_pos[playername][1],job_pos[playername][2],job_pos[playername][3])
						end
					end
				end
	end,

	[18] = function(playerid,playername)--работа транспортный детектив
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if (getElementModel(playerid) == 284) and search_inv_player_2_parameter(playerid, 10) == getElementData(playerid, "player_id") and getElementData(playerid, "crimes_data") == 0 and search_inv_player_2_parameter(playerid, 109) ~= 0 then
					if (job_call[playername] == 0) then
						local plate = search_inv_player_2_parameter(playerid, 109)--player_car_police()

						if plate then
							local result = sqlite( "SELECT * FROM car_db WHERE number = '"..plate.."'" )
							local pos = {result[1]["x"],result[1]["y"],result[1]["z"]}

							job_call[playername] = {1,plate}
							job_pos[playername] = {pos[1],pos[2],pos[3]}

							sendMessage(playerid, "Найдите т/с гос.номер "..job_call[playername][2], color_mes.yellow)

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
							job_marker[playername] = createMarker ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], "checkpoint", 5.0, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, playerid )
						end

					elseif (job_call[playername][1] == 1) then
						if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5.0) then
							local randomize = random(get("zp_player_police_car")/2,get("zp_player_police_car"))

							inv_player_delet(playerid, 109, job_call[playername][2])

							sqlite( "UPDATE car_db SET theft = '0' WHERE number = '"..job_call[playername][2].."'")

							car_spawn(job_call[playername][2])

							inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

							sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

							destroyElement(job_blip[playername])
							destroyElement(job_marker[playername])

							job_blip[playername] = 0
							job_pos[playername] = 0
							job_call[playername] = 0
							job_marker[playername] = 0
						end
					end
				end
	end,

	[19] = function(playerid,playername)--работа спасатель
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		if vehicleid and getElementData(playerid, "crimes_data") == 0 then
					if getElementModel(vehicleid) == 563 and (getElementModel(playerid) == 277 or getElementModel(playerid) == 278 or getElementModel(playerid) == 279) then
						if job_call[playername] == 0 then
							local ped_pos = {random(-3000,3000), random(-5000,-4000), 0}
							local randomize_skin = 1

							while true do
								local skin_table = getValidPedModels()
								local random1 = random(1,312)
								if skin_table[random1] and skin_table[random1] ~= 264 and skin_table[random1] ~= 311 and skin_table[random1] ~= 162 then
									randomize_skin = skin_table[random1]
									break
								else
									random1 = random(1,#skin_table)
								end
							end

							sendMessage(playerid, "Спасите человека в океане", color_mes.yellow)

							job_call[playername] = 1
							job_pos[playername] = {ped_pos[1],ped_pos[2],ped_pos[3]}

							job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )
							job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0.0, true )
							add_ped_in_no_ped_damage(job_ped[playername])

						elseif job_call[playername] == 1 then
							if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 5) then
								sendMessage(playerid, "Отвезите пострадавшего в ближайшую больницу", color_mes.yellow)

								if not getVehicleOccupant ( vehicleid, 1 ) then
									warpPedIntoVehicle ( job_ped[playername], vehicleid, 1 )
								end
									
								delet_ped_in_no_ped_damage(job_ped[playername])

								job_call[playername] = 2

								destroyElement(job_blip[playername])

								job_blip[playername] = 0
							end

						elseif job_call[playername] == 2 then
							for k,v in pairs(getElementData(resourceRoot, "hospital_spawn")) do
								if isPointInCircle3D(x,y,z, v[1],v[2],v[3], 40) then
									local randomize = random(get("zp_player_rescuer")/2,get("zp_player_rescuer"))

									sendMessage(playerid, "Вы получили "..randomize.."$", color_mes.green)

									inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

									destroyElement(job_ped[playername])

									job_ped[playername] = 0
									job_pos[playername] = 0
									job_call[playername] = 0
								end
							end
						end
					end
				end	
	end,

	[20] = function(playerid,playername)--работа киллер
		local vehicleid = getPlayerVehicle(playerid)
		local x,y,z = getElementPosition(playerid)
		local skin_table = {}

				for k,v in pairs(name_mafia) do
					if k ~= 0 then
						for k,v in pairs(v[2]) do
							table.insert(skin_table, v)

							if getElementModel(playerid) == v and search_inv_player_2_parameter(playerid, 85) ~= 0 and getElementData(playerid, "crimes_data") >= get("crimes_kill") then
								if job_call[playername] == 0 then
									local randomize = random(1,#original_business_pos)

									sendMessage(playerid, "Устраните цель", color_mes.yellow)

									job_call[playername] = 1
									job_pos[playername] = {original_business_pos[randomize][1],original_business_pos[randomize][2],original_business_pos[randomize][3]-1}

									job_blip[playername] = createBlip ( job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 0, 2, color_mes.yellow[1],color_mes.yellow[2],color_mes.yellow[3], 255, 0, 16383.0, playerid )

								elseif job_call[playername] == 1 then
									if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then

										local random1 = random(1,#skin_table)
										local randomize_skin = skin_table[random1]

										local x1,y1 = player_position( playerid )
										police_chat(playerid, "[ДИСПЕТЧЕР] Перестрелка, координаты [X  "..x1..", Y  "..y1.."], подозреваемый "..playername)

										job_call[playername] = 2
										job_ped[playername] = createPed ( randomize_skin, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3]+1, 0.0, true )

										triggerClientEvent(playerid, "event_givePedWeapon", playerid, job_ped[playername], getElementData(resourceRoot, "weapon")[18][2], 10000, true)
										triggerClientEvent(playerid, "event_setPedControlState", playerid, job_ped[playername], "fire", true)

										function died()
											job_call[playername] = 3

											addcrimes(playerid, get("zakon_kill_crimes"))
										end
										addEventHandler("onPedWasted", job_ped[playername], died)
									end

								elseif job_call[playername] == 2 then
									if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
										triggerClientEvent(playerid, "event_setPedAimTarget", playerid, job_ped[playername], x, y, z)
									end

								elseif job_call[playername] == 3 then
									if isPointInCircle3D(x,y,z, job_pos[playername][1],job_pos[playername][2],job_pos[playername][3], 40) then
										local randomize = random(get("zp_player_kill")/2,get("zp_player_kill"))

										inv_server_load( playerid, "player", 0, 1, search_inv_player_2_parameter(playerid, 1)+randomize, playername )

										sendMessage(playerid, "Вы получили за задание "..randomize.."$", color_mes.green)

										destroyElement(job_blip[playername])
										destroyElement(job_ped[playername])

										job_blip[playername] = 0
										job_pos[playername] = 0
										job_call[playername] = 0
										job_ped[playername] = 0
									end
								end
							end
						end
					end
				end
	end,
}

function job_timer2 (playerid)
	local playername = getPlayerName(playerid)

	timer_job[playername] = setTimer(table_job[getElementData(playerid, "job_player")], 1000, 0, playerid,playername)
end

function job_0( playername )
	if isTimer(timer_job[playername]) then
		killTimer(timer_job[playername])
	end

	if job_ped[playername] ~= 0 then
		destroyElement(job_ped[playername])

		delet_ped_in_no_ped_damage(job_ped[playername])
	end

	if job_blip[playername] ~= 0 then
		destroyElement(job_blip[playername])
	end

	if job_marker[playername] ~= 0 then
		destroyElement(job_marker[playername])
	end

	if job_object[playername] ~= 0 then
		destroyElement(job_object[playername])
	end

	if job_vehicle[playername] ~= 0 then
		destroyElement(job_vehicle[playername])
	end

	setElementData(getPlayerFromName(playername), "job_player", 0)
	job_pos[playername] = 0
	job_call[playername] = 0
	timer_job[playername] = 0

	job_ped[playername] = 0
	job_blip[playername] = 0
	job_marker[playername] = 0
	job_object[playername] = 0
	job_vehicle[playername] = 0
end

function car_theft_fun(playername, car_theft_win)

	if(job_vehicleid[playername] ~= 0) then

		for k,v in pairs(getElementsByType("player")) do
		
			if(getPlayerVehicle(v) == job_vehicleid[playername][1]) then
			
				removePedFromVehicle(v)
			end
		end

		setTimer(function() 
			setElementPosition(job_vehicleid[playername][1],job_vehicleid[playername][2],job_vehicleid[playername][3],job_vehicleid[playername][4])
			setElementRotation(job_vehicleid[playername][1], 0,0,job_vehicleid[playername][5])

			local plate = getVehiclePlateText(job_vehicleid[playername][1])
			local result = sqlite( "SELECT COUNT() FROM car_db WHERE number = '"..plate.."'" )
			if (result[1]["COUNT()"] == 1) then
				sqlite( "UPDATE car_db SET x = '"..job_vehicleid[playername][2].."', y = '"..job_vehicleid[playername][3].."', z = '"..job_vehicleid[playername][4].."', rot = '"..job_vehicleid[playername][5].."', fuel = '"..fuel[plate].."', probeg = '"..probeg[plate].."' WHERE number = '"..plate.."'")
			end

			if car_theft_win then
				sqlite( "UPDATE car_db SET theft = '1' WHERE number = '"..plate.."'")
				destroyElement(job_vehicleid[playername][1])
			end

			job_vehicleid[playername] = 0
			job_call[playername] = 0
		end, 1000, 1)

		if(isTimer(job_timer[playername])) then
		
			killTimer(job_timer[playername])
		end

		job_timer[playername] = 0

		if job_blip[playername] ~= 0 then
			destroyElement(job_blip[playername])
		end

		if job_marker[playername] ~= 0 then
			destroyElement(job_marker[playername])
		end

		job_blip[playername] = 0
		job_marker[playername] = 0

		triggerClientEvent( getPlayerFromName(playername), "destroyHudTimer", getPlayerFromName(playername) )
	end
end

function player_in_car_theft(plate) 

	local count = 0

	for k,v in pairs(getElementsByType("player")) do
		local playername = getPlayerName(v)
		if(job_vehicleid[playername] ~= 0) then
		
			if( getVehiclePlateText(job_vehicleid[playername][1]) == plate ) then
			
				count = count+1
			end
		end
	end

	return count
end

function player_car_theft()
	local car_theft_table = {}

	for k,vehicleid in pairs(getElementsByType("vehicle")) do
		if getElementDimension(vehicleid) == 0 and (getVehicleType(vehicleid) == "Automobile" or getVehicleType(vehicleid) == "Bike" or getVehicleType(vehicleid) == "Monster Truck" or getVehicleType(vehicleid) == "Quad" or getVehicleType(vehicleid) == "Helicopter" or getVehicleType(vehicleid) == "Plane") then
			table.insert(car_theft_table, vehicleid)
		end
	end

	if #car_theft_table > 0 then
		local vehicleid = random(1,#car_theft_table)
		return car_theft_table[vehicleid]
	else
		return false
	end
end

function player_car_police()
	local car_theft_table = {}

	for k,v in pairs(sqlite( "SELECT * FROM car_db WHERE theft = '1'" )) do
		table.insert(car_theft_table, v["number"])
	end

	if #car_theft_table > 0 then
		local vehicleid = random(1,#car_theft_table)
		return car_theft_table[vehicleid]
	else
		return false
	end
end