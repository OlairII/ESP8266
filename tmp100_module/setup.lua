-- file: setup.lua
local module = {}

local function TMP100()
    i2c.setup(0, config.sda, config.scl, i2c.SLOW)
    i2c.start(0)
    i2c.address(0, config.dev_addr, i2c.TRANSMITTER)
    i2c.write(0, config.config_addr)
    i2c.write(0, config.resolution) --configura o config register para 12bits de resol
    i2c.stop(0)
    print("configurou")
end

function module.start()  
  print("entrou no setup start")  
  TMP100()
  print("meio")
  app.start()
  print("mandou app start")
end

return module  
