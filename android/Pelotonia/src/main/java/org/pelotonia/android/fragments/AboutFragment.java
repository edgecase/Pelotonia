package org.pelotonia.android.fragments;

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import org.pelotonia.android.R;
import org.pelotonia.android.activity.MainActivity;

public class AboutFragment extends Fragment {

    MainActivity.FragmentChangeCallback mCallback;

    public static AboutFragment newInstance(MainActivity.FragmentChangeCallback callback) {
        AboutFragment f = new AboutFragment();
        f.mCallback = callback;
        return f;
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("About Pelotonia");
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
                WebFragment f = WebFragment.newInstance("http://www.pelotonia.org/", "Pelotonia");
                mCallback.changeFragment(f);
            }
        });
        TextView faqText = (TextView) view.findViewById(R.id.faq_text);
        faqText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                WebFragment f = WebFragment.newInstance("http://www.pelotonia.org/ride/faq", "F.A.Q.");
                mCallback.changeFragment(f);
            }
        });
        TextView sandlotText = (TextView) view.findViewById(R.id.credit_text);
        sandlotText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                WebFragment f = WebFragment.newInstance("http://www.isandlot.com/about-us", "Sandlot Software");
                mCallback.changeFragment(f);

            }
        });

        return view;
    }

}
