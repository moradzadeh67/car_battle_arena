import 'package:flutter/material.dart';

class JoystickOverlay extends StatefulWidget {
  final Function(double x, double y) onChanged;

  const JoystickOverlay({super.key, required this.onChanged});

  @override
  State<JoystickOverlay> createState() => _JoystickOverlayState();
}

class _JoystickOverlayState extends State<JoystickOverlay> {
  Offset _dragPosition = Offset.zero;
  final double _joystickRadius = 60.0;
  final double _knobRadius = 25.0;

  void _updatePosition(Offset localPosition) {
    setState(() {
      final center = Offset(_joystickRadius, _joystickRadius);
      final delta = localPosition - center;
      final distance = delta.distance;

      if (distance <= _joystickRadius) {
        _dragPosition = delta;
      } else {
        _dragPosition = delta * (_joystickRadius / distance);
      }

      // Normalize to -1.0 to 1.0
      widget.onChanged(
        _dragPosition.dx / _joystickRadius,
        -_dragPosition.dy / _joystickRadius, // Invert Y for forward/backward
      );
    });
  }

  void _onDragEnd() {
    setState(() {
      _dragPosition = Offset.zero;
      widget.onChanged(0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _joystickRadius * 2,
      height: _joystickRadius * 2,
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: GestureDetector(
        onPanUpdate: (details) => _updatePosition(details.localPosition),
        onPanEnd: (_) => _onDragEnd(),
        child: Stack(
          children: [
            Positioned(
              left: _joystickRadius + _dragPosition.dx - _knobRadius,
              top: _joystickRadius + _dragPosition.dy - _knobRadius,
              child: Container(
                width: _knobRadius * 2,
                height: _knobRadius * 2,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, spreadRadius: 1)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
