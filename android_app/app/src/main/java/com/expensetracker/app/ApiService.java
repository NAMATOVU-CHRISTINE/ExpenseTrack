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
    
    // Dashboard - Pointing to the new mobile-specific endpoint
    @GET("api/dashboard/")
    Call<FinancialData> getFinancialData(@Header("Authorization") String token);
    
    @GET("api/expenses/recent/")
    Call<List<Expense>> getRecentExpenses(@Header("Authorization") String token);
    
    // Expenses
    @GET("api/expenses/")
    Call<List<Expense>> getExpenses(@Header("Authorization") String token);
}