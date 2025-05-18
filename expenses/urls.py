from django.urls import path
from . import views

urlpatterns = [
    path('', views.expense_dashboard, name='expense_dashboard'),
    path('list/', views.expense_list, name='expense_list'),
    path('add/', views.expense_add, name='expense_add'),
    path('edit/<int:pk>/', views.expense_edit, name='expense_edit'),
    path('delete/<int:pk>/', views.expense_delete, name='expense_delete'),
    path('categories/', views.category_list, name='category_list'),
    path('categories/add/', views.category_add, name='category_add'),
    path('categories/edit/<int:pk>/', views.category_edit, name='category_edit'),
    path('upload-receipt/', views.upload_receipt, name='upload_receipt'),
    path('process-receipt/<int:receipt_id>/', views.process_receipt, name='process_receipt'),
    path('share-expense/<int:expense_id>/', views.share_expense, name='share_expense'),
    path('category-rules/', views.add_category_rule, name='category_rules'),
    path('bulk-update/', views.bulk_update_categories, name='bulk_update'),
    path('suggest-category/', views.suggest_category, name='suggest_category'),
    path('ajax-update-notes-tags/<int:expense_id>/', views.ajax_update_notes_tags, name='ajax_update_notes_tags'),
    path('stop-recurring/<int:pk>/', views.expense_stop_recurring, name='expense_stop_recurring'),
    
    # Recurring expenses
    path('recurring/', views.recurring_expense_list, name='recurring_expense_list'),
    path('recurring/add/', views.recurring_expense_add, name='recurring_expense_add'),
    path('recurring/edit/<int:pk>/', views.recurring_expense_edit, name='recurring_expense_edit'),
    path('recurring/delete/<int:pk>/', views.recurring_expense_delete, name='recurring_expense_delete'),
    path('recurring/toggle/<int:pk>/', views.recurring_expense_toggle, name='recurring_expense_toggle'),
    path('recurring/generate/<int:pk>/', views.generate_now, name='generate_now'),
    path('recurring/dashboard/', views.recurring_expense_dashboard, name='recurring_expense_dashboard'),
]