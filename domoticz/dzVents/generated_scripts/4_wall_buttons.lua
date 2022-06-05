return {
	on = {
		devices = {
			'PiZiGate - Bouton Couloir 1',
			'PiZiGate - Bouton Couloir 2',
            'PiZiGate - Bouton Couloir 3',
            'PiZiGate - Bouton Couloir 4'
		}
	},
	logging = {
		level = domoticz.DEBUG,
		marker = 'template',
	},
	execute = function(domoticz, device)
        local targetButton = device.name:sub(#device.name, #device.name)
        domoticz.log('Will perform 4 Wall button : '..targetButton, domoticz.LOG_INFO)
	    if targetButton == '1' then
	        if device.state == 'Click' then
		        domoticz.devices("PiZiGate - Prise PC").switchOn().checkFirst()
            elseif device.state == "Double Click" then
    		    domoticz.devices("WoL PC Salon").switchOn()
            elseif device.state == "Long Click"  then
    		    domoticz.scenes("Night").switchOn()
    		else
                domoticz.log('Cannot perform Wall button : '..targetButton..' : '..device.state, domoticz.LOG_INFO)
    	    end
	    elseif targetButton == '2' then
	        if device.state == 'Click' then
		        domoticz.devices("Salle à manger").toggleSwitch()
            elseif device.state == "Double Click" then
    		    domoticz.devices("PiZiGate - Prise Lave-Vaisselle").toggleSwitch()
            elseif device.state == "Long Click"  then
		        domoticz.devices("SafeSwitch - Chauffage").toggleSwitch()
    		else
                domoticz.log('Cannot perform Wall button : '..targetButton..' : '..device.state, domoticz.LOG_INFO)
    	    end
	    elseif targetButton == '3' then
	        if device.state == 'Click' then
		        domoticz.devices("PiZiGate - Lampadaire").toggleSwitch()
            elseif device.state == "Double Click" then
    		    domoticz.emitEvent('waterShower', "true")
            elseif device.state == "Long Click"  then
    		    domoticz.devices("En bas").toggleSwitch()
    		else
                domoticz.log('Cannot perform Wall button : '..targetButton..' : '..device.state, domoticz.LOG_INFO)
    	    end
	    elseif targetButton == '4' then
	        if device.state == 'Click' then
		        domoticz.devices("Salon").toggleSwitch()
            elseif device.state == "Double Click" then
    		    domoticz.devices("PiZiGate - Prise Cuisine").toggleSwitch()
            elseif device.state == "Long Click"  then
    		    domoticz.devices("PiZiGate - Prise Salon 1").toggleSwitch()
    		else
                domoticz.log('Cannot perform Wall button : '..targetButton..' : '..device.state, domoticz.LOG_INFO)
    	    end
        end

	end
}
