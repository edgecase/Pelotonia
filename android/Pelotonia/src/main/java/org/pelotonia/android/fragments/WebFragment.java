package org.pelotonia.android.fragments;

import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;

import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import org.pelotonia.android.R;

public class WebFragment extends Fragment {

    String url;

    public WebFragment(String url) {
        this.url = url;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        public void onFragmentInteraction(Uri uri);
    }
}
