function indexOf(array, value)
    for i, v in pairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

return {
	on = {
		customEvents = {
			'rotateSwitch'
		}
	},
    data = {
        previousState = { initial = { idx360 = 1 } }
    },
	execute = function(domoticz, event)
	    local device = domoticz.devices(event.data)
	    local states =  device.levelNames
	    local actualStateIdx = indexOf(states,device.sValue)
	    local nextStateIdx 
	    if actualStateIdx == #states  then 
	        nextStateIdx = 1 
	    else 
	        nextStateIdx = actualStateIdx + 1 
	    end
		domoticz.log('Device '.. device.name ..'['..device.id..'] = '..actualStateIdx..'['..device.sValue ..'] => ' ..nextStateIdx..'['..states[nextStateIdx]..'] ', domoticz.LOG_INFO)
		device.switchSelector(states[nextStateIdx])
		domoticz.data.previousState['idx'..device.id] = nextStateIdx
	end
}