local module = {}

module.SSID = {}  
module.SSID["jrwifi"] = "senha321"

module.HOST = "broker.hivemq.com"  
module.PORT = 1883  
module.ID = node.chipid()

module.scl = 2  --Pino d2
module.sda = 1  --Pino d1
module.dev_addr = 0x48
module.config_addr = 0x01 --config register
module.temp_addr = 0x00 --temp register
module.resolution = 0x60 --resolucao 12bits

module.ENDPOINT = "JRNodemcu/"  
return module
