from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.views.decorators.http import require_POST
from django.utils import timezone
from django.http import JsonResponse
from django.db.models import Sum
from django.contrib.auth.models import User
from datetime import datetime, date, timedelta
import calendar
import json
import random
import logging
from .models import Expense, Category, SharedExpense, Receipt, CategoryRule, RecurringExpense
from budgets.models import Budget
from users.models import InAppNotification, IncomeSource
from .forms import (
    ExpenseForm, CategoryForm, BulkCategoryUpdateForm, 
    ShareExpenseForm, ReceiptUploadForm, RecurringExpenseForm,
    CategoryRuleForm
)
from django.conf import settings
from django.core.management.base import BaseCommand
import pytesseract
import cv2
import numpy as np
from PIL import Image
import re

# Configure logging
logger = logging.getLogger(__name__)

# Configure Tesseract path
pytesseract.pytesseract.tesseract_cmd = settings.TESSERACT_CMD

# Create your views here.

@login_required
def expense_dashboard(request):
    # Add logic to check and generate recurring expenses
    check_recurring_expenses(request.user)
    
    today = timezone.now().date()
    first_day = date(today.year, today.month, 1)
    last_day = date(today.year, today.month, calendar.monthrange(today.year, today.month)[1])
    
    # Get all expenses for filtering
    expenses = Expense.objects.filter(user=request.user).select_related('category')
    
    # Get recent expenses, ordered by date
    recent_expenses = expenses.order_by('-date')[:20]
    
    # Calculate current month's financial summary
    total_spent = expenses.filter(date__range=[first_day, last_day]).aggregate(total=Sum('amount'))['total'] or 0
    
    # Get total income from IncomeSource
    income_sources = IncomeSource.objects.filter(
        user=request.user,
        is_active=True
    )
    total_income = sum(
        source.amount * (
            1 if source.frequency == 'monthly'
            else 4.33 if source.frequency == 'weekly'
            else 2.17 if source.frequency == 'biweekly'
            else 0.33 if source.frequency == 'quarterly'
            else 0.083 if source.frequency == 'yearly'
            else 30 if source.frequency == 'daily'
            else 1
        )
        for source in income_sources
    )
    
    savings = total_income - total_spent
    savings_rate = (savings / total_income * 100) if total_income > 0 else 0
    
    # Calculate month-over-month changes
    prev_month_start = (first_day - timedelta(days=1)).replace(day=1)
    prev_month_end = first_day - timedelta(days=1)
    
    prev_month_spent = expenses.filter(date__range=[prev_month_start, prev_month_end]).aggregate(total=Sum('amount'))['total'] or 0
    
    expense_change = ((total_spent - prev_month_spent) / prev_month_spent * 100) if prev_month_spent > 0 else 0
    income_change = 0  # Since we're using active income sources, we'll skip the change calculation

    # Get budget status
    monthly_budget = Budget.objects.filter(
        user=request.user,
        month__year=today.year,
        month__month=today.month
    ).aggregate(total=Sum('limit'))['total'] or 0
    
    budget_status = (total_spent / monthly_budget * 100) if monthly_budget > 0 else 0
    
    # Calculate spending by category for charts
    categories = Category.objects.filter(user=request.user)
    category_spending = []
    for cat in categories:
        amount = expenses.filter(category=cat, date__range=[first_day, last_day]).aggregate(total=Sum('amount'))['total'] or 0
        if amount > 0:
            category_spending.append({
                'name': cat.name,
                'amount': float(amount),
                'color': cat.color or '#' + ''.join([random.choice('0123456789ABCDEF') for _ in range(6)])
            })
    
    # Sort categories by amount (highest first)
    category_spending = sorted(category_spending, key=lambda x: x['amount'], reverse=True)
    
    # Find top category
    top_category = None
    if category_spending:
        top_category = categories.filter(name=category_spending[0]['name']).first()
    
    # Monthly spending trend data for chart
    months = []
    spending_data = []
    
    for i in range(5, -1, -1):  # Last 6 months
        month_date = today - timedelta(days=30*i)
        month_start = date(month_date.year, month_date.month, 1)
        month_end = date(month_date.year, month_date.month, calendar.monthrange(month_date.year, month_date.month)[1])
        
        month_expenses = expenses.filter(
            date__range=[month_start, month_end]
        ).aggregate(total=Sum('amount'))['total'] or 0
        
        months.append(month_date.strftime('%b'))
        spending_data.append(float(month_expenses))
    
    # Prepare data for charts
    chart_data = {
        'categories': [cat['name'] for cat in category_spending[:7]],  # Top 7 categories
        'amounts': [cat['amount'] for cat in category_spending[:7]],
        'colors': [cat['color'] for cat in category_spending[:7]],
        'months': months,
        'spending_trend': spending_data
    }
    
    # Get all tags for filtering
    all_tags = set()
    for expense in expenses:
        all_tags.update(expense.tags)
    all_tags = sorted(list(all_tags))
    
    # Get recurring expenses and prepare calendar data
    recurring_expenses = RecurringExpense.objects.filter(user=request.user, status='active')
    upcoming_recurring_expenses = []
    recurring_expenses_json = []
    
    for expense in recurring_expenses:
        next_date = expense.get_next_date()
        if next_date and next_date <= today + timedelta(days=30):
            upcoming_recurring_expenses.append({
                'description': expense.description,
                'amount': expense.amount,
                'category': expense.category,
                'next_date': next_date
            })
            
            # Add to calendar events
            recurring_expenses_json.append({
                'title': expense.description,
                'start': next_date.strftime('%Y-%m-%d'),
                'backgroundColor': expense.category.color if expense.category else '#667eea',
                'borderColor': expense.category.color if expense.category else '#667eea',
                'extendedProps': {
                    'amount': str(expense.amount),
                    'category': expense.category.name if expense.category else 'Uncategorized',
                    'frequency': expense.get_frequency_display()
                }
            })
    
    context = {
        'expenses': recent_expenses,
        'total_spent': total_spent,
        'total_income': total_income,
        'savings': savings,
        'savings_rate': savings_rate,
        'income_change': income_change,
        'expense_change': expense_change,
        'budget_status': budget_status,
        'categories': categories,
        'top_category': top_category,
        'all_tags': all_tags,
        'recurring_expenses_json': json.dumps(recurring_expenses_json),
        'upcoming_recurring_expenses': upcoming_recurring_expenses,
        'chart_data': chart_data,
        'today': today,
        # Add context for features from expense_list
        'unprocessed_receipts': Receipt.objects.filter(user=request.user, is_processed=False),
        'shared_expenses': SharedExpense.objects.filter(expense__user=request.user),
        'category_rules': CategoryRule.objects.filter(user=request.user),
    }
    return render(request, 'expenses.html', context)

