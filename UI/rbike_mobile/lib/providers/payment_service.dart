import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:rbike_mobile/utils/stripe_keys.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String _currency = 'BAM'; // BAM currency

  static Future<String> createPaymentIntent(double amount) async {
    try {
      final body = {
        'amount': (amount * 100).round().toString(),
        'currency': _currency,
        'payment_method_types[]': 'card',
      };

      final headers = {
        'Authorization': 'Bearer ${StripeKeys.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data['client_secret'];
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  static Future<PaymentResult> processPayment(
    double amount,
    String email,
  ) async {
    try {
      final clientSecret = await createPaymentIntent(amount);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'rBike',
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF2196F3),
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final paymentIntentId = _extractPaymentIntentId(clientSecret);

      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntentId,
        message: 'Payment successful',
      );
    } catch (e) {
      if (e is StripeException) {
        return PaymentResult(
          success: false,
          message: e.error.localizedMessage ?? 'Payment failed',
        );
      } else {
        return PaymentResult(success: false, message: 'Payment failed: $e');
      }
    }
  }

  static String _extractPaymentIntentId(String clientSecret) {
    return clientSecret.split('_secret_')[0];
  }

  static Future<bool> validateCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    try {
      await Stripe.instance.createTokenForCVCUpdate(cvc);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String message;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    required this.message,
  });
}
