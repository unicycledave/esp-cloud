The goal of this project is to create a physical manifestation of 'cloud' in a tiny glass jar.
Inspired by the glow cloud from the podcast 'Welcome to Night Vale', when a button is pushed on the base of the jar, it will change the colour of all the other internet-connected jars, wherever they are, and the colour will remain 'set' for either 30 minutes or until another button is pushed, overriding the first colour. Each unit has its own colour, so you can know who is interacting with you.

This is the code repository for the ESP8266-01 module which will power the whole thing. 

There are several goals to this firmware:

a: be small; fit within the aviailable flash space of the esp-01 units that I have.
b: be reliable; predict failure conditions and allow for remote troubleshooting and graceful failure modes.
c: be easy to use; people who aren't me will have these units and probably don't want to spend the whole day fighting with them.

Next steps for implementation:
1. write a small web server which will host a simple utility to configure the esp on the target wifi network
2. write a sockets-enabled host and client which will actually handle the colours of each unit
3. ensure that failure modes of both things are gracefully handled; potentially display output / error codes when applicable.