@login_required
def expense_list(request):
    expenses = Expense.objects.filter(user=request.user).select_related('category').order_by('-date')
    return render(request, 'expenses/expense_list.html', {'expenses': expenses})

@login_required
def expense_add(request):
    if request.method == 'POST':
        form = ExpenseForm(request.POST)
        if form.is_valid():
            expense = form.save(commit=False)
            expense.user = request.user
            expense.save()
            messages.success(request, 'Expense added successfully!')
            return redirect('expense_dashboard')
    else:
        form = ExpenseForm()
    return render(request, 'expenses/expense_add.html', {'form': form})

@login_required
def expense_edit(request, pk):
    expense = get_object_or_404(Expense, pk=pk, user=request.user)
    if request.method == 'POST':
        form = ExpenseForm(request.POST, instance=expense)
        if form.is_valid():
            form.save()
            messages.success(request, 'Expense updated successfully!')
            return redirect('expense_dashboard')
    else:
        form = ExpenseForm(instance=expense)
    return render(request, 'expenses/expense_edit.html', {'form': form, 'expense': expense})

@login_required
def expense_delete(request, pk):
    expense = get_object_or_404(Expense, pk=pk, user=request.user)
    if request.method == 'POST':
        expense.delete()
        messages.success(request, 'Expense deleted successfully!')
        return redirect('expense_dashboard')
    return render(request, 'expenses/expense_delete.html', {'expense': expense})

@login_required
def category_list(request):
    categories = Category.objects.filter(user=request.user)
    return render(request, 'expenses/category_list.html', {'categories': categories})

@login_required
def category_add(request):
    if request.method == 'POST':
        form = CategoryForm(request.POST)
        if form.is_valid():
            category = form.save(commit=False)
            category.user = request.user
            category.save()
            messages.success(request, 'Category added successfully!')
            return redirect('category_list')
    else:
        form = CategoryForm()
    return render(request, 'expenses/category_add.html', {'form': form})

