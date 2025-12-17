"""
URL configuration for finance_manager project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse
from django.views.generic import TemplateView
from . import views, api
from users import api_views as user_api_views
from expenses import api_views as expense_api_views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', views.home, name='home'),
    path('mobile/', views.mobile_app, name='mobile_app'),
    path('users/', include('users.urls')),
    path('expenses/', include('expenses.urls')),
    path('budgets/', include('budgets.urls')),
    path('reports/', include('reports.urls')),
    
    # API endpoints (Legacy / Web)
    path('api/financial-data/', api.financial_data, name='api_financial_data'),
    path('api/financial-data/update/', api.update_financial_data, name='api_update_financial_data'),
    path('api/income-source/add/', api.add_income_source, name='api_add_income_source'),
    path('api/create-sample-data/', api.create_sample_data, name='api_create_sample_data'),
    
    # Mobile API Endpoints
    path('api/auth/login/', user_api_views.LoginView.as_view(), name='api_login'),
    path('api/auth/register/', user_api_views.RegisterView.as_view(), name='api_register'),
    path('api/expenses/', expense_api_views.ExpenseListCreateView.as_view(), name='api_expenses'),
    path('api/expenses/recent/', expense_api_views.RecentExpenseListView.as_view(), name='api_recent_expenses'),
    path('api/categories/', expense_api_views.CategoryListCreateView.as_view(), name='api_categories'),
    path('api/dashboard/', expense_api_views.FinancialDataView.as_view(), name='api_mobile_dashboard'),

    # PWA files
    path('sw.js', TemplateView.as_view(template_name='sw.js', content_type='application/javascript'), name='sw'),
    path('manifest.json', TemplateView.as_view(template_name='manifest.json', content_type='application/json'), name='manifest'),
]

# Serve static and media files during development
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

MEDIA_URL = '/media/'
MEDIA_ROOT = settings.BASE_DIR / 'media'
