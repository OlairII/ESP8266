-- file : application.lua
local module = {}  
m = nil

-- Sends a simple ping to the broker
local function send_ping()
	print("Sending data")
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
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
    tmr.alarm(6, 4000, tmr.ALARM_AUTO, send_ping)
    tmr.alarm(5, 1000, tmr.ALARM_AUTO, RaS_temp)
end 

local function handle_mqtt_error(client, reason)
    print("FAIL!")
    tmr.alarm(2, 10*1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

local function do_mqtt_connect()
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 0, con_success(con), handle_mqtt_error)
end

function module.start()  
	m = mqtt.Client(config.ID, 120)
    print("Client created")
    do_mqtt_connect()
end

return module  
