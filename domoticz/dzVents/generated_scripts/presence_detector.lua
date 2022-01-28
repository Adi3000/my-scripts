return {
	on = {
		devices = {
			'Phone*'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
	    local phoneGroup = domoticz.groups("Phones")
	    local presenceDevice = domoticz.devices("Presence")
	    domoticz.log('State of group phone is '..phoneGroup.state, domoticz.LOG_INFO)
	    if (phoneGroup.state == 'Off') 
	    then
		    domoticz.log('All phones left, presence is off', domoticz.LOG_INFO)
		    domoticz.devices("Presence").switchOff()
		elseif (presenceDevice.state == "Off")
		then
    		local who = string.gsub(device.name, "Phone (%a)", "%1")
		    domoticz.log(who..' returns, presence is on', domoticz.LOG_INFO)
    	    domoticz.notify("Hello", "Hello "..who.." ! Content de te voir", domoticz.PRIORITY_NORMAL, nil, nil, domoticz.NSS_TELEGRAM)
		    presenceDevice.switchOn()
		end
	end
}