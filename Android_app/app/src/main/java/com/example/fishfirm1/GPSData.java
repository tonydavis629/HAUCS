package com.example.fishfirm1;

public class GPSData {
    String SPEED, HEADING, LNG, NUM_SAT, ALT, LAT;

    public GPSData() {
    }

    public GPSData(String SPEED, String HEADING, String LNG, String NUM_SAT, String ALT, String LAT) {
        this.SPEED = SPEED;
        this.HEADING = HEADING;
        this.LNG = LNG;
        this.NUM_SAT = NUM_SAT;
        this.ALT = ALT;
        this.LAT = LAT;
    }

    public String getSPEED() {
        return SPEED;
    }

    public void setSPEED(String SPEED) {
        this.SPEED = SPEED;
    }

    public String getHEADING() {
        return HEADING;
    }

    public void setHEADING(String HEADING) {
        this.HEADING = HEADING;
    }

    public String getLNG() {
        return LNG;
    }

    public void setLNG(String LNG) {
        this.LNG = LNG;
    }

    public String getNUM_SAT() {
        return NUM_SAT;
    }

    public void setNUM_SAT(String NUM_SAT) {
        this.NUM_SAT = NUM_SAT;
    }

    public String getALT() {
        return ALT;
    }

    public void setALT(String ALT) {
        this.ALT = ALT;
    }

    public String getLAT() {
        return LAT;
    }

    public void setLAT(String LAT) {
        this.LAT = LAT;
    }
}
