package org.pelotonia.pelotonia.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import org.pelotonia.pelotonia.R;
import org.pelotonia.pelotonia.objects.Rider;

import java.util.List;

public class RiderListAdapter extends ArrayAdapter<Rider> {

    public RiderListAdapter(Context context, int resource, int textViewResourceId, List<Rider> objects) {
        super(context, resource, textViewResourceId, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Rider rider = getItem(position);
        View view = super.getView(position, convertView, parent);

        ImageView iconView = (ImageView) view.findViewById(R.id.commentListItemIcon);
        Picasso.with(this.getContext()).load("https://www.mypelotonia.org/" +rider.getRiderPhotoThumbUrl()).into(iconView);

        TextView textView = (TextView) view.findViewById(R.id.commentListItemText);
        textView.setText(rider.route);

        TextView titleView = (TextView) view.findViewById(R.id.commentListItemTitle);
        titleView.setText(rider.name);

        return view;
    }
}
