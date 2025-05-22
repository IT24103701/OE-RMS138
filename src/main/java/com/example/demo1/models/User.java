package com.earm.admin_mangement.model;

public abstract class User {
    public static String name;
    public static String email;
    public static String password;
    public static String NIC;

    public User(String name, String email, String password, String NIC) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.NIC = NIC;
    }

    // Getters and setters
    public static String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public static String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public static String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public static String getNIC() {
        return NIC;
    }

    public void setNIC(String NIC) {
        this.NIC = NIC;
    }
}
