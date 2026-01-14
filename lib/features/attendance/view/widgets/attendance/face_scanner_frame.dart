import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FaceScannerFrame extends StatefulWidget {
  final Widget child;
  final bool isScanning;
  final bool isSuccess;
  final bool isFailure;
  final String? message;

  const FaceScannerFrame({
    super.key,
    required this.child,
    this.isScanning = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.message,
  });

  @override
  State<FaceScannerFrame> createState() => _FaceScannerFrameState();
}

class _FaceScannerFrameState extends State<FaceScannerFrame> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    if (widget.isScanning) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FaceScannerFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isScanning) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Preview
          SizedBox(
            width: 250.h,
            height: 250.h,
            child: ClipPath(clipper: _FaceScannerClipper(), child: widget.child),
          ),

          // Animated Scanning Line
          if (widget.isScanning && !widget.isSuccess && !widget.isFailure)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  top: (250.h * 0.1) + (250.h * 0.8 * _animationController.value),
                  child: Container(
                    width: 200.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0),
                          Colors.blue,
                          Colors.blue.withOpacity(0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Frame Corners
          CustomPaint(
            size: Size(250.h, 250.h),
            painter: _ScannerFramePainter(
              color: widget.isSuccess
                  ? Colors.green
                  : (widget.isFailure ? Colors.red : Colors.blue),
            ),
          ),

          // Success Overlay
          if (widget.isSuccess)
            _buildStatusOverlay(
              icon: Icons.check_circle,
              color: Colors.green,
              text: widget.message ?? "Success",
            ),

          // Failure Overlay
          if (widget.isFailure)
            _buildStatusOverlay(
              icon: Icons.error,
              color: Colors.red,
              text: widget.message ?? "Not Recognized",
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay({required IconData icon, required Color color, required String text}) {
    return Container(
      width: 250.h,
      height: 250.h,
      decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 80.sp),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceScannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ScannerFramePainter extends CustomPainter {
  final Color color;
  _ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.r
      ..strokeCap = StrokeCap.round;

    final length = size.width * 0.15;
    final radius = 20.r;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, length)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(length, 0),
      paint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - length, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, length),
      paint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - length)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(length, size.height),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - length, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
        ..lineTo(size.width, size.height - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
