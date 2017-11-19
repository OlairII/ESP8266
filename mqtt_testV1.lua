
--mqtt var
mqtt.host = "broker.hivemq.com"
mqtt.port = 1883
mqtt.wport = 8000

--i2c var
id=0
scl=2  --d2
sda=1  --d1
dev_addr=0x48
config_addr=0x01 --config register
temp_addr=0x00 --temp register
DADO_temp = 0

--configura o tmp100
i2c.setup(id, sda, scl, i2c.SLOW)
i2c.start(id)
i2c.address(id, dev_addr, i2c.TRANSMITTER)
i2c.write(id, config_addr)
i2c.write(id, 0x60) --configura o config register para 12bits de resol
i2c.stop(id)

--le os dados de temperatura
function read_temp()
i2c.start(id)
i2c.address(id, dev_addr, i2c.TRANSMITTER)
i2c.write(id, temp_addr)
i2c.start(id)
i2c.address(id, dev_addr, i2c.RECEIVER)
temp=i2c.read(id, 2)
i2c.stop(id)
--faz a converção do dado
nbl=(string.byte(temp,2))/16
bh=(string.byte(temp,1))*16
conc=bh+nbl
temperatura=0.0625*conc
print(temperatura)
end

--timer para ler o dados de temperatura
tmr.alarm( 0, 1000, tmr.ALARM_AUTO, read_temp)


--conexao wifi
wifi.setmode(wifi.STATION)
wifi.sta.config("Tenda","26697800")
--timer para conectar e mostrar o IP
tmr.alarm(1, 2000, tmr.ALARM_AUTO, wifi_wait_ip)

function wifi_wait_ip()
	if wifi.sta.getip() == nil then
		print("IP nao disponivel ...")
	else
		tmr.stop(1)
		print("\n============================")
		print("IP:"..wifi.sta.getip())
end



function register_myself()  
    m:subscribe(DADO_temp, 2, function(conn)
        print("Successfully subscribed to data endpoint")
		mqttCon
    end)
end


function mqttCon()
	m = mqtt.Client("olair"..node.chipid(), 120)
	--conecta ao broker
	m:connect(mqtt.host, mqtt.port, 0, 0, function(con)
		register_myself()
		--manda ping a cada 1s
		tmr.stop(6)
		tmr.alarm(6, 1000, 1, send_ping)
	end)
end

function register_myself()
	m:subscribe("JRnodeMCU/", 0, function(conn)
		print("Inscicao feita")
	end)
end

function send_ping()
	m:publish("JRnodeMCU/ping", 0, 0)
end
	


--[[config mqtt
print(mqtt.Client("olair.teste", 10))
mqtt:connect(mqtt.host, mqtt.port, 0, 0,function(con) 
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end) 
--envia dado mqtt
mqtt:publish(tmp100_data, DADO_temp, 2,true)]]


