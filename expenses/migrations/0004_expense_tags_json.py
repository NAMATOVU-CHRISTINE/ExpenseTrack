# Generated by Django 5.2.1 on 2025-05-17 03:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('expenses', '0003_alter_category_created_at_alter_category_updated_at_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='expense',
            name='tags_json',
            field=models.TextField(blank=True, default='{}', null=True),
        ),
    ]
