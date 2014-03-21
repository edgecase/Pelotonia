package org.pelotonia.android.fragments;

import android.content.Intent;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import org.pelotonia.android.R;
import org.pelotonia.android.activity.WebActivity;

public class AboutFragment extends Fragment {


    public AboutFragment() {
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
        View view = inflater.inflate(R.layout.fragment_about, container, false);

        TextView versionText = (TextView) view.findViewById(R.id.version_text);
        versionText.setText(getString(R.string.about_version, getString(R.string.app_version)));
        Typeface font = Typeface.createFromAsset(getActivity().getAssets(), "fonts/Baksheesh-Regular.ttf");
        versionText.setTypeface(font);

        TextView feedbackText = (TextView) view.findViewById(R.id.feedback_text);
        feedbackText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_SEND);
                intent.setType("text/html");
                intent.putExtra(Intent.EXTRA_EMAIL, "mark@isandlot.com");
                intent.putExtra(Intent.EXTRA_SUBJECT, "Pelotonia Android App Feedback");
                startActivity(Intent.createChooser(intent, "Send Feedback"));
            }
        });

        TextView websiteText = (TextView) view.findViewById(R.id.pelotonia_link_text);
        websiteText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), WebActivity.class);
                intent.putExtra("url","http://www.pelotonia.org/");
                intent.putExtra("title","Pelotonia");
                startActivity(intent);
            }
        });
        TextView faqText = (TextView) view.findViewById(R.id.faq_text);
        faqText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), WebActivity.class);
                intent.putExtra("url","http://www.pelotonia.org/ride/faq");
                intent.putExtra("title","Frequently Asked Questions");
                startActivity(intent);
            }
        });
        TextView sandlotText = (TextView) view.findViewById(R.id.credit_text);
        sandlotText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), WebActivity.class);
                intent.putExtra("url","http://www.isandlot.com/about-us");
                intent.putExtra("title","Sandlot Software");
                startActivity(intent);
            }
        });

        return view;
    }

}
