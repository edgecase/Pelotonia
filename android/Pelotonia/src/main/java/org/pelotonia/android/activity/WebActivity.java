package org.pelotonia.android.activity;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import org.pelotonia.android.R;
import org.pelotonia.android.fragments.ProfileFragment;
import org.pelotonia.android.fragments.WebFragment;

public class WebActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web);

        FragmentManager fragmentManager = getSupportFragmentManager();

        String url = getIntent().getStringExtra("url");

        fragmentManager.beginTransaction()
                .replace(R.id.container, new WebFragment(url))
                .commit();
        if (getIntent().hasExtra("title")) {
            this.setTitle(getIntent().getStringExtra("title"));
        }
        ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);

    }

}
