

# **📊 Expense Tracker – Personal Finance Manager**  
Expense Tracker is a robust and feature-rich financial management application developed with Django, tailored to meet the diverse needs of individuals, families, and businesses aiming to gain full control over their finances. It enables users to effortlessly record and categorize expenses, set and monitor personalized budgets, and visualize spending patterns through interactive analytics and reports. The platform supports multi-user collaboration, allowing for shared financial oversight within households or teams, and incorporates automated notifications for budget limits and upcoming bills to promote proactive money management. With a secure authentication system and user-friendly interface, Expense Tracker simplifies the complexities of daily financial tracking and decision-making, empowering users to build better financial habits, avoid overspending, and confidently achieve their short- and long-term financial goals.

## **🚀 Key Features**  

### **📌 Expense Management**  
- **Detailed Expense Logging** – Track expenses with descriptions, amounts, and timestamps.  
- **Multi-Currency Support** – Record transactions in different currencies for international users.  
- **Smart Categorization** – Organize expenses using icons, tags, and color-coded categories.  
- **Receipt Upload & Processing** – Attach receipts for automatic expense verification.  
- **Expense Notes & Attachments** – Keep extra details for reference and documentation.  

### **🔄 Recurring Expense Automation**  
- **Flexible Scheduling** – Set up daily, weekly, monthly, or custom recurring transactions.  
- **Automatic Expense Generation** – Pre-configured expenses appear automatically based on user settings.  
- **Customizable End Dates** – Define expiration dates for recurring payments.  
- **Status Tracking** – Monitor active, paused, or completed recurring expenses.  

### **👨‍👩‍👧‍👦 Family Expense Sharing**  
- **Shared Financial Tracking** – Collaborate on expenses with family members or roommates.  
- **Bill Splitting** – Easily divide costs among multiple users.  
- **Real-Time Notifications** – Get alerts when a shared expense is logged or updated.  
- **Transaction History** – Maintain a complete record of shared financial activities.  

### **💰 Budget Management**  
- **Custom Budget Planning** – Allocate budgets for various expense categories.  
- **Rolling Budgeting Options** – Configure budgets to adjust dynamically based on spending patterns.  
- **Real-Time Budget Utilization** – Track spending progress compared to allocated budgets.  
- **Automated Budget Overrun Alerts** – Receive notifications when nearing budget limits.  

### **📈 Income Management**  
- **Multi-Source Income Tracking** – Manage regular salary, freelance earnings, and side hustles.  
- **Income Categorization & Analysis** – Break down income sources for better understanding.  
- **Frequency Management** – Configure recurring income cycles such as weekly, monthly, or yearly payments.  

### **📊 Advanced Financial Analytics**  
- **Spending Trend Reports** – Identify high-expenditure areas and optimize spending habits.  
- **Category-Based Breakdown** – Visualize how much is spent per category.  
- **Income vs. Expense Comparison** – Analyze financial health and savings patterns.  
- **Custom Date Range Reports** – Generate analytics for any time frame.  

### **🔍 Financial Health Monitoring**  
- **Anomaly Detection** – Identify unusual spending behaviors.  
- **Savings Rate Calculations** – Assess monthly savings performance.  
- **Personalized Budget Recommendations** – AI-driven insights for better financial planning.  

### **🚀 Smart Automation & Insights**  
- **Automatic Expense Categorization** – AI-based classification for easier management.  
- **Smart Receipt Processing** – Extract and log details from uploaded receipts.  
- **Financial Goal Tracking** – Set and monitor savings goals.  
- **Spending Alerts** – Receive notifications for unusual or excessive spending.  

---

## **⚙️ Technical Stack**  
- **Backend:** Django 4.x, RESTful API, SQLite/PostgreSQL  
- **Frontend:** Bootstrap 5, Chart.js, Font Awesome, JavaScript  
- **Security:** CSRF protection, authentication middleware, encrypted user data  
- **Automation:** Celery background tasks for processing transactions  

---
## 🌟 Screenshots

Below are some screenshots to give you a quick look at how Expense Tracker works:

