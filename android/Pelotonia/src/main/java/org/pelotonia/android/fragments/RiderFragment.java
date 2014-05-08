package org.pelotonia.android.fragments;

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialize.CommentUtils;
import com.socialize.entity.Comment;
import com.socialize.entity.Entity;
import com.socialize.entity.ListResult;
import com.socialize.error.SocializeException;
import com.socialize.listener.comment.CommentAddListener;
import com.socialize.listener.comment.CommentListListener;
import com.squareup.picasso.Picasso;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.pelotonia.android.R;
import org.pelotonia.android.activity.MainActivity;
import org.pelotonia.android.adapter.CommentAdapter;
import org.pelotonia.android.objects.Rider;
import org.pelotonia.android.util.JsoupUtils;
import org.pelotonia.android.util.PelotonUtil;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;

import uk.co.senab.actionbarpulltorefresh.library.ActionBarPullToRefresh;
import uk.co.senab.actionbarpulltorefresh.library.PullToRefreshLayout;
import uk.co.senab.actionbarpulltorefresh.library.listeners.OnRefreshListener;
import uk.co.senab.actionbarpulltorefresh.library.viewdelegates.ViewDelegate;

public class RiderFragment extends ListFragment implements
        OnRefreshListener, ViewDelegate {
    private Rider rider = null;
    private List<Comment> commentList = new ArrayList<Comment>();
    private CommentAdapter adapter;
    private PullToRefreshLayout mPullToRefreshLayout;
    private View headerView;
    private Entity entity;
    private MainActivity.FragmentChangeCallback mRiderStoryListener;
    private boolean following = false;
    private static PelotoniaTask task;
    public static RiderFragment newRiderInstance(MainActivity.FragmentChangeCallback listener, Rider rider) {
        RiderFragment fragment = new RiderFragment();
        fragment.rider = rider;
        fragment.mRiderStoryListener = listener;
        fragment.entity = new Entity("https://www.mypelotonia.org/" + fragment.rider.getProfileUrl(), fragment.rider.getName());
        return fragment;
    }

    public static RiderFragment newPelotoniaInstance(MainActivity.FragmentChangeCallback listener) {
        RiderFragment fragment = new RiderFragment();
        fragment.entity = new Entity("http://www.pelotonia.org", "Pelotonia");
        fragment.mRiderStoryListener = listener;
        return fragment;
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("Rider Profile");
    }

    @Override
    public View onCreateView (LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        adapter = new CommentAdapter(getActivity(), R.layout.comment_layout,
                R.id.commentListItemText, commentList);

        // Inflate the layout for this fragment
        final View view = inflater.inflate(R.layout.fragment_pelotonia_wall, container, false);
        if (rider == null) {
            headerView = inflater.inflate(R.layout.fragment_pelotonia, null);
        } else {
            headerView = inflater.inflate(R.layout.fragment_rider, null);
            final Button support = (Button) headerView.findViewById(R.id.support_button);
                support.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        DonateDialogFragment f = new DonateDialogFragment();
                        f.setRider(rider);
                        f.show(getActivity().getSupportFragmentManager(), "Donate");

                    }
                });
                following = PelotonUtil.isFollowing(getActivity(), rider);

                final Button follow = (Button) headerView.findViewById(R.id.follow_button);
                if(!following && rider.getRiderId().equals(PelotonUtil.getRider(getActivity().getApplicationContext()).getRiderId())){
                    follow.setEnabled(false);
                    follow.setVisibility(View.GONE);
                } else {
                    follow.setText(following ? "Unfollow" : "Follow");
                    follow.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (following) {
                                if (PelotonUtil.unfollowRider(getActivity(), rider)) {
                                    following = false;
                                    follow.setText("Follow");
                                }
                            } else {
                                if (PelotonUtil.followRider(getActivity(), rider)) {
                                    following = true;
                                    follow.setText("Unfollow");
                                }
                            }
                        }
                    });
                }

        }
        View hLayout = headerView.findViewById(R.id.header_layout);
        hLayout.setClickable(true);
        hLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRiderStoryListener != null) {
                    mRiderStoryListener.changeFragment(RiderStoryFragment.newRiderInstance(rider), true);
                }
            }
        });

        View dLayout = headerView.findViewById(R.id.donation_progress);
        if (dLayout != null) {
            dLayout.setClickable(true);
            dLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mRiderStoryListener != null) {
                        mRiderStoryListener.changeFragment(RiderDonationsFragment.newInstance(rider), true);
                    }
                }
            });
        }

        if (view != null) {
            mPullToRefreshLayout = (PullToRefreshLayout) view.findViewById(R.id.ptr_layout);

            ActionBarPullToRefresh.from(getActivity())
                    // Here we'll set a custom ViewDelegate
                    .useViewDelegate(RelativeLayout.class, this)
                    .listener(this)
                    .setup(mPullToRefreshLayout);


            ListView commentListView = (ListView) view.findViewById(android.R.id.list);
            commentListView.addHeaderView(headerView);
            commentListView.setClickable(false);

            ImageButton commentButton = (ImageButton) view.findViewById(R.id.commentButton);
            commentButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    final EditText commentText = (EditText) view.findViewById(R.id.commentEditText);
                    if (!commentText.getText().toString().isEmpty()) {

                        CommentUtils.addComment(getActivity(), getEntity(), commentText.getText().toString(), new CommentAddListener() {
                            @Override
                            public void onCreate(Comment result) {
                                commentList.add(0, result);
                                adapter.notifyDataSetChanged();
                                commentText.setText("");
                            }

                            @Override
                            public void onError(SocializeException error) {
                                //TODO display error?
                                Log.e("Chuck", error.toString());
                            }
                        });
                    }
                }
            });
            task = new PelotoniaTask();
            if (rider == null) {
                task.execute("https://www.mypelotonia.org/counter_homepage.jsp");
            } else {
                task.execute("https://www.mypelotonia.org/" + rider.profileUrl);
                ImageView avatar = (ImageView) headerView.findViewById(R.id.rider_avatar);
                Picasso.with(getActivity()).load("https://www.mypelotonia.org/" + rider.getRiderPhotoThumbUrl()).into(avatar);
                TextView headerText = (TextView) headerView.findViewById(R.id.header);
                headerText.setText(rider.name);
                TextView routeText = (TextView) headerView.findViewById(R.id.sub_header);
                routeText.setText(rider.route);
            }
        }
        setListAdapter(adapter);
        return view;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if(task != null)
            task.cancel(true);
    }

    @Override
    public void onRefreshStarted(View view) {

        task = new PelotoniaTask();

        if (rider == null) {

            task.execute("https://www.mypelotonia.org/counter_homepage.jsp");
        } else {
            rider.lastUpdated = Calendar.getInstance();
            rider.lastUpdated.add(Calendar.DAY_OF_MONTH, -2);
            task.execute("https://www.mypelotonia.org/" + rider.profileUrl);
        }
    }

    @Override
    public boolean isReadyForPull(View view, float v, float v2) {
        return (getListView().getFirstVisiblePosition() == 0 && (getListView().getChildCount() == 0 || getListView().getChildAt(0).getTop() == 0));
    }

    private class PelotoniaTask extends AsyncTask<String, Void, Document> {
        private boolean socializeComplete = false;
        private boolean pelotoniaComplete = false;


        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            if (rider != null && rider.lastUpdated == null) {
                Rider tmpRider = PelotonUtil.getRiderById(getActivity(), rider.getRiderId());
                if (tmpRider != null) {
                    rider = tmpRider;
                }
            }
        }


        @Override
        protected Document doInBackground(String... urls) {
            Document doc = null;
            Calendar refreshTime = Calendar.getInstance();
            refreshTime.add(Calendar.DAY_OF_MONTH, -1);

            if (rider == null || rider.lastUpdated == null || rider.lastUpdated.getTime().before(refreshTime.getTime())) {
                doc = JsoupUtils.getDocument(urls[0]);
            }

            if(isCancelled())
                return null;
            CommentUtils.getCommentsByEntity(getActivity(), entity.getKey(), 0, 0, new CommentListListener() {
                @Override
                public void onList(ListResult<Comment> result) {

                    if(isCancelled())
                    return;

                    socializeComplete = true;
                    commentList.clear();
                    commentList.addAll(result.getItems());
                    adapter.notifyDataSetChanged();
                    if (pelotoniaComplete) {
                        mPullToRefreshLayout.setRefreshComplete();
                    }
                }

                @Override
                public void onError(SocializeException error) {
                    Log.e("Chuck", error.toString());
                    socializeComplete = true;
                    if (pelotoniaComplete) {
                        mPullToRefreshLayout.setRefreshComplete();
                    }
                }
            });

            return doc;
        }

        @Override
        protected void onPostExecute(Document doc) {
            if (doc != null) {
                if (rider == null) {
                    int targetAmount = 15000000;

                    Element amountRaisedElement = doc.getElementById("amount-to-date");
                    Element riderCountElement = doc.getElementById("riders");
                    String amountRaisedText = amountRaisedElement.text();
                    TextView raised = (TextView) headerView.findViewById(R.id.raised_amount);
                    Double raisedInt;
                    if (amountRaisedText.startsWith("$")) {
                        raisedInt = Double.valueOf(amountRaisedText.substring(1));
                    } else {
                        raisedInt = Double.valueOf(amountRaisedText);
                    }
                    DecimalFormat formatter = new DecimalFormat("##,###,###");
                    raised.setText("$" + formatter.format(raisedInt));
                    TextView riders = (TextView) headerView.findViewById(R.id.riders_count);
                    riders.setText(riderCountElement.text());
                } else {
                    Element participantDash = doc.select("div.dashboard-participant").first();
                    if (participantDash != null) {
                        Elements years = participantDash.getElementsByTag("img");
                        Iterator<Element> i = years.iterator();
                        rider.riderYears.clear();
                        while (i.hasNext()) {
                            Element year = i.next();
                            rider.riderYears.add(year.attr("alt"));
                        }
                    }
                    Element dash = doc.select("div.dashboard-status").first();
                    if (dash != null) {
                        String tmp1 = dash.select("dd").get(1).text();
                        tmp1 = tmp1.substring(tmp1.indexOf("$"));
                        tmp1 = tmp1.replaceAll(",", "");
                        rider.setAmountRaised(Double.parseDouble(tmp1.substring(1)));
                    } else {
                        rider.setAmountRaised(0);
                    }
                    if (rider.isHighRoller()) {
                        rider.setAmountPledged(4000);
                    } else {
                        Element meter = doc.getElementsByClass("meter-inner").first();
                        if (meter != null) {
                            Elements meterRows = meter.select("td.label");
                            String tmp = meterRows.get(1).text();
                            tmp = tmp.substring(tmp.indexOf("$"));
                            //tmp = tmp.replaceAll(",", "");
                            tmp = tmp.replaceAll("[^\\d]","");
                           try {
                               rider.setAmountPledged(Double.parseDouble(tmp.substring(1)));
                           }
                           catch(NumberFormatException nfe){
                               //fallback to  0
                               rider.setAmountPledged(0);
                           }
                        } else {
                            rider.setAmountPledged(0);
                        }
                    }

                    Element storyElement = doc.select("div.story").first();
                    if (storyElement != null) {
                        rider.setStory(storyElement.html().replaceAll("<br />", "\n"));
                    }

                    Element donorTable = doc.select("table.donor-list").first();
                    rider.getDonors().clear();
                    if (donorTable != null) {
                        Elements donorRows = donorTable.getElementsByTag("tr");

                        Iterator<Element> i = donorRows.iterator();
                        // skip the header row
                        i.next();
                        while (i.hasNext()) {
                            Element row = i.next();
                            Rider.Donor donor = rider.new Donor();
                            donor.name = row.select("td.name").first().text();
                            donor.amount = row.select("td.amount").first().text();
                            donor.date = row.select("td.date").first().text();
                            rider.addDonor(donor);
                        }
                    }
                    rider.lastUpdated = Calendar.getInstance();
                    PelotonUtil.saveRiderById(getActivity(), rider);
                }
            }
            pelotoniaComplete = true;
            if (socializeComplete) {
                mPullToRefreshLayout.setRefreshComplete();
            }
            if (rider != null) {
                TextView tv = (TextView) headerView.findViewById(R.id.raised);
                TextView tv2 = (TextView) headerView.findViewById(R.id.progressBar_text);
                ProgressBar progress = (ProgressBar) headerView.findViewById(R.id.progressBar);
                NumberFormat formatter = NumberFormat.getCurrencyInstance();
                if (rider.amountPledged > 0) {
                    tv.setText(formatter.format(rider.amountRaised) + " of " + formatter.format(rider.amountPledged));
                    progress.setMax(rider.amountPledged.intValue());
                    progress.setProgress(rider.amountRaised.intValue());
                    tv2.setText(NumberFormat.getPercentInstance().format(rider.amountRaised / rider.amountPledged));
                    progress.setVisibility(View.VISIBLE);
                    tv2.setVisibility(View.VISIBLE);
                } else {
                    tv.setText(formatter.format(rider.amountRaised));
                    progress.setVisibility(View.INVISIBLE);
                    tv2.setVisibility(View.GONE);
                }
                if (rider.riderYears.contains("2009")) {
                    headerView.findViewById(R.id.rider_2009).setVisibility(View.VISIBLE);
                } else {
                    headerView.findViewById(R.id.rider_2009).setVisibility(View.GONE);
                }
                if (rider.riderYears.contains("2010")) {
                    headerView.findViewById(R.id.rider_2010).setVisibility(View.VISIBLE);
                } else {
                    headerView.findViewById(R.id.rider_2010).setVisibility(View.GONE);
                }
                if (rider.riderYears.contains("2011")) {
                    headerView.findViewById(R.id.rider_2011).setVisibility(View.VISIBLE);
                } else {
                    headerView.findViewById(R.id.rider_2011).setVisibility(View.GONE);
                }
                if (rider.riderYears.contains("2012")) {
                    headerView.findViewById(R.id.rider_2012).setVisibility(View.VISIBLE);
                } else {
                    headerView.findViewById(R.id.rider_2012).setVisibility(View.GONE);
                }
                if (rider.riderYears.contains("2013")) {
                    headerView.findViewById(R.id.rider_2013).setVisibility(View.VISIBLE);
                } else {
                    headerView.findViewById(R.id.rider_2013).setVisibility(View.GONE);
                }
                if (rider.riderYears.contains("2014")) {
                    headerView.findViewById(R.id.rider_2014).setVisibility(View.VISIBLE);
                } else {
                    headerView.findViewById(R.id.rider_2014).setVisibility(View.GONE);
                }
            }
        }
    }

    private Entity getEntity() {
        return entity;
    }
}
