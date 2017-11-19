--mod 15:07
--mod 15:08
--mod 15:19
--mod 15:45 amend
--mod 15:50

function wifi_wait_ip()  
    if wifi.sta.getip()== nil then
        print("IP unavailable, Waiting...")
    else
        tmr.stop(1)
        print("\n====================================")
        print("ESP8266 mode is: " .. wifi.getmode())
        print("MAC address is: " .. wifi.ap.getmac())
        print("IP is "..wifi.sta.getip())
        print("====================================")
    end
end


--nil
wifi.setmode(wifi.STATION)
wifi.sta.config("jrwifi","senha321")
tmr.alarm(1, 2500, 1, wifi_wait_ip)




--192.168.18.110
