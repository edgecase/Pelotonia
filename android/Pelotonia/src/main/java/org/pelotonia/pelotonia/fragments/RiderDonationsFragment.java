package org.pelotonia.pelotonia.fragments;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import org.pelotonia.pelotonia.R;
import org.pelotonia.pelotonia.adapter.DonationAdapter;
import org.pelotonia.pelotonia.objects.Rider;

import java.text.NumberFormat;

public class RiderDonationsFragment extends ListFragment {
    private Rider rider = null;

    public static RiderDonationsFragment newInstance(Rider rider) {
        RiderDonationsFragment fragment = new RiderDonationsFragment();
        fragment.rider = rider;
        return fragment;
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("Donations");
    }

    @Override
    public View onCreateView (LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        DonationAdapter adapter = new DonationAdapter(getActivity(), R.layout.donation_layout,
                R.id.donation_amount, rider.getDonors());

        // Inflate the layout for this fragment
        final View view = inflater.inflate(R.layout.fragment_rider_donations, container, false);
        View headerView = inflater.inflate(R.layout.fragment_rider, null);

        if (headerView != null) {
            ImageView avatar = (ImageView) headerView.findViewById(R.id.rider_avatar);
            Picasso.with(getActivity()).load("https://www.mypelotonia.org/" + rider.getRiderPhotoThumbUrl()).into(avatar);
            TextView headerText = (TextView) headerView.findViewById(R.id.header);
            headerText.setText(rider.name);
            TextView routeText = (TextView) headerView.findViewById(R.id.sub_header);
            routeText.setText(rider.route);
            TextView tv = (TextView) headerView.findViewById(R.id.raised);
            TextView tv2 = (TextView) headerView.findViewById(R.id.progressBar_text);
            ProgressBar progress = (ProgressBar) headerView.findViewById(R.id.progressBar);
            NumberFormat formatter = NumberFormat.getCurrencyInstance();

            if (rider.amountPledged > 0) {
                tv.setText(formatter.format(rider.amountRaised) + " of " + formatter.format(rider.amountPledged));
                progress.setMax(rider.amountPledged.intValue());
                progress.setProgress(rider.amountRaised.intValue());
                tv2.setText(NumberFormat.getPercentInstance().format(rider.amountRaised / rider.amountPledged));
                progress.setVisibility(View.VISIBLE);
                tv2.setVisibility(View.VISIBLE);
            } else {
                tv.setText(formatter.format(rider.amountRaised));
                progress.setVisibility(View.INVISIBLE);
                tv2.setVisibility(View.GONE);
            }

            Button button = (Button) headerView.findViewById(R.id.support_button);
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    DonateDialogFragment f = new DonateDialogFragment();
                    f.setRider(rider);
                    f.show(getActivity().getSupportFragmentManager(), "Donate");
                }
            });
            Button follow = (Button) headerView.findViewById(R.id.follow_button);
            follow.setVisibility(View.GONE);

            if (rider.riderYears.contains("2009")) {
                headerView.findViewById(R.id.rider_2009).setVisibility(View.VISIBLE);
            } else {
                headerView.findViewById(R.id.rider_2009).setVisibility(View.GONE);
            }
            if (rider.riderYears.contains("2010")) {
                headerView.findViewById(R.id.rider_2010).setVisibility(View.VISIBLE);
            } else {
                headerView.findViewById(R.id.rider_2010).setVisibility(View.GONE);
            }
            if (rider.riderYears.contains("2011")) {
                headerView.findViewById(R.id.rider_2011).setVisibility(View.VISIBLE);
            } else {
                headerView.findViewById(R.id.rider_2011).setVisibility(View.GONE);
            }
            if (rider.riderYears.contains("2012")) {
                headerView.findViewById(R.id.rider_2012).setVisibility(View.VISIBLE);
            } else {
                headerView.findViewById(R.id.rider_2012).setVisibility(View.GONE);
            }
            if (rider.riderYears.contains("2013")) {
                headerView.findViewById(R.id.rider_2013).setVisibility(View.VISIBLE);
            } else {
                headerView.findViewById(R.id.rider_2013).setVisibility(View.GONE);
            }
            if (rider.riderYears.contains("2014")) {
                headerView.findViewById(R.id.rider_2014).setVisibility(View.VISIBLE);
            } else {
                headerView.findViewById(R.id.rider_2014).setVisibility(View.GONE);
            }
        }

        if (view != null) {
            ListView donorListView = (ListView) view.findViewById(android.R.id.list);
            donorListView.addHeaderView(headerView);
            donorListView.setClickable(false);
        }
        setListAdapter(adapter);

        return view;
    }

}
