import os
import csv
import serial
import time
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
from datetime import datetime

from dataclasses import dataclass
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon

# Based off the THE GREAT PUMPKIN PLOTTER

######### COMPATIBLE SERIAL MESSAGES ##############
# For following examples, <val> can be replaced by any int, float, or string
#
# "GPS_DATA NUM_SAT <val> SPEED <val> HEADING <val> LAT <val> LNG <val> ALT <val> DVAL <val> TVAL <val>\r\n"
#
# "SENSOR_DATA pres <val> temp <val> DO <val> pres <val> temp <val> DO <val> ..... repeating ..... \r\n"


def init_serial(port):
    """
    Initialize Serial Port
    """
    global ser

    ser = serial.Serial(port=port, baudrate=115200,
                         parity=serial.PARITY_NONE,
                          stopbits=serial.STOPBITS_ONE,
                           bytesize=serial.EIGHTBITS,
                            timeout=0)
    return ser


def writeCSV(file, time, data):
    with open(file,'a',newline='') as csvfile:
      writer = csv.writer(csvfile, delimiter=',')
      writer.writerow([time, *data])


def init_file(header):
    filePath = "data"

    date = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')

    if not os.path.exists(filePath):
        os.mkdir(filePath)

    csvFile = filePath + "/" + date + ".csv"

    with open(csvFile,'w',newline='') as csvfile:
      writer = csv.writer(csvfile, delimiter=',')
      writer.writerow(header)

    return csvFile



def processGPS(message):
    """
    Converts message list into a gps dictionary and corresponding timestamp.
    """
    data = dict()

    i = 1
    while i < len(message):
        data[message[i]] = message[ i + 1]
        i += 2

    timestamp = data.pop('DVAL') + data.pop('TVAL')

    return data, timestamp

def processSensor(message):
    """
    Converts message list into a sensor data dictionary
    """
    data = dict()
    i = 1
    while i < len(message):
        data[i // 6 + 1] = {message[i] : message[i + 1], message[i + 2] : message[i + 3], 
                    message[i + 4] : message[i + 5]}
        i += 6

    return data

def uploadData(gdata, sdata, timestamp):
    """
    Uploads Data to the Real-Time Database in Firebase. Pond ID is currently
    hardcoded. Will be replaced by a lookup table in a future version
    """
    pid = str(findPond(gdata["LAT"], gdata["LNG"]))
    print(pid)

    #select pond
    pref = ref.child(pid)

    pref.child(timestamp).set({"GPSData" : gdata, "SensorData" : sdata})

############# POND ID LOOKUP #######################
@dataclass  
class PONDID:
    id: int
    bounds: Polygon

###########################################################
################## a test case (pond 37) ##################
# inPoint =Point(37.634200, -89.175187)
inPoint =Point(37.634641,-89.173786)

###########################################################


#build pond list
pond_list  = []
def initPondList():
    """
    Creates a lists of polygons associated with each pond in the look
    up table. Updates variables 'pond_list'
    """
    id=0
    with open('pond_lut.csv', newline='') as csvfile:
        pondreader = csv.reader(csvfile,delimiter=',')  
        for row in pondreader:
            if (id>0):
                c_ul=Point(float(row[1]),float(row[2]))
                c_ur=Point(float(row[3]),float(row[4]))
                c_ll=Point(float(row[5]),float(row[6]))
                c_lr=Point(float(row[7]),float(row[8]))
                pList=[c_ul,c_ll,c_lr,c_ur,c_ul]
                cPOLYGON = Polygon(pList)
                cPond=PONDID(row[0],cPOLYGON)
                pond_list.append(cPond)
            id=id+1

def findPond(lat=37.634640, lon=89.173787):
    """
    Returns pond from pond_list that contains lat, lon points
    """
    inPoint = Point(float(lat), -1 * float(lon))
    foundId = ""
    for pond in pond_list:
        cpondid= pond.id
        cPoly = pond.bounds
        cf=0
        if (cPoly.contains(inPoint)):
            cf = 1
            print('found pond id:'+str(cpondid))
            foundId = cpondid
    if len(foundId) > 1:
        print('final pond id:'+ foundId)
    else:
        print("No Pond Found!!")
        foundId = "NO_POND_FOUND"
    return foundId

############# Initialize Pond Lookup ###############
initPondList()
print("Number of Ponds Availabe: ", len(pond_list))
print(findPond())


############# SERIAL PORT VARIABLES ################
# port = '/dev/cu.usbserial-2'
# header = ['time', 'numSat', 'speed', 'heading', 'lat', 'lng', 'alt']
header = ['time', 'value0', 'value1', 'value2', 'value3', 'value4', 'value5', 'value6', 'value7', 'value8', 'value9']
file = init_file(header)
port = '/dev/cu.usbserial-0001'
ser  = init_serial(port)


############ FIREBASE VARIABLES ####################
#Store Key in separate file !!!
cred = credentials.Certificate("fb_key.json")
firebase_admin.initialize_app(cred, {'databaseURL': 'https://haucs-monitoring-default-rtdb.firebaseio.com'})
ref = db.reference('/ponds/')


############ GLOBAL VARIABLES #####################
#serial input buffer
buf = b''
#latest GPS DATA
gps_data = dict()
#latest SAMPLE DATA
sensor_data = dict()
timestamp = ""
gps_updated = False
sensor_updated = False


########### MAIN LOOP ############################
while True:
    
    c = ser.read()
    if(c):
        buf = b''.join([buf, c])

        if buf[-1] == 13: #ends with carriage return
            message = buf.decode()
            message = message.split()
            buf = b''

            if len(message) >= 1:
                # pfint(message)
                if message[0] == "GPS_DATA":
                    gps_data, timestamp = processGPS(message)
                    gps_updated = True
                    print(gps_data)

                    #handle gps data logging
                    t_gps = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
                    # writeCSV(file, t_gps, list(gps_data.values()))

                elif message[0] == "SENSOR_DATA":
                    sensor_data = processSensor(message)
                    t = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
                    print(sensor_data)
                    #store data locally
                    data_for_csv = []
                    i = 1
                    while i < len(message):
                        data_for_csv.append(message[i + 1] + ' ' + message[i + 3] + ' ' + message[i + 5])
                        i += 6
                    writeCSV(file, t, data_for_csv)
                    print("wrote csv")
                    sensor_updated = True

    # if  sensor_updated:
    #     gps_updated = False
    #     sensor_updated = False
    #     try:
    #         uploadData(gps_data, sensor_data, timestamp)
    #     except:
    #         print("Tried and Failed to Upload to Database.")




ser.close()





