package org.pelotonia.android.fragments;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.Fragment;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.socialize.entity.User;
import com.squareup.picasso.Picasso;

import org.pelotonia.android.PelotoniaApplication;
import org.pelotonia.android.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Fragment used for managing interactions for and presentation of a navigation drawer.
 * See the <a href="https://developer.android.com/design/patterns/navigation-drawer.html#Interaction">
 * design guidelines</a> for a complete explanation of the behaviors implemented here.
 */
public class NavigationDrawerFragment extends Fragment {

    /**
     * Remember the position of the selected item.
     */
    private static final String STATE_SELECTED_POSITION = "selected_navigation_drawer_position";

    /**
     * Per the design guidelines, you should show the drawer on launch until the user manually
     * expands it. This shared preference tracks this.
     */
    private static final String PREF_USER_LEARNED_DRAWER = "navigation_drawer_learned";

    /**
     * A pointer to the current callbacks instance (the Activity).
     */
    private NavigationDrawerCallbacks mCallbacks;

    /**
     * Helper component that ties the action bar to the navigation drawer.
     */
    private ActionBarDrawerToggle mDrawerToggle;

    private DrawerLayout mDrawerLayout;
    private ListView mDrawerListView1;
    private ListView mDrawerListView2;
    private View mFragmentContainerView;

    private int mCurrentSelectedPosition = 0;
    private boolean mFromSavedInstanceState;
    private boolean mUserLearnedDrawer;

    public NavigationDrawerFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Read in the flag indicating whether or not the user has demonstrated awareness of the
        // drawer. See PREF_USER_LEARNED_DRAWER for details.
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(getActivity());
        mUserLearnedDrawer = sp.getBoolean(PREF_USER_LEARNED_DRAWER, false);

        if (savedInstanceState != null) {
            mCurrentSelectedPosition = savedInstanceState.getInt(STATE_SELECTED_POSITION);
            mFromSavedInstanceState = true;
        }

        // Select either the default item (0) or the last selected item.
        //selectItem(mCurrentSelectedPosition);

