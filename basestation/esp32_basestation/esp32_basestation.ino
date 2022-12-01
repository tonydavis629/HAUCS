//#include "heltec.h"
#include <SPI.h>
#include <LoRa.h>
#include<Arduino.h>

/***********************************define variables***************************************************************/
#define DEBUG 1
#define PYTHON 1

////////////////////////////    LORA parameters ///////////////////////
#define SS 18
#define RST 14
#define DI0 26
#define BAND 915E6
#define spreadingFactor 7 //increasing spreading factor if comm quality is not sufficient.
#define SignalBandwidth 31.25E3 // 1.25kbs
#define preambleLength 8
#define codingRateDenominator 8
byte localAddress = 0xFE;     // address of this device (base station)
byte destination = 0;         // remote address
byte broadcastaddr = 0xFF;      // destination to send to (broadcast)
byte destination1 = 0xBB;      // Drone 1
byte destination2 = 0xDD;      // Drone 2

int packetcounter = 0; // LoRA packets counter

//////////////////////////   SENSOR DATA  /////////////////////
#define SENSORMAX 20  // assuming at most 20 depth
typedef struct sensorData {
  uint8_t pres; // pressure
  uint8_t temp; // temp
  uint8_t DO;   // DO
} SENSORDATA;
SENSORDATA currReading[SENSORMAX];

//////////////////////// GPS DATA ////////////////////////////
int GPSlen = 29;

float LatRaw = 0;
float LngRaw = 0;
float AltRaw = 0;
float SpeedRaw = 0;
float HeadingRaw = 0;
unsigned long gpsUpdateTime = 0;
int dValue = 0;
int tValue = 0;
byte incoming[128];                //we will stay well below the 255 byte limit of LoRA

////////////////////// WINCH DATA ///////////////////////////
int hall_v = -1;
int current_angle = -1;
int target_angle = -1;
int offset_angle = -1;
int diff_angle = -1;
int power = -1;
uint8_t flag = 255;


///////////////////// DISPLAY INFO ////////////////////////
bool ack = false;
bool msgSent = false;
int msgRSSI = 0;
float msgSNR=  0;
unsigned long update_time = 0;

size_t datalen = -1; // number of reading (max is SENSORMAX)



