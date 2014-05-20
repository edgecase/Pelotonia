package org.pelotonia.pelotonia.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.TextView;

import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

public class PicassoTextView extends TextView implements Target {

    public PicassoTextView(Context context) {
       super(context);
    }

    public PicassoTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public PicassoTextView(Context context, AttributeSet attrs, int defStyle){
        super(context, attrs, defStyle);
    }

    @Override
    public void onBitmapFailed(Drawable drawable) {
        this.setCompoundDrawables(drawable, null, null, null);
    }

    @Override
    public void onPrepareLoad(Drawable drawable) {
        this.setCompoundDrawables(drawable, null, null, null);
    }

    @Override
    public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
        this.setCompoundDrawables(new BitmapDrawable(getResources(),bitmap), null, null, null);
    }
}
