return {
	on = {
		devices = {
			'PiZiGate - Bouton Couloir'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
		if device.state == "Double Click" then
		    domoticz.devices("PiZiGate - Prise PC").switchOn().checkFirst()
        elseif  device.state == "Click"  then
		    domoticz.devices("SafeSwitch - Chauffage").toggleSwitch()
        elseif device.state == "Long Click"  then
		    domoticz.scenes("Night").switchOn()
	    end
	end
}