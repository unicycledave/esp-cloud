-- init.lua --

-- this file is taken from allaboutcircuits.com while I figure out how this works... --

-- Global Variables (Modify for your network)
--ssid = "Hacklab-Guests"
--pass = ""

-- Configure Wireless Internet
print('\nAll About Circuits init.lua\n')
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ',wifi.sta.getmac())
print('Chip ID: ',node.chipid())
print('Heap Size: ',node.heap(),'\n')
-- wifi config start
wifi.sta.config("Hacklab-Members","arduino1")
-- wifi config end

-- Run the main file
dofile("main.lua")
