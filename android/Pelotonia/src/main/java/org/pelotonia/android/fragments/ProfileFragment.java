package org.pelotonia.android.fragments;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.text.format.DateUtils;
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
import org.pelotonia.android.objects.WorkOut;
import org.pelotonia.android.util.PelotonUtil;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;

public class ProfileFragment extends Fragment {
     //TODO: remove simba log
    private static final int MAX_IMG=3;
    public ProfileFragment() {
        // Required empty public constructor
    }

    private Rider user;
    public static Fragment newInstance(){
        ProfileFragment f = new ProfileFragment();
        return f;
    }

    SearchFragment searchFragment;
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        user = PelotonUtil.getRider(getActivity().getApplicationContext());
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
        Picasso.with(getActivity()).load(PelotonUtil.URL_PREFIX+user.getRiderPhotoThumbUrl()).into(avatarImage);

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

        //TODO: uncomment me once nested work
        //imgList = PelotonUtil.getImageList(getActivity());

        if (imgList == null)
            imgList= new LinkedList<String>();

        g = (GridView) getActivity().findViewById(R.id.rider_gallery);
        imgAdapter= new ImageAdapter(getActivity(),imgList);

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

        // Mock for now
        WorkOut latestWorkout = new WorkOut( WorkOut.Excercise.RIDING, System.currentTimeMillis() , 100, 4000);
        TextView dateText = (TextView) view.findViewById(R.id.rider_date);
        dateText.setText(DateUtils.formatDateTime(getActivity(),latestWorkout.date,DateUtils.FORMAT_SHOW_DATE));
        TextView milesText = (TextView) view.findViewById(R.id.rider_miles);
        milesText.setText(String.valueOf(latestWorkout.miles));
        TextView duration = (TextView) view.findViewById(R.id.rider_duration);
        duration.setText(DateUtils.formatElapsedTime(new StringBuilder("H:MM"),latestWorkout.elapsedTime));
        //TODO: Set the proper image type on imageview workout!

        /*
            Go to workout History Fragment
            TODO: Use nested Fragment ??
         */

        ImageButton workOutHistory = (ImageButton) view.findViewById(R.id.workOutHistory);
        workOutHistory.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //TODO:
                // call the right delegate
            }
        });

        //TODO: Convert to proper date Time format
        duration.setText(DateUtils.formatElapsedTime(new StringBuilder("H:MM"),latestWorkout.elapsedTime));
        Log.d("Simba", "Duration: " +duration.getText().toString());
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
                imagePath = photoFile.getAbsolutePath();
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

}
