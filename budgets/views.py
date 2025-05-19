from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .forms import BudgetForm
from .models import Budget
from expenses.models import Expense, Category
from django.db.models import Sum, Count, Avg, F, ExpressionWrapper, DecimalField, Q
from django.utils import timezone
from datetime import datetime, timedelta
import calendar
import json
import random
from decimal import Decimal

# Custom JSON encoder to handle Decimal objects
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return float(o)
        return super().default(o)

# Create your views here.

@login_required
def budget_list(request):
    today = timezone.now().date()
    current_month = today.replace(day=1)
    
    # Get month filter from request or use current month
    month_param = request.GET.get('month', '')
    if month_param:
        try:
            year, month = month_param.split('-')
            selected_month = datetime(int(year), int(month), 1).date()
        except (ValueError, TypeError):
            selected_month = current_month
    else:
        selected_month = current_month
    
    # Get active budgets for the selected month
    budgets = Budget.objects.filter(
        user=request.user,
        month__year=selected_month.year,
        month__month=selected_month.month,
        active=True
    ).select_related('category')
    
    # Calculate spending for each budget
    for budget in budgets:
        month_start = datetime(budget.month.year, budget.month.month, 1).date()
        month_end = (month_start.replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)
        
        spent = Expense.objects.filter(
            user=request.user,
            category=budget.category,
            date__range=[month_start, month_end]
        ).aggregate(total=Sum('amount'))['total'] or 0
        
        budget.spent = spent
        budget.remaining = budget.limit - spent
        budget.spent_percentage = min(round((spent / budget.limit) * 100, 1), 100) if budget.limit else 0
    
    # FEATURE 1: Budget Overview Summary
    total_budget = budgets.aggregate(total=Sum('limit'))['total'] or 0
    total_spent = sum(budget.spent for budget in budgets)
    total_remaining = total_budget - total_spent
    budget_usage_percent = round((total_spent / total_budget) * 100) if total_budget else 0
    
    # Get previous month data for comparison
    prev_month = (selected_month.replace(day=1) - timedelta(days=1)).replace(day=1)
    prev_month_spent = Expense.objects.filter(
        user=request.user,
        date__year=prev_month.year,
        date__month=prev_month.month
    ).aggregate(total=Sum('amount'))['total'] or 0
    
    # Calculate month-over-month change
    mom_change = round(((total_spent - prev_month_spent) / prev_month_spent) * 100) if prev_month_spent else 0
    
    # FEATURE 2: Monthly Trend Analysis
    # Get last 6 months of budget vs actual data
    trend_data = {
        'months': [],
        'budget': [],
        'actual': []
    }
    
    for i in range(5, -1, -1):
        month_date = selected_month.replace(day=1) - timedelta(days=30*i)
        month_start = month_date
        month_end = (month_start.replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)
        
        month_budget = Budget.objects.filter(
            user=request.user,
            month__year=month_date.year,
            month__month=month_date.month
        ).aggregate(total=Sum('limit'))['total'] or 0
        
        month_spent = Expense.objects.filter(
            user=request.user,
            date__range=[month_start, month_end]
        ).aggregate(total=Sum('amount'))['total'] or 0
        
        trend_data['months'].append(month_date.strftime('%b'))
        trend_data['budget'].append(float(month_budget))
        trend_data['actual'].append(float(month_spent))
    
    # FEATURE 3: Category Budget Distribution
    categories = Category.objects.filter(user=request.user)
    category_data = {
        'labels': [],
        'budget_values': [],
        'spent_values': [],
        'colors': []  # Initialize as empty array
    }
    
    if not categories.exists():
        # If no categories exist, provide default empty data
        category_data['labels'] = []
        category_data['budget_values'] = []
        category_data['spent_values'] = []
        category_data['colors'] = []
    else:
        for category in categories:
            cat_budget = Budget.objects.filter(
                user=request.user,
                category=category,
                month__year=selected_month.year,
                month__month=selected_month.month
            ).aggregate(total=Sum('limit'))['total'] or 0
            
            if cat_budget > 0:
                cat_spent = Expense.objects.filter(
                    user=request.user,
                    category=category,
                    date__year=selected_month.year,
                    date__month=selected_month.month
                ).aggregate(total=Sum('amount'))['total'] or 0
                
                category_data['labels'].append(category.name)
                category_data['budget_values'].append(float(cat_budget))
                category_data['spent_values'].append(float(cat_spent))
                category_data['colors'].append(category.color or '#' + ''.join([random.choice('0123456789ABCDEF') for _ in range(6)]))
    
    # FEATURE 4: Spending Alerts
    spending_alerts = []
    
    # Check for over-budget categories
    for budget in budgets:
        if budget.spent > budget.limit:
            overspent_amount = budget.spent - budget.limit
            overspent_percent = round((overspent_amount / budget.limit) * 100)
            spending_alerts.append({
                'type': 'danger',
                'icon': 'fa-exclamation-circle',
                'message': f"{budget.category.name} is {overspent_percent}% over budget (UGX {overspent_amount:,.0f} extra)"
            })
        elif budget.spent > (budget.limit * Decimal('0.9')):
            percent_used = round((budget.spent / budget.limit) * 100)
            spending_alerts.append({
                'type': 'warning',
                'icon': 'fa-exclamation-triangle',
                'message': f"{budget.category.name} is at {percent_used}% of budget"
            })
    
    # Check for unusual spending patterns
    categories_with_expenses = Expense.objects.filter(
        user=request.user,
        date__year=selected_month.year,
        date__month=selected_month.month
    ).values('category').annotate(count=Count('id'), total=Sum('amount'))
    
    for category_data in categories_with_expenses:
        try:
            category = Category.objects.get(pk=category_data['category'])
            
            # Get average spending for this category in previous 3 months
            prev_3_months_start = (selected_month.replace(day=1) - timedelta(days=90))
            avg_spending = Expense.objects.filter(
                user=request.user,
                category=category,
                date__gte=prev_3_months_start,
                date__lt=selected_month
            ).values('date__year', 'date__month').annotate(
                monthly_total=Sum('amount')
            ).aggregate(avg=Avg('monthly_total'))['avg'] or 0
            
            # If current spending is 50% more than average
            if avg_spending > 0 and category_data['total'] > (avg_spending * Decimal('1.5')):
                spending_alerts.append({
                    'type': 'info',
                    'icon': 'fa-info-circle',
                    'message': f"Unusual spending in {category.name}: UGX {category_data['total']:,.0f} (avg: UGX {avg_spending:,.0f})"
                })
        except Category.DoesNotExist:
            continue
    
    # FEATURE 5: Smart Budget Recommendations
    budget_recommendations = []
    
    # Categories without budgets
    categories_without_budget = Category.objects.filter(
        user=request.user
    ).exclude(
        id__in=Budget.objects.filter(
            user=request.user,
            month__year=selected_month.year,
            month__month=selected_month.month
        ).values('category_id')
    )
    
    # For categories with expenses but no budget
    for category in categories_without_budget:
        category_expenses = Expense.objects.filter(
            user=request.user,
            category=category,
            date__year=selected_month.year,
            date__month=selected_month.month
        ).aggregate(total=Sum('amount'))['total'] or 0
        
        if category_expenses > 0:
            budget_recommendations.append({
                'type': 'suggestion',
                'icon': 'fa-lightbulb',
                'category': category,
                'message': f"Create a budget for {category.name} (spent UGX {category_expenses:,.0f} this month)",
                'suggested_amount': category_expenses
            })
    
    # Adjustments for budgets that are consistently over or under
    for budget in budgets:
        # Check last 3 months
        prev_3_months_spending = []
        for i in range(1, 4):
            check_month = (selected_month.replace(day=1) - timedelta(days=30*i))
            month_spent = Expense.objects.filter(
                user=request.user,
                category=budget.category,
                date__year=check_month.year,
                date__month=check_month.month
            ).aggregate(total=Sum('amount'))['total'] or 0
            
            month_budget = Budget.objects.filter(
                user=request.user,
                category=budget.category,
                month__year=check_month.year,
                month__month=check_month.month
            ).aggregate(total=Sum('limit'))['total'] or 0
            
            if month_budget > 0:
                prev_3_months_spending.append({
                    'month': check_month.strftime('%b'),
                    'spent': month_spent,
                    'budget': month_budget,
                    'percent': (month_spent / month_budget) * 100
                })
        
        if len(prev_3_months_spending) > 0:
            avg_percent = sum(month['percent'] for month in prev_3_months_spending) / len(prev_3_months_spending)
            
            # If consistently over budget by 20%+
            if avg_percent > 120:
                suggested_increase = round(budget.limit * (avg_percent / 100))
                budget_recommendations.append({
                    'type': 'adjustment',
                    'icon': 'fa-arrow-up',
                    'category': budget.category,
                    'message': f"Consider increasing your {budget.category.name} budget",
                    'current_amount': budget.limit,
                    'suggested_amount': suggested_increase,
                    'percent_diff': round(avg_percent - 100)
                })
            # If consistently under budget by 30%+
            elif avg_percent < 70:
                suggested_decrease = round(budget.limit * (avg_percent / 100))
                budget_recommendations.append({
                    'type': 'adjustment',
                    'icon': 'fa-arrow-down',
                    'category': budget.category,
                    'message': f"Consider decreasing your {budget.category.name} budget",
                    'current_amount': budget.limit,
                    'suggested_amount': suggested_decrease,
                    'percent_diff': round(100 - avg_percent)
                })
    
    # Limit to top 3 recommendations
    budget_recommendations = budget_recommendations[:3]
    
    context = {
        'budgets': budgets,
        'selected_month': selected_month,
        'total_budget': total_budget,
        'total_spent': total_spent,
        'total_remaining': total_remaining,
        'budget_usage_percent': budget_usage_percent,
        'mom_change': mom_change,
        'trend_data': json.dumps(trend_data, cls=DecimalEncoder),
        'category_data': json.dumps(category_data, cls=DecimalEncoder),
        'spending_alerts': spending_alerts,
        'budget_recommendations': budget_recommendations
    }
    
    return render(request, 'budgets/budget_list.html', context)

@login_required
def budget_add(request):
    if request.method == 'POST':
        form = BudgetForm(user=request.user, data=request.POST)
        if form.is_valid():
            budget = form.save(commit=False)
            budget.user = request.user
            budget.save()
            messages.success(request, 'Budget added successfully!')
            return redirect('budget_list')
    else:
        form = BudgetForm(user=request.user)
    
    return render(request, 'budgets/budget_add.html', {'form': form})

@login_required
def budget_edit(request, pk):
    budget = get_object_or_404(Budget, pk=pk, user=request.user)
    
    if request.method == 'POST':
        form = BudgetForm(user=request.user, data=request.POST, instance=budget)
        if form.is_valid():
            form.save()
            messages.success(request, 'Budget updated successfully!')
            return redirect('budget_list')
    else:
        form = BudgetForm(user=request.user, instance=budget)
    
    return render(request, 'budgets/budget_edit.html', {'form': form, 'budget': budget})

@login_required
def budget_delete(request, pk):
    budget = get_object_or_404(Budget, pk=pk, user=request.user)
    
    if request.method == 'POST':
        budget.delete()
        messages.success(request, 'Budget deleted successfully!')
        return redirect('budget_list')
    
    return render(request, 'budgets/budget_delete.html', {'budget': budget})
