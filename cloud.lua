-- cloud.lua --
-- called by init.lua. --
local led = 4 -- GPIO2
local button = 3 -- GPIO0
server = "192.168.111.152"
lastContact = 0

gpio.mode(led, gpio.OUTPUT)
gpio.mode(button, gpio.INT, gpio.PULLUP)

function debounce(func)
	local last = 0
	local delay = 200000

	return function(...)
		local now = tmr.now()
		if now - last < delay then return end

		last = now
		return func(...)
	end
end

function onChange()
	if gpio.read(button) == 0 then
		sock:send(node.chipid()..":BUTTON")
	end
end

sock = net.createConnection(net.TCP, 0)

sock:on("connection", function(sck)
	sck:send(node.chipid()..":"..wifi.sta.getip())
	lastContact = 0
end)

sock:on("receive", function(sck, c)
	node.input(c .. "\n")
	lastContact = 0
	sock:send(node.chipid())
	print(c)
end)

function connect()
	sock:connect(8450,server)
end

function ledclr(r, g, b)
	ws2812.write(led, string.char(g, r, b, g, r, b, g, r, b))
end

gpio.trig(button, "down", debounce(onChange))

tmr.alarm(6, 1000, tmr.ALARM_AUTO, function()
	if lastContact > 60 then
		sock:close()
		connect()
	else
		lastContact = lastContact + 1
	end
end)

connect()
