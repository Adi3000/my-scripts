return {
	on = {
		devices = {
			'Variable - *'
		}
	},
	execute = function(domoticz, device)
	    local prefix = "Variable - "
	    local variableName = device.name:sub(#prefix+1, #device.name)
		domoticz.log('Variable [' .. variableName .. '] will be from '..domoticz.variables(variableName).value..' to '.. device.sValue, domoticz.LOG_INFO)
		domoticz.variables(variableName).set(device.sValue)
	end
}