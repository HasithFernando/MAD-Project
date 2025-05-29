import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String? id; // Document ID from Firestore
  final String userId;
  final String name; // Recipient's name
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String postalCode;
  final String country;
  final String? phoneNumber;
  bool isDefault;

  AddressModel({
    this.id,
    required this.userId,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.country,
    this.phoneNumber,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      addressLine1: data['addressLine1'] ?? '',
      addressLine2: data['addressLine2'],
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      country: data['country'] ?? '',
      phoneNumber: data['phoneNumber'],
      isDefault: data['isDefault'] ?? false,
    );
  }

  // Helper for display
  String get fullAddress {
    List<String> parts = [addressLine1];
    if (addressLine2 != null && addressLine2!.isNotEmpty)
      parts.add(addressLine2!);
    parts.add('$city, $postalCode');
    parts.add(country);
    return parts.join('\n');
  }
}
