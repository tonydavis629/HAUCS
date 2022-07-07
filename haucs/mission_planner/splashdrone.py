import socket

def main():
    TCP_IP = '192.168.2.1' 
    TCP_PORT = 2022      
    BUFFER_SIZE = 1024

    start = '0xa6' #start flag for splash
    msgid = '0x01' #message ID
    src = '0x04' #ground control
    dest = '0x01' #flight control
    payload = 
    checksum =
    PackLength = 5 + len(payload) #5 bytes for start, msgid, src, dest, checksum
    
    MESSAGE = [start,PackLength,msgid,src,dest,payload,checksum]
    MESSAGE = ''.join(MESSAGE)
    print(MESSAGE)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((TCP_IP, TCP_PORT))
    s.send(MESSAGE)
    data = s.recv(BUFFER_SIZE)
    print(data)
    s.close()
    
if __name__ == '__main__':
    main()