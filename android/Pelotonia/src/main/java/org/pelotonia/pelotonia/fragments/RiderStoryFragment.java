package org.pelotonia.pelotonia.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarActivity;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import org.pelotonia.pelotonia.R;
import org.pelotonia.pelotonia.objects.Rider;

public class RiderStoryFragment extends Fragment {
    private Rider rider = null;

    public static RiderStoryFragment newRiderInstance(Rider rider) {
        RiderStoryFragment fragment = new RiderStoryFragment();
        fragment.rider = rider;
        return fragment;
    }

    public static RiderStoryFragment newPelotoniaInstance() {
        RiderStoryFragment fragment = new RiderStoryFragment();
        return fragment;
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("Profile");
    }

    @Override
    public View onCreateView (LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view;
        if (rider == null) {
            view = inflater.inflate(R.layout.fragment_pelotonia_story, null);
        } else {
            view = inflater.inflate(R.layout.fragment_rider_story, null);

            ImageView avatar = (ImageView) view.findViewById(R.id.rider_avatar);
            Picasso.with(getActivity()).load("https://www.mypelotonia.org/" + rider.getRiderPhotoThumbUrl()).into(avatar);

            TextView headerText = (TextView) view.findViewById(R.id.header);
            headerText.setText(rider.name);

            TextView routeText = (TextView) view.findViewById(R.id.sub_header);
            routeText.setText(rider.route);

            TextView storyText = (TextView) view.findViewById(R.id.rider_story);
            storyText.setText(Html.fromHtml(rider.story));
        }
        return view;
    }
}
