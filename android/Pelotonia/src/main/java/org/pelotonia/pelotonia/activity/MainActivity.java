package org.pelotonia.pelotonia.activity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;

import com.socialize.Socialize;

import org.pelotonia.pelotonia.R;
import org.pelotonia.pelotonia.fragments.AboutFragment;
import org.pelotonia.pelotonia.fragments.NavigationDrawerFragment;
import org.pelotonia.pelotonia.fragments.RiderFragment;
import org.pelotonia.pelotonia.fragments.SearchFragment;
import org.pelotonia.pelotonia.fragments.TeamFragment;
import org.pelotonia.pelotonia.fragments.WebFragment;
import org.pelotonia.pelotonia.util.PelotonUtil;

public class MainActivity extends ActionBarActivity
        implements NavigationDrawerFragment.NavigationDrawerCallbacks {

    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment mNavigationDrawerFragment;
    private FragmentChangeCallback callback = new FragmentChangeCallback();

    public class FragmentChangeCallback {
        public void changeFragment(Fragment f, boolean addToBackStack) {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction()
                    .setCustomAnimations(R.anim.slide_left_in, R.anim.slide_left_out, R.anim.slide_right_in, R.anim.slide_right_out)
                    .replace(R.id.container, f);
            if (addToBackStack) {
                transaction.addToBackStack(null);
            }
            transaction.commit();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Socialize.onCreate(this, savedInstanceState);

        mNavigationDrawerFragment = (NavigationDrawerFragment)
                getSupportFragmentManager().findFragmentById(R.id.navigation_drawer);

        // Set up the drawer.
        mNavigationDrawerFragment.setUp(
                R.id.navigation_drawer,
                (DrawerLayout) findViewById(R.id.drawer_layout));

        FragmentManager fragmentManager = getSupportFragmentManager();
        if (PelotonUtil.getRider(getApplicationContext()) == null){
            fragmentManager.beginTransaction()
                    .replace(R.id.container, SearchFragment.newInstance(callback, true))
                    .commit();
        }
        else {
            fragmentManager.beginTransaction()
                    .replace(R.id.container, RiderFragment.newRiderInstance(callback, PelotonUtil.getRider(this)))
                    .commit();
        }
    }

    @Override
    public void onNavigationDrawerItemSelected(int position) {
        FragmentManager fragmentManager = getSupportFragmentManager();

        switch (position) {
            case 1:
                fragmentManager.beginTransaction()
                    .replace(R.id.container, RiderFragment.newPelotoniaInstance(callback))
                    .addToBackStack(null)
                    .commit();
                break;
            case 2:
                if (PelotonUtil.getRider(getApplicationContext()) == null){
                    fragmentManager.beginTransaction()
                            .replace(R.id.container, SearchFragment.newInstance(callback, true))
                            .commit();
                }
                else {
                    fragmentManager.beginTransaction()
                        .replace(R.id.container, RiderFragment.newRiderInstance(callback,PelotonUtil.getRider(this)))
                        .addToBackStack("riders")
                        .commit();
                }
                break;
            case 3:
                if (PelotonUtil.getFollowedRidersCount(getApplicationContext()) > 0) {
                    fragmentManager.beginTransaction()
                            .replace(R.id.container, TeamFragment.newInstance(callback))
                            .addToBackStack(null)
                            .commit();
                } else {
                    fragmentManager.beginTransaction()
                            .replace(R.id.container, SearchFragment.newInstance(callback,false))
                            .addToBackStack(null)
                            .commit();
                }
                break;
            case 4:
                fragmentManager.beginTransaction()
                        .replace(R.id.container, WebFragment.newInstance("http://www.pelotonia.org/register", "Register"))
                        .addToBackStack(null)
                        .commit();
                break;
            case 5:
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.youtube.com/watch?v=cpJd255qiGM")));
                break;
            case 6:
                fragmentManager.beginTransaction()
                        .replace(R.id.container, AboutFragment.newInstance(callback))
                        .addToBackStack(null)
                        .commit();
                break;
        }
    }

    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setDisplayShowTitleEnabled(true);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!mNavigationDrawerFragment.isDrawerOpen()) {
            // Only show items in the action bar relevant to this screen
            // if the drawer is not showing. Otherwise, let the drawer
            // decide what to show in the action bar.
            getMenuInflater().inflate(R.menu.main, menu);
            restoreActionBar();
            return true;
        }
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        switch (item.getItemId()) {
            case R.id.action_settings:
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onPause() {
        super.onPause();

        // Call Socialize in onPause
        Socialize.onPause(this);
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Call Socialize in onResume
        Socialize.onResume(this);
    }

    @Override
    protected void onDestroy() {
        // Call Socialize in onDestroy before the activity is destroyed
        Socialize.onDestroy(this);

        super.onDestroy();
    }


}
