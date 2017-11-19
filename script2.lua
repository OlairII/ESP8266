function cons(t)
    print("conectou")
end


station_cfg = {} 
station_cfg.ssid = "jrwifi"
station_cfg.pwd = "senhasdfg1"
station_cfg.auto = true
station_cfg.save = true

print("Configuring Wifi ...")
wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, cons(t))
wifi.setmode(wifi.STATION);
wifi.sta.config(station_cfg) 
