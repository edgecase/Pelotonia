package org.pelotonia.pelotonia.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import org.pelotonia.pelotonia.R;

public class WebFragment extends Fragment {

    String url;
    String title;


    public static WebFragment newInstance(String url, String title) {
        WebFragment f = new WebFragment();
        f.url = url;
        f.title = title;
        return f;
    }

    public WebFragment() {

    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle(title);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        WebView view = (WebView) inflater.inflate(R.layout.fragment_webview, container, false);
        if (view != null) {
            view.setWebViewClient(new WebViewClient());
            view.getSettings().setBuiltInZoomControls(true);
            view.getSettings().setSupportZoom(true);
            view.getSettings().setLoadWithOverviewMode(true);
            view.getSettings().setUseWideViewPort(true);
            view.loadUrl(url);
        }
        return view;
    }
}
