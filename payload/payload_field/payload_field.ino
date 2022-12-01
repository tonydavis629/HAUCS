/*
  The code will upload the sensor data to the topside while waiting for topside command

*/
#include <ArduinoBLE.h>
#include <Adafruit_LPS2X.h>

#define DATALEN 5
#define ARRAYLEN 12 // assue we will have three data (pres, DO, temp);
#define DO_PIN A0

Adafruit_LPS28 lps;
Adafruit_Sensor *lps_temp, *lps_pressure;


//Payload Service
BLEService payloadService("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
// Payload Characteristic
//BLEUnsignedCharCharacteristic payloadChar("3072feb5-544e-4d57-a0eb-2eb7374419b7",  // standard 16-bit characteristic UUID
//  BLERead | BLENotify | BLEWrite); // remote clients will be able to get notifications if this characteristic changes
BLECharacteristic payloadChar("3072feb5-544e-4d57-a0eb-2eb7374419b7",  // standard 16-bit characteristic UUID
                              BLERead | BLENotify | BLEWrite, 31, 0); // remote clients will be able to get notifications if this characteristic changes

uint8_t origVal = 0;  // last battery level reading from analog input
long previousMillis = 0;  // last time the battery level was checked, in ms
float psr;
float tem;
int initial_DO = -1;
unsigned long samplingTimeMax = 1000;
unsigned long samplingTime = 0;

void setup() {
  Serial.begin(9600);
  digitalWrite(LED_BUILTIN, LOW);
  delay(5000);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.println("Adafruit LPS2X test!");

  /////////////////////////////////////////////////////////////
  if (!lps.begin_I2C()) {
    Serial.println("Failed to find LPS2X chip");
    for (int i = 0; i < 100; i ++)
    {
      digitalWrite(LED_BUILTIN, LOW);
      delay(50);
      digitalWrite(LED_BUILTIN, HIGH);
      delay(50);
      }
  }
  Serial.println("LPS2X Found!");

  //Initial DO
  initial_DO = analogRead(DO_PIN);
  
  lps_temp = lps.getTemperatureSensor();
  lps_pressure = lps.getPressureSensor();
  // initialize serial communication

  //pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected
  // begin initialization
  
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    delay(1000);
    while (1);
  }
  /* Set a local name for the Bluetooth® Low Energy device
    This name will appear in advertising packets
    and can be used by remote devices to identify this Bluetooth® Low Energy device
    The name can be changed but maybe be truncated based on space left in advertisement packet
  */
  Serial.println("starting BLE:");

  BLE.setLocalName("sensorMonitor");
  BLE.setAdvertisedService(payloadService); // add the service UUID
  payloadService.addCharacteristic(payloadChar); // add the battery level characteristic
  BLE.addService(payloadService); // Add the battery service
  payloadChar.setEventHandler(BLEWritten, payloadCharWritten);
  payloadChar.writeValue(origVal); // set initial value for this characteristic

  /* Start advertising Bluetooth® Low Energy.  It will start continuously transmitting Bluetooth® Low Energy
    advertising packets and will be visible to remote Bluetooth® Low Energy central devices
    until it receives a new connection */

  // start advertising
  BLE.advertise();
  Serial.println("Bluetooth® device active, waiting for connections...");
}
//////////////////////////////////////////////////////////////////////////////////
/* we will need some timing sync (roughly) between topside and payload
   one is when to start sensing (i.e., delay)
   second is how long to do sensing
*/
int timerInt = 0;// this is the timer to be triggered by the winch release command
int sensingDelay = 5; // we delay 1 seconds from the trigger to give suffient time
int sensingDuration = 25; // we will measure total of 20 seconds (1+20=21).We assume a sampling rate of 1Hz.

// we assume the payload will be out of water after this time
// we will initalize sending data even we did not receive the command from topside...
int winchDwonDuration = 60;
uint8_t pond_id = 0;
bool winchRelease = false;
bool waitingUplaod = false;
bool cmdRcvd = false;
int  cmdType = -1;
#define  parmCnt 1; // here we expect only one parameter (pond_id)
// int  cmdParm[parmCnt]; // this is just an example if multiple parameters are expected.

//////////////////////////////////////////////////////////////////////////////////

// data storage array
unsigned char sdata[ARRAYLEN]; // p, DO, temp * 20
int sid = 0; // data index
bool centralChk = false;
bool disconnectChk = false;

