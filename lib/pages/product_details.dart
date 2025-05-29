// product_details.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  bool isFavorite = false;
  bool isLoading = false;
  bool isLoadingFavorite = false;

  // Theme colors
  static const Color primaryColor = Color(0xFF8D6E63);
  static const Color successColor = Color(0xFF388E3C);
  static const Color errorColor = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    try {
      setState(() => isLoadingFavorite = true);
      // Mock check - replace with actual favorite check logic
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => isFavorite = false); // Default to false
      }
    } catch (e) {
      _showErrorSnackBar('Failed to check favorite status');
    } finally {
      if (mounted) {
        setState(() => isLoadingFavorite = false);
      }
    }
  }

  String _getTimeAgo(Timestamp? timestamp) {
    try {
      if (timestamp == null) return 'Unknown time';
      final DateTime dateTime = timestamp.toDate();
      return timeago.format(dateTime);
    } catch (e) {
      return 'Unknown time';
    }
  }

  String _formatPrice(double? price) {
    if (price == null) return 'Price unavailable';
    return 'Rs. ${price.toStringAsFixed(2)}';
  }

  void _navigateBack() {
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
            (route) => false,
      );
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() => isLoadingFavorite = true);

      // Mock favorite toggle - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => isFavorite = !isFavorite);
        _showSuccessSnackBar(
            isFavorite ? 'Added to favorites' : 'Removed from favorites'
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update favorites');
    } finally {
      if (mounted) {
        setState(() => isLoadingFavorite = false);
      }
    }
  }

  Future<void> _shareProduct() async {
    try {
      final String shareText = '''
Check out this amazing thrift find!

${widget.product.name ?? 'Product'}
${_formatPrice(widget.product.price)}
Location: ${widget.product.location ?? 'Unknown'}
Saves ${widget.product.co2Saved?.toStringAsFixed(2) ?? '0'}kg CO2

Get it on ThriftTale!
''';

      // Copy to clipboard as alternative to sharing
      await Clipboard.setData(ClipboardData(text: shareText));
      _showSuccessSnackBar('Product details copied to clipboard!');
    } catch (e) {
      _showErrorSnackBar('Failed to share product');
    }
  }

  Future<void> _addToCart() async {
    if (isLoading) return;

    try {
      setState(() => isLoading = true);

      // Mock add to cart - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        _showSuccessSnackBar('Added to cart successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add to cart');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _buyNow() async {
    if (isLoading) return;

    try {
      setState(() => isLoading = true);

      // Mock buy now - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        _showSuccessSnackBar('Proceeding to checkout...');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to process purchase');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return Colors.grey;

    if (colorValue is Color) return colorValue;

    if (colorValue is int) {
      return Color(colorValue);
    }

    if (colorValue is String) {
      try {
        return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _navigateBack,
          ),
          actions: [
            if (isLoadingFavorite)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black,
                ),
                onPressed: _toggleFavorite,
              ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: _shareProduct,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(),
              _buildProductInfo(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.product.imageUrls?.isNotEmpty == true
            ? Image.network(
          widget.product.imageUrls!.first,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            double? progressValue;
            if (loadingProgress.expectedTotalBytes != null) {
              progressValue = loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!;
            }
            return Center(
              child: CircularProgressIndicator(
                value: progressValue,
                color: primaryColor,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Image not available',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        )
            : Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 80, color: Colors.grey),
                SizedBox(height: 8),
                Text('No image available',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final product = widget.product;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Name and CO2 savings
          Row(
            children: [
              Text(
                product.sellerName ?? 'Unknown Seller',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              if (product.co2Saved != null && product.co2Saved! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Saves ${product.co2Saved!.toStringAsFixed(2)}kg CO2',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Product title
          Text(
            product.name ?? 'Unnamed Product',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Location and time
          Text(
            '${product.location ?? 'Unknown location'} • ${_getTimeAgo(product.timestamp)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Price
          Text(
            _formatPrice(product.price),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          // Size section
          if (product.size?.isNotEmpty == true) ...[
            const Text(
              'Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.size!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Color section
          if (product.color != null) ...[
            const Text(
              'Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(product.color),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Quantity selection
          _buildQuantitySelector(),
          const SizedBox(height: 24),

          // Description
          if (product.description?.isNotEmpty == true) ...[
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              product.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove),
                color: quantity > 1 ? Colors.black : Colors.grey,
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _buyNow,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative Product Detail Page (consolidated from your original code)
class ProductDetailPage extends StatefulWidget {
  final String productId;
  final String sellerId;
  final String productName;
  final String productImage;
  final double productPrice;
  final String productDescription;

  const ProductDetailPage({
    Key? key,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isLoading = false;

  Future<void> _addToCart() async {
    setState(() => isLoading = true);

    // Mock add to cart
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart!'),
          backgroundColor: Color(0xFF388E3C),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: widget.productImage.isNotEmpty
                  ? Image.network(
                widget.productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  );
                },
              )
                  : const Center(
                child: Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Text(
                    widget.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.productPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.productDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Add to Cart Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: isLoading
                          ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                          : const Text(
                        'Add to Cart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Product List Item Widget
class ProductListItem extends StatelessWidget {
  final String productId;
  final String sellerId;
  final String productName;
  final String productImage;
  final double productPrice;

  const ProductListItem({
    Key? key,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                productId: productId,
                sellerId: sellerId,
                productName: productName,
                productImage: productImage,
                productPrice: productPrice,
                productDescription: 'Product description goes here...',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: productImage.isNotEmpty
                    ? Image.network(
                  productImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                )
                    : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),

              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${productPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // You can add rating widget here when available
                    const Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
