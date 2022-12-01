package com.example.fishfirm1.adapters;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.fishfirm1.R;
import com.example.fishfirm1.TimeStampModel;

import java.util.List;

public class TimestampRecyclerAdapter extends RecyclerView.Adapter<TimestampRecyclerAdapter.TimestampRecyclerAdapterVH> {
    private final Context context;

    List<TimeStampModel> timeStampModelList;
    List<String> timeStampKeyList;


    public TimestampRecyclerAdapter(Context context, List<TimeStampModel> timeStampModelList,List<String> timeStampKeyList) {
        this.context = context;
        this.timeStampModelList = timeStampModelList;
        this.timeStampKeyList = timeStampKeyList;
    }

    @NonNull
    @Override
    public TimestampRecyclerAdapterVH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        View inflate = LayoutInflater.from(parent.getContext()).inflate(R.layout.timestampsample, null);
        RecyclerView.LayoutParams lp = new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        inflate.setLayoutParams(lp);
        return new TimestampRecyclerAdapterVH(inflate);
    }

    @Override
    public void onBindViewHolder(@NonNull final TimestampRecyclerAdapterVH holder, final int position) {
        TimeStampModel model=timeStampModelList.get(position);
        holder.timestampTv.setText(timeStampKeyList.get(position));
        holder.SPEEDTv.setText("Speed :"+model.getGpsData().getSPEED());
        holder.ALTTv.setText("Alt :"+model.getGpsData().getALT());
        holder.HEADINGTv.setText("Heading :"+model.getGpsData().getHEADING());
        holder.LATTv.setText("Lat :"+model.getGpsData().getLAT());
        holder.LNGTv.setText("Long :"+model.getGpsData().getLNG());
        holder.NUM_SATTv.setText("Num. Sat :"+model.getGpsData().getNUM_SAT());
        SensorRecyclerAdapter adapter=new SensorRecyclerAdapter(context,model.getSensorDataModelList());
        holder.recyclerViewSensor.setLayoutManager(new LinearLayoutManager(context));
        holder.recyclerViewSensor.setNestedScrollingEnabled(true);
        holder.recyclerViewSensor.setAdapter(adapter);

    }

    @Override
    public int getItemCount() {
        return timeStampModelList.size();
    }

    static class TimestampRecyclerAdapterVH extends RecyclerView.ViewHolder {
        TextView timestampTv, SPEEDTv, HEADINGTv, LNGTv, NUM_SATTv, ALTTv, LATTv;
        RecyclerView recyclerViewSensor;
        public TimestampRecyclerAdapterVH(@NonNull View itemView) {
            super(itemView);
            timestampTv = itemView.findViewById(R.id.timestamp);
            SPEEDTv = itemView.findViewById(R.id.speed);
            HEADINGTv = itemView.findViewById(R.id.heading);
            LNGTv = itemView.findViewById(R.id.lng);
            NUM_SATTv = itemView.findViewById(R.id.num_sat);
            ALTTv = itemView.findViewById(R.id.alt);
            LATTv = itemView.findViewById(R.id.lat);
            recyclerViewSensor = itemView.findViewById(R.id.sensorRecycler);


        }
    }
}
