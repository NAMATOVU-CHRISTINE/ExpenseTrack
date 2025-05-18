from django.urls import path
from . import views

urlpatterns = [
    path('', views.reports_dashboard, name='reports_dashboard'),
    path('chart/', views.reports_chart, name='reports_chart'),
    path('export/pdf/', views.export_pdf, name='export_pdf'),
] 