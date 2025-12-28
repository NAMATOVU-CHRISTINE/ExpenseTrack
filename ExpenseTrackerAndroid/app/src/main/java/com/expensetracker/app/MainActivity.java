package com.expensetracker.app;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private ExpenseAdapter adapter;
    private List<Expense> expenses = new ArrayList<>();
    private TextView totalText;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        prefs = getSharedPreferences("expenses", MODE_PRIVATE);
        
        totalText = findViewById(R.id.totalText);
        recyclerView = findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        adapter = new ExpenseAdapter();
        recyclerView.setAdapter(adapter);

        FloatingActionButton fab = findViewById(R.id.fab);
        fab.setOnClickListener(v -> showAddExpenseDialog());

        loadExpenses();
    }

    private void showAddExpenseDialog() {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_add_expense, null);
        EditText titleInput = dialogView.findViewById(R.id.titleInput);
        EditText amountInput = dialogView.findViewById(R.id.amountInput);
        EditText categoryInput = dialogView.findViewById(R.id.categoryInput);

        new AlertDialog.Builder(this)
                .setTitle("Add Expense")
                .setView(dialogView)
                .setPositiveButton("Add", (dialog, which) -> {
                    String title = titleInput.getText().toString().trim();
                    String amountStr = amountInput.getText().toString().trim();
                    String category = categoryInput.getText().toString().trim();

                    if (title.isEmpty() || amountStr.isEmpty()) {
                        Toast.makeText(this, "Please fill title and amount", Toast.LENGTH_SHORT).show();
                        return;
                    }

                    try {
                        double amount = Double.parseDouble(amountStr);
                        addExpense(title, amount, category.isEmpty() ? "General" : category);
                    } catch (NumberFormatException e) {
                        Toast.makeText(this, "Invalid amount", Toast.LENGTH_SHORT).show();
                    }
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void addExpense(String title, double amount, String category) {
        String date = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault()).format(new Date());
        Expense expense = new Expense(title, amount, category, date);
        expenses.add(0, expense);
        adapter.notifyItemInserted(0);
        recyclerView.scrollToPosition(0);
        updateTotal();
        saveExpenses();
    }

    private void deleteExpense(int position) {
        expenses.remove(position);
        adapter.notifyItemRemoved(position);
        updateTotal();
        saveExpenses();
    }

    private void updateTotal() {
        double total = 0;
        for (Expense e : expenses) {
            total += e.amount;
        }
        totalText.setText(String.format(Locale.getDefault(), "Total: UGX %.0f", total));
    }

    private void saveExpenses() {
        JSONArray array = new JSONArray();
        for (Expense e : expenses) {
            try {
                JSONObject obj = new JSONObject();
                obj.put("title", e.title);
                obj.put("amount", e.amount);
                obj.put("category", e.category);
                obj.put("date", e.date);
                array.put(obj);
            } catch (JSONException ex) {
                ex.printStackTrace();
            }
        }
        prefs.edit().putString("data", array.toString()).apply();
    }

    private void loadExpenses() {
        String data = prefs.getString("data", "[]");
        try {
            JSONArray array = new JSONArray(data);
            for (int i = 0; i < array.length(); i++) {
                JSONObject obj = array.getJSONObject(i);
                expenses.add(new Expense(
                        obj.getString("title"),
                        obj.getDouble("amount"),
                        obj.getString("category"),
                        obj.getString("date")
                ));
            }
            adapter.notifyDataSetChanged();
            updateTotal();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    static class Expense {
        String title, category, date;
        double amount;

        Expense(String title, double amount, String category, String date) {
            this.title = title;
            this.amount = amount;
            this.category = category;
            this.date = date;
        }
    }

    class ExpenseAdapter extends RecyclerView.Adapter<ExpenseAdapter.ViewHolder> {
        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_expense, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            Expense expense = expenses.get(position);
            holder.titleText.setText(expense.title);
            holder.amountText.setText(String.format(Locale.getDefault(), "UGX %.0f", expense.amount));
            holder.categoryText.setText(expense.category);
            holder.dateText.setText(expense.date);
            
            holder.itemView.setOnLongClickListener(v -> {
                new AlertDialog.Builder(MainActivity.this)
                        .setTitle("Delete Expense")
                        .setMessage("Delete \"" + expense.title + "\"?")
                        .setPositiveButton("Delete", (d, w) -> deleteExpense(holder.getAdapterPosition()))
                        .setNegativeButton("Cancel", null)
                        .show();
                return true;
            });
        }

        @Override
        public int getItemCount() {
            return expenses.size();
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            TextView titleText, amountText, categoryText, dateText;

            ViewHolder(View view) {
                super(view);
                titleText = view.findViewById(R.id.titleText);
                amountText = view.findViewById(R.id.amountText);
                categoryText = view.findViewById(R.id.categoryText);
                dateText = view.findViewById(R.id.dateText);
            }
        }
    }
}
