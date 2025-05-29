import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftale/models/address_model.dart';
import 'package:thriftale/services/address_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart'; // Assuming you have this for simple text

class AddEditAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressPage({Key? key, this.address}) : super(key: key);

  @override
  _AddEditAddressPageState createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();
  String? _userId; // Nullable, check before use

  late TextEditingController _nameController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _phoneNumberController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User not authenticated. Please log in again.')),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    _userId = currentUser.uid;

    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _addressLine1Controller =
        TextEditingController(text: widget.address?.addressLine1 ?? '');
    _addressLine2Controller =
        TextEditingController(text: widget.address?.addressLine2 ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _postalCodeController =
        TextEditingController(text: widget.address?.postalCode ?? '');
    _countryController =
        TextEditingController(text: widget.address?.country ?? 'United States');
    _phoneNumberController =
        TextEditingController(text: widget.address?.phoneNumber ?? '');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Authentication error. Please log in again.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final addressToSave = AddressModel(
        id: widget.address?.id,
        userId: _userId!, // We've checked for null
        name: _nameController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isNotEmpty
            ? _addressLine2Controller.text.trim()
            : null,
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isNotEmpty
            ? _phoneNumberController.text.trim()
            : null,
        isDefault: _isDefault,
      );

      try {
        if (widget.address == null) {
          await _addressService.addAddress(addressToSave);
        } else {
          await _addressService.updateAddress(addressToSave);
        }
        if (mounted)
          Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save address: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
              text: label,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.black),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter $label',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              filled: true,
              fillColor: AppColors.lightlightBlue,
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      // If userId wasn't set in initState (e.g., user logged out)
      return Scaffold(body: Center(child: Text("Authentication required.")));
    }
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: widget.address == null ? 'Add New Address' : 'Edit Address',
          color: AppColors.black,
          fontSize: LableTexts.subLable,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField(
                  label: 'Full Name *', controller: _nameController),
              _buildTextField(
                  label: 'Address Line 1 *',
                  controller: _addressLine1Controller),
              _buildTextField(
                  label: 'Address Line 2 (Optional)',
                  controller: _addressLine2Controller,
                  isRequired: false),
              _buildTextField(label: 'City *', controller: _cityController),
              _buildTextField(
                  label: 'Postal Code *', controller: _postalCodeController),
              _buildTextField(
                  label: 'Country *', controller: _countryController),
              _buildTextField(
                  label: 'Phone Number (Optional)',
                  controller: _phoneNumberController,
                  isRequired: false,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: AppColors.highlightbrown,
                  ),
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDefault = !_isDefault;
                          });
                        },
                        child: CustomText(
                          text: 'Set as default address',
                          color: AppColors.black,
                          fontSize: LableTexts.subLable,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: _isLoading ? 'Saving...' : 'Save Address',
                onPressed: _isLoading
                    ? () {}
                    : _saveAddress, // Pass empty lambda if disabled
                backgroundColor:
                    _isLoading ? AppColors.lightGray : AppColors.highlightbrown,
                textColor: AppColors.white,
                textWeight: FontWeight.w600,
                textSize: 16, // Example size
                width: double.infinity,
                height: 50,
                borderRadius: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
