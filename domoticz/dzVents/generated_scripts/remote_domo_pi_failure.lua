return {
	on = {
		customEvents = {
			'fail_remoteDomoPi'
		}
	},
	logging = {
		level = domoticz.INFO,
		marker = 'template',
	},
	execute = function(domoticz, event)
	    domoticz.log("Receiving data : "..event.data, domoticz.LOG_INFO)
	    if event.data == "_health;RaspberryPI" then
		    domoticz.log("Stopping server because receiving "..event.data, domoticz.LOG_INFO)
	        domoticz.devices("Domoticz Stop").switchOff()
        end
	end
}