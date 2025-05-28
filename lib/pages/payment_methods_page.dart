import 'package:flutter/material.dart';
import 'package:thriftale/models/payment_method_model.dart';
import 'package:thriftale/pages/add_payment_method_page.dart';
import 'package:thriftale/services/payment_service.dart';
import 'package:thriftale/services/payment_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_text.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.CardBg,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomText(
                    text: 'Payment Methods',
                    color: AppColors.black,
                    fontSize: LableTexts.subLable,
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddPaymentMethodPage(),
                        ),
                      );
                      if (result == true) {
                        setState(() {}); // Refresh the list
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 213, 167, 66),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Payment Methods List
            Expanded(
              child: StreamBuilder<List<PaymentMethod>>(
                stream: _paymentService.getPaymentMethods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                            text: 'Error loading payment methods',
                            color: Colors.grey[600]!,
                            fontSize: ParagraphTexts.textFieldLable,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    );
                  }

                  final paymentMethods = snapshot.data ?? [];

                  if (paymentMethods.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                            text: 'No payment methods added',
                            color: Colors.grey[600]!,
                            fontSize: ParagraphTexts.textFieldLable,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(height: 8),
                          CustomText(
                            text: 'Tap + to add your first payment method',
                            color: Colors.grey[500]!,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final paymentMethod = paymentMethods[index];
                      return _buildPaymentMethodCard(paymentMethod);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod paymentMethod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: paymentMethod.isDefault
            ? Border.all(
                color: const Color.fromARGB(255, 213, 167, 66), width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Card type icon
              _buildCardTypeIcon(paymentMethod.type),
              const SizedBox(width: 12),

              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text: paymentMethod.maskedCardNumber,
                          color: AppColors.black,
                          fontSize: ParagraphTexts.textFieldLable,
                          fontWeight: FontWeight.w600,
                        ),
                        if (paymentMethod.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 213, 167, 66),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: paymentMethod.cardHolderName,
                      color: Colors.grey[600]!,
                      fontSize: ParagraphTexts.normalParagraph,
                      fontWeight: FontWeight.w400,
                    ),
                    CustomText(
                      text:
                          'Expires ${paymentMethod.expiryMonth.toString().padLeft(2, '0')}/${paymentMethod.expiryYear.toString().substring(2)}',
                      color: Colors.grey[500]!,
                      fontSize: ParagraphTexts.normalParagraph * 0.9,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, paymentMethod),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (!paymentMethod.isDefault)
                    const PopupMenuItem(
                      value: 'setDefault',
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 18),
                          SizedBox(width: 8),
                          Text('Set as Default'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'mastercard':
        return Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF79E1B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'visa':
        return Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'amex':
        return Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'AMEX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.credit_card,
            color: Colors.white,
            size: 16,
          ),
        );
    }
  }

  void _handleMenuAction(String action, PaymentMethod paymentMethod) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddPaymentMethodPage(
              existingPaymentMethod: paymentMethod,
            ),
          ),
        );
        if (result == true) {
          setState(() {}); // Refresh the list
        }
        break;
      case 'setDefault':
        try {
          await _paymentService.setDefaultPaymentMethod(paymentMethod.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Default payment method updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
      case 'delete':
        _showDeleteConfirmation(paymentMethod);
        break;
    }
  }

  void _showDeleteConfirmation(PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text(
            'Are you sure you want to delete this payment method ending in ${paymentMethod.lastFourDigits}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _paymentService.deletePaymentMethod(paymentMethod.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment method deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
