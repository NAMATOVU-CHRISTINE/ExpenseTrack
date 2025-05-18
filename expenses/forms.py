from django import forms
from .models import Expense, Category, Receipt, SharedExpense, CategoryRule, RecurringExpense
from django.contrib.auth.models import User

class ExpenseForm(forms.ModelForm):
    class Meta:
        model = Expense
        fields = ['category', 'amount', 'description', 'date', 'is_recurring', 'notes']
        widgets = {
            'date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'description': forms.TextInput(attrs={'class': 'form-control'}),
            'category': forms.Select(attrs={'class': 'form-select'}),
            'is_recurring': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'notes': forms.Textarea(attrs={'class': 'form-control', 'rows': 2, 'placeholder': 'Optional notes (e.g. details, items, etc.)'}),
        }

class ReceiptUploadForm(forms.ModelForm):
    class Meta:
        model = Receipt
        fields = ['image']
        widgets = {
            'image': forms.FileInput(attrs={'class': 'form-control', 'accept': 'image/*'}),
        }

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

class RecurringExpenseForm(forms.ModelForm):
    class Meta:
        model = RecurringExpense
        fields = ['category', 'amount', 'description', 'frequency', 'start_date', 
                 'end_date', 'day_of_month', 'notes']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'description': forms.TextInput(attrs={'class': 'form-control'}),
            'frequency': forms.Select(attrs={'class': 'form-select'}),
            'start_date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'end_date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'day_of_month': forms.NumberInput(attrs={'class': 'form-control', 'min': '1', 'max': '31'}),
            'notes': forms.Textarea(attrs={'class': 'form-control', 'rows': 2}),
        }
    
    def clean_day_of_month(self):
        day = self.cleaned_data.get('day_of_month')
        frequency = self.cleaned_data.get('frequency')
        
        if frequency == 'monthly' and day:
            if day < 1 or day > 31:
                raise forms.ValidationError("Day of month must be between 1 and 31.")
        
        return day
    
    def clean(self):
        cleaned_data = super().clean()
        start_date = cleaned_data.get('start_date')
        end_date = cleaned_data.get('end_date')
        
        if start_date and end_date and end_date < start_date:
            raise forms.ValidationError("End date cannot be before start date.")
            
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        
        # Initialize next_date if this is a new instance
        if not instance.pk:
            instance.next_date = instance.start_date
        
        if commit:
            instance.save()
        
        return instance

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