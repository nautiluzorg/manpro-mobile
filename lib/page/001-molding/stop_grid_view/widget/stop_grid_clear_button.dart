import 'package:flutter/material.dart';

class StopGridClearButton extends StatelessWidget {
  final VoidCallback onTap;

  const StopGridClearButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.red.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 5,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.clear, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
