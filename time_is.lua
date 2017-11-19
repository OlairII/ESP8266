-- connects to the web site "time.is" to retrieve the local time and date

year=0                  -- global year
month=0                 -- global month
day=0                   -- global day
dow=0                   -- global day of week
hour=0                  -- global hour
minute=0                -- global minute
second=0                -- global second

--connect to time.is to get the current time and date
function getTime()

   -- return the number corresponding to the three letter abbreviation of the month
   function nmonth(month) return (string.find("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",string.upper(month))+2)/3 end

   -- return the number corresponding to the three letter abbreviation of the day of week
   function ndow(dow) return (string.find("SUNMONTUEWEDTHUFRISAT",string.upper(dow))+2)/3 end

   local conn=net.createConnection(net.TCP,0)
   conn:connect(80,"time.is")
   
   conn:on("connection",
      function(conn, payload) 
         conn:send("HEAD / HTTP/1.1\r\n".. 
                   "Host: time.is\r\n"..
                   "Accept: */*\r\n"..
                   "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                   "\r\n\r\n") 
      end --function
   ) --end of on "connection" event handler
                
   conn:on("receive",
      function(conn,payload)
         --print(payload)
         conn:close()
         local p=string.find(payload,"Expires: ") -- find the time and date string in the payload from time.is
         if p~=nil then
            -- print(string.sub(payload,p,p+39))
            -- extract numbers corresponfing to the hour, minute, second, day, month
            -- and year from the payload received from time.is in response to our HEAD request
            -- p+0123456789012345678901234567890123456789
            --   Expires: Sat, 30 Jan 2016 06:15:11 -0500
            dow=ndow(string.sub(payload,p+9,p+11))
            hour=tonumber(string.sub(payload,p+26,p+27))
            minute=tonumber(string.sub(payload,p+29,p+30))
            second=tonumber(string.sub(payload,p+32,p+33))
            day=tonumber(string.sub(payload,p+14,p+15))
            month=nmonth(string.sub(payload,p+17,p+19))
            year=tonumber(string.sub(payload,p+21,p+24))
         else
            -- print("time.is update failed!")
         end
      end --function
   ) --end of on "receive" event handler
   
   conn:on("disconnection",
      function(conn,payload) 
         conn=nil
         payload=nil
      end --function
   )  -- end of on "disconnecttion" event handler
end    
-----------------------------------------------------------------------------
-- script execution starts here...
-----------------------------------------------------------------------------
print("\nContacting time.is...") 
getTime()           -- contact time.is for the current time and date
tmr.alarm(0,500,0,  -- after a half second...
   function()     
       if year ~= 0 then   
          print(string.format("%02d:%02d:%02d  %02d/%02d/%04d",hour,minute,second,month,day,year))
       else
          print("Unable to get time and date from the time.is.")       
       end
  
   end
)
