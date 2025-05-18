# Personal Finance Manager

A comprehensive web-based expense tracking and budgeting application built with Django that helps users manage their personal finances effectively. This application provides robust features for expense tracking, budget management, and financial analytics with a focus on user experience and practical financial management.

## Core Features

### Expense Management
- **Comprehensive Expense Tracking**
  - Detailed expense logging with descriptions, amounts, and dates
  - Multiple currency support
  - Custom categorization with color-coding and icons
  - Tag-based expense organization
  - Receipt upload and automatic processing
  - Notes and attachments for expenses

- **Smart Recurring Expenses**
  - Support for multiple frequencies (daily, weekly, biweekly, monthly, quarterly, biannual, annual)
  - Automatic expense generation
  - Flexible scheduling options
  - End date configuration
  - Status tracking (active/paused/completed)

- **Family Expense Sharing**
  - Share expenses with family members
  - Split bills functionality
  - Shared expense tracking
  - Real-time notifications for shared expenses
  - Transaction history for shared expenses

### Budget Management
- **Flexible Budget Creation**
  - Monthly budget planning
  - Category-wise budget allocation
  - Custom budget periods
  - Rolling budgets
  - Budget templates

- **Smart Budget Features**
  - Real-time budget utilization tracking
  - Category-wise spending limits
  - Budget vs actual comparison
  - Automatic notifications for budget overruns
  - Monthly budget rollover options

### Income Management
- **Multiple Income Sources**
  - Track regular and irregular income
  - Income frequency management
  - Active/inactive source tracking
  - Income categorization
  - Source-wise analysis

### Advanced Analytics
- **Comprehensive Reports**
  - Monthly spending trends
  - Category-wise analysis
  - Income vs expense comparison
  - Budget utilization reports
  - Custom date range reports

- **Financial Health Monitoring**
  - Spending pattern analysis
  - Anomaly detection
  - Financial health scoring
  - Savings rate calculation
  - Monthly comparison metrics

### Smart Features
- **Automation Tools**
  - Automatic expense categorization rules
  - Smart receipt processing
  - Recurring expense automation
  - Budget notifications
  - Spending alerts

- **Financial Insights**
  - Personalized spending insights
  - Budget recommendations
  - Savings opportunities
  - Expense optimization suggestions
  - Financial goal tracking

## Technical Specifications

### Backend Architecture
- Django 4.x framework
- SQLite database (easily upgradeable to PostgreSQL)
- RESTful API architecture
- Custom middleware for authentication
- Celery for background tasks (optional)

### Frontend Technologies
- Bootstrap 5 for responsive design
- Chart.js for interactive visualizations
- Font Awesome icons
- Custom CSS for theming
- JavaScript for dynamic interactions

### Security Features
- Django's built-in security features
- CSRF protection
- Session management
- Secure password handling
- Data encryption

## Advanced Usage

### Expense Categories
```python
ICON_CHOICES = [
    'fa-car' (Transportation),
    'fa-money-bill' (Bills),
    'fa-tshirt' (Clothes),
    'fa-gamepad' (Entertainment),
    'fa-utensils' (Food),
    'fa-gas-pump' (Fuel),
    'fa-tags' (General),
    'fa-gift' (Gifts),
    'fa-briefcase-medical' (Health),
    'fa-umbrella-beach' (Holidays),
    'fa-home' (Home),
    'fa-child' (Kids),
    'fa-shopping-cart' (Shopping)
]
```

### Recurring Expense Frequencies
- Daily
- Weekly
- Bi-weekly
- Monthly
- Quarterly
- Bi-annual
- Annual

### API Endpoints
- `/api/expenses/` - Expense management
- `/api/budgets/` - Budget operations
- `/api/categories/` - Category management
- `/api/reports/` - Report generation
- `/api/users/` - User management

## Development Setup

1. **Clone and Environment Setup**
```bash
git clone https://github.com/yourusername/expense-tracker.git
cd expense-tracker
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. **Install Dependencies**
```bash
pip install -r requirements.txt
```

3. **Environment Configuration**
Create a `.env` file with:
```
DEBUG=True
SECRET_KEY=your_secret_key
DATABASE_URL=sqlite:///db.sqlite3
```

4. **Database Setup**
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

5. **Run Development Server**
```bash
python manage.py runserver
```

## Testing

Run the test suite:
```bash
python manage.py test
```

## Deployment

### Requirements
- Python 3.8+
- Django 4.x
- Other dependencies listed in requirements.txt

### Production Setup
1. Set DEBUG=False in settings
2. Configure production database
3. Set up static file serving
4. Configure email backend
5. Set up SSL certificate

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m 'Add YourFeature'`
4. Push to the branch: `git push origin feature/YourFeature`
5. Submit a pull request

## Support

- Documentation: [Wiki](https://github.com/yourusername/expense-tracker/wiki)
- Issues: [GitHub Issues](https://github.com/yourusername/expense-tracker/issues)
- Email: support@expensetracker.com

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Django community
- Bootstrap team
- Chart.js contributors
- Font Awesome team
- All contributors and users of the application