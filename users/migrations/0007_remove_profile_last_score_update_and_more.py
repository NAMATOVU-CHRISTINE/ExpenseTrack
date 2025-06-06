# Generated by Django 5.2.1 on 2025-05-18 05:19

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0006_profile_monthly_income_profile_savings_amount_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='profile',
            name='last_score_update',
        ),
        migrations.AddField(
            model_name='profile',
            name='bill_payment_streak',
            field=models.IntegerField(default=0),
        ),
        migrations.AddField(
            model_name='profile',
            name='emergency_fund_ratio',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=5),
        ),
        migrations.AddField(
            model_name='profile',
            name='financial_health_factors',
            field=models.JSONField(default=dict),
        ),
        migrations.AddField(
            model_name='profile',
            name='last_bill_payment',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='profile',
            name='savings_streak',
            field=models.IntegerField(default=0),
        ),
    ]
