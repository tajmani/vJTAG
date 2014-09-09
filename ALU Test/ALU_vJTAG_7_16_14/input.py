import socket
 
host = 'localhost'
port = 2540
size = 1024
 
def Open(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(( host,port))
    return s
 
def write_to_reg(conn,intValue):
    size = 8
    bStr_LEDValue = bin(intValue).lstrip('0b').zfill(size) #Convert from int to binary string
    conn.send(bStr_LEDValue.encode('utf-8') + b'\n') #Newline is required to flush the buffer on the Tcl server
    data = conn.recv(10)
    return data
	
conn = Open(host, port)

while True:
	a =input("Please enter a value for Register A : ")
	if a == 'end':
		break
	a_int = int(a)
	write_to_reg(conn, a_int)




conn.close()