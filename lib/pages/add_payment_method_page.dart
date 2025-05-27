import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thriftale/models/payment_method_model.dart';
import 'package:thriftale/services/payment_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';

class AddPaymentMethodPage extends StatefulWidget {
  final PaymentMethod? existingPaymentMethod;

  const AddPaymentMethodPage({super.key, this.existingPaymentMethod});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _cardType = 'visa';
  bool _isDefault = false;
  bool _isLoading = false;

  bool get _isEditing => widget.existingPaymentMethod != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final payment = widget.existingPaymentMethod!;
    _cardNumberController.text = payment.cardNumber;
    _cardHolderController.text = payment.cardHolderName;
    _expiryController.text =
        '${payment.expiryMonth.toString().padLeft(2, '0')}/${payment.expiryYear.toString().substring(2)}';
    _cvvController.text = payment.cvv;
    _cardType = payment.type;
    _isDefault = payment.isDefault;
  }

  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'mastercard';
    } else if (cardNumber.startsWith('3')) {
      return 'amex';
    }
    return 'visa';
  }

  void _onCardNumberChanged(String value) {
    String cleanedValue = value.replaceAll(' ', '');
    if (cleanedValue.isNotEmpty) {
      setState(() {
        _cardType = _detectCardType(cleanedValue);
      });
    }
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse expiry date
      List<String> expiryParts = _expiryController.text.split('/');
      int month = int.parse(expiryParts[0]);
      int year = 2000 + int.parse(expiryParts[1]);

      PaymentMethod paymentMethod = PaymentMethod(
        id: _isEditing ? widget.existingPaymentMethod!.id : '',
        type: _cardType,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolderName: _cardHolderController.text,
        expiryMonth: month,
        expiryYear: year,
        cvv: _cvvController.text,
        isDefault: _isDefault,
        createdAt: _isEditing
            ? widget.existingPaymentMethod!.createdAt
            : DateTime.now(),
      );

      if (_isEditing) {
        await _paymentService.updatePaymentMethod(
            widget.existingPaymentMethod!.id, paymentMethod);
      } else {
        await _paymentService.addPaymentMethod(paymentMethod);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                    text: _isEditing
                        ? 'Edit Payment Method'
                        : 'Add Payment Method',
                    color: AppColors.black,
                    fontSize: LableTexts.subLable,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card preview
                      Container(
                        width: double.infinity,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade800,
                              Colors.blue.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'DEBIT CARD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  _buildCardTypeIcon(),
                                ],
                              ),
                              Text(
                                _cardNumberController.text.isEmpty
                                    ? '**** **** **** ****'
                                    : _formatCardNumber(
                                        _cardNumberController.text),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CARD HOLDER',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        _cardHolderController.text.isEmpty
                                            ? 'YOUR NAME'
                                            : _cardHolderController.text
                                                .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EXPIRES',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        _expiryController.text.isEmpty
                                            ? 'MM/YY'
                                            : _expiryController.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card Number
                      _buildLabel('Card Number'),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          _CardNumberInputFormatter(),
                        ],
                        onChanged: _onCardNumberChanged,
                        decoration:
                            _buildInputDecoration('1234 5678 9012 3456'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          String cleanValue = value.replaceAll(' ', '');
                          if (cleanValue.length < 13 ||
                              cleanValue.length > 16) {
                            return 'Please enter a valid card number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Card Holder Name
                      _buildLabel('Card Holder Name'),
                      TextFormField(
                        controller: _cardHolderController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration('John Doe'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card holder name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Expiry and CVV Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Expiry Date'),
                                TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    _ExpiryDateInputFormatter(),
                                  ],
                                  decoration: _buildInputDecoration('MM/YY'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length != 5) {
                                      return 'Invalid format';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('CVV'),
                                TextFormField(
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: _buildInputDecoration('123'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return 'Invalid CVV';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Set as default checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _isDefault,
                            onChanged: (value) {
                              setState(() {
                                _isDefault = value ?? false;
                              });
                            },
                            activeColor:
                                const Color.fromARGB(255, 213, 167, 66),
                          ),
                          CustomText(
                            text: 'Set as default payment method',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.textFieldLable,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Save Button
                      CustomButton(
                        text: _isLoading
                            ? 'Saving...'
                            : (_isEditing
                                ? 'Update Payment Method'
                                : 'Add Payment Method'),
                        backgroundColor: _isLoading
                            ? Colors.grey
                            : const Color.fromARGB(255, 213, 167, 66),
                        textColor: AppColors.white,
                        textWeight: FontWeight.w600,
                        textSize: ParagraphTexts.textFieldLable,
                        width: double.infinity,
                        height: 52,
                        borderRadius: 50,
                        onPressed:
                            _isLoading ? () {} : () => _savePaymentMethod(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomText(
        text: text,
        color: AppColors.black,
        fontSize: ParagraphTexts.textFieldLable,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: ParagraphTexts.textFieldLable,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromARGB(255, 213, 167, 66)),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildCardTypeIcon() {
    switch (_cardType) {
      case 'mastercard':
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(left: -8),
              decoration: const BoxDecoration(
                color: Color(0xFFF79E1B),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'visa':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatCardNumber(String value) {
    String cleanValue = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cleanValue[i];
    }
    return formatted;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String inputData = newValue.text;
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      int index = i + 1;
      if (index % 4 == 0 && inputData.length != index) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String inputData = newValue.text;
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      int index = i + 1;
      if (index % 2 == 0 && inputData.length != index && index != 4) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ),
    );
  }
}
