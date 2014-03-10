package org.pelotonia.android.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.socialize.entity.Comment;
import com.socialize.i18n.DefaultLocalizationService;
import com.socialize.ui.util.DateUtils;
import com.socialize.util.ResourceLocator;
import com.squareup.picasso.Picasso;

import org.pelotonia.android.R;

import java.util.List;

/**
 * Created by ckasek on 2/23/14.
 */
public class CommentAdapter extends ArrayAdapter<Comment> {

    private DateUtils dateUtils;

    public CommentAdapter(Context context, int resource, int textViewResourceId, List<Comment> objects) {
        super(context, resource, textViewResourceId, objects);

        dateUtils = new DateUtils();
        DefaultLocalizationService defaultLocalizationService = new DefaultLocalizationService();
        ResourceLocator resourceLocator = new ResourceLocator();
        defaultLocalizationService.setResourceLocator(resourceLocator);
        defaultLocalizationService.init(getContext());
        dateUtils.setLocalizationService(defaultLocalizationService);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Comment comment = getItem(position);
        View view = super.getView(position, convertView, parent);

        ImageView iconView = (ImageView) view.findViewById(R.id.commentListItemIcon);
        Picasso.with(this.getContext()).load(comment.getUser().getSmallImageUri()).into(iconView);

        TextView textView = (TextView) view.findViewById(R.id.commentListItemText);
        textView.setText(comment.getDisplayText());

        TextView titleView = (TextView) view.findViewById(R.id.commentListItemTitle);
        titleView.setText(comment.getUser().getDisplayName() + ", " + dateUtils.getTimeString(System.currentTimeMillis() - comment.getDate()));

        return view;
    }
}
