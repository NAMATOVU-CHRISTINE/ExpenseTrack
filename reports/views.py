from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.db.models import Sum, Count
from django.utils import timezone
from datetime import timedelta, datetime, date
from expenses.models import Expense
from users.models import IncomeSource
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from io import BytesIO

# Create your views here.

@login_required
def reports_dashboard(request):
    # Get date range for current month
    today = timezone.now()
    first_day = today.replace(day=1)
    last_day = (first_day + timedelta(days=32)).replace(day=1) - timedelta(days=1)

    # Get previous month for comparison
    prev_month = first_day - timedelta(days=1)
    prev_first_day = prev_month.replace(day=1)
    prev_last_day = prev_month

    # Calculate total income and expenses for current month
    current_income = IncomeSource.objects.filter(
        user=request.user,
        is_active=True
    ).aggregate(total=Sum('amount'))['total'] or 0

    current_expenses = Expense.objects.filter(
        user=request.user,
        date__gte=first_day,
        date__lte=last_day
    ).aggregate(total=Sum('amount'))['total'] or 0

    # Calculate previous month totals
    prev_income = IncomeSource.objects.filter(
        user=request.user,
        is_active=True
    ).aggregate(total=Sum('amount'))['total'] or 0

    prev_expenses = Expense.objects.filter(
        user=request.user,
        date__gte=prev_first_day,
        date__lte=prev_last_day
    ).aggregate(total=Sum('amount'))['total'] or 0

    # Calculate percentage changes
    income_change = ((current_income - prev_income) / prev_income * 100) if prev_income else 0
    expense_change = ((current_expenses - prev_expenses) / prev_expenses * 100) if prev_expenses else 0

    # Calculate savings rate
    savings_rate = ((current_income - current_expenses) / current_income * 100) if current_income else 0

    # Get expense categories breakdown
    categories = Expense.objects.filter(
        user=request.user,
        date__gte=first_day,
        date__lte=last_day
    ).values('category').annotate(
        total=Sum('amount')
    ).order_by('-total')

    # Get recent transactions
    recent_transactions = []
    
    # Add recent expenses
    expenses = Expense.objects.filter(
        user=request.user
    ).order_by('-date')[:5]
    
    for expense in expenses:
        transaction_date = expense.date
        if isinstance(transaction_date, date) and not isinstance(transaction_date, datetime):
            transaction_date = datetime.combine(transaction_date, datetime.min.time())
            if timezone.is_naive(transaction_date):
                transaction_date = timezone.make_aware(transaction_date)
        recent_transactions.append({
            'date': transaction_date,
            'description': expense.description,
            'category': expense.category,
            'amount': expense.amount,
            'type': 'expense',
            'status': 'Completed',
            'status_color': 'success'
        })

    # Add recent income sources
    income_sources = IncomeSource.objects.filter(
        user=request.user
    ).order_by('-created_at')[:5]
    
    for income in income_sources:
        transaction_date = income.created_at
        if isinstance(transaction_date, date) and not isinstance(transaction_date, datetime):
            transaction_date = datetime.combine(transaction_date, datetime.min.time())
            if timezone.is_naive(transaction_date):
                transaction_date = timezone.make_aware(transaction_date)
        recent_transactions.append({
            'date': transaction_date,
            'description': income.name,
            'category': 'Income',
            'amount': income.amount,
            'type': 'income',
            'status': 'Active' if income.is_active else 'Inactive',
            'status_color': 'success' if income.is_active else 'warning'
        })

    # Sort transactions by date
    recent_transactions.sort(key=lambda x: x['date'], reverse=True)
    recent_transactions = recent_transactions[:5]

    context = {
        'total_income': current_income,
        'total_expenses': current_expenses,
        'savings_rate': savings_rate,
        'budget_status': 75,  # This should be calculated based on your budget model
        'recent_transactions': recent_transactions,
        'income_change': income_change,
        'expense_change': expense_change,
    }
    
    return render(request, 'reports/reports_dashboard.html', context)

@login_required
def reports_chart(request):
    return render(request, 'reports/reports_chart.html')

