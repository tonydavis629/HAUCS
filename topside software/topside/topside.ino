#include "BLEDevice.h"
//#include "BLEScan.h"
#include "TinyGPS++.h"
#include "heltec.h"
#include <SPI.h>
//#include <LoRa.h>
#include<Arduino.h>
#include <ESP32Servo360.h>
//#include <esp_now.h>
//#include <WiFi.h>

/***********************************define variables***************************************************************/
#define DEBUG 1 // print out verbose debug messages

///////// IMPORTANT!!!!!!!!!!!! Make sure these flags are turned off during actual operation!!!!!!!!!! //////////
#define BLETEST 1 // this will ignore anything from the base station...
#define LORATEST 1 // using dummy data to test topside -- basestation

//Using ESP32 Serial2 instead of softwareSerial
TinyGPSPlus gps;

// define servo object
ESP32Servo360 servo;

////////////////////////////    LORA parameters ///////////////////////
#define SS 18
#define RST 14
#define DI0 26
#define BAND 915E6
#define spreadingFactor 7 //increasing spreading factor if comm quality is not sufficient.
//#define SignalBandwidth 62.5E3 // 2.5kbs
#define SignalBandwidth 31.25E3 // 1.25kbs
#define preambleLength 8
#define codingRateDenominator 8
byte localAddress = 0xBB;     // address of this device (Drone 1)
byte destination = 0xFF;      // destination to send to (broadcast)
int packetcounter = 0; // LoRA packets counter
////////////////////////////////////////////////////////////////////

//////////////////BLE: the remote service we wish to connect to///////////
static BLEUUID serviceUUID("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
// The characteristic of the remote service we are interested in.
static BLEUUID    charUUID("3072feb5-544e-4d57-a0eb-2eb7374419b7");
static boolean doConnect = false;
static boolean connected = false;
static boolean doScan = false;
static BLERemoteCharacteristic* pRemoteCharacteristic;
static BLEAdvertisedDevice* myDevice;

/**
   Scan for BLE servers and find the first one that advertises the service we are looking for.
*/
class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
//       Called for each advertising BLE server.
    void onResult(BLEAdvertisedDevice advertisedDevice) 
    {
      Serial.print("BLE Advertised Device found: ");
      Serial.println(advertisedDevice.toString().c_str());
      // We have found a device, let us now see if it contains the service we are looking for.
      if (advertisedDevice.haveServiceUUID() && advertisedDevice.isAdvertisingService(serviceUUID)) {
        BLEDevice::getScan()->stop();
        myDevice = new BLEAdvertisedDevice(advertisedDevice);
        doConnect = true;
        doScan = true;
      } // Found our server
    } // onResult
}; // MyAdvertisedDeviceCallbacks

//////////////////sensor data///////////////////////
#define SENSORMAX 20  // assuming at most 20 depth
typedef struct sensorData {
  uint8_t pres; // pressure
  uint8_t temp; // temp
  uint8_t DO;   // DO
} SENSORDATA;
SENSORDATA currReading[SENSORMAX];

SENSORDATA testData[7] = {
    {50,25,15},
    {49,24,14},
    {51,23,5},
    {31,19,7},
    {44,21,10},
    {45,19,13},
    {52,18,16}
}; 

/////////////// GPS data ///////////////////
// base to reduce the data dimension (SIU ToN);
//int baseLat = 37; 
//int baseLon = 89;

byte GPSData[29];
int GPSlen = 29;
/////////////////////////////////////////////////////

size_t datalen = -1; // number of reading (max is SENSORMAX)

//////////////////////////////////////////////////////////////////////////
uint8_t curCmd = 255; // cmd sends to the payload, set a default of FF
/////////////////////////////////////////////////////////////////////////

///////////// sensing time /////////////////////////////////////////////////
// This include the estimated time for winch deployed/retrive and sensing//
int timerCnt = 0;
int sensingTime = 45000*5; // 45 seconds.~200ms sampling rate
// note: this may not needed, this can be checked with altitude
// wait 30 seconds after winch goes down, before checking if payload is online or not
int idleTime = 30000*5; //~200ms sampling rate
////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////
uint8_t pond_id = 1;

/////////////////////////////////////////////////
// servo parms
int target_angle = 0;
int hold_flag = 0;
int diff_angle_prev = 0;
int diff_angle = 0;
/////////////////////////////////////////////////

