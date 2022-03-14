return {
	on = {
		devices = {
			'PiZiGate - Sonette'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
		domoticz.log('Ringing ' .. device.name , domoticz.LOG_INFO)
		local ringGroup = domoticz.groups("Sonette")
        ringGroup.devices().forEach(function(switch)
            switch.switchOn().forSec(2).repeatAfterSec(2, 3)
        end)
	end
}