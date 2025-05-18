from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
import json
from datetime import datetime, timedelta

class Category(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    keywords = models.TextField(blank=True, help_text="Comma-separated keywords for auto-categorization")
    color = models.CharField(max_length=7, default="#667eea")
    icon = models.CharField(max_length=50, default="fa-tag")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Expense(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.CharField(max_length=200)
    date = models.DateField()
    is_recurring = models.BooleanField(default=False)
    recurring_expense = models.ForeignKey('RecurringExpense', on_delete=models.SET_NULL, null=True, blank=True, related_name='generated_expenses')
    receipt = models.ForeignKey('Receipt', on_delete=models.SET_NULL, null=True, blank=True)
    notes = models.TextField(blank=True, help_text="Optional notes for this expense")
    tags_json = models.TextField(blank=True, null=True, default='{}')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    @property
    def tags_with_colors(self):
        """Return a list of (tag, color) tuples from the JSON data"""
        if not self.tags_json:
            return []
        try:
            tags_data = json.loads(self.tags_json)
            return [(tag, color) for tag, color in tags_data.items()]
        except:
            return []
    
    @property
    def tags(self):
        """Return just the list of tags"""
        return [tag for tag, _ in self.tags_with_colors]

    def __str__(self):
        return f"{self.description} - UGX {self.amount}"

class RecurringExpense(models.Model):
    FREQUENCY_CHOICES = [
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
        ('biweekly', 'Bi-weekly'),
        ('monthly', 'Monthly'),
        ('quarterly', 'Quarterly'),
        ('biannual', 'Bi-annual'),
        ('annual', 'Annual'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('paused', 'Paused'),
        ('completed', 'Completed'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.CharField(max_length=200)
    frequency = models.CharField(max_length=10, choices=FREQUENCY_CHOICES, default='monthly')
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True, help_text="Leave blank for indefinite recurring expenses")
    next_date = models.DateField(help_text="Next date this expense will be generated")
    day_of_month = models.IntegerField(null=True, blank=True, help_text="Day of month for monthly expenses (1-31)")
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')
    last_generated = models.DateField(null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.description} - {self.get_frequency_display()} (UGX {self.amount})"
    
    def get_next_date(self):
        """Returns the next date this expense will be generated"""
        return self.next_date if self.status == 'active' else None
        
    def calculate_next_date(self):
        if not self.last_generated:
            return self.start_date
            
        current_date = self.last_generated
        
        if self.frequency == 'daily':
            next_date = current_date + timedelta(days=1)
        elif self.frequency == 'weekly':
            next_date = current_date + timedelta(weeks=1)
        elif self.frequency == 'biweekly':
            next_date = current_date + timedelta(weeks=2)
        elif self.frequency == 'monthly':
            # Handle month rollover properly
            month = current_date.month + 1
            year = current_date.year
            if month > 12:
                month = 1
                year += 1
                
            # Handle day of month preference if set
            if self.day_of_month:
                day = min(self.day_of_month, 28)  # Ensure valid for all months
            else:
                day = current_date.day
                
            # Adjust for months with fewer days
            while True:
                try:
                    next_date = datetime(year, month, day).date()
                    break
                except ValueError:
                    day -= 1
        elif self.frequency == 'quarterly':
            # Add 3 months
            month = current_date.month + 3
            year = current_date.year
            if month > 12:
                month = month - 12
                year += 1
            
            day = min(current_date.day, 28)
            next_date = datetime(year, month, day).date()
        elif self.frequency == 'biannual':
            # Add 6 months
            month = current_date.month + 6
            year = current_date.year
            if month > 12:
                month = month - 12
                year += 1
            
            day = min(current_date.day, 28)
            next_date = datetime(year, month, day).date()
        elif self.frequency == 'annual':
            # Add a year
            next_date = datetime(current_date.year + 1, 
                                current_date.month, 
                                min(current_date.day, 28)).date()
        else:
            # Default to monthly if unknown frequency
            next_date = current_date + timedelta(days=30)
            
        return next_date
    
    def is_due(self):
        """Check if this recurring expense is due to be generated"""
        today = timezone.now().date()
        return (
            self.status == 'active' and 
            self.next_date <= today and
            (self.end_date is None or self.end_date >= today)
        )
    
    def generate_expense(self):
        """Generate an actual expense from this recurring template"""
        if not self.is_due():
            return None
            
        expense = Expense(
            user=self.user,
            category=self.category,
            amount=self.amount,
            description=self.description,
            date=self.next_date,
            is_recurring=True,
            recurring_expense=self,
            notes=self.notes
        )
        expense.save()
        
        # Update recurring expense
        self.last_generated = self.next_date
        self.next_date = self.calculate_next_date()
        
        # Check if we've reached the end date
        if self.end_date and self.next_date > self.end_date:
            self.status = 'completed'
            
        self.save()
        
        return expense

class Receipt(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    image = models.ImageField(upload_to='receipts/')
    extracted_text = models.TextField(blank=True)
    extracted_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    extracted_date = models.DateField(null=True, blank=True)
    extracted_merchant = models.CharField(max_length=200, blank=True)
    is_processed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Receipt {self.id} - {self.user.username}"

class SharedExpense(models.Model):
    expense = models.ForeignKey(Expense, on_delete=models.CASCADE)
    shared_with = models.ForeignKey(User, on_delete=models.CASCADE, related_name='shared_expenses')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    is_paid = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.expense.description} - Shared with {self.shared_with.username}"

class CategoryRule(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    pattern = models.CharField(max_length=200, help_text="Regex pattern for matching")
    priority = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.category.name} - {self.pattern}"
