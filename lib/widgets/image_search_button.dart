import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/image_search_screen.dart';

class ImageSearchButton extends StatelessWidget {
  final double size;
  final bool showLabel;
  final EdgeInsetsGeometry? margin;

  const ImageSearchButton({
    super.key,
    this.size = 20,
    this.showLabel = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: showLabel
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => const ImageSearchScreen());
              },
              backgroundColor: Colors.pink[600],
              elevation: 4,
              icon: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: size,
              ),
              label: const Text(
                'Search by Image',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[400]!, Colors.pink[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink[200]!.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: size,
                    ),
                    // Optional: Add a small badge indicator for new feature
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                Get.to(() => const ImageSearchScreen());
              },
              tooltip: 'Search by Image',
            ),
    );
  }
}

class ImageSearchCard extends StatelessWidget {
  const ImageSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[100]!, Colors.pink[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.pink[100]!.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search by Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find similar fashion items using photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.pink[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.pink[600],
            size: 16,
          ),
        ],
      ),
    );
  }
}
