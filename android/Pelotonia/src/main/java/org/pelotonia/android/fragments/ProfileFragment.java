package org.pelotonia.android.fragments;

import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.socialize.CommentUtils;
import com.socialize.UserUtils;
import com.socialize.entity.Comment;
import com.socialize.entity.ListResult;
import com.socialize.entity.User;
import com.socialize.error.SocializeException;
import com.socialize.listener.comment.CommentListListener;
import com.squareup.picasso.Picasso;

import org.pelotonia.android.adapter.CommentAdapter;
import org.pelotonia.android.R;

public class ProfileFragment extends Fragment {

    private User user;
    private ListView commentList;

    public ProfileFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            user = UserUtils.getCurrentUser(getActivity());
        } catch (SocializeException e) {
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        TextView nameView = (TextView) view.findViewById(R.id.nameTextView);
        nameView.setText(user.getDisplayName());

        TextView descView = (TextView) view.findViewById(R.id.titleTextView);
        descView.setText(user.getDescription());

        ImageView avatarImage = (ImageView) view.findViewById(R.id.avatarImageView);
        Picasso.with(getActivity()).load(user.getSmallImageUri()).into(avatarImage);

        View profileLayout = view.findViewById(R.id.profileLayout);
        profileLayout.setClickable(true);
        profileLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                UserUtils.showUserSettings(getActivity());
            }
        });

        commentList = (ListView) view.findViewById(R.id.commentsList);

        CommentUtils.getCommentsByUser(getActivity(), user,0,0,new CommentListListener() {
            @Override
            public void onList(ListResult<Comment> result) {

                commentList.setAdapter(new CommentAdapter(getActivity(), R.layout.comment_layout,
                        R.id.commentListItemText,
                        result.getItems()));
            }

            @Override
            public void onError(SocializeException error) {

            }
        });

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
