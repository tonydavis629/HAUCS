import socket
import struct
# import numpy as np

start = 0xa6 #start flag for splash
TCP_IP = '192.168.2.1' 
TCP_PORT = 2022      
BUFFER_SIZE = 64

#message checksum computed by table lookup
CRC8_Table =[
  0, 94, 188, 226, 97, 63, 221, 131, 194, 156, 126, 32, 163, 253, 31, 65,
  157, 195, 33, 127, 252, 162, 64, 30, 95, 1, 227, 189, 62, 96, 130, 220,
  35, 125, 159, 193, 66, 28, 254, 160, 225, 191, 93, 3, 128, 222, 60, 98,
  190, 224, 2, 92, 223, 129, 99, 61, 124, 34, 192, 158, 29, 67, 161, 255,
  70, 24, 250, 164, 39, 121, 155, 197, 132, 218, 56, 102, 229, 187, 89, 7,
  219, 133, 103, 57, 186, 228, 6, 88, 25, 71, 165, 251, 120, 38, 196, 154,
  101, 59, 217, 135, 4, 90, 184, 230, 167, 249, 27, 69, 198, 152, 122, 36,
  248, 166, 68, 26, 153, 199, 37, 123, 58, 100, 134, 216, 91, 5, 231, 185,
  140, 210, 48, 110, 237, 179, 81, 15, 78, 16, 242, 172, 47, 113, 147, 205,
  17, 79, 173, 243, 112, 46, 204, 146, 211, 141, 111, 49, 178, 236, 14, 80,
  175, 241, 19, 77, 206, 144, 114, 44, 109, 51, 209, 143, 12, 82, 176, 238,
  50, 108, 142, 208, 83, 13, 239, 177, 240, 174, 76, 18, 145, 207, 45, 115,
  202, 148, 118, 40, 171, 245, 23, 73, 8, 86, 180, 234, 105, 55, 213, 139,
  87, 9, 235, 181, 54, 104, 138, 212, 149, 203, 41, 119, 244, 170, 72, 22,
  233, 183, 85, 11, 136, 214, 52, 106, 43, 117, 151, 201, 74, 20, 246, 168,
  116, 42, 200, 150, 21, 75, 169, 247, 182, 232, 10, 84, 215, 137, 107, 53 
]

#opcodes for message payload
opcodes = {'FC_TASK_OC_TRAN_STR': 0x01, 'FC_TASK_OC_ADD':0x03, 'FC_TASK_OC_READ':0x04,
           'FC_TASK_OC_START':0x05, 'FC_TASK_OC_STOP':0x06, 'FC_TASK_OC_ERROR':0xfb,
           'FC_TASK_OC_ACK':0xfc, 'FC_TASK_OC_ACTION':0xfd, 'FC_TASK_OC_CLEAR':0xfe,
           'FC_TASK_OC_TRAN_END':0xff}

#bytes for specifying type of message
msgids = {'Stat_Rep':0x1d, 'Mis_Ctrl':0x34, 'Ext_Ctrl':0x30, 'Way_Pt_Rep':0x31}

task_type = {None:None,'FC_TSK_Null':0, 'FC_TSK_TakeOff':1, 'FC_TSK_Land':2, 
             'FC_TSK_RTH':3, 'FC_TSK_SetHome':4, 'FC_TSK_SetPOI': 5,
             'FC_TSK_DelPOI':6, 'FC_TSK_MOVE':7, 'FC_TSK_Gimbal':8, 
             'FC_TSK_SetEXTIO':9, 'FC_TSK_WayPoint':10, 'FC_TSK_SetSpeed':11, 
             'FC_TSK_SetALT':12, 'FC_TSK_WAIT_MS':15, 'FC_TSK_REPLAY':16, 
             'FC_TSK_CAMERA':17, 'FC_TSK_RESERVE':18, 'FC_TSK_CIRCLE':19}

def CRC8_table_lookup(buffer, offset):
    # Calculate the CRC8 of the buffer
    crc = 0
    for i,_ in enumerate(buffer):
        crc = CRC8_Table[crc ^ buffer[i + offset]]
    return crc

