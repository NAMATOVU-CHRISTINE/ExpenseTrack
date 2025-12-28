package com.expensetracker.native;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

public class MainActivity extends Activity {
    
    private TextView totalExpensesText;
    private TextView monthlyBudgetText;
    private ListView expensesList;
    private Button addExpenseButton;
    private ArrayAdapter<String> expensesAdapter;
    private ArrayList<String> expenses;
    private SharedPreferences prefs;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initViews();
        loadData();
        setupListeners();
        updateUI();
    }
    
    private void initViews() {
        totalExpensesText = findViewById(R.id.total_expenses);
        monthlyBudgetText = findViewById(R.id.monthly_budget);
        expensesList = findViewById(R.id.expenses_list);
        addExpenseButton = findViewById(R.id.add_expense_button);
        
        expenses = new ArrayList<String>();
        expensesAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, expenses);
        expensesList.setAdapter(expensesAdapter);
        
        prefs = getSharedPreferences("ExpenseTracker", MODE_PRIVATE);
    }
    
    private void loadData() {
        Set<String> savedExpenses = prefs.getStringSet("expenses", new HashSet<String>());
        expenses.clear();
        expenses.addAll(savedExpenses);
        expensesAdapter.notifyDataSetChanged();
    }
    
    private void setupListeners() {
        addExpenseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, AddExpenseActivity.class);
                startActivityForResult(intent, 1);
            }
        });
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == RESULT_OK) {
            String newExpense = data.getStringExtra("expense");
            if (newExpense != null) {
                expenses.add(newExpense);
                saveExpenses();
                expensesAdapter.notifyDataSetChanged();
                updateUI();
            }
        }
    }
    
    private void saveExpenses() {
        Set<String> expensesSet = new HashSet<String>(expenses);
        prefs.edit().putStringSet("expenses", expensesSet).apply();
    }
    
    private void updateUI() {
        double total = calculateTotal();
        totalExpensesText.setText("Total: $" + String.format("%.2f", total));
        monthlyBudgetText.setText("Budget: $2500.00");
    }
    
    private double calculateTotal() {
        double total = 0;
        for (String expense : expenses) {
            try {
                String[] parts = expense.split(" - \\$");
                if (parts.length > 1) {
                    total += Double.parseDouble(parts[1]);
                }
            } catch (NumberFormatException e) {
                // Skip invalid entries
            }
        }
        return total;
    }
}
