package com.expensetracker.app;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;
import java.util.Locale;

public class ExpenseAdapter extends RecyclerView.Adapter<ExpenseAdapter.ViewHolder> {

    private final List<Expense> expenses;
    private final OnExpenseLongClickListener listener;

    public interface OnExpenseLongClickListener {
        void onLongClick(int position, Expense expense);
    }

    public ExpenseAdapter(List<Expense> expenses, OnExpenseLongClickListener listener) {
        this.expenses = expenses;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_expense, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Expense expense = expenses.get(position);
        holder.titleText.setText(expense.title);
        holder.amountText.setText(String.format(Locale.getDefault(), "UGX %.0f", expense.amount));
        holder.categoryText.setText(expense.category);
        holder.dateText.setText(expense.date);

        holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                listener.onLongClick(holder.getAdapterPosition(), expense);
                return true;
            }
        });
    }

    @Override
    public int getItemCount() {
        return expenses.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView titleText;
        TextView amountText;
        TextView categoryText;
        TextView dateText;

        public ViewHolder(@NonNull View view) {
            super(view);
            titleText = view.findViewById(R.id.titleText);
            amountText = view.findViewById(R.id.amountText);
            categoryText = view.findViewById(R.id.categoryText);
            dateText = view.findViewById(R.id.dateText);
        }
    }
}
