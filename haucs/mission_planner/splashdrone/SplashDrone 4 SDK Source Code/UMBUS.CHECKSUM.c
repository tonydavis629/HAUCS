/*
Checksum is calculate by CRC8 lookup

*/

/* CRC 8 bit lookup table */
extern const uint8_t CRC8_Table[] ={
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
};

/**/
uint8_t CRC8_Table_Get(uint8_t *buffer, int32_t offset, int32_t len) {
  uint8_t crc;
  int32_t j;
  crc = 0;
  
  for (j = 0; j < len; j++) {
    crc = CRC8_Table[crc ^ buffer[offset]];
    offset++;
  }
  return (crc);
}

/* [Example] Calcuate Checksum */
void calChecksum(void){
  uint8_t testData[128];
  uint8_t checkSum = CRC8_Table_Get(testData,0,128);
}

/* Packet Format */
void Umbus_PackToSend(uint8_t msgID,  uint8_t* p_data, uint8_t DataNum, uint8_t  dest,  uint8_t src){
  int cnt;
  uint8_t outBuf[256];

  outBuf[0] = 0xa6;
  outBuf[1] = DataLen + 6; //[Example] +6 = length from 0xa6 to the end of Checksum
  outBuf[2] = msgID;
  outBuf[3] = src;
  outBuf[4] = dest;

  cnt = 5;
  int k;
  for(k=0;k<DataNum;k++){
    outBuf[cnt] = p_data[k];
    cnt++;
  }

  uint8_t checkSum = CRC8_Table_Get(outBuf,1,cnt-1);
  outBuf[cnt++] = checkSum;

  SerialPort.Write(outBuf,cnt);
}

/* [Example] Turn off aircraft arm light */
void taskOffLed(){
  uint8_t taskData[11];
  taskData[0] = 0xfd; //Excute command immeidately
  taskData[1] = 0x00; //Mission ID, user-defined, do not set to the same ID as other missions
  taskData[2] = 0x09; //Mission Type
  //Mission Data - select IO
  taskData[3] = 0x30;
  taskData[4] = 0x00;
  taskData[5] = 0x00;
  taskData[6] = 0x00;
  //Mission Data - Control ON/OFF
  taskData[7]  = 0x00; //0x30 = Turn ON the arm light
  taskData[8]  = 0x00;
  taskData[9]  = 0x00;
  taskData[10] = 0x00;
  //Send Mission, souce device is Flight Control, Destination is defined by user
  Umbus_PackToSend(0x34,taskData,11,0x01,0xc8);
  //Packet should be packed and sent to serial port in the following format
  //a6 11 34 c8 01 fd 00 09 30 00 00 00 00 00 00 00 4b
}