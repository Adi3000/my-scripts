function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end

function synchDevice(state, index, deviceName, domoticz)
    if deviceName ~= 'null' then
        local targetedDevice = domoticz.devices(deviceName)
        domoticz.log('Synch device '..deviceName..' to '..state.. ' (actual : '..targetedDevice.state..')', domoticz.LOG_INFO)
        if state == '1' and targetedDevice.state ~= 'On'  then
		    domoticz.log('IPX800 ['..index..'] - '..deviceName..' set to On', domoticz.LOG_INFO)
            domoticz.devices(deviceName).switchOn()
        elseif state == '0' and targetedDevice.state ~= 'Off' then
		    domoticz.log('IPX800 ['..index..'] - '..deviceName..' set to Off', domoticz.LOG_INFO)
            domoticz.devices(deviceName).switchOff()
        end
    end
end

return {
	on = {
		devices = {
			'IPX800 Log'
		},
		customEvents = {
			'ipx800Delayed'
		}
	},
	logging = {
		level = domoticz.DEBUG,
		marker = 'template',
	},
	execute = function(domoticz, event)
	    if event.isDevice then
            domoticz.emitEvent('ipx800Delayed', 'IPX800 Log' ).afterSec(1)
        elseif event.isCustomEvent then
            local device = domoticz.devices(event.data)
    		domoticz.log('IPX800 ' .. device.name .. ' status changed to ' .. device.sValue, domoticz.LOG_INFO)
    		local s = split(device.sValue, ';')
    		local outputs = s[1]
    		local inputs = s[2]
    		local outputsMap = split(domoticz.variables('ipx800Outputs').value, ',')
    		local inputsMap = split(domoticz.variables('ipx800Inputs').value, ',')
    		
            for output, deviceName in pairs(outputsMap) do
                synchDevice(outputs:sub(output,output),output, deviceName, domoticz)
            end
            for input, deviceName in pairs(inputsMap) do
    		    synchDevice(inputs:sub(input,input),input, deviceName, domoticz)
            end
        end
	end
}