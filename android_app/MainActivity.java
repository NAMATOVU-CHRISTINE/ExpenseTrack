package com.expensetracker.app;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class MainActivity extends AppCompatActivity {
    
    private EditText etUsername, etPassword;
    private Button btnLogin, btnSignup;
    private ApiService apiService;
    private SharedPreferences sharedPreferences;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initViews();
        setupRetrofit();
        checkIfLoggedIn();
        setupClickListeners();
    }
    
    private void initViews() {
        etUsername = findViewById(R.id.et_username);
        etPassword = findViewById(R.id.et_password);
        btnLogin = findViewById(R.id.btn_login);
        btnSignup = findViewById(R.id.btn_signup);
        
        sharedPreferences = getSharedPreferences("ExpenseTracker", MODE_PRIVATE);
    }
    
    private void setupRetrofit() {
        apiService = ApiClient.getClient().create(ApiService.class);
    }
    
    private void checkIfLoggedIn() {
        String token = sharedPreferences.getString("auth_token", null);
        if (token != null) {
            startActivity(new Intent(this, DashboardActivity.class));
            finish();
        }
    }
    
    private void setupClickListeners() {
        btnLogin.setOnClickListener(v -> performLogin());
        btnSignup.setOnClickListener(v -> {
            startActivity(new Intent(this, SignupActivity.class));
        });
    }
    
    private void performLogin() {
        String username = etUsername.getText().toString().trim();
        String password = etPassword.getText().toString().trim();
        
        if (username.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }
        
        LoginRequest loginRequest = new LoginRequest(username, password);
        
        apiService.login(loginRequest).enqueue(new Callback<LoginResponse>() {
            @Override
            public void onResponse(Call<LoginResponse> call, Response<LoginResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    LoginResponse loginResponse = response.body();
                    
                    // Save token
                    sharedPreferences.edit()
                            .putString("auth_token", loginResponse.getToken())
                            .putString("username", username)
                            .apply();
                    
                    // Navigate to dashboard
                    startActivity(new Intent(MainActivity.this, DashboardActivity.class));
                    finish();
                } else {
                    Toast.makeText(MainActivity.this, "Login failed", Toast.LENGTH_SHORT).show();
                }
            }
            
            @Override
            public void onFailure(Call<LoginResponse> call, Throwable t) {
                Toast.makeText(MainActivity.this, "Network error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
}