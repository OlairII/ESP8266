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
    getDayTime() -- contact the NIST daytime server for the current time and date
  end
end


--nil
wifi.setmode(wifi.STATION)
wifi.sta.config("jrwifi","senha321")

tmr.alarm(1, 2500, 1, wifi_wait_ip)

--192.168.18.110


-- connects to a NIST Daytime server to get the current date and time

TZ=-4       -- my time zone is Eastern Standard Time
year=0      -- global year
month=0     -- global month
day=0       -- global day
hour=0      -- global hour
minute=0    -- global minute
second=0    -- global second

function getDayTime()
   local tt=0
   
   local conn=net.createConnection(net.TCP,0) 
   conn:connect(13,"time.nist.gov")
   
   -- on connection event handler
   conn:on("connection", 
      function(conn, payload)
         --print("Connected...")
      end -- function
   ) -- end of on "connecttion" event handler
         
   -- on receive event handler         
   conn:on("receive",
      function(conn,payload) 
        --print(payload)
        --1234567890123456789012345678901234567890123456789 
        -- JJJJJ YR-MO-DA HH:MM:SS TT L H msADV UTC(NIST) *
        if string.sub(payload,39,47)=="UTC(NIST)" then
           year=tonumber(string.sub(payload,8,9))+2000
           month=tonumber(string.sub(payload,11,12))
           day=tonumber(string.sub(payload,14,15))
           hour=tonumber(string.sub(payload,17,18))
           minute=tonumber(string.sub(payload,20,21))
           second=tonumber(string.sub(payload,23,24))
           tt=tonumber(string.sub(payload,26,27))

           hour=hour+TZ    -- convert from UTC to local time
         
           if ((tt>1) and (tt<51)) or ((tt==51) and (hour>1)) or ((tt==1) and (hour<2)) then
              hour=hour+1  -- daylight savings time currently in effect, add one hour
           end
         
           hour=hour%24
        end -- if string.sub(payload,39,47)=="UTC(NIST)" then
      end -- function
   ) -- end of on "receive" event handler

   -- on disconnect event handler           
   conn:on("disconnection", 
      function(conn,payload) 
         --print("Disconnected...")
         conn=nil
         payload=nil
      end -- function
   )  -- end of on "disconnecttion" event handler
end -- function getDayTime()

-- Execution starts here...
print("\ncontacting NIST server...")
tmr.alarm(5,5000,1,        -- after a half second...
   function()
     getDayTime()
     if year~=0 then
        print(string.format("%02d:%02d:%02d  %02d/%02d/%04d",hour,minute,second,month,day,year))
     else
        print("Unable to get time and date from the NIST server.")
     end
   end
)
