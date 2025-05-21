package com.example.demo1.services;

import com.example.demo1.models.QuestionModel;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class QuestionService {
    private static final String FILE_PATH = "questions.txt";
    private static final String DELIMITER = ",";

    public QuestionService() {
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
            }
        }
    }

    public boolean createQuestion(QuestionModel question) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            List<QuestionModel> questions = getAllQuestions();
            int maxId = 0;
            for (QuestionModel q : questions) {
                if (q.getId() > maxId) {
                    maxId = q.getId();
                }
            }
            question.setId(maxId + 1);

            String line = question.getId() + DELIMITER +
                    question.getQuestion() + DELIMITER +
                    question.getAnswer() + DELIMITER +
                    question.getType();
            writer.write(line);
            writer.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error creating question: " + e.getMessage());
            return false;
        }
    }

    public List<QuestionModel> getAllQuestions() {
        List<QuestionModel> questions = new ArrayList<>();
        File file = new File(FILE_PATH);

        if (!file.exists()) {
            try {
                file.createNewFile();
                return questions;
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
                return questions;
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(DELIMITER);
                if (parts.length == 4) {
                    QuestionModel question = new QuestionModel();
                    question.setId(Integer.parseInt(parts[0]));
                    question.setQuestion(parts[1]);
                    question.setAnswer(parts[2]);
                    question.setType(parts[3]);
                    questions.add(question);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading questions: " + e.getMessage());
        }
        return questions;
    }

    public QuestionModel getQuestionById(int id) {
        List<QuestionModel> questions = getAllQuestions();
        for (QuestionModel question : questions) {
            if (question.getId() == id) {
                return question;
            }
        }
        return null;
    }

    public boolean updateQuestion(QuestionModel updatedQuestion) {
        List<QuestionModel> questions = getAllQuestions();
        boolean found = false;

        for (QuestionModel question : questions) {
            if (question.getId() == updatedQuestion.getId()) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (QuestionModel question : questions) {
                if (question.getId() == updatedQuestion.getId()) {
                    String line = updatedQuestion.getId() + DELIMITER +
                            updatedQuestion.getQuestion() + DELIMITER +
                            updatedQuestion.getAnswer() + DELIMITER +
                            updatedQuestion.getType();
                    writer.write(line);
                } else {
                    String line = question.getId() + DELIMITER +
                            question.getQuestion() + DELIMITER +
                            question.getAnswer() + DELIMITER +
                            question.getType();
                    writer.write(line);
                }
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error updating question: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteQuestion(int id) {
        List<QuestionModel> questions = getAllQuestions();
        boolean found = false;

        for (QuestionModel question : questions) {
            if (question.getId() == id) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (QuestionModel question : questions) {
                if (question.getId() != id) {
                    String line = question.getId() + DELIMITER +
                            question.getQuestion() + DELIMITER +
                            question.getAnswer() + DELIMITER +
                            question.getType();
                    writer.write(line);
                    writer.newLine();
                }
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error deleting question: " + e.getMessage());
            return false;
        }
    }
}