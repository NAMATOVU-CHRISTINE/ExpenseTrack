from django.contrib import admin
from .models import Profile, RecurringBill, InAppNotification

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'monthly_savings_target', 'preferred_currency', 'low_balance_threshold')

@admin.register(RecurringBill)
class RecurringBillAdmin(admin.ModelAdmin):
    list_display = ('user', 'name', 'amount', 'due_date', 'frequency', 'is_active')

@admin.register(InAppNotification)
class InAppNotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'message', 'notif_type', 'is_read', 'created_at')
