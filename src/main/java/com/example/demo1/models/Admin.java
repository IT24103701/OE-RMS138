package com.earm.admin_mangement.model;

public class Admin extends User {
     public static String empNumber;

    public Admin(String name, String email, String password, String NIC, String empNumber) {
        super(name, email, password, NIC);
        this.empNumber = empNumber;
    }

    public static String getEmpNumber() {
        return empNumber;
    }

    public void setEmpNumber(String empNumber) {
        this.empNumber = empNumber;
    }
}
