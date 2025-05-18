from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import login as auth_login
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from expenses.models import Expense, Category
from users.models import IncomeSource
from django.db.models import Sum
from datetime import datetime
import random

@login_required
def home(request):
    # Get current date
    today = datetime.now()
    
    # Get total income and sources
    total_income = IncomeSource.objects.filter(
        user=request.user,
        is_active=True
    ).aggregate(total=Sum('amount'))['total'] or 0

    income_sources = IncomeSource.objects.filter(
        user=request.user,
        is_active=True
    ).values('name', 'amount').order_by('-amount')
    
    # Get recent expenses
    recent_expenses = Expense.objects.filter(user=request.user).order_by('-date')[:5]
    
    # Get top categories with expenses for the current month
    month_start = today.replace(day=1)
    month_end = (month_start.replace(month=month_start.month % 12 + 1) 
                if month_start.month < 12 
                else month_start.replace(year=month_start.year + 1, month=1))
    
    top_categories = Category.objects.filter(
        expense__user=request.user,
        expense__date__gte=month_start,
        expense__date__lt=month_end
    ).annotate(
        total=Sum('expense__amount')
    ).order_by('-total')[:5]
    
    # Motivational quotes for the dashboard
    motivational_quotes = [
        "Track your expenses today for a better financial tomorrow.",
        "The more you save, the more you have for the things that truly matter.",
        "Financial planning is not just about money; it's about creating options for your future.",
        "Small savings add up to big results over time.",
        "Budget like a pro, live like a dream.",
        "Every expense tracked is a step towards financial freedom."
    ]
    
    # Choose a random quote
    motivational_quote = random.choice(motivational_quotes)
    
    context = {
        'recent_expenses': recent_expenses,
        'top_categories': top_categories,
        'today': today,
        'motivational_quote': motivational_quote,
        'total_income': total_income,
        'income_sources': income_sources
    }
    
    return render(request, 'home.html', context)

def login(request):
    if request.user.is_authenticated:
        return render(request, 'home.html')
    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            auth_login(request, user)
            return redirect('home')
    else:
        form = AuthenticationForm()
    return render(request, 'users/login.html', {'form': form})