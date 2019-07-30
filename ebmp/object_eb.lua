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
	{"knife", 322},
	{"pumpkin01", 323},
	{"hfyri", 311},
	{"sheriffpolicefemale", 64},
	{"sofybu_2", 75},
	{"wfyclpd", 87},
	{"wfyclot", 145},
	{"wmyplt", 62},
	{"vitpra", 162},
	{"grenade", 342},
	{"colt45", 346},
	{"desert_eagle", 348},
	{"chromegun", 349},
	{"nitestick", 334},
	{"cuntgun", 357},
	{"ak47", 355},
	{"m4", 356},
	{"chnsaw", 341},
	{"micro_uzi", 352},
	{"mp5lng", 353},
	{"silenced", 347},
	{"spraycan", 365},
	{"teargas", 343},
}

local wheel = {
	{"wheel_gn1", 1082},
	{"wheel_gn2", 1085},
	{"wheel_gn3", 1096},
	{"wheel_gn4", 1097},
	{"wheel_gn5", 1098},
	{"wheel_lr1", 1077},
	{"wheel_lr2", 1083},
	{"wheel_lr3", 1078},
	{"wheel_lr4", 1076},
	{"wheel_lr5", 1084},
	{"wheel_or1", 1025},
	{"wheel_sr1", 1079},
	{"wheel_sr2", 1075},
	{"wheel_sr3", 1074},
	{"wheel_sr4", 1081},
	{"wheel_sr5", 1080},
	{"wheel_sr6", 1073},
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

		for k,v in pairs(wheel) do
			local dff = engineLoadDFF ( "dff_and_txd/"..v[1]..".dff" )
			engineReplaceModel ( dff, v[2] )
		end
	end
end)