from django.contrib import admin
from django.utils.html import format_html
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.models import User
from django.db.models import Sum
from django.utils import timezone
from django.urls import reverse
from django.apps import apps
from .models import (
    Profile, RecurringBill, InAppNotification, FinanceGoal, 
    FamilyMember, ActivityLog
)

class ProfileInline(admin.StackedInline):
    model = Profile
    can_delete = False
    fields = ('profile_picture', 'monthly_savings_target', 'preferred_currency', 
             'dark_mode', 'email_notifications', 'financial_health_score')
    readonly_fields = ('financial_health_score',)

class FinanceGoalInline(admin.TabularInline):
    model = FinanceGoal
    extra = 1
    fields = ('title', 'target_amount', 'current_amount', 'deadline', 'is_completed')

class FamilyMemberInline(admin.TabularInline):
    model = FamilyMember
    extra = 1
    fields = ('name', 'relationship', 'email', 'is_active')

class CustomUserAdmin(BaseUserAdmin):
    inlines = (ProfileInline, FinanceGoalInline, FamilyMemberInline)
    list_display = ('username', 'email', 'full_name', 'savings_progress', 'expenses_this_month', 'active_goals', 'date_joined')
    list_filter = BaseUserAdmin.list_filter + ('profile__preferred_currency', 'profile__dark_mode', 'profile__email_notifications')
    actions = ['reset_financial_health', 'export_financial_summary']
    
    def full_name(self, obj):
        return obj.get_full_name() or obj.username
    full_name.short_description = 'Name'

    def savings_progress(self, obj):
        if hasattr(obj, 'profile'):
            target = obj.profile.monthly_savings_target
            current = obj.profile.savings_amount
            if target:
                percentage = min((current / target) * 100, 100)
                color = 'success' if percentage >= 100 else 'warning' if percentage >= 70 else 'danger'
                return format_html(
                    '''<div class="progress" style="width: 100px;">
                         <div class="progress-bar bg-{}" role="progressbar" style="width: {}%"
                              title="UGX {:,.2f} / {:,.2f}">
                           {:.1f}%
                         </div>
                       </div>''',
                    color, percentage, current, target, percentage
                )
        return '-'
    savings_progress.short_description = 'Savings Progress'

    def expenses_this_month(self, obj):
        Expense = apps.get_model('expenses', 'Expense')
        today = timezone.now()
        total = Expense.objects.filter(
            user=obj,
            date__year=today.year,
            date__month=today.month
        ).aggregate(Sum('amount'))['amount__sum'] or 0
        return format_html('UGX {:,.2f}', total)
    expenses_this_month.short_description = 'This Month'

    def active_goals(self, obj):
        count = obj.financegoal_set.filter(is_completed=False).count()
        return format_html(
            '<a href="{}?user__id__exact={}&is_completed__exact=0">{} active</a>',
            reverse('admin:users_financegoal_changelist'),
            obj.id,
            count
        )
    active_goals.short_description = 'Goals'

    def reset_financial_health(self, request, queryset):
        for user in queryset:
            if hasattr(user, 'profile'):
                user.profile.financial_health_score = 0
                user.profile.save()
        self.message_user(request, f'Reset financial health score for {queryset.count()} users')
    reset_financial_health.short_description = "Reset financial health scores"

    def export_financial_summary(self, _, queryset):
        import csv
        from django.http import HttpResponse
        Expense = apps.get_model('expenses', 'Expense')

        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="financial_summary.csv"'
        writer = csv.writer(response)
        writer.writerow([
            'Username', 'Email', 'Monthly Target', 'Current Savings',
            'Total Expenses', 'Active Goals', 'Health Score'
        ])

        for user in queryset:
            profile = user.profile
            total_expenses = Expense.objects.filter(user=user).aggregate(Sum('amount'))['amount__sum'] or 0
            active_goals = user.financegoal_set.filter(is_completed=False).count()

            writer.writerow([
                user.username,
                user.email,
                profile.monthly_savings_target,
                profile.savings_amount,
                total_expenses,
                active_goals,
                profile.financial_health_score
            ])

        return response
    export_financial_summary.short_description = "Export financial summary"

