package com.example.fishfirm1;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

public class Pond1Activity extends AppCompatActivity {

    Button do_statusBtn, temperatureBtn, layeredDataBtn;
    String pondTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pond1);
        Bundle bundle = getIntent().getExtras();
        do_statusBtn = findViewById(R.id.button_do);
        temperatureBtn = findViewById(R.id.button_temp);
        layeredDataBtn=findViewById(R.id.layeredDataBtn);

        layeredDataBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent=new Intent( Pond1Activity.this,LayeredDataActivity.class);
                startActivity(intent);
            }
        });

        final FirebaseDatabase database = FirebaseDatabase.getInstance();
        Query ref = database.getReference("ponds/Pond1").limitToLast(1);

        ref.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {

                Log.wtf("Data",dataSnapshot.toString());
                for (DataSnapshot dataSnapshot1:dataSnapshot.getChildren()){
                    DataSnapshot sensorSnap=dataSnapshot1.child("SensorData");
                    sensorSnap=sensorSnap.child(""+(sensorSnap.getChildrenCount()-1));

                final float doLevel = Float.valueOf( sensorSnap.child("do_level").getValue(String.class));
                final float temperature = Float.valueOf(sensorSnap.child("temp").getValue(String.class));
                do_statusBtn.setText(doLevel + "%");
                if (doLevel > 30) {
                    do_statusBtn.setBackgroundColor(Color.YELLOW);
                } else if (doLevel > 20) {
                    do_statusBtn.setBackgroundColor(Color.GREEN);
                } else if (doLevel > 10) {
                    do_statusBtn.setBackgroundColor(Color.RED);
                }
                temperatureBtn.setText(temperature + "°");
                if (temperature > 30) {
                    temperatureBtn.setBackgroundColor(Color.YELLOW);
                } else if (temperature > 20) {
                    temperatureBtn.setBackgroundColor(Color.GREEN);
                } else if (temperature > 10) {
                    temperatureBtn.setBackgroundColor(Color.RED);
                }
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.out.println("The read failed: " + databaseError.getCode());
            }
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Intent intent = new Intent(Pond1Activity.this, MainActivity.class);
        startActivity(intent);
        finish();
    }
}