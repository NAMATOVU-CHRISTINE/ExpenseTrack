from django.db import models
from django.contrib.auth.models import User
from expenses.models import Category

# Create your models here.

class Budget(models.Model):
    RECURRENCE_CHOICES = [
        ('one-time', 'One-time'),
        ('monthly', 'Monthly'),
        ('yearly', 'Yearly'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    limit = models.DecimalField(max_digits=10, decimal_places=2)
    month = models.DateField()
    description = models.TextField(blank=True, null=True)
    color = models.CharField(max_length=20, blank=True, null=True)
    notifications = models.BooleanField(default=False)
    recurrence = models.CharField(max_length=10, choices=RECURRENCE_CHOICES, default='one-time')
    active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.user.username} - {self.category.name} - {self.month}"

class MonthlyBudget(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    month = models.DateField()  # e.g., 2024-06-01 for June 2024

    def __str__(self):
        return f"{self.category} - {self.month.strftime('%B %Y')}"