        // Indicate that this fragment would like to influence the set of actions in the action bar.
        setHasOptionsMenu(true);
    }

    class NavItem {
        String text;
        int iconId;
        String url;

        NavItem(String text, String url) {
            this.text = text;
            this.url = url;
        }

        NavItem(String text, int iconId) {
            this.text = text;
            this.iconId = iconId;
        }

        public String toString() {
            return text;
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {

        RelativeLayout mDrawerRelativeLayout = (RelativeLayout) inflater.inflate(
                R.layout.fragment_navigation_drawer, container, false);
        Typeface font = Typeface.createFromAsset(getActivity().getAssets(), "fonts/Baksheesh-Regular.ttf");

        mDrawerListView1 = (ListView) mDrawerRelativeLayout.findViewById(R.id.listView1);
        TextView header1 = new TextView(getActivity());
        header1.setTextSize(22);
        header1.setTypeface(font);
        header1.setBackgroundColor(getResources().getColor(R.color.nav_header_bg));
        header1.setPadding(10,10,10,10);
        header1.setTextColor(getResources().getColor(R.color.pelotonia_green));
        header1.setText("Participate");
        mDrawerListView1.addHeaderView(header1, null, false);

        mDrawerListView2 = (ListView) mDrawerRelativeLayout.findViewById(R.id.listView2);
        TextView header2 = new TextView(getActivity());
        header2.setTextSize(22);
        header2.setTypeface(font);
        header2.setBackgroundColor(getResources().getColor(R.color.nav_header_bg));
        header2.setTextColor(getResources().getColor(R.color.pelotonia_green));
        header2.setPadding(10,10,10,10);
        header2.setText("Pelotonia");
        mDrawerListView2.addHeaderView(header2, null, false);

        AdapterView.OnItemClickListener clickListener = new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                selectItem((ListView) parent, position);
            }
        };

        mDrawerListView1.setOnItemClickListener(clickListener);
        mDrawerListView2.setOnItemClickListener(clickListener);

        mDrawerListView1.setAdapter(new ArrayAdapter<NavItem>(
                getActionBar().getThemedContext(),
                R.layout.nav_item,
                R.id.labelView,
                getNavList()) {
            public View getView (int position, View convertView, ViewGroup parent) {
                View view = super.getView(position, convertView, parent);
                ImageView iv = (ImageView)view.findViewById(R.id.iconView);

                NavItem item = getItem(position);
                if (item.url == null) {
                    iv.setImageResource(item.iconId);
                } else {
                    Picasso.with(getActivity()).load(item.url).into(iv);
                }
                return view;
            }
        });
        mDrawerListView2.setAdapter(new ArrayAdapter<NavItem>(
                getActionBar().getThemedContext(),
                R.layout.nav_item,
                R.id.labelView,
                new NavItem[]{
                        new NavItem(getString(R.string.nav_register), R.drawable.ic_register),
                        new NavItem(getString(R.string.nav_safety), R.drawable.ic_action_video),
                        new NavItem(getString(R.string.nav_about), R.drawable.ic_pelotonia),
                }){
                    public View getView (int position, View convertView, ViewGroup parent) {
                        View view = super.getView(position, convertView, parent);
                        ImageView iv = (ImageView)view.findViewById(R.id.iconView);
                        iv.setImageResource(getItem(position).iconId);
                        return view;
                    }
                }
        );
        mDrawerListView1.setItemChecked(mCurrentSelectedPosition, true);


        return mDrawerRelativeLayout;
    }

    public boolean isDrawerOpen() {
        return mDrawerLayout != null && mDrawerLayout.isDrawerOpen(mFragmentContainerView);
    }

    /**
     * Users of this fragment must call this method to set up the navigation drawer interactions.
     *
     * @param fragmentId   The android:id of this fragment in its activity's layout.
     * @param drawerLayout The DrawerLayout containing this fragment's UI.
     */
    public void setUp(int fragmentId, DrawerLayout drawerLayout) {
        mFragmentContainerView = getActivity().findViewById(fragmentId);
        mDrawerLayout = drawerLayout;

        // set a custom shadow that overlays the main content when the drawer opens
        mDrawerLayout.setDrawerShadow(R.drawable.drawer_shadow, GravityCompat.START);
        // set up the drawer's list view with items and click listener

        ActionBar actionBar = getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setHomeButtonEnabled(true);

        // ActionBarDrawerToggle ties together the the proper interactions
        // between the navigation drawer and the action bar app icon.
        mDrawerToggle = new ActionBarDrawerToggle(
                getActivity(),                    /* host Activity */
                mDrawerLayout,                    /* DrawerLayout object */
                R.drawable.ic_drawer,             /* nav drawer image to replace 'Up' caret */
                R.string.navigation_drawer_open,  /* "open drawer" description for accessibility */
                R.string.navigation_drawer_close  /* "close drawer" description for accessibility */
        ) {
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                if (!isAdded()) {
                    return;
                }

                getActivity().supportInvalidateOptionsMenu(); // calls onPrepareOptionsMenu()
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                if (!isAdded()) {
                    return;
                }

                if (!mUserLearnedDrawer) {
                    // The user manually opened the drawer; store this flag to prevent auto-showing
                    // the navigation drawer automatically in the future.
                    mUserLearnedDrawer = true;
                    SharedPreferences sp = PreferenceManager
                            .getDefaultSharedPreferences(getActivity());
                    sp.edit().putBoolean(PREF_USER_LEARNED_DRAWER, true).apply();
                }

                getActivity().supportInvalidateOptionsMenu(); // calls onPrepareOptionsMenu()
            }
        };

        // If the user hasn't 'learned' about the drawer, open it to introduce them to the drawer,
        // per the navigation drawer design guidelines.
        if (!mUserLearnedDrawer && !mFromSavedInstanceState) {
            mDrawerLayout.openDrawer(mFragmentContainerView);
        }

        // Defer code dependent on restoration of previous instance state.
        mDrawerLayout.post(new Runnable() {
            @Override
            public void run() {
                mDrawerToggle.syncState();
            }
        });

        mDrawerLayout.setDrawerListener(mDrawerToggle);
    }

    private void selectItem(ListView view, int position) {

        mDrawerListView1.clearChoices();
        mDrawerListView2.clearChoices();
        mCurrentSelectedPosition = position;
        if (view != null) {
            view.setItemChecked(position, true);
        }
        if (mDrawerLayout != null) {
            mDrawerLayout.closeDrawer(mFragmentContainerView);
        }
        if (mCallbacks != null) {
            if (view.getId() == R.id.listView2) {
                position += 3;
            }
            mCallbacks.onNavigationDrawerItemSelected(position);
        }
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            mCallbacks = (NavigationDrawerCallbacks) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement NavigationDrawerCallbacks.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_SELECTED_POSITION, mCurrentSelectedPosition);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        // Forward the new configuration the drawer toggle component.
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        // If the drawer is open, show the global app actions in the action bar. See also
        // showGlobalContextActionBar, which controls the top-left area of the action bar.
        if (mDrawerLayout != null && isDrawerOpen()) {
            inflater.inflate(R.menu.main, menu);
            showGlobalContextActionBar();
        }
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    /**
     * Per the navigation drawer design guidelines, updates the action bar to show the global app
     * 'context', rather than just what's in the current screen.
     */
    private void showGlobalContextActionBar() {
        ActionBar actionBar = getActionBar();
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setTitle(R.string.app_name);
    }

    private ActionBar getActionBar() {
        return ((ActionBarActivity) getActivity()).getSupportActionBar();
    }

    /**
     * Callbacks interface that all activities using this fragment must implement.
     */
    public static interface NavigationDrawerCallbacks {
        /**
         * Called when an item in the navigation drawer is selected.
         */
        void onNavigationDrawerItemSelected(int position);
    }

    public void updateUserInfo() {
        ArrayAdapter<NavItem> adapter = (ArrayAdapter)mDrawerListView1.getAdapter();
        adapter.clear();
        adapter.addAll(getNavList());
        adapter.notifyDataSetChanged();
    }

    public List<NavItem> getNavList() {
        List<NavItem> navItems = new ArrayList<NavItem>();
        navItems.add(new NavItem(getString(R.string.pelotonia), R.drawable.ic_pelotonia));
        User user = ((PelotoniaApplication)getActivity().getApplication()).getUser();
        if (user == null) {
            navItems.add(new NavItem(getString(R.string.nav_my_profile), R.drawable.ic_action_person));
        } else {
            navItems.add(new NavItem(user.getDisplayName(), user.getSmallImageUri()));
        }
        navItems.add(new NavItem(getString(R.string.nav_riders), R.drawable.ic_action_group));
        return navItems;
    }
}
