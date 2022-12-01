package com.example.fishfirm1;

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

public class DetailsActivity extends AppCompatActivity {

    Button do_statusBtn,temperatureBtn;
    String pondTitle;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_details);
        Bundle bundle = getIntent().getExtras();
        do_statusBtn=findViewById(R.id.button_do);
        temperatureBtn=findViewById(R.id.button_temp);


        if (bundle != null) {
            pondTitle = bundle.getString("pondTitle");
        }



        final FirebaseDatabase database = FirebaseDatabase.getInstance();
        DatabaseReference ref = database.getReference("ponds/"+pondTitle);

        ref.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                final int doLevel = dataSnapshot.child("doLevel").getValue(Integer.class);
                final int temperature = dataSnapshot.child("temperature").getValue(Integer.class);
                do_statusBtn.setText(doLevel+"%");
                if (doLevel > 30) {
                    do_statusBtn.setBackgroundColor(Color.YELLOW);
                    temperatureBtn.setBackgroundColor(Color.YELLOW);
                } else if (doLevel > 20) {
                    do_statusBtn.setBackgroundColor(Color.GREEN);
                    temperatureBtn.setBackgroundColor(Color.GREEN);
                } else if (doLevel > 10) {
                    do_statusBtn.setBackgroundColor(Color.RED);
                    temperatureBtn.setBackgroundColor(Color.RED);
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

            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.out.println("The read failed: " + databaseError.getCode());
            }
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Intent intent =new Intent(DetailsActivity.this,MainActivity.class);
        startActivity(intent);
        finish();
    }
}