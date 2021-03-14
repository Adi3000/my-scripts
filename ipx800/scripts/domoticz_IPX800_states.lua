function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end

function synchDevice(state, index, deviceName, domoticz)
    if( deviceName ~= 'null' )
    then
        local targetedDevice = domoticz.devices(deviceName)
        domoticz.log('Synch device '..deviceName..' to '..state.. ' (actual : '..targetedDevice.state..')', domoticz.LOG_INFO)
        if( state == '1' and targetedDevice.state ~= 'On' )
        then
		    domoticz.log('IPX800 ['..index..'] set to On ', domoticz.LOG_INFO)
            domoticz.devices(deviceName).switchOn().silent()
        elseif ( state == '0' and targetedDevice.state ~= 'Off' )
        then
		    domoticz.log('IPX800 ['..index..'] set to Off ', domoticz.LOG_INFO)
            domoticz.devices(deviceName).switchOff().silent()
        end
    end
end

return {
	on = {
		devices = {
			'IPX800 Log'
		}
	},
	execute = function(domoticz, device)
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
}
