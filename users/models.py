from django.contrib.auth.models import User
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone

# Create your models here.

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True, default='assets/default/default-avatar.png')    
    monthly_savings_target = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    last_savings_date = models.DateField(null=True, blank=True)
    preferred_currency = models.CharField(max_length=3, default='UGX')
    dark_mode = models.BooleanField(default=False)
    email_notifications = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    low_balance_threshold = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    # Financial Status Fields
    savings_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    savings_target = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    monthly_income = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    disposable_income = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    
    # Financial Health Metrics
    financial_health_score = models.IntegerField(default=0)
    financial_health_factors = models.JSONField(default=dict)
    savings_streak = models.IntegerField(default=0)
    last_bill_payment = models.DateField(null=True, blank=True)
    bill_payment_streak = models.IntegerField(default=0)
    emergency_fund_ratio = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    
    # Settings and Preferences
    budget_notification_threshold = models.IntegerField(default=80)  # Notify when budget usage reaches this percentage
    savings_notification_enabled = models.BooleanField(default=True)
    bills_notification_enabled = models.BooleanField(default=True)
    expense_anomaly_alerts = models.BooleanField(default=True)
    weekly_report_enabled = models.BooleanField(default=True)
    
    def calculate_savings_progress(self):
        if self.savings_target > 0:
            return (self.savings_amount / self.savings_target) * 100
        return 0
    
    def update_emergency_fund_ratio(self):
        monthly_expenses = self.user.expense_set.filter(
            date__gte=timezone.now() - timezone.timedelta(days=30)
        ).aggregate(models.Sum('amount'))['amount__sum'] or 0
        
        if monthly_expenses > 0:
            self.emergency_fund_ratio = self.savings_amount / monthly_expenses
            self.save(update_fields=['emergency_fund_ratio'])
    
    def update_health_score(self):
        """Updates the financial health score based on various factors"""
        score = 50  # Base score
        
        # Factor 1: Emergency Fund (up to +20 points)
        if self.emergency_fund_ratio >= 6:  # 6 months of expenses
            score += 20
        elif self.emergency_fund_ratio >= 3:  # 3 months of expenses
            score += 10
        
        # Factor 2: Savings Target Progress (up to +15 points)
        savings_progress = self.calculate_savings_progress()
        score += min(15, int(savings_progress * 0.15))
        
        # Factor 3: Bill Payment Streak (up to +10 points)
        score += min(10, self.bill_payment_streak)
        
        # Factor 4: Savings Streak (up to +5 points)
        score += min(5, self.savings_streak)
        
        self.financial_health_score = min(100, score)
        self.save(update_fields=['financial_health_score'])
    
    def __str__(self):
        return f"{self.user.username}'s Profile"

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()

class IncomeSource(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    frequency = models.CharField(max_length=20, choices=[
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
        ('yearly', 'Yearly')
    ])
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s {self.name}"

class FinanceGoal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    target_amount = models.DecimalField(max_digits=10, decimal_places=2)
    current_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    deadline = models.DateField()
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s {self.title}"

class ActivityLog(models.Model):
    ACTIVITY_TYPES = [
        ('savings_added', 'Savings Added'),
        ('expense_added', 'Expense Added'),
        ('bill_paid', 'Bill Paid'),
        ('goal_reached', 'Goal Reached'),
        ('budget_exceeded', 'Budget Exceeded'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    activity_type = models.CharField(max_length=50, choices=ACTIVITY_TYPES, default='savings_added')
    description = models.TextField(default='', blank=True)
    amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    date = models.DateField(default=timezone.now)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.activity_type} - {self.date}"

class FamilyMember(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='family_members')
    name = models.CharField(max_length=100)
    relationship = models.CharField(max_length=50)
    email = models.EmailField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s {self.relationship} - {self.name}"

class RecurringBill(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    due_date = models.DateField()
    frequency = models.CharField(max_length=20, choices=[('monthly', 'Monthly'), ('weekly', 'Weekly')])
    is_active = models.BooleanField(default=True)
    category = models.CharField(max_length=50, blank=True, null=True)
    payment_status = models.CharField(
        max_length=20,
        choices=[('paid', 'Paid'), ('pending', 'Pending'), ('overdue', 'Overdue')],
        default='pending'
    )
    reminder_days = models.IntegerField(default=3)  # Days before due date to send reminder
    last_paid_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.name} ({self.user.username})"

class InAppNotification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    message = models.CharField(max_length=255)
    notif_type = models.CharField(max_length=50, default='info')  # e.g., info, warning, success
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username}: {self.message[:30]}..."

class SavingsGoal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    target_amount = models.DecimalField(max_digits=10, decimal_places=2)
    current_savings = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    target_date = models.DateField()
    monthly_contribution = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    interest_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)  # Annual interest rate
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s {self.name} Goal"

class ExpenseAnomaly(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    usual_amount = models.DecimalField(max_digits=10, decimal_places=2)
    percentage_change = models.DecimalField(max_digits=10, decimal_places=2)
    date_detected = models.DateTimeField(auto_now_add=True)
    is_acknowledged = models.BooleanField(default=False)
    
    def __str__(self):
        return f"{self.user.username}'s anomaly in {self.category}"