class splashdrone():
    """
    Control the splashdrone 4 with python. Default wifi password is 12345678.
    """
    def __init__(self): 
        self.src = 0x04 #ground control
        self.dest = 0x01 #flight control
        self.task_id = 0 #initial task id
        self.msgid = msgids['Mis_Ctrl'] #message ID

    def clear_mission(self):     
        opcode = 'FC_TASK_OC_CLEAR'
        task = None
        data = []

        print('Clear mission queue')
        self.send(opcode,task,data)

    def start_tx(self):      
        opcode = 'FC_TASK_OC_START'
        task = None
        data = []

        print('Sending start')
        self.send(opcode,task,data)

    def end_tx(self):
        opcode = 'FC_TASK_OC_TRAN_END'
        task = None
        data = []

        print('End tx')
        self.send(opcode,task,data)

    def add_task(self,task:str,data:list):
        opc = 'FC_TASK_OC_ADD'

        self.send(opc,task,data)

        self.task_id += 1

    def execute(self):       
        opc = 'FC_TASK_OC_START'
        task = None
        data = []

        print('Executing mission')
        self.send(opc,task,data)

    def make_payload(self,opcode,task,task_data):      
        if opcode == 'FC_TASK_OC_CLEAR' or opcode == 'FC_TASK_OC_STOP' or opcode == 'FC_TASK_OC_START':
            self.task_id = 0x00
        elif opcode == 'FC_TASK_OC_TRAN_END':
            self.task_id = 0xFF
            
        payload = [opcodes[opcode],self.task_id,task_type[task]] + task_data
        payload = [item for item in payload if item is not None]
        
        return payload

    def send(self,opc,task,data):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((TCP_IP, TCP_PORT))

        payload = self.make_payload(opc,task,data)
        
        PackLength = 6 + len(payload) #6 bytes for start, packlength, msgid, src, dest, checksum
        
        msg = [start,PackLength,self.msgid,self.src,self.dest] + payload
    
        checksum = CRC8_table_lookup(msg[1:], 0)
        packet = msg + [checksum]
        print([hex(item) for item in packet])

        s.send(bytes(packet))
        ack = s.recv(BUFFER_SIZE) 
        
        print('ACK:')
        print([hex(i) for i in ack])
        
        s.close()

    def wait(self,time:float):
        task = 'FC_TSK_WAIT_MS'
        time_ms = struct.pack('<I',int(time*1000))
        data = list(time_ms)
        print('Waiting for ' + str(time) + ' seconds')
        self.add_task(task,data)

    def lights(self,state:bool):
        task = 'FC_TSK_SetEXTIO'
        ioSelect = 0x33
        ioSelect = struct.pack('<i',ioSelect)
        if state:
            ioSet = 0x33
        else:
            ioSet = 0x00
        ioSet = struct.pack('<i',ioSet)
        data = list(ioSelect) + list(ioSet)
        
        print('Setting lights to ' + str(state))
        self.add_task(task,data)
    
    def set_home(self,lat:float,long:float):
        """
        lat: latitude in 1e7 format
        long: longitude in 1e7 format
        """
        task = 'FC_TSK_SetHome'
        lat = round(lat * 1e7)
        long = round(long * 1e7)
        
        lat_b = struct.pack('<i',lat) #little endian int32/int
        long_b = struct.pack('<i',long)
        data = list(lat_b) + list(long_b)
        
        print('Setting home to ' + str(lat) + ',' + str(long))
        self.add_task(task,data)
        
    def takeoff(self,alt:int):
        """
        alt: altitude 0-65535 cm
        """
        task = 'FC_TSK_TakeOff'
        alt_b = struct.pack('<h',alt) #little endian int16/short
        data = list(alt_b)
        
        print('Taking off to ' + str(alt) + ' cm')
        self.add_task(task,data)
        
    def land(self):
        task = 'FC_TSK_Land'
        data = []
        print('Landing')
        self.add_task(task,data)
        
    def set_speed(self,speed:int):
        """
        speed: 0-65535 cm/s 
        """
        task = 'FC_TSK_SetSpeed'
        speed_b = struct.pack('<H',speed)
        data = list(speed_b)
        print('Setting speed to ' + str(speed) + ' cm/s')
        self.add_task(task,data)
        
    def set_alt(self,alt:int):
        """
        alt: altitude 0-65535 cm
        """
        task = 'FC_TSK_SetALT'
        alt_b = struct.pack('<h',alt)
        data = list(alt_b)
        print('Setting altitude to ' + str(alt) + ' cm')
        self.add_task(task,data)
        
    def add_wp(self,lat:float=None,long:float=None,alt:int=None,speed:int=None,hovertime:int=None):
        """
        lat: latitude in 1e7 format
        long: longitude in 1e7 format
        alt: altitude 0-65535 cm
        speed: 0-65535 cm/s
        """
        task = 'FC_TSK_WayPoint'
        self.set_speed(speed)
        self.set_alt(alt)
        
        hovertime_b = struct.pack('<H',hovertime)
        
        lat = round(lat * 1e7)
        long = round(long * 1e7)
        
        lat_b = struct.pack('<i',lat) #little endian int32/int
        long_b = struct.pack('<i',long)
        
        data = list(hovertime_b) + list(lat_b) + list(long_b)
        print('Adding waypoint at ' + str(lat) + ',' + str(long))
        self.add_task(task,data)

    def return_home(self):
        task = 'FC_TSK_RTH'
        data = []
        print('Returning home')
        self.add_task(task,data)

    def set_gimbal(self,roll:float,pitch:float,yaw:float):
        """
        roll: +/- 0-90 degrees
        pitch: +/- 0-45 degrees
        yawn: +/- 0-45 degrees
        """
        prev_dest = self.dest
        self.dest = 0x03

        task = 'FC_TSK_SetGimbal'
        roll_b = struct.pack('<h',roll)
        pitch_b = struct.pack('<h',pitch)
        yawn_b = struct.pack('<h',yaw)
        
        data = list(roll_b) + list(pitch_b) + list(yawn_b)
        print('Setting gimbal roll, pitch, yaw to', + str(roll) + ',' + str(pitch) + ',' + str(yaw))
        self.add_task(task,data)
        
        self.dest = prev_dest

    def activate_payload(self):
        task = 'FC_TSK_CAMERA'
        data = struct.pack('<h',0x33)
        data = list(data)
        
        print('Activating payload')
        self.add_task(task,data)

