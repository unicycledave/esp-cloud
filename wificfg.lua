-- wificfg.lua --
-- function replace (...)
function unescape(s)
	s = string.gsub(s, "+", " ")
	s = string.gsub(s, "%%(%x%x)", function (h)
		return string.char(tonumber(h, 16))
		end)
	return s
end

function host_ap ()
	print("Entering wifi Setup..")

	wifi.setmode(wifi.STATIONAP)
	cfg={}
		cfg.ssid="GLOW_CLOUD"
		cfg.password="all-hail"
	wifi.ap.config(cfg)

	ipcfg={}
		ipcfg.ip="192.168.1.1"
		ipcfg.netmask="255.255.255.0"
		ipcfg.gateway="192.168.1.1"
	wifi.ap.setip(ipcfg)

	ap_list = ""

	function listap(t)
	  for bssid,v in pairs(t) do
	   local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
		ap_list = ap_list.."<option value='"..ssid.."'>"..ssid.."</option>"
	  end
	end
	wifi.sta.getap(1, listap)

	srv=net.createServer(net.TCP)
	srv:listen(80,function(conn)
		conn:on("receive", function(client,request)
			local buf = "";
			local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
			if(method == nil)then
				_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
			end
			local _GET = {}
			if (vars ~= nil)then
				for k, v in string.gmatch(vars, "(%w+)=([%w%^%$%(%)%[%]%.%%%*%+%?%-]+)&*") do
					_GET[k] = v
				end
			end

			if path == "/favicon.ico" then
				conn:send("HTTP/1.1 404 file not found")
				return
			end   

			if (path == "/" and  vars == nil) then
				buf = buf.."<html><body style='width:90%;margin-left:auto;margin-right:auto;background-color:#000000;'>";
				buf = buf.."<center><font color='#ff00ff'>"
				buf = buf.."Welcome to the Glow Cloud configuration.<br>"
				buf = buf.."Please enter your WiFi connection information below:<br>"
				buf = buf.."<form action='' method='get'>"
				buf = buf.."<input type='text' name='ssid' value='' maxlength='100' width='100px' placeholder='network name' /><br>"
				buf = buf.."<input type='text' name='password' value='' maxlength='100' width='100px' placeholder='password' /><br>"
				buf = buf.."<br><br>"
				buf = buf.."<p><input type='submit' value='ALL HAIL THE GLOW CLOUD!'</p>"
				buf = buf.."</body></html>"
		
			elseif (vars ~= nil) then
				restarting = "<html><body style='width:90%;margin-left:auto;margin-right:auto;background-color:#000000;'><font color='#ff00ff'><h1>Restarting...You may close this window.</h1></body></html>"
				client:send(restarting);
				client:close();
				print("vars are" .. vars)
				if(_GET.ssid)then
					if (_GET.ssid) then
						ssid = unescape(_GET.ssid)
						print(_GET.ssid)
					end
					if (_GET.password) then
						password = unescape(_GET.password)
					end
					
					file.open("ap_cfg", "w")
					file.writeline(ssid)
					file.writeline(password)
					file.close()

					print("Setting to: "..ssid..":"..password)
					tmr.alarm(0, 5000, 1, function()
						node.restart()
					end)
				end
			end

			client:send(buf);
			client:close();
			collectgarbage();
		end)
		
	end)
end

print("ap_cfg file not found, entering AP mode")
host_ap()
