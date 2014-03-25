package org.pelotonia.android.objects;

import java.util.List;
import java.util.Vector;

public class Rider {

    public String name;
    public String riderId;
    public String riderPhotoThumbUrl;
    public String donateUrl;
    public String profileUrl;
    public String riderType;
    public String route;
    public boolean highRoller;
    public boolean livingProof;
    public String story;
    public Double amountRaised;
    public Double amountPledged;

    private List<Donor> donors = new Vector<Donor>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRiderId() {
        return riderId;
    }

    public void setRiderId(String riderId) {
        this.riderId = riderId;
    }

    public String getRiderPhotoThumbUrl() {
        return riderPhotoThumbUrl;
    }

    public void setRiderPhotoThumbUrl(String riderPhotoThumbUrl) {
        this.riderPhotoThumbUrl = riderPhotoThumbUrl;
    }

    public String getDonateUrl() {
        return donateUrl;
    }

    public void setDonateUrl(String donateUrl) {
        this.donateUrl = donateUrl;
    }

    public String getProfileUrl() {
        return profileUrl;
    }

    public void setProfileUrl(String profileUrl) {
        this.profileUrl = profileUrl;
    }

    public String getRiderType() {
        return riderType;
    }

    public void setRiderType(String riderType) {
        this.riderType = riderType;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }

    public String getStory() {
        return story;
    }

    public void setStory(String story) {
        this.story = story;
    }

    public boolean isHighRoller() {
        return highRoller;
    }

    public void setHighRoller(boolean highRoller) {
        this.highRoller = highRoller;
    }

    public boolean isLivingProof() {
        return livingProof;
    }

    public void setLivingProof(boolean livingProof) {
        this.livingProof = livingProof;
    }

    public double getAmountRaised() {
        return amountRaised;
    }

    public void setAmountRaised(double amountRaised) {
        this.amountRaised = amountRaised;
    }

    public double getAmountPledged() {
        return amountPledged;
    }

    public void setAmountPledged(double amountPledged) {
        this.amountPledged = amountPledged;
    }

    public void addDonor(Donor donor) {
        donors.add(donor);
    }

    public List<Donor> getDonors() {
        return donors;
    }

    public class Donor {
        public String date;
        public String name;
        public String amount;

        @Override
        public String toString() {
            return name + " donated " + amount + " on " + date;
        }
    }
}
