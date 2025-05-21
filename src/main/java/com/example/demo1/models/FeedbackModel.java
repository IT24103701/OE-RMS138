package com.example.demo1.models;

public class FeedbackModel extends BaseEntitiy {
    private String message;
    private String feedback;
    private int rating;

    public FeedbackModel() {
    }

    public FeedbackModel(String message, String feedback, int rating) {
        this.message = message;
        this.feedback = feedback;
        this.rating = rating;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }


    public int compareTo(FeedbackModel other) {
        return Integer.compare(this.getRating(), other.getRating());
    }
}