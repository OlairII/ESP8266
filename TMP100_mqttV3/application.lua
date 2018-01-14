-- file : application.lua
local module = {}  
m = nil

local function RS_int()

    tmr.alarm(4, 100, tmr.ALARM_SINGLE, function()
        if gpio.read(3) == 0 then
            print("abriu")
            tm = rtctime.epoch2cal(rtctime.get()-3600*2)
            str_tm = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
            m:publish(config.ENDPOINT .. "DoorStatus", "The door has CLOSEed at:\n "..str_tm, 0, 0 )
        else
            print("fechou")
            tm = rtctime.epoch2cal(rtctime.get()-3600*2)
            str_tm = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
            m:publish(config.ENDPOINT .. "DoorStatus", "The door has OPENed at:\n "..str_tm, 0, 0 )
        end
    end)
end


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
    tm = rtctime.epoch2cal(rtctime.get()-3600*2)
    str_tm = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
    print(str_tm)     
    m:publish(config.ENDPOINT .. "temperature", "Data acquired at: "..str_tm.."\nTemperature: "..temperatura, 0, 0 )
    --m:publish(config.ENDPOINT .. "temperature", temperatura, 0, 0)
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
    gpio.trig(3, "both", RS_int)
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
