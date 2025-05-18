from django.contrib import admin
from .models import Category, Expense, Receipt, SharedExpense, CategoryRule, RecurringExpense

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'user')
    search_fields = ('name',)

@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'amount', 'date', 'is_recurring')
    list_filter = ('category', 'is_recurring')
    search_fields = ('description',)

admin.site.register(Receipt)
admin.site.register(SharedExpense)
admin.site.register(CategoryRule)
admin.site.register(RecurringExpense)
