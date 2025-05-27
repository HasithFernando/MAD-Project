import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thriftale/services/checkout_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final CheckoutService _checkoutService = CheckoutService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 246, 246),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomText(
          text: 'Order History',
          color: AppColors.black,
          fontSize: LableTexts.subLable,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _checkoutService.getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'Error loading orders',
                    color: AppColors.black,
                    fontSize: ParagraphTexts.textFieldLable,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: snapshot.error.toString(),
                    color: AppColors.black.withOpacity(0.6),
                    fontSize: ParagraphTexts.normalParagraph,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'No Orders Yet',
                    color: AppColors.black,
                    fontSize: ParagraphTexts.textFieldLable,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: 'Start shopping to see your orders here!',
                    color: AppColors.black.withOpacity(0.6),
                    fontSize: ParagraphTexts.normalParagraph,
                    fontWeight: FontWeight.normal,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderSummary = order['orderSummary'] ?? {};
              final createdAt = order['createdAt'];
              final status = order['status'] ?? 'unknown';

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text:
                              'Order #${order['id'].substring(0, 8).toUpperCase()}',
                          color: AppColors.black,
                          fontSize: ParagraphTexts.textFieldLable,
                          fontWeight: FontWeight.w600,
                        ),
                        _buildStatusChip(status),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Order Date
                    if (createdAt != null)
                      CustomText(
                        text: _formatDate(createdAt),
                        color: AppColors.black.withOpacity(0.6),
                        fontSize: ParagraphTexts.normalParagraph,
                        fontWeight: FontWeight.normal,
                      ),

                    const SizedBox(height: 16),

                    // Order Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Total Amount:',
                          color: AppColors.black,
                          fontSize: ParagraphTexts.normalParagraph,
                          fontWeight: FontWeight.normal,
                        ),
                        CustomText(
                          text:
                              'Rs. ${(orderSummary['total'] ?? 0.0).toStringAsFixed(2)}',
                          color: AppColors.black,
                          fontSize: ParagraphTexts.normalParagraph,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Environmental Impact
                    if (orderSummary['co2Saved'] != null &&
                        orderSummary['co2Saved'] > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'CO₂ Saved:',
                            color: Colors.green.shade700,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.normal,
                          ),
                          CustomText(
                            text:
                                '${(orderSummary['co2Saved'] ?? 0.0).toStringAsFixed(1)} kg',
                            color: Colors.green.shade700,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    if (orderSummary['itemsRescued'] != null &&
                        orderSummary['itemsRescued'] > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Items Rescued:',
                            color: Colors.green.shade700,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.normal,
                          ),
                          CustomText(
                            text: '${orderSummary['itemsRescued']} items',
                            color: Colors.green.shade700,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Action Button
                    GestureDetector(
                      onTap: () => _showOrderDetails(order),
                      child: CustomText(
                        text: 'View Details',
                        color: const Color.fromARGB(255, 213, 167, 66),
                        fontSize: ParagraphTexts.normalParagraph,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        displayText = 'Completed';
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        displayText = 'Pending';
        break;
      case 'payment_failed':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        displayText = 'Failed';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomText(
        text: displayText,
        color: textColor,
        fontSize: ParagraphTexts.normalParagraph * 0.9,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'Unknown date';

      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Unknown date';
      }

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Order Details',
                    color: AppColors.black,
                    fontSize: LableTexts.subLable,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Order details content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add order details here based on your order structure
                    CustomText(
                      text: 'Order ID: ${order['id']}',
                      color: AppColors.black,
                      fontSize: ParagraphTexts.normalParagraph,
                      fontWeight: FontWeight.normal,
                    ),
                    const SizedBox(height: 16),

                    // Add more order details as needed
                    CustomText(
                      text: 'Status: ${order['status']}',
                      color: AppColors.black,
                      fontSize: ParagraphTexts.normalParagraph,
                      fontWeight: FontWeight.normal,
                    ),

                    // You can add more details like items, shipping address, etc.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
