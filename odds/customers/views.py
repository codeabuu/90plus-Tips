import string
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django.utils import timezone
from .models import UserSubscription
from rest_framework.authtoken.models import Token
import uuid
import logging
import json
import threading
from django.core.mail import send_mail
from django.conf import settings

from .throttles import (
    RevenueCatWebhookThrottle,
    AnonymousUserThrottle,
    VerifySubscriptionThrottle,
    SubscriptionStatusThrottle
    )

from .permissions import IsAppUser

logger = logging.getLogger(__name__)

# Your product IDs
PRODUCT_IDS = ['weekly_sub', 'monthly_sub', '3_months', 'yearly_sub']

def process_webhook_background(webhook_data):
    """Process webhook in background thread"""
    try:
                # Extract data from correct locations
        event_data = webhook_data.get('event', {})
        event_type = event_data.get('type') or webhook_data.get('type')
        app_user_id = event_data.get('app_user_id') or webhook_data.get('app_user_id')
        product_id = event_data.get('product_id') or webhook_data.get('product_id', '')
        entitlement_id = webhook_data.get('entitlement_id', '')
        
        # ✅ ADD DETAILED LOGGING
        logger.info(f"🎯 WEBHOOK EVENT: {event_type}")
        logger.info(f"   User: {app_user_id}")
        logger.info(f"   Product: {product_id}, Entitlement: {entitlement_id}")
        logger.info(f"   Full event data: {json.dumps(event_data, indent=2)}")
        
        if not app_user_id:
            logger.error("❌ No app_user_id in background processing")
            return
        
        # Update subscription
        subscription, created = UserSubscription.objects.get_or_create(app_user_id=app_user_id)
        
        
        if event_type in ['INITIAL_PURCHASE', 'RENEWAL', 'PRODUCT_CHANGE', 'UNCANCELLATION']:
            subscription.is_active = True
            subscription.entitlement_id = entitlement_id
            subscription.product_id = product_id
            subscription.premium_granted_at = timezone.now()
            subscription.expires_at = webhook_data.get('expires_at')
            
            logger.info(f"✅ Subscription GRANTED: {app_user_id} | Event: {event_type}")
            
        elif event_type in ['CANCELLATION', 'EXPIRATION', 'NON_RENEWING_PURCHASE']:
            subscription.is_active = False
            subscription.expires_at = None
            logger.info(f"🔴 Subscription REVOKED: {app_user_id} | Event: {event_type}")
        else:
            logger.info(f"ℹ️  Other event: {event_type} - No subscription change")
        
        subscription.last_verified = timezone.now()
        subscription.save()

        logger.info(f"🎉 Webhook processing completed for event: {event_type}")

    except Exception as e:
        logger.error(f"🚨 Background webhook error: {str(e)}", exc_info=True)

@api_view(['POST'])
@permission_classes([AllowAny])
@throttle_classes([RevenueCatWebhookThrottle])
def revenuecat_webhook(request):
    """
    Handle RevenueCat webhook events - ASYNC VERSION
    """
    try:
        logger.info("🎯 WEBHOOK RECEIVED - Starting async processing")
        
        # Start background processing
        thread = threading.Thread(
            target=process_webhook_background,
            args=(request.data,)
        )
        thread.daemon = True
        thread.start()
        
        # ✅ FIX: Return 200 OK instead of 202 Accepted
        return Response({
            'status': 'success', 
            'message': 'Webhook processing started'
        }, status=200)
        
    except Exception as e:
        logger.error(f"🚨 Webhook acceptance error: {str(e)}")
        return Response({'status': 'error', 'message': str(e)}, status=500)


@api_view(['GET'])
@permission_classes([IsAppUser])
@throttle_classes([SubscriptionStatusThrottle])
def check_subscription_status(request):
    """
    Check current subscription status for a user - READ ONLY (DO NOT MODIFY)
    """
    app_user_id = request.GET.get('app_user_id')
    if not app_user_id:
        return Response({'error': 'app_user_id is required'}, status=400)
    
    try:
        subscription = UserSubscription.objects.get(app_user_id=app_user_id)
        
        remaining_days = subscription.get_remaining_days()
        
        return Response({
            'is_active': subscription.is_active,
            'entitlement_id': subscription.entitlement_id,
            'product_id': subscription.product_id,
            'expires_at': subscription.expires_at,
            'remaining_days': remaining_days,
            'last_verified': subscription.last_verified,
        })
    except UserSubscription.DoesNotExist:
        return Response({
            'is_active': False,
            'entitlement_id': '',
            'product_id': '',
            'remaining_days': 0,
            'last_verified': None,
        })


@api_view(['POST'])
@permission_classes([AllowAny])
def contact_us(request):
    """
    General Contact Us API - Send email message from users
    """
    try:
        # Extract data from request
        name = request.data.get('name', '')
        email = request.data.get('email', '')
        message = request.data.get('message', '')
        subject = request.data.get('subject', 'Contact Us Form Submission')

        # Prepare email content
        email_subject = f"Contact Us: {subject} from {name}"

        # Create simple email message
        email_message = f"""
Name: {name}
Email: {email}
Subject: {subject}

Message:
{message}

---
Sent from your app contact form
        """.strip()

        # Get recipient email from settings or use default
        recipient_email = getattr(settings, 'CONTACT_EMAIL', settings.DEFAULT_FROM_EMAIL)

        # Send email
        send_mail(
            subject=email_subject,
            message=email_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[recipient_email],
            fail_silently=False,
        )

        # Log the contact form submission
        logger.info(f"📧 Contact form submitted: {name} ({email}) - {subject}")

        return Response({
            'status': 'success',
            'message': 'Thank you for your message! We will get back to you soon.'
        }, status=200)

    except Exception as e:
        logger.error(f"Contact form error: {str(e)}")
        return Response({'error': 'Failed to send your message. Please try again later.'}, status=500)