@login_required
def category_edit(request, pk):
    category = get_object_or_404(Category, pk=pk, user=request.user)
    if request.method == 'POST':
        form = CategoryForm(request.POST, instance=category)
        if form.is_valid():
            form.save()
            messages.success(request, 'Category updated successfully!')
            return redirect('category_list')
    else:
        form = CategoryForm(instance=category)
    return render(request, 'expenses/category_add.html', {'form': form, 'edit': True})

@login_required
def add_category_rule(request):
    if request.method == 'POST':
        form = CategoryRuleForm(request.POST)
        if form.is_valid():
            rule = form.save(commit=False)
            rule.user = request.user
            rule.save()
            messages.success(request, 'Category rule added successfully!')
            return redirect('expense_dashboard')
    else:
        form = CategoryRuleForm()
    return render(request, 'expenses/category_rule_form.html', {'form': form})

@login_required
def suggest_category(request):
    if 'description' in request.GET:
        description = request.GET['description']
        # Find matching rule with highest priority
        rule = CategoryRule.objects.filter(
            user=request.user,
            is_active=True,
            pattern__iregex=description
        ).order_by('-priority').first()
        
        if rule:
            return JsonResponse({'category': rule.category.id})
    return JsonResponse({'category': None})

@login_required
def upload_receipt(request):
    if request.method == 'POST':
        form = ReceiptUploadForm(request.POST, request.FILES)
        if form.is_valid():
            receipt = form.save(commit=False)
            receipt.user = request.user
            
            # Save the receipt first
            receipt.save()
            
            try:
                # Process the image
                image = Image.open(receipt.image)
                # Convert to numpy array for OpenCV
                image_np = np.array(image)
                
                # Convert to grayscale
                gray = cv2.cvtColor(image_np, cv2.COLOR_BGR2GRAY)
                # Thresholding
                thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
                
                # Extract text using pytesseract
                extracted_text = pytesseract.image_to_string(thresh)
                receipt.extracted_text = extracted_text
                
                # Try to extract amount
                amount_pattern = r'\$?\d+\,?\d*\.\d{2}'
                amounts = re.findall(amount_pattern, extracted_text)
                if amounts:
                    receipt.extracted_amount = max([float(a.replace('$', '').replace(',', '')) for a in amounts])
                
                # Try to extract date
                date_patterns = [
                    r'\d{2}/\d{2}/\d{4}',
                    r'\d{2}-\d{2}-\d{4}',
                    r'\d{4}-\d{2}-\d{2}'
                ]
                for pattern in date_patterns:
                    dates = re.findall(pattern, extracted_text)
                    if dates:
                        try:
                            receipt.extracted_date = datetime.strptime(dates[0], pattern.replace('\\d', '%d').replace('\\', '%'))
                            break
                        except ValueError:
                            continue
                
                # Try to extract merchant name (first line that's not a date or amount)
                lines = extracted_text.split('\n')
                for line in lines:
                    line = line.strip()
                    if line and not re.search(amount_pattern, line) and not any(re.search(p, line) for p in date_patterns):
                        receipt.extracted_merchant = line[:200]  # Limit to model field size
                        break
                
                receipt.is_processed = True
                receipt.save()
                
                # Create expense if we have an amount
                if receipt.extracted_amount:
                    expense = Expense(
                        user=request.user,
                        amount=receipt.extracted_amount,
                        date=receipt.extracted_date or datetime.now().date(),
                        description=receipt.extracted_merchant or 'Receipt expense',
                        receipt=receipt
                    )
                    expense.save()
                    messages.success(request, 'Receipt processed and expense created successfully!')
                    return redirect('expense_edit', pk=expense.pk)
                
                messages.success(request, 'Receipt processed successfully!')
                return redirect('expense_list')
                
            except IOError as e:
                messages.error(request, f'Error reading receipt image: {str(e)}')
            except pytesseract.TesseractError as e:
                messages.error(request, f'Error processing receipt text: {str(e)}')
            except Exception as e:
                messages.error(request, f'Unexpected error processing receipt: {str(e)}')
                logger.exception('Error processing receipt')
            return redirect('expense_list')
    else:
        form = ReceiptUploadForm()
    
    return render(request, 'expenses/upload_receipt.html', {'form': form})