@login_required
def export_pdf(request):
    # Create a BytesIO buffer to receive the PDF data
    buffer = BytesIO()
    
    # Create the PDF object, using the buffer as its "file"
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    
    # Container for the 'Flowable' objects
    elements = []
    
    # Get styles
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        spaceAfter=30
    )
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=16,
        spaceAfter=12
    )
    
    # Add title
    elements.append(Paragraph("Financial Report", title_style))
    elements.append(Paragraph(f"Generated on: {timezone.now().strftime('%B %d, %Y')}", styles['Normal']))
    elements.append(Spacer(1, 20))
    
    # Get date range for current month
    today = timezone.now()
    first_day = today.replace(day=1)
    last_day = (first_day + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    
    # Calculate totals
    current_income = IncomeSource.objects.filter(
        user=request.user,
        is_active=True
    ).aggregate(total=Sum('amount'))['total'] or 0

    current_expenses = Expense.objects.filter(
        user=request.user,
        date__gte=first_day,
        date__lte=last_day
    ).aggregate(total=Sum('amount'))['total'] or 0

    # Add summary section
    elements.append(Paragraph("Monthly Summary", heading_style))
    summary_data = [
        ["Category", "Amount (UGX)"],
        ["Total Income", f"{current_income:,.0f}"],
        ["Total Expenses", f"{current_expenses:,.0f}"],
        ["Net Savings", f"{(current_income - current_expenses):,.0f}"]
    ]
    
    summary_table = Table(summary_data, colWidths=[3*inch, 2*inch])
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 12),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    elements.append(summary_table)
    elements.append(Spacer(1, 20))
    
    # Add expense categories breakdown
    elements.append(Paragraph("Expense Categories", heading_style))
    categories = Expense.objects.filter(
        user=request.user,
        date__gte=first_day,
        date__lte=last_day
    ).values('category').annotate(
        total=Sum('amount')
    ).order_by('-total')
    
    category_data = [["Category", "Amount (UGX)", "Percentage"]]
    for category in categories:
        percentage = (category['total'] / current_expenses * 100) if current_expenses else 0
        category_data.append([
            category['category'],
            f"{category['total']:,.0f}",
            f"{percentage:.1f}%"
        ])
    
    category_table = Table(category_data, colWidths=[2*inch, 2*inch, 1*inch])
    category_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 12),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    elements.append(category_table)
    elements.append(Spacer(1, 20))
    
    # Add recent transactions
    elements.append(Paragraph("Recent Transactions", heading_style))
    recent_transactions = []
    
    # Add recent expenses
    expenses = Expense.objects.filter(
        user=request.user
    ).order_by('-date')[:5]
    
    for expense in expenses:
        transaction_date = expense.date
        if isinstance(transaction_date, date) and not isinstance(transaction_date, datetime):
            transaction_date = datetime.combine(transaction_date, datetime.min.time())
            if timezone.is_naive(transaction_date):
                transaction_date = timezone.make_aware(transaction_date)
        recent_transactions.append({
            'date': transaction_date,
            'description': expense.description,
            'category': expense.category,
            'amount': expense.amount,
            'type': 'expense'
        })

    # Add recent income sources
    income_sources = IncomeSource.objects.filter(
        user=request.user
    ).order_by('-created_at')[:5]
    
    for income in income_sources:
        transaction_date = income.created_at
        if isinstance(transaction_date, date) and not isinstance(transaction_date, datetime):
            transaction_date = datetime.combine(transaction_date, datetime.min.time())
            if timezone.is_naive(transaction_date):
                transaction_date = timezone.make_aware(transaction_date)
        recent_transactions.append({
            'date': transaction_date,
            'description': income.name,
            'category': 'Income',
            'amount': income.amount,
            'type': 'income'
        })

    # Sort transactions by date
    recent_transactions.sort(key=lambda x: x['date'], reverse=True)
    recent_transactions = recent_transactions[:5]
    
    transaction_data = [["Date", "Description", "Category", "Amount (UGX)"]]
    for transaction in recent_transactions:
        transaction_data.append([
            transaction['date'].strftime('%Y-%m-%d'),
            transaction['description'],
            transaction['category'],
            f"{transaction['amount']:,.0f}"
        ])
    
    transaction_table = Table(transaction_data, colWidths=[1.5*inch, 2*inch, 1.5*inch, 1.5*inch])
    transaction_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 12),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    elements.append(transaction_table)
    
    # Build the PDF
    doc.build(elements)
    
    # Get the value of the BytesIO buffer
    pdf = buffer.getvalue()
    buffer.close()
    
    # Create the HTTP response
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="financial_report_{today.strftime("%Y%m%d")}.pdf"'
    response.write(pdf)
    
    return response
