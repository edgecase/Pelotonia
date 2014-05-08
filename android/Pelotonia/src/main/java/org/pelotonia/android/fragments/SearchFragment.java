package org.pelotonia.android.fragments;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v7.app.ActionBarActivity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.pelotonia.android.R;
import org.pelotonia.android.activity.MainActivity;
import org.pelotonia.android.adapter.RiderListAdapter;
import org.pelotonia.android.objects.Rider;
import org.pelotonia.android.util.JsoupUtils;
import org.pelotonia.android.util.PelotonUtil;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class SearchFragment extends ListFragment {


    private static boolean saveProfile =false;

    public static SearchFragment newInstance(MainActivity.FragmentChangeCallback listener, boolean setProfile) {
        saveProfile = setProfile;
        SearchFragment fragment = new SearchFragment();
        fragment.mCallbackListener = listener;
        return fragment;
    }

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public SearchFragment() {
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("Find Riders");
    }

    RiderListAdapter adapter;
    List<Rider> searchList= new ArrayList<Rider>();
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        adapter = new RiderListAdapter(getActivity(), R.layout.comment_layout,
                R.id.commentListItemText, searchList);
        setListAdapter(adapter);

        final View view = inflater.inflate(R.layout.fragment_search,container,false);

        EditText editText = (EditText) view.findViewById(R.id.search_text);
        editText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    if (v.getText().length() > 0) {
                        new SearchTask().execute(v.getText().toString());
                        InputMethodManager imm = (InputMethodManager)getActivity().getSystemService(
                                Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                    }
                    return true;
                }
                return false;
            }
        });

        ImageButton searchBtn = (ImageButton) view.findViewById(R.id.search_button);
        searchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                EditText input  = (EditText)getView().findViewById(R.id.search_text);
                if (input.getText().length()>0) {
                    new SearchTask().execute(input.getText().toString());
                    InputMethodManager imm = (InputMethodManager)getActivity().getSystemService(
                            Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(input.getWindowToken(), 0);
                }
            }
        });

        return view;
    }

    private class SearchTask extends AsyncTask <String, Void, List<Rider>> {

        final String url = "https://www.mypelotonia.org/riders_searchresults.jsp?Rider&RIDERS&RideDistance=&LastName=";
        //TODO: Progressbar UI show busy search
        ProgressDialog progressDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            progressDialog = new ProgressDialog(getActivity());
            progressDialog.setCancelable(false);
            progressDialog.setIndeterminate(true);
            progressDialog.setMessage("Searching...");
            progressDialog.show();
        }

        @Override
        protected List<Rider> doInBackground(String... name) {
           Document doc = JsoupUtils.getDocument(url + name[0]);
            List<Rider> riders = new ArrayList<Rider>();
            if (doc != null) {
                Element table = doc.getElementById("search-results");
                Elements tableRows = table.getElementsByTag("tr");
                Iterator<Element> i = tableRows.iterator();
                i.next();
                while (i.hasNext()) {
                    Element tableRow = i.next();
                    Rider rider = new Rider();
                    Element photoRow = tableRow.select("td.photo").first();
                    if (photoRow != null) {
                        rider.setName(photoRow.select("img").first().attr("alt"));
                        rider.setProfileUrl(photoRow.select("a").first().attr("href"));
                        rider.setRiderPhotoThumbUrl(photoRow.select("img").first().attr("src"));
                    }
                    Element typeRow = tableRow.select("td.type").first();
                    if (typeRow != null) {
                        rider.setRiderType(typeRow.select("img").attr("alt"));
                    }
                    Element proofRow = tableRow.select("td.living-proof").first();
                    if (proofRow != null) {
                        rider.setLivingProof(proofRow.select("img").size() > 0);
                    }
                    Element rollerRow = tableRow.select("td.high-roller").first();
                    if (rollerRow != null) {
                        rider.setHighRoller(rollerRow.select("img").size() > 0);
                    }
                    Element donateRow = tableRow.select("a.btn-donate").first();
                    if (donateRow != null) {
                        rider.setDonateUrl(donateRow.attr("href"));
                    }
                    Element routeRow = tableRow.select("td.route").first();
                    if (routeRow != null) {
                        rider.setRoute(routeRow.text());
                    }
                    Element idRow = tableRow.select("td.id").first();
                    if (idRow != null) {
                        rider.setRiderId(idRow.text());
                    }
                    riders.add(rider);
                }

            }
            return riders;
        }
        @Override
        protected void onPostExecute(List<Rider> searchResult) {
            searchList.clear();
            if(searchResult.size()>0)
                searchList.addAll(searchResult);
            else {
                TextView tv = (TextView) getView().findViewById(android.R.id.empty);
                tv.setText("No Result found");
            }

            adapter.notifyDataSetChanged();
            progressDialog.dismiss();
        }
    }

    MainActivity.FragmentChangeCallback mCallbackListener;

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        Rider r = adapter.getItem(position);
        if(saveProfile)
            PelotonUtil.saveRider(getActivity().getApplicationContext(),r);

        mCallbackListener.changeFragment(RiderFragment.newRiderInstance(mCallbackListener, r));
    }
}
