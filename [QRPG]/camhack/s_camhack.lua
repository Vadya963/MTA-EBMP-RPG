function setPlayerCamHackEnabled( thePlayer, state )
	return triggerClientEvent( thePlayer,"onClientEnableCamMode", root, state )
end

function setPlayerCamHackDisabled( thePlayer )
	return triggerClientEvent( thePlayer,"onClientDisableCamMode", root )
end

addEventHandler( "onResourceStop", resourceRoot, 
	function( )
		for i,thePlayer in pairs( getElementsByType( "player" ) ) do
			if getElementData( thePlayer, "isPlayerInCamHackMode" ) then 
				setElementAlpha( thePlayer, 255 )
				setElementFrozen( thePlayer, false ) 
				setElementCollisionsEnabled( thePlayer, true ) 	
			end
		end
	end
)

	function camhackm_fun( thePlayer )
		if isPedInVehicle( thePlayer ) then
			if getVehicleOccupant( getPedOccupiedVehicle( thePlayer ) ) ~= thePlayer then
				if getElementData( thePlayer, "isPlayerInCamHackMode" ) then 
					--setElementAlpha( thePlayer, 255 )
					setPlayerCamHackDisabled( thePlayer )
				else
					--setElementAlpha( thePlayer, 0 )
					setPlayerCamHackEnabled( thePlayer, false )
				end
			end
		else
			if getElementData( thePlayer, "isPlayerInCamHackMode" ) then 
				--setElementAlpha( thePlayer, 255 )
				setPlayerCamHackDisabled( thePlayer )
				setElementFrozen( thePlayer, false ) 
				setElementCollisionsEnabled( thePlayer, true ) 		
			else
				--setElementAlpha( thePlayer, 0 )
				setPlayerCamHackEnabled( thePlayer, false )
				setElementFrozen( thePlayer, true ) 
				setElementCollisionsEnabled( thePlayer, false ) 			
			end
		end
	end

addEvent("event_camhackm_fun", true)
addEventHandler("event_camhackm_fun", root, camhackm_fun)