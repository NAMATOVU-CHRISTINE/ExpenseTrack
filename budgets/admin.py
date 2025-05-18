from django.contrib import admin
from django.utils.html import format_html
from django.contrib import messages
from .models import Budget, MonthlyBudget

class MonthlyBudgetInline(admin.TabularInline):
    model = MonthlyBudget
    extra = 1
    fields = ('month', 'amount')
    ordering = ('-month',)
    max_num = 12

@admin.register(Budget)
class BudgetAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'category', 'limit_display', 'progress_bar', 'month', 'recurrence', 'active')
    list_filter = ('active', 'recurrence', 'category', 'month', 'user')
    search_fields = ('category__name', 'user__username', 'description')
    inlines = [MonthlyBudgetInline]
    actions = ['duplicate_budget', 'activate_budgets', 'deactivate_budgets']
    
    def limit_display(self, obj):
        return format_html('<span style="font-weight: bold;">UGX {:,.2f}</span>', obj.limit)
    limit_display.short_description = 'Budget Limit'
    
    def progress_bar(self, obj):
        total_expenses = obj.get_total_expenses()
        if obj.limit:
            percentage = min((total_expenses / obj.limit) * 100, 100)
            color = 'success' if percentage < 80 else 'warning' if percentage < 100 else 'danger'
            return format_html(
                '''<div style="width: 100px;">
                      <div class="progress">
                        <div class="progress-bar bg-{}" role="progressbar" 
                             style="width: {}%;" title="UGX {:,.2f} of UGX {:,.2f}">
                          {:.1f}%
                        </div>
                      </div>
                   </div>''',
                color, percentage, total_expenses, obj.limit, percentage
            )
        return '-'
    progress_bar.short_description = 'Progress'

    def duplicate_budget(self, request, queryset):
        count = 0
        for budget in queryset:
            # Create new budget with same attributes but inactive
            budget.pk = None  # This will create a new instance
            budget.active = False
            budget.description = f"Copy of {budget.description or 'Budget'}"
            budget.save()
            count += 1
        
        messages.success(request, f'Successfully duplicated {count} budget(s).')
    duplicate_budget.short_description = "Duplicate selected budgets"

    def activate_budgets(self, request, queryset):
        updated = queryset.update(active=True)
        messages.success(request, f'{updated} budgets have been activated.')
    activate_budgets.short_description = "Activate selected budgets"

    def deactivate_budgets(self, request, queryset):
        updated = queryset.update(active=False)
        messages.success(request, f'{updated} budgets have been deactivated.')
    deactivate_budgets.short_description = "Deactivate selected budgets"

@admin.register(MonthlyBudget)
class MonthlyBudgetAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'amount_display', 'month', 'progress_display', 'remaining_budget')
    list_filter = ('month', 'category', 'user')
    search_fields = ('category__name', 'user__username')
    date_hierarchy = 'month'

    def amount_display(self, obj):
        return format_html('UGX {:,.2f}', obj.amount)
    amount_display.short_description = 'Amount'

    def progress_display(self, obj):
        expenses = obj.get_monthly_expenses()
        if obj.amount:
            percentage = min((expenses / obj.amount) * 100, 100)
            color = 'success' if percentage < 80 else 'warning' if percentage < 100 else 'danger'
            return format_html(
                '''<div class="progress" style="width: 100px;">
                     <div class="progress-bar bg-{}" role="progressbar" style="width: {}%"
                          title="UGX {:,.2f} of UGX {:,.2f}">
                       {:.1f}%
                     </div>
                   </div>''',
                color, percentage, expenses, obj.amount, percentage
            )
        return '-'
    progress_display.short_description = 'Usage'

    def remaining_budget(self, obj):
        expenses = obj.get_monthly_expenses()
        remaining = obj.amount - expenses
        color = 'green' if remaining > 0 else 'red'
        return format_html('<span style="color: {};">UGX {:,.2f}</span>', color, remaining)
    remaining_budget.short_description = 'Remaining'

    class Media:
        css = {
            'all': ['admin/css/vendor/bootstrap/css/bootstrap.min.css']
        }
