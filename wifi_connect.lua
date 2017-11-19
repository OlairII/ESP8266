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
    st.sync("1.br.pool.ntp.org", function()
        tm = rtctime.epoch2cal(rtctime.get())
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    end)
  end
end


--nil

wifi.setmode(wifi.STATION)
wifi.sta.config("jrwifi","senha321")
print("iniciando")

tmr.alarm(1, 2500, 1, wifi_wait_ip)

--192.168.18.110
