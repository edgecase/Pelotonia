package org.pelotonia.pelotonia.fragments;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import org.pelotonia.pelotonia.R;
import org.pelotonia.pelotonia.activity.MainActivity;
import org.pelotonia.pelotonia.adapter.RiderListAdapter;
import org.pelotonia.pelotonia.objects.Rider;
import org.pelotonia.pelotonia.util.PelotonUtil;

import java.util.ArrayList;
import java.util.List;

public class TeamFragment extends ListFragment {
    MainActivity.FragmentChangeCallback mCallbackListener;
    List<Rider> riderList = new ArrayList<Rider>();
    RiderListAdapter adapter;

    public TeamFragment() {
        // Required empty public constructor
    }

    public static TeamFragment newInstance(MainActivity.FragmentChangeCallback listener) {
        TeamFragment fragment = new TeamFragment();
        fragment.mCallbackListener = listener;
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        adapter = new RiderListAdapter(getActivity(), R.layout.comment_layout,
                R.id.commentListItemText, riderList);
        setListAdapter(adapter);

        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_team, container, false);
        return view;
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        Rider r = adapter.getItem(position);
        mCallbackListener.changeFragment(RiderFragment.newRiderInstance(mCallbackListener, r), true);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.team, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case R.id.action_search: {
                mCallbackListener.changeFragment(SearchFragment.newInstance(mCallbackListener,false), true);
                return true;
            }
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("Followed Riders");
        riderList.clear();
        riderList.addAll(PelotonUtil.getFollowedRiders(getActivity()));
        adapter.notifyDataSetChanged();
    }
}
