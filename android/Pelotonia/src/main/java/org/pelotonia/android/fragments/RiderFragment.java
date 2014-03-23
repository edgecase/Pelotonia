package org.pelotonia.android.fragments;

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialize.CommentUtils;
import com.socialize.api.action.user.SocializeUserUtils;
import com.socialize.entity.Comment;
import com.socialize.entity.Entity;
import com.socialize.entity.ListResult;
import com.socialize.error.SocializeException;
import com.socialize.google.gson.Gson;
import com.socialize.listener.comment.CommentAddListener;
import com.socialize.listener.comment.CommentListListener;
import com.squareup.picasso.Picasso;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.pelotonia.android.R;
import org.pelotonia.android.adapter.CommentAdapter;
import org.pelotonia.android.objects.Rider;
import org.pelotonia.android.util.JsoupUtils;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import uk.co.senab.actionbarpulltorefresh.library.ActionBarPullToRefresh;
import uk.co.senab.actionbarpulltorefresh.library.PullToRefreshLayout;
import uk.co.senab.actionbarpulltorefresh.library.listeners.OnRefreshListener;
import uk.co.senab.actionbarpulltorefresh.library.viewdelegates.ViewDelegate;

/**
 * A simple {@link android.support.v4.app.Fragment} subclass.
 *
 */
public class RiderFragment extends ListFragment implements
        OnRefreshListener, ViewDelegate {
    private Rider rider = null;
    private List<Comment> commentList = new ArrayList<Comment>();
    private CommentAdapter adapter;
    private PullToRefreshLayout mPullToRefreshLayout;
    private View headerView;
    private Entity entity;

    public static RiderFragment newRiderInstance(String riderJson) {
        RiderFragment fragment = new RiderFragment();
        Gson gson = new Gson();
        fragment.rider = gson.fromJson(riderJson, Rider.class);
        fragment.entity = new Entity("https://www.mypelotonia.org/" + fragment.rider.getProfileUrl(), fragment.rider.getName());
        return fragment;
    }

    public static RiderFragment newPelotoniaInstance() {
        RiderFragment fragment = new RiderFragment();
        fragment.entity = new Entity("http://www.pelotonia.org", "Pelotonia");
        return fragment;
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
            Log.d("Chuck", entity.getKey());
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
                    Log.e("Chuck", error.getMessage());
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
                    // TODO parse rider profile page
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
