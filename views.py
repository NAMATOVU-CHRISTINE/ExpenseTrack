def home(request):
    # Get total income
    total_income = Income.objects.filter(user=request.user).aggregate(
        total=Sum('amount')
    )['total'] or 0

    # Get income sources
    income_sources = Income.objects.filter(user=request.user).values(
        'name', 'amount'
    ).order_by('-amount')

    context = {
        'total_income': total_income,
        'income_sources': income_sources,
        # ... other context data
    }
    return render(request, 'home.html', context)