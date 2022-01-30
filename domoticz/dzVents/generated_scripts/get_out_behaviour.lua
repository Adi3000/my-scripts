return {
	on = {
		devices = {
			'Presence'
		}
	},
	data = {
        out_status = { initial = 'there' }
    },
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'template',
	},
	execute = function(domoticz, device)
	    local nightScene = domoticz.scenes("Night")
	    domoticz.log('Device ' .. device.name .. ' was changed to '..device.state, domoticz.LOG_INFO)
	    if device.state == "Off" then
	        domoticz.notify("Out", "Je vais tout etendre dans 60 secondes ", domoticz.PRIORITY_NORMAL, nil, nil, domoticz.NSS_TELEGRAM)
    	    domoticz.data.out_status = 'out'
            nightScene.switchOn().afterSec(60) 
	    elseif domoticz.data.out_status == 'out'  then
	        domoticz.notify("Out", "J'annule l'extinction des feux ", domoticz.PRIORITY_NORMAL, nil, nil, domoticz.NSS_TELEGRAM)
	        domoticz.data.out_status = 'canceled'
            nightScene.cancelQueuedCommands()
		end
	end
}