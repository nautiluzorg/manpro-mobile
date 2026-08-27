import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';

class EmployeePhotoCard extends StatelessWidget {
  final String employeeId;

  const EmployeePhotoCard({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                      color: Colors.greenAccent.withValues(alpha: 0.18),
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
                      color: Colors.greenAccent.withValues(alpha: 0.25),
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
                    color: Colors.blueGrey.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      "${AppConfig.baseUrl}/media/img/employee/$employeeId.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
