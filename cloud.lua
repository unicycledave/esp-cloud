-- cloud.lua --
-- called by init.lua. --
local led = 4 -- GPIO2
local button = 3 -- GPIO0
server = "192.168.0.104"
lastContact = 0

gpio.mode(led, gpio.OUTPUT)
gpio.mode(button, gpio.INT, gpio.PULLUP)

-- these are global values that can be set by the pulse function
r = "0"
g = "0"
b = "0"
sinpos = 1
sin = {0.034, 0.069, 0.104, 0.139, 0.173, 0.207, 0.241, 0.275, 0.309, 0.342, 0.374, 0.406, 0.438, 0.469, 0.5, 
0.529, 0.559, 0.587, 0.615, 0.642, 0.669, 0.694, 0.719, 0.743, 0.766, 0.788, 0.809, 0.829, 0.848, 0.866, 0.882, 0.898,
0.913, 0.927, 0.939, 0.951, 0.961, 0.970, 0.978, 0.984, 0.990, 0.994, 0.997, 0.999, 1.0, 0.999, 0.997, 0.994, 0.990, 
0.984, 0.978, 0.970, 0.961, 0.951, 0.939, 0.927, 0.913, 0.898, 0.882, 0.866, 0.848, 0.829, 0.809, 0.788, 0.766, 0.743,
0.719, 0.694, 0.669, 0.642, 0.615, 0.587, 0.559, 0.529, 0.5, 0.469, 0.438, 0.406, 0.374, 0.342, 0.309, 0.275, 0.241, 
0.207, 0.173, 0.139, 0.104, 0.069, 0.03}

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

function ledclr(red, green, blue)
	r = red
	g = green
	b = blue
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

-- this will do sine wave pulsing of the leds
tmr.alarm(5, 40, tmr.ALARM_AUTO, function()
	if r == nil then
		r = "0"
	end
	if g == nil then
		g = "0"
	end
	if b == nil then
		b = "0"
	end

	red = r * sin[sinpos]
	green = g * sin[sinpos]
	blue = b * sin[sinpos]

	ws2812.write(led, string.char(green, red, blue, green, red, blue, green, red, blue))	

	if sinpos == 87 then
		sinpos = 1
	else
		sinpos = sinpos + 1
	end
end)

connect()
