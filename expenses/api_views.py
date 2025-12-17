from rest_framework import generics, permissions
from .models import Expense, Category
from .serializers import ExpenseSerializer, CategorySerializer
from django.db.models import Sum
from rest_framework.views import APIView
from rest_framework.response import Response
from datetime import datetime, timedelta

class ExpenseListCreateView(generics.ListCreateAPIView):
    serializer_class = ExpenseSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Expense.objects.filter(user=self.request.user).order_by('-date')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class RecentExpenseListView(generics.ListAPIView):
    serializer_class = ExpenseSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Expense.objects.filter(user=self.request.user).order_by('-date')[:5]

class CategoryListCreateView(generics.ListCreateAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Category.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class FinancialDataView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        today = datetime.now()
        month_start = datetime(today.year, today.month, 1)
        
        # Total expenses this month
        total_expenses = Expense.objects.filter(
            user=user, 
            date__gte=month_start
        ).aggregate(Sum('amount'))['amount__sum'] or 0
        
        # Budget (assuming simple profile monthly income as budget for now, or fetch from Budget model)
        # Using a dummy value if no budget model integration yet
        monthly_budget = 0 
        if hasattr(user, 'profile'):
             monthly_budget = user.profile.monthly_income

        # Category breakdown
        category_expenses = []
        categories = Category.objects.filter(expense__user=user, expense__date__gte=month_start).distinct()
        for cat in categories:
            amount = Expense.objects.filter(
                user=user, 
                category=cat,
                date__gte=month_start
            ).aggregate(Sum('amount'))['amount__sum'] or 0
            
            category_expenses.append({
                'name': cat.name,
                'amount': amount
            })
            
        return Response({
            'totalExpenses': total_expenses,
            'monthlyBudget': monthly_budget,
            'categoryExpenses': category_expenses
        })
