from django.core.management.base import BaseCommand
from django.utils import timezone
from users.models import RecurringBill, FinanceGoal, Profile
from django.core.mail import send_mail
from datetime import timedelta

class Command(BaseCommand):
    help = 'Send reminders for upcoming bills, goal deadlines, and low balance alerts.'

    def handle(self, *args, **kwargs):
        today = timezone.now().date()
        soon = today + timedelta(days=3)

        # Bill reminders
        bills = RecurringBill.objects.filter(is_active=True, due_date__range=[today, soon])
        for bill in bills:
            subject = f"Upcoming Bill: {bill.name}"
            message = f"Hi {bill.user.username},\n\nYour bill '{bill.name}' of UGX {bill.amount} is due on {bill.due_date}."
            send_mail(subject, message, 'noreply@yourapp.com', [bill.user.email])
            self.stdout.write(self.style.SUCCESS(f"Bill reminder sent to {bill.user.email} for {bill.name}"))

        # Goal deadline alerts
        goals = FinanceGoal.objects.filter(is_completed=False, deadline__range=[today, soon])
        for goal in goals:
            subject = f"Goal Deadline Approaching: {goal.title}"
            message = f"Hi {goal.user.username},\n\nYour goal '{goal.title}' deadline is on {goal.deadline}."
            send_mail(subject, message, 'noreply@yourapp.com', [goal.user.email])
            self.stdout.write(self.style.SUCCESS(f"Goal deadline alert sent to {goal.user.email} for {goal.title}"))

        # Low balance alerts
        for profile in Profile.objects.all():
            # You need to implement your own balance calculation logic here:
            balance = 0  # TODO: Replace with actual balance calculation
            if profile.low_balance_threshold and balance < profile.low_balance_threshold:
                subject = "Low Balance Alert"
                message = f"Hi {profile.user.username},\n\nYour balance is UGX {balance}, below your threshold of UGX {profile.low_balance_threshold}."
                send_mail(subject, message, 'noreply@yourapp.com', [profile.user.email])
                self.stdout.write(self.style.WARNING(f"Low balance alert sent to {profile.user.email}")) 