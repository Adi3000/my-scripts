return {
	on = {
		devices = {
			'PiZiGate - Bouton Salon',
			'PiZiGate - Bouton Porte fenêtre'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
        domoticz.log('Wall button pressed '..device.name..' : '..device.state, domoticz.LOG_INFO)
        if device.name == 'PiZiGate - Bouton Salon' then
            if device.state == "Click"  then
    		    domoticz.devices("Salon").toggleSwitch()
            elseif device.state == "Double Click" then
    		    domoticz.devices("PiZiGate - Prise Hifi").switchOn().checkFirst()
            elseif device.state == "Long Click"  then
    		    domoticz.scenes("PiZiGate - Prise Canape").toggleSwitch()
    		else
                domoticz.log('Cannot perform Wall button : '..device.name..' : '..device.state, domoticz.LOG_INFO)
    	    end
        elseif device.name == 'PiZiGate - Bouton Porte fenêtre' then
            if device.state == "Click" then
    		    domoticz.devices("Jardin").toggleSwitch()
            elseif device.state == "Double Click" then
                if  domoticz.devices("Cuisine").state == "On" then
        		    domoticz.devices("Salon").switchOff()
        		    domoticz.groups("Cuisine").switchOff()
        		else
        		    domoticz.devices("Salon").switchOn()
        		    domoticz.groups("Cuisine").switchOn() 
                end
            elseif device.state == "Long Click"  then
    		    domoticz.scenes("Night").switchOn()
    		else
                domoticz.log('Cannot perform Wall button : '..device.name..' : '..device.state, domoticz.LOG_INFO)
    	    end
		else
            domoticz.log('Cannot find Wall button : '..device.name..' : '..device.state, domoticz.LOG_INFO)
	    end
	end
}