@login_required
def process_receipt(request, receipt_id):
    receipt = get_object_or_404(Receipt, id=receipt_id, user=request.user)
    
    if request.method == 'POST':
        amount = request.POST.get('amount')
        receipt_date = request.POST.get('date')
        merchant = request.POST.get('merchant')
        
        if amount:
            receipt.extracted_amount = float(amount)
        if receipt_date:
            receipt.extracted_date = datetime.strptime(receipt_date, '%Y-%m-%d')
        if merchant:
            receipt.extracted_merchant = merchant
        
        receipt.is_processed = True
        receipt.save()
        
        # Create or update expense
        expense = Expense.objects.filter(receipt=receipt).first()
        if not expense:
            expense = Expense(
                user=request.user,
                receipt=receipt
            )
        
        expense.amount = receipt.extracted_amount
        expense.date = receipt.extracted_date or datetime.now().date()
        expense.description = receipt.extracted_merchant or 'Receipt expense'
        expense.save()
        
        messages.success(request, 'Receipt processed and expense updated successfully!')
        return redirect('expense_edit', pk=expense.id)
    
    context = {
        'receipt': receipt,
        'extracted_text': receipt.extracted_text
    }
    return render(request, 'expenses/process_receipt.html', context)

@login_required
def share_expense(request, expense_id):
    expense = get_object_or_404(Expense, id=expense_id, user=request.user)
    shared_expenses = SharedExpense.objects.filter(expense=expense)
    
    if request.method == 'POST':
        form = ShareExpenseForm(request.POST, expense=expense)
        if form.is_valid():
            shared_expense = form.save(commit=False)
            shared_expense.expense = expense
            shared_expense.save()
            
            # Create notification for the user being shared with
            InAppNotification.objects.create(
                user=shared_expense.shared_with,
                message=f"{request.user.username} shared an expense of UGX {shared_expense.amount} with you",
                notif_type="info"
            )
            
            messages.success(request, "Expense shared successfully!")
            return redirect('expense_dashboard')
    else:
        form = ShareExpenseForm(expense=expense)
    
    return render(request, 'expenses/share_expense.html', {
        'expense': expense,
        'form': form,
        'shared_expenses': shared_expenses
    })

@login_required
def bulk_update_categories(request):
    if request.method == 'POST':
        form = BulkCategoryUpdateForm(request.user, request.POST)
        if form.is_valid():
            category = form.cleaned_data['category']
            expenses = form.cleaned_data['expenses']
            expenses.update(category=category)
            messages.success(request, f'Updated {expenses.count()} expenses to category {category.name}.')
            return redirect('expense_dashboard')
    else:
        form = BulkCategoryUpdateForm(request.user)
    return render(request, 'expenses/bulk_update.html', {'form': form})

@login_required
@require_POST
def ajax_update_notes_tags(request, expense_id):
    expense = get_object_or_404(Expense, id=expense_id, user=request.user)
    
    try:
        data = json.loads(request.body)
        notes = data.get('notes', '')
        tags = data.get('tags', [])
        tag_colors = data.get('tag_colors', [])
        
        # Update notes
        expense.notes = notes
        
        # Store tags and colors as JSON in a custom field
        # Since we don't have a separate tags model, we'll save them as a JSON field in the database
        # This will be handled in the save method of the expense model
        
        # Create a dictionary of tags and their colors
        tags_data = {}
        for i, tag in enumerate(tags):
            if tag.strip():  # Only add non-empty tags
                tags_data[tag.strip()] = tag_colors[i] if i < len(tag_colors) else '#8888ff'
        
        # Store the tags_data as JSON in a field (we'll add this field to the model)
        expense.tags_json = json.dumps(tags_data)
        expense.save()
        
        return JsonResponse({'success': True})
    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)})

@login_required
def expense_stop_recurring(request, pk):
    expense = get_object_or_404(Expense, pk=pk, user=request.user)
    if expense.is_recurring:
        expense.is_recurring = False
        expense.save()
        messages.success(request, 'Expense is no longer recurring.')
    return redirect('expense_dashboard')

