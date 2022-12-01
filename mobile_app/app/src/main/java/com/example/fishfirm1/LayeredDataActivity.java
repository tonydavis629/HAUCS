package com.example.fishfirm1;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Bundle;
import android.util.Log;

import com.example.fishfirm1.adapters.TimestampRecyclerAdapter;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class LayeredDataActivity extends AppCompatActivity {
    GPSData gpsData;
    List<SensorDataModel> sensorDataModelList=new ArrayList<>();
    List<TimeStampModel> timeStampModels=new ArrayList<>();
    RecyclerView timestampRecycler;
    List<String> timeStampKeyList=new ArrayList<>();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_layered_data);

        timestampRecycler=findViewById(R.id.timestampsRecycler);

        final FirebaseDatabase database = FirebaseDatabase.getInstance();
        DatabaseReference ref = database.getReference("ponds/Pond1");

        ref.addValueEventListener(new ValueEventListener() {

            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {

                    if (timeStampModels.size() > 0) {
                        timeStampModels.clear();
                        timeStampKeyList.clear();
                    }

                    for (DataSnapshot dataSnapshot1 : dataSnapshot.getChildren()) {
                        if (sensorDataModelList.size() > 0) {
                            sensorDataModelList.clear();
                        }
                        timeStampKeyList.add(dataSnapshot1.getKey());
                        try {

                            gpsData = dataSnapshot1.child("GPSData").getValue(GPSData.class);
                            for (DataSnapshot dataSnapshot2 : dataSnapshot1.child("SensorData").getChildren()) {
                                Log.wtf("Data", dataSnapshot2.toString());
                                SensorDataModel sensorDataModel = dataSnapshot2.getValue(SensorDataModel.class);
                                sensorDataModelList.add(sensorDataModel);
                            }
                            TimeStampModel timeStampModel = new TimeStampModel(gpsData, sensorDataModelList);
                            timeStampModels.add(timeStampModel);
                        } catch (Exception e){
                            Log.wtf("Exception",e.getMessage());
                        }


                    }

                    callAdapter();

            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.out.println("The read failed: " + databaseError.getCode());
            }
        });

    }

    private void callAdapter() {
        TimestampRecyclerAdapter adapter=new TimestampRecyclerAdapter(LayeredDataActivity.this,timeStampModels,timeStampKeyList);
        timestampRecycler.setLayoutManager(new LinearLayoutManager(LayeredDataActivity.this));
        timestampRecycler.setNestedScrollingEnabled(true);
        timestampRecycler.setAdapter(adapter);
    }
}