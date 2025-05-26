import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAddingForm extends StatefulWidget {
  const ProductAddingForm({super.key});

  @override
  State<ProductAddingForm> createState() => _ProductAddingFormState();
}

class _ProductAddingFormState extends State<ProductAddingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // Controller for location

  String? _selectedCategory;
  String? _selectedSize;
  Color? _selectedColor;
  final List<File> _selectedImageFiles = [];
  final List<String> _uploadedImageUrls = [];

  final ProductService _productService = ProductService();

  // Variables for seller information
  String? _currentUserId;
  String? _currentUserName;

  // Updated categories for a clothing thrift shop
  final List<String> categories = [
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Footwear',
    'Accessories',
    'Sportswear',
    'Formal Wear',
    'Traditional Wear',
    'Kids Wear',
    'Other Clothing'
  ];
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];
  final List<Color> colors = [
    Colors.red,
    Colors.blue.shade800,
    Colors.green,
    Colors.black,
    Colors.white,
    Colors.brown.shade400,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.yellow,
    Colors.teal,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _fetchSellerInfo();
  }

  // Method to fetch current user's ID and Name
  void _fetchSellerInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      // Prefer displayName, fallback to email, then a default string
      _currentUserName = user.displayName ?? user.email ?? 'Unknown Seller';
    } else {
      // Handle case where user is not logged in (e.g., navigate to login page)
      // For now, setting defaults for demonstration
      _currentUserId = 'anonymous_user_id';
      _currentUserName = 'Anonymous User';
      print('User not logged in. Using default seller info.');
      // You might want to navigate to login or show an error here.
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose(); // Dispose location controller
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImageFiles.add(File(image.path));
      });
    }
  }

  // --- CO2 Calculation Logic ---
  double _calculateCo2Saved() {
    // These are illustrative values (in kg of CO2 equivalent) based on
    // approximate savings from buying secondhand instead of new.
    // Real-world values would require more specific research for different
    // material types, manufacturing processes, and garment lifecycles.
    double co2 = 0.0;

    if (_selectedCategory == null) {
      return 0.0; // Cannot calculate without category
    }

    // Base CO2 savings per category
    switch (_selectedCategory) {
      case 'Tops':
        co2 = 7.0; // e.g., t-shirt, blouse, shirt
        break;
      case 'Bottoms':
        co2 = 12.0; // e.g., jeans, trousers, skirts
        break;
      case 'Dresses':
        co2 = 15.0; // e.g., casual dress, evening gown
        break;
      case 'Outerwear':
        co2 = 25.0; // e.g., jackets, coats, sweaters
        break;
      case 'Footwear':
        co2 = 10.0; // e.g., shoes, boots, sneakers
        break;
      case 'Accessories':
        co2 = 2.0; // e.g., scarves, hats, belts, small bags
        break;
      case 'Sportswear':
        co2 = 9.0; // e.g., activewear, tracksuits
        break;
      case 'Formal Wear':
        co2 = 18.0; // e.g., suits, formal dresses
        break;
      case 'Traditional Wear':
        co2 = 14.0; // e.g., saree, kurta, sarong
        break;
      case 'Kids Wear':
        co2 = 4.0; // generally smaller items
        break;
      case 'Other Clothing':
        co2 = 8.0; // default for other clothing items
        break;
      default:
        co2 = 0.0;
    }

    // Adjust based on size (larger items might have slightly higher embodied carbon)
    if (_selectedSize != null) {
      switch (_selectedSize) {
        case 'M':
          co2 *= 1.05;
          break;
        case 'L':
          co2 *= 1.10;
          break;
        case 'XL':
          co2 *= 1.15;
          break;
        case 'XXL':
          co2 *= 1.20;
          break;
        // XS, S, Free Size might have baseline or slightly lower adjustments
      }
    }

    // You can add more factors here if relevant, e.g., material type if collected.
    return double.parse(co2.toStringAsFixed(2)); // Round to 2 decimal places
  }

  // In product_adding_form.dart
  Future<void> _addProduct() async {
    // ... (initial validation and seller info checks)

    try {
      // ... (show loading snackbar)

      _uploadedImageUrls.clear();

      // Generate a preliminary document ID to use for image storage path AND for the Firestore document itself
      DocumentReference productRef =
          _productService.firestore.collection('products').doc();
      String productId = productRef.id; // This is the ID we will use everywhere

      for (File imageFile in _selectedImageFiles) {
        // Pass the generated productId to the upload function
        String? downloadUrl =
            await _productService.uploadProductImage(imageFile, productId);
        if (downloadUrl != null) {
          _uploadedImageUrls.add(downloadUrl);
        }
      }

      if (_uploadedImageUrls.isEmpty && _selectedImageFiles.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload images. Product not added.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Calculate CO2 saved
      double calculatedCo2Saved = _calculateCo2Saved();

      await _productService.addProduct(
        name: _productNameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        category: _selectedCategory!,
        size: _selectedSize!,
        color: _selectedColor!,
        imageUrls: _uploadedImageUrls,
        sellerId: _currentUserId!,
        sellerName: _currentUserName!,
        location: _locationController.text,
        co2Saved: calculatedCo2Saved,
        productId: productId, // <--- Pass the generated ID here
      );

      // ... (show success snackbar, clear form, navigate)
    } catch (e) {
      // ... (error handling)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            NavigationUtils.frontNavigation(context, const Home());
          },
        ),
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: _selectedImageFiles.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 50,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add product images',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImageFiles.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedImageFiles.length) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                    ),
                                    child: Icon(Icons.add,
                                        color: Colors.grey.shade700),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImageFiles[index],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      width: 100,
                                      child: const Center(
                                        child:
                                            Icon(Icons.broken_image, size: 30),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              if (_selectedImageFiles.isEmpty &&
                  _formKey.currentState?.validate() ==
                      false) // Only show if images are empty and form is invalid
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Please add at least one product image',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Product Name
              _buildTextField(
                controller: _productNameController,
                labelText: 'Product Name',
                hintText: 'e.g., Vintage Denim Jacket',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              _buildTextField(
                controller: _priceController,
                labelText: 'Price (Rs.)',
                hintText: 'e.g., 2500.00',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Tell us about your product...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Input
              _buildTextField(
                controller: _locationController,
                labelText: 'Your Location',
                hintText: 'e.g., Colombo, Kandy, Galle',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Dropdown
              _buildDropdownField(
                labelText: 'Category',
                value: _selectedCategory,
                items: categories,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Size selection
              const Text(
                'Size',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: sizes.map((size) {
                  bool isSelected = _selectedSize == size;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSize = size;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.brown.shade400
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.brown.shade400
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_selectedSize == null &&
                  _formKey.currentState?.validate() ==
                      false) // Only show if size is empty and form is invalid
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Please select a size',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Color selection
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: colors.map((color) {
                  bool isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.brown.shade400
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_selectedColor == null &&
                  _formKey.currentState?.validate() ==
                      false) // Only show if color is empty and form is invalid
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Please select a color',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12),
                  ),
                ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.brown.shade400, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.brown.shade400, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text('Select $labelText'),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