/* operation mode  -- this can be changed at the base station
   in manual mode the base station will issue command to control the winch release
   in auto mode, the base station will send two commands: S for sensing, H for return home)
   we will attempt to use drone motion
   (i.e., release winch if drone is in decent for N seconds and we are not returning home)
*/
int opmode = 0; // 0: manual (default); 1: auto-sensing; (allows winchRelease) 2: auto-home (disable winchRelease)

//////////////// These are cmds sent from base station /////////////////////////////////////////
int remoteCmd = -1;
int32_t remoteParm = 99999;
bool newManualCmd = false;
////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////Automating winch release /////////////////////////////////////////
float cAlt = 1000, preAlt = 1000;
int AltTh = 50; // we never intend to fly above 50 meter.
float prevAlt; //looking at the movements in ~2 seconds.
int trid = 0;
int mvDirection = 0; //0: horizontal; 1: up; -1: down
int cndTh = 5; // we track for 1 sec (? -- is this long enough)?
float chTh = 0.1; // we check if the change is more than 10cm(? -- is this large enough?)
//////////////////////////////////////////////////////////////////////////////
/***********************************************************************************************************/

void setup() {
  Serial.begin(115200);

  //////////// GPS using serial 2 //////////////////////////
  Serial2.begin(9600, SERIAL_8N1, 16, 17);
  Serial.println("GPS Start");//Just show to the monitor
  //////////////////////////////////////////////////////////
  
  ///////////// Initialize Servo //////////////////////////
  servo.attach(13, 12); // Control pin (white), signal pin (yellow).
  servo.setSpeed(140);
  //  servo.setOffset();
  servo.setMinimalForce(30);
  //////////////////////////////////////////////////////////
  
  Serial.println("Starting Arduino BLE Client application...");
  BLEDevice::init("");

  // Retrieve a Scanner and set the callback we want to use to be informed when we
  // have detected a new device.  Specify that we want active scanning and start the
  // scan to run for 5 seconds.
  BLEScan* pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setInterval(1349);
  pBLEScan->setWindow(449);
  pBLEScan->setActiveScan(true);
  pBLEScan->start(5, false);

  /////////////// LoRA////////////////////////////////////////////////////////////////
  SPI.begin(5, 19, 27, 18);
  LoRa.setPins(SS, RST, DI0);
  if (!LoRa.begin(BAND,true)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  LoRa.setSpreadingFactor(spreadingFactor);
  LoRa.setSignalBandwidth(SignalBandwidth);
  LoRa.setCodingRate4(codingRateDenominator);
  LoRa.setPreambleLength(preambleLength);
  if (DEBUG == 1)
  {
    Serial.println("LoRa Sender Initial OK!");
    Serial.print("LoRa Spreading Factor: ");
    Serial.println(spreadingFactor);
    Serial.print("LoRa Signal Bandwidth: ");
    Serial.println(SignalBandwidth);
  }
  delay(1000);
} // End of setup.

void loop() 
{
  // If the flag "doConnect" is true then we have scanned for and found the desired
  // BLE Server with which we wish to connect.  Now we connect to it.  Once we are
  // connected we set the connected flag to be true.
  if (doConnect == true) {
    if (connectToServer()) {
      Serial.println("We are now connected to the BLE Server.");
    } else {
      Serial.println("We have failed to connect to the server; there is nothin more we will do.");
    }
    doConnect = false;
  }
  /////////////////////////////////////// GPS read //////////////////////////////
  // I am lazy here. This may need to move into the block when winch release cmd is sent
  bool recebido = false;
  while (Serial2.available()) {
     char cIn = Serial2.read();
     recebido = gps.encode(cIn);
  }
  if (gps.location.isUpdated() && gps.altitude.isUpdated())
  {
    //Get the latest info from the gps object which it derived from the data sent by the GPS unit
    preAlt = cAlt;
    cAlt = updateGPSData();
  }

  if (LORATEST==1)
  {
    //Get the latest info from the gps object which it derived from the data sent by the GPS unit
    preAlt = cAlt;
    cAlt = updateGPSData();
  }

  // If we are connected to a peer BLE Server, update the characteristic each time we are reached
  // with the current time since boot.
  if (connected) {
    if (BLETEST==1) // we will test interactive control from the serial monitor connected to the topside
    {
      int rval= readSerialInput(); // return the remote command or -1 if the command is illegal.
      if (rval>0) // legal cmd
      {
        curCmd = rval;
        procManualCmds();
      }
    }
    else
    {
      if (opmode==0) // if we are in manual mode, we process remote cmd to set winch release and data uploading
      {
        if (newManualCmd == true) // We received new remote cmds
        {
          procManualCmds();
          newManualCmd =false; // so we dont react to it over and over again.
        }
      }
      if (opmode==1) // if we are in auto and sensing mode, lets check if we need to set the winch release and data upload commands
      {
        checkDroneMovements();
      }
    }
  }
  else 
  {
    if (doScan) 
    { 
      // ((curCmd == 2) && (timerCnt>idleTime)):  is the condition to check the winch is being retrieved.
      if (((curCmd == 2) && (timerCnt>idleTime)) || (curCmd !=2)) 
      {
        BLEDevice::getScan()->start(0);  // start scan after disconnect, most likely there is better way to do it in arduino
      }
    }
  }
  if (curCmd == 2) // if we are in sensing mode, increment the timer.
  {
    timerCnt++;
    if(timerCnt>sensingTime)// outside the sensing time window, reset the cmd and counter
    {
      curCmd = 0;
      timerCnt = 0;
      Serial.println("sensing timer ends");
    }
  }
  if (LORATEST==1)
  {
    int rval= readSerialInput(); // return the remote command or -1 if the command is illegal.
    if (rval>0) // legal cmd
    {
      curCmd = rval;
      procManualCmds();
    }
  }
  onReceive(LoRa.parsePacket());
  // Delay total 200 ms between loops (100ms in GPS read). This is the samplign rate
  // We use faster sampling in case we need to estimate the platform motion via GPS altitude changes. 
  delay(100); 
} // End of loop

////// Testing control using serial monitor connected to topside ////////////////////
//// This will bypass the loRA message from base station to topside /////////////////
int readSerialInput()      
{
  int rval=255; // intializing to 0XFF
  if (Serial.available() > 0) 
  {
    // read the incoming byte:
    rval=  Serial.parseInt(); // read in is ascii value
    delay(100);
    if (rval !=255)
    {
      Serial.print("new cmd: ");
      Serial.println(curCmd);
      return rval;
    }
    else // same cmd or illegal cmd (255)
    {
      Serial.print("old or illegal cmd ");
      return -1;
    }
  }
  return - 1;
}

void procManualCmds()
{
  if (curCmd == 7) // help menu to out the possible commands
  {
    Serial.println("Help menu: ");
    //Serial.println("Received sensor data: 1");
    Serial.println("Initiating winch down: 2");
  }
  if (curCmd==2) // send cmd to payload to set winch timer
  {
     /* now is the zero time for the data for thsi pond
     so we will need to record the topside info:
      LockinGPSData();
      //pond_id=LookupPondId();  
     This will then be merged with payload data when it becomes avaiable and send via lora.
    */
    uint8_t cmdVal[2];
    cmdVal[0]=2;
    cmdVal[1]=pond_id;
    pRemoteCharacteristic->writeValue(cmdVal[0],1);
    delay(100);
    pRemoteCharacteristic->writeValue(cmdVal[1],1);

    // instead of real pond id, we sent alternatively 0, 1
    // the thinking here is that we will have sufficient time to send data associate with 
    curCmd = 0;// reset to 0
    timerCnt = 0;// I am lazy here, just usint an counter increment on 1 sec...
    Serial.println("sensing timer starts");
  }
  // this should be triggered by the servo encoder reading
  // payload is above water.
  if (curCmd==3) // infor payload to start upload data
  {
    uint8_t cmdVal[2];
    cmdVal[0]=3;
    cmdVal[1]=pond_id;
    //pRemoteCharacteristic->writeValue(cmdVal,2);
    pRemoteCharacteristic->writeValue(cmdVal[0],1);
    delay(100);
    pRemoteCharacteristic->writeValue(cmdVal[1],1);

    // instead of real pond id, we sent alternatively 0, 1
    // the thinking here is that we will have sufficient time to send data associate with 
    pond_id ++; // hard code pond_id for now.
    curCmd = 0;// reset to 0
    timerCnt = 0;// reset timer too.
    Serial.println("start uploading data");
  }
  if (curCmd==4) // test sending data to base station
  {
    if (LORATEST == 1)
    {
      Serial.println("sending simulating data to basestation");
      memcpy(&currReading, &testData, sizeof(testData));
      int slen =7;
      send_GPS_and_Payload_Data_via_LoRA(slen);
    }
  }
}

////// BLE notification call back  /////////////////////////
static void notifyCallback(
  BLERemoteCharacteristic* pBLERemoteCharacteristic,
  uint8_t* pData,
  size_t length,
  bool isNotify)
{
  Serial.print("data length: ");
  Serial.println(length);
  if (length>3) // the sensor data will be an array with length>3 bytes -- at least one structure
  {
    if (DEBUG == 1)
    {
      Serial.print("data length: ");
      Serial.println(length);
      int i=0;
      while (i<length)
      {
        Serial.print("press: ");
        Serial.print(*pData++);i++;
        Serial.print(", DO: ");
        Serial.print(*pData++);i++;
        Serial.print(", temp: ");
        Serial.println(*pData);i++;
      }
    }
    size_t slen=dataparser(pData,length, currReading); //parsing the data stream to sensor data structure array
    if (slen == SENSORMAX)// we have enough data now
    {
      /* we will send the payload data and GPS data via LorA     
      * Lora has a MAX limit of 255 bytes
      * we should stay well below this limit for each packet (60bytes payload and 29 bytes GPS)
      */
      send_GPS_and_Payload_Data_via_LoRA(slen);
    }
  }
}
// we will not search for marker for now since we are dealing with fixe
// data upload event
// if this is deemed insufficient, we can add marker later.

int oid=0; // output data index; 
size_t dataparser(uint8_t* pData, size_t dlen, SENSORDATA* currReading)
{
  int iid=0; // input data index;
  while (iid<dlen)
  {
    currReading[oid].pres=pData[iid];iid++;
    currReading[oid].temp=pData[iid];iid++;
    currReading[oid].DO=pData[iid];iid++;
    oid++;
  }
  return oid; // length of sensor data (bytes)
}

// used for simulated data set
float initTestAlt = 2;
float altTestInc = 0.2;
float altTestTopTh = 10;
float altTestLowTh = 0;
int   altTestId = 0;
int altDirection = -1; //-1: down, 1: up

float updateGPSData()
{
  float calt = 1000;
  int gid=0;
  byte numSat;
  int speedValue, headingVal, dValue, tValue;
  float LatRaw, LngRaw,AltRaw;
  speedValue = round(gps.speed.kmph()*1000); //0.001kmph accuracy.
  if (LORATEST==0)// use real data
  {
    numSat = gps.satellites.value();
    LatRaw = gps.location.lat();
    LngRaw = gps.location.lng();
    AltRaw = gps.altitude.meters();
    speedValue = round(gps.speed.kmph()*1000); //0.001kmph accuracy.
    headingVal = gps.course.value(); // Raw course in 100ths of a degree (i32)
    dValue = gps.date.value();
    tValue = gps.time.value();
  }
  else //simulated data
  {
    numSat = 5;
    LatRaw = 37.634725;
    LngRaw = -89.175868;
    
    // simulating the drone either ascend or descend
    AltRaw = initTestAlt+altTestId*altTestInc*altDirection; altTestId++;
    if (AltRaw>altTestTopTh|| AltRaw<altTestLowTh)//reset simulation...
    {
      AltRaw = initTestAlt;
      altTestId=0;
    }
    speedValue = 10; //0.001kmph accuracy.
    headingVal = 120; // Raw course in 100ths of a degree (i32)
    dValue = 100822;//DDMMYY
    tValue = 10152010; //HHMMSSCC
  }
  
  GPSData[gid++] = numSat & 0xFF;
  int latVInt = round(abs(LatRaw)*1e6); //this should be enought accuracy ...
  GPSData[gid++]  = (latVInt>>24) & 0xFF;
  GPSData[gid++]  = (latVInt >> 16) & 0xFF;
  GPSData[gid++]  = (latVInt >> 8) & 0xFF;
  GPSData[gid++]  = latVInt & 0xFF;
  
  int lngVInt = round(abs(LngRaw)*1e6); //this should be enought accuracy ...
  GPSData[gid++]  = (lngVInt>>24) & 0xFF;
  GPSData[gid++]  = (lngVInt >> 16) & 0xFF;
  GPSData[gid++]  = (lngVInt >> 8) & 0xFF;
  GPSData[gid++]  = lngVInt & 0xFF;    

  int altVInt = round(AltRaw*1000); // 1mm accuracy...
  GPSData[gid++]  = (altVInt>>24) & 0xFF;
  GPSData[gid++]  = (altVInt >> 16) & 0xFF;
  GPSData[gid++]  = (altVInt >> 8) & 0xFF;
  GPSData[gid++]  = altVInt & 0xFF;   
  
  GPSData[gid++]  = (speedValue>>24) & 0xFF;
  GPSData[gid++]  = (speedValue >> 16) & 0xFF;
  GPSData[gid++]  = (speedValue >> 8) & 0xFF;
  GPSData[gid++]  = speedValue & 0xFF;

  GPSData[gid++]  = (headingVal>>24) & 0xFF;
  GPSData[gid++]  = (headingVal >> 16) & 0xFF;
  GPSData[gid++]  = (headingVal >> 8) & 0xFF;
  GPSData[gid++]  = headingVal & 0xFF;

  GPSData[gid++]  = (dValue>>24) & 0xFF;
  GPSData[gid++]  = (dValue >> 16) & 0xFF;
  GPSData[gid++]  = (dValue >> 8) & 0xFF;
  GPSData[gid++]  = dValue & 0xFF;
  
  GPSData[gid++]  = (tValue>>24) & 0xFF;
  GPSData[gid++]  = (tValue >> 16) & 0xFF;
  GPSData[gid++]  = (tValue >> 8) & 0xFF;
  GPSData[gid++]  = tValue & 0xFF;
  
  if ((DEBUG==1) && (LORATEST!=1))
  {
    Serial.print("Satellite Count:");
    Serial.println(gps.satellites.value());
    Serial.print("Latitude:");
    Serial.println(gps.location.lat(), 6);
    Serial.print("Longitude:");
    Serial.println(gps.location.lng(), 6);
    Serial.print("Speed KMPH:");
    Serial.println(gps.speed.kmph()); // km/hr
    Serial.print("Altitude Meters:");
    Serial.println(gps.altitude.meters());
    Serial.print("date:");
    Serial.println(gps.date.value());
    Serial.print("time:");
    Serial.println(gps.time.value());
  }
  smartDelay(100);
  return AltRaw; //return current altitude
}

// we will send GPS and Payload data together but in separate packats
// GPS will be 32 bytes;
// Payload data will be 60 bytes (20 pts of 3 bytes);
void send_GPS_and_Payload_Data_via_LoRA(int slen)
{
    delay(500);
    Serial.print("Sending packet: ");
    Serial.println(packetcounter);
    Serial.println("packlen:"+String(GPSlen));
    // PACKET HEADER 
    LoRa.beginPacket();
    /*
     * LoRa.setTxPower(txPower,RFOUT_pin);
     * txPower -- 0 ~ 20
     * RFOUT_pin could be RF_PACONFIG_PASELECT_PABOOST or RF_PACONFIG_PASELECT_RFO
     *   - RF_PACONFIG_PASELECT_PABOOST -- LoRa single output via PABOOST, maximum output 20dBm
     *   - RF_PACONFIG_PASELECT_RFO     -- LoRa single output via RFO_HF / RFO_LF, maximum output 14dBm
    */
    LoRa.setTxPower(14,RF_PACONFIG_PASELECT_PABOOST);
    LoRa.write(destination);              // add destination address (here we use 0xFF -- broadcast)
    LoRa.write(localAddress);             // add sender address
    // PACKET BODY (GPS Data)
    LoRa.write(packetcounter); // add message ID
    LoRa.write(GPSlen);        // add payload length
    LoRa.write(GPSData,GPSlen);       // add payload
    // PACKET END 
    LoRa.endPacket();
    delay(1000);
    packetcounter++;      
    
    Serial.print("Sending packet: ");
    Serial.println(packetcounter);
    // PACKET HEADER 
    LoRa.beginPacket();
    LoRa.setTxPower(14,RF_PACONFIG_PASELECT_PABOOST);

    LoRa.write(destination);              // add destination address (here we use 0xFF -- broadcast)
    LoRa.write(localAddress);             // add sender address
    // PACKET BODY (Sensor Data)
    uint8_t byteLen = slen*3; // each data point has 3 bytes;
    Serial.println("packlen:"+String(byteLen));

    LoRa.write(packetcounter); // add message ID
    LoRa.write(byteLen);        // add payload length
    LoRa.write((uint8_t *)currReading,byteLen);       // add payload
    // PACKET END 
    LoRa.endPacket();
    delay(250);
    packetcounter++;      
}
  
///////////////////////// LORA msg callback ///////////////////////////////////////////////
/// For now, we only expect commands from base station /////////////////////////////////////
void onReceive(int packetSize) 
{
  if (packetSize == 0) return;          // if there's no packet, return
  // read packet header bytes:
  int recipient = LoRa.read();          // recipient address
  byte sender = LoRa.read();            // sender address
  byte incomingMsgId = LoRa.read();     // incoming msg ID
  byte incomingLength = LoRa.read();    // incoming msg length
  String incoming = "";
  uint8_t incomingChar[50];
  int parm =-999;
  int iid=0;
  while (LoRa.available()) {
    incomingChar[iid++]= (uint8_t) LoRa.read();
  }

  if (incomingLength != iid) {   // check length for error
    Serial.println("error: message length does not match length");
    return;                             // skip rest of function
  }

  // if the recipient isn't this device or broadcast,
  if (recipient != localAddress && recipient != 0xFF) {
    Serial.println("This message is not for me.");
    return;                             // skip rest of function
  }
  
  ////////////////////////////////////////////
  ////we expect the msg will be:
  // cmd: 1 byte
  // (optional) parameter: 4 byte (integer)
  if (incomingLength == 1) // only cmd, no parameter
  { 
    remoteCmd = incomingChar[0];
    remoteParm = -1; // set the parameter to default.
  }
  if (incomingLength == 5)
  {
    remoteCmd = incomingChar[0];
    remoteParm = (int32_t)(incomingChar[1]<<24)+(int32_t) (incomingChar[2]<<16)+(int32_t) (incomingChar[3]<<8)+(int32_t) (incomingChar[4]);
    //remoteParm = (incomingChar[4]&0xFF);
    Serial.println("remoteParm_init: "+String(remoteParm));
  }
  // we process remote command
  if (DEBUG == 1)
  {
    // if message is for this device, or broadcast, print details:
    Serial.println("Received from: 0x" + String(sender, HEX));
    Serial.println("Sent to: 0x" + String(recipient, HEX));
    Serial.println("Message ID: " + String(incomingMsgId));
    Serial.println("Message length: " + String(incomingLength));
    Serial.println("remoteCmd: "+String(remoteCmd));
    Serial.println("remoteParm: "+String(remoteParm));
    Serial.println("incomingChar[1]: "+String(incomingChar[1]));
    Serial.println("incomingChar[2]: "+String(incomingChar[2]));
    Serial.println("incomingChar[3]: "+String(incomingChar[3]));
    Serial.println("incomingChar[4]: "+String(incomingChar[4]));    
    Serial.println("RSSI: " + String(LoRa.packetRssi()));
    Serial.println("Snr: " + String(LoRa.packetSnr()));
    Serial.println();
  }
  processRemoteCmd();
}

////////// this is only needed in auto mode /////////////////////////////////////////
void checkDroneMovements()
{
  if ((cAlt <AltTh) && (prevAlt< AltTh)) // cAlt return will be 1000 if the reading is incorrect.
  {
    if (abs(cAlt-prevAlt)<chTh) // movement is small (horizonal movements)
    {
      trid = 0; // we don't care... reset the counter 
    }
    else if (cAlt-prevAlt>chTh)// continue moving up
    {
      if (mvDirection==1) // continue ascending
      {
        trid++;
        // the drone has been decending for cndTh*0.2 sec now and we are in sensing mode.
        if ((trid>cndTh) && (opmode==1))
        {
          curCmd = 3;         // we should engate data upload
          trid = 0;
        }
      }
      else // start to climb
      {
        trid = 0;
        mvDirection=1;
      }
    }
    if (prevAlt-cAlt>chTh) // moving down -- we do care!
    {
      trid++;
      // the drone has been decending for cndTh*0.2 sec now and we are in sensing mode.
      if ((trid>cndTh) && (opmode==1))
      {
        curCmd = 2;         // we should engate winch release.
        trid = 0;
      }
    }
  }
}

/// BLE related classes and functions ///////////////////////////////
class MyClientCallback : public BLEClientCallbacks {
    void onConnect(BLEClient* pclient) {}
    void onDisconnect(BLEClient* pclient) 
    {
      connected = false;
      Serial.println("onDisconnect");
    }
};

bool connectToServer() {
  Serial.print("Forming a connection to ");
  Serial.println(myDevice->getAddress().toString().c_str());
  BLEClient*  pClient  = BLEDevice::createClient();
  Serial.println(" - Created client");
  pClient->setClientCallbacks(new MyClientCallback());

  // Connect to the remove BLE Server.
  pClient->connect(myDevice);  // if you pass BLEAdvertisedDevice instead of address, it will be recognized type of peer device address (public or private)
  Serial.println(" - Connected to server");
  //pClient->setMTU(517); //set client to request maximum MTU from server (default is 23 otherwise)
  int mtuval=pClient->getMTU(); 
  Serial.print("MTU:");
  Serial.println(mtuval);

  // Obtain a reference to the service we are after in the remote BLE server.
  BLERemoteService* pRemoteService = pClient->getService(serviceUUID);
  if (pRemoteService == nullptr) {
    Serial.print("Failed to find our service UUID: ");
    Serial.println(serviceUUID.toString().c_str());
    pClient->disconnect();
    return false;
  }
  Serial.println(" - Found our service");
  // Obtain a reference to the characteristic in the service of the remote BLE server.
  pRemoteCharacteristic = pRemoteService->getCharacteristic(charUUID);
  if (pRemoteCharacteristic == nullptr) {
    Serial.print("Failed to find our characteristic UUID: ");
    Serial.println(charUUID.toString().c_str());
    pClient->disconnect();
    return false;
  }
  Serial.println(" - Found our characteristic");

  // Read the value of the characteristic.
  if (pRemoteCharacteristic->canRead()) {
    std::string value = pRemoteCharacteristic->readValue();
    Serial.print("The characteristic value was: ");
    Serial.println(value.c_str());
  }

  if (pRemoteCharacteristic->canNotify())
    pRemoteCharacteristic->registerForNotify(notifyCallback);
  connected = true;
  return true;
}

void   processRemoteCmd()
{
  int power, rope_len, offset_angle;
  float target_angle;
  switch(remoteCmd) 
  {
    case 'a':
      opmode=remoteParm; 
      if (DEBUG==1)
        Serial.println("setting opmod"); //manual (0) or auto (1)
      break;    
    case 's': 
      if (opmode == 0) //manual mode
      {
        curCmd=2;
        newManualCmd = true; // we received new cmd
        if (DEBUG==1)
          Serial.println("opmode: manual, remote start sampling");
      }
      else
         Serial.println("opmode: auto, ignore remote manual control of sampling");
      break;
    case 'u':
      if (opmode == 0)
      {
        curCmd=3;
        newManualCmd = true;  // we received new cmd
        if (DEBUG==1)
          Serial.println("opmode: manual, remote start data uploading");
      }
      else
         Serial.println("opmode: auto, ignore remote manual control of data uploading");
      break;
    case 'l':
      rope_len = remoteParm;
      target_angle = -1 * rope_len / 0.2617;
      servo.rotateTo(target_angle);
      if (DEBUG==1)
      {
        Serial.print("rotating to: ");
        Serial.println(target_angle);
      }
      break;   
    case 'p':
      power = remoteParm;
      servo.setMinimalForce(power);
      if (DEBUG == 1)
      {
        Serial.print("setting min power to: ");
        Serial.println(power);
      }
      break;
    case 'q':
      servo.stop();
      if (DEBUG == 1)
        Serial.println("Stopping Servo");
      break;
    // setting offset angle to current angle
    case 'o': 
      offset_angle = (int) servo.getAngle(); 
      servo.setOffset(offset_angle);
      target_angle = 0;
      servo.rotateTo(target_angle);
      if (DEBUG == 1)
      {
        Serial.println("Setting Offset");
        Serial.print("offset angle: ");
        Serial.println(offset_angle);
      }
      break;
    case 'r':
      servo.setOffset(0);
      target_angle = 0;
      servo.rotateTo(target_angle);
      if (DEBUG == 1)
      {
        Serial.println("Resetting Offset");
      }
      break;
  }
}

static void smartDelay(unsigned long ms)
{
  unsigned long start = millis();
  do
  {
    while (Serial2.available())
      gps.encode(Serial2.read());
  } while (millis() - start < ms);
}
