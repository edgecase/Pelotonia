package org.pelotonia.pelotonia.fragments;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.pelotonia.pelotonia.R;
import org.pelotonia.pelotonia.objects.WorkOut;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class WorkoutFragment extends ListFragment {

    public static WorkoutFragment newInstance() {
        WorkoutFragment fragment = new WorkoutFragment();
        return fragment;
    }
    public WorkoutFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_workout,container,false);
    }

    private List<WorkOut> workHistory = null;
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        //TODO: Mock the history for now
        workHistory = getMockWorkOut();
        ArrayAdapter<WorkOut> adapter = new ArrayAdapter<WorkOut>(getActivity(),R.layout.rider_item_list,workHistory){
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {

                View view =  super.getView(position, convertView, parent);
                WorkOut w = getItem(position);
                TextView dateText = (TextView) view.findViewById(R.id.rider_date);
                dateText.setText(DateUtils.formatDateTime(getActivity(), w.date, DateUtils.FORMAT_SHOW_DATE));
                TextView milesText = (TextView) view.findViewById(R.id.rider_miles);
                milesText.setText(String.valueOf(w.miles));
                TextView duration = (TextView) view.findViewById(R.id.rider_duration);
                duration.setText(DateUtils.formatElapsedTime(new StringBuilder("H:MM"),w.elapsedTime));
                return view;
            }
        };
        setListAdapter(adapter);

    }

    private List<WorkOut> getMockWorkOut(){
        long oneDay = 86400;
        List<WorkOut> w = new ArrayList<WorkOut>(3);
        Random r= new Random();
        WorkOut w1 = new WorkOut(WorkOut.Excercise.RIDING,System.currentTimeMillis(),r.nextInt(100),r.nextInt(3600));
        WorkOut w2 = new WorkOut(WorkOut.Excercise.RIDING,System.currentTimeMillis()-oneDay,r.nextInt(100),r.nextInt(3600));
        WorkOut w3 = new WorkOut(WorkOut.Excercise.RUNNING,System.currentTimeMillis()-(3*oneDay),r.nextInt(100),r.nextInt(3600));
        w.add(w1);
        w.add(w2);
        w.add(w3);
        return w;
    }
    @Override
    public void onDetach() {
        super.onDetach();
    }


}
