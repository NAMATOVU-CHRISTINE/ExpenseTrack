from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('signup/', views.signup, name='signup'),
    path('login/', auth_views.LoginView.as_view(
        template_name='users/login.html',
        redirect_authenticated_user=True
    ), name='login'),
    path('logout/', auth_views.LogoutView.as_view(
        template_name='users/logout.html',
        next_page='login'
    ), name='logout'),
    path('profile/', views.profile, name='profile'),
    path('profile/add-income/', views.add_income_source, name='add_income_source'),
    path('profile/add-goal/', views.add_finance_goal, name='add_finance_goal'),
    path('profile/add-family/', views.add_family_member, name='add_family_member'),
    path('password-change/', auth_views.PasswordChangeView.as_view(
        template_name='users/password_change.html',
        success_url='/users/password-change/done/'
    ), name='password_change'),
    path('password-change/done/', auth_views.PasswordChangeDoneView.as_view(
        template_name='users/password_change_done.html'
    ), name='password_change_done'),
    path('bill/add/', views.add_bill, name='add_bill'),
    path('bill/<int:bill_id>/mark-paid/', views.mark_bill_paid, name='mark_bill_paid'),
    path('savings/goal/add/', views.add_savings_goal, name='add_savings_goal'),
    path('savings/goal/<int:goal_id>/update/', views.update_savings, name='update_savings'),
]