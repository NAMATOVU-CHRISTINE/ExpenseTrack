from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth.decorators import login_required
import json
from datetime import datetime, timedelta
from django.db.models import Sum
import random

from expenses.models import Expense, Category
from budgets.models import Budget
from users.models import Profile, IncomeSource, RecurringBill

@login_required
@ensure_csrf_cookie
def financial_data(request):
    """API endpoint to get financial data for the dashboard."""
    user = request.user
    
    # Get current month data
    now = datetime.now()
    month_start = datetime(now.year, now.month, 1)
    month_end = (month_start + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    
    # Get user profile
    profile = user.profile
    
    # Get expense data from database
    expenses = Expense.objects.filter(user=user, date__gte=month_start, date__lte=month_end)
    total_expenses = expenses.aggregate(Sum('amount'))['amount__sum'] or 0
    
    # Get budget data from database
    budgets = Budget.objects.filter(user=user, is_active=True)
    total_budget = budgets.aggregate(Sum('amount'))['amount__sum'] or 0
    
    # Get categories with amounts from database
    categories = Category.objects.filter(expense__user=user, expense__date__gte=month_start, expense__date__lte=month_end).distinct()
    category_expenses = []
    top_category = None
    top_amount = 0
    
    for category in categories:
        amount = Expense.objects.filter(
            user=user, 
            category=category,
            date__gte=month_start, 
            date__lte=month_end
        ).aggregate(Sum('amount'))['amount__sum'] or 0
        
        category_expenses.append({
            'name': category.name,
            'amount': float(amount),
            'spent': float(amount),
            'color': category.color,
            'icon': category.icon
        })
        
        if amount > top_amount:
            top_amount = amount
            top_category = category.name
    
    # Get last month data for comparison from database
    last_month_start = month_start - timedelta(days=month_start.day)
    last_month_end = month_start - timedelta(days=1)
    
    last_month_expenses = Expense.objects.filter(
        user=user, 
        date__gte=last_month_start, 
        date__lte=last_month_end
    ).aggregate(Sum('amount'))['amount__sum'] or 0
    
    # Calculate month-over-month change
    if last_month_expenses > 0:
        monthly_change = ((total_expenses - last_month_expenses) / last_month_expenses) * 100
    else:
        monthly_change = 0
    
    # Get real bills from database
    real_bills = RecurringBill.objects.filter(user=user, is_active=True)
    bills_list = []
    
    for bill in real_bills:
        bills_list.append({
            'name': bill.name,
            'amount': float(bill.amount),
            'dueDate': bill.due_date.strftime('%Y-%m-%d'),
            'category': bill.category or 'Other',
            'status': bill.payment_status
        })
    
    # Get real income sources from database
    income_sources = IncomeSource.objects.filter(user=user, is_active=True)
    sources_list = []
    
    for source in income_sources:
        sources_list.append({
            'name': source.name,
            'amount': float(source.amount),
            'frequency': source.frequency,
            'isActive': source.is_active
        })
    
    # Construct the financial data object entirely from database data
    financial_data = {
        'savings': {
            'current': float(profile.savings_amount),
            'target': float(profile.savings_target)
        },
        'income': {
            'total': float(profile.monthly_income),
            'sources': sources_list
        },
        'budget': {
            'total': float(total_budget),
            'spent': float(total_expenses),
            'categories': category_expenses
        },
        'insights': {
            'topCategory': top_category or '',
            'monthlySpend': float(total_expenses),
            'monthlyChange': float(monthly_change)
        },
        'bills': bills_list
    }
    
    return JsonResponse(financial_data)

@login_required
@require_http_methods(["POST"])
def update_financial_data(request):
    """API endpoint to update financial data."""
    try:
        data = json.loads(request.body)
        user = request.user
        profile = user.profile
        
        # Update profile with new financial data
        if 'savings' in data:
            profile.savings_amount = data['savings']['current']
            profile.savings_target = data['savings']['target']
        
        if 'income' in data:
            profile.monthly_income = data['income']['total']
        
        profile.save()
        
        return JsonResponse({
            'status': 'success',
            'message': 'Financial data updated successfully'
        })
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)

