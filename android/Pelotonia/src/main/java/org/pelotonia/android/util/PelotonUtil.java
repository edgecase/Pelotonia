package org.pelotonia.android.util;


import android.content.Context;
import android.content.SharedPreferences;
import android.os.Environment;

import com.socialize.google.gson.Gson;
import com.socialize.google.gson.reflect.TypeToken;

import org.pelotonia.android.objects.Rider;

import java.io.File;
import java.util.LinkedList;
import java.util.List;

public class PelotonUtil {
    public final static String URL_PREFIX ="https://www.mypelotonia.org/";
    private final static String KEY="pelotonia_settings";
    private final static String RIDER_KEY ="rider";
    private static final String IMG_KEY = "image";
    public static final String imgDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_PICTURES).getPath() + File.separator +  "pelotonia";

    public static Rider getRider(Context context){
        SharedPreferences sharedPref = context.getSharedPreferences(
                KEY, Context.MODE_PRIVATE);
        String riderString = sharedPref.getString(RIDER_KEY,"");
        if(!riderString.isEmpty())
            return new Gson().fromJson(riderString,Rider.class);
        else
            return null;
    }

    public static boolean saveRider(Context context, Rider r) {
        SharedPreferences sharedPref = context.getSharedPreferences(
                KEY, Context.MODE_PRIVATE);

        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString(RIDER_KEY, new Gson().toJson(r));
        return editor.commit();
    }

    public static boolean savedImageList (Context context, List<String> imgList){
        SharedPreferences sharedPref = context.getSharedPreferences(
                KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();

        editor.putString(IMG_KEY, new Gson().toJson(imgList, new TypeToken<List<String>>() {}.getType()));
        return editor.commit();
    }

    public static LinkedList<String> getImageList(Context context){
        LinkedList<String> imgList ;
        SharedPreferences sharedPref = context.getSharedPreferences(
                KEY, Context.MODE_PRIVATE);
        imgList= new Gson().fromJson(sharedPref.getString(IMG_KEY,""),new TypeToken<LinkedList<String>>(){}.getType());

        return imgList;
    }
}
