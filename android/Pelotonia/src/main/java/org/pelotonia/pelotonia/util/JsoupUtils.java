package org.pelotonia.pelotonia.util;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import java.io.IOException;

/**
 * Created by ckasek on 3/9/14.
 */
public class JsoupUtils {

    public static Document getDocument(String url) {
        try {
            return Jsoup.connect(url).get();
        } catch (IOException ex) {
            return null;
        }
    }
}
