package com.example.demo1.services;

import com.example.demo1.models.ResultModel;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import com.example.demo1.utils.SelectionSort;
import java.util.LinkedList;

public class ResultService {
    private static final String FILE_PATH = "results.txt";
    private static final String DELIMITER = ",";

    public ResultService() {
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
            }
        }
    }

    public boolean createResult(ResultModel result) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            List<ResultModel> results = getAllResults();
            int maxId = 0;
            for (ResultModel r : results) {
                if (r.getId() > maxId) {
                    maxId = r.getId();
                }
            }
            result.setId(maxId + 1);

            String line = result.getId() + DELIMITER +
                    result.getStudentName() + DELIMITER +
                    result.getSubject() + DELIMITER +
                    result.getMarks();
            writer.write(line);
            writer.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error creating result: " + e.getMessage());
            return false;
        }
    }

    public List<ResultModel> getAllResults() {
        List<ResultModel> results = new ArrayList<>();
        File file = new File(FILE_PATH);

        if (!file.exists()) {
            try {
                file.createNewFile();
                return results;
            } catch (IOException e) {
                System.err.println("Error creating file: " + e.getMessage());
                return results;
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(DELIMITER);
                if (parts.length == 4) {
                    ResultModel result = new ResultModel();
                    result.setId(Integer.parseInt(parts[0]));
                    result.setStudentName(parts[1]);
                    result.setSubject(parts[2]);
                    result.setMarks(Integer.parseInt(parts[3]));
                    results.add(result);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading results: " + e.getMessage());
        }
        return results;
    }

    public ResultModel getResultById(int id) {
        List<ResultModel> results = getAllResults();
        for (ResultModel result : results) {
            if (result.getId() == id) {
                return result;
            }
        }
        return null;
    }

    public boolean updateResult(ResultModel updatedResult) {
        List<ResultModel> results = getAllResults();
        boolean found = false;

        for (ResultModel result : results) {
            if (result.getId() == updatedResult.getId()) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (ResultModel result : results) {
                if (result.getId() == updatedResult.getId()) {
                    String line = updatedResult.getId() + DELIMITER +
                            updatedResult.getStudentName() + DELIMITER +
                            updatedResult.getSubject() + DELIMITER +
                            updatedResult.getMarks();
                    writer.write(line);
                } else {
                    String line = result.getId() + DELIMITER +
                            result.getStudentName() + DELIMITER +
                            result.getSubject() + DELIMITER +
                            result.getMarks();
                    writer.write(line);
                }
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error updating result: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteResult(int id) {
        List<ResultModel> results = getAllResults();
        boolean found = false;

        for (ResultModel result : results) {
            if (result.getId() == id) {
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (ResultModel result : results) {
                if (result.getId() != id) {
                    String line = result.getId() + DELIMITER +
                            result.getStudentName() + DELIMITER +
                            result.getSubject() + DELIMITER +
                            result.getMarks();
                    writer.write(line);
                    writer.newLine();
                }
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error deleting result: " + e.getMessage());
            return false;
        }
    }



    public LinkedList<ResultModel> getResultsSortedByMarks() {
        List<ResultModel> results = getAllResults();
        if (results.isEmpty()) return new LinkedList<>();

        ResultModel[] resultArray = results.toArray(new ResultModel[0]);

        // Extract marks to sort
        int[] marks = new int[resultArray.length];
        for (int i = 0; i < resultArray.length; i++) {
            marks[i] = resultArray[i].getMarks();
        }

        // Sort marks and match to original ResultModel
        SelectionSort sortUtil = new SelectionSort();
        sortUtil.sort(marks);

        LinkedList<ResultModel> sortedList = new LinkedList<>();
        for (int mark : marks) {
            for (int i = 0; i < resultArray.length; i++) {
                if (resultArray[i] != null && resultArray[i].getMarks() == mark) {
                    sortedList.add(resultArray[i]);
                    resultArray[i] = null; // prevent duplicates
                    break;
                }
            }
        }

        return sortedList;
    }

    public LinkedList<ResultModel> getResultsSortedByStudentName() {
        List<ResultModel> results = getAllResults();
        if (results.isEmpty()) return new LinkedList<>();

        ResultModel[] resultArray = results.toArray(new ResultModel[0]);

        // Extract names
        String[] names = new String[resultArray.length];
        for (int i = 0; i < resultArray.length; i++) {
            names[i] = resultArray[i].getStudentName();
        }

        // Sort names
        SelectionSort sortUtil = new SelectionSort();
        sortUtil.sort(names);

        LinkedList<ResultModel> sortedList = new LinkedList<>();
        for (String name : names) {
            for (int i = 0; i < resultArray.length; i++) {
                if (resultArray[i] != null && resultArray[i].getStudentName().equals(name)) {
                    sortedList.add(resultArray[i]);
                    resultArray[i] = null; // avoid duplicate entries
                    break;
                }
            }
        }

        return sortedList;
    }

}
