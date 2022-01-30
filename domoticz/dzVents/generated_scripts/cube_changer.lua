math.randomseed(os.time())
math.random(); math.random(); math.random()

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function changeBrightness(domoticz, deviceName, brightness)
    local targetedDevice = domoticz.devices(deviceName)
    local hue, saturation, oldBrightness, isWhite = domoticz.utils.rgbToHSB(targetedDevice.getColor().r, targetedDevice.getColor().g, targetedDevice.getColor().b)
    targetedDevice.setColor(targetedDevice.getColor().r, targetedDevice.getColor().g, targetedDevice.getColor().b, brightness)
end

function addWW(domoticz, deviceName, addWWvalue)
    local targetedDevice = domoticz.devices(deviceName)
    local newWW = math.abs((math.floor(targetedDevice.getColor().ww) + addWWvalue) % 255)
    targetedDevice.setColor(255, 255, 255, nil, nil, wwValue)
end

function changeColor(domoticz, deviceName, hue)
    local targetedDevice = domoticz.devices(deviceName)
    local oldHue, saturation, value, isWhite = domoticz.utils.rgbToHSB(targetedDevice.getColor().r, targetedDevice.getColor().g, targetedDevice.getColor().b)
    targetedDevice.setHue(hue, value)
end

function addColor(domoticz, deviceName, addHue)
    local targetedDevice = domoticz.devices(deviceName)
    local oldHue, saturation, value, isWhite = domoticz.utils.rgbToHSB(targetedDevice.getColor().r, targetedDevice.getColor().g, targetedDevice.getColor().b)
    local newHue = math.abs((math.floor(oldHue) + addHue) % 360)
    if newHue + oldHue > newHue - oldHue  then
        targetedDevice.setHue(newHue, value)
    else
        addWW(domoticz, targetedDevice.name, 0)
    end
end

return {
	on = {
		devices = {
			'PiZiGate - Cube Chambre 1','PiZiGate - Cube Chambre 2'
		}
	},
	logging = {
		level = domoticz.DEBUG,
		marker = 'template',
	},
	execute = function(domoticz, device)
	    local cubeIndex = string.sub(device.name,-1)
	    local targetedDevice = domoticz.devices('PiZiGate - Chambre '..cubeIndex)
	    domoticz.log('Light '..cubeIndex..' device : '..targetedDevice.name, domoticz.LOG_INFO)
        if targetedDevice.getColor() ~= nil then
            if device.sValue == 'Flip_180'  then
                if targetedDevice.getColor().br ~= nil and targetedDevice.getColor().br > 0 then
		            -- changeBrightness(domoticz, targetedDevice.name, 0)
                    targetedDevice.switchOff()
		        else
		            targetedDevice.switchOn()
		            -- changeBrightness(domoticz, targetedDevice.name, 100)
		        end
	        elseif device.sValue == 'Flip_90' and targetedDevice.state == "Off"  then
                changeBrightness(domoticz, targetedDevice.name, 10)
                targetedDevice.switchOn()
	        elseif targetedDevice.state == "On" then 
	            if device.sValue == 'Flip_90' then
    		        changeBrightness(domoticz, targetedDevice.name, 10)
                elseif  device.sValue == 'Shake' then
                    domoticz.log('Light '..cubeIndex..' should random color')
                    changeColor(domoticz, targetedDevice.name, randomFloat(0,360))                
                elseif  device.sValue == 'Clock_Wise' then
                    domoticz.log('Light '..cubeIndex..' should add light, actual : '..targetedDevice.sValue)
                    addColor(domoticz, targetedDevice.name, 20)                
                elseif  device.sValue == 'Anti_Clock_Wise' then
                    domoticz.log('Light '..cubeIndex..' should back light, actual : '..targetedDevice.sValue)
                    addColor(domoticz, targetedDevice.name, -20)                
                elseif device.sValue == 'Move' then
                    domoticz.log('Light '..cubeIndex..' should be full bright : '..targetedDevice.sValue)    
                    if targetedDevice.getColor().br ~= nil or targetedDevice.getColor().br ~= 0 then
                       addWW(domoticz, targetedDevice.name, 50)
                    end
                end
            end
        end
	end
}