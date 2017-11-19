function espera_IP()
    if wifi.sta.getip()== nil then
        print("sem ip...")
    else
        print("\n====================================")
        tmr.stop(0)
        print("IP: " ..wifi.sta.getip)
        print("====================================")
    end
end

wifi.setmode(wifi.STATION)
wifi.sta.config("jrwifi","senha321")
tmr.alarm(0, 1000, tmr.ALARM_AUTO, espera_IP)


