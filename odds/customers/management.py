# Add this as a temporary view or management command
from django.utils import timezone

def recover_expired_subscriptions():
    """Recover subscriptions that were incorrectly marked as expired"""
    from .models import UserSubscription
    
    affected_users = UserSubscription.objects.filter(
        is_premium=False,  # Currently marked as expired
        expires_at__gt=timezone.now()  # But expiry date is in future
    )
    
    count = affected_users.count()
    
    for subscription in affected_users:
        subscription.is_premium = True
        subscription.save()
        print(f"✅ Recovered: {subscription.user.username} - Expires: {subscription.expires_at}")
    
    print(f"🎉 Recovered {count} incorrectly expired subscriptions")
    return count