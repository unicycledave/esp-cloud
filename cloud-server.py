#!/usr/bin/python
#
# This is a basic socket server to test the functionality of the glow cloud prototype.
# Ideally a bunch of clouds can connect to this sucker and it'll send them messages
# where appropriate.
#
# dave.davecox@gmail.com January 2016
#
# January 2016 - V0.1

import socket
import mysql.connector
import re
import time
import thread
import select

# defines:
maxclouds = 10
port = 8450
host = "192.168.111.152"
bufsize = 128
maxconns = maxclouds
debug = True

def update_sql(chipid, ip):
	connargs = {
		'user': 'root',
		'password': 'toor',
		'host': '127.0.0.1',
		'database': 'glow_cloud'
	}

	cnx = mysql.connector.connect(**connargs)
	cursor = cnx.cursor()
	
	chipids = ("SELECT * FROM clouds WHERE id='" + str(chipid) + "'") 
	cursor.execute(chipids)

	found = 0
	for iterable in cursor:
		for item in iterable:
			if str(item) == str(chipid):
				if debug:
					print "ID MATCHES!: " + chipid
				found = 1

	if found == 0:
		update = ("INSERT INTO clouds (id, ip, color, default_color, last_contact) VALUES ('" + str(chipid) + "', '" + str(ip) + "', '255,255,255', '255,255,255',  '" + str(int(time.time())) + "')")
		cursor.execute(update)
		cnx.commit()

	cnx.close()

	retval = True
	return retval

def write_log(string, error_level):
	if error_level == 0:
		error_string = "[INFO]: "
	elif error_level == 1:
		error_string = "[WARN]: "
	elif error_level == 2:
		error_string = "[ERROR]: "
	else:
		print "ERRONEOUS ERROR LEVEL"
		return 1

	print error_string + string
	return 0	

def set_all_colors(color):
	connargs = {
		'user': 'root',
		'password': 'toor',
		'host': '127.0.0.1',
		'database': 'glow_cloud'
	}

	cnx = mysql.connector.connect(**connargs)
	cursor = cnx.cursor()

	update_colors = ("UPDATE clouds SET color='" + color + "'")
	cursor.execute(update_colors)

	# error checking here..
	cnx.commit()
	cnx.close()

	return 1

def reset_all_colors():
	pass

def get_color_by_id(chipid):
	connargs = {
		'user': 'root',
		'password': 'toor',
		'host': '127.0.0.1',
		'database': 'glow_cloud'
	}

	cnx = mysql.connector.connect(**connargs)
	cursor = cnx.cursor()

	get_color = ("SELECT color FROM clouds WHERE id='" + chipid + "'")
	cursor.execute(get_color)
	
	for color in cursor:
		for value in color:
			retval = value 

	cnx.close()

	return retval
	
def handler(conn, addr):
	conn.setblocking(0)
	x = 0 
	color_delay = 0
	while 1:
		if x >= 30:
			# conn.send("ledclr(" + from_sql[1] + ")")
			conn.send("node.chipid()")
			x = 0
		
		x += 1
		time.sleep(0.5)


		try:
			data = conn.recv(bufsize)
			print data

			if data.endswith("BUTTON"):
				newcolor = get_color_by_id(data.split(":")[0])		
				print newcolor
				set_all_colors(newcolor)
				conn.send("ledclr(" + newcolor + ")")
			elif len(data) == 7:
				update_sql(data, addr[0])


		except socket.error:
			pass

		# if data == update, store info in table
		# if data == button, do a set_all_colors. +1 to button push counter as well
		# if current_time = 2am, do a reset!
			
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.bind((host, port))
serversocket.listen(maxclouds)

while 1:
	write_log("Server OK, waiting for connections on " + str(port) + ".", 0)
	conn, addr = serversocket.accept()
	
	write_log("New client connected from: " + str(addr), 0)
	thread.start_new_thread(handler, (conn, addr))

# alright, so, final things required to make this shit work:
# > SSL or encryption on messages between client and server.
#	> will need to compile this into the nodemcu image.
# > need to detect button sends correctly
# > need to send updates correctly
# > need to add node id as a column (instead of IP?) in table
# > also need to keep track of # of button presses per cloud.
# > nightly reboots when it's 2am or other arbitrary time (set by sql query?)
