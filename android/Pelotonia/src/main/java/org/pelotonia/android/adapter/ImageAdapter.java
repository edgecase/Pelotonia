package org.pelotonia.android.adapter;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;

import java.util.List;

public class ImageAdapter extends BaseAdapter {

    private Context context;
    private static final int MAX_SIZE = 250;
    private List<String> imageList;
    public ImageAdapter(Context context, List<String> source){
        this.context = context;
        this.imageList = source;
    }
    @Override
    public int getCount() {
        return imageList.size();
    }

    @Override
    public Object getItem(int i) {
        return imageList.get(i);
    }

    @Override
    public long getItemId(int i) {
        return 0;
    }

    // create a new ImageView for each item referenced by the Adapter
    public View getView(int position, View convertView, ViewGroup parent) {
        ImageView imageView;
        if (convertView == null) {  // if it's not recycled, initialize some attributes
            imageView = new ImageView(context);
            imageView.setLayoutParams(new GridView.LayoutParams(MAX_SIZE, MAX_SIZE));
            imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            imageView.setPadding(8, 8, 8, 8);


        } else {
            imageView = (ImageView) convertView;
        }
        imageView.setImageBitmap(getPic(MAX_SIZE,MAX_SIZE, (String) getItem(position)));

        return imageView;
    }

    /*
     Helper to avoid Out of Memory Exception
     */
    private Bitmap getPic(int width, int height, String imagePath) {

        int maxWidth = context.getResources().getDisplayMetrics().widthPixels;

        // Get the dimensions of the View
        int targetW = (maxWidth/3)-10;


        // Get the dimensions of the bitmap
        BitmapFactory.Options bmOptions = new BitmapFactory.Options();
        bmOptions.inJustDecodeBounds = true;

        BitmapFactory.decodeFile(imagePath, bmOptions);
        int photoW = bmOptions.outWidth;
        int photoH = bmOptions.outHeight;

        // Determine how much to scale down the image
        int scaleFactor = Math.min(photoW/targetW, photoH/targetW);

        // Decode the image file into a Bitmap sized to fill the View
        bmOptions.inJustDecodeBounds = false;
        bmOptions.inSampleSize = scaleFactor;
        bmOptions.inPurgeable = true;

        Bitmap bitmap = BitmapFactory.decodeFile(imagePath, bmOptions);
        if(bitmap == null)
            Log.e("Simba", "bitmap is NULL");
        return bitmap;
    }
}