@login_required
@require_http_methods(["POST"])
def add_income_source(request):
    """API endpoint to add a new income source."""
    try:
        data = json.loads(request.body)
        user = request.user
        
        # Create new income source
        income_source = IncomeSource.objects.create(
            user=user,
            name=data.get('name', ''),
            amount=data.get('amount', 0),
            frequency=data.get('frequency', 'monthly'),
            is_active=data.get('is_active', True)
        )
        
        # Update user's monthly income in profile
        profile = user.profile
        
        # Add proportional amount to monthly income based on frequency
        amount = float(data.get('amount', 0))
        frequency = data.get('frequency', 'monthly')
        monthly_equivalent = amount
        
        if frequency == 'yearly':
            monthly_equivalent = amount / 12
        elif frequency == 'quarterly':
            monthly_equivalent = amount / 3
        elif frequency == 'weekly':
            monthly_equivalent = amount * 4.33  # Average weeks per month
        elif frequency == 'daily':
            monthly_equivalent = amount * 30  # Approximate days per month
        
        # Update the profile's monthly income
        profile.monthly_income = float(profile.monthly_income) + monthly_equivalent
        profile.save()
        
        return JsonResponse({
            'status': 'success',
            'message': 'Income source added successfully',
            'income_source': {
                'id': income_source.id,
                'name': income_source.name,
                'amount': float(income_source.amount),
                'frequency': income_source.frequency
            }
        })
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)

@login_required
def create_sample_data(request):
    """Create sample data for testing the dashboard."""
    user = request.user
    created_items = []
    
    # Delete existing data if requested
    if request.GET.get('clear_existing') == 'true':
        # Delete existing income sources
        deleted = IncomeSource.objects.filter(user=user).delete()
        if deleted[0] > 0:
            created_items.append(f"Deleted {deleted[0]} income sources")
        
        # Delete existing bills
        deleted = RecurringBill.objects.filter(user=user).delete()
        if deleted[0] > 0:
            created_items.append(f"Deleted {deleted[0]} bills")
    
    # Create income sources with randomized values
    if IncomeSource.objects.filter(user=user).count() < 3:
        # Generate random values
        salary = random.randint(600000, 900000)
        freelance = random.randint(50000, 150000)
        investments = random.randint(10000, 30000)
        
        income_sources = [
            {'name': 'Salary', 'amount': salary, 'frequency': 'monthly'},
            {'name': 'Freelance', 'amount': freelance, 'frequency': 'monthly'},
            {'name': 'Investments', 'amount': investments, 'frequency': 'quarterly'}
        ]
        
        for source in income_sources:
            IncomeSource.objects.create(
                user=user,
                name=source['name'],
                amount=source['amount'],
                frequency=source['frequency'],
                is_active=True
            )
            created_items.append(f"Income Source: {source['name']} - {source['amount']} UGX")
    
    # Create bills with randomized values
    if RecurringBill.objects.filter(user=user).count() < 3:
        now = datetime.now()
        
        # Generate random values
        rent = random.randint(300000, 400000)
        internet = random.randint(70000, 90000)
        phone = random.randint(40000, 60000)
        
        bills = [
            {'name': 'Rent', 'amount': rent, 'days': random.randint(5, 10), 'category': 'Housing'},
            {'name': 'Internet', 'amount': internet, 'days': random.randint(2, 5), 'category': 'Utilities'},
            {'name': 'Phone Bill', 'amount': phone, 'days': random.randint(8, 15), 'category': 'Utilities'}
        ]
        
        for bill in bills:
            due_date = now + timedelta(days=bill['days'])
            RecurringBill.objects.create(
                user=user,
                name=bill['name'],
                amount=bill['amount'],
                due_date=due_date,
                frequency='monthly',
                is_active=True,
                category=bill['category']
            )
            created_items.append(f"Bill: {bill['name']} - {bill['amount']} UGX")
    
    # Update monthly income in profile based on actual database values
    total_monthly = 0
    for source in IncomeSource.objects.filter(user=user, is_active=True):
        if source.frequency == 'monthly':
            total_monthly += float(source.amount)
        elif source.frequency == 'quarterly':
            total_monthly += float(source.amount) / 3
        elif source.frequency == 'yearly':
            total_monthly += float(source.amount) / 12
    
    if total_monthly > 0:
        profile = user.profile
        profile.monthly_income = total_monthly
        
        # Set savings amount and target based on income
        profile.savings_amount = random.randint(int(total_monthly * 0.3), int(total_monthly * 0.8))
        profile.savings_target = random.randint(int(total_monthly * 1.5), int(total_monthly * 2.5))
        
        profile.save()
        created_items.append(f"Updated monthly income: {total_monthly} UGX")
        created_items.append(f"Updated savings amount: {profile.savings_amount} UGX")
        created_items.append(f"Updated savings target: {profile.savings_target} UGX")
    
    return JsonResponse({
        'status': 'success',
        'message': 'Sample data created successfully',
        'created_items': created_items
    }) 