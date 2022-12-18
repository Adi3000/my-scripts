local Time = require('Time')
return {
	on = {
		devices = {
			'PiZiGate - Motion Baignoire'
		},
		customEvents = {
			'waterShower'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	data = {
        last_on = { initial = Time()  }
    },
	execute = function(domoticz, device)
		local targetedDevice = domoticz.devices('Eau Chaude')
		local waitMinutes = domoticz.variables('showerMinDelay').value
		domoticz.log('Device ' .. targetedDevice.name .. ' is triggered ', domoticz.LOG_INFO)
		if device.isCustomEvent and device.data == 'false' then
            domoticz.log('Event received with a '.. device.data .. ' from trigger at '..domoticz.data.last_on.rawDateTime , domoticz.LOG_INFO)
            if domoticz.time.compare(domoticz.data.last_on).minutes >= waitMinutes  then
                targetedDevice.switchOff().checkFirst()
            end
        elseif device.isDevice or device.isCustomEvent then
		    domoticz.data.last_on = Time()
		    domoticz.log('Triggered '.. targetedDevice.name .. ' at ' .. domoticz.data.last_on.rawDateTime, domoticz.LOG_INFO)
    		targetedDevice.cancelQueuedCommands()
            targetedDevice.switchOn().checkFirst()
            domoticz.emitEvent('waterShower','false').afterMin(waitMinutes)
        end
	end
}