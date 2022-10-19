package com.example.fishfirm1;

import java.util.List;

public class PondModel {
    double doLevel;
    double temperature;
    List<TimeStampModel> timeStampModels;

    public PondModel(double doLevel, double temperature, List<TimeStampModel> timeStampModels) {
        this.doLevel = doLevel;
        this.temperature = temperature;
        this.timeStampModels = timeStampModels;
    }

    public PondModel(double doLevel, double temperature) {
        this.doLevel = doLevel;
        this.temperature = temperature;
    }

    public PondModel() {
    }

    public PondModel(List<TimeStampModel> timeStampModels) {
        this.timeStampModels = timeStampModels;
    }

    public double getDoLevel() {
        return doLevel;
    }

    public void setDoLevel(double doLevel) {
        this.doLevel = doLevel;
    }

    public double getTemperature() {
        return temperature;
    }

    public void setTemperature(double temperature) {
        this.temperature = temperature;
    }

    public List<TimeStampModel> getTimeStampModels() {
        return timeStampModels;
    }

    public void setTimeStampModels(List<TimeStampModel> timeStampModels) {
        this.timeStampModels = timeStampModels;
    }
}

