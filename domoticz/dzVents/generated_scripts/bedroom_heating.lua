return {
	on = {
		devices = {
			'PiZiGate - Chambre 1 (Temp)',
			'PiZiGate - Chambre 2 (Temp)',
			'Mode dodo'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, deviceInput) 
	    local device = deviceInput
	    if deviceInput.name == 'Mode dodo' then
	        device = domoticz.devices("PiZiGate - Chambre 1 (Temp)")
        end
	    local upstairsCheckerDevice = domoticz.devices("Mode dodo")
		local heatingDevice = domoticz.devices("Chauffage")
		local presenceDevice = domoticz.devices("Presence")
		local thermDevice = domoticz.devices(string.gsub(device.name, "[(]Temp[)]", "(Therm)"))
		local valveDevice = domoticz.devices(string.gsub(device.name, "[(]Temp[)]", "(Valve)"))
        local offTemp = domoticz.variables('globalOffTemp').value
        local minTemp = domoticz.variables('globalMinTemp').value
        local maxTemp = domoticz.variables('globalMaxTemp').value
        local heatingOn = thermDevice.setPoint > offTemp
		domoticz.log('Status : ' .. device.name .. ' , activation : '.. tostring(heatingOn) ..  ' (raw Set point : '..thermDevice.setPoint..')' , domoticz.LOG_INFO)
        if upstairsCheckerDevice.state == "On"  and  presenceDevice.state == "On"  then
    		if  device.temperature < minTemp then
                heatingDevice.switchOn().checkFirst()
                if valveDevice.state ~= "Manual" or heatingOn == false then 
                    valveDevice.switchSelector("Manual").checkFirst()
                    thermDevice.updateSetPoint(maxTemp)
                end
        		domoticz.log('Heating enabled : ' .. device.name .. ' is at '.. device.temperature ..' Min set point at '.. minTemp , domoticz.LOG_INFO)
            elseif device.temperature > maxTemp then
                heatingDevice.switchOff().checkFirst()
                if valveDevice.state ~= "Manual" or heatingOn == true then 
                    valveDevice.switchSelector("Manual").checkFirst()
                    thermDevice.updateSetPoint(offTemp)
                end
        		domoticz.log('Heating disabled : ' .. device.name .. ' is at '.. device.temperature ..' Max set point at '.. maxTemp, domoticz.LOG_INFO)
    		end
        elseif device.temperature < minTemp and heatingOn == false then
            if valveDevice.state ~= "Manual" then
                valveDevice.switchSelector("Manual").checkFirst()
            end
            thermDevice.updateSetPoint(maxTemp)
        	domoticz.log('Valve enabled : ' .. device.name .. ' is at '.. device.temperature ..' Min set point at '.. minTemp , domoticz.LOG_INFO)
        elseif  device.temperature > maxTemp and heatingOn == true then
            if valveDevice.state ~= "Manual" then
                valveDevice.switchSelector("Manual").checkFirst()
            end
            thermDevice.updateSetPoint(offTemp)
     		domoticz.log('Valve disabled : ' .. device.name .. ' is at '.. device.temperature ..' Max set point at '.. maxTemp, domoticz.LOG_INFO)
        end
        
	end
}