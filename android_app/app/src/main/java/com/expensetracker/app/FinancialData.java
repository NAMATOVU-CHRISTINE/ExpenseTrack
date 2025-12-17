package com.expensetracker.app;

import java.math.BigDecimal;
import java.util.List;

public class FinancialData {
    private BigDecimal totalExpenses;
    private BigDecimal monthlyBudget;
    private List<CategoryExpense> categoryExpenses;

    public BigDecimal getTotalExpenses() { return totalExpenses; }
    public BigDecimal getMonthlyBudget() { return monthlyBudget; }
    public List<CategoryExpense> getCategoryExpenses() { return categoryExpenses; }
}