# Re-register UserAdmin
admin.site.unregister(User)
admin.site.register(User, CustomUserAdmin)

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'monthly_target_display', 'savings_amount_display', 
                   'preferred_currency', 'financial_health_score', 'user_activity')
    list_filter = ('preferred_currency', 'dark_mode', 'email_notifications', 
                  'created_at', ('financial_health_score', admin.EmptyFieldListFilter))
    search_fields = ('user__username', 'user__email')
    readonly_fields = ('created_at', 'updated_at', 'financial_health_score')
    actions = ['recalculate_health_scores']

    def monthly_target_display(self, obj):
        return format_html('UGX {:,.2f}', obj.monthly_savings_target)
    monthly_target_display.short_description = 'Monthly Target'

    def savings_amount_display(self, obj):
        return format_html('UGX {:,.2f}', obj.savings_amount)
    savings_amount_display.short_description = 'Current Savings'

    def user_activity(self, obj):
        month_ago = timezone.now() - timezone.timedelta(days=30)
        activity_count = ActivityLog.objects.filter(
            user=obj.user,
            created_at__gte=month_ago
        ).count()
        return f'{activity_count} actions in 30 days'
    user_activity.short_description = 'Recent Activity'

    def recalculate_health_scores(self, request, queryset):
        for profile in queryset:
            score = self._calculate_financial_health(profile)
            profile.financial_health_score = score
            profile.save()
        self.message_user(request, f'Recalculated health scores for {queryset.count()} profiles')
    recalculate_health_scores.short_description = "Recalculate health scores"

    def _calculate_financial_health(self, profile):
        # Basic score starts at 50
        score = 50
        
        # Savings ratio (up to +30 points)
        if profile.monthly_savings_target > 0:
            savings_ratio = profile.savings_amount / profile.monthly_savings_target
            score += min(30, savings_ratio * 30)
        
        # Regular expense tracking (+10 points)
        month_ago = timezone.now() - timezone.timedelta(days=30)
        Expense = apps.get_model('expenses', 'Expense')
        if Expense.objects.filter(user=profile.user, created_at__gte=month_ago).exists():
            score += 10
        
        # Active budget management (+10 points)
        Budget = apps.get_model('budgets', 'Budget')
        if Budget.objects.filter(user=profile.user, active=True).exists():
            score += 10

        return min(100, int(score))

@admin.register(RecurringBill)
class RecurringBillAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'amount_display', 'due_date', 'frequency', 'status_display', 'is_active')
    list_filter = ('payment_status', 'frequency', 'is_active', 'due_date')
    search_fields = ('name', 'user__username', 'category')
    actions = ['mark_as_paid', 'mark_as_pending', 'activate_bills', 'deactivate_bills']
    date_hierarchy = 'due_date'

    def amount_display(self, obj):
        return format_html('UGX {:,.2f}', obj.amount)
    amount_display.short_description = 'Amount'

    def status_display(self, obj):
        colors = {
            'paid': 'success',
            'pending': 'warning',
            'overdue': 'danger'
        }
        return format_html(
            '<span class="badge badge-{}">{}</span>',
            colors.get(obj.payment_status, 'secondary'),
            obj.get_payment_status_display()
        )
    status_display.short_description = 'Status'

    def mark_as_paid(self, request, queryset):
        queryset.update(payment_status='paid', last_paid_date=timezone.now().date())
        self.message_user(request, f'Marked {queryset.count()} bills as paid')
    mark_as_paid.short_description = "Mark as paid"

    def mark_as_pending(self, request, queryset):
        queryset.update(payment_status='pending')
        self.message_user(request, f'Marked {queryset.count()} bills as pending')
    mark_as_pending.short_description = "Mark as pending"

    def activate_bills(self, request, queryset):
        queryset.update(is_active=True)
        self.message_user(request, f'Activated {queryset.count()} bills')
    activate_bills.short_description = "Activate bills"

    def deactivate_bills(self, request, queryset):
        queryset.update(is_active=False)
        self.message_user(request, f'Deactivated {queryset.count()} bills')
    deactivate_bills.short_description = "Deactivate bills"

@admin.register(InAppNotification)
class InAppNotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'message_preview', 'notif_type', 'is_read', 'created_at')
    list_filter = ('notif_type', 'is_read', 'created_at')
    search_fields = ('message', 'user__username')
    actions = ['mark_as_read', 'mark_as_unread', 'delete_old_notifications']
    date_hierarchy = 'created_at'

    def message_preview(self, obj):
        return obj.message[:50] + ('...' if len(obj.message) > 50 else '')
    message_preview.short_description = 'Message'

    def mark_as_read(self, request, queryset):
        queryset.update(is_read=True)
        self.message_user(request, f'Marked {queryset.count()} notifications as read')
    mark_as_read.short_description = "Mark as read"

    def mark_as_unread(self, request, queryset):
        queryset.update(is_read=False)
        self.message_user(request, f'Marked {queryset.count()} notifications as unread')
    mark_as_unread.short_description = "Mark as unread"

    def delete_old_notifications(self, request, queryset):
        month_ago = timezone.now() - timezone.timedelta(days=30)
        deleted, _ = queryset.filter(created_at__lt=month_ago, is_read=True).delete()
        self.message_user(request, f'Deleted {deleted} old notifications')
    delete_old_notifications.short_description = "Delete old read notifications"
