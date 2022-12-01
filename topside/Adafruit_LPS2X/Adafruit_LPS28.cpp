#include <Adafruit_LPS2X.h>

/*!  @brief Initializer for post i2c/spi init
 *   @param sensor_id Optional unique ID for the sensor set
 *   @returns True if chip identified and initialized
 */
bool Adafruit_LPS28::_init(int32_t sensor_id) {

  Adafruit_BusIO_Register chip_id = Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS2X_WHOAMI, 1);

  // make sure we're talking to the right chip
  uint8_t id = chip_id.read();

  if (id != LPS28HB_CHIP_ID) {
    return false;
  }
  _sensorid_pressure = sensor_id;
  _sensorid_temp = sensor_id + 1;

  temp_scaling = 100;
  temp_offset = 0;
  inc_spi_flag = 0x40;

  ctrl1_reg = new Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS28_CTRL_REG1, 1);
  ctrl2_reg = new Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS28_CTRL_REG2, 1);
  ctrl3_reg = new Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS28_CTRL_REG3, 1);
  threshp_reg = new Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS28_THS_P_L_REG, 1);

  reset();
  // do any software reset or other initial setup
  setDataRate(LPS28_RATE_10_HZ);

  pressure_sensor = new Adafruit_LPS2X_Pressure(this);
  temp_sensor = new Adafruit_LPS2X_Temp(this);
  delay(10); // delay for first reading
  return true;
}

/**
 * @brief Sets the rate at which pressure and temperature measurements
 *
 * @param new_data_rate The data rate to set. Must be a `lps28_rate_t`
 */
void Adafruit_LPS28::setDataRate(lps28_rate_t new_data_rate) {
  Adafruit_BusIO_Register ctrl1 = Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS28_CTRL_REG1, 1);
  Adafruit_BusIO_RegisterBits data_rate =
      Adafruit_BusIO_RegisterBits(&ctrl1, 4, 3);

  data_rate.write((uint8_t)new_data_rate);

  isOneShot = (new_data_rate == LPS22_RATE_ONE_SHOT) ? true : false;
}

/**
 * @brief Gets the current rate at which pressure and temperature measurements
 * are taken
 *
 * @return lps28_rate_t The current data rate
 */
lps28_rate_t Adafruit_LPS28::getDataRate(void) {
  Adafruit_BusIO_Register ctrl1 = Adafruit_BusIO_Register(
      i2c_dev, spi_dev, ADDRBIT8_HIGH_TOREAD, LPS28_CTRL_REG1, 1);
  Adafruit_BusIO_RegisterBits data_rate =
      Adafruit_BusIO_RegisterBits(&ctrl1, 4, 3);

  return (lps28_rate_t)data_rate.read();
}


/**
 * @brief Configures the INT pin, by default it will output DRDY signal
 * @param activelow Pass true to make the INT pin drop low on interrupt
 * @param opendrain Pass true to make the INT pin an open drain output
 * @param pres_high If true, interrupt fires on high threshold pass
 * @param pres_low If true, interrupt fires on low threshold pass
 */
void Adafruit_LPS28::configureInterrupt(bool activelow, bool opendrain,
                                        bool pres_high, bool pres_low) {
  uint8_t reg =
      (activelow << 7) | (opendrain << 6) | (pres_low << 1) | pres_high;
  ctrl3_reg->write(reg);
}
