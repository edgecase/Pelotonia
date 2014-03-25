package org.pelotonia.android.activity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;

import com.socialize.Socialize;
import com.socialize.UserUtils;
import com.socialize.entity.User;
import com.socialize.error.SocializeException;
import com.socialize.google.gson.Gson;
import com.socialize.listener.user.UserGetListener;

import org.pelotonia.android.PelotoniaApplication;
import org.pelotonia.android.R;
import org.pelotonia.android.fragments.AboutFragment;
import org.pelotonia.android.fragments.NavigationDrawerFragment;
import org.pelotonia.android.fragments.ProfileFragment;
import org.pelotonia.android.fragments.RiderFragment;
import org.pelotonia.android.fragments.SearchFragment;
import org.pelotonia.android.fragments.WebFragment;
import org.pelotonia.android.objects.Rider;
import org.pelotonia.android.util.PelotonUtil;

public class MainActivity extends ActionBarActivity
        implements NavigationDrawerFragment.NavigationDrawerCallbacks {
    private User user;
    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment mNavigationDrawerFragment;

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
     */
    private CharSequence mTitle;

    private SearchFragment.RiderClickListener riderListener = new SearchFragment.RiderClickListener() {
        @Override
        public void onRiderClick(String riderJson) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, RiderFragment.newRiderInstance(riderJson))
                    .addToBackStack("riders")
                    .commit();
        }
    };

    private SearchFragment.RiderClickListener profileListener = new SearchFragment.RiderClickListener(){
        @Override
        public void onRiderClick(String riderJson) {
            Rider r = new Gson().fromJson(riderJson, Rider.class);
            // Save the rider
            PelotonUtil.saveRider(getApplicationContext(),r);
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, RiderFragment.newRiderInstance(riderJson))
                    .addToBackStack("riders")
                    .commit();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Socialize.onCreate(this, savedInstanceState);
        UserUtils.getCurrentUserAsync(this, new UserGetListener() {
            @Override
            public void onGet(User user) {
                if (user != null && (user.getFirstName() != null || user.getLastName() != null)) {
                    ((PelotoniaApplication)getApplication()).setUser(user);
                    MainActivity.this.user = user;
                }
            }

            @Override
            public void onError(SocializeException error) {
                // do nothing
            }
        });

        mNavigationDrawerFragment = (NavigationDrawerFragment)
                getSupportFragmentManager().findFragmentById(R.id.navigation_drawer);
        mTitle = getTitle();

        // Set up the drawer.
        mNavigationDrawerFragment.setUp(
                R.id.navigation_drawer,
                (DrawerLayout) findViewById(R.id.drawer_layout));

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 100) {
            UserUtils.getCurrentUserAsync(this, new UserGetListener() {
                @Override
                public void onGet(User user) {
                    if (user != null && (user.getFirstName() != null || user.getLastName() != null)) {
                        ((PelotoniaApplication)getApplication()).setUser(user);
                        MainActivity.this.user = user;
                        getSupportFragmentManager().beginTransaction()
                                .replace(R.id.container, new ProfileFragment())
                                .addToBackStack("user")
                                .commit();
                     }
                }

                @Override
                public void onError(SocializeException error) {
                    // do nothing
                }
            });
        }
    }

    private void fetchUser(UserGetListener listener) {
        UserUtils.getCurrentUserAsync(this, listener);
    }

    @Override
    public void onNavigationDrawerItemSelected(int position) {
        FragmentManager fragmentManager = getSupportFragmentManager();

        switch (position) {
            case 1:
                fragmentManager.beginTransaction()
                    .replace(R.id.container, RiderFragment.newPelotoniaInstance())
                    .addToBackStack("pelotonia")
                    .commit();
                break;
            case 2:

                if (PelotonUtil.getRider(getApplicationContext()) == null){
                    fragmentManager.beginTransaction()
                            .replace(R.id.container, SearchFragment.newInstance(profileListener))
                            .addToBackStack("riders")
                            .commit();
                }
                else {
                    fragmentManager.beginTransaction()
                        .replace(R.id.container, ProfileFragment.newInstance())
                        .addToBackStack("profile")
                        .commit();
                }

                break;
            case 3:
                fragmentManager.beginTransaction()
                        .replace(R.id.container, SearchFragment.newInstance(riderListener))
                        .addToBackStack("riders")
                        .commit();
                break;
            case 4:
                fragmentManager.beginTransaction()
                        .replace(R.id.container, new WebFragment("http://www.pelotonia.org/register"))
                        .addToBackStack("register")
                        .commit();
                break;
            case 5:
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.youtube.com/watch?v=cpJd255qiGM")));
                break;
            case 6:
                fragmentManager.beginTransaction()
                        .replace(R.id.container, new AboutFragment())
                        .addToBackStack("about")
                        .commit();
                break;
        }

    }


    public void onSectionAttached(int number) {
        switch (number) {
            case 1:
                mTitle = getString(R.string.title_section1);
                break;
            case 2:
                mTitle = getString(R.string.title_section2);
                break;
            case 3:
                mTitle = getString(R.string.title_section3);
                break;
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }


    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setTitle(mTitle);
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
