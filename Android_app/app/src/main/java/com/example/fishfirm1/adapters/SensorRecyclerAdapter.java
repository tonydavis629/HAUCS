package com.example.fishfirm1.adapters;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.fishfirm1.R;
import com.example.fishfirm1.SensorDataModel;

import java.util.List;

public class SensorRecyclerAdapter extends RecyclerView.Adapter<SensorRecyclerAdapter.SensorRecyclerAdapterVH> {
    private final Context context;

    List<SensorDataModel> sensorDataModelList;


    public SensorRecyclerAdapter(Context context, List<SensorDataModel> sensorDataModelList) {
        this.context = context;
        this.sensorDataModelList = sensorDataModelList;
    }

    @NonNull
    @Override
    public SensorRecyclerAdapterVH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        View inflate = LayoutInflater.from(parent.getContext()).inflate(R.layout.sensorrecyclersample, null);
        RecyclerView.LayoutParams lp = new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        inflate.setLayoutParams(lp);
        return new SensorRecyclerAdapterVH(inflate);
    }

    @Override
    public void onBindViewHolder(@NonNull final SensorRecyclerAdapterVH holder, final int position) {
        SensorDataModel model = sensorDataModelList.get(position);
        holder.do_levelTv.setText("DO Level: " + model.getDo_level());
        holder.presTv.setText("Pressure: " + model.getPres());
        holder.tempTv.setText("Temperature: " + model.getTemp());

        holder.sensorIndexTv.setText(String.valueOf(position));

    }

    @Override
    public int getItemCount() {
        return sensorDataModelList.size();
    }

    static class SensorRecyclerAdapterVH extends RecyclerView.ViewHolder {
        TextView do_levelTv, presTv, tempTv, sensorIndexTv;

        public SensorRecyclerAdapterVH(@NonNull View itemView) {
            super(itemView);
            do_levelTv = itemView.findViewById(R.id.do_level);

            presTv = itemView.findViewById(R.id.pres);
            tempTv = itemView.findViewById(R.id.temp);
            sensorIndexTv = itemView.findViewById(R.id.sensorIndex);

        }
    }
}
