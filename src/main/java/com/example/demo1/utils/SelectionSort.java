package com.example.demo1.utils;

public class SelectionSort {

    public void sort(int[] arr) {
        if (arr == null || arr.length == 0) {
            return;
        }
        int n = arr.length;
        for (int i = 0; i < n - 1; i++) {
            int minIndex = i;
            for (int j = i + 1; j < n; j++) {
                if (arr[j] < arr[minIndex]) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                int temp = arr[i];
                arr[i] = arr[minIndex];
                arr[minIndex] = temp;
            }
        }
    }

    public void sort(double[] arr) {
        if (arr == null || arr.length == 0) {
            return;
        }
        int n = arr.length;
        for (int i = 0; i < n - 1; i++) {
            int minIndex = i;
            for (int j = i + 1; j < n; j++) {
                if (arr[j] < arr[minIndex]) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                double temp = arr[i];
                arr[i] = arr[minIndex];
                arr[minIndex] = temp;
            }
        }
    }

    public void sort(String[] arr) {
        if (arr == null || arr.length == 0) {
            return;
        }
        int n = arr.length;
        for (int i = 0; i < n - 1; i++) {
            int minIndex = i;
            for (int j = i + 1; j < n; j++) {
                if (arr[j] != null && (arr[minIndex] == null || arr[j].compareTo(arr[minIndex]) < 0)) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                String temp = arr[i];
                arr[i] = arr[minIndex];
                arr[minIndex] = temp;
            }
        }
    }

    public <T extends Comparable<T>> void sortGeneric(T[] arr) {
        if (arr == null || arr.length == 0) {
            return;
        }
        int n = arr.length;
        for (int i = 0; i < n - 1; i++) {
            int minIndex = i;
            for (int j = i + 1; j < n; j++) {
                if (arr[j] != null && (arr[minIndex] == null || arr[j].compareTo(arr[minIndex]) < 0)) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                T temp = arr[i];
                arr[i] = arr[minIndex];
                arr[minIndex] = temp;
            }
        }
    }

    public static void main(String[] args) {
        SelectionSort sorter = new SelectionSort();

        int[] intArray = {64, 25, 12, 22, 11};
        sorter.sort(intArray);
        System.out.println("Sorted int array:");
        for (int num : intArray) {
            System.out.print(num + " ");
        }
        System.out.println();

        double[] doubleArray = {3.14, 1.59, 2.65, 5.35, 8.97};
        sorter.sort(doubleArray);
        System.out.println("Sorted double array:");
        for (double num : doubleArray) {
            System.out.print(num + " ");
        }
        System.out.println();

        String[] stringArray = {"banana", "apple", "pear", "grape", "orange"};
        sorter.sort(stringArray);
        System.out.println("Sorted string array:");
        for (String str : stringArray) {
            System.out.print(str + " ");
        }
        System.out.println();
    }
}
