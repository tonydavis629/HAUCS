/* Intelligent Flight Battery Report Message Structure */
typedef struct{
  uint16_t Voltage;         /* Battery Voltage(mV) */
  uint16_t Capacity;        /* Battery Capacity(mah) */
  uint16_t RemainCap;       /* Remaining Battery Capacity(mah) */
  uint8_t  Percent;         /* Remaining Battery Percentage */
  int8_t   temperature;     /* Battery Temperature(degree Celcius) */
  uint8_t  RemainHoverTime; /* Remaining Hover Time(Minutes) */
  uint8_t  Reserve1;        /* Reserve Value */
  uint8_t  Reserve2;        /* Reserve Value */
  uint8_t  Reserve3;        /* Reserve Value */
  int32_t  eCurrent;        /* Battery Current(mA) */
}t_BatteryInf;