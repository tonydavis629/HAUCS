package com.example.fishfirm1;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.fishfirm1.databinding.ActivityMainBinding;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    ActivityMainBinding binding;
    List<PondModel> pondList;
    GPSData gpsData;
    List<SensorDataModel> sensorDataModelList=new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        pondList = new ArrayList<>();


        setListeners();
        final FirebaseDatabase database = FirebaseDatabase.getInstance();
        DatabaseReference ref = database.getReference("ponds");

        ref.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (pondList.size() > 0) {
                    pondList.clear();
                }

                for (DataSnapshot ds : dataSnapshot.getChildren()) {

                    if (timeStampModels.size() > 0) {
                        timeStampModels.clear();
                    }
                    for (DataSnapshot dataSnapshot1 : ds.getChildren()) {
                        if (sensorDataModelList.size() > 0) {
                            sensorDataModelList.clear();
                        }
                        gpsData = dataSnapshot1.child("GPSData").getValue(GPSData.class);
                        for (DataSnapshot dataSnapshot2 : dataSnapshot1.child("SensorData").getChildren()) {
                            Log.wtf("Data", dataSnapshot2.toString());
                            SensorDataModel sensorDataModel = dataSnapshot2.getValue(SensorDataModel.class);
                            sensorDataModelList.add(sensorDataModel);
                        }
                        TimeStampModel timeStampModel = new TimeStampModel(gpsData, sensorDataModelList);
                        timeStampModels.add(timeStampModel);
                    }

                    PondModel pond = new PondModel(timeStampModels);
                    pondList.add(pond);
                }
                changeData();

            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.out.println("The read failed: " + databaseError.getCode());
            }
        });
    }

    List<TimeStampModel> timeStampModels=new ArrayList<>();
    double doLevel;

    private void changeData() {
        for (int i = 0; i < pondList.size(); i++) {
            timeStampModels = pondList.get(i).getTimeStampModels();
            sensorDataModelList = timeStampModels.get(timeStampModels.size() - 1).getSensorDataModelList();
            doLevel = Double.valueOf(sensorDataModelList.get(sensorDataModelList.size() - 1).getDo_level());
            Log.wtf("Number", "" + i);
            switch (i) {
                case 0: {
                    if (doLevel > 65) {
                        binding.buttonOpenActivity2.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity2.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity2.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 1: {
                    //double doLevel = pondList.get(1).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity3.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity3.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity3.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 2: {
                    //double doLevel = pondList.get(2).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity4.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity4.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity4.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 3: {
                    //double doLevel = pondList.get(3).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity5.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity5.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity5.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 4: {
                    //double doLevel = pondList.get(4).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity6.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity6.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity6.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 5: {
                    //double doLevel = pondList.get(5).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity7.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity7.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity7.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 6: {
                    //double doLevel = pondList.get(6).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity8.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity8.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity8.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 7: {
                    //double doLevel = pondList.get(7).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity9.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity9.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity9.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 8: {
                    //double doLevel = pondList.get(8).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity10.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity10.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity10.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 9: {
                    //double doLevel = pondList.get(9).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity11.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity11.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity11.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 10: {
                    //double doLevel = pondList.get(10).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity12.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity12.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity12.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 11: {
                    //double doLevel = pondList.get(11).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity13.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity13.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity13.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 12: {
                    //double doLevel = pondList.get(12).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity14.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity14.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity14.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 13: {
                    //double doLevel = pondList.get(13).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity15.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity15.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity15.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 14: {
                    //double doLevel = pondList.get(14).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity16.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity16.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity16.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 15: {
                    //double doLevel = pondList.get(15).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity17.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity17.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity17.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 16: {
                    //double doLevel = pondList.get(16).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity18.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity18.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity18.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 17: {
                    //double doLevel = pondList.get(17).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity19.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity19.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity19.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 18: {
                    //double doLevel = pondList.get(18).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity20.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity20.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity20.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 19: {
                    //double doLevel = pondList.get(19).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity21.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity21.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity21.setBackgroundColor(Color.RED);
                    }
                    break;
                }
                case 20: {
                    //double doLevel = pondList.get(20).getDoLevel();
                    if (doLevel > 30) {
                        binding.buttonOpenActivity22.setBackgroundColor(Color.YELLOW);
                    } else if (doLevel > 20) {
                        binding.buttonOpenActivity22.setBackgroundColor(Color.GREEN);
                    } else if (doLevel > 10) {
                        binding.buttonOpenActivity22.setBackgroundColor(Color.RED);
                    }
                    break;
                }

            }

        }
    }

    private void setListeners() {

        binding.buttonOpenActivity2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond1Activity.class);
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond2Activity.class);
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond3Activity.class);
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity5.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond5Activity.class);
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity6.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond4Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity6.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity7.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond6Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity7.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity8.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond7Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity8.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity9.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond8Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity9.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity10.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond9Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity10.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity11.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond10Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity11.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity12.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond11Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity12.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity13.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond12Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity13.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity14.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Pond13Activity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity14.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity15.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity15.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity16.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity16.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity17.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity17.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity18.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity18.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity19.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity19.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity20.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity20.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity21.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity21.getText().toString());
                startActivity(intent);
                finish();
            }
        });
        binding.buttonOpenActivity22.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, DetailsActivity.class);
                intent.putExtra("pondTitle", binding.buttonOpenActivity22.getText().toString());
                startActivity(intent);
                finish();
            }
        });

    }
}