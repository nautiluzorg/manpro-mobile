import 'package:flutter/material.dart';

class NextOperatorCard extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String nrp;
  final String division;
  final String section;

  const NextOperatorCard({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.nrp,
    required this.division,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasOperator = name.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double size = MediaQuery.of(context).size.width * 0.18;

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size + 32,
                    height: size + 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size + 14,
                    height: size + 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.25),
                        width: 2,
                      ),
                      color: hasOperator ? null : Colors.grey.shade200,
                    ),
                    child: ClipOval(
                      child: hasOperator
                          ? Image.network(
                              photoUrl,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: size * 0.6,
                                color: Colors.grey,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: size * 0.6,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          hasOperator ? name : 'OPERATOR NAME',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          nrp.isEmpty ? 'ID SAP' : nrp,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          division.isEmpty ? 'Division' : division,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          section.isEmpty ? 'Section' : section,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
