package com.example.demo1.services;

import com.example.demo1.models.ExamModel;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class ExamService {
    private static final String FILE_PATH = "exams.txt";
    private static final String DELIMITER = ",";

    public ExamService() {
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
            }
        }
    }

    // Create operation
    public boolean createExam(ExamModel exam) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            // Generate ID (simple implementation)
            List<ExamModel> exams = getAllExams();
            int maxId = 0;
            for (ExamModel e : exams) {
                if (e.getId() > maxId) {
                    maxId = e.getId();
                }
            }
            exam.setId(maxId + 1);

            // Write to file
            String line = exam.getId() + DELIMITER +
                    exam.getName() + DELIMITER +
                    exam.getDate() + DELIMITER +
                    exam.getTime() + DELIMITER +
                    exam.getType();
            writer.write(line);
            writer.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error creating exam: " + e.getMessage());
            return false;
        }
    }

    // Read all operation
    public List<ExamModel> getAllExams() {
        List<ExamModel> exams = new ArrayList<>();
        File file = new File(FILE_PATH);

        // Create file if it doesn't exist
        if (!file.exists()) {
            try {
                file.createNewFile();
                return exams;
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
                return exams;
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(DELIMITER);
                if (parts.length == 5) {
                    ExamModel exam = new ExamModel();
                    exam.setId(Integer.parseInt(parts[0]));
                    exam.setName(parts[1]);
                    exam.setDate(parts[2]);
                    exam.setTime(parts[3]);
                    exam.setType(parts[4]);
                    exams.add(exam);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading exams: " + e.getMessage());
        }
        return exams;
    }

    // Read by ID operation
    public ExamModel getExamById(int id) {
        List<ExamModel> exams = getAllExams();
        for (ExamModel exam : exams) {
            if (exam.getId() == id) {
                return exam;
            }
        }
        return null;
    }

    // Update operation
    public boolean updateExam(ExamModel updatedExam) {
        List<ExamModel> exams = getAllExams();
        boolean found = false;

        for (ExamModel exam : exams) {
            if (exam.getId() == updatedExam.getId()) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (ExamModel exam : exams) {
                if (exam.getId() == updatedExam.getId()) {
                    // Write updated exam
                    String line = updatedExam.getId() + DELIMITER +
                            updatedExam.getName() + DELIMITER +
                            updatedExam.getDate() + DELIMITER +
                            updatedExam.getTime() + DELIMITER +
                            updatedExam.getType();
                    writer.write(line);
                } else {
                    // Write existing exam
                    String line = exam.getId() + DELIMITER +
                            exam.getName() + DELIMITER +
                            exam.getDate() + DELIMITER +
                            exam.getTime() + DELIMITER +
                            exam.getType();
                    writer.write(line);
                }
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error updating exam: " + e.getMessage());
            return false;
        }
    }

    // Delete operation
    public boolean deleteExam(int id) {
        List<ExamModel> exams = getAllExams();
        boolean found = false;

        for (ExamModel exam : exams) {
            if (exam.getId() == id) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (ExamModel exam : exams) {
                if (exam.getId() != id) {
                    String line = exam.getId() + DELIMITER +
                            exam.getName() + DELIMITER +
                            exam.getDate() + DELIMITER +
                            exam.getTime() + DELIMITER +
                            exam.getType();
                    writer.write(line);
                    writer.newLine();
                }
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error deleting exam: " + e.getMessage());
            return false;
        }
    }
}
