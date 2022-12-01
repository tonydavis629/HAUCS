package com.example.fishfirm1;

public class SensorDataModel {
    String do_level;
    String temp;
    String pres;

    public SensorDataModel() {
    }

    public SensorDataModel(String do_level, String temp, String pres) {
        this.do_level = do_level;
        this.temp = temp;
        this.pres = pres;
    }

    public String getDo_level() {
        return do_level;
    }

    public void setDo_level(String do_level) {
        this.do_level = do_level;
    }

    public String getTemp() {
        return temp;
    }

    public void setTemp(String temp) {
        this.temp = temp;
    }

    public String getPres() {
        return pres;
    }

    public void setPres(String pres) {
        this.pres = pres;
    }
}
