/* Flight Status Report */
typedef struct 
{
  int16_t      ATTPitch;       /* Pitch angle, unit: 0.1 degree */
  int16_t      ATTRoll;        /* Roll angle, unit: 0.1 degree */
  int16_t      ATTYaw;         /* Yaw angle, unit: 0.1 degree */
  uint16_t     FlySpeed;       /* Horizontal speed, unit: 0.1 m/s */
  int16_t      Altitude;       /* Altitude, unit: 0.1 m */
  uint16_t     Distance;       /* Distance, unit: 1 m */
  int16_t      Voltage;        /* Voltage, unit: 0.1v */
  int16_t      GpsHead;        /* GPS Course, in degree */
  int16_t      HomeHead;       /* Home Course, unit: 0.1 degree, +-1800 */
  uint16_t     FlyTime_Sec;    /* unit: 1 sec */
  int32_t      Lon,Lat;        /* the lag\lng of aircraft */
  int32_t      hLat,hLon;      /* the lag\lng of home point (take off point) */

  uint8_t      FrameType;      /* Frame type   0:quad-rotor   1:boat   2:fixed wing */
  uint8_t      InGas;          /* Motor throttle %0-100 */
  int8_t       VSpeed;         /* Vertical speed unit: 0.1m/s */
  uint8_t      VDOP;           /* Positioning accuracy */
  uint8_t      GpsNum;         /* Number of GPS statellites being received */
  uint8_t      reserve1;

  union {
    uint16_t data;
    struct {
      uint8_t FlyMode         : 4;   /* 0:Manual mode; 1:Balance mode; 2:ATTI mode; 3:GPS mode; 4:Cruise mode; 5:Headless mode; 6:Orbit mode; 7:Return-to-home */
      uint8_t IsLowVoltage    : 2;   /*  */
      uint8_t IsMotoUnlock    : 1;   /*  */
      uint8_t RcIsFailed      : 1;   /* Remote Control Signal Lost */
      uint8_t IsAhrsRst       : 1;   /* AHRS is initiating */
      uint8_t IsAltFailed     : 1;   /* Aircraft altitude control failed */
      uint8_t IsLanding       : 1;   /* Descending */
      uint8_t IsUping         : 1;   /* Ascending */
      uint8_t IsReturn        : 1;   /* Return-to-home in progress */
      uint8_t IsFlying        : 1;   /* In Flight */    
      uint8_t Tip_NOGPS       : 1;   /* No GPS signal */
      uint8_t IsHiMobility    : 1;   /* Flying under high speed */
    };
  }SysState1;  
  /**/
}FLY_REPORT_V1;

/**/
typedef struct REPORT_FOLLOWME {
  uint16_t Distance;          //Distance to the target location, unit: 1m
  int16_t  Course;            //Follow-me Course
} REPORT_FOLLOWME;