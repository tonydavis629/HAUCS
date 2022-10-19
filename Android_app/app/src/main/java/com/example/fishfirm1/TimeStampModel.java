package com.example.fishfirm1;

import java.util.List;

public class TimeStampModel {
    GPSData gpsData;
    List<SensorDataModel> sensorDataModelList;

    public TimeStampModel() {
    }

    public TimeStampModel(GPSData gpsData, List<SensorDataModel> sensorDataModelList) {
        this.gpsData = gpsData;
        this.sensorDataModelList = sensorDataModelList;
    }

    public GPSData getGpsData() {
        return gpsData;
    }

    public void setGpsData(GPSData gpsData) {
        this.gpsData = gpsData;
    }

    public List<SensorDataModel> getSensorDataModelList() {
        return sensorDataModelList;
    }

    public void setSensorDataModelList(List<SensorDataModel> sensorDataModelList) {
        this.sensorDataModelList = sensorDataModelList;
    }
}
