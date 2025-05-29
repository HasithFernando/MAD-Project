import 'package:flutter/material.dart';
import 'package:thriftale/models/address_model.dart';
import 'package:thriftale/services/address_service.dart';
import 'package:thriftale/pages/add_edit_address_page.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';

class AddressListPage extends StatefulWidget {
  final bool isSelectionMode;

  const AddressListPage({Key? key, this.isSelectionMode = false})
      : super(key: key);

  @override
  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressService _addressService = AddressService();

  Future<void> _navigateToAddeEditAddressPage({AddressModel? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressPage(address: address),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child:
                  Text('Delete', style: TextStyle(color: Colors.red.shade700)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _addressService.deleteAddress(addressId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address deleted successfully')),
          );
          // No need to call setState, StreamBuilder will update
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete address: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      await _addressService.setDefaultAddress(addressId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default address updated')),
        );
        // No need to call setState, StreamBuilder will update
        if (widget.isSelectionMode) {
          // If in selection mode, pop with the new default
          final addresses = await _addressService.getAddresses().first;
          final newDefault = addresses.firstWhere((ad) => ad.id == addressId,
              orElse: () => addresses.first);
          Navigator.pop(context, newDefault);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to set default address: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: widget.isSelectionMode ? 'Select Address' : 'My Addresses',
          color: AppColors.black,
          fontSize: LableTexts.subLable,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: _addressService.getAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.highlightbrown));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 60, color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  const CustomText(
                      text: 'No addresses found.',
                      fontSize: 18,
                      color: AppColors.black),
                  const SizedBox(height: 8),
                  CustomText(
                      text: 'Add a new address to get started.',
                      color: AppColors.gray),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Add New Address',
                    onPressed: () => _navigateToAddeEditAddressPage(),
                    backgroundColor: AppColors.highlightbrown,
                    textColor: AppColors.white,
                    textWeight: FontWeight.w600,
                    textSize: 16,
                    width: 220, // Adjusted width for better look
                    height: 50,
                    borderRadius: 25,
                  )
                ],
              ),
            );
          }

          final addresses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return InkWell(
                onTap: widget.isSelectionMode
                    ? () => Navigator.pop(context, address)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: address.isDefault
                        ? Border.all(
                            color: AppColors.highlightbrown, width: 1.5)
                        : Border.all(
                            color: AppColors.Inicator), // Use a lighter border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: CustomText(
                              text: address.name,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                          ),
                          if (address.isDefault)
                            Chip(
                              label: const Text('Default',
                                  style: TextStyle(
                                      fontSize: 10, color: AppColors.white)),
                              backgroundColor: AppColors.highlightbrown,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                          text: address.addressLine1, color: AppColors.gray),
                      if (address.addressLine2 != null &&
                          address.addressLine2!.isNotEmpty)
                        CustomText(
                            text: address.addressLine2!, color: AppColors.gray),
                      CustomText(
                          text: '${address.city}, ${address.postalCode}',
                          color: AppColors.gray),
                      CustomText(text: address.country, color: AppColors.gray),
                      if (address.phoneNumber != null &&
                          address.phoneNumber!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: CustomText(
                              text: 'Tel: ${address.phoneNumber}',
                              color: AppColors.gray),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!address.isDefault &&
                              !widget
                                  .isSelectionMode) // Don't show set default if in selection mode and it's not default
                            TextButton(
                              onPressed: () => _setDefaultAddress(address.id!),
                              child: const CustomText(
                                  text: 'Set Default',
                                  color: AppColors.highlightbrown),
                            ),
                          TextButton(
                            onPressed: () => _navigateToAddeEditAddressPage(
                                address: address),
                            child: const CustomText(
                                text: 'Edit', color: AppColors.linkColor),
                          ),
                          TextButton(
                            onPressed: () => _deleteAddress(address.id!),
                            child: CustomText(
                                text: 'Delete', color: Colors.red.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddeEditAddressPage(),
        label: const CustomText(
            text: 'Add Address',
            color: AppColors.white,
            fontWeight: FontWeight.w600),
        icon:
            const Icon(Icons.add_location_alt_outlined, color: AppColors.white),
        backgroundColor: AppColors.highlightbrown,
      ),
    );
  }
}
