package com.example.demo1.utils;

import com.example.demo1.models.ResultModel;

public class CustomLinkedList {

    private Node head;

    private static class Node {
        ResultModel data;
        Node next;

        Node(ResultModel data) {
            this.data = data;
            this.next = null;
        }
    }

    public void add(ResultModel data) {
        Node newNode = new Node(data);
        if (head == null) {
            head = newNode;
            return;
        }

        Node current = head;
        while (current.next != null) {
            current = current.next;
        }
        current.next = newNode;
    }

    public void addFirst(ResultModel data) {
        Node newNode = new Node(data);
        newNode.next = head;
        head = newNode;
    }

    public boolean removeByStudentAndSubject(String studentName, String subject) {
        if (head == null) return false;

        if (head.data.getStudentName().equals(studentName) &&
                head.data.getSubject().equals(subject)) {
            head = head.next;
            return true;
        }

        Node current = head;
        while (current.next != null) {
            ResultModel nextData = current.next.data;
            if (nextData.getStudentName().equals(studentName) &&
                    nextData.getSubject().equals(subject)) {
                current.next = current.next.next;
                return true;
            }
            current = current.next;
        }

        return false;
    }

    public boolean contains(String studentName, String subject) {
        Node current = head;
        while (current != null) {
            ResultModel data = current.data;
            if (data.getStudentName().equals(studentName) &&
                    data.getSubject().equals(subject)) {
                return true;
            }
            current = current.next;
        }
        return false;
    }

    public int size() {
        int count = 0;
        Node current = head;
        while (current != null) {
            count++;
            current = current.next;
        }
        return count;
    }

    public void printList() {
        Node current = head;
        while (current != null) {
            ResultModel data = current.data;
            System.out.println("Student: " + data.getStudentName() +
                    ", Subject: " + data.getSubject() +
                    ", Marks: " + data.getMarks());
            current = current.next;
        }
    }

    public boolean isEmpty() {
        return head == null;
    }


}
