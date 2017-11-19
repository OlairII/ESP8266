-- file : application.lua
local module = {}  

-- Reads and Sends temp data to the broker
local function RaS_temp()
    i2c.start(0)
    i2c.address(0, config.dev_addr, i2c.TRANSMITTER)
    i2c.write(0, config.temp_addr)
    i2c.start(0)
    i2c.address(0, config.dev_addr, i2c.RECEIVER)
    local temp = i2c.read(0, 2)
    i2c.stop(0)
    --faz a converção do dado
    local nbl = (string.byte(temp,2))/16
    local bh = (string.byte(temp,1))*16
    local conc = bh+nbl
    local temperatura = 0.0625*conc
    print(temperatura)
end

function module.start()  
	tmr.alarm( 0, 1000, tmr.ALARM_AUTO, RaS_temp)
end

return module  
