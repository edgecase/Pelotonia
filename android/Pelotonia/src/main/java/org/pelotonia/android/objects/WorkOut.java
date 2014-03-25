package org.pelotonia.android.objects;

public class WorkOut {

    public WorkOut (Excercise e, long d, int mil, long record){
        type =e; date = d; miles =mil; elapsedTime = record;
    }
    public enum Excercise {RIDING, RUNNING, OTHER};
    public Excercise type;
    public long date;
    public int miles;
    public long elapsedTime;
}
