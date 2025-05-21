package com.example.demo1.services;

import com.example.demo1.models.StudentModel;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class StudentService {
    private static final String FILE_PATH = "students.txt";
    private static final String DELIMITER = ",";

    public StudentService() {
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
    public boolean createStudent(StudentModel student) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            // Generate ID (simple implementation)
            List<StudentModel> students = getAllStudents();
            int maxId = 0;
            for (StudentModel s : students) {
                if (s.getId() > maxId) {
                    maxId = s.getId();
                }
            }
            student.setId(maxId + 1);

            // Write to file
            String line = student.getId() + DELIMITER +
                    student.getName() + DELIMITER +
                    student.getEmail() + DELIMITER +
                    student.getContactNumber() + DELIMITER +
                    student.getAge();
            writer.write(line);
            writer.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error creating student: " + e.getMessage());
            return false;
        }
    }

    // Read all operation
    public List<StudentModel> getAllStudents() {
        List<StudentModel> students = new ArrayList<>();
        File file = new File(FILE_PATH);

        // Create file if it doesn't exist
        if (!file.exists()) {
            try {
                file.createNewFile();
                return students;
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
                return students;
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(DELIMITER);
                if (parts.length == 5) {
                    StudentModel student = new StudentModel();
                    student.setId(Integer.parseInt(parts[0]));
                    student.setName(parts[1]);
                    student.setEmail(parts[2]);
                    student.setContactNumber(parts[3]);
                    student.setAge(Integer.parseInt(parts[4]));
                    students.add(student);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading students: " + e.getMessage());
        }
        return students;
    }

    // Read by ID operation
    public StudentModel getStudentById(int id) {
        List<StudentModel> students = getAllStudents();
        for (StudentModel student : students) {
            if (student.getId() == id) {
                return student;
            }
        }
        return null;
    }

    // Update operation
    public boolean updateStudent(StudentModel updatedStudent) {
        List<StudentModel> students = getAllStudents();
        boolean found = false;

        for (StudentModel student : students) {
            if (student.getId() == updatedStudent.getId()) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (StudentModel student : students) {
                if (student.getId() == updatedStudent.getId()) {
                    // Write updated student
                    String line = updatedStudent.getId() + DELIMITER +
                            updatedStudent.getName() + DELIMITER +
                            updatedStudent.getEmail() + DELIMITER +
                            updatedStudent.getContactNumber() + DELIMITER +
                            updatedStudent.getAge();
                    writer.write(line);
                } else {
                    // Write existing student
                    String line = student.getId() + DELIMITER +
                            student.getName() + DELIMITER +
                            student.getEmail() + DELIMITER +
                            student.getContactNumber() + DELIMITER +
                            student.getAge();
                    writer.write(line);
                }
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error updating student: " + e.getMessage());
            return false;
        }
    }

    // Delete operation
    public boolean deleteStudent(int id) {
        List<StudentModel> students = getAllStudents();
        boolean found = false;

        for (StudentModel student : students) {
            if (student.getId() == id) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (StudentModel student : students) {
                if (student.getId() != id) {
                    String line = student.getId() + DELIMITER +
                            student.getName() + DELIMITER +
                            student.getEmail() + DELIMITER +
                            student.getContactNumber() + DELIMITER +
                            student.getAge();
                    writer.write(line);
                    writer.newLine();
                }
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error deleting student: " + e.getMessage());
            return false;
        }
    }
}
