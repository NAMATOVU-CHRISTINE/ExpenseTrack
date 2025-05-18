from django import forms
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.db import models
from django.contrib.auth.models import User
from .models import Expense, Category, Receipt, SharedExpense, CategoryRule, RecurringExpense

class FormWarningMixin:
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.warnings = {}

    def add_warning(self, field, warning):
        if field not in self.warnings:
            self.warnings[field] = []
        self.warnings[field].append(warning)

def validate_positive_amount(value):
    if value <= 0:
        raise ValidationError('Amount must be greater than zero')

def validate_future_date(value):
    if value < timezone.now().date():
        raise ValidationError('Date cannot be in the past')

def validate_file_size(value):
    filesize = value.size
    if filesize > 10 * 1024 * 1024:  # 10MB
        raise ValidationError("Maximum file size is 10MB")

def validate_file_extension(value):
    import os
    ext = os.path.splitext(value.name)[1]
    valid_extensions = ['.jpg', '.jpeg', '.png', '.pdf']
    if ext.lower() not in valid_extensions:
        raise ValidationError('Unsupported file extension. Allowed: jpg, jpeg, png, pdf')

class ExpenseForm(FormWarningMixin, forms.ModelForm):
    amount = forms.DecimalField(
        max_digits=10, 
        decimal_places=2,
        validators=[validate_positive_amount],
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'min': '0.01',
            'step': '0.01'
        })
    )
    
    date = forms.DateField(
        widget=forms.DateInput(attrs={
            'type': 'date',
            'class': 'form-control'
        })
    )

    class Meta:
        model = Expense
        fields = ['category', 'amount', 'description', 'date', 'is_recurring', 'notes']
        widgets = {
            'description': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter expense description'
            }),
            'category': forms.Select(attrs={'class': 'form-select'}),
            'is_recurring': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'notes': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 2,
                'placeholder': 'Optional notes (e.g. details, items, etc.)'
            }),
        }

    def clean(self):
        cleaned_data = super().clean()
        amount = cleaned_data.get('amount')
        category = cleaned_data.get('category')
        
        if amount and category:
            # Check if this would exceed budget
            from budgets.models import Budget
            current_month = timezone.now().date().replace(day=1)
            budget = Budget.objects.filter(
                user=self.instance.user if self.instance.pk else None,
                category=category,
                month=current_month,
                active=True
            ).first()
            
            if budget:
                total_expenses = Expense.objects.filter(
                    user=self.instance.user if self.instance.pk else None,
                    category=category,
                    date__year=current_month.year,
                    date__month=current_month.month
                ).aggregate(total=models.Sum('amount'))['total'] or 0
                
                if total_expenses + amount > budget.limit:
                    self.add_warning(
                        'amount',
                        f'This expense will exceed your budget for {category.name} '
                        f'(Budget: UGX {budget.limit:,.2f}, '
                        f'Current: UGX {total_expenses:,.2f})'
                    )
        
        return cleaned_data

class ReceiptUploadForm(forms.ModelForm):
    image = forms.ImageField(
        validators=[validate_file_size, validate_file_extension],
        widget=forms.FileInput(attrs={
            'class': 'form-control',
            'accept': 'image/jpeg,image/png,application/pdf'
        })
    )

    class Meta:
        model = Receipt
        fields = ['image']

    def clean_image(self):
        image = self.cleaned_data.get('image')
        if image:
            from PIL import Image
            try:
                img = Image.open(image)
                img.verify()
            except Exception as exc:
                raise ValidationError('Invalid image file') from exc
        return image

