from django.contrib.auth.models import User
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone

# Create your models here.

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)
    monthly_savings_target = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    preferred_currency = models.CharField(max_length=3, default='UGX')
    dark_mode = models.BooleanField(default=False)
    email_notifications = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    low_balance_threshold = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    # Financial dashboard fields
    savings_amount = models.DecimalField(max_digits=12, decimal_places=2, default=520000)
    savings_target = models.DecimalField(max_digits=12, decimal_places=2, default=1000000)
    monthly_income = models.DecimalField(max_digits=12, decimal_places=2, default=700000)
    # Add fields for financial health score
    financial_health_score = models.IntegerField(default=0)
    financial_health_factors = models.JSONField(default=dict)
    savings_streak = models.IntegerField(default=0)
    last_bill_payment = models.DateField(null=True, blank=True)
    bill_payment_streak = models.IntegerField(default=0)
    emergency_fund_ratio = models.DecimalField(max_digits=5, decimal_places=2, default=0)

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
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    action = models.CharField(max_length=100)
    details = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.action}"

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
