import socketserver, socket, subprocess, time, errno, sys

host = 'localhost'
port = 2540
size = 1024

def Probe_Port(host, port):
    # AF_INET creates an IPV4 address family
    # SOCK_STREAM connections is TCP protocol
	try:
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	except socket.error as msg:
		print ("Failed to create socket. Error code: ", msg[0], " , Error message : ", msg[1])
		sys.exit();

	while True:
		try:
			s.connect(( host,port))
			break
		except OSError as e:
			print("There was a problem connecting to device, retrying")
	return s

def write_to_reg(conn,intValue):
# This will take an integer input and convert it to a binary string. It will also cut off the 0b at the beginning of the string.
    size = 8
    bStr_RegisterVal = bin(intValue).lstrip('0b').zfill(size) #Convert from int to binary string
    conn.send(bStr_RegisterVal.encode('utf-8') + b'\n') #Newline is required to flush the buffer on the Tcl server
    data = conn.recv(10)	# This will always need to have two additional bits added to the size of the string, this is for a start and stop bit.
    return data

###########################
########## Main ###########
###########################

#this will clear any previous port data
clear_serv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
clear_serv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)


subprocess.Popen('start /B start_TCL_Server.LNK', shell=True) #opens the TCL Server
time.sleep(1) #delays for 5 seconds

conn = Probe_Port(host, port)
time.sleep(1) #delays for 2 seconds

while True:
# This is a loop that will keep asking for first the address of the register that you want to write to.
# It will then ask for the value to write to the addressed register
	a =input("\nPlease enter a register address : ")
	if a == 'end':
		break
	a_int = int(a)
	write_to_reg(conn, a_int)
	b = input("\nPlease enter the integer value to be written to the register : ")
	if b == 'end':
		break
	b_int = int(b)
	write_to_reg(conn, b_int)

# Things to do.
		# Add in an extra input for the length of the data that you want to write.
		# This will require additional vhdl
		# also need to test the length of data that can be sent. From things read it seems that it is limited by tcl (32 bits)
		# look into making a tcl function file that can have python call the individual function:
			#Example;
				# This is a rather old thread, but I recently stumbled on Tkinter.Tcl() which gives you direct
				# access to a Tcl interpreter in python without having to spawn a Tk GUI as Tkinter.Tk() requires.

				# An example... suppose you have a Tcl file (foo.tcl) with a proc called main that requires an
				# single filename as an argument... main returns a string derived from reading foo.tcl.

						# from Tkinter import Tcl

						# MYFILE = 'bar.txt'
						# tcl = Tcl()
						# # Execute proc main from foo.tcl with MYFILE as the arg
						# tcl.eval('source foo.tcl')
						# tcl_str = tcl.eval('main %s' % MYFILE)
						# # Access the contents of a Tcl variable, $tclVar from python
						# tcl.eval('set tclVar foobarme')
						# tclVar = tcl.eval('return $tclVar')

				# I haven't found another way to access Tcl objects from python besides through a return value, but
				# this does give you a way to interface with Tcl procs. Furthermore, you can export python functions
				# into Tcl as discussed in Using Python functions in Tkinter.Tcl()
			# Also refer to this site https://wiki.python.org/moin/How%20Tkinter%20can%20exploit%20Tcl/Tk%20extensions


conn.close()








