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
    bStr_LEDValue = bin(intValue).split('0b')[1].zfill(size) #Convert from int to binary string
    conn.send(bStr_LEDValue.encode('utf-8') + b'\n') #Newline is required to flush the buffer on the Tcl server
    data = conn.recv(10)
    return data
	
conn = Open(host, port)

while True:
	write_to_reg(conn, 1)
	a =input("Please enter a value for Register A : ")
	if a == 'end':
		break
	a_int = int(a)
	write_to_reg(conn, a_int)
	write_to_reg(conn, 2)
	b =input("Please enter a value for Register B : ")
	if b == 'end':
		break
	b_int = int(b)
	write_to_reg(conn, b_int)
	print('The result of the calculation is : ')
	write_to_reg(conn, 3)
	write_to_reg(conn, 4)

conn.close()