class SharedExpenseForm(forms.ModelForm):
    class Meta:
        model = SharedExpense
        fields = ['shared_with', 'amount']
        widgets = {
            'shared_with': forms.Select(attrs={'class': 'form-select'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
        }

class CategoryRuleForm(forms.ModelForm):
    class Meta:
        model = CategoryRule
        fields = ['category', 'pattern', 'priority', 'is_active']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select'}),
            'pattern': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Enter regex pattern'}),
            'priority': forms.NumberInput(attrs={'class': 'form-control'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

class BulkCategoryUpdateForm(forms.Form):
    category = forms.ModelChoiceField(
        queryset=Category.objects.none(),
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    expenses = forms.ModelMultipleChoiceField(
        queryset=Expense.objects.none(),
        widget=forms.CheckboxSelectMultiple
    )

    def __init__(self, user, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['category'].queryset = Category.objects.filter(user=user)
        self.fields['expenses'].queryset = Expense.objects.filter(user=user)

class ShareExpenseForm(forms.ModelForm):
    shared_with = forms.ModelChoiceField(
        queryset=User.objects.all(),
        label="Share with",
        help_text="Select a user to share this expense with"
    )
    amount = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        help_text="Amount to share (must be less than or equal to the total expense amount)"
    )

    class Meta:
        model = SharedExpense
        fields = ['shared_with', 'amount']

    def __init__(self, expense, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.expense = expense
        # Exclude the expense owner from the list of users to share with
        self.fields['shared_with'].queryset = User.objects.exclude(id=expense.user.id)
        # Set max amount to the expense amount
        self.fields['amount'].max_value = expense.amount

    def clean_amount(self):
        amount = self.cleaned_data['amount']
        if amount > self.expense.amount:
            raise forms.ValidationError("Shared amount cannot be greater than the total expense amount")
        return amount

class RecurringExpenseForm(FormWarningMixin, forms.ModelForm):
    start_date = forms.DateField(
        validators=[validate_future_date],
        widget=forms.DateInput(attrs={
            'type': 'date',
            'class': 'form-control'
        })
    )
    
    end_date = forms.DateField(
        required=False,
        widget=forms.DateInput(attrs={
            'type': 'date',
            'class': 'form-control'
        })
    )

    class Meta:
        model = RecurringExpense
        fields = ['category', 'amount', 'description', 'frequency', 
                 'start_date', 'end_date', 'day_of_month', 'notes']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select'}),
            'amount': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '0.01',
                'step': '0.01'
            }),
            'description': forms.TextInput(attrs={'class': 'form-control'}),
            'frequency': forms.Select(attrs={'class': 'form-select'}),
            'day_of_month': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '1',
                'max': '31'
            }),
            'notes': forms.Textarea(attrs={'class': 'form-control', 'rows': 2}),
        }

    def clean(self):
        cleaned_data = super().clean()
        start_date = cleaned_data.get('start_date')
        end_date = cleaned_data.get('end_date')
        day_of_month = cleaned_data.get('day_of_month')

        if start_date and end_date and start_date > end_date:
            raise ValidationError({
                'end_date': 'End date must be after start date'
            })

        if day_of_month:
            if day_of_month > 28:
                self.add_warning(
                    'day_of_month',
                    'Some months have fewer than 31 days. The expense will be processed '
                    'on the last day of shorter months.'
                )

        return cleaned_data

ICON_CHOICES = [
    ('fa-car', 'Car'),
    ('fa-money-bill', 'Bills'),
    ('fa-tshirt', 'Clothes'),
    ('fa-gamepad', 'Entertainment'),
    ('fa-utensils', 'Food'),
    ('fa-gas-pump', 'Fuel'),
    ('fa-tags', 'General'),
    ('fa-gift', 'Gifts'),
    ('fa-briefcase-medical', 'Health'),
    ('fa-umbrella-beach', 'Holidays'),
    ('fa-home', 'Home'),
    ('fa-child', 'Kids'),
    ('fa-shopping-cart', 'Shopping'),
    ('fa-trophy', 'Sports'),
    ('fa-bus', 'Transport'),
    ('fa-graduation-cap', 'Education'),
    ('fa-heart', 'Charity'),
    ('fa-paw', 'Pets'),
    ('fa-plane', 'Travel'),
    ('fa-tools', 'Repairs'),
]

class CategoryForm(forms.ModelForm):
    icon = forms.ChoiceField(choices=ICON_CHOICES, widget=forms.Select(attrs={'class': 'form-select'}))
    color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color', 'class': 'form-control form-control-color', 'title': 'Pick a color'}))
    class Meta:
        model = Category
        fields = ['name', 'icon', 'color']
        widgets = {
            'name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Category Name',
                'required': 'required'
            })
        }