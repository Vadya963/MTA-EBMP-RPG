local dff_and_txd_table = {
	{"leyka", 321},
	{"horse", 264},
	{"gun_cane", 326},
	{"bat", 336},
	{"knifecur", 335},
	{"shovel", 337},
	{"pig", 2804, true},
	{"coal", 3931, true},
	{"armour", 1242},
}

local car_spawn_value = 0
addEventHandler( "onClientResourceStart", getRootElement( ),
function ( startedRes )
	if car_spawn_value == 0 then
		car_spawn_value = 1

		for k,v in pairs(dff_and_txd_table) do
			local txd = engineLoadTXD ( "dff_and_txd/"..v[1]..".txd" )
			engineImportTXD ( txd, v[2] )
			local dff = engineLoadDFF ( "dff_and_txd/"..v[1]..".dff" )
			engineReplaceModel ( dff, v[2] )

			if v[3] then
				local col = engineLoadCOL ( "dff_and_txd/"..v[1]..".col" )
				engineReplaceCOL ( col, v[2] )
			end
		end
	end
end)