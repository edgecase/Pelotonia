package org.pelotonia.android.fragments;

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v7.app.ActionBarActivity;
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

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
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

    public static RiderFragment newRiderInstance(MainActivity.FragmentChangeCallback listener, Rider rider) {
        RiderFragment fragment = new RiderFragment();
        fragment.rider = rider;
        fragment.mRiderStoryListener = listener;
        fragment.entity = new Entity("https://www.mypelotonia.org/" + fragment.rider.getProfileUrl(), fragment.rider.getName());
        return fragment;
    }

    public static RiderFragment newPelotoniaInstance(MainActivity.FragmentChangeCallback listener) {
        RiderFragment fragment = new RiderFragment();
        fragment.entity = new Entity("https://www.pelotonia.org", "Pelotonia");
        fragment.mRiderStoryListener = listener;
        return fragment;
    }

    @Override
    public void onResume() {
        super.onResume();
        ((ActionBarActivity)getActivity()).getSupportActionBar().setTitle("Profile");
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
            Button button = (Button) headerView.findViewById(R.id.support_button);
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    DonateDialogFragment f = new DonateDialogFragment();
                    f.show(getActivity().getSupportFragmentManager(), "Donate");
                }
            });
        }
        View hLayout = headerView.findViewById(R.id.header_layout);
        hLayout.setClickable(true);
        hLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRiderStoryListener != null) {
                    mRiderStoryListener.changeFragment(RiderStoryFragment.newRiderInstance(rider));
                }
            }
        });

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
                            }
                        });
                    }
                }
            });
            if (rider == null) {
                new PelotoniaTask().execute("https://www.mypelotonia.org/counter_homepage.jsp");
            } else {
                new PelotoniaTask().execute("https://www.mypelotonia.org/" + rider.profileUrl);
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
    public void onRefreshStarted(View view) {
        if (rider == null) {
            new PelotoniaTask().execute("https://www.mypelotonia.org/counter_homepage.jsp");
        } else {
            new PelotoniaTask().execute("https://www.mypelotonia.org/" + rider.profileUrl);
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
        protected Document doInBackground(String... urls) {
            Document doc = JsoupUtils.getDocument(urls[0]);
            CommentUtils.getCommentsByEntity(getActivity(), entity.getKey(), 0, 0, new CommentListListener() {
                @Override
                public void onList(ListResult<Comment> result) {
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
                    Element dash = doc.select("div.dashboard-status").first();
                    if (dash != null) {
                        String tmp1 = dash.select("dd").get(1).text();
                        tmp1 = tmp1.substring(tmp1.indexOf("$"));
                        tmp1 = tmp1.replaceAll(",", "");
                        rider.setAmountRaised(Double.parseDouble(tmp1.substring(1)));
                    } else {
                        rider.setAmountRaised(0);
                    }

                    Element meter = doc.getElementsByClass("meter-inner").first();
                    if (meter != null) {
                        Elements meterRows = meter.select("td.label");
                        String tmp = meterRows.get(1).text();
                        tmp = tmp.substring(tmp.indexOf("$"));
                        tmp = tmp.replaceAll(",","");
                        rider.setAmountPledged(Double.parseDouble(tmp.substring(1)));
                    } else {
                        rider.setAmountPledged(0);
                    }

                    Element storyElement = doc.select("div.story").first();
                    if (storyElement != null) {
                        rider.setStory(storyElement.html().replaceAll("<br />", "\n"));
                    }

                    Element donorTable = doc.select("table.donor-list").first();
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

                    TextView tv = (TextView) headerView.findViewById(R.id.raised);
                    NumberFormat formatter = NumberFormat.getCurrencyInstance();
                    tv.setText(formatter.format(rider.amountRaised) + " of " + formatter.format(rider.amountPledged));

                    ProgressBar progress = (ProgressBar) headerView.findViewById(R.id.progressBar);
                    progress.setProgress(rider.amountRaised.intValue());
                    progress.setMax(rider.amountPledged.intValue());

                    TextView tv2 = (TextView) headerView.findViewById(R.id.progressBar_text);
                    tv2.setText(NumberFormat.getPercentInstance().format(rider.amountRaised / rider.amountPledged));
                }
                pelotoniaComplete = true;
                if (socializeComplete) {
                    mPullToRefreshLayout.setRefreshComplete();
                }
            }
        }
    }

    private Entity getEntity() {
        return entity;
    }
}
