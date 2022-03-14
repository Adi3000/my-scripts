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
	execute = function(domoticz, device)
		local targetedDevice = domoticz.devices('Eau Chaude')
		domoticz.log('Device ' .. targetedDevice.name .. ' is triggered something', domoticz.LOG_INFO)
		if  device.bState  then
    		targetedDevice.cancelQueuedCommands()
            targetedDevice.switchOn().checkFirst()
            targetedDevice.switchOff().afterMin(domoticz.variables('showerMinDelay').value)
        end
	end
}