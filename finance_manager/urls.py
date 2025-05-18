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
from django.contrib.auth import views as auth_views
from .views import home
from django.conf import settings
from django.conf.urls.static import static
from . import views, api

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', home, name='home'),  # Home page is now the root URL
    path('users/', include('users.urls')),
    path('expenses/', include('expenses.urls')),
    path('budgets/', include('budgets.urls')),
    path('reports/', include('reports.urls')),
    
    # API endpoints
    path('api/financial-data/', api.financial_data, name='api_financial_data'),
    path('api/financial-data/update/', api.update_financial_data, name='api_update_financial_data'),
    path('api/income-source/add/', api.add_income_source, name='api_add_income_source'),
    path('api/create-sample-data/', api.create_sample_data, name='api_create_sample_data'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

MEDIA_URL = '/media/'
MEDIA_ROOT = settings.BASE_DIR / 'media'
