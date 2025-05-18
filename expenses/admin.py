from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.db.models import Sum
from django.contrib import messages
from django.core.exceptions import ValidationError
from .models import Category, Expense, Receipt, SharedExpense, CategoryRule, RecurringExpense

class CategoryInline(admin.TabularInline):
    model = CategoryRule
    extra = 1
    fields = ('pattern', 'priority', 'is_active')

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'color_display', 'icon_display', 'expense_count', 'total_amount', 'created_at')
    list_filter = ('created_at', 'user', 'icon')
    search_fields = ('name', 'user__username', 'keywords')
    readonly_fields = ('created_at', 'updated_at')
    inlines = [CategoryInline]
    actions = ['merge_categories']

    def color_display(self, obj):
        return format_html(
            '<span style="background-color: {}; color: white; padding: 5px; border-radius: 3px;">{}</span>',
            obj.color,
            obj.color
        )
    color_display.short_description = 'Color'

    def icon_display(self, obj):
        return format_html('<i class="fa {}" style="font-size: 20px;"></i>', obj.icon)
    icon_display.short_description = 'Icon'

    def expense_count(self, obj):
        return obj.expense_set.count()
    expense_count.short_description = 'Number of Expenses'

    def total_amount(self, obj):
        total = obj.expense_set.aggregate(Sum('amount'))['amount__sum']
        return f"UGX {total or 0:,.2f}"
    total_amount.short_description = 'Total Amount'

    def merge_categories(self, request, queryset):
        if queryset.count() < 2:
            self.message_user(request, "Please select at least two categories to merge", level=messages.ERROR)
            return
        
        primary_category = queryset.first()
        other_categories = queryset[1:]
        
        try:
            for category in other_categories:
                # Move all expenses to primary category
                for expense in category.expense_set.all():
                    expense.category = primary_category
                    expense.save()
                # Move all rules to primary category
                for rule in category.categoryrule_set.all():
                    rule.category = primary_category
                    rule.save()
                category.delete()
            
            self.message_user(request, f"Successfully merged {queryset.count()} categories")
        except Exception as exc:
            self.message_user(request, f"Error merging categories: {str(exc)}", level=messages.ERROR)
            raise ValidationError("Failed to merge categories") from exc
    
    merge_categories.short_description = "Merge selected categories"

class SharedExpenseInline(admin.TabularInline):
    model = SharedExpense
    extra = 1
    fields = ('shared_with', 'amount', 'is_paid')

@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ('id', 'description', 'user', 'category_link', 'amount_display', 'date', 'is_recurring', 'receipt_status', 'shared_status')
    list_filter = ('category', 'is_recurring', 'date', 'created_at', 'user')
    search_fields = ('description', 'user__username', 'category__name')
    readonly_fields = ('created_at', 'updated_at')
    date_hierarchy = 'date'
    list_per_page = 20
    inlines = [SharedExpenseInline]
    actions = ['mark_as_recurring', 'export_as_csv']

    def category_link(self, obj):
        if obj.category:
            url = reverse('admin:expenses_category_change', args=[obj.category.id])
            return format_html('<a href="{}">{}</a>', url, obj.category.name)
        return "-"
    category_link.short_description = 'Category'

    def amount_display(self, obj):
        return format_html('<span style="color: {};">UGX {:,.2f}</span>', 
                         'red' if obj.amount < 0 else 'green', 
                         obj.amount)
    amount_display.short_description = 'Amount'

    def receipt_status(self, obj):
        if obj.receipt:
            url = reverse('admin:expenses_receipt_change', args=[obj.receipt.id])
            return format_html('<a href="{}"><span style="color: green;">✓</span></a>', url)
        return format_html('<span style="color: red;">✗</span>')
    receipt_status.short_description = 'Receipt'

    def shared_status(self, obj):
        shared_count = obj.sharedexpense_set.count()
        if shared_count > 0:
            return format_html('<span title="Shared with {} users">🔗 {}</span>', shared_count, shared_count)
        return ''
    shared_status.short_description = 'Shared'

    def mark_as_recurring(self, request, queryset):
        updated = queryset.update(is_recurring=True)
        self.message_user(request, f'{updated} expenses marked as recurring.')
    mark_as_recurring.short_description = "Mark selected expenses as recurring"

    def export_as_csv(self, _, queryset):
        import csv
        from django.http import HttpResponse
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="expenses.csv"'
        
        writer = csv.writer(response)
        writer.writerow(['Description', 'Amount', 'Category', 'Date', 'Is Recurring'])
        
        for expense in queryset:
            writer.writerow([
                expense.description,
                expense.amount,
                expense.category.name if expense.category else '',
                expense.date,
                expense.is_recurring
            ])
        
        return response
    export_as_csv.short_description = "Export selected expenses as CSV"

@admin.register(Receipt)
class ReceiptAdmin(admin.ModelAdmin):
    list_display = ('user', 'expense_link', 'created_at', 'is_processed', 'extracted_amount', 'extracted_merchant')
    list_filter = ('is_processed', 'created_at', 'user')
    search_fields = ('extracted_text', 'extracted_merchant', 'user__username')
    readonly_fields = ('extracted_text', 'extracted_amount', 'extracted_date', 'extracted_merchant', 'is_processed')
    
    def expense_link(self, obj):
        if hasattr(obj, 'expense'):
            url = reverse('admin:expenses_expense_change', args=[obj.expense.id])
            return format_html('<a href="{}">{}</a>', url, obj.expense.description)
        return '-'
    expense_link.short_description = 'Related Expense'

@admin.register(RecurringExpense)
class RecurringExpenseAdmin(admin.ModelAdmin):
    list_display = ('user', 'description', 'amount', 'frequency', 'status', 'next_date')
    list_filter = ('frequency', 'status', 'category')
    search_fields = ('description', 'user__username')
    readonly_fields = ('last_generated', 'created_at', 'updated_at')
    date_hierarchy = 'start_date'
    
    def clean_instance(self, instance):
        if instance.end_date and instance.start_date and instance.start_date > instance.end_date:
            raise ValidationError({'end_date': 'End date must be after start date'})
        return instance
