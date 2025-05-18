from django import forms
from .models import Budget

class BudgetForm(forms.ModelForm):
    class Meta:
        model = Budget
        fields = ['category', 'limit', 'month', 'description', 'color', 'notifications', 'recurrence', 'active']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select', 'id': 'id_category', 'required': 'required', 'placeholder': ' '}),
            'limit': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': ' ', 'required': 'required', 'id': 'id_limit'}),
            'month': forms.DateInput(attrs={'class': 'form-control', 'type': 'date', 'required': 'required', 'id': 'id_month', 'placeholder': ' '}),
            'description': forms.Textarea(attrs={'class': 'form-control', 'placeholder': 'Description (optional)', 'rows': 2, 'id': 'id_description'}),
            'color': forms.TextInput(attrs={'type': 'color', 'id': 'id_color', 'style': 'width: 60px; height: 40px; padding: 2px;', 'class': ''}),
            'notifications': forms.CheckboxInput(attrs={'class': 'form-check-input', 'id': 'id_notifications'}),
            'recurrence': forms.Select(attrs={'class': 'form-select', 'id': 'id_recurrence'}),
            'active': forms.CheckboxInput(attrs={'class': 'form-check-input', 'id': 'id_active'}),
        }
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['category'].empty_label = 'Select category' 