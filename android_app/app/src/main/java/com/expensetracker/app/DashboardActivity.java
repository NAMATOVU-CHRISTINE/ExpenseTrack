package com.expensetracker.app;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.data.PieEntry;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DashboardActivity extends AppCompatActivity {
    
    private TextView tvTotalExpenses, tvMonthlyBudget, tvUsername;
    private RecyclerView rvRecentExpenses;
    private PieChart pieChart;
    private FloatingActionButton fabAddExpense;
    private ApiService apiService;
    private SharedPreferences sharedPreferences;
    private ExpenseAdapter expenseAdapter;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);
        
        initViews();
        setupRecyclerView();
        setupChart();
        loadDashboardData();
        setupClickListeners();
    }
    
    private void initViews() {
        tvTotalExpenses = findViewById(R.id.tv_total_expenses);
        tvMonthlyBudget = findViewById(R.id.tv_monthly_budget);
        tvUsername = findViewById(R.id.tv_username);
        rvRecentExpenses = findViewById(R.id.rv_recent_expenses);
        pieChart = findViewById(R.id.pie_chart);
        fabAddExpense = findViewById(R.id.fab_add_expense);
        
        sharedPreferences = getSharedPreferences("ExpenseTracker", MODE_PRIVATE);
        apiService = ApiClient.getClient().create(ApiService.class);
        
        // Set username
        String username = sharedPreferences.getString("username", "User");
        tvUsername.setText("Welcome, " + username);
    }
    
    private void setupRecyclerView() {
        expenseAdapter = new ExpenseAdapter(new ArrayList<>());
        rvRecentExpenses.setLayoutManager(new LinearLayoutManager(this));
        rvRecentExpenses.setAdapter(expenseAdapter);
    }
    
    private void setupChart() {
        pieChart.setUsePercentValues(true);
        pieChart.getDescription().setEnabled(false);
        pieChart.setExtraOffsets(5, 10, 5, 5);
        pieChart.setDragDecelerationFrictionCoef(0.95f);
        pieChart.setDrawHoleEnabled(true);
        pieChart.setHoleColor(android.R.color.white);
        pieChart.setTransparentCircleRadius(61f);
    }
    
    private void loadDashboardData() {
        String token = sharedPreferences.getString("auth_token", "");
        
        // Load financial data
        apiService.getFinancialData("Bearer " + token).enqueue(new Callback<FinancialData>() {
            @Override
            public void onResponse(Call<FinancialData> call, Response<FinancialData> response) {
                if (response.isSuccessful() && response.body() != null) {
                    FinancialData data = response.body();
                    updateUI(data);
                }
            }
            
            @Override
            public void onFailure(Call<FinancialData> call, Throwable t) {
                // Handle error
            }
        });
        
        // Load recent expenses
        apiService.getRecentExpenses("Bearer " + token).enqueue(new Callback<List<Expense>>() {
            @Override
            public void onResponse(Call<List<Expense>> call, Response<List<Expense>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    expenseAdapter.updateExpenses(response.body());
                }
            }
            
            @Override
            public void onFailure(Call<List<Expense>> call, Throwable t) {
                // Handle error
            }
        });
    }
    
    private void updateUI(FinancialData data) {
        if(data.getTotalExpenses() != null)
             tvTotalExpenses.setText("$" + String.format("%.2f", data.getTotalExpenses()));
        if(data.getMonthlyBudget() != null)
             tvMonthlyBudget.setText("$" + String.format("%.2f", data.getMonthlyBudget()));
        
        // Update pie chart
        if(data.getCategoryExpenses() != null)
            updatePieChart(data.getCategoryExpenses());
    }
    
    private void updatePieChart(List<CategoryExpense> categoryExpenses) {
        ArrayList<PieEntry> entries = new ArrayList<>();
        
        for (CategoryExpense category : categoryExpenses) {
            entries.add(new PieEntry(category.getAmount().floatValue(), category.getName()));
        }
        
        PieDataSet dataSet = new PieDataSet(entries, "Expenses by Category");
        dataSet.setSliceSpace(3f);
        dataSet.setSelectionShift(5f);
        
        // Add colors
        ArrayList<Integer> colors = new ArrayList<>();
        colors.add(getResources().getColor(android.R.color.holo_blue_bright));
        colors.add(getResources().getColor(android.R.color.holo_green_light));
        colors.add(getResources().getColor(android.R.color.holo_orange_light));
        colors.add(getResources().getColor(android.R.color.holo_red_light));
        colors.add(getResources().getColor(android.R.color.holo_purple));
        dataSet.setColors(colors);
        
        PieData data = new PieData(dataSet);
        data.setValueTextSize(11f);
        
        pieChart.setData(data);
        pieChart.invalidate();
    }
    
    private void setupClickListeners() {
        fabAddExpense.setOnClickListener(v -> {
            // startActivity(new Intent(this, AddExpenseActivity.class));
            Toast.makeText(this, "Add Expense Not Implemented", Toast.LENGTH_SHORT).show();
        });
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.dashboard_menu, menu);
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.menu_logout) {
            logout();
            return true;
        } else if (id == R.id.menu_budgets) {
            // startActivity(new Intent(this, BudgetsActivity.class));
            return true;
        } else if (id == R.id.menu_reports) {
            // startActivity(new Intent(this, ReportsActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
    
    private void logout() {
        sharedPreferences.edit().clear().apply();
        startActivity(new Intent(this, MainActivity.class));
        finish();
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        loadDashboardData(); // Refresh data when returning to dashboard
    }
}