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

# defines:
maxclouds = 10
port = 8450
host = socket.gethostname()
maxconns = maxclouds
debug = True

def update_sql(unit_number, ip, color, last_contact):
	connargs = {
		'user': 'root',
		'password': 'toor',
		'host': '127.0.0.1',
		'database': 'glow_cloud'
	}

	cnx = mysql.connector.connect(**connargs)
	cursor = cnx.cursor()

	update_msg = ("UPDATE clouds SET ip='" + ip + "', color='" + color + "', last_contact='" + str(last_contact) + "' WHERE id='" + str(unit_number) + "'")

	print update_msg
	
	cursor.execute(update_msg)
	cnx.commit()	
	cnx.close()

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

serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

serversocket.bind((host, port))
serversocket.listen(maxconns)

while 1:
	# wait for connections:
	conn, addr = serversocket.accept()
	pl = conn.recv(128)
	if debug == True:
		print pl

	# validate sent data:
	pl = pl.split("/")
	
	if int(pl[0]) < maxclouds:
		unit_number = pl[0]
		
		if re.match('([0-9]{1,3}\.){3}[0-9]{1,3}', pl[1]):
			ip = pl[1]

			if re.match('^([0-9]{1,3},){2}[0-9]{1,3}$', pl[2]):
				color = pl[2]

				# if we're in here, we've validated the data. update the mysql table:
				update_time = int(time.time())

				from_sql = update_sql(unit_number, ip, color, update_time)

			else:
				write_log("Malformed color value sent.", 2)
				if debug:
					print pl[2]

		else:
			write_log("Malformed ip address value sent.", 2)
			if debug:
				print pl[1]

	else:
		write_log("Incorrect unit_number sent.", 2)
		if debug:
			print pl[0]
	
	# check what the color string should be:
	
	current_color = "255,25,0"

	conn.send(current_color)

