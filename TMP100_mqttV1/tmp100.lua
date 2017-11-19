
local module

id=0
scl=2  --d2
sda=1  --d1
dev_addr=0x48
config_addr=0x01 --config register
temp_addr=0x00 --temp register

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


tmr.alarm( 0, 1000, tmr.ALARM_AUTO, read_temp)