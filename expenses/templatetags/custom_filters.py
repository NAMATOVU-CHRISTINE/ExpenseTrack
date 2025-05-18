from django import template

register = template.Library()

@register.filter
def index(indexable, i):
    """Get item at index in a list or other indexable object."""
    try:
        return indexable[i]
    except (IndexError, TypeError):
        return ""

@register.filter
def multiply(value, arg):
    """Multiply the value by the argument."""
    try:
        return float(value) * float(arg)
    except (ValueError, TypeError):
        return 0

@register.filter
def divide(value, arg):
    """Divide the value by the argument."""
    try:
        return float(value) / float(arg)
    except (ValueError, TypeError, ZeroDivisionError):
        return 0 