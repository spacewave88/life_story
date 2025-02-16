import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  final String text;
  final String route;
  final Offset startPoint;
  final Offset endPoint;

  const TextLink({
    Key? key,
    required this.text,
    required this.route,
    this.startPoint = Offset.zero,
    this.endPoint = const Offset(0, 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true, context),
      onExit: (_) => _onHover(false, context),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route), // Use Navigator.pushNamed here
        child: Stack(
          children: [
            // Text widget with highlight on hover
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).hoverColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  backgroundColor: Theme.of(context).hoverColor,
                ),
              ),
            ),
            // Line drawing using CustomPaint
            Positioned(
              left: startPoint.dx,
              top: startPoint.dy,
              child: CustomPaint(
                painter: LinePainter(startPoint, endPoint),
                size: Size(endPoint.dx - startPoint.dx, endPoint.dy - startPoint.dy),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHover(bool isHovered, BuildContext context) {
    if (isHovered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hovering over link')),
      );
    } else {
      // Clear any effects when not hovered
    }
  }
}

// Custom painter for drawing a line
class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}