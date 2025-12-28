package com.expensetracker.app;

public class Expense {
    public String title;
    public String category;
    public String date;
    public double amount;

    public Expense(String title, double amount, String category, String date) {
        this.title = title;
        this.amount = amount;
        this.category = category;
        this.date = date;
    }
}