### Dashboard

![Dashboard Screenshot](assets/screenshots/dashboard.jpg)
*The main dashboard provides an overview of your spending and income, as well as visual financial reports.*

### Add Expense Form

![Add Expense](assets/screenshots/add-expense.png)
*Easily log a new expense with details such as amount, category, and description.*

### Expense Categories

![Expense Categories](assets/screenshots/expense-categories.png)
*Organize your expenses with customizable categories and color-coded tags.*

### Analytics & Reports

![Analytics](assets/screenshots/analytics.png)
*View detailed breakdowns of your expenses and income by category, with interactive charts.*

### Budget Management

![Budget Management](assets/screenshots/budget-management.png)
*Allocate budgets for different expense categories and monitor your spending progress in real time.*

### Family/Shared Expenses

![Shared Expenses](assets/screenshots/shared-expenses.png)
*Collaborate with family members or roommates to track and split expenses.*

---
## **🛠️ Development Setup**  

### **1️⃣ Clone & Setup Environment**  
```bash
git clone https://github.com/yourusername/expense-tracker.git
cd expense-tracker
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```  

### **2️⃣ Install Dependencies**  
```bash
pip install -r requirements.txt
```  

### **3️⃣ Configure Environment Variables**  
Create a `.env` file with:  
```
DEBUG=True
SECRET_KEY=your_secret_key
DATABASE_URL=sqlite:///db.sqlite3
```  

### **4️⃣ Database Setup**  
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```  

### **5️⃣ Run Development Server**  
```bash
python manage.py runserver
```  

---

## **📝 API Endpoints**  
| **Endpoint** | **Functionality** |  
|-------------|------------------|  
| `/api/expenses/` | Manage and retrieve user expenses |  
| `/api/budgets/` | Budget creation, tracking, and allocation |  
| `/api/reports/` | Generate analytics and financial insights |  
| `/api/users/` | User authentication, profiles, and permissions |  

---

## **🚀 Deployment Guide**  
### **Requirements**  
- Python 3.8+  
- Django 4.x  
- Dependencies listed in `requirements.txt`  

### **Production Configuration**  
1. Set `DEBUG=False` for security.  
2. Configure **PostgreSQL** or another production-ready database.  
3. Enable **SSL** for secure data encryption.  
4. Set up **static file hosting** using Django’s built-in settings.  

---

### 🚀 How to Contribute

#### **1️⃣ Fork & Clone the Repository**  
First, fork the repository to your own GitHub account using the "Fork" button on GitHub.

Then, clone your forked repository to your local machine:
```bash
git clone https://github.com/NAMATOVU-CHRISTINE/ExpenseTrack.git
cd ExpenseTrack
```

#### **2️⃣ Create a Feature Branch**  
Create a new branch for your feature:
```bash
git checkout -b feature/<your-feature-name>
```

#### **3️⃣ Commit & Push Changes**  
After making your changes, stage, commit, and push them:
```bash
git add .
git commit -m "Add <your-feature-name>: <short description of your changes>"
git push origin feature/<your-feature-name>
```

> - Replace `<your-feature-name>` with a concise, descriptive branch name.
> - Update the commit message with a brief summary of your changes.
> - After pushing, open a Pull Request from your branch to `NAMATOVU-CHRISTINE/ExpenseTrack` on GitHub!

## 📚 Support 

If you need help or have any questions, please reach out:📧 **Email:** expensetracker100@gmail.com  

---

## **🙏 Acknowledgments**  
I extend my gratitude to:  
- **Django community** – For building an amazing framework.  
- **Bootstrap team** – For responsive UI components.  
- **Chart.js contributors** – For interactive financial visualizations.  
- **Font Awesome developers** – For beautiful icons.  
- **Every contributor and user** improving this project!  

---

## **🚀 About Me**  

**💻 I’m a Computer Scientist and aspiring Full Stack Developer, passionate about building high-quality, impactful software solutions. With a strong foundation in both front-end and back-end technologies, I am dedicated to continuous learning and driven by the desire to create software that makes a real difference. 🚀**

