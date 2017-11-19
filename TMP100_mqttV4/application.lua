-- file : application.lua
local module = {}  
m = nil

---
TZ=-2       -- my time zone is Eastern Standard Time
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

--------

-- Sends a simple ping to the broker
local function send_ping()
	print("Sending data")
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID, 0, 0)
end

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
    getDayTime()
    horario = string.format("%02d:%02d:%02d  %02d/%02d/%04d",hour,minute,second,month,day,year)
    m:publish(config.ENDPOINT .. "temperature", horario, 0, 0 )
	m:publish(config.ENDPOINT .. "temperature", temperatura, 0, 0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function con_success (con)
    print("Connected to the broker!") 
    --register_myself()
    -- And then pings each 4000 milliseconds
    tmr.alarm(6, 5000, tmr.ALARM_AUTO, send_ping)
	tmr.alarm(5, 2000, tmr.ALARM_AUTO, RaS_temp)
end 

function handle_mqtt_error(client, reason)
    print("FAIL!")
    tmr.alarm(3, 1000, tmr.ALARM_SEMI, do_mqtt_connect)
end


function do_mqtt_connect()
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 0, con_success(m), handle_mqtt_error)
end


function module.start()  
	m = mqtt.Client(config.ID, 120)
    m:on("offline", handle_mqtt_error)
    print("Client created")
    do_mqtt_connect()
    --m:on("offline", handle_mqtt_error)
end



return module  
