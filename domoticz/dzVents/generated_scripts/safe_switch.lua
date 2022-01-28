return {
	on = {
		devices = {
			'SafeSwitch*'
		}
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
	    local prefix = "SafeSwitch - "
	    local targetName = device.name:sub(#prefix+1, #device.name)
	    local targetDevice = domoticz.devices(targetName)
	    if(device.state == "On")
	    then
	        targetDevice.switchOn().checkFirst()
	        domoticz.log('Device ' .. targetDevice.name .. ' is swichedOn', domoticz.LOG_INFO)
	    elseif(device.state == "Off")
	    then
	        targetDevice.switchOff().checkFirst()
	        domoticz.log('Device ' .. targetDevice.name .. ' is swichedOff', domoticz.LOG_INFO)
	    end
	end
}