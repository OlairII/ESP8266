local function time_sync()
    sntp.sync("a.st1.ntp.br")
    sec = rtctime.get()
    if sec ~= 0 then
        tmr.stop(1)
        tm = rtctime.epoch2cal(rtctime.get()-3600*2)
        print("Conexao obtida em:")
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
        
    else
        tmr.alarm(1,5000, 1, time_sync)
    end
end



function wifi_wait_ip()
    if wifi.sta.getip()== nil then
        print("IP unavailable, Waiting...")
    else
        tmr.stop(1)
        print("IP is "..wifi.sta.getip())
        time_sync()
        --tm = rtctime.epoch2cal(rtctime.get()-3600*2)
        --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    end
end

cfg = {}
cfg.ssid = "jrwifi"
cfg.pwd = "senha321"
cfg.auto = true

wifi.setmode(wifi.STATION)
wifi.sta.config(cfg)

tmr.alarm(1, 2500, 1, wifi_wait_ip)

--192.168.18.110
