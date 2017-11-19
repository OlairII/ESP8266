-- file: setup.lua
local module = {}



function time_sync()
    sntp.sync("a.st1.ntp.br")
    sec = rtctime.get()
    if sec ~= 0 then
        tmr.stop(1)
        tm = rtctime.epoch2cal(rtctime.get()-3600*2)
        print("Connection established at:")
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
        app.start()
    else
        print("No time aquired")
        tmr.alarm(1,5000, 1, time_sync)
    end
end

local function wifi_wait_ip()
    if wifi.sta.getip()== nil then
        print("IP unavailable, Waiting...")
    else
        tmr.stop(1)
        print("IP is "..wifi.sta.getip())
        time_sync()
        
    end
end

--------TMP 100 config
local function TMP100()
    i2c.setup(0, config.sda, config.scl, i2c.SLOW)
    i2c.start(0)
    i2c.address(0, config.dev_addr, i2c.TRANSMITTER)
    i2c.write(0, config.config_addr)
    i2c.write(0, config.resolution) --configura o config register para 12bits de resol
    i2c.stop(0)
end

function module.start()
	TMP100()
	print("Configuring Wifi ...")
    wifi.setmode(wifi.STATION);
	wifi.sta.config(config.station_cfg)
    tmr.alarm(1, 1000, 1, wifi_wait_ip)    
end

return module
