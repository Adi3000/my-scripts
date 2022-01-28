return {
	on = {
		devices = {
			'PiZiGate - Motion Baignoire'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
		domoticz.log('Device ' .. device.name .. ' was changed', domoticz.LOG_INFO)
		local targetedDevice = domoticz.devices('Eau Chaude')
		if ( device.bState )
        then
    		targetedDevice.cancelQueuedCommands()
            targetedDevice.switchOn().checkFirst()
            targetedDevice.switchOff().afterMin(domoticz.variables('showerMinDelay').value)
        end
	end
}