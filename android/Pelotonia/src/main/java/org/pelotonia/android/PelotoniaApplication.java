package org.pelotonia.android;

import android.app.Application;

import com.socialize.UserUtils;
import com.socialize.entity.User;
import com.socialize.error.SocializeException;

/**
 * Created by ckasek on 2/23/14.
 */
public class PelotoniaApplication extends Application {

    private User user;

    @Override
    public void onCreate() {
        super.onCreate();

    }

    public void setUser(User user) {
        this.user = user;
    }

    public User getUser() {
        return user;
    }
}
