package com.expensetracker.app;

import java.math.BigDecimal;
import java.util.Date;

public class Expense {
    private int id;
    private String description;
    private BigDecimal amount;
    private String date;
    private Category category;
    private String notes;
    private boolean isRecurring;
    
    // Constructors
    public Expense() {}
    
    public Expense(String description, BigDecimal amount, String date, Category category) {
        this.description = description;
        this.amount = amount;
        this.date = date;
        this.category = category;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    
    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public boolean isRecurring() { return isRecurring; }
    public void setRecurring(boolean recurring) { isRecurring = recurring; }
}