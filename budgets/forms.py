from django import forms
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.db import models
from .models import Budget, MonthlyBudget
from expenses.models import Category
from expenses.forms import FormWarningMixin

def validate_positive_decimal(value):
    if value <= 0:
        raise ValidationError('Amount must be greater than zero')
    if value > 999999999:
        raise ValidationError('Amount is too large (maximum: 999,999,999)')

class BudgetForm(FormWarningMixin, forms.ModelForm):
    limit = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01',
            'placeholder': 'Enter budget limit'
        })
    )

    description = forms.CharField(
        required=False,
        widget=forms.Textarea(attrs={
            'class': 'form-control',
            'rows': 3,
            'placeholder': 'Optional: Add notes about this budget'
        })
    )

    color = forms.CharField(
        required=False,
        widget=forms.TextInput(attrs={
            'type': 'color',
            'class': 'form-control form-control-color',
            'title': 'Choose a color for this budget'
        })
    )

    class Meta:
        model = Budget
        fields = ['category', 'limit', 'month', 'description', 'color', 'notifications', 'recurrence', 'active']
        widgets = {
            'category': forms.Select(attrs={
                'class': 'form-select',
                'required': 'required'
            }),
            'month': forms.DateInput(attrs={
                'type': 'month',
                'class': 'form-control',
                'required': 'required'
            }),
            'notifications': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            }),
            'recurrence': forms.Select(attrs={
                'class': 'form-select'
            }),
            'active': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            })
        }

    def __init__(self, user, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user = user
        self.fields['category'].queryset = Category.objects.filter(user=user)
        
        # Set initial month to current month if not set
        if not self.instance.pk:
            self.initial['month'] = timezone.now().date().replace(day=1)

    def clean(self):
        cleaned_data = super().clean()
        category = cleaned_data.get('category')
        month = cleaned_data.get('month')
        recurrence = cleaned_data.get('recurrence')

        if category and month:
            # Check for existing budget in the same month
            existing_budget = Budget.objects.filter(
                user=self.user,
                category=category,
                month=month
            )
            if self.instance.pk:
                existing_budget = existing_budget.exclude(pk=self.instance.pk)
            
            if existing_budget.exists():
                raise ValidationError({
                    'category': 'A budget for this category already exists in the selected month'
                })

        # Validate month is not in the past
        if month and month < timezone.now().date().replace(day=1):
            self.add_warning(
                'month',
                'Setting a budget for a past month. This will only affect historical reports.'
            )

        # For recurring budgets, ensure proper setup
        if recurrence and recurrence != 'none':
            if not self.instance.pk:  # New budget
                # Check for existing recurring budget
                existing_recurring = Budget.objects.filter(
                    user=self.user,
                    category=category,
                    recurrence=recurrence,
                    active=True
                ).exists()
                
                if existing_recurring:
                    raise ValidationError({
                        'recurrence': f'An active {recurrence} recurring budget already exists for this category'
                    })

        return cleaned_data

class MonthlyBudgetForm(FormWarningMixin, forms.ModelForm):
    amount = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[validate_positive_decimal],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01'
        })
    )

    class Meta:
        model = MonthlyBudget
        fields = ['category', 'amount', 'month']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select'}),
            'month': forms.DateInput(attrs={
                'type': 'month',
                'class': 'form-control'
            })
        }

    def __init__(self, user, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user = user
        self.fields['category'].queryset = Category.objects.filter(user=user)

    def clean(self):
        cleaned_data = super().clean()
        category = cleaned_data.get('category')
        month = cleaned_data.get('month')
        amount = cleaned_data.get('amount')

        if category and month:
            # Check if amount exceeds any annual budget limits
            annual_budget = Budget.objects.filter(
                user=self.user,
                category=category,
                month__year=month.year,
                recurrence='yearly'
            ).first()

            if annual_budget:
                total_monthly = MonthlyBudget.objects.filter(
                    user=self.user,
                    category=category,
                    month__year=month.year
                ).exclude(pk=self.instance.pk if self.instance else None)\
                .aggregate(total=models.Sum('amount'))['total'] or 0

                if total_monthly + (amount or 0) > annual_budget.limit:
                    self.add_warning(
                        'amount',
                        f'This amount will exceed the yearly budget limit of UGX {annual_budget.limit:,.2f}'
                    )
            
            # Check if budget already exists for this month
            existing_budget = MonthlyBudget.objects.filter(
                user=self.user,
                category=category,
                month=month
            ).exclude(pk=self.instance.pk if self.instance else None).first()
            
            if existing_budget:
                raise ValidationError({
                    'category': 'A budget for this category already exists for the selected month'
                })

        return cleaned_data