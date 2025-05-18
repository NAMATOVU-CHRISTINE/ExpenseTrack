from django.contrib import admin
from .models import Budget, MonthlyBudget

@admin.register(Budget)
class BudgetAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'limit', 'month', 'recurrence', 'active')

@admin.register(MonthlyBudget)
class MonthlyBudgetAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'amount', 'month')
