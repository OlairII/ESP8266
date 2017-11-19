-- Pin definition 
local pin = 7     --  GPIO13
local status = gpio.LOW
local duration = 2000    -- 1 second duration for timer




-- Initialising pin
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, status)

-- Create an interval
tmr.alarm(0, duration, 1, function ()
    if status == gpio.LOW then
        status = gpio.HIGH
    else
        status = gpio.LOW
    end

    gpio.write(pin, status)
end)

i2c.setup(0, sda, scl, i2c.SLOW)