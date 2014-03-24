package org.pelotonia.android.fragments;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.squareup.picasso.Picasso;

import org.pelotonia.android.R;
import org.pelotonia.android.adapter.ImageAdapter;
import org.pelotonia.android.objects.Rider;
import org.pelotonia.android.util.PelotonUtil;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;

public class ProfileFragment extends Fragment {

    private static final int MAX_IMG=3;
    public ProfileFragment() {
        // Required empty public constructor
    }

    private Rider user;
    public static Fragment newInstance(){
        ProfileFragment f = new ProfileFragment();
        return f;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        Rider r = PelotonUtil.getRider(getActivity().getApplicationContext());
        // TODO: handle the case when there is no rider has been selected yet
        if (r == null){
            user = new Rider();
            user.amountRaised= "100.00";
            user.name = "Test Mark Harris";
            user.route= "Columbus to Gambier and Back";
            user.riderPhotoThumbUrl="https://www.mypelotonia.org/images/RiderPics/4111.jpg";
            user.story ="I am a user story Meooowth meow";
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        TextView nameView = (TextView) view.findViewById(R.id.nameTextView);
        nameView.setText(user.getName());

        TextView descView = (TextView) view.findViewById(R.id.titleTextView);
        descView.setText(user.getRoute());

        ImageView avatarImage = (ImageView) view.findViewById(R.id.avatarImageView);
        Picasso.with(getActivity()).load(user.getRiderPhotoThumbUrl()).into(avatarImage);

        return view;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        ImageButton takePic = (ImageButton) view.findViewById(R.id.takePic);
        takePic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dispatchTakePictureIntent();
            }
        });

        View header = (View) view.findViewById(R.id.rider_header);
        header.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //TODO: pop up the description
                Toast.makeText(getActivity(),"Display description", Toast.LENGTH_SHORT).show();
            }
        });

        imgList = PelotonUtil.getImageList(getActivity());

        if (imgList == null)
            imgList= new LinkedList<String>();

        g = (GridView) getActivity().findViewById(R.id.rider_gallery);
        imgAdapter= new ImageAdapter(getActivity(),imgList);
        Log.d("Simba", "Setting adapter");
        g.setAdapter(imgAdapter);

        g.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                Uri uri = Uri.parse("file://" + imgList.get(i));
                Intent photoIntent = new Intent();
                photoIntent.setDataAndType(uri, "image/*");
                photoIntent.setAction(Intent.ACTION_VIEW);
                startActivity(photoIntent);
           }
        });
    }

    private static final int REQUEST_IMAGE_CAPTURE = 1;
    private String imagePath;
    private void dispatchTakePictureIntent() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getActivity().getPackageManager()) != null) {

            File photoFile = null;
            try {
                photoFile = createImageFile();
            } catch (IOException ex) {
                // Error occurred while creating the File
            }
            // Continue only if the File was successfully created
            if (photoFile != null) {
                imagePath = /*"file: " +*/photoFile.getAbsolutePath();
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                        Uri.fromFile(photoFile)); 

                startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
            }
        }
        else{
            Toast.makeText(getActivity(),"Your device doesn\'t support any camera feature", Toast.LENGTH_SHORT).show();
        }

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == Activity.RESULT_OK) {
            displayImage();
        }
    }

    private LinkedList<String> imgList;
    private GridView g = null;
    private ImageAdapter imgAdapter = null;
    private String mCurrentPhotoPath=null;
    private void displayImage(){
        if(imgList.size()>= MAX_IMG){
            imgList.removeLast();
        }
        imgList.addFirst(imagePath);
        PelotonUtil.savedImageList(getActivity(), imgList);
        Log.d("Simba", "notify data set CHanged");
        imgAdapter.notifyDataSetChanged();
    }

    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + ".jpg";
        File storeDir = new File(PelotonUtil.imgDir);
        if (!storeDir.exists()) {
            storeDir.mkdirs();
        }
        return new File(storeDir, imageFileName);
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
//    public interface OnFragmentInteractionListener {
//        // TODO: Update argument type and name
//        public void onFragmentInteraction(Uri uri);
//    }
}
