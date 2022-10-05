/*
  The code will upload the sensor data to the topside while waiting for topside command
*/
#include <ArduinoBLE.h>
#include <Adafruit_LPS2X.h>
#define DO_PIN A0

Adafruit_LPS28 lps;
Adafruit_Sensor *lps_temp, *lps_pressure;


/////////////// Payload Service /////////////////////////////
BLEService payloadService("4fafc201-1fb5-459e-8fcc-c5c9c331914b");

BLEByteCharacteristic cmdChar("000C", BLERead | BLEWrite | BLENotify);
BLEByteCharacteristic calChar("CA11", BLERead | BLEWrite);
BLEByteCharacteristic sensChar("5E00", BLERead | BLEWrite);
BLECharacteristic payloadChar1("0001", BLERead | BLENotify | BLEWrite, 31, 0);
BLECharacteristic payloadChar2("0002", BLERead | BLENotify | BLEWrite, 31, 0);
BLECharacteristic payloadChar3("0003", BLERead | BLENotify | BLEWrite, 31, 0);

bool centralChk = false;
bool disconnectChk = false;

long previousMillis = 0;  // last time the battery level was checked, in ms
float psr;
float tem;
int initial_DO = -1;

//////////////// SAMPLING PARAMETERS ///////////////////////
int numSamples = 3;
unsigned long samplingTimeMax = 20000; //20 second duration
/////////////// SAMPLING VARIABLES ////////////////////////
unsigned long samplingTime = 0;
int sampleState = 0;
char sdata[30]; int sid = 0;

///////////////////////////////////////////////////////////

/*
 * Start Sequence
 */
void setup() {
  Serial.begin(9600);
  delay(1000);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.println("Adafruit LPS2X test!");

  if (!lps.begin_I2C()) {
    Serial.println("Failed to find LPS2X chip");
    for (int i = 0; i < 100; i ++)
    {
      digitalWrite(LED_BUILTIN, LOW); delay(50);
      digitalWrite(LED_BUILTIN, HIGH);delay(50);
      }
  }
  Serial.println("LPS2X Found!");

  //Initial DO
  initial_DO = analogRead(DO_PIN);
  
  lps_temp = lps.getTemperatureSensor();
  lps_pressure = lps.getPressureSensor();
  
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    delay(1000);
    while (1);
  }
  Serial.println("starting BLE:");

  BLE.setLocalName("sensorMonitor");
  BLE.setAdvertisedService(payloadService); // add the service UUID
  payloadService.addCharacteristic(cmdChar);
  payloadService.addCharacteristic(payloadChar1);
  payloadService.addCharacteristic(payloadChar2);
  payloadService.addCharacteristic(payloadChar3);
  payloadService.addCharacteristic(calChar);
  payloadService.addCharacteristic(sensChar);
      
  BLE.addService(payloadService); // Add the battery service
  cmdChar.setEventHandler(BLEWritten, cmdCharWritten);
  calChar.writeValue(0);
  calChar.setEventHandler(BLEWritten, calCharWritten);
  cmdChar.writeValue(0); // set initial value for this characteristic
  sensChar.setEventHandler(BLEWritten, sensCharWritten);

  // start advertising
  BLE.advertise();
  Serial.println("Bluetooth® device active, waiting for connections...");
}



void loop() {
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
  
  ////////////////// Handle Sampling //////////////////
  if ((sampleState <= numSamples) && (sampleState > 0)) {
    if((millis() - samplingTime) > samplingTimeMax){
      samplingTime = millis();
      updateSensorData(sampleState); 
      sampleState += 1;
      
      }
    }
}
void updateSensorData(int sampleState) // sampling one time
{

  //read temperature and pressure
  sensors_event_t pressure;
  sensors_event_t temp;
  lps_temp->getEvent(&temp);
  lps_pressure->getEvent(&pressure);
  psr = pressure.pressure;
  tem = temp.temperature;
    

  int praw = psr;
  int Draw = analogRead(A0);
  int DO = (100 * Draw) / initial_DO;
  int traw = tem;

  sid = sprintf(sdata, "P:%d DO:%d T:%d", praw, DO, traw);
//  sid = 1;
  
  //print readings
  Serial.print("HpA Pressure: "); Serial.println(praw);
  Serial.print("Temperature: ");Serial.print(traw); Serial.println(" degrees C");
  Serial.print("Raw DO     : "); Serial.println(Draw);
  Serial.print("Dissolved O: "); Serial.print(DO); Serial.println("%");

  switch (sampleState){
    case 1:
      payloadChar1.writeValue(sdata);
    break;

    case 2:
      payloadChar2.writeValue(sdata);
    break;

    case 3:
      payloadChar3.writeValue(sdata);
    break;
  }
  
}

/*
 * Handle Cmds From the Topside (or phone)
 */
void cmdCharWritten(BLEDevice central, BLECharacteristic characteristic) {
  // central wrote new value to characteristic, update LED
  Serial.print("Characteristic event, written");
  //handle sampling request
  if (cmdChar.value() == 1){
    cmdChar.writeValue(0);
    sampleState = 1; 
    samplingTime = millis();
  }
}

void calCharWritten(BLEDevice central, BLECharacteristic characteristic) {
  if (calChar.value() != 0){
    initial_DO = analogRead(DO_PIN);
    calChar.writeValue(0);
  }
}

void sensCharWritten(BLEDevice central, BLECharacteristic characteristic) {
  if (sensChar.value() == 1){
      if (!lps.begin_I2C()) {
        Serial.println("Failed to find LPS2X chip");
        sensChar.writeValue(0xFF);
      }
      else{
        lps_temp = lps.getTemperatureSensor();
        lps_pressure = lps.getPressureSensor();
        sensChar.writeValue(0);
      }
  }
}
