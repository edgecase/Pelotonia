package org.pelotonia.android.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.pelotonia.android.R;
import org.pelotonia.android.objects.Rider;

import java.util.List;

public class DonationAdapter extends ArrayAdapter<Rider.Donor> {


    public DonationAdapter(Context context, int resource, int textViewResourceId, List<Rider.Donor> objects) {
        super(context, resource, textViewResourceId, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Rider.Donor donor = getItem(position);
        View view = super.getView(position, convertView, parent);

        TextView amount = (TextView) view.findViewById(R.id.donation_amount);
        amount.setText(donor.amount);

        TextView name = (TextView) view.findViewById(R.id.donor_name);
        name.setText(donor.name);

        TextView date = (TextView) view.findViewById(R.id.donation_date);
        date.setText(donor.date);

        return view;
    }
}
