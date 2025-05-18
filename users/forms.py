from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.utils import timezone
from .models import Profile, IncomeSource, FinanceGoal, FamilyMember, RecurringBill, InAppNotification, SavingsGoal

class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(required=True, label='Email')

    class Meta:
        model = User
        fields = ("username", "email", "password1", "password2")

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data["email"]
        if commit:
            user.save()
        return user

class UserUpdateForm(forms.ModelForm):
    email = forms.EmailField()

    class Meta:
        model = User
        fields = ['username', 'email', 'first_name', 'last_name']

class ProfileUpdateForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['profile_picture', 'monthly_savings_target', 'preferred_currency', 'dark_mode', 'email_notifications']
        widgets = {
            'profile_picture': forms.FileInput(attrs={'class': 'form-control'}),
            'monthly_savings_target': forms.NumberInput(attrs={'class': 'form-control'}),
            'preferred_currency': forms.Select(attrs={'class': 'form-select'}),
            'dark_mode': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'email_notifications': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

class IncomeSourceForm(forms.ModelForm):
    class Meta:
        model = IncomeSource
        fields = ['name', 'amount', 'frequency', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Source name'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Amount'}),
            'frequency': forms.Select(attrs={'class': 'form-select'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

class FinanceGoalForm(forms.ModelForm):
    class Meta:
        model = FinanceGoal
        fields = ['title', 'target_amount', 'current_amount', 'deadline']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Goal title'}),
            'target_amount': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Target amount'}),
            'current_amount': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Current amount'}),
            'deadline': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
        }

class FamilyMemberForm(forms.ModelForm):
    class Meta:
        model = FamilyMember
        fields = ['name', 'relationship', 'email', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Member name'}),
            'relationship': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Relationship'}),
            'email': forms.EmailInput(attrs={'class': 'form-control', 'placeholder': 'Email (optional)'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

class ProfileImageForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['profile_picture']
        widgets = {
            'profile_picture': forms.ClearableFileInput(attrs={'class': 'form-control'}),
        }

class RecurringBillForm(forms.ModelForm):
    class Meta:
        model = RecurringBill
        fields = ['name', 'amount', 'due_date', 'frequency', 'is_active']
        widgets = {
            'due_date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'frequency': forms.Select(attrs={'class': 'form-select'}),
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

class InAppNotificationForm(forms.ModelForm):
    class Meta:
        model = InAppNotification
        fields = ['message', 'notif_type']
        widgets = {
            'message': forms.TextInput(attrs={'class': 'form-control'}),
            'notif_type': forms.Select(choices=[('info', 'Info'), ('warning', 'Warning'), ('success', 'Success')], attrs={'class': 'form-select'}),
        }

class SavingsGoalForm(forms.ModelForm):
    class Meta:
        model = SavingsGoal
        fields = ['name', 'target_amount', 'current_savings', 'target_date', 'interest_rate']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'target_amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'current_savings': forms.NumberInput(attrs={'class': 'form-control'}),
            'target_date': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
            'interest_rate': forms.NumberInput(attrs={'class': 'form-control', 'step': '0.1'}),
        }

    def clean(self):
        cleaned_data = super().clean()
        target_amount = cleaned_data.get('target_amount')
        current_savings = cleaned_data.get('current_savings')
        target_date = cleaned_data.get('target_date')

        if target_amount and current_savings and target_amount < current_savings:
            raise forms.ValidationError("Target amount cannot be less than current savings")

        if target_date and target_date < timezone.now().date():
            raise forms.ValidationError("Target date cannot be in the past")

        return cleaned_data