from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.contrib.auth.models import User
from django.http import HttpResponseBadRequest
from django.db.models import Sum
from django.utils import timezone
import calendar
import datetime
from decimal import Decimal
from .forms import (
    UserUpdateForm, ProfileUpdateForm, IncomeSourceForm,
    FinanceGoalForm, FamilyMemberForm, ProfileImageForm, SavingsGoalForm
)
from .models import (
    Profile, IncomeSource, FinanceGoal, FamilyMember, ActivityLog,
    RecurringBill, SavingsGoal, ExpenseAnomaly, InAppNotification
)
from budgets.models import Budget
from expenses.models import Expense, Category

# Create your views here.

def signup(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            # Profile is created automatically by post_save signal
            return redirect('login')
    else:
        form = UserCreationForm()
    return render(request, 'users/signup.html', {'form': form})

def calculate_financial_health(user):
    """Calculate financial health score and factors"""
    profile = user.profile
    total_score = 0
    factors = []
    
    # 1. Savings Rate (30 points)
    if profile.monthly_income > 0:
        savings_rate = (profile.savings_amount / profile.monthly_income) * Decimal('100')
        savings_points = min(30, int(savings_rate * Decimal('1.5')))  # 20% savings = full points
        factors.append({
            'name': 'Savings Rate',
            'score': savings_points,
            'max': 30,
            'description': 'Percentage of income being saved'
        })
        total_score += savings_points

    # 2. Budget Adherence (25 points)    
    today = timezone.now()
    _, last_day = calendar.monthrange(today.year, today.month)
    month_start = today.replace(day=1)
    month_end = today.replace(day=last_day)
    
    total_budget = Budget.objects.filter(
        user=user,
        month__year=today.year,
        month__month=today.month
    ).aggregate(Sum('limit'))['limit__sum'] or 0
    
    total_spent = Expense.objects.filter(
        user=user,
        date__range=[month_start, month_end]
    ).aggregate(Sum('amount'))['amount__sum'] or 0
    
    if total_budget > 0:
        budget_ratio = (total_spent / total_budget) * 100
        if budget_ratio <= 100:
            budget_points = 25
        else:
            budget_points = max(0, 25 - int((budget_ratio - 100) / 4))
    else:
        budget_points = 0
    
    factors.append({
        'name': 'Budget Adherence',
        'score': budget_points,
        'max': 25,
        'description': 'How well you stick to your budget'
    })
    total_score += budget_points

    # 3. Bill Payment History (25 points)
    bill_points = min(25, profile.bill_payment_streak)
    factors.append({
        'name': 'Bill Payment History',
        'score': bill_points,
        'max': 25,
        'description': 'Consistent bill payment streak'
    })
    total_score += bill_points

    # Update profile with new score and factors
    profile.financial_health_score = total_score
    profile.financial_health_factors = {
        'score': total_score,
        'factors': factors,
        'last_updated': timezone.now().isoformat()    }
    profile.save()

    return total_score, factors

@login_required
def profile(request):
    image_form = ProfileImageForm(instance=request.user.profile)
    if request.method == 'POST':
        if 'profile_picture' in request.FILES:
            image_form = ProfileImageForm(request.POST, request.FILES, instance=request.user.profile)
            if image_form.is_valid():
                image_form.save()
                ActivityLog.objects.create(
                    user=request.user,
                    action='Profile Picture Updated',
                    details='User updated their profile picture'
                )
                messages.success(request, 'Your profile picture has been updated!')
                return redirect('profile')
        else:
            u_form = UserUpdateForm(request.POST, instance=request.user)
            p_form = ProfileUpdateForm(request.POST, request.FILES, instance=request.user.profile)
            if u_form.is_valid() and p_form.is_valid():
                u_form.save()
                p_form.save()
                ActivityLog.objects.create(
                    user=request.user,
                    action='Profile Updated',
                    details='User updated their profile information'
                )
                messages.success(request, 'Your profile has been updated!')
                return redirect('profile')
    else:
        u_form = UserUpdateForm(instance=request.user)
        p_form = ProfileUpdateForm(instance=request.user.profile)

    # Get all related data
    income_sources = IncomeSource.objects.filter(user=request.user)
    finance_goals = FinanceGoal.objects.filter(user=request.user)
    for goal in finance_goals:
        if goal.target_amount > 0:
            goal.progress = (goal.current_amount / goal.target_amount) * 100
        else:
            goal.progress = 0
    family_members = FamilyMember.objects.filter(user=request.user)
    activity_logs = ActivityLog.objects.filter(user=request.user).order_by('-created_at')[:10]

    # Calculate total income
    total_income = sum(source.amount for source in income_sources if source.is_active)
    
    # Calculate total savings
    total_savings = sum(goal.current_amount for goal in finance_goals)
    
    # Calculate progress towards monthly savings target
    monthly_target = request.user.profile.monthly_savings_target
    savings_progress = (total_savings / monthly_target * 100) if monthly_target > 0 else 0
    
    # Import necessary models for budget and expense data
    from budgets.models import Budget
    from expenses.models import Expense, Category
    from django.db.models import Sum
    from django.utils import timezone
    import datetime
    
    # Get current month's data
    today = timezone.now().date()
    first_day_current_month = today.replace(day=1)
    last_day_current_month = (today.replace(day=28) + datetime.timedelta(days=4)).replace(day=1) - datetime.timedelta(days=1)
    
    # Get previous month's data for comparison
    first_day_prev_month = (first_day_current_month - datetime.timedelta(days=1)).replace(day=1)
    last_day_prev_month = first_day_current_month - datetime.timedelta(days=1)
    
    # Budget data
    current_month_budgets = Budget.objects.filter(
        user=request.user,
        month__year=today.year,
        month__month=today.month
    )
    total_budget = current_month_budgets.aggregate(Sum('limit'))['limit__sum'] or 0
    
    # Expense data
    current_month_expenses = Expense.objects.filter(
        user=request.user,
        date__range=[first_day_current_month, last_day_current_month]
    )
    prev_month_expenses = Expense.objects.filter(
        user=request.user,
        date__range=[first_day_prev_month, last_day_prev_month]
    )
    
    total_spent = current_month_expenses.aggregate(Sum('amount'))['amount__sum'] or 0
    prev_month_spent = prev_month_expenses.aggregate(Sum('amount'))['amount__sum'] or 0
    
    # Calculate budget utilization
    budget_utilization = (total_spent / total_budget * 100) if total_budget > 0 else 0
    
    # Calculate top spending category
    category_spending = current_month_expenses.values('category__name').annotate(
        total=Sum('amount')
    ).order_by('-total')
    
    top_category = category_spending[0]['category__name'] if category_spending else "None"
    monthly_spending = total_spent
    
    # Calculate monthly change percentage
    if prev_month_spent > 0:
        monthly_change = ((total_spent - prev_month_spent) / prev_month_spent) * 100
    else:
        monthly_change = 0

    # Get upcoming bill payments
    upcoming_bills = RecurringBill.objects.filter(
        user=request.user,
        is_active=True,
        payment_status='pending'
    ).order_by('due_date')[:5]
    
    # Process bills for reminders
    today = timezone.now().date()
    bills_due_soon = []
    for bill in upcoming_bills:
        days_until_due = (bill.due_date - today).days
        if days_until_due <= bill.reminder_days:
            bills_due_soon.append({
                'bill': bill,
                'days_left': days_until_due
            })

    # Detect expense anomalies
    anomalies = []
    if category_spending and len(category_spending) > 0:
        # Get average spending per category over last 3 months
        three_months_ago = first_day_prev_month - datetime.timedelta(days=60)
        
        hist_expenses = Expense.objects.filter(
            user=request.user,
            date__range=[three_months_ago, last_day_prev_month]
        )
        
        hist_category_spending = hist_expenses.values('category__name').annotate(
            total=Sum('amount')
        )
        
        # Convert to dictionary for easy lookup
        avg_spending = {}
        for item in hist_category_spending:
            avg_spending[item['category__name']] = item['total'] / 3  # 3 months
        
        # Find anomalies (spending 50% more than average)
        for item in category_spending:
            category = item['category__name']
            current_amount = item['total']
            if category in avg_spending and avg_spending[category] > 0:
                avg_amount = avg_spending[category]
                if current_amount > (avg_amount * 1.5):  # 50% increase threshold
                    pct_change = ((current_amount - avg_amount) / avg_amount) * 100
                    anomalies.append({
                        'category': category,
                        'current': current_amount,
                        'usual': avg_amount,
                        'percent': pct_change
                    })
    
    # Calculate financial health score
    health_score, health_factors = calculate_financial_health(request.user)
    
    # Update profile with health score
    profile = request.user.profile
    profile.financial_health_score = health_score
    profile.last_score_update = timezone.now()
    profile.save()
    
    # Get active savings goals for simulator
    savings_goals = SavingsGoal.objects.filter(user=request.user)
    for goal in savings_goals:
        # Calculate months remaining
        today = timezone.now().date()
        months_remaining = (goal.target_date.year - today.year) * 12 + (goal.target_date.month - today.month)
        goal.months_remaining = max(1, months_remaining)
        
        # Calculate monthly contribution needed
        amount_needed = goal.target_amount - goal.current_savings
        goal.required_monthly = amount_needed / goal.months_remaining if goal.months_remaining > 0 else amount_needed
        
        # Calculate progress percentage
        goal.progress_pct = (goal.current_savings / goal.target_amount * 100) if goal.target_amount > 0 else 0
    
    context = {
        'u_form': u_form,
        'p_form': p_form,
        'image_form': image_form,
        'income_sources': income_sources,
        'finance_goals': finance_goals,
        'family_members': family_members,
        'activity_logs': activity_logs,
        'total_income': total_income,
        'total_savings': total_savings,
        'savings_progress': savings_progress,
        'monthly_target': monthly_target,
        # New context variables for the added cards
        'total_budget': total_budget,
        'total_spent': total_spent,
        'budget_utilization': budget_utilization,
        'top_category': top_category,
        'monthly_spending': monthly_spending,
        'monthly_change': monthly_change,
        # Additional dashboard features
        'upcoming_bills': upcoming_bills,
        'bills_due_soon': bills_due_soon,
        'anomalies': anomalies,
        'savings_goals': savings_goals,
        'health_score': health_score,
        'health_factors': health_factors
    }
    
    return render(request, 'users/profile.html', context)

@login_required
def add_income_source(request):
    if request.method == 'POST':
        form = IncomeSourceForm(request.POST)
        if form.is_valid():
            income_source = form.save(commit=False)
            income_source.user = request.user
            income_source.save()
            ActivityLog.objects.create(
                user=request.user,
                action='Income Source Added',
                details=f'Added new income source: {income_source.name}'
            )
            messages.success(request, 'Income source added successfully!')
            return redirect('reports_dashboard')  # Changed from 'profile' to 'reports_dashboard'
    else:
        form = IncomeSourceForm()
    return render(request, 'users/add_income_source.html', {'form': form})

@login_required
def add_finance_goal(request):
    if request.method == 'POST':
        form = FinanceGoalForm(request.POST)
        if form.is_valid():
            goal = form.save(commit=False)
            goal.user = request.user
            goal.save()
            ActivityLog.objects.create(
                user=request.user,
                action='Finance Goal Added',
                details=f'Added new finance goal: {goal.title}'
            )
            messages.success(request, 'Finance goal added successfully!')
            return redirect('profile')
    else:
        form = FinanceGoalForm()
    return render(request, 'users/add_finance_goal.html', {'form': form})

@login_required
def add_family_member(request):
    if request.method == 'POST':
        form = FamilyMemberForm(request.POST)
        if form.is_valid():
            member = form.save(commit=False)
            member.user = request.user
            member.save()
            ActivityLog.objects.create(
                user=request.user,
                action='Family Member Added',
                details=f'Added new family member: {member.name}'
            )
            messages.success(request, 'Family member added successfully!')
            return redirect('profile')
    else:
        form = FamilyMemberForm()
    return render(request, 'users/add_family_member.html', {'form': form})

@login_required
def add_bill(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        amount = request.POST.get('amount')
        due_date = request.POST.get('due_date')
        frequency = request.POST.get('frequency')
        category = request.POST.get('category')

        bill = RecurringBill.objects.create(
            user=request.user,
            name=name,
            amount=amount,
            due_date=due_date,
            frequency=frequency,
            category=category,
            is_active=True
        )

        ActivityLog.objects.create(
            user=request.user,
            action='Bill Added',
            details=f'Added new bill: {bill.name}'
        )

        messages.success(request, 'Bill added successfully!')
        return redirect('profile')

@login_required
def mark_bill_paid(request, bill_id):
    bill = get_object_or_404(RecurringBill, id=bill_id, user=request.user)
    bill.payment_status = 'paid'
    bill.last_paid_date = timezone.now().date()
    bill.save()

    # Update bill payment streak
    profile = request.user.profile
    profile.bill_payment_streak += 1
    profile.last_bill_payment = timezone.now().date()
    profile.save()

    # Create activity log
    ActivityLog.objects.create(
        user=request.user,
        action='Bill Paid',
        details=f'Marked {bill.name} as paid'
    )

    messages.success(request, 'Bill marked as paid!')
    return redirect('profile')

@login_required
def add_savings_goal(request):
    if request.method == 'POST':
        form = SavingsGoalForm(request.POST)
        if form.is_valid():
            goal = form.save(commit=False)
            goal.user = request.user
            goal.save()

            ActivityLog.objects.create(
                user=request.user,
                action='Savings Goal Created',
                details=f'Created new savings goal: {goal.name}'
            )

            messages.success(request, 'Savings goal created successfully!')
            return redirect('profile')
    else:
        form = SavingsGoalForm()
    
    return render(request, 'users/add_savings_goal.html', {'form': form})

@login_required
def update_savings(request, goal_id):
    if request.method == 'POST':
        goal = get_object_or_404(SavingsGoal, id=goal_id, user=request.user)
        amount = Decimal(request.POST.get('amount', 0))
        
        goal.current_savings += amount
        goal.save()

        # Update profile savings amount
        profile = request.user.profile
        profile.savings_amount += amount
        profile.save()

        ActivityLog.objects.create(
            user=request.user,
            action='Savings Updated',
            details=f'Added UGX {amount:,.0f} to {goal.name}'
        )

        messages.success(request, f'Added UGX {amount:,.0f} to your savings goal!')
        return redirect('profile')

    return HttpResponseBadRequest('Invalid request method')
