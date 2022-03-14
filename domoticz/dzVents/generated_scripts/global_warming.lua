return {
	on = {
		devices = {
			'PiZiGate - Salon (Temp)',
			'En bas',
			'Presence'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, trigger)
	        local checkHeating = false
	        local device = domoticz.devices("PiZiGate - Salon (Temp)")
	        local downstairsCheckerDevice = domoticz.devices("En bas")
    		local presenceDevice = domoticz.devices("Presence")
  	        if downstairsCheckerDevice.state == "On" then
  	            checkHeating = true
  	        end
  	        local minTemp = domoticz.variables('globalMinTemp').value 
        	local maxTemp = domoticz.variables('globalMaxTemp').value
        	domoticz.log('Heat check '..downstairsCheckerDevice.state..'/'..presenceDevice.state..' : ' .. device.name .. ' is at '.. device.temperature, domoticz.LOG_INFO)
  	        if checkHeating == true then
            	domoticz.log('Heat check active : ' .. device.name .. ' is at '.. device.temperature, domoticz.LOG_INFO)
        		local heatingDevice = domoticz.devices("Chauffage")
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