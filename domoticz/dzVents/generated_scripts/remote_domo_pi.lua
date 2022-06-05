function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end


local callbackPrefix = "callback_"

return {
	on = {
		customEvents = {
			'remoteDomoPi'
		},
		timer = {
		   'every minute',
		},
		httpResponses = { 
		    callbackPrefix..'*' 
	    }
	},
	logging = {
		level = domoticz.INFO,
		marker = 'template',
	},
	execute = function(domoticz, event)
	    if event.isTimer then 
		    local deviceName = "RaspberryPI"
            domoticz.log('Health check on : '..deviceName, domoticz.LOG_INFO)
		    domoticz.devices(deviceName).switchOn().checkFirst()
		    domoticz.openURL({
		        url = "http://adi-home.adi3000.com:9966/_health",
		        method = 'GET',
		        callback = callbackPrefix.."_health::RaspberryPI"
	        })
	    elseif event.isCustomEvent then
		    local data = split(event.data,";")
		    domoticz.log("Will fetch "..data[1].." for "..data[2], domoticz.LOG_INFO)
		    domoticz.openURL({
		        url = "http://adi-home.adi3000.com:9966/"..data[1],
		        method = 'GET',
		        callback = callbackPrefix..data[1].."::"..data[2]
	        })
        elseif event.isHTTPResponse then
            local triggerInfo = event.trigger:sub(#callbackPrefix+1, #event.trigger)
            local trigger = split(triggerInfo,"::")
            domoticz.log("RemoteCallback from "..trigger[1].." on "..trigger[2] , domoticz.LOG_INFO)
            local device = domoticz.devices(trigger[2])
            if event.ok then
                domoticz.log("RemoteCallback to "..device.name.." finished successfully", domoticz.LOG_DEBUG)
            else
                domoticz.log("RemoteCallback failed to "..device.name.." with status "..event.statusCode, domoticz.LOG_ERROR)
    		    domoticz.emitEvent('fail_remoteDomoPi', trigger[1]..";"..trigger[2])
    		    domoticz.emitEvent('remoteDomoPi', trigger[1]..";"..trigger[2]).afterSec(60)
    	        domoticz.notify("remoteDomoPi", "Je n'ai pas reussi a envoyer la commande "..triggerInfo..". Il risque d'y avoir une desynchro" , domoticz.PRIORITY_NORMAL, nil, nil, domoticz.NSS_TELEGRAM)
    		    if event.statusCode ~= 404 then
    		        domoticz.log(event.data,  domoticz.LOG_ERROR)
                    domoticz.log(device.name.." trigger is retried. State of device is "..device.state, domoticz.LOG_INFO) 
                end
            end
		end
	end
}
