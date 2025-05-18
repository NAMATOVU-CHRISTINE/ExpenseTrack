from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.db import models
from .models import Profile, IncomeSource, FinanceGoal, FamilyMember, RecurringBill, SavingsGoal
from expenses.forms import FormWarningMixin

def validate_positive_decimal(value):
    if value <= 0:
        raise ValidationError('Amount must be greater than zero')
    if value > 999999999:
        raise ValidationError('Amount is too large (maximum: 999,999,999)')

def validate_future_deadline(value):
    if value <= timezone.now().date():
        raise ValidationError('Deadline must be in the future')

def validate_image(value):
    from django.core.files.images import get_image_dimensions
    width, height = get_image_dimensions(value)
    if width > 4096 or height > 4096:
        raise ValidationError('Image dimensions too large (max 4096x4096)')
    if value.size > 5*1024*1024:  # 5MB
        raise ValidationError('File size too large (max 5MB)')

class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter your email'
        })
    )

    class Meta:
        model = User
        fields = ("username", "email", "password1", "password2")
        widgets = {
            'username': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Choose a username'
            })
        }

    def clean_email(self):
        email = self.cleaned_data['email']
        if User.objects.filter(email=email).exists():
            raise ValidationError('This email is already registered')
        return email

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
    profile_picture = forms.ImageField(
        required=False,
        validators=[validate_image],
        widget=forms.FileInput(attrs={
            'class': 'form-control',
            'accept': 'image/*'
        })
    )

    monthly_savings_target = forms.DecimalField(
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0',
            'step': '1000'
        })
    )

    class Meta:
        model = Profile
        fields = ['profile_picture', 'monthly_savings_target', 'preferred_currency', 
                 'dark_mode', 'email_notifications', 'low_balance_threshold']
        widgets = {
            'preferred_currency': forms.Select(attrs={'class': 'form-select'}),
            'dark_mode': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'email_notifications': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'low_balance_threshold': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '0',
                'step': '1000'
            })
        }

    def clean_low_balance_threshold(self):
        threshold = self.cleaned_data['low_balance_threshold']
        if threshold < 0:
            raise ValidationError('Threshold cannot be negative')
        return threshold

class IncomeSourceForm(FormWarningMixin, forms.ModelForm):
    amount = forms.DecimalField(
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01'
        })
    )

    class Meta:
        model = IncomeSource
        fields = ['name', 'amount', 'frequency', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Income source name'
            }),
            'frequency': forms.Select(attrs={'class': 'form-select'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'})
        }

    def clean(self):
        cleaned_data = super().clean()
        amount = cleaned_data.get('amount')
        frequency = cleaned_data.get('frequency')

        if frequency == 'monthly' and amount:
            monthly_total = IncomeSource.objects.filter(
                user=self.instance.user if self.instance else None,
                frequency='monthly',
                is_active=True
            ).aggregate(total=models.Sum('amount'))['total'] or 0

            if monthly_total + amount > 100000000:  # 100M UGX limit
                self.add_warning(
                    'amount',
                    'Total monthly income seems unusually high. Please verify the amount.'
                )

        return cleaned_data

class FinanceGoalForm(FormWarningMixin, forms.ModelForm):
    target_amount = forms.DecimalField(
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01'
        })
    )

    current_amount = forms.DecimalField(
        required=False,
        initial=0,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0',
            'step': '0.01'
        })
    )

    deadline = forms.DateField(
        validators=[validate_future_deadline],
        widget=forms.DateInput(attrs={
            'class': 'form-control',
            'type': 'date'
        })
    )

    class Meta:
        model = FinanceGoal
        fields = ['title', 'target_amount', 'current_amount', 'deadline']
        widgets = {
            'title': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Goal title'
            })
        }

    def clean(self):
        cleaned_data = super().clean()
        target_amount = cleaned_data.get('target_amount')
        current_amount = cleaned_data.get('current_amount') or 0
        deadline = cleaned_data.get('deadline')

        if current_amount > target_amount:
            raise ValidationError({
                'current_amount': 'Current amount cannot exceed target amount'
            })

        if deadline:
            days_remaining = (deadline - timezone.now().date()).days
            monthly_saving_needed = (target_amount - current_amount) / (days_remaining / 30)
            
            if monthly_saving_needed > 50000000:  # 50M UGX monthly savings warning
                self.add_warning(
                    'deadline',
                    f'You will need to save UGX {monthly_saving_needed:,.2f} monthly to reach this goal. '
                    'Consider extending the deadline or adjusting the target.'
                )

        return cleaned_data

class FamilyMemberForm(forms.ModelForm):
    class Meta:
        model = FamilyMember
        fields = ['name', 'relationship', 'email', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Member name'
            }),
            'relationship': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Relationship'
            }),
            'email': forms.EmailInput(attrs={
                'class': 'form-control',
                'placeholder': 'Email (optional)'
            }),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'})
        }

    def clean_email(self):
        email = self.cleaned_data.get('email')
        if email:
            if FamilyMember.objects.filter(email=email).exclude(pk=self.instance.pk if self.instance else None).exists():
                raise ValidationError('A family member with this email already exists')
        return email

class ProfileImageForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['profile_picture']
        widgets = {
            'profile_picture': forms.ClearableFileInput(attrs={'class': 'form-control'}),
        }

class RecurringBillForm(FormWarningMixin, forms.ModelForm):
    amount = forms.DecimalField(
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01'
        })
    )

    due_date = forms.DateField(
        widget=forms.DateInput(attrs={
            'type': 'date',
            'class': 'form-control'
        })
    )

    class Meta:
        model = RecurringBill
        fields = ['name', 'amount', 'due_date', 'frequency', 'category', 'reminder_days', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'frequency': forms.Select(attrs={'class': 'form-select'}),
            'category': forms.TextInput(attrs={'class': 'form-control'}),
            'reminder_days': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '0',
                'max': '30'
            }),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'})
        }

    def clean(self):
        cleaned_data = super().clean()
        due_date = cleaned_data.get('due_date')
        reminder_days = cleaned_data.get('reminder_days')

        if due_date and reminder_days:
            reminder_date = due_date - timezone.timedelta(days=reminder_days)
            if reminder_date < timezone.now().date():
                self.add_warning(
                    'reminder_days',
                    'Reminder date is in the past. You may not receive the first reminder.'
                )

        return cleaned_data

class SavingsGoalForm(forms.ModelForm):
    target_amount = forms.DecimalField(
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01'
        })
    )

    class Meta:
        model = SavingsGoal
        fields = ['name', 'target_amount', 'target_date', 'current_savings']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'target_date': forms.DateInput(attrs={
                'type': 'date',
                'class': 'form-control'
            }),
            'current_savings': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '0',
                'step': '0.01'
            })
        }

    def clean_target_date(self):
        target_date = self.cleaned_data.get('target_date')
        if target_date and target_date < timezone.now().date():
            raise ValidationError('Target date must be in the future')
        return target_date