void setup() {
  
  Serial.begin(115200);
  delay(1000);
  //////////////////  LORA   /////////////////////
  SPI.begin(5, 19, 27, 18);
  LoRa.setPins(SS, RST, DI0);
  if (!LoRa.begin(BAND)) { /*PABOOST Enabled*/
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  LoRa.setSpreadingFactor(spreadingFactor);
  LoRa.setSignalBandwidth(SignalBandwidth);
  LoRa.setCodingRate4(codingRateDenominator);
  LoRa.setPreambleLength(preambleLength);
  LoRa.setTxPower(14,PA_OUTPUT_PA_BOOST_PIN);
//  LoRa.receive();
  if (DEBUG == 1)
  {
    Serial.println("LoRa Sender Initial OK!");
    Serial.print("LoRa Spreading Factor: ");
    Serial.println(spreadingFactor);
    Serial.print("LoRa Signal Bandwidth: ");
    Serial.println(SignalBandwidth);
  }
} // End of setup.

 

void loop() 
{
  //////////////////  SERIAL READ /////////////////////
  if(Serial.available())
  {
      String bufferStr = Serial.readString();
      char message[100];
      strcpy(message,bufferStr.c_str());
      char * strtokIndx;
      char * cmdArray;
      char cmd;
      // the input should be in the format of: cmd parm dest(drone)
      strtokIndx = strtok(message," ");      // get the first part - cmd
      if (strtokIndx != NULL) // we assume the cmd will be a single character (i.e., l, r, o etc.)
        cmd = strtokIndx[0];

      int parm = -1;
      strtokIndx = strtok(NULL, " "); // parsing parm
      if (strtokIndx != NULL) // we assume the cmd will be a single character (i.e., l, r, o etc.)
        parm = atoi(strtokIndx);
         
      int droneID = 0;
      strtokIndx = strtok(NULL, " "); //parsing drone id
      if (strtokIndx != NULL) // we assume the cmd will be a single character (i.e., l, r, o etc.)
        droneID = atoi(strtokIndx);
      if (DEBUG){
         Serial.print("cmd: ");     Serial.println(cmd);
         Serial.print("parm: ");    Serial.println(parm);
         Serial.print("droneID: "); Serial.println(droneID);
      }
//      send_Cmd_via_LoRA(cmd,parm,droneID );
  }
  //////////////////  LORA READ /////////////////////
  onReceive(LoRa.parsePacket());

  /////////////////  DISPLAY DATA //////////////////
  if(!PYTHON){
    if((millis() - update_time) > 5000){
      update_time = millis();
      updatePrint();
//      send_Cmd_via_LoRA('a',0,1 );
    }
  }
} // End Loop

/* 
 * we will send cmd (five bytes)
 * cmd: 1 byte
 * parm: 4 bytes
 */
void send_Cmd_via_LoRA(int cmd, int parm, int droneID)
{
  delay(250);
//  Serial.print("Sending to: "); Serial.print(droneID);
  // convert cmd and parm to a 5 byte byte stream
  int msgid=1,msglen = 5;
  uint8_t data[5];
  data[0]=cmd;
  data[msgid++]=parm>>24&0xFF;
  data[msgid++]=parm>>16&0xFF;
  data[msgid++]=parm>>8&0xFF;
  data[msgid++]=parm&0xFF;
  // PACKET HEADER 
  LoRa.beginPacket();
  if (droneID == 1)
    destination = destination1;
  if (droneID == 2)
    destination = destination2;
  LoRa.write(destination);                // add receiver address
  //LoRa.write(broadcastaddr);            // use 0xFF to send a broadcast msg
  LoRa.write(localAddress);               // add sender address    
  LoRa.write(packetcounter);              // add message ID
  LoRa.write(sizeof(data));               // add payload length
  LoRa.write(data,sizeof(data));          // add payload
  // PACKET END 
  LoRa.endPacket();
//  LoRa.receive();
  packetcounter++;   

  //handle ack
  msgSent = true;
  ack = false;
  update_time = millis();
}

/*
 * LoRa Message Callback
 * For now, we only expect data from the drones
 */
void onReceive(int packetSize) 
{
  yield(); 
  if (packetSize == 0) return;          // if there's no packet, return
  // read packet header bytes:
  int recipient = LoRa.read();          // recipient address
  byte sender = LoRa.read();            // sender address
  byte incomingMsgId = LoRa.read();     // incoming msg ID
  byte incomingLength = LoRa.read();    // incoming msg length
  int parm =-999;
  int iid = 0;

//  msgRSSI = LoRa.packetRssi();
//  msgSNR = LoRa.packetSnr();

  Serial.print("Packet Size: "); Serial.println(packetSize);

  //parse from LoRa buffer
  while (LoRa.available()) {
    incoming[iid++]= LoRa.read();
//    if(DEBUG){
//      Serial.print("incoming: "); Serial.println( incoming[iid - 1]);
//    }
  }
  //error check msg len vs intended msg len
  if (incomingLength != iid) {
    Serial.println("error: message length does not match length");
    return;                             // skip rest of function
  }
  
  // if the recipient isn't this device or broadcast,
  if (recipient != localAddress && recipient != 0xFF) {
    Serial.println("This message is not for me.");
    return;                             // skip rest of function
  }
  Serial.print("incoming Length: "); Serial.println(incomingLength);
  //Parse Msg based on Length
  //GPS Msg
  if (incomingLength == 29)
  {
    updateGPSData(incoming);
  }
  //Winch Msg
  else if(incomingLength == 22){
    updateWinch(incoming);
  }
  //ACK Msg & Display Immediately
  else if(incomingLength == 5){
    ack = true;
    if(!PYTHON){
      updatePrint();
      update_time = millis();
    }
  }
  //Sensor Msg
  else
  {
    Serial.println("Received Sensor Data");
    if (iid%3==0){
      int tupleLen = dataparser(incoming,iid,currReading);
      //send to python Basestation
      if(PYTHON || 1){
        printSensor(currReading, iid/3);
      }
    }
    else{
      Serial.println("data packet length should be multiples of 3");
    }
  }
  //print details
//  if (DEBUG){
//    Serial.println("Received from: 0x" + String(sender, HEX));
//    Serial.println("Sent to: 0x" + String(recipient, HEX));
//    Serial.println("Message ID: " + String(incomingMsgId));
//    Serial.println("Message length: " + String(incomingLength));
//    Serial.println("RSSI: " + String(LoRa.packetRssi()));
//    Serial.println("Snr: " + String(LoRa.packetSnr()));
//    Serial.println();
//  }
}

/*
 * Pack Data into Sensor Data Structure
 */
size_t dataparser(uint8_t* pData, size_t dlen, SENSORDATA* currReading)
{
  int iid=0; // input data index;
  int oid=0; // output data index; 
  while (iid<dlen)
  {   
      currReading[oid].pres=pData[iid];iid++;
      currReading[oid].temp=pData[iid];iid++;
      currReading[oid].DO=pData[iid];iid++;
      oid++;
      Serial.println(currReading[oid -1].pres);
      Serial.println(currReading[oid -1].temp);
      Serial.println(currReading[oid -1].DO);
  }
  return oid; // length of sensor data (bytes)
}

/*
 * Parse GPS data from GPS message. Values stored globally to
 * be accessed by display functions.
 * 
 * GPSData: data in GPS message
 */
void updateGPSData(uint8_t* GPSData)
{
  int gid=0;
  int staCnt = GPSData[gid++]  & 0xFF;
  int latVInt = (int32_t) (GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF);
  LatRaw = (float) latVInt/1e6;
  
  int lngVInt = (int32_t)(GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF);
  LngRaw = (float) lngVInt/1e6;

  int altVInt = (int32_t)(GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF);
  AltRaw = (float) altVInt/1000; //meter

  int speedValue = (int32_t)(GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF);
  SpeedRaw = (float) speedValue/1000; //kmph
  
  int headingVal = (int32_t)(GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF);
  HeadingRaw = (float) headingVal/100;
  
  dValue = (int32_t)(GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF); // date

  tValue = (int32_t)(GPSData[gid++]<<24)+(int32_t)(GPSData[gid++]<<16)+(int32_t)(GPSData[gid++]<<8)+(int32_t)(GPSData[gid++]&0xFF); // time
  Serial.print("GPS ID: "); Serial.println(gid);

  //reset gps time since updat 
  gpsUpdateTime = millis();
  
  //send message to python basestation
  if (PYTHON){
    Serial.print("GPS_DATA");
    Serial.print(" NUM_SAT "); Serial.print(staCnt);
    Serial.print(" SPEED "); Serial.print(SpeedRaw, 4);
    Serial.print(" HEADING "); Serial.print(HeadingRaw);
    Serial.print(" LAT "); Serial.print(LatRaw,6);
    Serial.print(" LNG "); Serial.print(LngRaw,6);
    Serial.print(" ALT "); Serial.print(AltRaw);
    Serial.print(" DVAL "); Serial.print(dValue);
    Serial.print(" TVAL "); Serial.println(tValue);
  }
}

/*
 * Parse Winch data from Winch message. Data stored
 * globally to be accessed by display functions.
 * 
 * ServoData: data in Servo Message
 * ToDO: Pass to Python Basestation
 */
void updateWinch(uint8_t* ServoData){
  int id = 0;
  hall_v = (int32_t)(ServoData[id++] << 24) + (int32_t)(ServoData[id++] << 16) + (int32_t)(ServoData[id++] << 8) + (int32_t)(ServoData[id++] & 0xFF);
  current_angle = (int32_t)(ServoData[id++] << 24) + (int32_t)(ServoData[id++] << 16) + (int32_t)(ServoData[id++] << 8) + (int32_t)(ServoData[id++] & 0xFF);
  target_angle = (int32_t)(ServoData[id++] << 24) + (int32_t)(ServoData[id++] << 16) + (int32_t)(ServoData[id++] << 8) + (int32_t)(ServoData[id++] & 0xFF);
  offset_angle = (int32_t)(ServoData[id++] << 24) + (int32_t)(ServoData[id++] << 16) + (int32_t)(ServoData[id++] << 8) + (int32_t)(ServoData[id++] & 0xFF);
  diff_angle = (int32_t)(ServoData[id++] << 24) + (int32_t)(ServoData[id++] << 16) + (int32_t)(ServoData[id++] << 8) + (int32_t)(ServoData[id++] & 0xFF);
  power = (ServoData[id++] & 0xFF);
  flag = (ServoData[id++] & 0xFF);
//  Serial.print("Winch ID: "); Serial.println(id);
}

/*
 * Send Sensor Data to Python Basestation.
 * 
 * currReading: SENSORDATA array where parsed data is stored.
 * dlen: # of datapoints sent over LoRa. 
 */
void printSensor(SENSORDATA* currReading, int dlen){
  Serial.print("SENSOR_DATA");
  for(int i = 0; i < dlen; i++){
    int mapHPA = map(currReading[i].pres,0,255,0,2000);
    Serial.print(" pres "); Serial.print(mapHPA);
    Serial.print(" temp "); Serial.print(currReading[i].DO);
    Serial.print(" do_level "); Serial.print(currReading[i].temp);
  }
  Serial.println();
}

/*
 * For Non-Python Basestation:
 * Print important Topside info in pretty format
 */
void updatePrint(){
  
  Serial.println("----- GPS -----");
  Serial.print("     Altitude: "); Serial.println(AltRaw);
  Serial.print("        Speed: "); Serial.println(SpeedRaw);
  Serial.print("      Heading: "); Serial.println(HeadingRaw);
  Serial.print(" Last Updated: "); Serial.println((int)((millis() - gpsUpdateTime) / 1000));
  Serial.println("---- WINCH ----");
  Serial.print(" Hall Voltage: ");  Serial.println(hall_v);
  Serial.print("Current Angle: ");  Serial.println(current_angle);
  Serial.print(" Target Angle: ");  Serial.println(target_angle);
  Serial.print(" Offset Angle: ");  Serial.println(offset_angle);
  Serial.print("   Diff Angle: ");  Serial.println(diff_angle);
  Serial.print("        power: ");  Serial.println(power);
  Serial.println("---- Flags ----");
  Serial.print("       Homing: "); Serial.println((flag) & 0x01);
  Serial.print("  Reduced Pwr: "); Serial.println((flag >> 1) & 0x01);
  Serial.print("      Zeroing: "); Serial.println((flag >> 2) & 0x01);
  Serial.print("   Hall Error: "); Serial.println((flag >> 3) & 0x01);
  Serial.println("----- CMD -----");
  Serial.print("Sent: "); Serial.print(msgSent ? "yes" : "no"); Serial.print(" Received: "); Serial.println(ack ? "yes" : "no");
  if(ack){
  Serial.print("RSSI: "); Serial.print(msgRSSI);                Serial.print("      SNR: "); Serial.println(msgSNR);
  }
  Serial.println("---------------");

  msgSent = false;
  ack = false;
}
