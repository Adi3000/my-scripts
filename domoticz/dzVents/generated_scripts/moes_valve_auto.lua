return {
	on = {
		devices = {
			'PiZiGate - Chambre 1 (Valve)',
			'PiZiGate - Chambre 2 (Valve)',
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
		data = {
        previousMode = { initial = { } }
    },
	execute = function(domoticz, device)
	    if domoticz.data.previousMode['idx'..device.id] == nil  then
	        if device.state == "Auto" then
	            domoticz.data.previousMode['idx'..device.id] = "Off"
	        else
	            domoticz.data.previousMode['idx'..device.id] = device.state
	        end
        end
		if device.state == "Auto" then
		    device.switchSelector(domoticz.data.previousMode['idx'..device.id]).checkFirst()
    	end
	end
}