import 'package:flutter/material.dart';
import 'package:aspire_edge/theme/app_theme.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.stepNumber,
    required this.icon,
    required this.gradient,
    this.isTextOnTop = false,
  }) : super(key: key);

  final String title, description, image;
  final int stepNumber;
  final bool isTextOnTop;
  final IconData icon;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isTextOnTop) ...[
            _buildTextContent(context),
            const SizedBox(height: 48),
            _buildEnhancedImageContent(context),
          ] else ...[
            _buildEnhancedImageContent(context),
            const SizedBox(height: 48),
            _buildTextContent(context),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedImageContent(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * 0.65;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated background orb
        AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                gradient[0].withOpacity(0.15),
                gradient[1].withOpacity(0.05),
              ],
            ),
          ),
        ),

        // Floating elements
        Positioned(
          top: imageSize * 0.1,
          left: imageSize * 0.1,
          child: _buildFloatingElement(0, context),
        ),
        Positioned(
          bottom: imageSize * 0.15,
          right: imageSize * 0.1,
          child: _buildFloatingElement(1, context),
        ),

        // Main image container
        Container(
          width: imageSize * 0.8,
          height: imageSize * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _buildImageWithFallback(imageSize * 0.6),
          ),
        ),

        // Step indicator with icon
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingElement(int index, BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.08;
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000 + (index * 200)),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient[0].withOpacity(0.1),
      ),
    );
  }

  Widget _buildImageWithFallback(double size) {
    return Image.asset(
      image,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: gradient[0].withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            size: size * 0.4,
            color: gradient[0],
          ),
        );
      },
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Enhanced Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 28 : 32,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
                height: 1.2,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Premium Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGrey,
                height: 1.6,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}