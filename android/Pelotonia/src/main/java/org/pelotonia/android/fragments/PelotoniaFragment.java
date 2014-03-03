package org.pelotonia.android.fragments;



import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import org.pelotonia.android.R;

/**
 * A simple {@link android.support.v4.app.Fragment} subclass.
 *
 */
public class PelotoniaFragment extends Fragment {


    public PelotoniaFragment() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_pelotonia, container, false);
        return view;
    }


}
