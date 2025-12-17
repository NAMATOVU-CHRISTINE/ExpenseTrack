package com.expensetracker.app;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class ExpenseAdapter extends RecyclerView.Adapter<ExpenseAdapter.ViewHolder> {

    private List<Expense> expenses;

    public ExpenseAdapter(List<Expense> expenses) {
        this.expenses = expenses;
    }

    public void updateExpenses(List<Expense> expenses) {
        this.expenses = expenses;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // We will create a simple layout for item since item_expense.xml is likely missing
        // or we can try to use a standard one.
        // Let's assume there is an item_expense.xml or create one.
        // For now I will create item_expense.xml as well.
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_expense, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Expense expense = expenses.get(position);
        holder.tvDescription.setText(expense.getDescription());
        holder.tvAmount.setText(String.valueOf(expense.getAmount()));
        holder.tvDate.setText(expense.getDate());
    }

    @Override
    public int getItemCount() {
        return expenses != null ? expenses.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public TextView tvDescription;
        public TextView tvAmount;
        public TextView tvDate;

        public ViewHolder(View itemView) {
            super(itemView);
            tvDescription = itemView.findViewById(R.id.tv_description);
            tvAmount = itemView.findViewById(R.id.tv_amount);
            tvDate = itemView.findViewById(R.id.tv_date);
        }
    }
}