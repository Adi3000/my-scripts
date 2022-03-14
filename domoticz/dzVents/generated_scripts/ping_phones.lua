function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


return {
	on = {
		timer = {
			'every minutes'
		},
		customEvents = {
			'manualPingPhone'
		},
		httpResponses = { 
		   'ping_phone_callback'
	    }
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, event)
	    if event.isTimer or event.isCustomEvent then
    	    domoticz.openURL({
    	        url = "http://adi-home.adi3000.com:9966/ping/phones",
    	        method = 'GET',
    	        callback = "ping_phone_callback"
            })
--	        domoticz.emitEvent("manualPingPhone", "true" ).afterSec(20)
--	        domoticz.emitEvent("manualPingPhone", "true" ).afterSec(40)
        elseif event.isHTTPResponse then
            for i, phoneInfo in ipairs(event.json) do 
                local phone = domoticz.devices(phoneInfo.name)
                if phone.bState ~= phoneInfo.status then
                    domoticz.log("Will change status of "..phone.name .." to ".. tostring(phoneInfo.status) , domoticz.LOG_INFO)
                    if phoneInfo.status then
                        phone.switchOn()
                    else
                        phone.switchOff()
                    end
                end
            end
        end
        
	end
}
