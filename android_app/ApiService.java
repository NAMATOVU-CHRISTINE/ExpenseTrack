package com.expensetracker.app;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Path;

public interface ApiService {
    
    // Authentication
    @POST("api/auth/login/")
    Call<LoginResponse> login(@Body LoginRequest loginRequest);
    
    @POST("api/auth/register/")
    Call<RegisterResponse> register(@Body RegisterRequest registerRequest);
    
    // Dashboard
    @GET("api/financial-data/")
    Call<FinancialData> getFinancialData(@Header("Authorization") String token);
    
    @GET("api/expenses/recent/")
    Call<List<Expense>> getRecentExpenses(@Header("Authorization") String token);
    
    // Expenses
    @GET("api/expenses/")
    Call<List<Expense>> getExpenses(@Header("Authorization") String token);
    
    @POST("api/expenses/")
    Call<Expense> createExpense(@Header("Authorization") String token, @Body Expense expense);
    
    @PUT("api/expenses/{id}/")
    Call<Expense> updateExpense(@Header("Authorization") String token, @Path("id") int id, @Body Expense expense);
    
    // Categories
    @GET("api/categories/")
    Call<List<Category>> getCategories(@Header("Authorization") String token);
    
    @POST("api/categories/")
    Call<Category> createCategory(@Header("Authorization") String token, @Body Category category);
    
    // Budgets
    @GET("api/budgets/")
    Call<List<Budget>> getBudgets(@Header("Authorization") String token);
    
    @POST("api/budgets/")
    Call<Budget> createBudget(@Header("Authorization") String token, @Body Budget budget);
    
    // Reports
    @GET("api/reports/monthly/")
    Call<MonthlyReport> getMonthlyReport(@Header("Authorization") String token);
    
    @GET("api/reports/category/")
    Call<List<CategoryReport>> getCategoryReport(@Header("Authorization") String token);
}