void loop() {
//  updateSensorData();
  // wait for a Bluetooth® Low Energy central
  BLEDevice central = BLE.central();
  // if a central is connected to the peripheral:
  if (central) {
    if (centralChk == false)
    {
      Serial.print("Connected to central: ");
      // print the central's BT address:
      Serial.println(central.address());
      digitalWrite(LED_BUILTIN, LOW);
    }
    centralChk = true;
    disconnectChk = false;

  }
  else
  {
    // when the central disconnects, turn off the LED:
    if (disconnectChk == false)
    {
      Serial.print("Disconnected from central: ");
      Serial.println(central.address());
      centralChk = false;
      digitalWrite(LED_BUILTIN, HIGH);
    }
    disconnectChk = true;
  }
//  delay(1000)
  if (winchRelease == true)
  {
    if((millis() - samplingTime) > samplingTimeMax){
      samplingTime = millis();
      timerInt++;
    //Serial.print("timerInt:");
    //Serial.println(timerInt);

    // warning!!! this logic may need to be looked into more
    // we want to start sampling right away but avoid sampling in air
    // but maybe we should collect in-air data and weed out using pressure?
    // start sampling
    if (timerInt > sensingDelay)
    {
      Serial.print("sampling data:");
      Serial.println(sid);

      if (sid < ARRAYLEN)
      {
        updateSensorData(); // only sample 20 data points
      }
    }
    if (timerInt > sensingDuration)
    {
      // reset the counter and winch release flag;
      waitingUplaod = true; // we set the flag so we know we haven't upload the data yet.
    }
    // time is up but we still haven't upload the data yet..
    // let's assume the paylaod is out of water by now, we should send the data.
    //Testing to see if this fixes data issue
//    if ((timerInt > winchDwonDuration) && (waitingUplaod == true))
//    {
//      Serial.print("# data points:");
//      Serial.println(sid);
//      payloadChar.writeValue(sdata, sid); // and update the sensor data characteristic
//      sid = 0;
//      timerInt = 0;
//      winchRelease = false;
//      waitingUplaod = false;
//    }
    }
  }
}
void updateSensorData() // sampling one time
{
  /* Read the current voltage level on the A0 analog input pin.
    This is used here to simulate the charge level of a battery.
  */
  sensors_event_t pressure;
  sensors_event_t temp;
  lps_temp->getEvent(&temp);
  lps_pressure->getEvent(&pressure);
  psr = pressure.pressure;
  tem = temp.temperature;
  /* Display the results (pressure is measured in hPa) */
  // Serial.print("Pressure: ");Serial.print(pressure.pressure);Serial.println(" hPa");
    

  int praw = psr;
  sdata[sid++] = map(praw, 0, 2000, 0, 255);
  int Draw = analogRead(A0);
  int DO = (100 * Draw) / initial_DO;
  sdata[sid++] = DO;
  int traw = tem;
  sdata[sid++] = traw;
  Serial.print("Sid: "); Serial.println(sid);
  Serial.print("HpA Pressure: "); Serial.println(praw);
  Serial.print("MAP pressure: "); Serial.println(map(praw, 0, 2000, 0, 255));
  Serial.print("Temperature: ");Serial.print(traw); Serial.println(" degrees C");
  Serial.print("Raw DO     : "); Serial.println(Draw);
  Serial.print("Dissolved O: "); Serial.print(DO); Serial.println("%");
  
}

// there may be better to handle this.. but I can only send a scalar value over ...
// so the cmd will be sent in two steps
// first value is the cmd type (i.e., winch release, upload data etc.)
// the second value will be the pond_id (or other parameters).
// this can be extended to multiple parameters, but the key is all the commands have the same length.
void payloadCharWritten(BLEDevice central, BLECharacteristic characteristic) {
  // central wrote new value to characteristic, update LED
  Serial.print("Characteristic event, written: ");
  if (payloadChar.value()) {
    uint8_t cval;
    payloadChar.readValue(cval);
    Serial.print("cmdType: ");
    Serial.println(cval);
    Serial.print("cmdRcvd: ");
    Serial.println(cmdRcvd);

    cmdType = cval; 
//    if (cmdRcvd == false) // this is a cmd string
//    {
//      cmdRcvd = true;
//      cmdType = cval;
//    }
//    else // if already received cmd string, we expect parameters. here if
//    {
//      // this can be a while statement if more than one parameter are expected.
//      //cmdParm = cval;
//      pond_id = cval;
//      cmdRcvd = false; // reset the cmd
//    }
//    if (cmdRcvd == true) // this is a cmd string
//    {
      //pond_id = cval;
    if (cmdType == 2)
    {
      Serial.print("setting winch relased:");
      // we initialize the timer and set the winch release flag.
      timerInt = 0;
      winchRelease = true;
      Serial.println(winchRelease);
    }
    if (cmdType == 3)
    {
      Serial.println("ready to upload data");
      // we initialize the timer and set the winch release flag.
      Serial.print("# data points:");
      Serial.println(sid);

      for(int i = 0; i < sid; i++){
        Serial.print("sid: "); Serial.print(i); Serial.print(" val: "); Serial.println(sdata[i]);
      }
      payloadChar.writeValue(sdata, sid); // and update the sensor data characteristic
      sid = 0;
      timerInt = 0;
      winchRelease = false;
      waitingUplaod = false;
    }
//    }
  }
}
