import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/models/payment_method_model.dart';
import 'package:thriftale/models/address_model.dart';
import 'package:thriftale/pages/success.dart';
import 'package:thriftale/pages/cart.dart';
import 'package:thriftale/pages/payment_methods_page.dart';
import 'package:thriftale/pages/add_payment_method_page.dart';
import 'package:thriftale/pages/add_edit_address_page.dart';
import 'package:thriftale/pages/address_list_page.dart';
import 'package:thriftale/services/cart_service.dart';
import 'package:thriftale/services/checkout_service.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:thriftale/services/payment_service.dart';
import 'package:thriftale/services/address_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final CheckoutService _checkoutService = CheckoutService();
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final PaymentService _paymentService = PaymentService();
  final AddressService _addressService = AddressService();
  String? userId; // Made nullable

  bool _isLoadingData = true; // For initial data load
  bool _isProcessingCheckout = false; // For checkout submission

  Map<String, dynamic>? _orderSummary;
  List<Map<String, dynamic>> _cartItems = [];
  List<Product?> _products = [];
  PaymentMethod? _selectedPaymentMethod;
  bool _hasPaymentMethods = false;

  AddressModel? _selectedAddress;
  bool _hasAddresses = false;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog("User not authenticated. Please log in again.",
            shouldPop: true);
      });
    } else {
      userId = currentUser.uid;
      _loadCheckoutData();
    }
  }

  Future<void> _loadCheckoutData() async {
    if (userId == null) return;

    if (mounted) setState(() => _isLoadingData = true);

    try {
      final cartStream = _cartService.getCartItems(userId!);
      final cartSnapshot = await cartStream.first;
      _cartItems = cartSnapshot;

      if (_cartItems.isNotEmpty) {
        final productFutures = _cartItems
            .map((item) => _productService.getProductById(item['productId']));
        _products = await Future.wait(productFutures);
        _orderSummary = await _calculateOrderSummary();
      } else {
        _orderSummary = null;
      }

      // These can run in parallel if independent, or sequentially
      await Future.wait([
        _loadPaymentMethods(),
        _loadShippingAddresses(),
      ]);
    } catch (e) {
      if (mounted) _showErrorDialog('Failed to load checkout data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadShippingAddresses() async {
    if (userId == null) return;
    try {
      AddressModel? defaultAddress = await _addressService.getDefaultAddress();
      if (defaultAddress != null) {
        _selectedAddress = defaultAddress;
        _hasAddresses = true;
      } else {
        final addresses = await _addressService.getAddresses().first;
        if (addresses.isNotEmpty) {
          _selectedAddress =
              addresses.first; // Select the first one if no default
          _hasAddresses = true;
        } else {
          _selectedAddress = null;
          _hasAddresses = false;
        }
      }
    } catch (e) {
      print('Error loading shipping addresses: $e');
      _selectedAddress = null;
      _hasAddresses = false;
    }
    // No setState here, _loadCheckoutData's finally block handles it
  }

  Future<void> _loadPaymentMethods() async {
    if (userId == null) return;
    try {
      final paymentMethodsStream = _paymentService
          .getPaymentMethods(); // Assuming this uses current user
      final paymentMethods = await paymentMethodsStream.first;
      _hasPaymentMethods = paymentMethods.isNotEmpty;

      if (_hasPaymentMethods) {
        _selectedPaymentMethod =
            await _paymentService.getDefaultPaymentMethod();
        if (_selectedPaymentMethod == null && paymentMethods.isNotEmpty) {
          // _selectedPaymentMethod = paymentMethods.first; // Optionally select the first if no default
        }
      } else {
        _selectedPaymentMethod = null;
      }
    } catch (e) {
      print('Error loading payment methods: $e');
      _hasPaymentMethods = false;
      _selectedPaymentMethod = null;
    }
    // No setState here
  }

  Future<Map<String, dynamic>> _calculateOrderSummary() async {
    double subtotal = 0;
    double totalCO2 = 0;
    int itemsRescued = _products
        .where((p) => p != null)
        .length; // Count only non-null products

    for (Product? product in _products) {
      if (product != null) {
        subtotal += product.price;
        totalCO2 += product.co2Saved;
      }
    }

    return {
      'subtotal': subtotal,
      'deliveryFee': 0.0,
      'total': subtotal,
      'co2Saved': totalCO2,
      'itemsRescued': itemsRescued,
    };
  }

  Future<void> _processCheckout() async {
    if (userId == null) {
      _showErrorDialog("User not authenticated. Please log in again.",
          shouldPop: true);
      return;
    }
    if (_orderSummary == null || _cartItems.isEmpty) {
      _showErrorDialog('Your cart is empty.');
      return;
    }
    if (!_hasAddresses || _selectedAddress == null) {
      _showErrorDialog('Please add or select a shipping address.');
      return;
    }
    if (!_hasPaymentMethods || _selectedPaymentMethod == null) {
      _showErrorDialog('Please add or select a payment method.');
      return;
    }

    if (mounted) setState(() => _isProcessingCheckout = true);

    try {
      List<Map<String, dynamic>> orderItems = [];
      for (int i = 0; i < _cartItems.length; i++) {
        final cartItem = _cartItems[i];
        final product =
            _products[i]; // Assumes _products and _cartItems are in sync
        if (product != null) {
          orderItems.add({
            'productId': cartItem['productId'],
            'productName': product.name,
            'price': product.price,
            'co2Saved': product.co2Saved,
            'imageUrl':
                product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
            'location': product.location,
          });
        }
      }

      final paymentMethodData = {
        'type': _selectedPaymentMethod!.type,
        'lastFourDigits': _selectedPaymentMethod!.lastFourDigits,
        'expiryMonth': _selectedPaymentMethod!.expiryMonth,
        'expiryYear': _selectedPaymentMethod!.expiryYear,
        'isDefault': _selectedPaymentMethod!.isDefault,
      };

      final shippingAddressData = _selectedAddress!.toMap();
      // shippingAddressData.remove('id'); // Depending on your backend
      // shippingAddressData.remove('userId'); // Depending on your backend

      final result = await _checkoutService.completeCheckout(
        cartItems: orderItems,
        shippingAddress: shippingAddressData,
        paymentMethod: paymentMethodData,
        totalAmount: _orderSummary!['total'],
        totalCO2Saved: _orderSummary!['co2Saved'],
        itemsRescued: _orderSummary!['itemsRescued'],
      );

      if (result['success']) {
        await _cartService.clearCart(userId!);
        if (mounted) {
          NavigationUtils.frontNavigation(
              // Assuming this works for full-screen replacement
              context,
              Success(
                orderId: result['orderId'],
                totalAmount: _orderSummary!['total'],
                co2Saved: _orderSummary!['co2Saved'],
                itemsRescued: _orderSummary!['itemsRescued'],
              ));
        }
      } else {
        _showErrorDialog(
            result['message'] ?? 'Checkout failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Checkout error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessingCheckout = false);
    }
  }

  void _showErrorDialog(String message, {bool shouldPop = false}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible:
          !shouldPop, // If shouldPop, make it non-dismissible until action
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 10),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (shouldPop) {
                Navigator.of(context)
                    .popUntil((route) => route.isFirst); // Go to home/login
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeIcon(String cardType) {
    // Your existing _buildCardTypeIcon logic
    switch (cardType.toLowerCase()) {
      case 'mastercard':
        return Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
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
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(4.0),
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
      case 'american express':
        return Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: const Center(
            child: Text(
              'AMEX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return Icon(Icons.credit_card, color: AppColors.gray, size: 24);
    }
  }

  Widget _buildAddPaymentMethodSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.Inicator, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Payment Method',
            color: AppColors.black,
            fontSize: ParagraphTexts.textFieldLable,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 16.0),
          InkWell(
            // Make the whole container tappable
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddPaymentMethodPage(),
                ),
              );
              if (result == true && mounted) {
                await _loadPaymentMethods();
                setState(() {});
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.highlightbrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.highlightbrown,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_card,
                    color: AppColors.highlightbrown,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'Add Payment Method',
                    color: AppColors.highlightbrown,
                    fontSize: ParagraphTexts.textFieldLable,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: CustomText(
              text: 'A payment method is required to proceed.',
              color: AppColors.gray,
              fontSize: ParagraphTexts.normalParagraph * 0.9,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingPaymentMethodSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: 'Payment Method',
                color: AppColors.black,
                fontSize: ParagraphTexts.textFieldLable,
                fontWeight: FontWeight.w600,
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsPage(),
                    ),
                  );
                  if (result == true && mounted) {
                    // result can be true if a default was changed or new added
                    await _loadPaymentMethods();
                    setState(() {});
                  }
                },
                child: const CustomText(
                  text: 'Change',
                  color: AppColors.linkColor,
                  fontSize: ParagraphTexts.textFieldLable,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (_selectedPaymentMethod != null) ...[
            Row(
              children: [
                _buildCardTypeIcon(_selectedPaymentMethod!.type),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: _selectedPaymentMethod!.maskedCardNumber,
                        color: AppColors.black,
                        fontSize: ParagraphTexts.textFieldLable,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        text: _selectedPaymentMethod!.cardHolderName,
                        color: AppColors.gray,
                        fontSize: ParagraphTexts.normalParagraph,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Center(
                child: CustomText(
                    text: "No payment method selected.",
                    color: AppColors.gray)),
          ],
        ],
      ),
    );
  }

  Widget _buildShippingAddressDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Shipping address',
          color: AppColors.black,
          fontSize: ParagraphTexts.textFieldLable,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 12.0),
        if (_isLoadingData &&
            _selectedAddress == null) // Still loading initial address
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
                child: Text("Loading address...",
                    style: TextStyle(color: AppColors.gray))),
          )
        else if (_selectedAddress != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: _selectedAddress!.name,
                        color: AppColors.black,
                        fontSize: ParagraphTexts.textFieldLable,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final AddressModel? newAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AddressListPage(isSelectionMode: true)),
                        );
                        if (newAddress != null && mounted) {
                          setState(() {
                            _selectedAddress = newAddress;
                            _hasAddresses = true;
                          });
                        } else if (mounted) {
                          // If newAddress is null (e.g. back button pressed), reload to ensure consistency
                          await _loadShippingAddresses();
                          setState(() {});
                        }
                      },
                      child: const CustomText(
                        text: 'Change',
                        color: AppColors.linkColor,
                        fontSize: ParagraphTexts.textFieldLable,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                CustomText(
                  text: _selectedAddress!.addressLine1,
                  color: AppColors.gray,
                  fontSize: ParagraphTexts.textFieldLable * 0.9,
                ),
                if (_selectedAddress!.addressLine2 != null &&
                    _selectedAddress!.addressLine2!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  CustomText(
                    text: _selectedAddress!.addressLine2!,
                    color: AppColors.gray,
                    fontSize: ParagraphTexts.textFieldLable * 0.9,
                  ),
                ],
                const SizedBox(height: 4.0),
                CustomText(
                  text:
                      '${_selectedAddress!.city}, ${_selectedAddress!.postalCode}',
                  color: AppColors.gray,
                  fontSize: ParagraphTexts.textFieldLable * 0.9,
                ),
                CustomText(
                  text: _selectedAddress!.country,
                  color: AppColors.gray,
                  fontSize: ParagraphTexts.textFieldLable * 0.9,
                ),
                if (_selectedAddress!.phoneNumber != null &&
                    _selectedAddress!.phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  CustomText(
                    text: 'Tel: ${_selectedAddress!.phoneNumber!}',
                    color: AppColors.gray,
                    fontSize: ParagraphTexts.textFieldLable * 0.9,
                  ),
                ],
              ],
            ),
          )
        else // No address selected and not loading (i.e., no addresses exist)
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEditAddressPage()),
              );
              if (result == true && mounted) {
                await _loadShippingAddresses();
                setState(() {});
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.highlightbrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.highlightbrown,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_location_alt_outlined,
                    color: AppColors.highlightbrown,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'Add Shipping Address',
                    color: AppColors.highlightbrown,
                    fontSize: ParagraphTexts.textFieldLable,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        if (!_isLoadingData && !_hasAddresses && _selectedAddress == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
                child: CustomText(
              text: "A shipping address is required to proceed.",
              color: AppColors.gray,
              fontSize: ParagraphTexts.normalParagraph * 0.9,
              textAlign: TextAlign.center,
            )),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null && !_isLoadingData) {
      // Critical: User not logged in and not in initial load
      return Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Authentication Required."),
            SizedBox(height: 20),
            CustomButton(
                text: "Go to Login", // Or Home
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst), // Or your login page
                backgroundColor: AppColors.highlightbrown,
                textColor: AppColors.white,
                textWeight: FontWeight.w600,
                textSize: 16,
                width: 150,
                height: 40,
                borderRadius: 20)
          ],
        ),
      ));
    }

    bool canSubmitOrder = _orderSummary != null &&
        _cartItems.isNotEmpty &&
        _selectedAddress != null &&
        _selectedPaymentMethod != null &&
        !_isProcessingCheckout && // Not currently processing
        !_isLoadingData; // Not in initial data load phase

    return Scaffold(
      backgroundColor: AppColors.lightlightBlue,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : NavigationUtils.frontNavigation(
                            context, const Cart()),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.CardBg.withOpacity(
                              0.5)), // Made CardBg lighter
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CustomText(
                    text: 'Checkout',
                    color: AppColors.black,
                    fontSize: LableTexts.subLable,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingData
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.highlightbrown))
                  : _cartItems.isEmpty && !_isLoadingData
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_checkout_outlined,
                                size: 60, color: AppColors.lightGray),
                            const SizedBox(height: 16),
                            const CustomText(
                                text: 'Your cart is empty.',
                                fontSize: 18,
                                color: AppColors.black),
                            const SizedBox(height: 20),
                            CustomButton(
                              text: 'Go Shopping',
                              onPressed: () => Navigator.popUntil(
                                  context, (route) => route.isFirst),
                              backgroundColor: AppColors.highlightbrown,
                              textColor: AppColors.white,
                              textWeight: FontWeight.w600,
                              textSize: 16,
                              width: 180,
                              height: 50,
                              borderRadius: 25,
                            )
                          ],
                        ))
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                              16.0, 0, 16.0, 16.0), // Adjusted padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShippingAddressDisplay(),
                              const SizedBox(height: 24),
                              const CustomText(
                                text: 'Payment',
                                color: AppColors.black,
                                fontSize: ParagraphTexts.textFieldLable,
                                fontWeight: FontWeight.w600,
                              ),
                              _hasPaymentMethods &&
                                      _selectedPaymentMethod != null
                                  ? _buildExistingPaymentMethodSection()
                                  : _buildAddPaymentMethodSection(),
                              const SizedBox(height: 30),
                              if (_orderSummary != null) ...[
                                const CustomText(
                                  text: 'Order Summary',
                                  color: AppColors.black,
                                  fontSize: ParagraphTexts.textFieldLable,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Order:',
                                    'Rs. ${_orderSummary!['subtotal'].toStringAsFixed(2)}'),
                                const SizedBox(height: 10),
                                _buildSummaryRow(
                                    'Delivery:',
                                    _orderSummary!['deliveryFee'] == 0.0
                                        ? 'Free'
                                        : 'Rs. ${_orderSummary!['deliveryFee'].toStringAsFixed(2)}'),
                                const SizedBox(height: 10),
                                Divider(
                                    color: AppColors.Inicator.withOpacity(0.5)),
                                const SizedBox(height: 10),
                                _buildSummaryRow('Total:',
                                    'Rs. ${_orderSummary!['total'].toStringAsFixed(2)}',
                                    isTotal: true),
                                const SizedBox(height: 15),
                                Divider(
                                    color: AppColors.Inicator.withOpacity(0.5)),
                                const SizedBox(height: 15),
                                _buildSummaryRow('Carbon Saved:',
                                    '${_orderSummary!['co2Saved'].toStringAsFixed(1)} kg'),
                                const SizedBox(height: 10),
                                _buildSummaryRow('Items Rescued:',
                                    '${_orderSummary!['itemsRescued']} items'),
                              ] else if (_isLoadingData)
                                Center(
                                    child: Text("Loading summary...",
                                        style:
                                            TextStyle(color: AppColors.gray))),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
            ),
            if (!_isLoadingData) // Show button area only if initial data load is complete
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  text:
                      _isProcessingCheckout ? 'Processing...' : 'Submit Order',
                  backgroundColor: canSubmitOrder
                      ? AppColors.highlightbrown
                      : AppColors.lightGray,
                  textColor: AppColors.white,
                  textWeight: FontWeight.w600,
                  textSize:
                      ParagraphTexts.textFieldLable, // Ensure this is a double
                  width: double.infinity,
                  height: 52,
                  borderRadius: 50,
                  onPressed: canSubmitOrder
                      ? _processCheckout
                      : () {
                          String message =
                              "Please complete all details to proceed.";
                          if (_orderSummary == null || _cartItems.isEmpty)
                            message = "Your cart is empty. Please add items.";
                          else if (_selectedAddress == null)
                            message =
                                "Please add or select a shipping address.";
                          else if (_selectedPaymentMethod == null)
                            message = "Please add or select a payment method.";
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(message)));
                        },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: label,
          color: isTotal ? AppColors.black : AppColors.gray,
          fontSize: isTotal
              ? ParagraphTexts.normalParagraph * 1.1
              : ParagraphTexts.normalParagraph,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        ),
        CustomText(
          text: value,
          color: AppColors.black,
          fontSize: isTotal
              ? ParagraphTexts.normalParagraph * 1.1
              : ParagraphTexts.normalParagraph,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
