return {
	on = {
		devices = {
		    --'PiZiGate - Chambre 1 (Temp)',
			--'PiZiGate - Chambre 2 (Temp)',
			--'PiZiGate - Couloir (Temp)',
			'PiZiGate - Salon (Temp)',
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
	        local checkHeating = false
	        local downstairsCheckerDevice = domoticz.devices("En bas")
        	local upstairsCheckerDevice = domoticz.devices("Mode dodo")
  	        if upstairsCheckerDevice.state == "On" and device.name == 'PiZiGate - Couloir (Temp)' then
  	            checkHeating = true
  	        elseif downstairsCheckerDevice.state == "On" and device.name == 'PiZiGate - Salon (Temp)'  then
  	            checkHeating = true
  	        end
  	        if checkHeating == true and device.temperature ~= 0 and device.temperature ~= 80 then
            	domoticz.log('Heat check active : ' .. device.name .. ' is at '.. device.temperature, domoticz.LOG_INFO)
        		local heatingDevice = domoticz.devices("Chauffage")
        		local presenceDevice = domoticz.devices("Presence")
        		local minTemp = domoticz.variables('globalMinTemp').value 
        		local maxTemp = domoticz.variables('globalMaxTemp').value
        		domoticz.log('Device ' .. device.name .. ' is at '.. device.temperature ..' Min/max Set point at '..minTemp ..'/'..maxTemp, domoticz.LOG_DEBUG)
        		if device.temperature < minTemp and presenceDevice.state == "On"  then
                    heatingDevice.switchOn().checkFirst()
            		domoticz.log('Heating enabled : ' .. device.name .. ' is at '.. device.temperature ..' Global Min set point at '.. minTemp , domoticz.LOG_INFO)
                elseif device.temperature >= maxTemp  then
                    heatingDevice.switchOff().checkFirst()
            		domoticz.log('Heating disabled : ' .. device.name .. ' is at '.. device.temperature ..' Global Max set point at '.. maxTemp, domoticz.LOG_INFO)
        		end
    	    else
    	       domoticz.log('Avoid heat check for ' .. device.name .. ' at '.. device.temperature, domoticz.LOG_DEBUG)
        	end
	end
}