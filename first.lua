-- init.lua --

-- add a delay so that it's possible to reset the nodemcu if things go south.
tmr.delay(6000000)

if file.open("ap_cfg", "r") then
	-- connect to wifi from file:
	ssid = string.gsub(file.readline(), "\n", "")
	pass = string.gsub(file.readline(), "\n", "")	

	print(ssid..' '..pass)

	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid, pass)
	wifi.sta.connect()

	local cnt = 0
	tmr.alarm(3, 1000, 1, function()
		if (wifi.sta.getip() == nil) and (cnt < 20) then
			print("attempting to connect to wifi..")
			cnt = cnt + 1
		else 
			tmr.stop(3)

			if (cnt < 20) then
				print ("connected, IP is "..wifi.sta.getip())
				dofile ("cloud.lua")
			else
				print("connection failed - removing ap_cfg.")
				file.remove("ap_cfg")
				node.restart()
			end

		cnt = nil
		ssid = nil
		pass = nil
		collectgarbage();
		end
	end)
else
	dofile("wificfg.lua")
end
