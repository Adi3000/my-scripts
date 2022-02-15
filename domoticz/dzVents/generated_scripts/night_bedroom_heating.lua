return {
	on = {
		devices = {
			'PiZiGate - Chambre 1 (Temp)',
			'PiZiGate - Chambre 2 (Temp)',
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	data = {
        previousSetPoint = { initial = { } }
    },
	execute = function(domoticz, device) 
	    local upstairsCheckerDevice = domoticz.devices("Mode dodo")
		local heatingDevice = domoticz.devices("Chauffage")
		local thermDevice = domoticz.devices(string.gsub(device.name, "[(]Temp[)]", "(Therm)"))
		local valveDevice = domoticz.devices(string.gsub(device.name, "[(]Temp[)]", "(Valve)"))
		if domoticz.data.previousSetPoint['idx'..thermDevice.id] == nil  then
		    domoticz.data.previousSetPoint['idx'..thermDevice.id] = thermDevice.setPoint
        end
        local lastMinTemp = domoticz.data.previousSetPoint['idx'..thermDevice.id]
        
        if upstairsCheckerDevice.state == "On"  and  device.name ~= 'PiZiGate - Chambre 2 (Temp)'  then
    		domoticz.log('Device ' .. device.name .. ' is at '.. device.temperature ..' Set point at '..minTemp, domoticz.LOG_DEBUG)
    		if  device.temperature < lastMinTemp then
                heatingDevice.switchOn().checkFirst()
                valveDevice.switchSelector("Manual").checkFirst()
        		domoticz.log('Heating enabled : ' .. device.name .. ' is at '.. device.temperature ..' Night set point at '.. lastMinTemp , domoticz.LOG_INFO)
            elseif device.temperature >= thermDevice.setPoint then
                domoticz.data.previousSetPoint['idx'..thermDevice.id] = thermDevice.setPoint
                heatingDevice.switchOff().checkFirst()
                valveDevice.switchSelector("Off").checkFirst()
        		domoticz.log('Heating disabled : ' .. device.name .. ' is at '.. device.temperature ..' Night set point at '.. thermDevice.setPoint, domoticz.LOG_INFO)
    		end
	    elseif device.temperature < lastMinTemp  then
            valveDevice.switchSelector("Manual").checkFirst()
        	domoticz.log('Valve enabled : ' .. device.name .. ' is at '.. device.temperature ..' Stored set point at '.. lastMinTemp , domoticz.LOG_INFO)
        elseif  device.temperature >= thermDevice.setPoint then
            domoticz.data.previousSetPoint['idx'..thermDevice.id] = thermDevice.setPoint
            valveDevice.switchSelector("Off").checkFirst()
     		domoticz.log('Valve disabled : ' .. device.name .. ' is at '.. device.temperature ..' Stored set point at '.. domoticz.data.previousSetPoint['idx'..thermDevice.id], domoticz.LOG_INFO)
        end
        
	end
}