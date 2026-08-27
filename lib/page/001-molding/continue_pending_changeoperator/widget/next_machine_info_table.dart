import 'package:flutter/material.dart';

class NextMachineInfoTable extends StatelessWidget {
  final int sisaShoot;
  final String machineName;
  final String nextOperatorName;

  const NextMachineInfoTable({
    super.key,
    required this.sisaShoot,
    required this.machineName,
    required this.nextOperatorName,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('SISA SHOOT', sisaShoot.toString(), true, null),
      ('MACHINE', machineName, true, null),
      ('NEXT OPERATOR', nextOperatorName, true, Colors.green),
    ];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FixedColumnWidth(20),
          2: FlexColumnWidth(2.8),
        },
        children: List.generate(rows.length, (index) {
          final item = rows[index];
          final bool isEven = index.isEven;

          return _tableRow2(
            label: item.$1,
            value: item.$2,
            isBold: item.$3,
            valueColor: item.$4,
            backgroundColor: isEven
                ? Colors.indigo.shade200.withValues(alpha: 0.15)
                : Colors.white,
          );
        }),
      ),
    );
  }

  TableRow _tableRow2({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
    Color? backgroundColor,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(6),
          child: Text(':', textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