if __name__ == '__main__':
    sp = splashdrone()
    
    home = [27.53553982543517, -80.35212724345607]
    pts = [[27.53545733286293, -80.35233656244517], [27.535471940927074, -80.35263697395594]]
    
    sp.start_tx()
    sp.set_home(home[0],home[1])
    
    sp.takeoff(300)
    sp.wait(3)
    
    for pt in pts:
        sp.add_wp(pt[0],pt[1],300,200,10)
        sp.activate_payload()
        sp.land()
        sp.wait(30)
        sp.takeoff(300)
        sp.activate_payload()
    
    sp.return_home()
    sp.end_tx()
    sp.execute()
    
    
    #### actual test
    
    # route0 = []
    # with open('C:\\Users\\anthonydavis2020\\Documents\\github\\HAUCS\\haucs\\HPProutes0.txt', 'r') as f:
    #     lines = f.readlines()
    #     for line in lines:
    #         coord = line.strip('\n').split(',')
    #         coord = [float(i) for i in coord]
    #         route0.append(coord)
            
    # sp.start_tx()
    
    # sp.set_home(route0[0][0],route0[0][1])
    # sp.takeoff(300)
    # sp.wait(3)
    
    # for pond in route0:
    #     sp.add_wp(lat=pond[0],long=pond[1],alt=300,speed=200,hovertime=5)  
    #     sp.activate_payload()
    #     sp.land()
    #     sp.wait(30)
    #     sp.takeoff(300)
    #     sp.activate_payload()
        
    # sp.return_home()
    # sp.end_tx()
    # sp.execute()
    


    