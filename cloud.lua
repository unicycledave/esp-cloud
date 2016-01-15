-- cloud.lua --

local pin = 4 -- GPIO2
local value = gpio.LOW

gpio.mode(pin, gpio.OUTPUT)

while 1 do
	for val = 0, 75, 1 do
		tmr.delay(100)
		ws2812.writergb(pin, string.char(val, 0, val*3))
	end
end
