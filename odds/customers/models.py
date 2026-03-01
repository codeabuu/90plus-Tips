from django.db import models
from django.utils import timezone


class UserSubscription(models.Model):
    """
    Stores subscription state for a user identified by RevenueCat app_user_id.
    """
    # RevenueCat user ID (anonymous ID or app-specific user ID)
    app_user_id = models.CharField(max_length=100, unique=True)

    # RevenueCat product and entitlement
    product_id = models.CharField(max_length=100)
    entitlement_id = models.CharField(max_length=100, blank=True)

    # Subscription state
    is_active = models.BooleanField(default=False)
    expires_at = models.DateTimeField(null=True, blank=True)

    # Last time we verified this subscription (optional but recommended)
    last_verified = models.DateTimeField(auto_now=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.app_user_id} - Active: {self.is_active} | Product: {self.product_id}"

    def is_expired(self):
        """
        Returns True if subscription is expired.
        """
        if not self.is_active or not self.expires_at:
            return True
        return timezone.now() > self.expires_at

    def get_remaining_days(self):
        """
        Returns remaining subscription days.
        """
        if not self.is_active or not self.expires_at:
            return 0
        remaining = self.expires_at - timezone.now()
        return max(0, remaining.days)