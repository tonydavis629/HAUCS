# Basestation Software
Our current implementation of a basestation involves a Heltec Wifi LoRa V2 board that contains an esp32 and LoRa transceiver. This board communicates over serial with a PC. The PC is responsible for reading the sensor data passed through the Heltec board and uploading the data to our Firebase database. 

## ESP32 Basestation
This folder contains all of the code for receiving LoRa packets from the drone and passing them over serial to the PC. This code can be run in Arduino IDE.

## PC Basestation
This folder contains python code for reading the LoRa packets over serial, logging the data locally, and uploading the data to our Firebase database. In addition, the folder also holds the lookup table we use to associate a GPS coordinate with a specific pond ID.