@login_required
def recurring_expense_list(request):
    recurring_expenses = RecurringExpense.objects.filter(user=request.user).order_by('-created_at')
    
    # Group by status
    active_expenses = recurring_expenses.filter(status='active')
    paused_expenses = recurring_expenses.filter(status='paused')
    completed_expenses = recurring_expenses.filter(status='completed')
    
    # Get summary stats
    total_monthly = sum(expense.amount for expense in active_expenses if expense.frequency == 'monthly')
    
    # Calculate approximate monthly costs for other frequencies
    monthly_equivalent = 0
    for expense in active_expenses:
        if expense.frequency == 'daily':
            monthly_equivalent += expense.amount * 30
        elif expense.frequency == 'weekly':
            monthly_equivalent += expense.amount * 4.33
        elif expense.frequency == 'biweekly':
            monthly_equivalent += expense.amount * 2.17
        elif expense.frequency == 'quarterly':
            monthly_equivalent += expense.amount / 3
        elif expense.frequency == 'biannual':
            monthly_equivalent += expense.amount / 6
        elif expense.frequency == 'annual':
            monthly_equivalent += expense.amount / 12
    
    # Check for any recurring expenses that need to be generated
    check_recurring_expenses(request.user)
    
    # Get next upcoming generated expenses
    upcoming_expenses = []
    for expense in active_expenses:
        days_until = (expense.next_date - timezone.now().date()).days
        if days_until >= 0:
            upcoming_expenses.append({
                'expense': expense,
                'days_until': days_until,
                'next_date': expense.next_date
            })
    
    # Sort by days until due
    upcoming_expenses.sort(key=lambda x: x['days_until'])
    upcoming_expenses = upcoming_expenses[:5]  # Just show top 5
    
    # Get recently generated expenses
    recent_generated = Expense.objects.filter(
        user=request.user,
        is_recurring=True,
        recurring_expense__isnull=False
    ).order_by('-date')[:5]
    
    context = {
        'active_expenses': active_expenses,
        'paused_expenses': paused_expenses,
        'completed_expenses': completed_expenses,
        'total_monthly': total_monthly,
        'monthly_equivalent': monthly_equivalent,
        'upcoming_expenses': upcoming_expenses,
        'recent_generated': recent_generated
    }
    
    return render(request, 'expenses/recurring_list.html', context)

@login_required
def recurring_expense_add(request):
    if request.method == 'POST':
        form = RecurringExpenseForm(request.POST)
        if form.is_valid():
            recurring_expense = form.save(commit=False)
            recurring_expense.user = request.user
            recurring_expense.status = 'active'
            recurring_expense.save()
            
            messages.success(request, 'Recurring expense added successfully!')
            return redirect('recurring_expense_list')
    else:
        # Pre-fill date with today
        form = RecurringExpenseForm(initial={'start_date': timezone.now().date()})
    
    context = {
        'form': form,
        'title': 'Add Recurring Expense',
        'button_text': 'Create'
    }
    
    return render(request, 'expenses/recurring_form.html', context)

@login_required
def recurring_expense_edit(request, pk):
    recurring_expense = get_object_or_404(RecurringExpense, pk=pk, user=request.user)
    
    if request.method == 'POST':
        form = RecurringExpenseForm(request.POST, instance=recurring_expense)
        if form.is_valid():
            form.save()
            messages.success(request, 'Recurring expense updated successfully!')
            return redirect('recurring_expense_list')
    else:
        form = RecurringExpenseForm(instance=recurring_expense)
    
    context = {
        'form': form,
        'recurring_expense': recurring_expense,
        'title': 'Edit Recurring Expense',
        'button_text': 'Update'
    }
    
    return render(request, 'expenses/recurring_form.html', context)

@login_required
def recurring_expense_delete(request, pk):
    recurring_expense = get_object_or_404(RecurringExpense, pk=pk, user=request.user)
    
    if request.method == 'POST':
        recurring_expense.delete()
        messages.success(request, 'Recurring expense deleted successfully!')
        return redirect('recurring_expense_list')
    
    context = {
        'recurring_expense': recurring_expense
    }
    
    return render(request, 'expenses/recurring_confirm_delete.html', context)

@login_required
def recurring_expense_toggle(request, pk):
    recurring_expense = get_object_or_404(RecurringExpense, pk=pk, user=request.user)
    
    if recurring_expense.status == 'active':
        recurring_expense.status = 'paused'
        messages.success(request, 'Recurring expense paused!')
    else:
        recurring_expense.status = 'active'
        messages.success(request, 'Recurring expense activated!')
    
    recurring_expense.save()
    return redirect('recurring_expense_list')

