package com.example.demo1.services;

import com.example.demo1.models.FeedbackModel;
import com.example.demo1.utils.CustomLinkedList;
import com.example.demo1.utils.SelectionSort;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class FeedbackService {
    private static final String FILE_PATH = "feedback.txt";
    private static final String DELIMITER = ",";

    public FeedbackService() {
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
            }
        }
    }

    public boolean createFeedback(FeedbackModel feedback) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            List<FeedbackModel> feedbacks = getAllFeedbacks();
            int maxId = 0;
            for (FeedbackModel f : feedbacks) {
                if (f.getId() > maxId) {
                    maxId = f.getId();
                }
            }
            feedback.setId(maxId + 1);

            String line = feedback.getId() + DELIMITER +
                    feedback.getMessage() + DELIMITER +
                    feedback.getFeedback() + DELIMITER +
                    feedback.getRating();
            writer.write(line);
            writer.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error creating feedback: " + e.getMessage());
            return false;
        }
    }

    public List<FeedbackModel> getAllFeedbacks() {
        List<FeedbackModel> feedbacks = new ArrayList<>();
        File file = new File(FILE_PATH);

        if (!file.exists()) {
            try {
                file.createNewFile();
                return feedbacks;
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
                return feedbacks;
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(DELIMITER);
                if (parts.length == 4) {
                    FeedbackModel feedback = new FeedbackModel();
                    feedback.setId(Integer.parseInt(parts[0]));
                    feedback.setMessage(parts[1]);
                    feedback.setFeedback(parts[2]);
                    feedback.setRating(Integer.parseInt(parts[3]));
                    feedbacks.add(feedback);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading feedbacks: " + e.getMessage());
        }
        return feedbacks;
    }

    public FeedbackModel getFeedbackById(int id) {
        List<FeedbackModel> feedbacks = getAllFeedbacks();
        for (FeedbackModel feedback : feedbacks) {
            if (feedback.getId() == id) {
                return feedback;
            }
        }
        return null;
    }

    public boolean updateFeedback(FeedbackModel updatedFeedback) {
        List<FeedbackModel> feedbacks = getAllFeedbacks();
        boolean found = false;

        for (FeedbackModel feedback : feedbacks) {
            if (feedback.getId() == updatedFeedback.getId()) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (FeedbackModel feedback : feedbacks) {
                if (feedback.getId() == updatedFeedback.getId()) {
                    String line = updatedFeedback.getId() + DELIMITER +
                            updatedFeedback.getMessage() + DELIMITER +
                            updatedFeedback.getFeedback() + DELIMITER +
                            updatedFeedback.getRating();
                    writer.write(line);
                } else {
                    String line = feedback.getId() + DELIMITER +
                            feedback.getMessage() + DELIMITER +
                            feedback.getFeedback() + DELIMITER +
                            feedback.getRating();
                    writer.write(line);
                }
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error updating feedback: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteFeedback(int id) {
        List<FeedbackModel> feedbacks = getAllFeedbacks();
        boolean found = false;

        for (FeedbackModel feedback : feedbacks) {
            if (feedback.getId() == id) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (FeedbackModel feedback : feedbacks) {
                if (feedback.getId() != id) {
                    String line = feedback.getId() + DELIMITER +
                            feedback.getMessage() + DELIMITER +
                            feedback.getFeedback() + DELIMITER +
                            feedback.getRating();
                    writer.write(line);
                    writer.newLine();
                }
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error deleting feedback: " + e.getMessage());
            return false;
        }
    }


    // Method to sort feedbacks by rating using SelectionSort
    public List<FeedbackModel> getFeedbacksSortedByRating() {
        List<FeedbackModel> feedbacks = getAllFeedbacks();
        int[] ratings = new int[feedbacks.size()];

        // Extract ratings for sorting
        for (int i = 0; i < feedbacks.size(); i++) {
            ratings[i] = feedbacks.get(i).getRating();
        }

        // Use selection sort
        SelectionSort sorter = new SelectionSort();
        sorter.sort(ratings);

        // Create sorted list of feedbacks based on sorted ratings
        List<FeedbackModel> sortedFeedbacks = new ArrayList<>();
        for (int rating : ratings) {
            // Find feedbacks with this rating and add them
            for (FeedbackModel feedback : feedbacks) {
                if (feedback.getRating() == rating && !sortedFeedbacks.contains(feedback)) {
                    sortedFeedbacks.add(feedback);
                    break;
                }
            }
        }

        return sortedFeedbacks;
    }

    // Method to store feedbacks in a CustomLinkedList
    public CustomLinkedList storeFeedbacksInLinkedList() {
        List<FeedbackModel> feedbacks = getAllFeedbacks();
        CustomLinkedList linkedList = new CustomLinkedList();

        // Add all feedbacks to the linked list
        for (FeedbackModel feedback : feedbacks) {
            linkedList.add(feedback);
        }

        return linkedList;
    }
}