from rest_framework import serializers
from .models import Expense, Category

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'color', 'icon']

class ExpenseSerializer(serializers.ModelSerializer):
    category_details = CategorySerializer(source='category', read_only=True)
    
    class Meta:
        model = Expense
        fields = ['id', 'description', 'amount', 'date', 'category', 'category_details', 'notes', 'is_recurring']
