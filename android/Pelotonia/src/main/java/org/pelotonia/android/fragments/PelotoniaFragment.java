package org.pelotonia.android.fragments;



import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.socialize.CommentUtils;
import com.socialize.api.action.user.SocializeUserUtils;
import com.socialize.entity.Comment;
import com.socialize.entity.Entity;
import com.socialize.entity.ListResult;
import com.socialize.error.SocializeException;
import com.socialize.listener.comment.CommentAddListener;
import com.socialize.listener.comment.CommentListListener;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.pelotonia.android.R;
import org.pelotonia.android.adapter.CommentAdapter;
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
public class PelotoniaFragment extends ListFragment implements
        OnRefreshListener, ViewDelegate {
    private final Entity entity = new Entity("https://www.mypelotonia.org/riders_profile.jsp?MemberID=4111&SearchStart=0&PAGING", "Pelotonia");
    private List<Comment> commentList = new ArrayList<Comment>();
    private CommentAdapter adapter;
    private PullToRefreshLayout mPullToRefreshLayout;
    private View headerView;

    public PelotoniaFragment() {
        // Required empty public constructor

    }


    @Override
    public View onCreateView (LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        adapter = new CommentAdapter(getActivity(), R.layout.comment_layout,
                R.id.commentListItemText, commentList);

        // Inflate the layout for this fragment
        final View view = inflater.inflate(R.layout.fragment_pelotonia_wall, container, false);

        headerView = inflater.inflate(R.layout.fragment_pelotonia, null);

        if (view != null) {
            mPullToRefreshLayout = (PullToRefreshLayout) view.findViewById(R.id.ptr_layout);

            ActionBarPullToRefresh.from(getActivity())
                    // Here we'll set a custom ViewDelegate
                    .useViewDelegate(RelativeLayout.class, this)
                    .listener(this)
                    .setup(mPullToRefreshLayout);


            ListView commentListView = (ListView) view.findViewById(android.R.id.list);
            commentListView.addHeaderView(headerView);

            commentListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    Comment comment = (Comment)adapter.getItem(position);
                    SocializeUserUtils utils = new SocializeUserUtils();
                    utils.showUserProfileView(getActivity(), comment.getUser(), comment, null);
                }
            });

            commentListView.setOnScrollListener(new AbsListView.OnScrollListener() {
                @Override
                public void onScrollStateChanged(AbsListView view, int scrollState) {

                }

                @Override
                public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

                }
            });

            ImageButton commentButton = (ImageButton) view.findViewById(R.id.commentButton);
            commentButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    final EditText commentText = (EditText) view.findViewById(R.id.commentEditText);
                    if (!commentText.getText().toString().isEmpty()) {

                        CommentUtils.addComment(getActivity(), entity, commentText.getText().toString(), new CommentAddListener() {
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

            new PelotoniaTask().execute("https://www.mypelotonia.org/counter_homepage.jsp");
        }
        setListAdapter(adapter);
        return view;
    }

    @Override
    public void onRefreshStarted(View view) {
        new PelotoniaTask().execute("https://www.mypelotonia.org/counter_homepage.jsp");
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
                int targetAmount = 15000000;

                Element amountRaisedElement = doc.getElementById("amount-to-date");
                Element riderCountElement = doc.getElementById("riders");
                String amountRaisedText = amountRaisedElement.text();
                TextView raised = (TextView)headerView.findViewById(R.id.raised_amount);
                Double raisedInt;
                if (amountRaisedText.startsWith("$")) {
                    raisedInt = Double.valueOf(amountRaisedText.substring(1));
                } else {
                    raisedInt = Double.valueOf(amountRaisedText);
                }
                DecimalFormat formatter = new DecimalFormat("##,###,###");
                raised.setText("$" + formatter.format(raisedInt));
                TextView riders = (TextView)headerView.findViewById(R.id.riders_count);
                riders.setText(riderCountElement.text());

                pelotoniaComplete = true;
                if (socializeComplete) {
                    mPullToRefreshLayout.setRefreshComplete();
                }
            }
        }
    }
}