@login_required
def generate_now(request, pk):
    recurring_expense = get_object_or_404(RecurringExpense, pk=pk, user=request.user)
    
    # Allow generating even if not due
    expense = Expense(
        user=request.user,
        category=recurring_expense.category,
        amount=recurring_expense.amount,
        description=recurring_expense.description,
        date=timezone.now().date(),
        is_recurring=True,
        recurring_expense=recurring_expense,
        notes=recurring_expense.notes
    )
    expense.save()
    
    # Update recurring expense
    recurring_expense.last_generated = timezone.now().date()
    recurring_expense.next_date = recurring_expense.calculate_next_date()
    recurring_expense.save()
    
    messages.success(request, 'Expense generated successfully!')
    return redirect('recurring_expense_list')

def check_recurring_expenses(user):
    """Automatically generate due recurring expenses"""
    today = timezone.now().date()
    
    # Find recurring expenses that are due
    due_expenses = RecurringExpense.objects.filter(
        user=user,
        status='active',
        next_date__lte=today
    )
    
    # Generate expenses for each due recurring expense
    for recurring_expense in due_expenses:
        recurring_expense.generate_expense()

@login_required
def recurring_expense_dashboard(request):
    """Dashboard view showing an overview of recurring expenses"""
    recurring_expenses = RecurringExpense.objects.filter(user=request.user)
    
    # Group expenses by category
    expenses_by_category = {}
    categories = Category.objects.filter(user=request.user)
    
    for category in categories:
        expenses = recurring_expenses.filter(category=category, status='active')
        if expenses.exists():
            total = sum(expense.amount for expense in expenses)
            expenses_by_category[category] = {
                'expenses': expenses,
                'total': total
            }
    
    # Calculate statistics
    total_recurring = sum(item['total'] for item in expenses_by_category.values())
    
    # Group by frequency
    expenses_by_frequency = {}
    for freq, _ in RecurringExpense.FREQUENCY_CHOICES:
        expenses = recurring_expenses.filter(frequency=freq, status='active')
        if expenses.exists():
            total = sum(expense.amount for expense in expenses)
            expenses_by_frequency[freq] = {
                'expenses': expenses,
                'total': total,
                'display': dict(RecurringExpense.FREQUENCY_CHOICES)[freq]
            }
    
    context = {
        'expenses_by_category': expenses_by_category,
        'expenses_by_frequency': expenses_by_frequency,
        'total_recurring': total_recurring,
        'recurring_count': recurring_expenses.filter(status='active').count()
    }
    
    return render(request, 'expenses/recurring_dashboard.html', context)

# Management command for seeding default categories
class Command(BaseCommand):
    help = 'Seed 20 default categories for all users'
    def handle(self, *args, **kwargs):
        default_categories = [
            ('Auto', 'fa-car', '#388e3c'),
            ('Bills', 'fa-money-bill', '#388e3c'),
            ('Clothes', 'fa-tshirt', '#388e3c'),
            ('Entertainment', 'fa-gamepad', '#388e3c'),
            ('Food', 'fa-utensils', '#388e3c'),
            ('Fuel', 'fa-gas-pump', '#388e3c'),
            ('General', 'fa-tags', '#388e3c'),
            ('Gifts', 'fa-gift', '#388e3c'),
            ('Health', 'fa-briefcase-medical', '#388e3c'),
            ('Holidays', 'fa-umbrella-beach', '#388e3c'),
            ('Home', 'fa-home', '#388e3c'),
            ('Kids', 'fa-child', '#388e3c'),
            ('Shopping', 'fa-shopping-cart', '#388e3c'),
            ('Sports', 'fa-trophy', '#388e3c'),
            ('Transport', 'fa-bus', '#388e3c'),
            ('Education', 'fa-graduation-cap', '#388e3c'),
            ('Charity', 'fa-heart', '#388e3c'),
            ('Pets', 'fa-paw', '#388e3c'),
            ('Travel', 'fa-plane', '#388e3c'),
            ('Repairs', 'fa-tools', '#388e3c'),
        ]
        for user in User.objects.all():
            for name, icon, color in default_categories:
                if not Category.objects.filter(user=user, name=name).exists():
                    Category.objects.create(user=user, name=name, icon=icon, color=color)
        self.stdout.write(self.style.SUCCESS('Default categories seeded for all users.'))
