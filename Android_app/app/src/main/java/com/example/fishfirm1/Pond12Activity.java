package com.example.fishfirm1;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.widget.Button;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class Pond12Activity extends AppCompatActivity {

    Button do_statusBtn,temperatureBtn;
    String pondTitle;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pond12);
        Bundle bundle = getIntent().getExtras();
        do_statusBtn=findViewById(R.id.button_do);
        temperatureBtn=findViewById(R.id.button_temp);





        final FirebaseDatabase database = FirebaseDatabase.getInstance();
        DatabaseReference ref = database.getReference("ponds/12");

        ref.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                final float doLevel = (float) dataSnapshot.child("doLevel").getValue(Float.class);
                final float temperature = dataSnapshot.child("temperature").getValue(Float.class);
                do_statusBtn.setText(doLevel+"%");
                if (doLevel > 30) {
                    do_statusBtn.setBackgroundColor(Color.YELLOW);
                } else if (doLevel > 20) {
                    do_statusBtn.setBackgroundColor(Color.GREEN);
                } else if (doLevel > 10) {
                    do_statusBtn.setBackgroundColor(Color.RED);
                }
                temperatureBtn.setText(temperature+"°");
                if (temperature > 30) {
                    temperatureBtn.setBackgroundColor(Color.YELLOW);
                } else if (temperature > 20) {
                    temperatureBtn.setBackgroundColor(Color.GREEN);
                } else if (temperature > 10) {
                    temperatureBtn.setBackgroundColor(Color.RED);
                }
            }



            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("ponds/12/1");


                /*public void onDataChange(DataSnapshot dataSnapshot) {
                    final float doLevel = (float) dataSnapshot.child("doLevel").getValue(Float.class);
                    final float temperature = dataSnapshot.child("temperature").getValue(Float.class);
                    do_statusBtn.setText(doLevel+"%");
                    if (doLevel > 30) {
                        do_statusBtn.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        do_statusBtn.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        do_statusBtn.setBackgroundColor(Color.RED);
                    }
                    temperatureBtn.setText(temperature+"°");
                    if (temperature > 30) {
                        temperatureBtn.setBackgroundColor(Color.YELLOW);
                    } else if (temperature > 20) {
                        temperatureBtn.setBackgroundColor(Color.GREEN);
                    } else if (temperature > 10) {
                        temperatureBtn.setBackgroundColor(Color.RED);
                    }


                    }*/
            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.out.println("The read failed: " + databaseError.getCode());
            }
        });
        }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Intent intent =new Intent(Pond12Activity.this,MainActivity.class);
        startActivity(intent);
        finish();
    }
}